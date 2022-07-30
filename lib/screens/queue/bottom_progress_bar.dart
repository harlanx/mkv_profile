import 'package:fluent_ui/fluent_ui.dart';
import 'package:merge2mkv/data/app_data.dart';
import 'package:provider/provider.dart';

class BottomProgressBar extends StatefulWidget {
  const BottomProgressBar({Key? key}) : super(key: key);

  @override
  State<BottomProgressBar> createState() => _BottomProgressBarState();
}

class _BottomProgressBarState extends State<BottomProgressBar> {
  @override
  Widget build(BuildContext context) {
    var showsQueue = context.watch<ShowQueueListNotifier>();
    if (showsQueue.items.isEmpty) return const SizedBox.shrink();
    final activeQueue = showsQueue.activeIndex != null ? showsQueue.items[showsQueue.activeIndex!].show.title : 'None';
    return Card(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Processing: $activeQueue'),
          SizedBox(
            width: 150,
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Builder(
                builder: (context) {
                  if (showsQueue.progress <= 0) return const Text('— — — — —');
                  return ProgressBar(value: showsQueue.progress);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
