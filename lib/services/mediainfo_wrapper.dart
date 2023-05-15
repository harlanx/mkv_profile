import 'dart:ffi';

import 'package:ffi/ffi.dart';

typedef MediaInfoNewType = Pointer<Void> Function();
typedef MediaInfoNew = Pointer<Void> Function();

typedef MediaInfoNewQuickType = Pointer<Void> Function(
    Pointer<Utf8>, Pointer<Utf8>);
typedef MediaInfoNewQuick = Pointer<Void> Function(
    Pointer<Utf8>, Pointer<Utf8>);

typedef MediaInfoDeleteType = Void Function(Pointer<Void>);
typedef MediaInfoDelete = void Function(Pointer<Void>);

typedef MediaInfoOpenType = Size Function(Pointer<Void>, Pointer<Utf8>);
typedef MediaInfoOpen = int Function(Pointer<Void>, Pointer<Utf8>);

typedef MediaInfoOptionType = Pointer<Utf8> Function(
    Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>);
typedef MediaInfoOption = Pointer<Utf8> Function(
    Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>);

typedef MediaInfoInformType = Pointer<Utf8> Function(Pointer<Void>, Uint32);
typedef MediaInfoInform = Pointer<Utf8> Function(Pointer<Void>, int);

typedef MediaInfoCloseType = Void Function(Pointer<Void>);
typedef MediaInfoClose = void Function(Pointer<Void>);

class MediaInfoWrapper {
  final String dllPath;
  late final DynamicLibrary library;
  late final MediaInfoNew _new;
  late final MediaInfoNewQuick _newQuick;
  late final MediaInfoDelete _delete;
  late final MediaInfoOpen _open;
  late final MediaInfoOption _option;
  late final MediaInfoInform _inform;
  late final MediaInfoClose _close;

  MediaInfoWrapper({required this.dllPath})
      : library = DynamicLibrary.open(dllPath) {
    _new = library
        .lookupFunction<MediaInfoNewType, MediaInfoNew>('MediaInfoA_New');
    _newQuick =
        library.lookupFunction<MediaInfoNewQuickType, MediaInfoNewQuick>(
            'MediaInfoA_New_Quick');
    _delete = library.lookupFunction<MediaInfoDeleteType, MediaInfoDelete>(
        'MediaInfoA_Delete');
    _open = library
        .lookupFunction<MediaInfoOpenType, MediaInfoOpen>('MediaInfoA_Open');
    _option = library.lookupFunction<MediaInfoOptionType, MediaInfoOption>(
        'MediaInfoA_Option');
    _inform = library.lookupFunction<MediaInfoInformType, MediaInfoInform>(
        'MediaInfoA_Inform');
    _close = library
        .lookupFunction<MediaInfoCloseType, MediaInfoClose>('MediaInfoA_Close');
  }

  Pointer<Void>? _handle;

  void open(String filePath) {
    _handle = _new();
    _open(_handle!, filePath.toNativeUtf8());
  }

  void quickOpen(String filePath, {String options = ""}) {
    _handle = _newQuick(filePath.toNativeUtf8(), options.toNativeUtf8());
  }

  String option(String option, {String value = ''}) {
    final optionNamePtr = option.toNativeUtf8();
    final optionValuePtr = value.toNativeUtf8();
    return _option(_handle ?? nullptr, optionNamePtr, optionValuePtr)
        .toDartString();
  }

  String get inform {
    final infoPtr = _inform(_handle!, 0);
    return infoPtr.toDartString();
  }

  String getJsonInfo(String filePath) {
    open(filePath);
    option('Language', value: 'raw');
    option('Complete', value: '1');
    option('output', value: 'JSON');
    final info = _inform(_handle!, 0).toDartString();
    close();
    return info;
  }

  void close() {
    _close(_handle!);
    _delete(_handle!);
  }
}
