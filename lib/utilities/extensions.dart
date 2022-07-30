import 'dart:io';
import 'package:flutter/widgets.dart';

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
}

extension BuildContextExtension on BuildContext {
  Rect? get globalPaintBounds {
    final renderObject = findRenderObject();
    final matrix = renderObject?.getTransformTo(null);

    if (matrix != null && renderObject?.paintBounds != null) {
      final rect = MatrixUtils.transformRect(matrix, renderObject!.paintBounds);
      return rect;
    } else {
      return null;
    }
  }
}
