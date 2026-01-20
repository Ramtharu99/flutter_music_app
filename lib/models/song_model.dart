class Song {
  final int id;
  final String title;
  final String artist;
  final String? fileUrl;
  final String coverImage;
  final int duration;
  final String? album;
  final String? genre;
  final String price;
  final String description;
  final int playsCount;
  final bool isPurchased;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isDownloaded;
  final String? localPath;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.coverImage,
    required this.duration,
    required this.price,
    required this.description,
    required this.playsCount,
    required this.isPurchased,
    this.fileUrl,
    this.album,
    this.genre,
    this.createdAt,
    this.updatedAt,
    this.isDownloaded = false,
    this.localPath,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title'] ?? '',
      artist: json['artist'] ?? json['artist_name'] ?? '',
      fileUrl: json['file_url'] ?? json['url'] ?? json['audio_url'],
      coverImage:
          json['cover_image'] ??
          json['image'] ??
          json['image_url'] ??
          json['artwork'] ??
          '',
      duration: json['duration'] is int
          ? json['duration']
          : int.tryParse(json['duration']?.toString() ?? '0') ?? 0,
      album: json['album']?.toString(),
      genre: json['genre']?.toString(),
      price: json['price']?.toString() ?? '0.00',
      description: json['description'] ?? '',
      playsCount: json['plays_count'] is int
          ? json['plays_count']
          : int.tryParse(json['plays_count']?.toString() ?? '0') ?? 0,
      isPurchased: json['is_purchased'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      isDownloaded: json['is_downloaded'] ?? false,
      localPath: json['local_path']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'file_url': fileUrl,
      'cover_image': coverImage,
      'duration': duration,
      'album': album,
      'genre': genre,
      'price': price,
      'description': description,
      'plays_count': playsCount,
      'is_purchased': isPurchased,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_downloaded': isDownloaded,
      'local_path': localPath,
    };
  }

  /// Create a copy with some fields changed
  Song copyWith({
    int? id,
    String? title,
    String? artist,
    String? fileUrl,
    String? coverImage,
    int? duration,
    String? album,
    String? genre,
    String? price,
    String? description,
    int? playsCount,
    bool? isPurchased,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDownloaded,
    String? localPath,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      fileUrl: fileUrl ?? this.fileUrl,
      coverImage: coverImage ?? this.coverImage,
      duration: duration ?? this.duration,
      album: album ?? this.album,
      genre: genre ?? this.genre,
      price: price ?? this.price,
      description: description ?? this.description,
      playsCount: playsCount ?? this.playsCount,
      isPurchased: isPurchased ?? this.isPurchased,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      localPath: localPath ?? this.localPath,
    );
  }

  /// Get display duration (formatted)
  String get displayDuration {
    if (duration == 0) return '--:--';
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  String toString() => 'Song(id: $id, title: $title, artist: $artist)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode ^ title.hashCode;
}
