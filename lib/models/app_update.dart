class AppUpdate {
  AppUpdate({
    required this.isOutdated,
    required this.info,
    required this.isModifiersOutdated,
    required this.modifiersInfo,
  });

  final bool isOutdated;
  final Map<String, dynamic> info;
  final bool isModifiersOutdated;
  final String modifiersInfo;
}
