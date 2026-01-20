class User {
  final int id;
  final String email;
  final String? name;
  final String? profileImage;
  final String? phone;
  final bool isPremium;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.profileImage,
    this.phone,
    this.isPremium = false,
    this.createdAt,
    this.updatedAt,
  });

  String get fullName {
    if (name == null || name?.isEmpty == true) {
      return email.split('@').first;
    }
    return (name ?? '').trim();
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      email: json['email'] ?? '',
      name: json['name']?.toString(),
      profileImage: json['profile_image'] ?? json['avatar'],
      phone: json['phone']?.toString(),
      isPremium: json['is_premium'] ?? json['isPremium'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profile_image': profileImage,
      'phone': phone,
      'is_premium': isPremium,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? email,
    String? name,
    String? profileImage,
    String? phone,
    bool? isPremium,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      phone: phone ?? this.phone,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'User(id: $id, email: $email, name: $fullName)';
}
