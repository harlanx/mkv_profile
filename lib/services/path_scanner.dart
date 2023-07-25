import '../data/app_data.dart';
import '../services/app_services.dart';
import '../utilities/utilities.dart';

class PathScanner {
  static Future<GroupingResult> scan(String path) async {
    dynamic entityForAbsolutePath;
    if (path.isNotEmpty) {
      entityForAbsolutePath = await FileSystemEntity.isDirectory(path)
          ? Directory(path)
          : File(path);
    }

    final dir = Directory(entityForAbsolutePath.absolute.path);
    final dirContents = await _recursiveScan(dir);
    try {
      _isForGrouping(dirContents);
    } catch (e) {
      rethrow;
    }
    return await FileGrouper.group(dirContents);
  }

  static Future<PathData> _recursiveScan(Directory dir) async {
    final dirMain = dir.list(recursive: true);
    final List<File> files = [];
    final dirs = [dir];
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

  static void _isForGrouping(PathData data) {
    if (data.videos.isEmpty) {
      throw ('No videos were found. Please check the folder.');
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
