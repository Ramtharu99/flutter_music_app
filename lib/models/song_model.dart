/// Song Model
/// Data model for songs throughout the app.
library;

class Song {
  final String id;
  final String title;
  final String artist;
  final String url;
  final String imageUrl;
  final int? duration; // in seconds
  final String? album;
  final String? genre;
  final bool isDownloaded;
  final String? localPath;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.url,
    required this.imageUrl,
    this.duration,
    this.album,
    this.genre,
    this.isDownloaded = false,
    this.localPath,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      artist: json['artist'] ?? json['artist_name'] ?? '',
      url: json['url'] ?? json['audio_url'] ?? '',
      imageUrl: json['image'] ?? json['image_url'] ?? json['artwork'] ?? '',
      duration: json['duration'],
      album: json['album'],
      genre: json['genre'],
      isDownloaded: json['is_downloaded'] ?? false,
      localPath: json['local_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'url': url,
      'image': imageUrl,
      'duration': duration,
      'album': album,
      'genre': genre,
      'is_downloaded': isDownloaded,
      'local_path': localPath,
    };
  }

  /// Create a copy with some fields changed
  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? url,
    String? imageUrl,
    int? duration,
    String? album,
    String? genre,
    bool? isDownloaded,
    String? localPath,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      duration: duration ?? this.duration,
      album: album ?? this.album,
      genre: genre ?? this.genre,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      localPath: localPath ?? this.localPath,
    );
  }

  /// Get display duration (formatted)
  String get displayDuration {
    if (duration == null) return '--:--';
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  String toString() => 'Song(id: $id, title: $title, artist: $artist)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
