import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

import 'fluent_localizations_fil.dart';

class CustomFluentLocalizationDelegate
    extends LocalizationsDelegate<FluentLocalizations> {
  @override
  Future<FluentLocalizations> load(Locale locale) {
    return SynchronousFuture<FluentLocalizations>(
        lookupFluentLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'fil',
      ].contains(locale.languageCode);

  @override
  bool shouldReload(CustomFluentLocalizationDelegate old) => false;
}

FluentLocalizations lookupFluentLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'fil':
      return FluentLocalizationFil();
  }

  throw FlutterError(
      'FluentLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the definition of custom localizations. Please check the custom '
      'localizations configuration in utilities > custom_fluent_localizations.');
}
