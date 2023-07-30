import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:fluent_ui/fluent_ui.dart' show showDialog;

import 'package:async/async.dart';
import 'package:window_manager/window_manager.dart';
import 'package:path/path.dart' as path;

import '../data/app_data.dart';
import '../models/models.dart';
import '../utilities/utilities.dart';

class ShowMerger {
  static CancelableCompleter? process;
  static double _localPercent = 0.0;
  static bool active = false;

  static Future<void> start(TaskListNotifier tasks) async {
    if (await AppData.checkMkvMerge()) {
      tasks.updateStatus(true);
      process = CancelableCompleter(
        onCancel: () {
          debugPrint('Task Canceled');
          tasks.updateStatus(false);
        },
      );
      process!.complete(
        // For debugging task process.
        //_debugProcessTask(tasks),
        _processTasks(tasks),
      );
    } else {
      await showDialog<void>(
        context: AppData.mainNavigatorKey.currentContext!,
        builder: (context) => const ToolNotExistDialog(
          toolName: 'mkvmerge',
          info:
              'This app relies on mkvmerge to merge files or modify. Please configure the missing tool in Settings > Misc > mkvmerge then browse for the correct .exe file.',
        ),
      );
    }
  }

  /// For debugging task progress.
  // ignore: unused_element
  static Future<void> _debugProcessTask(TaskListNotifier tln) async {
    // Create copy so we don't get concurrent modification error.
    final selected = List<MapEntry<int, TaskNotifier>>.from(tln.items.entries
            .where((e) => tln.selected.contains(e.key))
            .toList())
        .iterator;
    while (selected.moveNext()) {
      if (!tln.active) continue;

      final tn = selected.current.value;
      // Do fake process here
      for (var progress = 0.0; progress <= 100.0; progress += 2) {
        await windowManager.setProgressBar(progress / 100);
        if (!tln.active) break;
        await Future.delayed(const Duration(milliseconds: 100), () {
          tn.updateProgress(progress);
        });
      }

      if (tn.progress >= 100.0) {
        // Output logging
        AppData.outputs.add([
          OutputBasic(
            title: tn.show.title,
            path: tn.show.directory.path,
            profile: tn.profile.name,
            info: OutputInfo(
              taskStatus: TaskStatus.completed,
              outputPath: tn.show.directory.path,
              log: 'Successfully merged files.',
            ),
            dateTime: DateTime.now(),
            duration: const Duration(seconds: 10),
          ),
        ]);
        // Update list
        tln.remove([selected.current.key]);
        // Force notify table listeners (Because PlutoGrid has it's own state management)
        AppData.taskStateKey.currentState?.fetchData();
        AppData.outputStateKey.currentState?.fetchData();
        await _debugProcessTask(tln);
        return;
      } else {
        selected.current.value.updateProgress(0.0);
        await windowManager.setProgressBar(0.0);
      }
    }
    await windowManager.setProgressBar(0.0);
    tln.updateStatus(false);
  }

  // Processing using recursion.
  static Future<void> _processTasks(TaskListNotifier tln) async {
    final selected = List<MapEntry<int, TaskNotifier>>.from(tln.items.entries
            .where((e) => tln.selected.contains(e.key))
            .toList())
        .iterator;
    while (selected.moveNext()) {
      if (!tln.active) continue;

      final tn = selected.current.value;
      // Do mkvmerge processes here
      // Both method uses concurrency + parallelism
      // However methodA is the probably the most commonly used.
      final result = await _mergeMethodA(tln, tn);
      //final result = await _mergeMethodB(tasks, task);

      if (result.taskStatus == TaskStatus.completed ||
          result.taskStatus == TaskStatus.error) {
        //Output logging
        final resultModified = result.copyWith(
          log: result.log.removeLinesWith('Progress:'),
        );
        AppData.outputs.add([
          OutputBasic(
            title: tn.show.title,
            path: result.outputPath,
            profile: tn.profile.name,
            info: resultModified,
            dateTime: DateTime.now(),
            duration: DurationExtension.parseMultiple(
              resultModified.log.linesWith('Multiplexing took'),
            ),
          ),
        ]);
        // Update list
        tln.remove([selected.current.key]);
        // Force notify table listeners (Because PlutoGrid has it's own state management)
        AppData.taskStateKey.currentState?.fetchData();
        AppData.outputStateKey.currentState?.fetchData();
        await _processTasks(tln);
        return;
      } else {
        selected.current.value.updateProgress(0.0);
        await windowManager.setProgressBar(0.0);
      }
    }
    await windowManager.setProgressBar(0.0);
    tln.updateStatus(false);
  }

