import 'package:flutter/material.dart';
import 'package:cortdex/src/dart/settings/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'localization.g.dart';

// TODO: Config iOS
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.

enum LocalizationKey implements SettingsKey {
  languageCode
}

@riverpod
class AppLanguage extends _$AppLanguage {

  @override
  Locale build() {
    return Locale(Settings().getOrInsert(LocalizationKey.languageCode, 'en'));
  }

  void changeLanguage(Locale locale) async {
    state = locale;
    await Settings().save(LocalizationKey.languageCode, locale.languageCode);
  }

}