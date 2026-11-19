/// A single DM chat message.
class ChatMessage {
  const ChatMessage({
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.createdAt,
    this.isPending = false,
    this.isRecalled = false,
    this.pendingId,
  });

  final int senderId;
  final int receiverId;
  final String text;

  /// ISO-8601 timestamp string as received from the server.
  final String createdAt;

  /// True when the message was sent locally but not yet acknowledged by server.
  final bool isPending;

  /// True when the sender has recalled this message.
  final bool isRecalled;

  /// Server-assigned or client-epoch id used for ack / update correlation.
  final int? pendingId;

  /// Unique key used for local storage and recall lookup.
  String get messageKey => '${createdAt}_$senderId';

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      senderId: (json['senderId'] ?? json['sender_id'] as num).toInt(),
      receiverId: (json['receiverId'] ?? json['receiver_id'] as num).toInt(),
      text: json['text'] as String? ?? '',
      createdAt: json['createdAt'] ?? json['created_at'] as String? ?? '',
      pendingId: json['id'] != null ? (json['id'] as num).toInt() : null,
    );
  }

  ChatMessage copyWith({bool? isPending, bool? isRecalled, int? pendingId}) {
    return ChatMessage(
      senderId: senderId,
      receiverId: receiverId,
      text: text,
      createdAt: createdAt,
      isPending: isPending ?? this.isPending,
      isRecalled: isRecalled ?? this.isRecalled,
      pendingId: pendingId ?? this.pendingId,
    );
  }
}
