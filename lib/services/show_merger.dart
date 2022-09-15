import 'dart:async';

import 'package:path/path.dart' as path;
import 'package:merge2mkv/data/app_data.dart';
import 'package:merge2mkv/models/models.dart';
import 'package:merge2mkv/utilities/utilities.dart';

class ShowMerger {
  final String _mkvmergeDir = path.join(
      File(Platform.resolvedExecutable).parent.path, 'bin', 'mkvmerge.exe');
  CancelableOperation? process;
  double _localPercent = 0.0;

  void start(TaskListNotifier tasks) {
    tasks.updateStatus(true);
    process = CancelableOperation.fromFuture(
      // For debugging task process.
      // disable _processTasks when testing debug.
      //_debugPrcsKeep(tasks),
      _processTasks(tasks),
      onCancel: () {
        tasks.updateStatus(false);
      },
    );
  }

  /// For debugging task progress.
  Future<void> _debugPrcsKeep(TaskListNotifier tasks) async {
    // Create copy so we don't get concurrent modification error.
    var selected = List<MapEntry<int, TaskNotifier>>.from(tasks.items.entries
            .where((e) => tasks.selected.contains(e.key))
            .toList())
        .iterator;
    while (selected.moveNext()) {
      if (!tasks.active) continue;

      var task = selected.current.value;
      //// Do fake process here
      for (var progress = 0.0; progress <= 100.0; progress += 5) {
        if (!tasks.active) break;
        await Future.delayed(const Duration(milliseconds: 100), () {
          task.updateProgress(progress);
        });
      }

      if (task.progress >= 100.0) {
        //Output Logging
        AppData.outputs.add([
          OutputBasic(
            title: task.item.title,
            path: task.item.directory.parent.path,
            profile: task.profile.name,
            info: OutputInfo(
              taskStatus: TaskStatus.completed,
              log: 'Successfully merged files.',
            ),
            dateTime: DateTime.now(),
          ),
        ]);
        // Update list
        tasks.remove([selected.current.key]);
        //Force notify table listeners (Because PlutoGrid has it's own state management)
        AppData.taskStateKey.currentState?.fetchData();
        AppData.outputStateKey.currentState?.fetchData();
        _debugPrcsKeep(tasks);
        return;
      } else {
        selected.current.value.updateProgress(0.0);
      }
    }
    tasks.updateStatus(false);
  }

  // Processing using recursion.
  Future<void> _processTasks(TaskListNotifier tasks) async {
    var selected = List<MapEntry<int, TaskNotifier>>.from(tasks.items.entries
            .where((e) => tasks.selected.contains(e.key))
            .toList())
        .iterator;
    while (selected.moveNext()) {
      if (!tasks.active) continue;

      var task = selected.current.value;
      //// Do mkvmerge process here
      var result = await _mergeShow(task);

      if (result.taskStatus == TaskStatus.completed ||
          result.taskStatus == TaskStatus.error) {
        //Output logging
        AppData.outputs.add([
          OutputBasic(
            title: task.item.title,
            path: task.item.directory.parent.path,
            profile: task.profile.name,
            info: result.copyWith(log: result.log.removeBlankLines()),
            dateTime: DateTime.now(),
          ),
        ]);
        // Update list
        tasks.remove([selected.current.key]);
        // Force notify table listeners (Because PlutoGrid has it's own state management)
        AppData.taskStateKey.currentState?.fetchData();
        AppData.outputStateKey.currentState?.fetchData();
        _processTasks(tasks);
        return;
      } else if (result.taskStatus == TaskStatus.canceled) {
        selected.current.value.updateProgress(0.0);
      }
    }
    tasks.updateStatus(false);
  }

