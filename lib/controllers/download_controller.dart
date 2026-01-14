import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class DownloadController extends GetxController {
  final GetStorage storage = GetStorage();

  static const String key = 'downloadedSongs';

  List<String> getDownloadedSongs() {
    return storage.read(key)?.cast<String>() ?? [];
  }

  void downloadSong(String title) {
    final songs = getDownloadedSongs();

    if (!songs.contains(title)) {
      songs.add(title);
      storage.write(key, songs);
      update();
    }
  }

  void removeSong(String title) {
    final songs = getDownloadedSongs();
    songs.remove(title);
    storage.write(key, songs);
    update();
  }
}
