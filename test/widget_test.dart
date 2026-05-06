import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talkverse/main.dart';

void main() {
  group('TalkVerse App Tests', () {
    testWidgets('App should render without errors', (WidgetTester tester) async {
      // 构建应用
      await tester.pumpWidget(const TalkVerseApp());

      // 验证底部导航栏标签存在
      expect(find.text('角色'), findsOneWidget);
      expect(find.text('我的'), findsOneWidget);
    });

    testWidgets('Bottom navigation should work', (WidgetTester tester) async {
      // 构建应用
      await tester.pumpWidget(const TalkVerseApp());

      // 点击角色标签
      await tester.tap(find.text('角色'));
      await tester.pumpAndSettle();

      // 验证切换到角色页面
      expect(find.text('角色列表'), findsOneWidget);
    });

    testWidgets('Chat list screen should render', (WidgetTester tester) async {
      // 构建应用
      await tester.pumpWidget(const TalkVerseApp());

      // 验证聊天列表页面包含角色名称
      expect(find.text('小助手'), findsOneWidget);
      expect(find.text('诗人'), findsOneWidget);
      expect(find.text('朋友'), findsOneWidget);
    });
  });
}
