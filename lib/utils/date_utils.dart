import 'package:intl/intl.dart';

/// 日期工具类
/// 提供日期格式化和处理功能
class AppDateUtils {
  /// 格式化时间为聊天时间显示
  /// 今天显示时间，昨天显示"昨天"，其他显示日期
  static String formatChatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (messageDate == yesterday) {
      return '昨天';
    } else if (now.difference(dateTime).inDays < 7) {
      return DateFormat('EEEE', 'zh_CN').format(dateTime);
    } else {
      return DateFormat('MM/dd').format(dateTime);
    }
  }

  /// 格式化完整日期时间
  static String formatFullDateTime(DateTime dateTime) {
    return DateFormat('yyyy年MM月dd日 HH:mm').format(dateTime);
  }

  /// 格式化日期
  static String formatDate(DateTime dateTime) {
    return DateFormat('yyyy年MM月dd日').format(dateTime);
  }

  /// 格式化时间
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  /// 获取相对时间描述
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return formatDate(dateTime);
    }
  }
}
