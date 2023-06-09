import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart' show Color, HSLColor;
import 'package:path/path.dart' as p;
import 'package:win32/win32.dart';

extension FileSystemEntityExtension on FileSystemEntity {
  /// Returns the name of the file with the extension.
  /// Folder names are returned as is.
  String get name => path.split(Platform.pathSeparator).last;

  /// Reveals the file or directory in highlighted mode on Windows File Explorer .
  Future<void> revealInExplorer() async {
    if (await exists()) {
      await Process.run('explorer.exe', ['/select,$path']);
    }
  }
}

extension FileExtension on File {
  /// Returns the extension of the file.
  String get extension => name.split('.').last;

  /// Returns the name of the file without the extension
  String get title => name.substring(0, name.indexOf(extension) - 1);
}

extension DirectoryExtension on Directory {
  /// Creates a folder asynchronously without replacing existing folder with exact similar name
  /// by appending an incremental number.
  Future<Directory> createSafe(
    String name, {
    String format = '(d)',
    bool space = true,
  }) {
    var result = nameSafe(name, format, space);
    return Directory(p.join(path, result)).create();
  }

  /// Creates a folder synchronously without replacing existing folder with the exact name
  /// by appending an incremental number.
  void createSafeSync(
    String name, {
    String format = '(d)',
    bool space = true,
  }) {
    var result = nameSafe(name, format, space);
    return Directory(p.join(path, result)).createSync();
  }

  /// Generates folder name that doesn't conflict with existing folder with the exact name
  /// by appending an incremental number. If no existing folder with exact name is found,
  /// it uses the specified name.
  String nameSafe(String name, String format, bool space) {
    // get all from directory path
    var list = Directory(path).listSync();

    // list all folder names
    var nameList = list.map((e) => e.absolute.path.split('\\').last).toList();

    // set initial value
    var result = name;

    int i = 0;
    // increment file name when duplicate found
    while (nameList.contains(result)) {
      i += 1;
      result = name + (space ? ' ' : '') + format.replaceAll('d', '$i');
    }
    return result;
  }
}

extension StringExtension on String {
  List<String> multiSplit(Iterable<String> delimeters) => delimeters.isEmpty
      ? [this]
      : split(RegExp(delimeters.map(RegExp.escape).join('|')));

  String get capitalized =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';

  String get titleCased => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.capitalized)
      .join(' ');

  String get removeBlankLines {
    return replaceAll(RegExp(r'(\n\s*){2,}'), '\n');
  }

  String removeLinesWith(String text) {
    return replaceAll(
      RegExp('(.*$text.*)', multiLine: true),
      '',
    ).removeBlankLines;
  }

  List<String> linesWith(String text) {
    var lines = split('\n');
    var matches = <String>[];
    for (var line in lines) {
      if (RegExp('(.*$text.*)').hasMatch(line)) {
        matches.add(line);
      }
    }
    return matches;
  }

  String get singleSpace {
    return replaceAll(RegExp(r"\s+"), " ");
  }

  String get noBreakHyphen => replaceAll('-', '\u2011');

  bool get isValidFileName {
    final invalidChar = RegExp(r'[<>:"/\\|?*]');
    return !invalidChar.hasMatch(this);
  }

  String get regexSafe {
    const List<String> needsEscaping = [
      r'\',
      '[',
      ']',
      '^',
      r'$',
      '.',
      '|',
      '?',
      '*',
      '+',
      '(',
      ')',
    ];
    if (needsEscaping.contains(this)) {
      return '\\$this';
    } else {
      return this;
    }
  }
}

extension IntExtension on int {
  String formatByteSize(
      {int decimals = 1, bool binaryPrefixes = false, bool space = false}) {
    if (this <= 0) return "0 B";
    int fac = 1000;
    List suffixes = ["B", "kB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    if (binaryPrefixes) {
      fac = 1024;
      suffixes = ["B", "KiB", "MiB", "GiB", "TiB", "PiB", "EiB", "ZiB", "YiB"];
    }

    var i = (log(this) / log(fac)).floor();
    i = i >= (suffixes.length - 1) ? suffixes.length - 1 : i;
    return '${(this / pow(fac, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  String formatBitSpeed({int decimals = 1, bool space = false}) {
    double bytes = toDouble();
    int i = -1;
    const byteUnits = [
      "kbps",
      "Mbps",
      "Gbps",
      "Tbps",
      "Pbps",
      "Ebps",
      "Zbps",
      "Ybps"
    ];
    do {
      bytes = bytes / 1024;
      i++;
    } while (bytes > 1024);

    return max(bytes, 0.1).toStringAsFixed(decimals) +
        (space ? ' ' : '') +
        byteUnits[i];
  }

  String formatFrequency({int decimals = 1, bool space = false}) {
    double hertz = toDouble();
    int i = -1;
    const frequencyUnits = [
      "Hz",
      "KHz",
      "MHz",
      "GHz",
      "THz",
      "PHz",
      "EHz",
      "ZHz",
      "YHz"
    ];
    do {
      hertz = hertz / 1000;
      i++;
    } while (hertz > 1000);

    return hertz.toStringAsFixed(decimals) +
        (space ? ' ' : '') +
        frequencyUnits[i];
  }
}

extension DurationExtension on Duration {
  String formatDuration({String delimiter = ''}) {
    var seconds = inSeconds;
    final days = seconds ~/ Duration.secondsPerDay;
    seconds -= days * Duration.secondsPerDay;
    final hours = seconds ~/ Duration.secondsPerHour;
    seconds -= hours * Duration.secondsPerHour;
    final minutes = seconds ~/ Duration.secondsPerMinute;
    seconds -= minutes * Duration.secondsPerMinute;

    final List<String> tokens = [];
    if (days != 0) {
      tokens.add('${days}d');
    }
    if (tokens.isNotEmpty || hours != 0) {
      tokens.add('${hours}h');
    }
    if (tokens.isNotEmpty || minutes != 0) {
      tokens.add('${minutes}m');
    }
    tokens.add('${seconds}s');

    return tokens.join(delimiter);
  }

  /// This is specific only for extracting the duration of the process
  /// from mkvmerge's final verbose line
  static Duration parseSingle(String input) {
    List<String> words = input.split(' ');

    int? hours;
    int? minutes;
    int? seconds;
    int? milliseconds;

    for (int i = 0; i < words.length; i++) {
      if (words[i].contains('hour')) {
        hours = int.tryParse(words[i - 1]);
      } else if (words[i].contains('minute')) {
        minutes = int.tryParse(words[i - 1]);
      } else if (words[i].contains('second')) {
        seconds = int.tryParse(words[i - 1]);
      } else if (words[i].contains('millisecond')) {
        milliseconds = int.tryParse(words[i - 1]);
      }
    }

    return Duration(
      hours: hours ?? 0,
      minutes: minutes ?? 0,
      seconds: seconds ?? 0,
      milliseconds: milliseconds ?? 0,
    );
  }

  static Duration parseMultiple(List<String> inputs) {
    Duration result = Duration.zero;
    for (var input in inputs) {
      result += parseSingle(input);
    }
    return result;
  }
}

extension ColorExtension on Color {
  Color hued([double value = 360]) {
    return HSLColor.fromColor(this).withHue(value.clamp(0, 360)).toColor();
  }

  Color saturate([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    return HSLColor.fromColor(this).withSaturation(amount).toColor();
  }
}

extension DynamicLibraryExtension on DynamicLibrary {
  void unload() {
    FreeLibrary(handle.address);
  }
}
