import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/models/song_model.dart';
import 'package:music_app/services/connectivity_service.dart';
import 'package:music_app/services/offline_storage_service.dart';
import 'package:music_app/widgets/empty_state.dart';
import 'package:music_app/widgets/music_list_tile.dart';
import 'package:music_app/widgets/song_menu.dart';

class SongsList extends StatefulWidget {
  final List<Song> songs;
  final OfflineStorageService offlineStorageService;
  final ConnectivityService connectivityService;
  final Function(Song) onSongTap;
  final bool showOfflineOptions;
  final SongMenuType menuType;
  final Function(List<Song>)? onDeleteSelected;

  const SongsList({
    super.key,
    required this.songs,
    required this.offlineStorageService,
    required this.connectivityService,
    required this.onSongTap,
    this.showOfflineOptions = false,
    this.menuType = SongMenuType.all,
    this.onDeleteSelected,
  });

  @override
  State<SongsList> createState() => _SongsListState();
}

class _SongsListState extends State<SongsList> {
  final Set<int> _selectedSongIds = {};

  bool get isMultiSelectMode => _selectedSongIds.isNotEmpty;

  void _toggleSelection(Song song) {
    setState(() {
      if (_selectedSongIds.contains(song.id)) {
        _selectedSongIds.remove(song.id);
      } else {
        _selectedSongIds.add(song.id);
      }
    });
  }

  void _clearSelection() {
    setState(() => _selectedSongIds.clear());
  }

  void _deleteSelected() {
    final selectedSongs = widget.songs
        .where((s) => _selectedSongIds.contains(s.id))
        .toList();

    if (widget.onDeleteSelected != null) {
      widget.onDeleteSelected!(selectedSongs);
    }

    _clearSelection();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.songs.isEmpty) {
      return EmptyState(
        title: 'No Songs Available',
        subtitle: widget.connectivityService.isOffline
            ? 'Connect to internet to load songs'
            : 'Pull to refresh',
      );
    }

    return Column(
      children: [
        if (isMultiSelectMode)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[900],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedSongIds.length} selected',
                  style: const TextStyle(color: Colors.white),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _deleteSelected,
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                    IconButton(
                      onPressed: _clearSelection,
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ...widget.songs.map((song) {
          final isSelected = _selectedSongIds.contains(song.id);
          final isDownloaded = widget.offlineStorageService.isSongDownloaded(
            song.id.toString(),
          );

          return MusicListTile(
            image: song.coverImage.isNotEmpty
                ? song.coverImage
                : 'assets/images/logo.png',
            title: song.title,
            subtitle: song.artist,
            song: song,
            selected: isSelected,
            isDownloaded: false,
            // Hide tick & download in list
            onTap: () {
              if (isMultiSelectMode) {
                _toggleSelection(song);
                return;
              }
              if (widget.connectivityService.isOffline && !isDownloaded) {
                Get.snackbar(
                  'Offline',
                  'This song is not available offline',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }
              widget.onSongTap(song);
            },
            onLongPress: () => _toggleSelection(song),
            onMoreTap: (position) {
              SongMenu.show(
                context,
                position,
                song,
                widget.offlineStorageService,
                type: widget.menuType,
                onDelete: (s) {
                  if (widget.onDeleteSelected != null) {
                    widget.onDeleteSelected!([s]);
                  }
                  setState(() {
                    _selectedSongIds.remove(s.id);
                  });
                },
                onDownload: (s) async {
                  await widget.offlineStorageService.saveDownloadedSong(s);
                  Get.snackbar(
                    'Downloaded',
                    '${s.title} downloaded successfully',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  setState(() {}); // refresh UI
                },
              );
            },
          );
        }).toList(),
      ],
    );
  }
}
