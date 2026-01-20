import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/music_controller.dart';
import '../models/song_model.dart';

class ArtistSongsScreen extends StatelessWidget {
  final String artist;
  final List<Map<String, dynamic>> songs;

  const ArtistSongsScreen({
    super.key,
    required this.artist,
    required this.songs,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text('$artist Songs'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: ListView.builder(
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
          return ListTile(
            leading: Image.network(
              song['image'],
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey,
                  child: const Icon(Icons.music_note, color: Colors.white),
                );
              },
            ),
            title: Text(
              song['title'],
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              song['artist'],
              style: TextStyle(color: Colors.grey.shade400),
            ),
            onTap: () {
              final songObjects = songs
                  .map((song) => Song.fromJson(song))
                  .toList();
              MusicController.playPlaylist(
                songs: songObjects,
                startIndex: index,
              );
            },
          );
        },
      ),
    );
  }
}
