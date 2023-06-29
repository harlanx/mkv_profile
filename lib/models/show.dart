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
    required Directory directory,
    required this.video,
  }) : super(directory: directory);

  final Video video;
}

class Series extends Show {
  Series({
    required Directory directory,
    required this.seasons,
  }) : super(directory: directory);

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
    bool include = true,
  })  : fileTitle = mainFile.title,
        super(title: mainFile.title, include: include);

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

  Future<void> loadInfo() async {
    info = await MetadataScanner.video(mainFile);

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
    String? title,
    bool include = true,
  }) : super(title: title, include: include);
  final int id;
  final String uid;
  final dynamic info;

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
}

class AddedTrack extends TrackProperties {
  AddedTrack({
    required this.file,
    String? title,
    bool include = true,
  }) : super(title: title, include: include);

  final File file;
  dynamic info;

  Future<void> loadInfo() async {
    if (AppData.audioFormats.contains(file.extension)) {
      info = await MetadataScanner.audio(file);
    } else if (AppData.subtitleFormats.contains(file.extension)) {
      info = await MetadataScanner.subtitle(file);
    }

    language = await AppData.languageCodes.identifyByText(file.title);
    if (AppData.subtitleFormats.contains(file.extension)) {
      flags['forced']!.value = await _isForced;
      flags['hearing_impaired']!.value = await _isHearingImpaired;
      flags['text_description']!.value = await _isTextDescription;
    }
  }

  Future<bool> get _isForced async {
    // Usually Forced Subtitles are less than 20KB
    return await file.length() < 20000;
  }

  Future<bool> get _isHearingImpaired async {
    const ls = LineSplitter();
    final content = ls.convert(file.readAsStringSync());
    final samples = content.take(500);
    // Matches (), []. For  <i> </i>, we can use '\<i>(.*?)\<\/i>' however sometimes it exist in non sdh subtitles
    final hearingIndicator = RegExp(r'\[(.*?)\]|\((.*?)\)');
    final visualIndicator = RegExp(
        r'\[(.*?)Description\]|\((.*?)Description\)|\[(.*?)AD\]|\((.*?)AD\)');
    final hearingResult =
        samples.where((text) => hearingIndicator.hasMatch(text));
    final visualResult =
        samples.where((text) => visualIndicator.hasMatch(text));
    return hearingResult.length > 3 && visualResult.isEmpty;
  }

  Future<bool> get _isTextDescription async {
    const ls = LineSplitter();
    final content = ls.convert(file.readAsStringSync());
    final samples = content.take(500);
    // Matches (), []. For  <i> </i>, we can use '\<i>(.*?)\<\/i>' however sometimes it exist in non sdh subtitles
    final visualIndicator = RegExp(
        r'\[(.*?)Description\]|\((.*?)Description\)|\[(.*?)TD\]|\((.*?)TD\)|\[(.*?)AD\]|\((.*?)AD\)');
    final visualResult =
        samples.where((text) => visualIndicator.hasMatch(text));
    return visualResult.length > 3;
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
