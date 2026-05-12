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
    return RemoteRoleCard(
      remoteId: row['remote_id'] as String,
      ownerUsername: row['owner_username'] as String,
      character: Character.fromRemoteJson({
        'id': 0,
        'name': row['name'],
        'avatar': row['avatar'],
        'personality': row['personality'],
        'greeting': row['greeting'],
        'myNickname': row['my_nickname'],
        'aiNickname': row['ai_nickname'],
      }),
    );
  }
}
