library;

class User {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? profileImage;
  final String? phone;
  final bool isPremium;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.profileImage,
    this.phone,
    this.isPremium = false,
    this.createdAt,
  });

  String get fullName {
    if (firstName == null && lastName == null) return email.split('@').first;
    return '${firstName ?? ''} ${lastName ?? ''}'.trim();
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? json['firstName'],
      lastName: json['last_name'] ?? json['lastName'],
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
      'first_name': firstName,
      'last_name': lastName,
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
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profileImage: profileImage ?? this.profileImage,
      phone: phone ?? this.phone,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'User(id: $id, email: $email, name: $fullName)';
}
