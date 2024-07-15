import 'package:async/async.dart';
import 'package:path/path.dart' as path;

import '../data/app_data.dart';
import '../models/models.dart';
import '../services/app_services.dart';
import '../utilities/utilities.dart';

abstract class Show {
  Show({
    required this.directory,
  }) : title = directory.name;

  String title;
  final Directory directory;
}

class Movie extends Show {
  Movie({
    required super.directory,
    required this.video,
  });

  final Video video;
}

class Series extends Show {
  Series({
    required super.directory,
    required this.seasons,
  });

  final List<Season> seasons;

  List<Video> get allVideos =>
      seasons.fold([], (all, season) => all..addAll(season.videos));
}

class Season {
  Season({
    required this.number,
    required this.videos,
  }) : folderTitle = 'Season ${number.toString().padLeft(2, '0')}';

  final int number;
  String folderTitle;
  final List<Video> videos;
}

class Video extends TrackProperties {
  Video({
    required this.mainFile,
    this.season,
    this.episode,
    this.removeChapters = false,
    this.removeAttachments = false,
    String? title,
    super.include,
  })  : fileTitle = mainFile.title,
        super(title: mainFile.title);

  final File mainFile;
  final int? season;
  final int? episode;
  String fileTitle;
  late final MediaInfo info;
  final List<EmbeddedTrack> embeddedAudios = [];
  final List<AddedTrack> addedAudios = [];
  final List<EmbeddedTrack> embeddedSubtitles = [];
  final List<AddedTrack> addedSubtitles = [];
  final List<EmbeddedTrack> embeddedChapters = [];
  final List<AddedTrack> addedChapters = [];
  final List<EmbeddedTrack> embeddedAttachments = [];
  final List<AddedTrack> addedAttachments = [];
  bool removeChapters;
  bool removeAttachments;
  final _memoizer = AsyncMemoizer();

  @override
  Future<void> loadInfo() async {
    return await _memoizer.runOnce(() async {
      info = await MetadataScanner.video(mainFile);
      flags = info.videoInfo.first.flags;

      for (var audio in info.audioInfo) {
        embeddedAudios.add(
          EmbeddedTrack(
            id: audio.id,
            uid: audio.uid!,
            info: audio,
            title: audio.title,
            include: true,
          )
            ..language = audio.language
            ..flags = audio.flags,
        );
      }
      for (var subtitle in info.textInfo) {
        embeddedSubtitles.add(
          EmbeddedTrack(
            id: subtitle.id,
            uid: subtitle.uid!,
            info: subtitle,
            title: subtitle.title,
            include: true,
          )
            ..language = subtitle.language
            ..flags = subtitle.flags,
        );
      }
      for (var chapter in info.menuInfo) {
        embeddedChapters.add(
          EmbeddedTrack(
            id: chapter.id,
            uid: chapter.uid,
            info: chapter,
          ),
        );
      }

      for (var attachment in info.attachmentInfo) {
        embeddedAttachments.add(
          EmbeddedTrack(
            id: attachment.id,
            uid: attachment.uid,
            title: attachment.name,
            info: attachment,
          ),
        );
      }
    });
  }

  List<TrackProperties> get audios => [...embeddedAudios, ...addedAudios];
  List<TrackProperties> get subtitles =>
      [...embeddedSubtitles, ...addedSubtitles];
  List<TrackProperties> get chapters => [...embeddedChapters, ...addedChapters];
  List<TrackProperties> get attachments =>
      [...embeddedAttachments, ...addedAttachments];

  Future<void> addAudios(List<String> filePaths) async {
    final files = filePaths
        .map((e) => File(e))
        .where((file) => AppData.audioFormats.contains(file.extension))
        .toList();
    final tracks = files.map((e) => AddedTrack(file: e)).toList();
    addedAudios.addAll(tracks);
  }

