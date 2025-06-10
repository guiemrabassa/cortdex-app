// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get helloWorld => 'Hello World!';

  @override
  String get welcomeMessage => 'Welcome to the Cortdex application!';

  @override
  String get chooseDatabaseType => 'Choose Database Type';

  @override
  String get local => 'Local';

  @override
  String local_(Object value) {
    return 'Local $value';
  }

  @override
  String get remote => 'Remote';

  @override
  String remote_(Object value) {
    return 'Remote $value';
  }

  @override
  String get connection => 'Connection';

  @override
  String get chooseConnectionType => 'Choose Connection Type';

  @override
  String get saveDbSettings => 'Save database settings';

  @override
  String get settings => 'Settings';

  @override
  String settings_(Object value) {
    return '$value settings';
  }

  @override
  String get loading => 'Loading';

  @override
  String get failed => 'Failed';

  @override
  String get loadingFailed => 'Loading failed';

  @override
  String get eraseAllSettings => 'Erase all settings';

  @override
  String get client => 'Client';

  @override
  String get server => 'Server';

  @override
  String get choose => 'Choose';

  @override
  String get address => 'Address';

  @override
  String address_(Object value) {
    return '$value Address';
  }

  @override
  String get port => 'Port';

  @override
  String get model => 'Model';

  @override
  String get path => 'Path';

  @override
  String path_(Object value) {
    return '$value path';
  }

  @override
  String get enter => 'Enter';

  @override
  String enter_(Object value) {
    return 'Enter $value';
  }

  @override
  String get database => 'Database';

  @override
  String selectionHint(String value) {
    return 'Choose the $value';
  }

  @override
  String get connect => 'Connect';

  @override
  String connectTo(String value) {
    return 'Connect to $value';
  }

  @override
  String get disconnect => 'Disconnect';

  @override
  String disconnectFrom(String value) {
    return 'Disconnect from $value';
  }

  @override
  String get start => 'Start';

  @override
  String startThe(String value) {
    return 'Start $value';
  }

  @override
  String get stop => 'Stop';

  @override
  String stop_(Object value) {
    return 'Stop $value';
  }

  @override
  String create_(String value) {
    return 'Create $value';
  }

  @override
  String inputHint(String value) {
    return 'Enter the $value';
  }

  @override
  String get addNew => 'Add new';

  @override
  String get add => 'Add';

  @override
  String get create => 'Create';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get use => 'Use';

  @override
  String error(String value) {
    return 'Error$value';
  }

  @override
  String notFound(String value) {
    return 'No $value found';
  }

  @override
  String get share => 'Share';

  @override
  String get menu => 'Menu';

  @override
  String get noteEditorHint => 'Start writing your notes...';

  @override
  String get attribute => 'Attribute';

  @override
  String get attributes => 'Attributes';

  @override
  String get note => 'note';

  @override
  String get notes => 'notes';

  @override
  String get pin => 'Pin';

  @override
  String get unpin => 'Unpin';

  @override
  String get interval => 'Interval';

  @override
  String get seconds => 'Seconds';

  @override
  String get autoSave => 'Auto save';

  @override
  String get saveOnClose => 'Save on close';
}
