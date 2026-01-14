import 'package:flutter/material.dart';

class MusicCard extends StatelessWidget {
  final String image;
  final String title;
  final String artist;
  final VoidCallback? onTap;

  const MusicCard({
    super.key,
    required this.image,
    required this.title,
    required this.artist,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                image,
                height: 140,
                width: 140,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // fallback if image fails to load
                  return Container(
                    height: 140,
                    width: 140,
                    color: Colors.grey,
                    child: const Icon(Icons.music_note, color: Colors.white),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              artist,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
