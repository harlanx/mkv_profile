import 'package:fluent_ui/fluent_ui.dart';
import 'package:merge2mkv/data/app_data.dart';
import 'package:window_manager/window_manager.dart';

/// FluentAppBar is a custom app bar that matches the Fluent Theme (Windows 11).
/// It is not the same as the generic title bar for windows which can also be
/// configured with the [WindowManager] package.
class FluentAppBar extends NavigationAppBar {
  FluentAppBar()
      : super(
          automaticallyImplyLeading: false,
          actions: const WindowButtons(),
          height: 34,
          title: DragToMoveArea(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(FluentIcons.my_movies_t_v),
                  SizedBox(width: 10),
                  Text(AppData.kAppTitle),
                ],
              ),
            ),
          ),
        );
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FluentThemeData theme = FluentTheme.of(context);

    return SizedBox(
      width: 138,
      height: 50,
      child: WindowCaption(
        brightness: theme.brightness,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
