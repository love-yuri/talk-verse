import 'dart:convert';

import 'character.dart';

/// 远程共享角色卡摘要
class RemoteRoleCard {
  final String remoteId;
  final String ownerUsername;
  final Character character;

  const RemoteRoleCard({
    required this.remoteId,
    required this.ownerUsername,
    required this.character,
  });

  factory RemoteRoleCard.fromRow(Map<String, Object?> row) {
    final characterJson = jsonDecode(row['character_json'] as String) as Map<String, dynamic>;
    return RemoteRoleCard(
      remoteId: row['remote_id'] as String,
      ownerUsername: row['owner_username'] as String,
      character: Character.fromRemoteJson(characterJson),
    );
  }
}
