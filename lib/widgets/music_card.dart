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
              child: _buildImage(),
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

  Widget _buildImage() {
    // Check if it's a network URL or asset
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return Image.network(
        image,
        height: 140,
        width: 140,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _placeholderImage();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 140,
            width: 140,
            color: Colors.grey.shade800,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.grey.shade400,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      );
    } else {
      // Asset image
      return Image.asset(
        image.isNotEmpty ? image : 'assets/images/logo.png',
        height: 140,
        width: 140,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _placeholderImage();
        },
      );
    }
  }

  Widget _placeholderImage() {
    return Container(
      height: 140,
      width: 140,
      color: Colors.grey.shade800,
      child: const Icon(Icons.music_note, color: Colors.white, size: 40),
    );
  }
}