  Future<void> addSubtitles(List<String> filePaths) async {
    final files = filePaths
        .map((e) => File(e))
        .where((file) => AppData.subtitleFormats.contains(file.extension))
        .toList();
    final tracks = files.map((e) => AddedTrack(file: e)).toList();
    addedSubtitles.addAll(tracks);
  }

  Future<void> addChapters(List<String> filePaths) async {
    final files = filePaths
        .map((e) => File(e))
        .where((file) => AppData.chapterFormats.contains(file.extension))
        .toList();
    final tracks = files.map((e) => AddedTrack(file: e)).toList();
    addedChapters.addAll(tracks);
  }

  Future<void> addAttachments(List<String> filePaths) async {
    final files = filePaths
        .map((e) => File(e))
        .where((file) => [...AppData.fontFormats, ...AppData.imageFormats]
            .contains(file.extension))
        .toList();
    final tracks = files.map((e) => AddedTrack(file: e)).toList();
    addedAttachments.addAll(tracks);
  }

  void removeAudio(String path) {
    addedAudios.removeWhere((audio) => audio.file.path == path);
  }

  void removeSubtitle(String path) {
    addedSubtitles.removeWhere((sub) => sub.file.path == path);
  }

  void removeChapter(String path) {
    addedChapters.removeWhere((chap) => chap.file.path == path);
  }

  void removeAttachment(String path) {
    addedAttachments.removeWhere((attach) => attach.file.path == path);
  }

  /// Generates an mkvmerge command for the the video file
  List<String> command(Show show, [String? folder]) {
    final videoInfo = info.videoInfo.first;
    final fileName = '$fileTitle.mkv';
    String seasonName = '';
    if (season != null) {
      final seasonInfo =
          (show as Series).seasons.singleWhere((s) => s.number == season);
      seasonName = seasonInfo.folderTitle;
    }
    folder ??= path.join(show.directory.parent.path, show.title);
    final output = path.join(
      folder,
      seasonName,
      fileName,
    );
    return [
      // Output File
      '--output',
      output,
      // Video
      '--title',
      title ?? '',
      '--track-name',
      '${videoInfo.id}:${title ?? ''}',
      '--language',
      '${videoInfo.id}:${language.iso6392 ?? language.iso6393}',
      for (var flag in flags.values) ...flag.command(videoInfo.id),
      // Extra Options
      if ((extraOptions ?? '').isNotEmpty)
        ...extraOptions!.replaceAll('%id%', videoInfo.id.toString()).split(' '),
      // Remove non-included Embedded Audios
      if (embeddedAudios.any((ea) => !ea.include)) ...[
        '--audio-tracks',
        '!${List<String>.from(embeddedAudios.where((ea) => !ea.include).map((e) => e.id.toString())).join(',')}',
      ],
      // Embedded Audios
      for (var embedAudio in embeddedAudios) ...embedAudio.command,

      // Remove non-included Embedded Subtitles
      if (embeddedSubtitles.any((es) => !es.include)) ...[
        '--subtitle-tracks',
        '!${List<String>.from(embeddedSubtitles.where((es) => !es.include).map((e) => e.id.toString())).join(',')}',
      ],
      // Embedded Subtitles
      for (var embedSub in embeddedSubtitles) ...embedSub.command,

      // Input File
      mainFile.path,
      // Added Audios
      for (var addAudio in addedAudios) ...addAudio.command,
      // Added Subtitles
      for (var addSub in addedSubtitles) ...addSub.command,

      // Remove embedded chapters in the input file.
      // Usually exist on mkv
      if (removeChapters) '--no-chapters',
      // Chapter Files
      for (var chapter in addedChapters) ...chapter.command,

      // Remove fonts and images/poster
      if (removeAttachments) '--no-attachments',
      // Attachment Files
      for (var attachment in addedAttachments) ...attachment.command,
    ];
  }
}

class EmbeddedTrack extends TrackProperties {
  EmbeddedTrack({
    required this.id,
    this.uid = '',
    required this.info,
    super.title,
    super.include,
  });
  final int id;
  final String uid;
  final dynamic info;
  final _memoizer = AsyncMemoizer();

