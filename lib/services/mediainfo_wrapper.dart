import 'dart:ffi';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:ffi/ffi.dart';

typedef MediaInfoNewType = Pointer<IntPtr> Function();
typedef MediaInfoNew = Pointer<IntPtr> Function();

typedef MediaInfoDeleteType = Void Function(Pointer<IntPtr>);
typedef MediaInfoDelete = void Function(Pointer<IntPtr>);

typedef MediaInfoOpenType = Int32 Function(Pointer<IntPtr>, Pointer<Utf8>);
typedef MediaInfoOpen = int Function(Pointer<IntPtr>, Pointer<Utf8>);

typedef MediaInfoOptionType = Int32 Function(
    Pointer<IntPtr>, Pointer<Utf8>, Pointer<Utf8>);
typedef MediaInfoOption = int Function(
    Pointer<IntPtr>, Pointer<Utf8>, Pointer<Utf8>);

typedef MediaInfoInformType = Pointer<Utf8> Function(Pointer<IntPtr>, IntPtr);
typedef MediaInfoInform = Pointer<Utf8> Function(Pointer<IntPtr>, int);

typedef MediaInfoCloseType = Void Function(Pointer<IntPtr>);
typedef MediaInfoClose = void Function(Pointer<IntPtr>);

class MediaInfoWrapper {
  late final DynamicLibrary _mediaInfoDll;
  late final MediaInfoNew _new;
  late final MediaInfoDelete _delete;
  late final MediaInfoOpen _open;
  late final MediaInfoOption _option;
  late final MediaInfoInform _inform;
  late final MediaInfoClose _close;

  MediaInfoWrapper()
      : _mediaInfoDll = DynamicLibrary.open(path.join(
            File(Platform.resolvedExecutable).parent.path,
            'bin',
            'MediaInfo.dll')) {
    _new = _mediaInfoDll
        .lookupFunction<MediaInfoNewType, MediaInfoNew>('MediaInfoA_New');
    _delete =
        _mediaInfoDll.lookupFunction<MediaInfoDeleteType, MediaInfoDelete>(
            'MediaInfoA_Delete');
    _open = _mediaInfoDll
        .lookupFunction<MediaInfoOpenType, MediaInfoOpen>('MediaInfoA_Open');
    _option =
        _mediaInfoDll.lookupFunction<MediaInfoOptionType, MediaInfoOption>(
            'MediaInfoA_Option');
    _inform =
        _mediaInfoDll.lookupFunction<MediaInfoInformType, MediaInfoInform>(
            'MediaInfoA_Inform');
    _close = _mediaInfoDll
        .lookupFunction<MediaInfoCloseType, MediaInfoClose>('MediaInfoA_Close');
  }

  late Pointer<IntPtr> _handle;

  void open(String filePath) {
    _handle = _new();
    final pathPtr = filePath.toNativeUtf8();
    _open(_handle, pathPtr);
    calloc.free(pathPtr);
  }

  String get inform {
    return using((Arena arena) {
      final infoPtr = _inform(_handle, 0);
      return infoPtr.toDartString();
    });
  }

  String getJsonInfo() {
    final optionPtr = 'Output'.toNativeUtf8();
    final valuePtr = 'JSON'.toNativeUtf8();
    _option(_handle, optionPtr, valuePtr);
    calloc.free(optionPtr);
    calloc.free(valuePtr);
    final infoPtr = _inform(_handle, 0);
    final info = infoPtr.toDartString();
    return info;
  }

  void close() {
    _close(_handle);
    _delete(_handle);
  }
}
