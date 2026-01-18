library;

class Artist {
  final String id;
  final String name;
  final String? imageUrl;
  final String? bio;
  final int? songCount;
  final int? followers;

  Artist({
    required this.id,
    required this.name,
    this.imageUrl,
    this.bio,
    this.songCount,
    this.followers,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      imageUrl: json['image'] ?? json['image_url'] ?? json['avatar'],
      bio: json['bio'] ?? json['description'],
      songCount: json['song_count'],
      followers: json['followers'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': imageUrl,
      'bio': bio,
      'song_count': songCount,
      'followers': followers,
    };
  }

  @override
  String toString() => 'Artist(id: $id, name: $name)';
}
