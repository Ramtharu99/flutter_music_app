import 'package:flutter/material.dart';
import 'package:music_app/models/song_model.dart';
import 'package:music_app/services/offline_storage_service.dart';

enum SongMenuType { all, offline }

class SongMenu {
  static void show(
    BuildContext context,
    Offset position,
    Song song,
    OfflineStorageService offlineStorage, {
    required SongMenuType type,
    Function(Song)? onDelete,
    Function(Song)? onDownload,
  }) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final items = <PopupMenuEntry>[];

    if (type == SongMenuType.all) {
      // Only show Download if song is not downloaded
      if (!offlineStorage.isSongDownloaded(song.id.toString())) {
        items.add(
          PopupMenuItem(
            child: const Text('Download'),
            onTap: () {
              if (onDownload != null) onDownload(song);
            },
          ),
        );
      }
    }

    if (type == SongMenuType.offline) {
      items.add(
        PopupMenuItem(
          child: const Text('Delete'),
          onTap: () {
            if (onDelete != null) onDelete(song);
          },
        ),
      );
    }

    if (items.isEmpty) return;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(position, position),
        Offset.zero & overlay.size,
      ),
      items: items,
    );
  }
}