  Future<OutputInfo> _mergeShow(TaskNotifier taskNotifier) async {
    if (!(await taskNotifier.item.directory.exists())) {
      return OutputInfo(
          taskStatus: TaskStatus.error, log: 'Directory no longer exist.');
    }
    if (!AppData.profiles.items.containsKey(taskNotifier.profile.id)) {
      return OutputInfo(
          taskStatus: TaskStatus.error, log: 'Profile no longer exist.');
    }
    var show = taskNotifier.item;
    var result = OutputInfo(taskStatus: TaskStatus.canceled, log: '');
    Completer<OutputInfo> completer = Completer<OutputInfo>();

    if (show is Movie) {
      String title = TitleScanner.scanTitle(taskNotifier);
      String outputName = '${show.directory.path}\\$title\\$title.mkv';
      List<Subtitle> subtitles = show.video.subtitles;
      subtitles
          .sort((b, a) => a.file.lengthSync().compareTo(b.file.lengthSync()));

      // await Process.run(executable, arguments);
      // Maybe show how long it took?
      Process.start(
        _mkvmergeDir,
        [
          '--output',
          outputName, // Output File
          //'--title', title, // Title From TitleScanner
          '--language', //Video Track Language
          '${show.video.info.media.videoInfo.id}:${show.video.info.media.videoInfo.language ?? 'und'}',
          // '--track-name 0:Undefined', // Adding Track Name
          for (var audioTrack in show.video.info.media.audioInfo) ...[
            '--language',
            '${audioTrack.id}:${audioTrack.language ?? 'und'}'
          ],
          for (var subTrack in show.video.info.media.textInfo) ...[
            '--language',
            '${subTrack.id}:${subTrack.language ?? 'und'}'
          ],
          //'--no-attachments', // Remove all attachments such as movie poster/cover and fonts
          //'--no-chapters', // Remove all chapters, usually exist and hand generated on MKVs
          // '-S', // Remove all existing subtitles or -S 2,4 (keep 2 and 4 track subtitle)
          show.video.mainFile.path, // Input File
          for (var sub in subtitles) ...[
            if (sub.language.iso6393 ==
                taskNotifier.profile.defaultLanguage) ...[
              '--default-track',
              '0:yes'
            ] else ...[
              '--default-track',
              '0:no'
            ],
            '--language',
            '0:${sub.language.iso6393}',
            sub.file.path,
          ],
          //'--track-order 0:0,0:1,$subtitleOrder', // Track order may not be neccessary as it already follows the order of list of arguments.
        ],
      ).then((p) {
        //var mkvMergePattern = RegExp(r'mkvmerge v\d*\.?\d*\.?\d*');
        // Verbose listener
        var stdoutSub = p.stdout.transform(utf8.decoder).listen((verboseText) {
          result.log += '$verboseText\n';
          result.taskStatus = _identifyVerbose(verboseText);
          if (result.taskStatus == TaskStatus.processing) {
            _updateProgresses(taskNotifier, verboseText);
          }
        });

        // Wait for the process to complete
        p.exitCode.then((exitCode) {
          // Cancel the subscriptions
          stdoutSub.cancel();

          // Process completed, fulfill the completer with the desired result
          completer.complete(result);
        });
      });
    } else {
      show as Series;
      String title = TitleScanner.scanTitle(taskNotifier);
      bool hasError = false;
      for (var sns in show.seasons) {
        if (hasError == true) break;
        sns.videos.sort((a, b) => compareNatural(
            a.mainFile.name,
            b.mainFile
                .name)); // Sort by name so it gets merged in the correct order
        for (var v in sns.videos) {
          if (hasError == true) break;
          String episodeTitle = TitleScanner.scanEpisode(
              taskNotifier.profile, sns.season, title, v);
          String outputName =
              '${show.directory}\\$title\\Season ${sns.season.toString().padLeft(2, '0')}\\$episodeTitle.mkv';
          List<Subtitle> subtitles = v.subtitles;
          subtitles.sort(
              (b, a) => a.file.lengthSync().compareTo(b.file.lengthSync()));
          Process.start(
            _mkvmergeDir,
            [
              '--output',
              outputName, // Output File
              //'--title', title, // Title From TitleScanner
              '--language', //Video Track Language
              '${v.info.media.videoInfo.id}:${v.info.media.videoInfo.language ?? 'und'}',
              // '--track-name 0:Undefined', // Adding Track Name
              for (var audioTrack in v.info.media.audioInfo) ...[
                '--language',
                '${audioTrack.id}:${audioTrack.language ?? 'und'}'
              ],
              for (var subTrack in v.info.media.textInfo) ...[
                '--language',
                '${subTrack.id}:${subTrack.language ?? 'und'}'
              ],
              //'--no-attachments', // Remove all attachments such as movie poster/cover and fonts
              //'--no-chapters', // Remove all chapters, usually exist and hand generated on MKVs
              // '-S', // Remove all existing subtitles or -S 2,4 (keep 2 and 4 track subtitle)
              v.mainFile.path, // Input File
              for (var sub in subtitles) ...[
                if (sub.language.iso6393 ==
                    taskNotifier.profile.defaultLanguage) ...[
                  '--default-track',
                  '0:yes'
                ] else ...[
                  '--default-track',
                  '0:no'
                ],
                '--language',
                '0:${sub.language}',
                sub.file.path,
              ],
              //'--track-order 0:0,0:1,$subtitleOrder', // Track order may not be neccessary as it follows the order of list of arguments.
            ],
          ).then((p) {
            var stdoutSub = p.stdout.transform(utf8.decoder).listen(
              (verboseText) {
                result.log += '$verboseText\n';
                result.taskStatus = _identifyVerbose(verboseText);
                if (result.taskStatus == TaskStatus.processing) {
                  _updateProgresses(taskNotifier, verboseText);
                } else if (result.taskStatus == TaskStatus.error) {
                  hasError = true;
                }
              },
            );

            // Wait for the process to complete
            p.exitCode.then((exitCode) {
              // Cancel the subscriptions
              stdoutSub.cancel();
              // Process completed
              completer.complete(result);
            });
          });
        }
      }
    }
    return completer.future;
  }

  void _updateProgresses(TaskNotifier tn, String verbose) {
    double currentPercent = tn.progress;

    final progressText = RegExp(r'Progress: \d*\.?\d*%');
    if (progressText.hasMatch(verbose)) {
      currentPercent = double.parse(progressText
          .firstMatch(verbose)![0]!
          .replaceAll(RegExp('[^0-9]'), ''));
      _localPercent = currentPercent;
      tn.updateProgress(double.parse(_localPercent.toStringAsFixed(1)));
    }
  }

  TaskStatus _identifyVerbose(String verbose) {
    if (verbose.contains('Error:')) {
      return TaskStatus.error;
    }
    if (verbose.contains('Multiplexing took')) {
      return TaskStatus.completed;
    }
    return TaskStatus.processing;
  }
}
