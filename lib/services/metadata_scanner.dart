import 'dart:io';
import 'package:merge2mkv/models/models.dart';
import 'package:merge2mkv/services/mediainfo_wrapper.dart';

class MetadataScanner {
  static Future<MediaInfo> scanViaCLI(File file) async {
    String appFolder = File(Platform.resolvedExecutable).parent.path;
    final String mediaInfoDir =
        "$appFolder\\data\\flutter_assets\\assets\\mediainfo\\MediaInfo.exe";
    var rawJson = await Process.run(
        mediaInfoDir, ['--Language=raw', '--Full', file.path, '--output=JSON']);
    return MediaInfo.fromRawJson(rawJson.stdout);
  }

  static Future<MediaInfo> scanViaDLL(File file) async {
    final mediaInfoWrapper = MediaInfoWrapper();
    mediaInfoWrapper.open(file.path);
    final info = mediaInfoWrapper.getJsonInfo();
    mediaInfoWrapper.close();
    return MediaInfo.fromRawJson(
        info.split('\n').where((line) => line.trim().isNotEmpty).join());
  }
}
