import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../constants/webdav_config.dart';

/// WebDAV 同步异常
class WebDavException implements Exception {
  final String message;
  final int? statusCode;
  final Object? cause;

  const WebDavException(this.message, {this.statusCode, this.cause});

  @override
  String toString() => message;
}

/// WebDAV 基础服务
class WebDavService {
  final http.Client _client;

  WebDavService({http.Client? client}) : _client = client ?? http.Client();

  /// 确保远程目录存在
  Future<void> ensureRemoteDirectory() async {
    _ensureConfigured();
    final response = await _send('MKCOL', WebDavConfig.remoteRoot, headers: _authHeaders(), allowBody: false);
    if (response.statusCode == 201 || response.statusCode == 405) return;
    if (response.statusCode == 301 || response.statusCode == 302) return;
    _throwForStatus(response, '创建远程目录失败');
  }

  /// 下载远程文件到临时目录
  Future<File> download(String remotePath, {String? localName}) async {
    _ensureConfigured();
    final response = await _client
        .get(_remoteUri(remotePath), headers: _authHeaders())
        .timeout(WebDavConfig.requestTimeout);

    if (response.statusCode == 404) {
      throw WebDavException('远程文件不存在', statusCode: response.statusCode);
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwForStatus(response, '下载远程文件失败');
    }

    final dir = await getTemporaryDirectory();
    final name = localName ?? '${DateTime.now().microsecondsSinceEpoch}_${remotePath.split('/').last}';
    final file = File('${dir.path}${Platform.pathSeparator}$name');
    await file.writeAsBytes(response.bodyBytes, flush: true);
    return file;
  }

  /// 上传本地文件到远程
  Future<void> upload(String remotePath, File file, {String? lockToken}) async {
    _ensureConfigured();
    final headers = {
      ..._authHeaders(),
      'Content-Type': 'application/octet-stream',
      if (lockToken != null) 'If': '($lockToken)',
    };
    final response = await _client
        .put(_remoteUri(remotePath), headers: headers, body: await file.readAsBytes())
        .timeout(WebDavConfig.requestTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwForStatus(response, '上传远程文件失败');
    }
  }

  /// 锁定远程文件
  Future<String> lock(String remotePath) async {
    _ensureConfigured();
    final response = await _send(
      'LOCK',
      remotePath,
      headers: {
        ..._authHeaders(),
        'Depth': '0',
        'Timeout': 'Second-${WebDavConfig.lockTimeoutSeconds}',
        'Content-Type': 'application/xml; charset=utf-8',
      },
      body: '''<?xml version="1.0" encoding="utf-8" ?>
<D:lockinfo xmlns:D="DAV:">
  <D:lockscope><D:exclusive/></D:lockscope>
  <D:locktype><D:write/></D:locktype>
  <D:owner>TalkVerse</D:owner>
</D:lockinfo>''',
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwForStatus(response, '锁定远程文件失败');
    }

    final headerToken = response.headers['lock-token'];
    if (headerToken != null && headerToken.trim().isNotEmpty) {
      return headerToken.trim();
    }

    final match = RegExp(r'opaquelocktoken:[^<\s]+').firstMatch(response.body);
    if (match != null) return '<${match.group(0)}>';
    throw const WebDavException('无法读取 WebDAV 锁令牌');
  }

  /// 解锁远程文件
  Future<void> unlock(String remotePath, String lockToken) async {
    final response = await _send(
      'UNLOCK',
      remotePath,
      headers: {
        ..._authHeaders(),
        'Lock-Token': lockToken,
      },
      allowBody: false,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwForStatus(response, '解锁远程文件失败');
    }
  }

  /// 在 WebDAV 锁内执行操作
  Future<T> withLock<T>(String remotePath, Future<T> Function(String lockToken) action) async {
    final lockToken = await lock(remotePath);
    try {
      return await action(lockToken);
    } finally {
      try {
        await unlock(remotePath, lockToken);
      } on WebDavException {
        // 锁会在服务端超时后自动释放。
      }
    }
  }

  Uri _remoteUri(String remotePath) {
    final normalizedBase = WebDavConfig.baseUrl.endsWith('/') ? WebDavConfig.baseUrl : '${WebDavConfig.baseUrl}/';
    final normalizedPath = remotePath.startsWith('/') ? remotePath.substring(1) : remotePath;
    return Uri.parse(normalizedBase).resolve(normalizedPath);
  }

  Map<String, String> _authHeaders() {
    final token = base64Encode(utf8.encode('${WebDavConfig.username}:${WebDavConfig.password}'));
    return {'Authorization': 'Basic $token'};
  }

  Future<http.Response> _send(
    String method,
    String remotePath, {
    Map<String, String>? headers,
    String? body,
    bool allowBody = true,
  }) async {
    final request = http.Request(method, _remoteUri(remotePath));
    request.headers.addAll(headers ?? const {});
    if (allowBody && body != null) request.body = body;
    final streamed = await _client.send(request).timeout(WebDavConfig.requestTimeout);
    return http.Response.fromStream(streamed);
  }

  void _ensureConfigured() {
    if (!WebDavConfig.isConfigured) {
      throw const WebDavException('请先在 webdav_config.dart 中填写坚果云 WebDAV 配置');
    }
  }

  Never _throwForStatus(http.Response response, String prefix) {
    final message = switch (response.statusCode) {
      401 || 403 => 'WebDAV 认证失败，请检查账号或应用密码',
      404 => '远程文件不存在',
      409 => '远程目录不存在',
      423 => '云端文件正在被其他设备使用，请稍后再试',
      >= 500 => 'WebDAV 服务器暂时不可用',
      _ => '$prefix：HTTP ${response.statusCode}',
    };
    throw WebDavException(message, statusCode: response.statusCode);
  }
}
