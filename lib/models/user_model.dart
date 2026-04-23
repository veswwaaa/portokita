class UserModel {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final String? bio;
  final String? kategori;
  
  final List<String> myPortofolios; // id portofolio yang di upload user
  final List<String> likedPortofolios; // id portofolio yang di like user

  //statistik
  final int totalLikes;
  final int totalViews;

  //metadata
  final DateTime createdAt;
  final DateTime updatedAt;

  /// constructor
  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.bio,
    this.kategori,
    this.myPortofolios = const [],
    this.likedPortofolios = const [],
    this.totalLikes = 0,
    this.totalViews = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      username: data['username'] ?? 'Anonymous',
      email: data['email'] ?? '',
      avatarUrl: data['avatarUrl'],
      bio: data['bio'],
      kategori: data['kategori'],
      myPortofolios: List<String>.from(data['myPortfolios'] ?? []),
      likedPortofolios: List<String>.from(data['likedPortfolios'] ?? []),
      totalLikes: data['totalLikes'] ?? 0,
      totalViews: data['totalViews'] ?? 0,
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
      
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'email': email,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'kategori': kategori,
      'myPortfolios': myPortofolios,
      'likedPortfolios': likedPortofolios,
      'totalLikes': totalLikes,
      'totalViews': totalViews,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// copy usermode; dengan perubahan
  UserModel copyWith({
    String? username,
    String? email,
    String? avatarUrl,
    String? bio,
    String? kategori,
    List<String>? myPortfolios,
    List<String>? likedPortfolios,
    int? totalLikes,
    int? totalViews,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      kategori: kategori ?? this.kategori,
      myPortofolios: myPortfolios ?? this.myPortofolios,
      likedPortofolios: likedPortfolios ?? this.likedPortofolios,
      totalLikes: totalLikes ?? this.totalLikes,
      totalViews: totalViews ?? this.totalViews,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}