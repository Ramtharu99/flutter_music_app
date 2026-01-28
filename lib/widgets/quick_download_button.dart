import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/controllers/download_controller.dart';
import 'package:music_app/models/song_model.dart';

class QuickDownloadButton extends StatelessWidget {
  final Song song;
  final Size size;
  final Color? color;

  const QuickDownloadButton({
    super.key,
    required this.song,
    this.size = const Size(40, 40),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final downloadController = Get.find<DownloadController>();
    final songId = song.id.toString();

    return GetBuilder<DownloadController>(
      builder: (_) {
        final isDownloading = downloadController.isDownloading(songId);
        final progress = downloadController.getProgress(songId);
        final isDownloaded = downloadController.isSongDownloaded(songId);

        return GestureDetector(
          onTap: isDownloaded
              ? null
              : isDownloading
              ? null
              : () {
                  downloadController.downloadSong(song);
                },
          child: Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (color ?? Colors.blue.shade400).withOpacity(
                isDownloading || isDownloaded ? 1 : 0.2,
              ),
            ),
            child: isDownloaded
                ? Icon(
                    Icons.check,
                    color: Colors.green.shade400,
                    size: size.width * 0.5,
                  )
                : isDownloading
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: size.width * 0.7,
                        height: size.height * 0.7,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            color ?? Colors.blue.shade400,
                          ),
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * 0.2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Icon(
                    Icons.download,
                    color: color ?? Colors.blue.shade400,
                    size: size.width * 0.5,
                  ),
          ),
        );
      },
    );
  }
}
