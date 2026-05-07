import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ai_settings.dart';

/// 设置持久化服务
/// 使用 SharedPreferences 存储 AI 设置
class SettingsService {
  static const _key = 'ai_settings';
  static final SettingsService _instance = SettingsService._();
  SettingsService._();
  factory SettingsService() => _instance;

  AiSettings _settings = AiSettings();
  AiSettings get settings => _settings;

  /// 加载设置
  Future<AiSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json != null) {
      _settings = AiSettings.fromJson(jsonDecode(json) as Map<String, dynamic>);
    }
    return _settings;
  }

  /// 保存设置
  Future<void> save(AiSettings settings) async {
    _settings = settings;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(settings.toJson()));
  }
}
