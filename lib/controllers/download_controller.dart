import 'package:get_storage/get_storage.dart';

class DownloadController {
  final GetStorage storage = GetStorage();

  /// save downloaded song by title
  void downloadSong(String title) {
    List<String> downloadedSongs =
        storage.read('downloadSongs')?.cast<String>() ?? [];

    if (!downloadedSongs.contains(title)) {
      downloadedSongs.add(title);
      storage.write('downloadedSongs', downloadedSongs);
    }
  }

  /// Get all downloaded songs
  List<String> getDownloadedSongs() {
    return storage.read('downloadedSongs')?.cast<String>() ?? [];
  }
}
