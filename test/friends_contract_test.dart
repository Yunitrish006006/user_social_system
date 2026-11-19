import 'package:flutter_test/flutter_test.dart';
import 'package:user_social_system/user_social_system.dart';

void main() {
  test('preserves avatar resolution in friends, requests and room invites', () {
    final user = <String, dynamic>{'userId': 7, 'avatarUrl': '/avatar.png'};
    final overview = FriendsOverview.fromJson({
      'friends': [user],
      'incomingRequests': [
        {'id': 1, 'user': user},
      ],
      'roomInvites': [
        {'id': 2, 'roomCode': 'TEST', 'inviter': user},
      ],
    }, resolveAvatar: (url) => 'https://example.test$url');
    expect(
      overview.friends.single.avatarUrl,
      'https://example.test/avatar.png',
    );
    expect(
      overview.incomingRequests.single.user.avatarUrl,
      'https://example.test/avatar.png',
    );
    expect(
      overview.roomInvites.single.inviter.avatarUrl,
      'https://example.test/avatar.png',
    );
    expect(overview.outgoingRequests, isEmpty);
    expect(FriendsDirectory, isA<Type>());
  });
}
