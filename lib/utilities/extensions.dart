import 'dart:io';
import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:path/path.dart' as p;

extension LocaleExtension on Locale {
  // Update also when adding new locales
  String get name {
    switch (languageCode) {
      case 'en':
        return 'English';

      case 'fil':
        return 'Filipino';
      default:
        return '';
    }
  }

  // Note: Use NotoColorEmoji (Windows Compatible) since some OS like windows doesn't support (render) flag emojis
  // https://github.com/googlefonts/noto-emoji/tree/main/fonts
  String get flagEmoji {
    switch (languageCode) {
      case 'en':
        return _getFlagEmoji('GB');
      case 'fil':
        return _getFlagEmoji('PH');
      default:
        return '🏳️';
    }
  }

  static String _getFlagEmoji(String countryCode) {
    return countryCode.toUpperCase().replaceAllMapped(RegExp(r'[A-Z]'),
        (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397));
  }
}

extension FileSystemEntityExtension on FileSystemEntity {
  /// Returns the name of the file with the extension.
  /// Folder names are returned as is.
  String get name => path.split(Platform.pathSeparator).last;

  /// Reveals the file in highlighted mode or a directory with its content on Windows File Explorer.
  Future<void> revealInExplorer() async {
    if (await exists()) {
      final List<String> commands;
      if (this is Directory) {
        commands = [path];
      } else {
        /// For File
        commands = ['/select,', path];
      }
      await Process.run('explorer', commands);
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
    final result = nameSafe(name, format, space);
    return Directory(p.join(path, result)).create();
  }

  /// Creates a folder synchronously without replacing existing folder with the exact name
  /// by appending an incremental number.
  void createSafeSync(
    String name, {
    String format = '(d)',
    bool space = true,
  }) {
    final result = nameSafe(name, format, space);
    return Directory(p.join(path, result)).createSync();
  }

  /// Generates folder name that doesn't conflict with existing folder with the exact name
  /// by appending an incremental number. If no existing folder with exact name is found,
  /// it uses the specified name.
  String nameSafe(String name, String format, bool space) {
    // get all from directory path
    final list = Directory(path).listSync();

    // list all folder names
    final nameList = list.map((e) => e.absolute.path.split('\\').last).toList();

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
    final lines = split('\n');
    final matches = <String>[];
    for (var line in lines) {
      if (RegExp('(.*$text.*)').hasMatch(line)) {
        matches.add(line);
      }
    }
    return matches;
  }

  String get singleSpace {
    return replaceAll(RegExp(r'\s+'), ' ');
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
    if (this <= 0) return '0 B';
    int fac = 1000;
    List suffixes = ['B', 'kB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
    if (binaryPrefixes) {
      fac = 1024;
      suffixes = ['B', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB', 'EiB', 'ZiB', 'YiB'];
    }

    var i = (log(this) / log(fac)).floor();
    i = i >= (suffixes.length - 1) ? suffixes.length - 1 : i;
    return '${(this / pow(fac, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  String formatBitSpeed({int decimals = 1, bool space = false}) {
    double bytes = toDouble();
    int i = -1;
    const byteUnits = [
      'kbps',
      'Mbps',
      'Gbps',
      'Tbps',
      'Pbps',
      'Ebps',
      'Zbps',
      'Ybps'
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
      'Hz',
      'KHz',
      'MHz',
      'GHz',
      'THz',
      'PHz',
      'EHz',
      'ZHz',
      'YHz'
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
  String format({
    bool includeDay = true,
    bool includeHour = true,
    bool includeMinute = true,
    bool includeSecond = true,
    bool includeMillisecond = true,
    String daySymbol = 'd',
    String hourSymbol = 'h',
    String minuteSymbol = 'm',
    String secondSymbol = 's',
    String millisecondSymbol = 'ms',
    String delimiter = '',
    int dayPad = 0,
    int hourPad = 0,
    int minutePad = 0,
    int secondPad = 0,
    int millisecondPad = 0,
    bool ignoreZero = true,
  }) {
    var milliseconds = inMilliseconds;
    final days = milliseconds ~/ Duration.millisecondsPerDay;
    milliseconds -= days * Duration.millisecondsPerDay;
    final hours = milliseconds ~/ Duration.millisecondsPerHour;
    milliseconds -= hours * Duration.millisecondsPerHour;
    final minutes = milliseconds ~/ Duration.millisecondsPerMinute;
    milliseconds -= minutes * Duration.millisecondsPerMinute;
    final seconds = milliseconds ~/ Duration.millisecondsPerSecond;
    milliseconds -= seconds * Duration.millisecondsPerSecond;

    final List<String> tokens = [];
    if (includeDay && (days != 0 || !ignoreZero)) {
      tokens.add('${days.toString().padLeft(dayPad, '0')}$daySymbol');
    }
    if (includeHour && ((tokens.isNotEmpty || hours != 0) || !ignoreZero)) {
      tokens.add('${hours.toString().padLeft(hourPad, '0')}$hourSymbol');
    }
    if (includeMinute && ((tokens.isNotEmpty || minutes != 0) || !ignoreZero)) {
      tokens.add('${minutes.toString().padLeft(minutePad, '0')}$minuteSymbol');
    }
    if (includeSecond && ((tokens.isNotEmpty || seconds != 0) || !ignoreZero)) {
      tokens.add('${seconds.toString().padLeft(secondPad, '0')}$secondSymbol');
    }
    if (includeMillisecond) {
      tokens.add(
          '${milliseconds.toString().padLeft(millisecondPad, '0')}$millisecondSymbol');
    }

    return tokens.join(delimiter);
  }

  /// This is specific only for extracting the duration of the process
  /// from mkvmerge's final verbose line
  static Duration parseSingle(String input) {
    final words = input.split(' ');

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
