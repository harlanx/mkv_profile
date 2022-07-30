import 'package:merge2mkv/models/models.dart';
import 'dart:io';

class MetadataScanner {
  static Future<MediaInfo> scan(File file) async {
    String appFolder = Platform.resolvedExecutable;
    appFolder = appFolder.substring(0, appFolder.lastIndexOf("\\"));
    final String mediaInfoDir = "$appFolder\\data\\flutter_assets\\assets\\mediainfo\\MediaInfo.exe";
    var rawJson = await Process.run(mediaInfoDir, ['--Language=raw', '--Full', file.path, '--output=JSON']);
    return MediaInfo.fromRawJson(rawJson.stdout);
  }
}
