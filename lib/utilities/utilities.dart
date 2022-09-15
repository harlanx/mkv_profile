import 'dart:ui';
import 'dart:math';
import 'package:collection/collection.dart';
export 'dart:io';
export 'dart:convert';
export 'package:collection/collection.dart';
export 'package:async/async.dart';
export 'extensions.dart';
export 'title_scanner.dart';
export 'shared_prefs.dart';
export 'distance_algorithms.dart';
export 'custom_widgets/custom_widgets.dart';

class Utilities {
  static String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${((bytes / pow(1024, i)).toStringAsFixed(decimals))} ${suffixes[i]}';
  }

  // For List Comparison (For List<T> only).
  // Use == operator for single object that extends Equatable package.
  static Function deepEq = const DeepCollectionEquality().equals;

  ///Converts the original value using linear conversion while maintaining the correct ratio.
  static double toNewRange({
    required double oldValue,
    required double oldMin,
    required double oldMax,
    required double newMin,
    required double newMax,
  }) {
    double newValue = 0.0;
    newValue = (((oldValue - oldMin) * (newMax - newMin)) / (oldMax - oldMin)) +
        newMin;
    return newValue;
  }

  static double toAlignX(double value) {
    return toNewRange(
        oldValue: value,
        oldMax: window.physicalSize.width,
        oldMin: 0,
        newMax: 1,
        newMin: -1);
  }

  static double toAlignY(double value) {
    return toNewRange(
        oldValue: value,
        oldMax: window.physicalSize.height,
        oldMin: 0,
        newMax: 1,
        newMin: -1);
  }
}
