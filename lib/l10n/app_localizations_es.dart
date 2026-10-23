// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get commonBeta => 'Beta';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonUnavailable => 'No disponible';

  @override
  String get commonError => 'Error';

  @override
  String get homeDatabaseErrorTitle =>
      'No se pudo abrir la base de datos de NAHPU.';

  @override
  String get homeDatabaseErrorBody =>
      'Sus datos no se eliminaron. Vuelva a intentar la migración de la base de datos o reinicie NAHPU.';

  @override
  String get homeExistingProjects => 'Proyectos existentes';

  @override
  String get homeNoProjectsTitle => 'No se encontraron proyectos.';

  @override
  String get homeNoProjectsBody => 'Cree o importe un proyecto para comenzar.';

  @override
  String get homeSetupHint =>
      '¿Es nuevo en NAHPU? Ejecute Configurar NAHPU para elegir el formato de catálogo, los identificadores, los vocabularios y los ajustes de exportación.';

  @override
  String get homeSetupNahpu => 'Configurar NAHPU';

  @override
  String get homeStatistics => 'Estadísticas';

  @override
  String get homeSearchRecords => 'Buscar registros';

  @override
  String get homeSearchReset => 'Restablecer';

  @override
  String get homeSearchShowResults => 'Mostrar resultados';

  @override
  String get homeSearchHint =>
      'Número de campo, taxón, sitio o cualquier valor';

  @override
  String get homeSearchRecordType => 'Tipo de registro';

  @override
  String get homeSearchIn => 'Buscar en';

  @override
  String get homeSearchAllFields => 'Todos los campos';

  @override
  String get homeSearchProjects => 'Proyectos';

  @override
  String get homeSearchAllProjects => 'Todos los proyectos';

  @override
  String get homeSearchTaxa => 'Taxones';

  @override
  String get homeSearchQuickFilters => 'Filtros rápidos';

  @override
  String homeProjectAccessed(String date) {
    return 'Último acceso: $date';
  }

  @override
  String homeProjectCreated(String date) {
    return 'Creado: $date';
  }

  @override
  String get homeProjectActions => 'Acciones del proyecto';

  @override
  String get homeProjectEditInfo => 'Editar información';

  @override
  String get homeProjectShowQr => 'Mostrar QR';

  @override
  String get homeProjectExportInfo => 'Exportar información';

  @override
  String get homeProjectDetails => 'Detalles';

  @override
  String get homeProjectInformation => 'Información del proyecto';

  @override
  String get homeProjectQrCode => 'Código QR del proyecto';

  @override
  String get homeProjectQrDescription =>
      'Escanee este código al crear un proyecto nuevo para transferir la información del proyecto.';

  @override
  String aboutTitle(String appName) {
    return 'Acerca de $appName';
  }

  @override
  String get aboutTagline =>
      'Repensando los inventarios de biodiversidad en la era digital';

  @override
  String get aboutLicenses => 'Licencias';

  @override
  String get aboutAppVersion => 'Versión de la aplicación';

  @override
  String aboutVersionBuild(String version, String build) {
    return 'v$version (compilación $build)';
  }

  @override
  String get aboutCodename => 'Nombre en clave';

  @override
  String get aboutCodenameNote =>
      'De la primera prueba de campo real de NAHPU en el monte Gede, Java Occidental, Indonesia.';

  @override
  String get aboutDatabaseSchema => 'Esquema de la base de datos';

  @override
  String aboutSchemaSupported(String version) {
    return 'La aplicación admite la v$version';
  }

  @override
  String aboutDescription(String appName) {
    return '$appName es una aplicación de catálogo digital multiplataforma diseñada para la recopilación y gestión de datos de especímenes de historia natural, que ofrece información en el momento de la recolección.';
  }

  @override
  String get drawerCreateProject => 'Crear proyecto';

  @override
  String get drawerImportProject => 'Importar proyecto';

  @override
  String get drawerDatabaseStatistics => 'Estadísticas de la base de datos';

  @override
  String get drawerBackupDatabase => 'Respaldar la base de datos';

  @override
  String get drawerSettings => 'Configuración';

  @override
  String get drawerExportUserConfigs => 'Exportar configuraciones de usuario';

  @override
  String get drawerImportUserConfigs => 'Importar configuraciones de usuario';

  @override
  String get drawerAbout => 'Acerca de';

  @override
  String get drawerWebsite => 'Sitio web de NAHPU';

  @override
  String get drawerCookbook => 'Recetario';

  @override
  String get settingsApplications => 'Aplicación';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeLabel => 'Elija la apariencia clara u oscura';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsTools => 'Herramientas';

  @override
  String get settingsToolsLabel =>
      'Elija las herramientas que se muestran en el panel del proyecto';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Predeterminado del sistema';

  @override
  String settingsLanguageSystemLabel(String language) {
    return 'Sigue el idioma del dispositivo ($language)';
  }

  @override
  String get settingsLanguageBetaNote =>
      'El soporte de idiomas está en beta. Algunas pantallas siguen en inglés y las traducciones pueden ser borradores automáticos.';

  @override
  String get settingsRegionalFormat => 'Formato regional';

  @override
  String get settingsRegionalFormatMatchLanguage => 'Igual que el idioma';

  @override
  String get settingsRegionalFormatNote =>
      'Solo cambia cómo se muestran las fechas y los números. Los registros guardados y las exportaciones mantienen los formatos estándar.';

  @override
  String settingsRegionalFormatPreview(String date, String number) {
    return 'Ejemplo: $date · $number';
  }

  @override
  String get docsContents => 'Contenido';

  @override
  String docsCollapse(String title) {
    return 'Contraer $title';
  }

  @override
  String docsExpand(String title) {
    return 'Expandir $title';
  }

  @override
  String get docsLoadError => 'No se pudo cargar esta documentación.';

  @override
  String get docsOnlineLinks =>
      'Estos enlaces abren la documentación de NAHPU y requieren conexión a internet.';

  @override
  String get docsAsideNote => 'Nota';

  @override
  String get docsAsideCaution => 'Precaución';

  @override
  String get docsAsideTip => 'Consejo';

  @override
  String get docsAiTranslation => 'Traducción asistida por IA.';

  @override
  String get docsAiCheck => 'Verifique la exactitud';

  @override
  String docsReviewedBy(String reviewers) {
    return 'Verificada y revisada por $reviewers.';
  }

  @override
  String docsReviewerPair(String first, String second) {
    return '$first y $second';
  }

  @override
  String docsReviewerList(String leading, String last) {
    return '$leading y $last';
  }
}
