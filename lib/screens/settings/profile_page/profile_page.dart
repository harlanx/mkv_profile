import 'package:fluent_ui/fluent_ui.dart';
import 'package:merge2mkv/data/app_data.dart';
import 'package:merge2mkv/models/models.dart';
import 'package:merge2mkv/utilities/utilities.dart';
import 'package:provider/provider.dart';
import 'name_dialog.dart';

class ProfilePage extends StatefulWidget {
  final int index;
  late final UserProfile profile;
  ProfilePage({Key? key, required this.index}) : super(key: key) {
    if (index <= 1) {
      // Default profile (Shouldn't be deleted nor edited) so we just clone it.
      profile = AppData.profiles.items[1].copyWith(name: 'My New Profile');
    } else {
      profile = AppData.profiles.items[index]; // Pass profile by reference.
    }
  }

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final appData = context.read<AppData>();
  late final editProfile = widget.profile.copyWith(); // Copy without reference.;
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
                      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8.0),
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
                          header: const Text('Select what languages to include and set as default.'),
                          content: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 500),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: ListView.builder(
                                    itemCount: AppData.languageCodes.items.length,
                                    itemBuilder: (context, index) {
                                      final language = AppData.languageCodes.items.elementAt(index);
                                      return ListTile(
                                        onPressed: () {},
                                        leading: Text(language.alpha2),
                                        title: Text(language.english),
                                        trailing: IconLabelButton(
                                          onPressed: () => editProfile.updateLanguages(language.alpha2),
                                          iconData: FluentIcons.chevron_right,
                                          alignIconRight: true,
                                          label: 'Add',
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: ReorderableListView.builder(
                                    buildDefaultDragHandles: false,
                                    itemCount: editProfile.languages.length,
                                    onReorder: (oldIndex, newIndex) => editProfile.reorderLanguages(oldIndex, newIndex),
                                    itemBuilder: (context, index) {
                                      final language =
                                          AppData.languageCodes.alpha2ToCode(editProfile.languages.elementAt(index));
                                      final isDefault = language.alpha2 == editProfile.defaultLanguage;
                                      return ReorderableDragStartListener(
                                        key: ValueKey(language),
                                        index: index,
                                        child: ListTile(
                                          onPressed: (){},
                                          leading: IconLabelButton(
                                            onPressed: () => editProfile.updateLanguages(language.alpha2, false),
                                            iconData: FluentIcons.chevron_left,
                                            label: 'Remove',
                                          ),
                                          title: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(language.alpha2),
                                              const SizedBox(width: 8),
                                              Flexible(child: Text(language.english)),
                                            ],
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Visibility(visible: isDefault, child: const Text('Default')),
                                              Checkbox(
                                                semanticLabel: 'isDefault',
                                                checked: isDefault,
                                                onChanged: (val) => editProfile.updateDefaultLanguage(language.alpha2),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: Visibility(
                            visible: editProfile.defaultLanguage.isNotEmpty,
                            child: Text(editProfile.defaultLanguage),
                          ),
                        ),
                        Expander(
                          header: const Text('Replace with space. Regex is allowed. (Entry per line).'),
                          content: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 80, maxHeight: 200),
                            child: TextBox(
                              initialValue: editProfile.stringToSpace.join('\n'),
                              maxLines: null,
                              onChanged: (value) {
                                profile.stringToSpace = value.split('\n');
                              },
                              onSubmitted: (value) {
                                profile.updateAll(stringToSpace: value.split('\n'));
                              },
                            ),
                          ),
                        ),
                        Expander(
                          header: const Text('Remove text. Regex is allowed. (Entry per line).'),
                          content: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 80, maxHeight: 200),
                            child: TextBox(
                              initialValue: editProfile.stringToRemove.join('\n'),
                              maxLines: null,
                              onChanged: (value) {
                                profile.stringToRemove = value.split('\n');
                              },
                              onSubmitted: (value) {
                                profile.updateAll(stringToRemove: value.split('\n'));
                              },
                            ),
                          ),
                        ),
                        Checkbox(
                          content: const Text(
                              '''Use folder name (Recommended), else it uses video file name when scanning movie/series titles.'''),
                          checked: profile.useFolderName,
                          onChanged: (value) {
                            profile.updateAll(useFolderName: value);
                          },
                        ),
                        Checkbox(
                          content: const Text(
                              'Set SDH as default if available (It must be same the language as the default language set for subtitle.)'),
                          checked: profile.defaultSdh,
                          onChanged: (value) {
                            profile.updateAll(defaultSdh: value);
                          },
                        ),
                        Checkbox(
                          content: const Text('Include year in title if available'),
                          checked: profile.includeYear,
                          onChanged: (value) {
                            profile.updateAll(includeYear: value);
                          },
                        ),
                        Checkbox(
                          content: const Text(
                              'Set case sensitivity for the specified strings used when manipulating titles.'),
                          checked: profile.caseSensitive,
                          onChanged: (value) {
                            profile.updateAll(caseSensitive: value);
                          },
                        ),
                        Checkbox(
                          content: const Text(
                              'Remove leading/trailing and replace multiple whitespace to single whitespace.'),
                          checked: profile.whiteSpaceTrim,
                          onChanged: (value) {
                            profile.updateAll(whiteSpaceTrim: value);
                          },
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
    if (widget.index == 0) {
      AppData.profiles.addProfile(editProfile);
    } else {
      AppData.profiles.updateProfile(widget.index, editProfile);
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
      editProfile.updateAll(name: result);
    }
  }
}
