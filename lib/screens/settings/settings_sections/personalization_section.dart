import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as mt;
import 'package:fluent_ui/fluent_ui.dart';

import 'package:provider/provider.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:tuple/tuple.dart';

import '../../../data/app_data.dart';
import '../../../utilities/utilities.dart';

class PersonalizationSection extends StatelessWidget {
  const PersonalizationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context);

    return InfoLabel(
      label: l10n.personalization,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(FluentIcons.globe),
                  const SizedBox(width: 6),
                  Text(
                    l10n.language,
                    style: theme.typography.body,
                  ),
                  const Spacer(),
                  Selector<AppSettingsNotifier, Locale>(
                    selector: (p0, p1) => p1.locale,
                    builder: (context, value, child) {
                      return ComboBox<Locale>(
                        value: value,
                        items: [
                          for (var locale in AppLocalizations.supportedLocales)
                            ComboBoxItem(
                              value: locale,
                              child: RichText(
                                text: TextSpan(
                                  text: locale.flagEmoji,
                                  style: theme.typography.body?.copyWith(
                                      fontFamily: 'NotoColorEmojiWindows'),
                                  children: [
                                    TextSpan(
                                      text: ' ${locale.name}',
                                      style: theme.typography.bodyStrong,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            context
                                .read<AppSettingsNotifier>()
                                .setLocale(value);
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            Selector<AppSettingsNotifier, ThemeMode>(
              selector: (p0, p1) => p1.themeMode,
              builder: (context, value, child) {
                return Expander(
                  leading: const Icon(FluentIcons.circle_half_full),
                  header: Text(l10n.theme),
                  trailing: Text(value.name.titleCased),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final mode in ThemeMode.values)
                        Padding(
                          padding: ThemeMode.values.last == mode
                              ? EdgeInsets.zero
                              : const EdgeInsets.only(bottom: 10.0),
                          child: RadioButton(
                            content: Text(mode.name.titleCased),
                            checked: value == mode,
                            onChanged: (value) async {
                              context
                                  .read<AppSettingsNotifier>()
                                  .setThemeMode(mode);
                              WidgetsBinding.instance
                                  .addPostFrameCallback((_) async {
                                await Future.delayed(
                                    const Duration(milliseconds: 150),
                                    () async {
                                  if (context.mounted) {
                                    await context
                                        .read<AppSettingsNotifier>()
                                        .setWindowEffect(context,
                                            AppData.appSettings.windowEffect);
                                  }
                                });
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            Selector<AppSettingsNotifier, WindowsFluentEffect>(
              selector: (p0, p1) => p1.windowEffect,
              builder: (context, value, child) {
                return Expander(
                  leading: const Icon(FluentIcons.format_painter),
                  header: Text(l10n.windowEffect),
                  trailing: Text(value.name.titleCased),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: List.from(
                      WindowsFluentEffect.values.map(
                        (e) => Padding(
                          padding: WindowsFluentEffect.values.last == e
                              ? EdgeInsets.zero
                              : const EdgeInsets.only(bottom: 10.0),
                          child: RadioButton(
                            content: Text(e.name.titleCased),
                            checked: value == e,
                            onChanged: (value) async {
                              await context
                                  .read<AppSettingsNotifier>()
                                  .setWindowEffect(context, e);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            Selector<AppSettingsNotifier, Tuple2<AccentMode, Color>>(
              selector: (p0, p1) => Tuple2(p1.accentMode, p1.customAccent),
              builder: (context, value, child) {
                final accentMode = value.item1;
                final customAccent = value.item2;
                return Expander(
                  leading: const Icon(FluentIcons.color),
                  header: Text(l10n.accent),
                  trailing: Card(
                    backgroundColor: theme.accentColor,
                    child: const SizedBox(
                      height: 4,
                      width: 4,
                    ),
                  ),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${l10n.mode}: ',
                            style: theme.typography.bodyStrong,
                          ),
                          ComboBox<AccentMode>(
                            value: accentMode,
                            items: List.from(
                              AccentMode.values.map(
                                (e) => ComboBoxItem<AccentMode>(
                                  value: e,
                                  child: Text(e.name.titleCased),
                                ),
                              ),
                            ),
                            onChanged: (val) {
                              if (val != null) {
                                context
                                    .read<AppSettingsNotifier>()
                                    .setAccentMode(val);
                              }
                            },
                          ),
                          const SizedBox(width: 6),
                          for (var color
                              in theme.accentColor.swatch.entries) ...[
                            Container(
                              height: 20,
                              width: 20,
                              color: color.value,
                            ),
                          ],
                          if (kDebugMode) ...[
                            const SizedBox(width: 8),
                            Flexible(
                              child: Builder(
                                builder: (context) {
                                  final color =
                                      HSLColor.fromColor(theme.accentColor);
                                  return Text(
                                    'H:${color.hue.toStringAsFixed(2)} S:${color.saturation} L:${color.lightness.toStringAsFixed(2)}',
                                    maxLines: 1,
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                      Visibility(
                        visible: accentMode == AccentMode.custom,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: mt.Material(
                            child: ColorPicker(
                              color: customAccent,
                              enableOpacity: false,
                              enableTonalPalette: false,
                              showColorCode: true,
                              showRecentColors: true,
                              enableShadesSelection: false,
                              recentColors: [
                                for (var colorInt
                                    in AppData.defaultAccents) ...[
                                  Color(colorInt),
                                ],
                              ],
                              pickersEnabled: const {
                                ColorPickerType.both: false,
                                ColorPickerType.primary: true,
                                ColorPickerType.accent: false,
                                ColorPickerType.bw: false,
                                ColorPickerType.custom: false,
                                ColorPickerType.wheel: true,
                              },
                              onColorChanged: (val) {
                                context
                                    .read<AppSettingsNotifier>()
                                    .setAccentColor(val);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
