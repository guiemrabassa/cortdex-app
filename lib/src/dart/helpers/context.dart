
import 'package:cortdex/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

extension BuildContextCustomExtension on BuildContext {

  AppLocalizations get lang => AppLocalizations.of(this)!;

}