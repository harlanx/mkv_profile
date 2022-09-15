import 'package:fluent_ui/fluent_ui.dart';
import 'package:merge2mkv/data/app_data.dart';
import 'package:merge2mkv/models/models.dart';
import 'package:merge2mkv/utilities/utilities.dart';
import 'package:provider/provider.dart';
import 'name_dialog.dart';

class ProfilePage extends StatefulWidget {
  final int id;
  late final UserProfile profile;
  ProfilePage({Key? key, required this.id}) : super(key: key) {
    if (id <= 2) {
      // Default profile (Shouldn't be deleted nor edited) so we just clone it.
      // This is for creating new profile.
      profile = AppData.profiles.items[id]!.copyWith(name: 'My New Profile');
    } else {
      // This is for editing existing profiles.
      // Pass profile by reference.
      profile = AppData.profiles.items[id]!;
    }
  }

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final appData = context.read<AppData>();
  late final editProfile =
      widget.profile.copyWith(); // Copy without reference.;
  late final nameController = TextEditingController(text: widget.profile.name);

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(),
      child: NavigationView(
        appBar: FluentAppBar(),
        content: ChangeNotifierProvider<UserProfile>.value(
            value: editProfile,
            builder: (context, child) {
              return Consumer<UserProfile>(
                builder: (context, profile, child) {
                  return ScaffoldPage(
                    padding: EdgeInsets.zero,
                    header: CommandBarCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25.0, vertical: 8.0),
                      margin: const EdgeInsets.only(bottom: 10.0),
                      child: CommandBar(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        primaryItems: [
                          CommandBarButton(
                            icon: const Icon(FluentIcons.save),
                            label: const Text('Save'),
                            onPressed: () => _saveChanges(),
                          ),
                          CommandBarButton(
                            icon: const Icon(FluentIcons.cancel),
                            label: const Text('Cancel'),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    content: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              profile.name,
                              style: FluentTheme.of(context).typography.title,
                            ),
                            const SizedBox(width: 5),
                            IconButton(
                              icon: const Icon(FluentIcons.edit),
                              onPressed: () => _updateNameDialog(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Expander(
                          header: const Text(
                              'Select languages to include and choose to set as default.'),
                          trailing: Visibility(
                            visible: editProfile.defaultLanguage.isNotEmpty,
                            child: Text(AppData.languageCodes.items
                                    .firstWhereOrNull((code) =>
                                        code.iso6393 ==
                                        editProfile.defaultLanguage)
                                    ?.name ??
                                ''),
                          ),
                          content: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 500),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(' Langauge: '),
                                    Flexible(
                                      child: AutoSuggestBox<LanguageCode>(
                                        trailingIcon:
                                            const Icon(FluentIcons.search),
                                        onSelected: (selected) {
                                          if (selected.value != null) {
                                            editProfile.updateLanguages(
                                                selected.value!.iso6393);
                                          }
                                        },
                                        items: AppData.languageCodes.items.map(
                                          (code) {
                                            var title =
                                                '${code.name} (${code.iso6393}';
                                            if (code.iso6392 != null) {
                                              title += ', ${code.iso6392}';
                                            }
                                            if (code.iso6391 != null) {
                                              title += ', ${code.iso6391}';
                                            }
                                            title += ')';
                                            return AutoSuggestBoxItem<
                                                LanguageCode>(
                                              value: code,
                                              label: title,
                                            );
                                          },
                                        ).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                                const Text(' Selected Languages: '),
                                Flexible(
                                  child: ReorderableListView.builder(
                                    shrinkWrap: true,
                                    buildDefaultDragHandles: false,
                                    itemCount: editProfile.languages.length,
                                    onReorder: (oldIndex, newIndex) =>
                                        editProfile.reorderLanguages(
                                            oldIndex, newIndex),
                                    itemBuilder: (context, index) {
                                      final language = AppData
                                          .languageCodes.items
                                          .firstWhere((code) =>
                                              code.iso6393 ==
                                              editProfile.languages
                                                  .elementAt(index));
                                      var title =
                                          '${language.name} (${language.iso6393}';
                                      if (language.iso6392 != null) {
                                        title += ', ${language.iso6392}';
                                      }
                                      if (language.iso6391 != null) {
                                        title += ', ${language.iso6391}';
                                      }
                                      title += ')';

                                      final isDefault = language.iso6393 ==
                                          editProfile.defaultLanguage;
                                      return ReorderableDragStartListener(
                                        key: ValueKey(language),
                                        index: index,
                                        child: ListTile(
                                          onPressed: () {},
                                          trailing: IconButton(
                                            onPressed: () =>
                                                editProfile.updateLanguages(
                                                    language.iso6393, false),
                                            icon:
                                                const Icon(FluentIcons.remove),
                                          ),
                                          title: Text(title),
                                          leading: Checkbox(
                                            semanticLabel: 'isDefault',
                                            checked: isDefault,
                                            onChanged: (val) => editProfile
                                                .updateDefaultLanguage(
                                                    language.iso6393),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expander(
                          header: const Text(
                              'Remove text. Regex is allowed. (Entry per line).'),
                          content: ConstrainedBox(
                            constraints: const BoxConstraints(
                                minHeight: 80, maxHeight: 200),
                            child: TextBox(
                              controller: TextEditingController.fromValue(
                                TextEditingValue(
                                  text: editProfile.removeString.join('\n'),
                                ),
                              ),
                              //initialValue: editProfile.removeString.join('\n'),
                              maxLines: null,
                              onChanged: (value) =>
                                  profile.removeString = value.split('\n'),
                              onSubmitted: (value) => profile.update(
                                  removeString: value.split('\n')),
                            ),
                          ),
                        ),
                        Expander(
                          header: const Text(
                              'Replace with space. Regex is allowed. (Entry per line).'),
                          content: ConstrainedBox(
                            constraints: const BoxConstraints(
                                minHeight: 80, maxHeight: 200),
                            child: TextBox(
                              controller: TextEditingController.fromValue(
                                TextEditingValue(
                                  text: editProfile.replaceString.join('\n'),
                                ),
                              ),
                              //initialValue: editProfile.replaceString.join('\n'),
                              maxLines: null,
                              onChanged: (value) =>
                                  profile.replaceString = value.split('\n'),
                              onSubmitted: (value) => profile.update(
                                  replaceString: value.split('\n')),
                            ),
                          ),
                        ),
                        Checkbox(
                          content: const Text(
                              '''Use folder name (Recommended) instead of video file's name when scanning the title.'''),
                          checked: profile.useFolderName,
                          onChanged: (value) =>
                              profile.update(useFolderName: value),
                        ),
                        Checkbox(
                          content: const Text(
                              'Set case sensitivity for the specified strings used when manipulating titles.'),
                          checked: profile.caseSensitive,
                          onChanged: (value) {
                            profile.update(caseSensitive: value);
                          },
                        ),
                        Checkbox(
                          content: const Text(
                              'Set SDH version for the default language subtitle if available'),
                          checked: profile.defaultSdh,
                          onChanged: (value) =>
                              profile.update(defaultSdh: value),
                        ),
                        Checkbox(
                          content:
                              const Text('Remove language names from titles.'),
                          checked: profile.removeLanguageTitle,
                          onChanged: (value) =>
                              profile.update(removeLanguageTitle: value),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (editProfile == widget.profile) {
      return true;
    }
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Discard changes?'),
        content: const Text('Are you sure you want to discard changes?'),
        actions: [
          FilledButton(
            child: const Text('Save Changes'),
            onPressed: () => _saveChanges(),
          ),
          Button(
            child: const Text('''Don't Save'''),
            onPressed: () => Navigator.pop(context, true),
          ),
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  void _saveChanges() {
    if (widget.id <= 2) {
      editProfile.id = DateTime.now().millisecondsSinceEpoch;
      AppData.profiles.add(
        editProfile.id,
        editProfile,
      );
    } else {
      widget.profile.update(
        caseSensitive: editProfile.caseSensitive,
        defaultLanguage: editProfile.defaultLanguage,
        defaultSdh: editProfile.defaultSdh,
        episodeTitleFormat: editProfile.episodeTitleFormat,
        languages: editProfile.languages,
        name: editProfile.name,
        removeLanguageTitle: editProfile.removeLanguageTitle,
        removeString: editProfile.removeString,
        replaceString: editProfile.replaceString,
        titleFormat: editProfile.titleFormat,
        useFolderName: editProfile.useFolderName,
      );
      AppData.profiles.refresh();
    }
    Navigator.pop(context);
  }

  void _updateNameDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => NameDialog(
        profile: editProfile,
        controller: nameController,
      ),
    );
    if (result != null) {
      editProfile.update(name: result);
    }
  }
}
