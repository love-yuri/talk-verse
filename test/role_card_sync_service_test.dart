import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talkverse/models/character.dart';
import 'package:talkverse/models/chat_session.dart';
import 'package:talkverse/models/user_session.dart';
import 'package:talkverse/services/auth_service.dart';
import 'package:talkverse/services/character_storage_service.dart';
import 'package:talkverse/services/chat_storage_service.dart';
import 'package:talkverse/services/database_helper.dart';
import 'package:talkverse/services/remote_database_service.dart';
import 'package:talkverse/services/role_card_sync_service.dart';

class _FakeRemoteDatabaseService extends RemoteDatabaseService {
  final File file;

  _FakeRemoteDatabaseService(this.file);

  @override
  Future<File> getDatabase(RemoteDatabaseKind kind) async => file;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late File remoteFile;

  setUp(() async {
    await DatabaseHelper().initInMemory();

    final session = UserSession(
      userId: 1,
      username: 'tester',
      loginAt: DateTime(2026),
    );
    SharedPreferences.setMockInitialValues({
      'auth_session': jsonEncode(session.toJson()),
    });
    await AuthService().loadSession();

    final remoteDir = await Directory.systemTemp.createTemp('talkverse_test_');
    remoteFile = File('${remoteDir.path}${Platform.pathSeparator}role_card.db');
    final remoteDb = await databaseFactory.openDatabase(remoteFile.path);
    try {
      await remoteDb.execute('''
        CREATE TABLE shared_role_cards (
          remote_id TEXT PRIMARY KEY,
          owner_username TEXT NOT NULL,
          name TEXT NOT NULL,
          avatar TEXT NOT NULL,
          personality TEXT NOT NULL,
          greeting TEXT DEFAULT '',
          my_nickname TEXT DEFAULT '冒险者',
          ai_nickname TEXT DEFAULT ''
        )
      ''');
    } finally {
      await remoteDb.close();
    }
  });

  tearDown(() async {
    if (await remoteFile.exists()) {
      await remoteFile.parent.delete(recursive: true);
    }
  });

  test(
    'remote-deleted cards with chat records become local, others are removed',
    () async {
      final characterStorage = CharacterStorageService();
      final chatStorage = ChatStorageService();
      final localDb = DatabaseHelper().db;

      final withChatId = await characterStorage.save(
        Character(
          id: 0,
          name: 'With Chat',
          avatar: 'assets/images/default_avatar.png',
          personality: 'kind',
          greeting: '',
        ),
      );
      await localDb.insert('character_sync_meta', {
        'local_character_id': withChatId,
        'remote_id': 'remote-with-chat',
        'owner_username': 'tester',
        'last_synced_at': DateTime.now().toIso8601String(),
      });
      await chatStorage.saveSession(
        ChatSession(
          id: 0,
          characterId: withChatId,
          characterName: 'With Chat',
          characterAvatar: 'assets/images/default_avatar.png',
        ),
      );

      final withoutChatId = await characterStorage.save(
        Character(
          id: 0,
          name: 'Without Chat',
          avatar: 'assets/images/default_avatar.png',
          personality: 'quiet',
          greeting: '',
        ),
      );
      await localDb.insert('character_sync_meta', {
        'local_character_id': withoutChatId,
        'remote_id': 'remote-without-chat',
        'owner_username': 'tester',
        'last_synced_at': DateTime.now().toIso8601String(),
      });

      final result = await RoleCardSyncService(
        authService: AuthService(),
        characterStorage: characterStorage,
        remoteDb: _FakeRemoteDatabaseService(remoteFile),
      ).syncRemoteToLocal();

      expect(result.inserted, 0);
      expect(result.updated, 0);
      expect(result.localized, 1);
      expect(result.removed, 1);

      final withChat = await characterStorage.loadById(withChatId);
      final withoutChat = await characterStorage.loadById(withoutChatId);
      final metas = await localDb.query('character_sync_meta');

      expect(withChat, isNotNull);
      expect(withoutChat, isNull);
      expect(metas, isEmpty);
    },
  );
}