  /// Processes within max process limit
  // ignore: unused_element
  static Future<OutputInfo> _mergeMethodA(
    TaskListNotifier tln,
    TaskNotifier tn,
  ) async {
    late final result = OutputInfo(
      taskStatus: TaskStatus.canceled,
      outputPath: '',
      log: '',
    );

    if (!(await tn.show.directory.exists())) {
      result.taskStatus = TaskStatus.error;
      result.outputPath = tn.show.directory.path;
      result.log =
          'Source directory no longer exists. Cannot process non-existent files.';
      return result;
    }

    final folder = path.join(tn.show.directory.parent.path,
        tn.show.directory.parent.nameSafe(tn.show.title, '(d)', true));
    result.outputPath = folder;

    final queue = ListQueue<Completer<void>>();
    int runningProcesses = 0;

    final videos = tn.show is Movie
        ? [(tn.show as Movie).video]
        : (tn.show as Series).allVideos;

    final mainCompleter = Completer<OutputInfo>();

    final Map<String, double> videoPercents = {};
    final Map<String, TaskStatus> videoStatuses = {};

    for (final video in videos) {
      if (!tln.active) break;
      videoPercents.addAll({video.mainFile.path: 0.0});

      if (runningProcesses >= AppData.appSettings.maximumProcess) {
        final completer = Completer<void>();
        queue.add(completer);
        await completer.future;
      }

      debugPrint('Processing Item:${video.fileTitle}');
      unawaited(
        _processVideo(
          video,
          folder,
          tln,
          tn,
          result,
          videoPercents,
          videoStatuses,
          mainCompleter,
        ).then((_) {
          runningProcesses--;

          if (queue.isNotEmpty) {
            final completer = queue.removeFirst();
            completer.complete();
          }
          if (tn.completed == tn.total) {
            // Process completed, fulfill the completer with the info
            if (videoStatuses.values
                .every((status) => status == TaskStatus.completed)) {
              result.taskStatus = TaskStatus.completed;
            } else {
              result.taskStatus = TaskStatus.error;
            }

            mainCompleter.complete(result);
          }
        }),
      );

      runningProcesses++;
    }

    // Wait for all tasks to complete
    while (runningProcesses > 0) {
      if (!tln.active) break;
      final completer = Completer<void>();
      queue.add(completer);
      await completer.future;
    }
    // This is for when it is canceled
    if (!tln.active) {
      mainCompleter.complete(result);
    }

    return mainCompleter.future;
  }

