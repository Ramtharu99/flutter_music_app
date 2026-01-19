library;

class User {
  final String id;
  final String email;
  final String? name;
  final String? profileImage;
  final String? phone;
  final bool isPremium;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.profileImage,
    this.phone,
    this.isPremium = false,
    this.createdAt,
  });

  String get fullName {
    if (name == null) return email.split('@').first;
    return (name ?? '').trim();
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? json['name'],
      profileImage: json['profile_image'] ?? json['avatar'],
      phone: json['phone'],
      isPremium: json['is_premium'] ?? json['isPremium'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
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
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? profileImage,
    String? phone,
    bool? isPremium,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: firstName ?? name,
      profileImage: profileImage ?? this.profileImage,
      phone: phone ?? this.phone,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'User(id: $id, email: $email, name: $fullName)';
}
