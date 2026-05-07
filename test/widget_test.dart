import 'package:flutter_test/flutter_test.dart';
import 'package:talkverse/main.dart';

void main() {
  group('TalkVerse App Tests', () {
    testWidgets('App should render without errors', (WidgetTester tester) async {
      await tester.pumpWidget(const TalkVerseApp());
      expect(find.text('发现'), findsOneWidget);
      expect(find.text('我的'), findsOneWidget);
    });

    testWidgets('Chat list screen should render', (WidgetTester tester) async {
      await tester.pumpWidget(const TalkVerseApp());
      expect(find.text('小助手'), findsOneWidget);
      expect(find.text('诗人'), findsOneWidget);
      expect(find.text('朋友'), findsOneWidget);
    });
  });
}
