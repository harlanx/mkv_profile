import 'dart:ffi';

import 'package:ffi/ffi.dart';

typedef MediaInfoNewType = Pointer<Void> Function();
typedef MediaInfoNew = Pointer<Void> Function();

typedef MediaInfoNewQuickType = Pointer<Void> Function(
    Pointer<Utf16>, Pointer<Utf16>);
typedef MediaInfoNewQuick = Pointer<Void> Function(
    Pointer<Utf16>, Pointer<Utf16>);

typedef MediaInfoDeleteType = Void Function(Pointer<Void>);
typedef MediaInfoDelete = void Function(Pointer<Void>);

typedef MediaInfoOpenType = Size Function(Pointer<Void>, Pointer<Utf16>);
typedef MediaInfoOpen = int Function(Pointer<Void>, Pointer<Utf16>);

typedef MediaInfoOptionType = Pointer<Utf16> Function(
    Pointer<Void>, Pointer<Utf16>, Pointer<Utf16>);
typedef MediaInfoOption = Pointer<Utf16> Function(
    Pointer<Void>, Pointer<Utf16>, Pointer<Utf16>);

typedef MediaInfoInformType = Pointer<Utf16> Function(Pointer<Void>, Uint32);
typedef MediaInfoInform = Pointer<Utf16> Function(Pointer<Void>, int);

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
    _new =
        library.lookupFunction<MediaInfoNewType, MediaInfoNew>('MediaInfo_New');
    _newQuick =
        library.lookupFunction<MediaInfoNewQuickType, MediaInfoNewQuick>(
            'MediaInfo_New_Quick');
    _delete = library.lookupFunction<MediaInfoDeleteType, MediaInfoDelete>(
        'MediaInfo_Delete');
    _open = library
        .lookupFunction<MediaInfoOpenType, MediaInfoOpen>('MediaInfo_Open');
    _option = library.lookupFunction<MediaInfoOptionType, MediaInfoOption>(
        'MediaInfo_Option');
    _inform = library.lookupFunction<MediaInfoInformType, MediaInfoInform>(
        'MediaInfo_Inform');
    _close = library
        .lookupFunction<MediaInfoCloseType, MediaInfoClose>('MediaInfo_Close');
  }

  Pointer<Void>? _handle;

  void open(String filePath) {
    _handle = _new();
    _open(_handle!, filePath.toNativeUtf16());
  }

  void quickOpen(String filePath, {String options = ''}) {
    _handle = _newQuick(filePath.toNativeUtf16(), options.toNativeUtf16());
  }

  String option(String option, {String value = ''}) {
    final optionNamePtr = option.toNativeUtf16();
    final optionValuePtr = value.toNativeUtf16();
    return _option(_handle ?? nullptr, optionNamePtr, optionValuePtr)
        .toDartString();
  }

  String? get inform {
    final infoPtr = _inform(_handle!, 0);
    return infoPtr != nullptr ? infoPtr.toDartString() : null;
  }

  String? getJsonInfo(String filePath) {
    // Language raw have to be set first before opening file
    // See discussion at
    // https://sourceforge.net/p/mediainfo/discussion/297610/thread/07967637/
    option('Language', value: 'raw');
    open(filePath);
    option('Complete', value: '1');
    option('output', value: 'JSON');
    final info = inform;
    close();
    return info;
  }

  void close() {
    _close(_handle!);
    _delete(_handle!);
  }
}
