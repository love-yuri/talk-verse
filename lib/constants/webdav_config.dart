/*
 * @Author: love-yuri yuri2078170658@gmail.com
 * @Date: 2026-05-12 14:03:51
 * @LastEditTime: 2026-05-12 14:15:42
 * @Description: 
 */
/// WebDAV 远端路径配置。
class WebDavConfig {
  static const remoteRoot = 'talk-verse';
  static const systemDbPath = '$remoteRoot/system.db';
  static const roleCardDbPath = '$remoteRoot/role_card.db';

  static const requestTimeout = Duration(seconds: 30);
  static const lockTimeoutSeconds = 120;
}
