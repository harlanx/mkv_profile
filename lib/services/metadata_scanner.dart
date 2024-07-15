import 'package:flutter/foundation.dart';
//import 'package:flutter/services.dart';

import '../data/app_data.dart';
import '../models/models.dart';
import '../services/app_services.dart';
import '../utilities/utilities.dart';

class MetadataScanner {
  static final String _mediaInfoDebug =
      '${AppData.exeDir.path}\\data\\flutter_assets\\assets\\mediainfo\\MediaInfo.exe';

  static bool active = false;
  static late MediaInfoWrapper _miw;

  static void load() {
    // You can't hot restart with a loaded dll using DynamicLibrary.open unless it is unloaded which is why
    // we implemented the unload for DynamicLibrary in extensions. You can still use CLI version when debugging.
    // We're using the library version in production because it seems faster than the executable counterpart.
    _miw = MediaInfoWrapper(dllPath: AppData.appSettings.mediaInfoPath);
  }

  // We need to unload of the dll since it can be changed in the settings on runtime.
  static void unload() {
    _miw.library.close();
  }

  static Future<MediaInfo> video(File file) async {
    final mkvInfoJson =
        await Process.run(AppData.appSettings.mkvMergePath, ['-J', file.path]);

    final mkvInfo = MkvInfo.fromJson(mkvInfoJson.stdout);
    // print(mkvInfoJson.stdout);

    String? mediaInfoJson;
    if (kReleaseMode) {
      mediaInfoJson ??= _miw.getJsonInfo(file.path);
    }

    // Fallback if library's inform doesn't work sometimes
    mediaInfoJson ??= ((await Process.run(
      _mediaInfoDebug,
      ['--Language=raw', '--Complete', '--output=JSON', file.path],
      stdoutEncoding: const Utf8Codec(),
    ))
        .stdout as String);
    // await Clipboard.setData(ClipboardData(text: mediaInfoJson));
    // print(mediaInfoJson);
    return MediaInfo.fromJson(mediaInfoJson, mkvInfo);
  }

  static Future<AudioInfo> audio(File file) async {
    String? mediaInfoJson;
    if (kReleaseMode) {
      mediaInfoJson ??= _miw.getJsonInfo(file.path);
    }

    mediaInfoJson ??= ((await Process.run(_mediaInfoDebug,
            ['--Language=raw', '--Complete', '--output=JSON', file.path]))
        .stdout as String);

    final result = MediaInfo.fromJson(mediaInfoJson, null);
    return result.audioInfo.first;
  }

  static Future<TextInfo> subtitle(File file) async {
    String? mediaInfoJson;
    if (kReleaseMode) {
      mediaInfoJson ??= _miw.getJsonInfo(file.path);
    }

    mediaInfoJson ??= ((await Process.run(_mediaInfoDebug,
            ['--Language=raw', '--Complete', '--output=JSON', file.path]))
        .stdout as String);

    final result = MediaInfo.fromJson(mediaInfoJson, null);
    return result.textInfo.first;
  }
}
