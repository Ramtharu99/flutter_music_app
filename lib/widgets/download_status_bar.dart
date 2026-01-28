import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/controllers/download_controller.dart';

class DownloadStatusBar extends StatelessWidget {
  const DownloadStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DownloadController>(
      builder: (controller) {
        // Don't show if nothing is downloading
        if (controller.downloadingIds.isEmpty) {
          return const SizedBox.shrink();
        }

        // Get the first downloading item
        final downloadingId = controller.downloadingIds.first;
        final progress = controller.getProgress(downloadingId);
        final title = controller.currentDownloadingTitle;

        return Container(
          decoration: BoxDecoration(
            color: Colors.blue.shade900.withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.downloading, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Downloading',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade300,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      controller.cancelDownload(downloadingId);
                    },
                    child: Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
