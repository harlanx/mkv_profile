import 'package:merge2mkv/data/app_data.dart';
import 'package:merge2mkv/utilities/utilities.dart';

class PathScanner {
  FileSystemEntity entity = Directory.current;

  static Future<bool> isDirectory(String path) async {
    return await FileSystemEntity.isDirectory(path);
  }

  static Future<GroupingResult> scan(String path) async {
    dynamic entityForAbsolutePath;
    if (path.isNotEmpty) {
      entityForAbsolutePath = await FileSystemEntity.isDirectory(path)
          ? Directory(path)
          : File(path);
    }

    var dir = Directory(entityForAbsolutePath.absolute.path);
    var allContents = await _recursiveScan(dir);
    try {
      _isForGrouping(allContents);
    } catch (e) {
      rethrow;
    }
    return FileGrouper.group(allContents);
  }

  static Future<PathData> _recursiveScan(Directory dir) async {
    var dirMain = dir.list(recursive: true);
    List<File> files = [];
    List<Directory> dirs = [dir];
    await for (final FileSystemEntity entity in dirMain) {
      if (entity is File) {
        files.add(entity);
      } else if (entity is Directory) {
        if (dirs.length > AppData.appSettings.recursiveLimit) {
          throw ('Recursive scan directory limit. Increase the maximum in app settings.');
        } else {
          dirs.add(entity);
        }
      }
    }
    return PathData(
      directories: dirs,
      files: files,
    );
  }

  static _isForGrouping(PathData data) {
    if (data.videos.isEmpty) {
      throw ('No videos were found. Please check the folder.');
    }
    if (data.otherFiles.isEmpty) {
      throw ('Videos found but subtitles were not detected.');
    }
  }
}

class PathData {
  final List<Directory> directories;
  final List<File> files;
  late final Directory mainDir;
  late final List<File> videos;
  late final List<File> otherFiles;

  PathData({
    required this.directories,
    required this.files,
  }) {
    mainDir = directories.first;
    videos = files
        .where((item) => AppData.videoFormats.contains(item.extension))
        .toList();
    otherFiles = files
        .where((item) => !AppData.videoFormats.contains(item.extension))
        .toList();
  }
}
