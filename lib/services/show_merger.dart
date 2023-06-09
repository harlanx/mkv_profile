import 'dart:async';
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
              'This app relies on mkvmerge to merge the files into a single mkv file. Please configure the missing tool in Settings > Misc > mkvmerge then browse for the correct .exe file.',
        ),
      );
    }
  }

  /// For debugging task progress.
  // ignore: unused_element
  static Future<void> _debugProcessTask(TaskListNotifier tasks) async {
    // Create copy so we don't get concurrent modification error.
    var selected = List<MapEntry<int, TaskNotifier>>.from(tasks.items.entries
            .where((e) => tasks.selected.contains(e.key))
            .toList())
        .iterator;
    while (selected.moveNext()) {
      if (!tasks.active) continue;

      var task = selected.current.value;
      //// Do fake process here
      for (var progress = 0.0; progress <= 100.0; progress += 2) {
        windowManager.setProgressBar(progress / 100);
        if (!tasks.active) break;
        await Future.delayed(const Duration(milliseconds: 100), () {
          task.updateProgress(progress);
        });
      }

      if (task.progress >= 100.0) {
        //Output Logging
        AppData.outputs.add([
          OutputBasic(
            title: task.show.title,
            path: task.show.directory.path,
            profile: task.profile.name,
            info: OutputInfo(
              taskStatus: TaskStatus.completed,
              outputPath: task.show.directory.path,
              log: 'Successfully merged files.',
            ),
            dateTime: DateTime.now(),
            duration: const Duration(seconds: 10),
          ),
        ]);
        // Update list
        tasks.remove([selected.current.key]);
        //Force notify table listeners (Because PlutoGrid has it's own state management)
        AppData.taskStateKey.currentState?.fetchData();
        AppData.outputStateKey.currentState?.fetchData();
        await _debugProcessTask(tasks);
        return;
      } else {
        selected.current.value.updateProgress(0.0);
        windowManager.setProgressBar(0.0);
      }
    }
    windowManager.setProgressBar(0.0);
    tasks.updateStatus(false);
  }

  // Processing using recursion.
  static Future<void> _processTasks(TaskListNotifier tasks) async {
    var selected = List<MapEntry<int, TaskNotifier>>.from(tasks.items.entries
            .where((e) => tasks.selected.contains(e.key))
            .toList())
        .iterator;
    while (selected.moveNext()) {
      if (!tasks.active) continue;

      var task = selected.current.value;
      //// Do mkvmerge process here
      var result = await _merge(task);

      if (result.taskStatus == TaskStatus.completed ||
          result.taskStatus == TaskStatus.error) {
        //Output logging
        final resultModified = result.copyWith(
          log: result.log.removeLinesWith('Progress:'),
        );
        AppData.outputs.add([
          OutputBasic(
            title: task.show.title,
            path: result.outputPath,
            profile: task.profile.name,
            info: resultModified,
            dateTime: DateTime.now(),
            duration: DurationExtension.parseMultiple(
              resultModified.log.linesWith('Multiplexing took'),
            ),
          ),
        ]);
        // Update list
        tasks.remove([selected.current.key]);
        // Force notify table listeners (Because PlutoGrid has it's own state management)
        AppData.taskStateKey.currentState?.fetchData();
        AppData.outputStateKey.currentState?.fetchData();
        await _processTasks(tasks);
        return;
      } else if (result.taskStatus == TaskStatus.canceled) {
        selected.current.value.updateProgress(0.0);
        windowManager.setProgressBar(0.0);
      }
    }
    windowManager.setProgressBar(0.0);
    tasks.updateStatus(false);
  }

  static Future<OutputInfo> _merge(TaskNotifier tn) async {
    var result = OutputInfo(
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

    final String mkvmergeDir = AppData.appSettings.mkvMergePath;
    var folder = path.join(tn.show.directory.parent.path,
        tn.show.directory.parent.nameSafe(tn.show.title, '(d)', true));
    result.outputPath = folder;
    List<Video> videos = [];
    if (tn.show is Movie) {
      videos.add((tn.show as Movie).video);
    } else {
      videos.addAll((tn.show as Series).allVideos);
    }
    bool hasError = false;
    // Number of videos to process in parallel
    final videoBatches = videos.slices(AppData.appSettings.maximumProcess);

    final completer = Completer<OutputInfo>();

    Map<String, double> batchPercents = {};
    Future<void> processVideo(Video video, String folder) async {
      var process =
          await Process.start(mkvmergeDir, video.command(tn.show, folder));

      // Verbose listener
      await for (String verbose in process.stdout.transform(utf8.decoder)) {
        result.log += '$verbose\n';
        result.taskStatus = _identifyVerbose(verbose);
        if (result.taskStatus == TaskStatus.processing) {
          var verbosePercent = await _parseProgress(tn, verbose);
          if (verbosePercent != null) {
            debugPrint('${video.fileTitle}: {$verbosePercent}');
            batchPercents[video.mainFile.path] = verbosePercent;
            _localPercent = batchPercents.values.sum / batchPercents.length;
            tn.updateProgress(double.parse(_localPercent.toStringAsFixed(1)));
            await windowManager.setProgressBar(tn.progress / 100);
          }
        }
        if (result.taskStatus == TaskStatus.error) {
          hasError = true;
        }
        if (result.taskStatus == TaskStatus.completed) {
          // Increase completed count
          tn.increaseCompleted();
          debugPrint('${video.fileTitle} Completed');
          debugPrint('${tn.completed} out of ${tn.total} Completed');
          if (tn.completed == tn.total) {
            // Process completed, fulfill the completer with the info
            completer.complete(result);
          }
        }
      }
    }

    Future<void> processBatch(List<Video> batch) async {
      debugPrint(
          'Processing Batch Items: [${batch.map((e) => e.fileTitle).join(', ')}]');
      batchPercents.clear();
      batchPercents = {for (var v in batch) v.mainFile.path: 0.0};
      List<Future<void>> processingTasks = [];
      for (var v in batch) {
        if (hasError == true) break;
        processingTasks.add(processVideo(v, folder));
      }

      await Future.wait(processingTasks);
    }

    for (var batch in videoBatches) {
      if (hasError == true) break;
      await processBatch(batch);
    }

    return completer.future;
  }

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