  /// Processes by splitting into batches based on max process limit
  // ignore: unused_element
  static Future<OutputInfo> _mergeMethodB(
    TaskListNotifier tln,
    TaskNotifier tn,
  ) async {
    final result = OutputInfo(
      taskStatus: TaskStatus.canceled,
      outputPath: '',
      log: '',
    );
    if (!(await tn.show.directory.exists())) {
      result.taskStatus = TaskStatus.error;
      result.outputPath = tn.show.directory.path;
      result.log =
          'Source directory no longer exists. Cannot process non-existent files.';
      return result;
    }

    final folder = path.join(tn.show.directory.parent.path,
        tn.show.directory.parent.nameSafe(tn.show.title, '(d)', true));
    result.outputPath = folder;
    final List<Video> videos = [];
    if (tn.show is Movie) {
      videos.add((tn.show as Movie).video);
    } else {
      videos.addAll((tn.show as Series).allVideos);
    }

    // Number of videos to process in parallel
    final videoBatches = videos.slices(AppData.appSettings.maximumProcess);

    final mainCompleter = Completer<OutputInfo>();

    final Map<String, double> videoPercents = {};
    final Map<String, TaskStatus> videoStatuses = {};

    Future<void> processBatch(List<Video> batch) async {
      debugPrint(
          'Processing Batch Items: [${batch.map((e) => e.fileTitle).join(', ')}]');
      videoPercents.clear();
      videoPercents.addAll({for (var v in batch) v.mainFile.path: 0.0});
      final List<Future<void>> processingTasks = [];
      for (var v in batch) {
        if (!tln.active) break;
        processingTasks.add(
          _processVideo(
            v,
            folder,
            tln,
            tn,
            result,
            videoPercents,
            videoStatuses,
            mainCompleter,
          ),
        );
      }

      await Future.wait(processingTasks).then((value) {
        if (tn.completed == tn.total) {
          // Process completed, fulfill the completer with the info
          if (videoStatuses.values
              .every((status) => status == TaskStatus.completed)) {
            result.taskStatus = TaskStatus.completed;
          } else {
            result.taskStatus = TaskStatus.error;
          }
          mainCompleter.complete(result);
        }
      });
    }

    // Wait for all tasks to complete
    for (var batch in videoBatches) {
      if (!tln.active) break;
      await processBatch(batch);
    }

    // This is for when it is canceled
    if (!tln.active) {
      mainCompleter.complete(result);
    }

    return mainCompleter.future;
  }

  // MKVMerge process
  static Future<void> _processVideo(
    Video video,
    String folder,
    TaskListNotifier tln,
    TaskNotifier tn,
    OutputInfo result,
    Map<String, double> videoPercents,
    Map<String, TaskStatus> videoStatuses,
    Completer mainCompleter,
  ) async {
    videoStatuses.addAll({video.mainFile.path: TaskStatus.processing});
    final process = await Process.start(
        AppData.appSettings.mkvMergePath, video.command(tn.show, folder));

    // Verbose listener
    await for (String verbose in process.stdout.transform(utf8.decoder)) {
      if (!tln.active) {
        process.kill();
        result.taskStatus = TaskStatus.canceled;
        break;
      }
      result.log += '$verbose\n';
      final verboseStatus = _identifyVerbose(verbose);
      if (verboseStatus == TaskStatus.processing) {
        final verbosePercent = await _parseProgress(tn, verbose);
        if (verbosePercent != null) {
          debugPrint('${video.fileTitle}: {$verbosePercent}');
          videoPercents[video.mainFile.path] = verbosePercent;
          _localPercent = videoPercents.values.sum / videoPercents.length;
          tn.updateProgress(double.parse(_localPercent.toStringAsFixed(1)));
          await windowManager.setProgressBar(tn.progress / 100);
        }
      }
      if (verboseStatus == TaskStatus.error) {
        tn.increaseCompleted();
        videoPercents.remove(video.mainFile.path);
        videoStatuses[video.mainFile.path] = TaskStatus.error;
        debugPrint('${video.fileTitle} Has Error');
      }
      if (verboseStatus == TaskStatus.completed) {
        // Increase completed count
        tn.increaseCompleted();
        videoPercents.remove(video.mainFile.path);
        videoStatuses[video.mainFile.path] = TaskStatus.completed;
        debugPrint('${video.fileTitle} Completed');
        debugPrint('${tn.completed} out of ${tn.total} Completed');
      }
    }
  }

  // Miscs

  static Future<double?> _parseProgress(TaskNotifier tn, String verbose) async {
    double? percent;

    final progressText = RegExp(r'Progress: \d*\.?\d*%');
    if (progressText.hasMatch(verbose)) {
      percent = double.parse(progressText
          .firstMatch(verbose)![0]!
          .replaceAll(RegExp('[^0-9]'), ''));
    }
    return percent;
  }

  static TaskStatus _identifyVerbose(String verbose) {
    if (verbose.contains('Error:')) {
      return TaskStatus.error;
    }
    if (verbose.contains('Multiplexing took')) {
      return TaskStatus.completed;
    }
    return TaskStatus.processing;
  }
}
