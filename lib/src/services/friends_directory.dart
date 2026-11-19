import '../models/friends_models.dart';

/// Authenticated friends operations supplied by the host app.
abstract interface class FriendsDirectory {
  Future<FriendsOverview> fetchOverview();
  Future<List<FriendSearchResult>> searchByName(String query);
  Future<void> sendFriendRequest(int targetUserId);
  Future<void> acceptFriendRequest(int requestId);
  Future<void> rejectFriendRequest(int requestId);
  Future<void> cancelFriendRequest(int requestId);
  Future<void> removeFriend(int targetUserId);
  Future<void> blockUser(int targetUserId);
  Future<void> unblockUser(int targetUserId);
}
