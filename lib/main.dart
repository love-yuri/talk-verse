/*
 * @Author: love-yuri yuri2078170658@gmail.com
 * @Date: 2026-05-08 14:27:20
 * @LastEditTime: 2026-05-08 14:35:57
 * @Description: 
 */
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'constants/app_colors.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // 桌面端设置默认窗口大小（20:9 手机比例）并居中
  if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
    await windowManager.ensureInitialized();
    const size = Size(412, 715);
    await windowManager.waitUntilReadyToShow(
      const WindowOptions(size: size, center: true),
    );
    await windowManager.setMinimumSize(size);
    await windowManager.setTitle('TalkVerse');
    await windowManager.show();
  }

  runApp(const TalkVerseApp());
}

class TalkVerseApp extends StatelessWidget {
  const TalkVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TalkVerse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
      ),
      home: const MainScreen(),
    );
  }
}
