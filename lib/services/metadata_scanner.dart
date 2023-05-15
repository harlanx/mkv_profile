import 'package:flutter/foundation.dart';

import '../data/app_data.dart';
import '../models/models.dart';
import '../services/app_services.dart';
import '../utilities/utilities.dart';

class MetadataScanner {
  static final String _mediaInfoDebug =
      "${AppData.exeDir.path}\\data\\flutter_assets\\assets\\mediainfo\\MediaInfo.exe";

  static bool active = false;

  static Future<MediaInfo> video(File file) async {
    var mkvInfoJson =
        await Process.run(AppData.appSettings.mkvMergePath, ['-J', file.path]);
    var mkvInfo = MkvInfo.fromJson(mkvInfoJson.stdout);

    String mediaInfoJson;
    // You can't hot restart with DynamicLibrary.open so use CLI version when debugging.
    // We're using the library version in production because it seems faster than the executable counterpart.
    if (kDebugMode) {
      mediaInfoJson = (await Process.run(_mediaInfoDebug,
              ['--Language=raw', '--Complete', file.path, '--output=JSON']))
          .stdout;
    } else {
      var miw = MediaInfoWrapper(dllPath: AppData.appSettings.mediaInfoPath);
      mediaInfoJson = miw.getJsonInfo(file.path);
      // We need to unload of the dll since it can be changed in the settings on runtime.
      miw.library.unload();
    }

    return MediaInfo.fromJson(mediaInfoJson, mkvInfo);
  }

  static Future<AudioInfo> audio(File file) async {
    String mediaInfoJson;
    if (kDebugMode) {
      mediaInfoJson = (await Process.run(_mediaInfoDebug,
              ['--Language=raw', '--Complete', file.path, '--output=JSON']))
          .stdout;
    } else {
      var miw = MediaInfoWrapper(dllPath: AppData.appSettings.mediaInfoPath);
      mediaInfoJson = miw.getJsonInfo(file.path);
      miw.library.unload();
    }
    var result = MediaInfo.fromJson(mediaInfoJson, null);
    return result.audioInfo.first;
  }

  static Future<TextInfo> subtitle(File file) async {
    String mediaInfoJson;
    if (kDebugMode) {
      mediaInfoJson = (await Process.run(_mediaInfoDebug,
              [file.path, '--Language=raw', '--Complete', '--output=JSON']))
          .stdout;
    } else {
      var miw = MediaInfoWrapper(dllPath: AppData.appSettings.mediaInfoPath);
      mediaInfoJson = miw.getJsonInfo(file.path);
      miw.library.unload();
    }
    var result = MediaInfo.fromJson(mediaInfoJson, null);
    return result.textInfo.first;
  }
}