  /// Generates an mkvmerge command for the the embedded track
  List<String> get command {
    return [
      if (include) ...[
        '--track-name',
        '$id:${title ?? ''}',
        '--language',
        '$id:${language.iso6392 ?? language.iso6393}',
        for (var flag in flags.values) ...[...flag.command(id)],
        if ((extraOptions ?? '').isNotEmpty)
          ...extraOptions!.replaceAll('%id%', id.toString()).split(' '),
      ],
    ];
  }

  @override
  Future<void> loadInfo() async {
    return await _memoizer.runOnce(() async {
      flags['default']!.value = false;
      flags['original_language']!.value = await _isOriginalLanguage;
      flags['forced']!.value = await _isForced;
      flags['commentary']!.value = await _isCommentary;
      flags['hearing_impaired']!.value = await _isHearingImpaired;
      flags['visual_impaired']!.value = await _isVisualImpaired;
      flags['text_description']!.value = await _isTextDescription;
    });
  }

  Future<bool> get _isOriginalLanguage async {
    final identifiers = ['Original Language'];
    bool result = flags['original_language']!.value;
    // If false, reconfirm by using track title;
    if (!result) {
      result = identifiers.any((identifier) =>
          (title ?? '').contains(RegExp(identifier, caseSensitive: true)));
    }

    return result;
  }

  Future<bool> get _isForced async {
    final identifiers = ['Forced'];
    bool result = flags['forced']!.value;
    if (!result) {
      result = identifiers.any((identifier) =>
          (title ?? '').contains(RegExp(identifier, caseSensitive: true)));
    }

    return result;
  }

  Future<bool> get _isCommentary async {
    final identifiers = ['Commentary'];
    bool result = flags['commentary']!.value;
    if (!result) {
      result = identifiers.any((identifier) =>
          (title ?? '').contains(RegExp(identifier, caseSensitive: true)));
    }

    return result;
  }

  Future<bool> get _isHearingImpaired async {
    final identifiers = ['Hearing Impaired', 'SDH'];
    bool result = flags['hearing_impaired']!.value;
    if (!result) {
      result = identifiers.any((identifier) =>
          (title ?? '').contains(RegExp(identifier, caseSensitive: true)));
    }

    return result;
  }

  Future<bool> get _isVisualImpaired async {
    final identifiers = ['Visual Impaired', 'AD'];
    bool result = flags['visual_impaired']!.value;
    if (!result) {
      result = identifiers.any((identifier) =>
          (title ?? '').contains(RegExp(identifier, caseSensitive: true)));
    }

    return result;
  }

  Future<bool> get _isTextDescription async {
    final identifiers = ['Text Description', 'TD'];
    bool result = flags['text_description']!.value;
    if (!result) {
      result = identifiers.any((identifier) =>
          (title ?? '').contains(RegExp(identifier, caseSensitive: true)));
    }

    return result;
  }
}

class AddedTrack extends TrackProperties {
  AddedTrack({
    required this.file,
    super.title,
    super.include,
  });

  final File file;
  dynamic info;
  final _memoizer = AsyncMemoizer();

  @override
  Future<void> loadInfo() async {
    return await _memoizer.runOnce(() async {
      if (AppData.audioFormats.contains(file.extension)) {
        info = await MetadataScanner.audio(file);
      } else if (AppData.subtitleFormats.contains(file.extension)) {
        info = await MetadataScanner.subtitle(file);
      }

      language = await AppData.languageCodes.identifyByText(file.title);
      flags['enabled']!.value = true;
      flags['original_language']!.value = await _isOriginalLanguage;
      flags['forced']!.value = await _isForced;
      flags['commentary']!.value = await _isCommentary;
      flags['hearing_impaired']!.value = await _isHearingImpaired;
      flags['visual_impaired']!.value = await _isVisualImpaired;
      flags['text_description']!.value = await _isTextDescription;
    });
  }

