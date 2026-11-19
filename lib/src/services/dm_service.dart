import '../models/chat_message.dart';

/// Abstract service for DM chat operations.
///
/// Throw [UserSystemException] (from `exceptions.dart`) for user-facing errors.
///
/// Example implementation:
/// ```dart
/// class MyDmService implements DmService {
///   final _controller = StreamController<ChatMessage>.broadcast();
///
///   @override
///   Stream<ChatMessage> get messageStream => _controller.stream;
///   // ...
/// }
/// ```
abstract class DmService {
  /// Stream of incoming [ChatMessage]s for the active conversation.
  Stream<ChatMessage> get messageStream;

  /// Fetch stored chat history for the given conversation.
  Future<List<ChatMessage>> fetchHistory(int selfId, int friendId);

  /// Force-fetch history from the server and merge with local cache.
  Future<List<ChatMessage>> syncFromServer(int selfId, int friendId);

  /// Send a text message to [friendId].
  Future<void> sendMessage(int friendId, String text);

  /// Recall a previously sent message.
  Future<void> recallMessage(ChatMessage message);

  /// Upload local chat history to server for cross-device sync.
  Future<void> uploadSyncData(int selfId, int friendId);

  /// Download and merge chat history from server.
  Future<void> downloadAndMergeSyncData(int friendId);

  /// Establish a polling/socket connection to a DM conversation.
  Future<void> connectToDm(int selfId, int friendId, {bool isCaller = true});

  /// Disconnect from the current conversation.
  void disconnect();
}
