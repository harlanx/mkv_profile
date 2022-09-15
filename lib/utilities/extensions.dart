import 'dart:io';

extension FileSystemEntityExtension on FileSystemEntity {
  /// Returns the name of the file with the extension.
  /// Folder names are returned as is.
  String get name => path.split(Platform.pathSeparator).last;
}

extension FileExtension on File {
  /// Returns the extension of the file.
  String get extension => name.split('.').last;

  /// Returns the name of the file withouth the extension
  String get title => name.substring(0, name.indexOf(extension) - 1);
}

extension StringExtension on String {
  List<String> multiSplit(Iterable<String> delimeters) => delimeters.isEmpty
      ? [this]
      : split(RegExp(delimeters.map(RegExp.escape).join('|')));

  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');

  String removeBlankLines() {
    return replaceAll(RegExp(r'(\n\s*){2,}'), '\n');
  }
}

extension IntExtension on int {
  String formatBytes({bool binaryPrefixes = true}) {
    int bytes = this;
    int factor = binaryPrefixes ? 1024 : 1000;
    int unitIdx = 0;
    var units = binaryPrefixes
        ? ['B', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB', 'EiB', 'ZiB', 'YiB']
        : ['B', 'kB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];

    while (bytes >= factor && ++unitIdx > 0) {
      bytes ~/= factor;
    }

    return '$bytes ${units[unitIdx]}';
  }
}

extension DurationExtension on Duration {
  String formatDuration({String delimiter = ' '}) {
    var seconds = inSeconds;
    final days = seconds ~/ Duration.secondsPerDay;
    seconds -= days * Duration.secondsPerDay;
    final hours = seconds ~/ Duration.secondsPerHour;
    seconds -= hours * Duration.secondsPerHour;
    final minutes = seconds ~/ Duration.secondsPerMinute;
    seconds -= minutes * Duration.secondsPerMinute;

    final List<String> tokens = [];
    if (days != 0) {
      tokens.add('${days}D');
    }
    if (tokens.isNotEmpty || hours != 0) {
      tokens.add('${hours}H');
    }
    if (tokens.isNotEmpty || minutes != 0) {
      tokens.add('${minutes}M');
    }
    tokens.add('${seconds}S');

    return tokens.join(delimiter);
  }
}
