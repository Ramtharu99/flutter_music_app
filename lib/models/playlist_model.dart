/// Playlist Model
/// Data model for playlists.
library;

import 'song_model.dart';

class Playlist {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final List<Song> songs;
  final int songCount;
  final String? createdBy;
  final DateTime? createdAt;

  Playlist({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.songs = const [],
    this.songCount = 0,
    this.createdBy,
    this.createdAt,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    List<Song> songsList = [];
    if (json['songs'] != null) {
      songsList = (json['songs'] as List)
          .map((song) => Song.fromJson(song))
          .toList();
    }

    return Playlist(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      imageUrl: json['image'] ?? json['image_url'],
      songs: songsList,
      songCount: json['song_count'] ?? songsList.length,
      createdBy: json['created_by'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': imageUrl,
      'songs': songs.map((s) => s.toJson()).toList(),
      'song_count': songCount,
      'created_by': createdBy,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  String toString() => 'Playlist(id: $id, name: $name, songs: ${songs.length})';
}
