import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/controllers/download_controller.dart';
import 'package:music_app/models/song_model.dart';

class MusicListTile extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final void Function(Offset position)? onMoreTap;
  final bool isDownloaded;
  final Song? song;
  final bool selected;
  final VoidCallback? onLongPress;

  const MusicListTile({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.onMoreTap,
    this.isDownloaded = false,
    this.song,
    this.selected = false,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        color: selected ? Colors.blue.withOpacity(0.3) : Colors.transparent,
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
            if (song != null)
              _buildDownloadButton(context)
            else
              const SizedBox(),
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

  Widget _buildDownloadButton(BuildContext context) {
    final downloadController = Get.find<DownloadController>();
    final songId = song!.id.toString();

    return GetBuilder<DownloadController>(
      builder: (_) {
        final isDownloading = downloadController.isDownloading(songId);
        final progress = downloadController.getProgress(songId);

        if (isDownloading) {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              width: 20,
              height: 20,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue.shade400,
                      ),
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 7,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return GestureDetector(
          onTap: () {
            downloadController.downloadSong(song!);
          },
          child: Padding(padding: const EdgeInsets.all(8), child: Text('')),
        );
      },
    );
  }

  Widget _buildImage() {
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
