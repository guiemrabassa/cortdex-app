// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get helloWorld => '¡Hola Mundo!';

  @override
  String get welcomeMessage => '¡Bienvenido a la aplicación Cortdex!';

  @override
  String get chooseDatabaseType => 'Elegir Tipo de Base de Datos';

  @override
  String get local => 'Local';

  @override
  String local_(Object value) {
    return 'Local $value';
  }

  @override
  String get remote => 'Remoto';

  @override
  String remote_(Object value) {
    return 'Remoto $value';
  }

  @override
  String get connection => 'Conexión';

  @override
  String get chooseConnectionType => 'Elegir Tipo de Conexión';

  @override
  String get saveDbSettings => 'Guardar configuración de la base de datos';

  @override
  String get settings => 'Configuración';

  @override
  String settings_(Object value) {
    return 'Configuración de $value';
  }

  @override
  String get loading => 'Cargando';

  @override
  String get failed => 'Fallido';

  @override
  String get loadingFailed => 'Carga fallida';

  @override
  String get eraseAllSettings => 'Erase all settings';

  @override
  String get client => 'Cliente';

  @override
  String get server => 'Servidor';

  @override
  String get choose => 'Elegir';

  @override
  String get address => 'Dirección';

  @override
  String address_(Object value) {
    return 'Dirección de $value';
  }

  @override
  String get port => 'Puerto';

  @override
  String get model => 'Modelo';

  @override
  String get path => 'Ruta';

  @override
  String path_(Object value) {
    return 'Ruta de $value';
  }

  @override
  String get enter => 'Ingresar';

  @override
  String enter_(Object value) {
    return 'Ingresar $value';
  }

  @override
  String get database => 'Base de Datos';

  @override
  String selectionHint(String value) {
    return 'Elige el $value';
  }

  @override
  String get connect => 'Conectar';

  @override
  String connectTo(String value) {
    return 'Conectar a $value';
  }

  @override
  String get disconnect => 'Desconectar';

  @override
  String disconnectFrom(String value) {
    return 'Desconectar de $value';
  }

  @override
  String get start => 'Iniciar';

  @override
  String startThe(String value) {
    return 'Iniciar $value';
  }

  @override
  String get stop => 'Detener';

  @override
  String stop_(Object value) {
    return 'Detener $value';
  }

  @override
  String create_(String value) {
    return 'Crear $value';
  }

  @override
  String inputHint(String value) {
    return 'Ingresa el $value';
  }

  @override
  String get addNew => 'Añadir nuevo';

  @override
  String get add => 'Añadir';

  @override
  String get create => 'Crear';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get use => 'Usar';

  @override
  String error(String value) {
    return 'Error$value';
  }

  @override
  String notFound(String value) {
    return 'No se encontró $value';
  }

  @override
  String get share => 'Compartir';

  @override
  String get menu => 'Menú';

  @override
  String get noteEditorHint => 'Comienza a escribir tus notas...';

  @override
  String get attribute => 'Atributo';

  @override
  String get attributes => 'Attributes';

  @override
  String get note => 'nota';

  @override
  String get notes => 'notes';

  @override
  String get pin => 'Pin';

  @override
  String get unpin => 'Unpin';
}
