import 'package:merge2mkv/data/app_data.dart';
import 'package:merge2mkv/models/models.dart';
import 'package:merge2mkv/utilities/utilities.dart';

class ShowMerger {
  // TODO: Fix this dumbass
  Stream<double> merge(ShowListNotifier showlist) async* {
    const double max = 100.0;
    double progress = 0.0;
    for (ShowNotifier showNotifier in showlist.items) {
      _merge(showNotifier);
      yield progress;
      progress += max / showlist.items.length;
    }
  }

  Future<bool> _merge(ShowNotifier showNotifier) async {
    var show = showNotifier.item;
    String appFolder = Platform.resolvedExecutable;
    appFolder = appFolder.substring(0, appFolder.lastIndexOf("\\"));
    final String mkvmergeDir =
        "$appFolder\\data\\flutter_assets\\assets\\mkvmerge\\mkvmerge.exe";

    if (show is Movie) {
      String title = TitleScanner.scan(showNotifier);
      String outputName = '${show.directory}\\$title\\$title.mkv';
      List<Subtitle> subtitles = show.video.subtitles;
      subtitles.sort(
          (b, a) => a.sub.lengthSync().compareTo(b.sub.lengthSync()));
      String subtitleOrder =
          List<String>.generate(subtitles.length, (index) => '${index + 1}:0,')
              .join();

      await Process.run(mkvmergeDir, [
        '--ui-language en',
        '--gui-mode',
        '-o ^"$outputName^" --language 0:und', //Output 0:0
        '--title $title', //Metadata title
        '--language 1:en ^"^(^" ^"${show.video.mainFile.path}^" ^"^)^"', //Video file 0:1
        ...subtitles.map((e) {
          var defaultFlag = e == subtitles.first
              ? '--default-track-flag 0:yes'
              : '--default-track-flag 0:no';
          return '--language 0:${e.language} $defaultFlag ^"^(^" ^"${e.sub.path}^" ^"^)^"';
        }).toList(), //Subtitles n>1:0
        '--track-order 0:0,0:1,$subtitleOrder', // Track order
      ]);
    } else {
      show as Series;
      String title = TitleScanner.scan(showNotifier);
      for (var s in show.seasons) {
        s.videos.sort((a, b) => compareNatural(
            a.mainFile.name,
            b.mainFile
                .name)); // Sort by name so it gets merged in the correct order
        for (var v in s.videos) {
          String episodeTitle =
              TitleScanner.scanEpisode(title, v.mainFile);
          String outputName =
              '${show.directory}\\$title\\Season ${s.season.toString().padLeft(2, '0')}\\$episodeTitle.mkv';
          List<Subtitle> subtitles = v.subtitles;
          subtitles.sort((b, a) =>
              a.sub.lengthSync().compareTo(b.sub.lengthSync()));
          String subtitleOrder = List<String>.generate(
              subtitles.length, (index) => '${index + 1}:0,').join();

          await Process.run(mkvmergeDir, [
            '--ui-language en',
            '--gui-mode',
            '-o ^"$outputName^" --language 0:und', //Output 0:0
            '--title $title', //Metadata title
            '--language 1:en ^"^(^" ^"${v.mainFile.path}^" ^"^)^"', //Video file 0:1
            ...subtitles.map((e) {
              var defaultFlag = e == subtitles.first
                  ? '--default-track-flag 0:yes'
                  : '--default-track-flag 0:no';
              return '--language 0:${e.language} $defaultFlag ^"^(^" ^"${e.sub.path}^" ^"^)^"';
            }).toList(), //Subtitles n>0:0
            '--track-order 0:0,0:1,$subtitleOrder', // Track order
          ]);
        }
      }
    }
    return true;
  }
}