  Future<bool> get _isOriginalLanguage async {
    final identifiers = ['Original Language'];
    bool result = false;
    result = identifiers.any((identifier) =>
        file.title.contains(RegExp(identifier, caseSensitive: true)));

    return result;
  }

  Future<bool> get _isForced async {
    final identifiers = ['Forced'];
    bool result = false;
    result = identifiers.any((identifier) =>
        file.title.contains(RegExp(identifier, caseSensitive: true)));

    if (AppData.subtitleFormats.contains(file.extension)) {
      // Usually Forced Subtitles are less than 20KB
      result = await file.length() < 20000;
    }
    return result;
  }

  Future<bool> get _isCommentary async {
    final identifiers = ['Commentary'];
    bool result = false;
    result = identifiers.any((identifier) =>
        file.title.contains(RegExp(identifier, caseSensitive: true)));

    return result;
  }

  Future<bool> get _isHearingImpaired async {
    final identifiers = ['Hearing Impaired', 'SDH'];
    bool result = false;
    result = identifiers.any((identifier) =>
        file.title.contains(RegExp(identifier, caseSensitive: true)));

    if (AppData.subtitleFormats.contains(file.extension)) {
      const ls = LineSplitter();
      final content = ls.convert(await file.readAsString());
      final samples = content.take(500);
      // Matches (), []. For  <i> </i>, we can use '\<i>(.*?)\<\/i>' however sometimes it exist in non sdh subtitles
      final hearingIndicator = RegExp(r'\[(.*?)\]|\((.*?)\)');
      final visualIndicator = RegExp(
          r'\[(.*?)Description\]|\((.*?)Description\)|\[(.*?)AD\]|\((.*?)AD\)');
      final hearingResult =
          samples.where((text) => hearingIndicator.hasMatch(text));
      final visualResult =
          samples.where((text) => visualIndicator.hasMatch(text));
      result = hearingResult.length > 3 && visualResult.isEmpty;
    }
    return result;
  }

  Future<bool> get _isVisualImpaired async {
    final identifiers = ['Visual Impaired', 'AD'];
    bool result = false;
    result = identifiers.any((identifier) =>
        file.title.contains(RegExp(identifier, caseSensitive: true)));

    return result;
  }

  Future<bool> get _isTextDescription async {
    final identifiers = ['Text Description', 'TD'];
    bool result = false;
    result = identifiers.any((identifier) =>
        file.title.contains(RegExp(identifier, caseSensitive: true)));

    if (AppData.subtitleFormats.contains(file.extension)) {
      const ls = LineSplitter();
      final content = ls.convert(await file.readAsString());
      final samples = content.take(500);
      // Matches (), []. For  <i> </i>, we can use '\<i>(.*?)\<\/i>' however sometimes it exist in non sdh subtitles
      final visualIndicator = RegExp(
          r'\[(.*?)Description\]|\((.*?)Description\)|\[(.*?)TD\]|\((.*?)TD\)|\[(.*?)AD\]|\((.*?)AD\)');
      final visualResult =
          samples.where((text) => visualIndicator.hasMatch(text));
      result = visualResult.length > 3;
    }
    return result;
  }

  bool get isTrack {
    return AppData.audioFormats.contains(file.extension) ||
        AppData.subtitleFormats.contains(file.extension);
  }

  /// Generates an mkvmerge command for the the added track
  List<String> get command {
    return [
      if (include) ...[
        if (isTrack) ...[
          '--track-name',
          '0:${title ?? ''}',
          '--language',
          '0:${language.iso6392 ?? language.iso6393}',
          for (var flag in flags.values) ...[...flag.command(0)],
        ] else ...[
          if (AppData.chapterFormats.contains(file.extension)) ...[
            '--chapters',
          ] else ...[
            '--attach-file',
          ],
        ],
        if ((extraOptions ?? '').isNotEmpty)
          ...extraOptions!.replaceAll('%id%', '0').split(' '),
        file.path
      ],
    ];
  }
}
