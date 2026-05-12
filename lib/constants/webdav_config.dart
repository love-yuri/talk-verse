/*
 * @Author: love-yuri yuri2078170658@gmail.com
 * @Date: 2026-05-12 14:03:51
 * @LastEditTime: 2026-05-12 14:15:42
 * @Description: 
 */
/// WebDAV 连接配置
/// 将占位符替换为坚果云 WebDAV 地址、账号和应用密码。
class WebDavConfig {
  static const baseUrl = 'https://dav.jianguoyun.com/dav/';
  static const username = '2078170658@qq.com';
  static const password = 'a8uwd3rk47rf2tdi';

  static const remoteRoot = 'talk-verse';
  static const systemDbPath = '$remoteRoot/system.db';
  static const roleCardDbPath = '$remoteRoot/role_card.db';

  static const requestTimeout = Duration(seconds: 30);
  static const lockTimeoutSeconds = 120;

  static bool get isConfigured =>
      baseUrl.trim().isNotEmpty &&
      username.trim().isNotEmpty &&
      password.trim().isNotEmpty &&
      username != 'YOUR_WEBDAV_USERNAME' &&
      password != 'YOUR_WEBDAV_APP_PASSWORD';
}
