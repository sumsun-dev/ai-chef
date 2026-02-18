/// 채팅 메시지 역할
enum MessageRole { user, assistant }

/// 채팅 메시지
class ChatMessage {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final bool isLoading;
  final String? userId;
  final String? chefId;

  ChatMessage({
    String? id,
    required this.role,
    required this.content,
    DateTime? timestamp,
    this.isLoading = false,
    this.userId,
    this.chefId,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp = timestamp ?? DateTime.now();

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      role: json['role'] == 'user' ? MessageRole.user : MessageRole.assistant,
      content: json['content'] ?? '',
      timestamp: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      userId: json['user_id'],
      chefId: json['chef_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role == MessageRole.user ? 'user' : 'assistant',
      'content': content,
      'created_at': timestamp.toIso8601String(),
      if (userId != null) 'user_id': userId,
      if (chefId != null) 'chef_id': chefId,
    };
  }

  ChatMessage copyWith({
    String? id,
    MessageRole? role,
    String? content,
    DateTime? timestamp,
    bool? isLoading,
    String? userId,
    String? chefId,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isLoading: isLoading ?? this.isLoading,
      userId: userId ?? this.userId,
      chefId: chefId ?? this.chefId,
    );
  }
}
