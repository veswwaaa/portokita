class UserModel {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final String? bio;
  final String? kategori;
  final String? phoneNumber;
  final String? lokasi;
  final String? kelas;
  
  final List<String> myPortofolios; // id portofolio yang di upload user
  final List<String> likedPortfolios; // id portofolio yang di like user
  final List<String> savedPortfolios; // id portofolio yang di save user

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
    this.phoneNumber,
    this.lokasi,
    this.kelas,
    this.myPortofolios = const [],
    this.likedPortfolios = const [],
    this.savedPortfolios = const [],
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
      phoneNumber: data['phoneNumber'],
      lokasi: data['lokasi'],
      kelas: data['kelas'],
      myPortofolios: List<String>.from(data['myPortfolios'] ?? []),
      likedPortfolios: List<String>.from(data['likedPortfolios'] ?? []),
      savedPortfolios: List<String>.from(data['savedPortfolios'] ?? []),
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
      'phoneNumber': phoneNumber,
      'lokasi': lokasi,
      'kelas': kelas,
      'myPortfolios': myPortofolios,
      'likedPortfolios': likedPortfolios,
      'savedPortfolios': savedPortfolios,
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
    String? phoneNumber,
    String? lokasi,
    String? kelas,
    List<String>? myPortfolios,
    List<String>? likedPortfolios,
    List<String>? savedPortfolios,
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
      phoneNumber: phoneNumber ?? this.phoneNumber,
      lokasi: lokasi ?? this.lokasi,
      kelas: kelas ?? this.kelas,
      myPortofolios: myPortfolios ?? this.myPortofolios,
      likedPortfolios: likedPortfolios ?? this.likedPortfolios,
      savedPortfolios: savedPortfolios ?? this.savedPortfolios,
      totalLikes: totalLikes ?? this.totalLikes,
      totalViews: totalViews ?? this.totalViews,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}