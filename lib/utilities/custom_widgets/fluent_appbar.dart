import 'package:fluent_ui/fluent_ui.dart';

import 'package:window_manager/window_manager.dart';

import '../../data/app_data.dart';

/// FluentAppBar is a custom app bar that matches the Fluent Theme (Windows 11).
/// It is not the same as the generic title bar for windows which can also be
/// configured with the window_manager package.
class FluentAppBar extends NavigationAppBar {
  FluentAppBar({
    Key? key,
    required BuildContext context,
  }) : super(
          key: key,
          automaticallyImplyLeading: false,
          actions: const WindowButtons(),
          height: 34,
          title: DragToMoveArea(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/icons/mkv_profile.png',
                    height: FluentTheme.of(context).iconTheme.size,
                    width: FluentTheme.of(context).iconTheme.size,
                  ),
                  const SizedBox(width: 6),
                  const Text(AppData.appTitle),
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
