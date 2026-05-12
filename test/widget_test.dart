import 'package:flutter_test/flutter_test.dart';
import 'package:talkverse/main.dart';
import 'package:talkverse/services/database_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await DatabaseHelper().initInMemory();
  });

  group('TalkVerse App Tests', () {
    testWidgets('App should render without errors', (WidgetTester tester) async {
      await tester.pumpWidget(const TalkVerseApp());
      expect(find.text('对话'), findsOneWidget);
      expect(find.text('我的'), findsOneWidget);
    });

    testWidgets('Chat list screen should render', (WidgetTester tester) async {
      await tester.pumpWidget(const TalkVerseApp());
      expect(find.text('还没有对话'), findsOneWidget);
      expect(find.text('去发现页面，找到你的第一个聊天伙伴'), findsOneWidget);
    });
  });
}
