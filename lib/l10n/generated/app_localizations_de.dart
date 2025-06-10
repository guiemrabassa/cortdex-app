// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get helloWorld => 'Hallo Welt!';

  @override
  String get welcomeMessage => 'Willkommen bei der Cortdex-Anwendung!';

  @override
  String get chooseDatabaseType => 'Datenbanktyp auswählen';

  @override
  String get local => 'Lokal';

  @override
  String local_(Object value) {
    return 'Lokal $value';
  }

  @override
  String get remote => 'Remote';

  @override
  String remote_(Object value) {
    return 'Remote $value';
  }

  @override
  String get connection => 'Verbindung';

  @override
  String get chooseConnectionType => 'Verbindungstyp auswählen';

  @override
  String get saveDbSettings => 'Datenbankeinstellungen speichern';

  @override
  String get settings => 'Einstellungen';

  @override
  String settings_(Object value) {
    return '$value-Einstellungen';
  }

  @override
  String get loading => 'Laden';

  @override
  String get failed => 'Fehlgeschlagen';

  @override
  String get loadingFailed => 'Laden fehlgeschlagen';

  @override
  String get eraseAllSettings => 'Erase all settings';

  @override
  String get client => 'Client';

  @override
  String get server => 'Server';

  @override
  String get choose => 'Auswählen';

  @override
  String get address => 'Adresse';

  @override
  String address_(Object value) {
    return '$value-Adresse';
  }

  @override
  String get port => 'Port';

  @override
  String get model => 'Modell';

  @override
  String get path => 'Pfad';

  @override
  String path_(Object value) {
    return '$value-Pfad';
  }

  @override
  String get enter => 'Eingeben';

  @override
  String enter_(Object value) {
    return '$value eingeben';
  }

  @override
  String get database => 'Datenbank';

  @override
  String selectionHint(String value) {
    return 'Wähle den $value';
  }

  @override
  String get connect => 'Verbinden';

  @override
  String connectTo(String value) {
    return 'Mit $value verbinden';
  }

  @override
  String get disconnect => 'Trennen';

  @override
  String disconnectFrom(String value) {
    return 'Von $value trennen';
  }

  @override
  String get start => 'Starten';

  @override
  String startThe(String value) {
    return '$value starten';
  }

  @override
  String get stop => 'Stoppen';

  @override
  String stop_(Object value) {
    return '$value stoppen';
  }

  @override
  String create_(String value) {
    return '$value erstellen';
  }

  @override
  String inputHint(String value) {
    return 'Gib den $value ein';
  }

  @override
  String get addNew => 'Neu hinzufügen';

  @override
  String get add => 'Hinzufügen';

  @override
  String get create => 'Erstellen';

  @override
  String get delete => 'Löschen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get use => 'Verwenden';

  @override
  String error(String value) {
    return 'Fehler$value';
  }

  @override
  String notFound(String value) {
    return 'Kein $value gefunden';
  }

  @override
  String get share => 'Teilen';

  @override
  String get menu => 'Menü';

  @override
  String get noteEditorHint => 'Beginne, deine Notizen zu schreiben...';

  @override
  String get attribute => 'Attribut';

  @override
  String get attributes => 'Attributes';

  @override
  String get note => 'Notiz';

  @override
  String get notes => 'notes';

  @override
  String get pin => 'Pin';

  @override
  String get unpin => 'Unpin';
}
