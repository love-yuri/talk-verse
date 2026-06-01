import 'package:shared_preferences/shared_preferences.dart';

/// WebDAV 连接配置。
class WebDavConnectionConfig {
  final String baseUrl;
  final String username;
  final String password;

  /// 创建 WebDAV 连接配置。
  const WebDavConnectionConfig({
    required this.baseUrl,
    required this.username,
    required this.password,
  });

  /// 是否已经填写完整配置。
  bool get isConfigured =>
      baseUrl.trim().isNotEmpty &&
      username.trim().isNotEmpty &&
      password.trim().isNotEmpty;

  /// 返回去除首尾空白后的配置。
  WebDavConnectionConfig normalized() {
    return WebDavConnectionConfig(
      baseUrl: baseUrl.trim(),
      username: username.trim(),
      password: password.trim(),
    );
  }
}

/// WebDAV 配置持久化服务。
class WebDavConfigService {
  static const _baseUrlKey = 'webdav_base_url';
  static const _usernameKey = 'webdav_username';
  static const _passwordKey = 'webdav_password';

  static final WebDavConfigService _instance = WebDavConfigService._();
  WebDavConfigService._();
  factory WebDavConfigService() => _instance;

  WebDavConnectionConfig? _cache;

  /// 读取 WebDAV 配置。
  Future<WebDavConnectionConfig> load() async {
    if (_cache != null) return _cache!;
    final prefs = await SharedPreferences.getInstance();
    final config = WebDavConnectionConfig(
      baseUrl: prefs.getString(_baseUrlKey) ?? '',
      username: prefs.getString(_usernameKey) ?? '',
      password: prefs.getString(_passwordKey) ?? '',
    ).normalized();
    _cache = config;
    return config;
  }

  /// 保存 WebDAV 配置。
  Future<void> save(WebDavConnectionConfig config) async {
    final normalized = config.normalized();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, normalized.baseUrl);
    await prefs.setString(_usernameKey, normalized.username);
    await prefs.setString(_passwordKey, normalized.password);
    _cache = normalized;
  }

  /// 清空 WebDAV 配置。
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_baseUrlKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_passwordKey);
    _cache = const WebDavConnectionConfig(
      baseUrl: '',
      username: '',
      password: '',
    );
  }

  /// 当前是否已经配置 WebDAV。
  Future<bool> isConfigured() async => (await load()).isConfigured;
}
