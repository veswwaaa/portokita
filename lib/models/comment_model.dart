class Comment {
  final String id;
  final String portfolioId;
  final String userId;
  final String username;
  final String? userAvatar;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.portfolioId,
    required this.userId,
    required this.username,
    this.userAvatar,
    required this.text,
    required this.createdAt,
  });

  factory Comment.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Comment(
      id: documentId,
      portfolioId: data['portfolioId'] ?? '',
      userId: data['userId'] ?? '',
      username: data['username'] ?? 'Anonymous',
      userAvatar: data['userAvatar'],
      text: data['text'] ?? '',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'portfolioId': portfolioId,
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'text': text,
      'createdAt': createdAt,
    };
  }
}
