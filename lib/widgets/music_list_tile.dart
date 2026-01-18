/// Music List Tile Widget
/// Displays a song in a list format.
/// Handles both network and asset images.
library;

import 'package:flutter/material.dart';

class MusicListTile extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final void Function(Offset position)? onMoreTap;
  final bool isDownloaded;

  const MusicListTile({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.onMoreTap,
    this.isDownloaded = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: _buildImage(),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isDownloaded)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.download_done,
                            size: 14,
                            color: Colors.green.shade400,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            GestureDetector(
              onTapDown: (details) {
                onMoreTap?.call(details.globalPosition);
              },
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.more_vert, color: Colors.grey),
              ),
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
        height: 48,
        width: 48,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _placeholderImage();
        },
      );
    } else {
      return Image.asset(
        image.isNotEmpty ? image : 'assets/images/logo.png',
        height: 48,
        width: 48,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _placeholderImage();
        },
      );
    }
  }

  Widget _placeholderImage() {
    return Container(
      height: 48,
      width: 48,
      color: Colors.grey.shade800,
      child: const Icon(Icons.music_note, color: Colors.white, size: 20),
    );
  }
}
