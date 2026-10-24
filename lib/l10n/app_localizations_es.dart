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
  String get commonCancel => 'Cancelar';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonPreview => 'Vista previa';

  @override
  String get commonSortRecords => 'Ordenar registros';

  @override
  String get commonDeleteRecord => 'Eliminar registro';

  @override
  String get commonDeleteAllRecords => 'Eliminar todos los registros';

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

  @override
  String get narrativeTitle => 'Narrativa';

  @override
  String get narrativeRecordTitle => 'Registro de narrativa';

  @override
  String get narrativeSearchHint => 'Buscar narrativa';

  @override
  String get narrativeEmpty => 'No se encontró ninguna narrativa';

  @override
  String get narrativeCreate => 'Crear narrativa';

  @override
  String get narrativeActions => 'Acciones de narrativa';

  @override
  String get narrativeDeleteTitle => '¿Eliminar narrativa?';

  @override
  String get narrativeDeletePrompt => 'Eliminará esta narrativa';

  @override
  String get narrativeDeleteAllTitle => '¿Eliminar todas las narrativas?';

  @override
  String get narrativeDeleteAllPrompt =>
      'Eliminará todas las narrativas de este proyecto';

  @override
  String narrativeDeleteError(String error) {
    return 'Error al eliminar la narrativa: $error';
  }

  @override
  String get narrativeDeleted => 'Narrativa eliminada';

  @override
  String get narrativeTextLabel => 'Narrativa';

  @override
  String get narrativeTextHint => 'Escriba la narrativa (admite Markdown)';

  @override
  String get narrativeTextEmpty =>
      'Sin narrativa. Use el botón Editar de arriba para empezar a escribir.';

  @override
  String get narrativeDate => 'Fecha';

  @override
  String get narrativeDateHint => 'Ingrese la fecha';

  @override
  String get narrativeTime => 'Hora';

  @override
  String get narrativeTimeHint => 'Ingrese la hora';

  @override
  String get narrativeWriter => 'Autor';

  @override
  String get narrativeWriterHint => 'Elija el nombre de una persona';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonDone => 'Listo';

  @override
  String get commonExport => 'Exportar';

  @override
  String get commonRemove => 'Quitar';

  @override
  String get commonReset => 'Restablecer';

  @override
  String get settingsNavCatalogs => 'Catálogos';

  @override
  String get settingsNavCatalogFormat => 'Formato';

  @override
  String get settingsNavCatalogFormatLabel => 'Elija el formato del catálogo';

  @override
  String settingsNavCatalogFormatLoadError(String error) {
    return 'No se pudo cargar el formato del catálogo: $error';
  }

  @override
  String get settingsNavSites => 'Sitios';

  @override
  String get settingsNavSitesLabel =>
      'Administre tipos de sitio, tipos de hábitat y datums de coordenadas';

  @override
  String get settingsNavEvents => 'Eventos';

  @override
  String get settingsNavEventsLabel =>
      'Administre actividades, métodos de colecta, funciones del personal y campos ambientales';

  @override
  String get settingsNavSpecimens => 'Especímenes';

  @override
  String get settingsNavSpecimensLabel =>
      'Administre la configuración de campos y de ID de tejidos, y los vocabularios controlados de los formularios de especímenes';

  @override
  String get settingsNavCustomFields => 'Campos personalizados';

  @override
  String get settingsNavCustomFieldsLabel =>
      'Administre campos para sitios, datos ambientales, especímenes, partes y parásitos';

  @override
  String get settingsNavDatabase => 'Base de datos';

  @override
  String get settingsNavTaxa => 'Taxones';

  @override
  String get settingsNavTaxaLabel => 'Administre los registros taxonómicos';

  @override
  String get settingsNavPersonnel => 'Personal';

  @override
  String get settingsNavPersonnelLabel =>
      'Administre los registros del personal';

  @override
  String get settingsNavBackupDatabaseLabel =>
      'Copia de seguridad completa de todos los registros y la configuración';

  @override
  String get settingsNavReplaceDatabase => 'Reemplazar base de datos';

  @override
  String get settingsNavReplaceDatabaseLabel =>
      'Reemplace la base de datos actual por otro archivo de base de datos';

  @override
  String get settingsNavExports => 'Exportaciones';

  @override
  String get settingsNavTabularData => 'Datos tabulares';

  @override
  String get settingsNavTabularDataLabel =>
      'Administre los ajustes predefinidos para exportar en formatos tabulares';

  @override
  String get settingsNavDocuments => 'Documentos';

  @override
  String get settingsNavDocumentsLabel =>
      'Administre los ajustes predefinidos para exportar documentos';

  @override
  String get settingsNavTemplateEditor => 'Editor de plantillas';

  @override
  String get settingsNavTemplateEditorLabel =>
      'Cree y edite plantillas de documentos';

  @override
  String get settingsCommonSetCaseFormat => 'Elegir mayúsculas y minúsculas';

  @override
  String get settingsFileTreeEmpty => 'La carpeta de la aplicación está vacía.';

  @override
  String settingsFileTreeUnlinkedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sin vincular',
      one: '1 sin vincular',
    );
    return '$_temp0';
  }

  @override
  String get settingsFileTreeRemoveEmptyFolder => 'Quitar esta carpeta vacía';

  @override
  String get settingsFileTreeSelectFolder => 'Seleccionar esta carpeta';

  @override
  String settingsFileTreeSelectRemovable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Seleccionar los $count archivos que se pueden quitar aquí',
      one: 'Seleccionar el archivo que se puede quitar aquí',
    );
    return '$_temp0';
  }

  @override
  String get settingsFileTreeSaveCopy => 'Guardar una copia';

  @override
  String get settingsFileTreeRemoveFile => 'Quitar este archivo';

  @override
  String get settingsFileTreeKept => 'Conservado';

  @override
  String get settingsSelectionApplicationFolder => 'Carpeta de la aplicación';

  @override
  String settingsSelectionTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count archivos seleccionados',
      one: '1 archivo seleccionado',
    );
    return '$_temp0';
  }

  @override
  String get settingsSelectionArchiveFormat => 'Formato del archivo comprimido';

  @override
  String get settingsSelectionNoFolder =>
      'Para exportar una selección se necesita una carpeta donde escribir, y este dispositivo no la ofrece. Aun así, puede eliminar los archivos seleccionados después de revisarlos.';

  @override
  String get settingsSelectionExportNote =>
      'Al exportar, estos archivos se guardan en un único archivo comprimido y luego se ofrece quitar los originales. Al eliminar, se quitan de inmediato y no se puede deshacer.';

  @override
  String get settingsSelectionDeleteNote =>
      'Al eliminar, los archivos seleccionados se quitan de inmediato y no se puede deshacer.';

  @override
  String get settingsSelectionDeletePermanently => 'Eliminar definitivamente';

  @override
  String get settingsMapLayers => 'Capas del mapa';

  @override
  String get settingsMapPmtilesType => 'Tipo de capa PMTiles';

  @override
  String settingsMapImportError(String error) {
    return 'No se pudo importar la capa del mapa: $error';
  }

  @override
  String get settingsMapBaseLayer => 'Capa base';

  @override
  String get settingsMapCustomLayers => 'Capas personalizadas';

  @override
  String settingsMapLoadError(String error) {
    return 'No se pudieron cargar las capas personalizadas del mapa: $error';
  }

  @override
  String get settingsMapNoCustomLayers =>
      'No se ha importado ninguna capa personalizada.';

  @override
  String get settingsMapImportCustomLayer => 'Importar capa personalizada';

  @override
  String settingsMapKindUnavailableOnDesktop(String kind) {
    return '$kind · no disponible en escritorio';
  }

  @override
  String get settingsMapConfigureLayer => 'Configurar capa';

  @override
  String get settingsMapShowLayer => 'Mostrar capa';

  @override
  String get settingsMapLayerUnavailableOnDesktop =>
      'Esta capa no está disponible en escritorio';

  @override
  String get settingsMapLayerTypeUnavailableOnDesktop =>
      'Este tipo de capa no está disponible en escritorio.';

  @override
  String get settingsMapOpacity => 'Opacidad';

  @override
  String get settingsMapUseTerrain => 'Usar para el terreno 3D';

  @override
  String get settingsMapHillshadeNote =>
      'El sombreado del relieve sigue visible cuando el terreno está desactivado.';

  @override
  String get settingsMapLayerOrder => 'Orden de las capas';

  @override
  String get settingsMapMoveEarlier => 'Mover antes';

  @override
  String get settingsMapMoveLater => 'Mover después';

  @override
  String get settingsMapDeleteLayer => 'Eliminar capa';

  @override
  String get settingsMapDeleteLayerTitle => '¿Eliminar la capa del mapa?';

  @override
  String settingsMapDeleteLayerBody(String name) {
    return '¿Eliminar $name y sus datos de mapa almacenados?';
  }

  @override
  String get settingsMapSupportedFormatsDesktop =>
      'En escritorio admite GeoJSON, Shapefiles WGS84 comprimidos en ZIP y PMTiles ráster.';

  @override
  String get settingsMapSupportedFormats =>
      'Admite GeoJSON, Shapefiles WGS84 comprimidos en ZIP y PMTiles.';

  @override
  String get settingsDataUsage => 'Uso de datos';

  @override
  String get settingsDataUsageLabel =>
      'Explore y limpie la carpeta de la aplicación';

  @override
  String get settingsDataUsageRescan => 'Volver a analizar';

  @override
  String get settingsDataUsageFiles => 'Archivos';

  @override
  String get settingsDataUsageFilesLabel => 'Incluye imágenes y otros archivos';

  @override
  String get settingsDataUsageMediaFiles => 'Archivos multimedia';

  @override
  String get settingsDataUsageMediaFilesLabel => 'Imágenes, audio, video';

  @override
  String get settingsDataUsageTotal => 'Uso total';

  @override
  String get settingsDataUsageReclaimable => 'Recuperable';

  @override
  String get settingsDataUsageReclaimableLabel =>
      'Archivos sin vincular que se pueden quitar';

  @override
  String get settingsDataUsageNone => 'Ninguno';

  @override
  String get settingsDataUsageRemoveOriginalsTitle => '¿Quitar los originales?';

  @override
  String settingsDataUsageArchiveWritten(
    int count,
    String archive,
    String size,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se guardaron $count archivos en $archive ($size).',
      one: 'Se guardó 1 archivo en $archive ($size).',
    );
    return '$_temp0';
  }

  @override
  String get settingsDataUsageRemoveOriginalsBody =>
      'Quitarlos de NAHPU libera el espacio. El archivo comprimido conserva su copia, y esto no se puede deshacer.';

  @override
  String settingsDataUsageExportedTo(String path) {
    return 'Exportado a $path';
  }

  @override
  String settingsDataUsageExportFailed(String error) {
    return 'La exportación falló: $error';
  }

  @override
  String settingsDataUsageSaveCopyFailed(String name, String error) {
    return 'No se pudo guardar $name: $error';
  }

  @override
  String get settingsDataUsageRemoveFileTitle => '¿Quitar este archivo?';

  @override
  String settingsDataUsageRemoveFileBody(String name, String size) {
    return '$name ($size) no está vinculado a ningún registro. Esto no se puede deshacer.';
  }

  @override
  String get settingsDataUsageRemoveFolderTitle =>
      '¿Quitar esta carpeta vacía?';

  @override
  String settingsDataUsageRemoveFolderBody(String name) {
    return '$name no contiene archivos. Quitarla no afecta a ningún registro.';
  }

  @override
  String settingsDataUsageRemovedFolder(String name) {
    return 'Se quitó $name.';
  }

  @override
  String settingsDataUsageRemoveFolderFailed(String name) {
    return 'No se pudo quitar $name.';
  }

  @override
  String settingsDataUsageDeleteSelectionTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Eliminar $count archivos seleccionados?',
      one: '¿Eliminar 1 archivo seleccionado?',
    );
    return '$_temp0';
  }

  @override
  String get settingsDataUsageDeleteSelectionBody =>
      'Estos archivos no están vinculados a ningún registro. Esto no se puede deshacer.';

  @override
  String get settingsDataUsageCollapseAll => 'Contraer todo';

  @override
  String get settingsDataUsageExpandAll => 'Expandir todo';

  @override
  String get settingsDataUsageSelectAll => 'Seleccionar todo';

  @override
  String get settingsDataUsageSelect => 'Seleccionar';

  @override
  String get settingsDataUsageClear => 'Borrar selección';

  @override
  String settingsDataUsageReview(int count) {
    return 'Revisar $count';
  }

  @override
  String get settingsDataUsageScanError =>
      'No se pudo leer la carpeta de la aplicación';

  @override
  String get settingsDataUsagePruneTitle => 'Quitar archivos sin vincular';

  @override
  String get settingsDataUsagePruneDescription =>
      'Archivos que ya no usa ningún registro, como restos de multimedia eliminada o de importaciones canceladas. No se ven afectados los archivos vinculados, las bases de datos y sus copias de seguridad, las fuentes personalizadas, las capas del mapa ni los archivos fuera de las carpetas que administra NAHPU.';

  @override
  String get settingsDataUsageNothingToReclaim =>
      'No hay espacio que recuperar.';

  @override
  String settingsDataUsagePruneButton(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quitar $count archivos sin vincular ($size)',
      one: 'Quitar 1 archivo sin vincular ($size)',
    );
    return '$_temp0';
  }

  @override
  String settingsDataUsagePruneConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Quitar $count archivos sin vincular?',
      one: '¿Quitar 1 archivo sin vincular?',
    );
    return '$_temp0';
  }

  @override
  String settingsDataUsagePruneConfirmBody(String size) {
    return 'Esto libera $size. No se ven afectados los archivos aún vinculados a sus registros, su base de datos y sus copias de seguridad, ni sus fuentes personalizadas y capas del mapa.\n\nEsto no se puede deshacer.';
  }

  @override
  String settingsDataUsageRemovedSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se quitaron $count archivos ($size).',
      one: 'Se quitó 1 archivo ($size).',
    );
    return '$_temp0';
  }

  @override
  String settingsDataUsageKeptChanged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Se conservaron $count archivos porque cambiaron durante el análisis.',
      one: 'Se conservó 1 archivo porque cambió durante el análisis.',
    );
    return '$_temp0';
  }

  @override
  String get commonOk => 'Aceptar';

  @override
  String get recordsCatalogFormat => 'Formato de catálogo';

  @override
  String get recordsCatalogMeasurementRecords => 'Registros de medidas';

  @override
  String get recordsCatalogAlwaysShowBatFields =>
      'Mostrar siempre los campos de murciélagos';

  @override
  String get recordsCatalogBatFieldsNote =>
      'Si se activa, los campos específicos de murciélagos se muestran siempre en los campos de medidas de mamíferos. También puede mostrar u ocultar los campos específicos de murciélagos para cada registro de espécimen en la pantalla del registro de espécimen.';

  @override
  String get recordsVocabularyCaseFormat => 'Formato de mayúsculas';

  @override
  String recordsVocabularyCaseFormatLoadError(String error) {
    return 'No se pudo cargar el formato de mayúsculas: $error';
  }

  @override
  String get recordsVocabularyCaseAny => 'Sin formato fijo';

  @override
  String get recordsVocabularyCaseSentence => 'Tipo oración';

  @override
  String get recordsVocabularyCaseTitle => 'Tipo título';

  @override
  String get recordsVocabularyCaseUpper => 'Mayúsculas';

  @override
  String get recordsVocabularyCaseLower => 'Minúsculas';

  @override
  String get recordsSiteSettings => 'Configuración de sitios';

  @override
  String get recordsSiteTypes => 'Tipos de sitio';

  @override
  String get recordsSiteHabitatTypes => 'Tipos de hábitat';

  @override
  String get recordsSiteDatums => 'Datums';

  @override
  String get recordsSiteGeographyFields => 'Campos geográficos';

  @override
  String recordsSiteGeographyFieldsLoadError(String error) {
    return 'No se pudieron cargar los campos geográficos: $error';
  }

  @override
  String get recordsSiteMaps => 'Mapas';

  @override
  String get recordsSiteMapLayers => 'Capas del mapa';

  @override
  String get recordsSiteMapLayersLabel =>
      'Elija una capa base o importe y administre capas personalizadas';

  @override
  String get recordsCollEventSettings =>
      'Configuración de eventos de recolección';

  @override
  String get recordsCollEventPrimaryActivities => 'Actividades principales';

  @override
  String get recordsCollEventCollectionMethods => 'Métodos de recolección';

  @override
  String get recordsCollEventPersonnelRoles => 'Funciones del personal';

  @override
  String get recordsCollEventEnvironmentalDataFields =>
      'Campos de datos ambientales';

  @override
  String recordsCollEventEnvironmentalDataFieldsLoadError(String error) {
    return 'No se pudieron cargar los campos de datos ambientales: $error';
  }

  @override
  String get recordsCollEventTemperature => 'Temperatura';

  @override
  String get recordsCollEventHumidity => 'Humedad';

  @override
  String get recordsCollEventEnvironmentalMeasurements =>
      'Mediciones ambientales';

  @override
  String get recordsCollEventAquaticData => 'Datos acuáticos';

  @override
  String get recordsCollEventAstronomy => 'Astronomía';

  @override
  String get recordsSpecimenSettings => 'Configuración de especímenes';

  @override
  String get recordsSpecimenCaptureRecords => 'Registros de captura';

  @override
  String get recordsSpecimenAlwaysShowCollector =>
      'Mostrar siempre el campo de colector';

  @override
  String get recordsSpecimenIdentificationMethods =>
      'Métodos de identificación';

  @override
  String get recordsSpecimenLifeStages => 'Etapas de vida';

  @override
  String get recordsSpecimenTypes => 'Tipos de espécimen';

  @override
  String get recordsSpecimenTreatments => 'Tratamientos';

  @override
  String get recordsSpecimenConditions => 'Condiciones';

  @override
  String get recordsSpecimenSex => 'Sexo';

  @override
  String recordsSpecimenSexNote(String male, String female, String unknown) {
    return '$male, $female y $unknown están siempre disponibles. Agregue términos opcionales con +. Un signo de interrogación registra la incertidumbre del examinador.';
  }

  @override
  String recordsSpecimenSexLoadError(String error) {
    return 'No se pudieron cargar las opciones de sexo: $error';
  }

  @override
  String get recordsSpecimenSexSelected => 'Seleccionados';

  @override
  String get recordsSpecimenSexAdditional => 'Opciones adicionales';

  @override
  String get recordsSpecimenSexRemoveBlockedTitle =>
      'No se puede quitar el sexo';

  @override
  String recordsSpecimenSexRemoveBlockedBody(String sex) {
    return '$sex se usa en uno o más registros de espécimen. Cambie esos registros antes de quitar esta opción.';
  }

  @override
  String get recordsSpecimenParasites => 'Parásitos';

  @override
  String get recordsSpecimenParasiteIdentification => 'Identificación';

  @override
  String get recordsSpecimenParasiteCategories => 'Categorías';

  @override
  String get recordsSpecimenParasiteDetectionMethods => 'Métodos de detección';

  @override
  String get recordsSpecimenParasitePreparationMethods =>
      'Métodos de preparación';

  @override
  String get recordsSpecimenParasiteAnatomicalLocations =>
      'Ubicaciones anatómicas';

  @override
  String get recordsSpecimenParasiteStorage => 'Almacenamiento';

  @override
  String get recordsSpecimenParasiteIdPrefix => 'Prefijo del ID de parásito';

  @override
  String recordsSpecimenParasiteIdPrefixHint(String example) {
    return 'Ingrese un prefijo, p. ej. $example';
  }

  @override
  String get recordsSpecimenParasiteIdNumber => 'Número del ID de parásito';

  @override
  String get recordsSpecimenNextNumberHint => 'Ingrese el siguiente número';

  @override
  String get recordsSpecimenFieldId => 'ID de campo';

  @override
  String recordsSpecimenFieldIdModeLoadError(String error) {
    return 'No se pudo cargar el modo de ID de campo: $error';
  }

  @override
  String get recordsSpecimenPersonnelId => 'ID del personal';

  @override
  String get recordsSpecimenPersonnelIdDescription =>
      'El ID consiste en las iniciales de una persona y un número correlativo. Lo configurará al crear personal con la función de catalogador.';

  @override
  String get recordsSpecimenProjectId => 'ID del proyecto';

  @override
  String get recordsSpecimenProjectIdDescription =>
      'El proyecto mantiene un único número correlativo con un prefijo y un sufijo compartidos.';

  @override
  String get recordsSpecimenPersonnelFieldIdNoteTitle =>
      'Los ID de campo del personal requieren un catalogador';

  @override
  String get recordsSpecimenPersonnelFieldIdNoteBody =>
      'Agregue una persona con la función de catalogador en el proyecto y asigne un número de campo actual a esa función.';

  @override
  String get recordsSpecimenAddPersonnel => 'Agregar personal';

  @override
  String get recordsSpecimenPrefix => 'Prefijo';

  @override
  String get recordsSpecimenSuffix => 'Sufijo';

  @override
  String recordsSpecimenExampleHint(String example) {
    return 'p. ej. $example';
  }

  @override
  String get recordsSpecimenCurrentCatalogNumber => 'Número de catálogo actual';

  @override
  String recordsSpecimenFieldIdPreview(String id) {
    return 'Vista previa: $id';
  }

  @override
  String get recordsSpecimenAutoIncrement =>
      'Incrementar automáticamente el número de catálogo';

  @override
  String get recordsSpecimenSaveFieldIdSettings =>
      'Guardar la configuración de ID de campo';

  @override
  String get recordsSpecimenFieldIdSettingsSaved =>
      'Configuración de ID de campo guardada.';

  @override
  String get recordsSpecimenNoProjectFieldIdTitle =>
      'Abra un proyecto para configurar los ID de campo del proyecto';

  @override
  String get recordsSpecimenNoProjectFieldIdBody =>
      'El prefijo, el número actual y el sufijo se guardan por proyecto.';

  @override
  String get recordsSpecimenFieldIdChangeTitle =>
      '¿Cambiar el formato de ID de campo del proyecto?';

  @override
  String get recordsSpecimenFieldIdChangeBody =>
      'Cambiar el prefijo o el sufijo del ID de campo del proyecto modifica los ID existentes del proyecto. Es posible que estos identificadores ya se hayan usado en exportaciones o escrito en etiquetas de especímenes. Verifique los nuevos valores antes de cambiarlos.';

  @override
  String get recordsSpecimenIUnderstand => 'Entiendo';

  @override
  String get recordsSpecimenTissueId => 'ID de tejido';

  @override
  String get recordsSpecimenNextTissueId => 'Siguiente ID de tejido';

  @override
  String get recordsSpecimenIndividualTagId => 'ID de etiqueta individual';

  @override
  String get recordsSpecimenNextTag => 'Siguiente etiqueta';

  @override
  String get recordsCustomFieldTitle => 'Campos personalizados';

  @override
  String get recordsCustomFieldFieldsTab => 'Campos';

  @override
  String get recordsCustomFieldEditField => 'Editar campo';

  @override
  String recordsCustomFieldLoadError(String error) {
    return 'No se pudieron cargar los campos: $error';
  }

  @override
  String recordsCustomFieldSaved(String name) {
    return 'Se guardó «$name».';
  }

  @override
  String recordsCustomFieldImportQrError(String error) {
    return 'No se pudo importar el código QR: $error';
  }

  @override
  String recordsCustomFieldImportError(String error) {
    return 'No se pudieron importar los campos personalizados: $error';
  }

  @override
  String get recordsCustomFieldImportEmpty =>
      'Esta configuración de usuario no contiene plantillas de campos personalizados.';

  @override
  String recordsCustomFieldImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se importaron $count definiciones de campos personalizados.',
      one: 'Se importó 1 definición de campo personalizado.',
    );
    return '$_temp0';
  }

  @override
  String recordsCustomFieldExportError(String error) {
    return 'No se pudieron exportar los campos personalizados: $error';
  }

  @override
  String recordsCustomFieldExportedTo(String path) {
    return 'Campos personalizados exportados a $path';
  }

  @override
  String get recordsCustomFieldExported => 'Campos personalizados exportados';

  @override
  String get recordsCustomFieldQrTooLargeTitle =>
      'El código QR es demasiado grande';

  @override
  String get recordsCustomFieldQrTooLargeBody =>
      'Los campos personalizados seleccionados contienen demasiados datos para un solo código QR. Expórtelos como archivo.';

  @override
  String get recordsCustomFieldExportFile => 'Exportar archivo';

  @override
  String get recordsCustomFieldDiscardLegacyTitle =>
      '¿Descartar los valores heredados?';

  @override
  String recordsCustomFieldDiscardLegacyBody(String name) {
    return 'Los valores heredados de «$name» no se pueden recuperar después de descartarlos.';
  }

  @override
  String get recordsCustomFieldDiscardValues => 'Descartar valores';

  @override
  String get recordsCustomFieldDeleteTitle =>
      '¿Eliminar el campo personalizado?';

  @override
  String recordsCustomFieldDeleteBody(String name) {
    return '¿Eliminar «$name» de forma permanente? Esta acción no se puede deshacer.';
  }

  @override
  String get recordsCustomFieldSelectFields => 'Seleccionar campos';

  @override
  String get recordsCustomFieldShowArchived => 'Mostrar campos archivados';

  @override
  String recordsCustomFieldAllArchived(String location) {
    return 'Todos los campos personalizados de $location están archivados.';
  }

  @override
  String recordsCustomFieldEmpty(String location) {
    return 'Aún no hay campos personalizados en $location.';
  }

  @override
  String get recordsCustomFieldAdd => 'Agregar campo personalizado';

  @override
  String get recordsCustomFieldArchived => 'Archivado';

  @override
  String get recordsCustomFieldActive => 'Activo';

  @override
  String get recordsCustomFieldDefinitionActions => 'Acciones de la definición';

  @override
  String get recordsCustomFieldMoveUp => 'Subir';

  @override
  String get recordsCustomFieldMoveDown => 'Bajar';

  @override
  String get recordsCustomFieldRestore => 'Restaurar';

  @override
  String get recordsCustomFieldArchive => 'Archivar';

  @override
  String get recordsCustomFieldDiscardLegacy => 'Descartar valores heredados';

  @override
  String get recordsCustomFieldDeleteInUse => 'Eliminar (valores en uso)';

  @override
  String get recordsCustomFieldSelectPrompt =>
      'Seleccione un campo personalizado para editarlo o agregue uno nuevo.';

  @override
  String get recordsCustomFieldNew => 'Nuevo campo personalizado';

  @override
  String recordsCustomFieldEditName(String name) {
    return 'Editar $name';
  }

  @override
  String recordsCustomFieldShownIn(String location) {
    return 'Se muestra en $location';
  }

  @override
  String get recordsCustomFieldDetails => 'Detalles';

  @override
  String get recordsCustomFieldStatus => 'Estado';

  @override
  String get recordsCustomFieldScope => 'Alcance';

  @override
  String get recordsCustomFieldStoredValues => 'Valores almacenados';

  @override
  String get recordsCustomFieldLegacyValues => 'Valores heredados';

  @override
  String get recordsCustomFieldDeletion => 'Eliminación';

  @override
  String get recordsCustomFieldDeletionAvailable => 'Disponible';

  @override
  String get recordsCustomFieldDeletionUnavailable =>
      'No disponible hasta que se borren todos los valores almacenados';

  @override
  String recordsCustomFieldUsageLoadError(String error) {
    return 'No se pudo cargar el uso: $error';
  }

  @override
  String get recordsCustomFieldProjectUuid => 'UUID del proyecto';

  @override
  String get recordsCustomFieldDefinitionUuid => 'UUID de la definición';

  @override
  String get recordsCustomFieldSourceTemplateUuid =>
      'UUID de la plantilla de origen';

  @override
  String get recordsCustomFieldNotFromTemplate =>
      'No se importó desde una plantilla';

  @override
  String get recordsCustomFieldTypeText => 'Texto';

  @override
  String get recordsCustomFieldTypeNumber => 'Número';

  @override
  String get recordsCustomFieldTypeBoolean => 'Sí / No';

  @override
  String get recordsCustomFieldTypeDropdown => 'Lista desplegable';

  @override
  String get recordsCustomFieldScopeGlobal => 'Global';

  @override
  String get recordsCustomFieldScopeProject => 'Proyecto actual';

  @override
  String get recordsCustomFieldAllCatalogs => 'Todos los formatos de catálogo';

  @override
  String recordsCustomFieldCatalogOnly(String catalog) {
    return 'Solo $catalog';
  }

  @override
  String get commonSelectAll => 'Seleccionar todo';

  @override
  String get commonClear => 'Borrar';

  @override
  String get commonImport => 'Importar';

  @override
  String get databaseSelectFileFailed => 'No se pudo seleccionar el archivo.';

  @override
  String get databaseReplaceConfirmTitle => '¿Reemplazar la base de datos?';

  @override
  String get databaseReplace => 'Reemplazar';

  @override
  String get databaseRestoreCancelled =>
      'Restauración cancelada. La base de datos no se reemplazó.';

  @override
  String get databaseRestoreCannotStop =>
      'La restauración está reemplazando sus datos y no se puede detener ahora.';

  @override
  String get databaseCancelRestoreTitle => '¿Cancelar la restauración?';

  @override
  String get databaseCancelRestoreBody =>
      'El archivo comprimido aún se está leyendo. Si sale ahora, se cancela la restauración y sus datos actuales no se modifican.';

  @override
  String get databaseKeepRestoring => 'Continuar restaurando';

  @override
  String get databaseCancelRestore => 'Cancelar restauración';

  @override
  String databaseReplaceFailed(String error) {
    return 'No se pudo reemplazar la base de datos: $error';
  }

  @override
  String get databaseReplaceDatabase => 'Reemplazar la base de datos';

  @override
  String get databaseReplaceWith => 'Reemplazar con';

  @override
  String get databaseSourceDescription =>
      'Un archivo de respaldo de NAHPU o un archivo de base de datos SQLite.';

  @override
  String get databaseNoFileSelected => 'Ningún archivo seleccionado';

  @override
  String get databaseBrowse => 'Examinar';

  @override
  String get databaseChangeFile => 'Cambiar';

  @override
  String get databaseClearFile => 'Quitar archivo';

  @override
  String get databaseSupportedFormats => 'ZIP, TAR.GZ o SQLITE3';

  @override
  String get databaseCannotRestore => 'No se puede restaurar';

  @override
  String get databaseSqliteDatabase => 'Base de datos SQLite';

  @override
  String get databaseBackupArchive => 'Archivo de respaldo de NAHPU';

  @override
  String databaseBackupArchiveRestores(String database) {
    return 'Archivo de respaldo de NAHPU · restaura $database';
  }

  @override
  String get databaseBeforeReplacing => 'Antes de reemplazar';

  @override
  String get databaseReplaceWarning =>
      'Esta acción reemplazará todos los registros de NAHPU. Los archivos multimedia o de configuración que coincidan con el archivo de respaldo se sobrescribirán. Esta acción no se puede deshacer.';

  @override
  String get databaseBackupFirst => 'Respaldar primero los datos actuales';

  @override
  String get databaseBackupFirstSubtitle =>
      'Guarda un archivo completo, incluidos los archivos multimedia, en la carpeta de respaldos de NAHPU';

  @override
  String get databaseNoSafetyBackup =>
      'Sin respaldo de seguridad. Sus registros y archivos multimedia actuales no se guardan antes de reemplazarlos.';

  @override
  String get databaseComparisonTitle => 'Actual y reemplazo';

  @override
  String get databaseChooseFileToCompare => 'Elija un archivo para comparar.';

  @override
  String get databaseArchiveIncludesConfigs =>
      'Este archivo también incluye configuraciones de usuario, que la restauración importa.';

  @override
  String get databaseSchemaVersion => 'Versión del esquema';

  @override
  String get databaseAssociatedFiles => 'Archivos asociados';

  @override
  String get databaseSize => 'Tamaño';

  @override
  String databaseSchemaUpgraded(int version, int current) {
    return 'El esquema v$version del reemplazo se actualiza a la v$current después de la restauración.';
  }

  @override
  String databaseSchemaNewer(int version) {
    return 'El esquema v$version del reemplazo es más reciente que esta aplicación.';
  }

  @override
  String get databaseTableProjects => 'Proyectos';

  @override
  String get databaseTablePersonnel => 'Personal';

  @override
  String get databaseTableTaxa => 'Taxones';

  @override
  String get databaseTableSites => 'Sitios';

  @override
  String get databaseTableCollectionEvents => 'Eventos de colecta';

  @override
  String get databaseTableSpecimens => 'Especímenes';

  @override
  String get databaseTableNarratives => 'Narrativas';

  @override
  String get databaseTableMediaRecords => 'Registros multimedia';

  @override
  String get databaseIssueNotNahpu =>
      'Este archivo no es una base de datos de NAHPU. Elija un archivo de respaldo o de base de datos de NAHPU.';

  @override
  String get databaseIssueNewerSchema =>
      'Esta base de datos se creó con una versión más reciente de NAHPU. Actualice NAHPU y luego restáurela.';

  @override
  String get databaseIssueUnreadable =>
      'No se pudo leer esta base de datos. Es posible que el archivo esté dañado.';

  @override
  String get databaseColumnCurrent => 'Actual';

  @override
  String get databaseColumnReplacement => 'Reemplazo';

  @override
  String get databaseColumnChange => 'Cambio';

  @override
  String get databaseRestoring => 'Restaurando la base de datos';

  @override
  String get databaseRestoreHint =>
      'Restaurar un respaldo con muchas fotos puede tardar varios minutos. Mantenga NAHPU abierto hasta que termine.';

  @override
  String get databaseChooseDatabase => 'Elegir base de datos';

  @override
  String get databaseChooseDatabaseBody =>
      'Este archivo contiene varios archivos de base de datos en su raíz. Elija la base de datos que desea restaurar.';

  @override
  String get databaseConfirmWithBackup =>
      'Primero se guarda un respaldo completo de sus datos actuales. ¿Desea continuar?';

  @override
  String get databaseConfirmWithoutBackup =>
      'No se hará ningún respaldo, por lo que sus datos actuales no se podrán recuperar. ¿Desea continuar?';

  @override
  String get databaseReplaceSuccess => 'Listo 🎉';

  @override
  String get databaseReplaced => '¡La base de datos se reemplazó!';

  @override
  String get databaseBackupFilePath => 'Ruta del archivo de respaldo:';

  @override
  String get databaseBackToHome => 'Volver al inicio';

  @override
  String databaseIosBackupPath(
    String appDir,
    String backupDir,
    String fileName,
  ) {
    return 'App Archivos/En mi dispositivo/$appDir/$backupDir/$fileName';
  }

  @override
  String get transferCustomFieldsQrTitle =>
      'Código QR de campos personalizados';

  @override
  String transferCustomFieldsQrDescription(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Escanee este código desde otro dispositivo con NAHPU para importar $count definiciones de campos personalizados.',
      one:
          'Escanee este código desde otro dispositivo con NAHPU para importar 1 definición de campo personalizado.',
    );
    return '$_temp0';
  }

  @override
  String get transferExportCustomFields => 'Exportar campos personalizados';

  @override
  String get transferShowQr => 'Mostrar QR';

  @override
  String get transferExportFile => 'Exportar archivo';

  @override
  String get transferNoCustomFields =>
      'No hay campos personalizados disponibles para exportar.';

  @override
  String transferSelectedCount(int selected, int total) {
    return '$selected de $total seleccionados';
  }

  @override
  String get transferScopeGlobal => 'Global';

  @override
  String get transferScopeCurrentProject => 'Proyecto actual';

  @override
  String get transferArchived => 'Archivado';

  @override
  String get transferImportCustomFields => 'Importar campos personalizados';

  @override
  String transferReusableDefinitions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count definiciones reutilizables',
      one: '1 definición reutilizable',
    );
    return '$_temp0';
  }

  @override
  String get transferDestination => 'Destino';

  @override
  String get transferCustomFieldImportNote =>
      'Las definiciones se verifican antes de importarlas. Las que coinciden por ID de plantilla se actualizan de forma segura; los demás campos no cambian.';

  @override
  String get transferImportSelectedConfigs =>
      'Importar configuraciones seleccionadas';

  @override
  String get transferWillImport => 'Se importará';

  @override
  String get transferImportSelectedConfigsConfirm =>
      '¿Importar las configuraciones seleccionadas?';

  @override
  String get transferConfigsImported =>
      'Se importaron las configuraciones de usuario seleccionadas.';

  @override
  String get transferImportConfirmationBody =>
      'Los grupos seleccionados se reemplazarán. Los campos personalizados se emparejan por ID de plantilla y se combinan, por lo que se conservan las definiciones existentes. Los grupos no seleccionados no cambian.';

  @override
  String get transferCustomFieldDestination =>
      'Destino de los campos personalizados';

  @override
  String get transferSectionUserConfigs =>
      'Vocabularios controlados y configuración';

  @override
  String get transferSectionRecordExportPresets =>
      'Ajustes predefinidos de exportación tabular';

  @override
  String get transferSectionTemplatePresets => 'Plantillas de documentos';

  @override
  String get transferSectionDocumentLayouts =>
      'Ajustes predefinidos de diseño de documentos';

  @override
  String get transferSectionTemplateTablePreview =>
      'Columnas de vista previa de la tabla de plantillas';

  @override
  String get transferSectionCustomFields => 'Campos personalizados';

  @override
  String get transferConfigSections => 'Secciones de configuración';

  @override
  String get transferChooseFileToPreview =>
      'Elija un archivo de configuración de usuario para ver una vista previa de su contenido.';

  @override
  String get transferSelectAtLeastOneSection =>
      'Seleccione al menos una sección de configuración.';

  @override
  String transferEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entradas',
      one: '1 entrada',
    );
    return '$_temp0';
  }

  @override
  String get transferNoSavedEntries => 'No hay entradas guardadas';

  @override
  String get transferOtherSettings => 'Otros ajustes';

  @override
  String get transferNoItems => 'Sin elementos';

  @override
  String transferMappingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count asignaciones',
      one: '1 asignación',
    );
    return '$_temp0';
  }

  @override
  String get transferIncompatiblePreset => 'Ajuste predefinido incompatible';

  @override
  String transferBlockCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bloques',
      one: '1 bloque',
    );
    return '$_temp0';
  }

  @override
  String get setupReviewSetup => 'Revisar configuración';

  @override
  String get setupSkipSetup => 'Omitir configuración';

  @override
  String get setupStepWelcome => 'Bienvenida';

  @override
  String get setupCatalogFormat => 'Formato de catálogo';

  @override
  String get setupIdentifiers => 'Identificadores';

  @override
  String get setupStepSites => 'Sitios';

  @override
  String get setupStepEvents => 'Eventos';

  @override
  String get setupStepSpecimens => 'Especímenes';

  @override
  String get setupParasites => 'Parásitos';

  @override
  String get setupExportPresets => 'Ajustes de exportación';

  @override
  String get setupStepFinish => 'Finalizar';

  @override
  String get setupWelcomeTitle => 'Configure NAHPU';

  @override
  String get setupWelcomeMessage =>
      'NAHPU registra especímenes según sus propias convenciones. Aquí se configura el formato del número de catálogo y los vocabularios controlados para sitios, eventos y especímenes.';

  @override
  String get setupWelcomeCatalogFormat => 'El grupo taxonómico que cataloga.';

  @override
  String get setupWelcomeIdentifiers =>
      'Cómo se forman los números de campo y de tejido.';

  @override
  String get setupControlledVocabularies => 'Vocabularios controlados';

  @override
  String get setupWelcomeVocabularies =>
      'Los vocabularios para sitios, eventos y especímenes.';

  @override
  String get setupWelcomeExportPresets =>
      'Diseños de impresión y ajustes tabulares incluidos para las exportaciones.';

  @override
  String get setupWelcomeNotPermanent =>
      'Esto toma unos minutos y nada aquí es permanente. Puede cambiar cada respuesta más adelante en Configuración o al ejecutar este asistente de nuevo.';

  @override
  String get setupImportTitle => '¿Ya tiene la configuración de su equipo?';

  @override
  String get setupImportMessage =>
      'Un equipo solo necesita configurar esto una vez. Si su equipo ya configuró NAHPU, importe su archivo de configuraciones de usuario y podrá omitir el resto de este asistente. Al final puede exportar la suya para el resto del equipo.';

  @override
  String get setupCatalogFormatMessage =>
      'El formato determina qué campos de medidas aparecen en los registros de especímenes.';

  @override
  String get setupCatalogFormatNote =>
      'Puede cambiar el formato de catálogo en cualquier momento, y un mismo proyecto puede contener registros en más de un formato. Elija el formato que usará con más frecuencia.';

  @override
  String setupCatalogFormatLoadError(String error) {
    return 'No se pudo cargar el formato de catálogo: $error';
  }

  @override
  String get setupFieldIdsTitle => 'ID de campo de especímenes';

  @override
  String get setupFieldIdsMessage =>
      'Elija su estrategia de ID de campo. Completará la configuración de ID al crear un proyecto nuevo.';

  @override
  String get setupIdentifiersNote =>
      'Esta configuración de identificadores puede cambiarse para otro proyecto. Puede ajustarla en Configuración > Catálogos.';

  @override
  String get setupTissueIdsTitle => 'ID de tejidos';

  @override
  String get setupTissueIdsMessage =>
      'Algunas colecciones numeran los tejidos por separado del espécimen. Configúrelo aquí si su colección lo usa. Si no establece un ID de tejido, NAHPU usa automáticamente el ID de campo del espécimen.';

  @override
  String get setupUseSeparateTissueId => 'Usar un ID de tejido independiente';

  @override
  String get setupNextTissueId => 'Siguiente ID de tejido';

  @override
  String get setupSitesTitle => 'Vocabularios de sitios';

  @override
  String get setupSitesMessage =>
      'Los vocabularios controlados para los formularios de sitios y coordenadas. Agregue sus propios términos, elimine los que no usará o deje los valores predeterminados. Puede actualizar estas listas más adelante en Configuración > Sitios.';

  @override
  String get setupSiteTypes => 'Tipos de sitio';

  @override
  String get setupHabitatTypes => 'Tipos de hábitat';

  @override
  String get setupDatums => 'Datums';

  @override
  String get setupEventsTitle => 'Vocabularios de eventos de recolecta';

  @override
  String get setupEventsMessage =>
      'Los vocabularios controlados para los eventos de recolecta. Puede actualizar estas listas más adelante en Configuración > Eventos.';

  @override
  String get setupPrimaryActivities => 'Actividades principales';

  @override
  String get setupCollectionMethods => 'Métodos de recolecta';

  @override
  String get setupPersonnelRoles => 'Funciones del personal';

  @override
  String get setupSpecimensTitle => 'Vocabularios de especímenes';

  @override
  String get setupSpecimensMessage =>
      'Los vocabularios controlados para los registros de especímenes. Puede actualizar estas listas más adelante en Configuración > Especímenes.';

  @override
  String get setupIdentificationMethods => 'Métodos de identificación';

  @override
  String get setupLifeStages => 'Etapas de vida';

  @override
  String get setupSpecimenTypes => 'Tipos de espécimen';

  @override
  String get setupTreatments => 'Tratamientos';

  @override
  String get setupConditions => 'Condiciones';

  @override
  String get setupParasitesMessage =>
      'NAHPU incluye un formulario de parásitos independiente para asociar registros de parásitos con especímenes. El interruptor de abajo le permite configurar los vocabularios controlados para los registros de parásitos.';

  @override
  String get setupCollectsParasites => 'Recolectaré parásitos';

  @override
  String get setupParasiteCategories => 'Categorías';

  @override
  String get setupDetectionMethods => 'Métodos de detección';

  @override
  String get setupPreparationMethods => 'Métodos de preparación';

  @override
  String get setupAnatomicalLocations => 'Ubicaciones anatómicas';

  @override
  String get setupStorage => 'Almacenamiento';

  @override
  String get setupFinishTitle => 'Todo está configurado';

  @override
  String get setupFinishMessage =>
      'NAHPU usará estas convenciones para los registros nuevos.';

  @override
  String get setupNotSet => 'Sin definir';

  @override
  String get setupFieldId => 'ID de campo';

  @override
  String get setupProjectId => 'ID del proyecto';

  @override
  String get setupPersonnelId => 'ID del personal';

  @override
  String get setupTissueId => 'ID de tejido';

  @override
  String get setupTissueNumberedSeparately => 'Numerado por separado';

  @override
  String get setupTissueFollowsSpecimen => 'Sigue al espécimen';

  @override
  String get setupParasitesCollected => 'Se recolectan';

  @override
  String get setupParasitesNotCollected => 'No se recolectan';

  @override
  String get setupShareTitle => 'Comparta esta configuración con su equipo';

  @override
  String get setupShareMessage =>
      'Su equipo solo necesita hacer esto una vez. Exporte estas configuraciones de usuario y compártalas con los miembros de su equipo o colaboradores para que todos trabajen con los mismos vocabularios y ajustes.';

  @override
  String get setupFinishNote =>
      'Nada aquí es definitivo. Cambie cualquier ajuste en Configuración o vuelva a ejecutar Configurar NAHPU desde el menú.';

  @override
  String get setupExportPresetsMessage =>
      'Estos son los ajustes predeterminados para exportar registros. Los diseños de impresión se usan para etiquetas, marbetes y libretas de campo. Los ajustes tabulares se usan para hojas de cálculo. Puede administrar o crear sus propios ajustes en el menú Configuración.';

  @override
  String get setupPresetDefaults => 'Predeterminados';

  @override
  String get setupPresetDefaultsMessage =>
      'Ajustes adecuados para cualquier formato de catálogo.';

  @override
  String setupPresetsForFormat(String catalogFormat) {
    return 'Para $catalogFormat';
  }

  @override
  String get setupPresetsForFormatMessage =>
      'Ajustes opcionales creados para este formato de catálogo.';

  @override
  String get setupAddSelectedPresets => 'Agregar ajustes seleccionados';

  @override
  String setupBundledPresetsLoadError(String error) {
    return 'No se pudieron cargar los ajustes incluidos: $error';
  }

  @override
  String setupAddPresetsError(String error) {
    return 'No se pudieron agregar los ajustes: $error';
  }

  @override
  String setupExportPresetCounts(int documentCount, int tabularCount) {
    return '$documentCount de documento, $tabularCount tabulares';
  }

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonCreate => 'Crear';

  @override
  String get commonSelect => 'Seleccionar';

  @override
  String get presetsTemplateDeleteTitle => 'Eliminar plantilla';

  @override
  String presetsDeleteNamePrompt(String name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String get presetsTemplateUnusedDelete =>
      'Esta plantilla no se usa y se eliminará de forma permanente.';

  @override
  String presetsTemplateInUse(int blockCount, int layoutCount) {
    String _temp0 = intl.Intl.pluralLogic(
      blockCount,
      locale: localeName,
      other: '$blockCount bloques',
      one: '1 bloque',
    );
    String _temp1 = intl.Intl.pluralLogic(
      layoutCount,
      locale: localeName,
      other: '$layoutCount diseños de impresión',
      one: '1 diseño de impresión',
    );
    return 'Esta plantilla se usa en $_temp0 de $_temp1. Elija un reemplazo antes de eliminarla.';
  }

  @override
  String presetsTemplateUsageBlocks(
    String layoutName,
    int count,
    String blocks,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'bloques',
      one: 'bloque',
    );
    return '$layoutName: $_temp0 $blocks';
  }

  @override
  String get presetsTemplateNoReplacement =>
      'Cree otra plantilla con el mismo tipo de registro o cambie los bloques de diseño afectados antes de eliminar esta.';

  @override
  String get presetsTemplateReplacement => 'Plantilla de reemplazo';

  @override
  String get presetsTemplateReplacementNote =>
      'El tamaño de página, los márgenes, la cuadrícula y el relleno no cambiarán. Revise los diseños de impresión afectados después del reemplazo.';

  @override
  String get presetsTemplateEmpty =>
      'Aún no hay plantillas. Las plantillas definen el contenido que se coloca en los bloques de los diseños de impresión.';

  @override
  String get presetsTemplateNoMatch =>
      'Ninguna plantilla coincide con su búsqueda.';

  @override
  String get presetsTemplateNoneToExport => 'No hay plantillas para exportar';

  @override
  String get presetsTemplateExportTitle => 'Exportar plantillas';

  @override
  String presetsTemplateCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plantillas',
      one: '1 plantilla',
    );
    return '$_temp0';
  }

  @override
  String presetsTemplateInvalidFile(String error) {
    return 'Archivo de plantilla no válido: $error';
  }

  @override
  String presetsTemplateImportFailed(String error) {
    return 'Error al importar las plantillas: $error';
  }

  @override
  String presetsTemplateImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se importaron $count plantillas',
      one: 'Se importó 1 plantilla',
    );
    return '$_temp0';
  }

  @override
  String presetsTemplateImportedPartial(int imported, int offered, int limit) {
    return 'Se importaron $imported de $offered plantillas (límite: $limit)';
  }

  @override
  String presetsTemplateLoadError(String error) {
    return 'No se pudieron cargar las plantillas: $error';
  }

  @override
  String presetsTemplateDeleted(String name) {
    return 'Se eliminó \"$name\"';
  }

  @override
  String presetsTemplateDeletedUpdated(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'actualizaron $count bloques',
      one: 'actualizó 1 bloque',
    );
    return 'Se eliminó \"$name\" y se $_temp0';
  }

  @override
  String presetsTemplateDeleteError(String error) {
    return 'No se pudo eliminar la plantilla: $error';
  }

  @override
  String get presetsTemplateSearchHint => 'Buscar plantillas';

  @override
  String get presetsUnused => 'Sin usar';

  @override
  String presetsTemplateLayoutCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count diseños',
      one: '1 diseño',
    );
    return '$_temp0';
  }

  @override
  String get presetsTemplateOptions => 'Opciones de plantilla';

  @override
  String get presetsRecordTypeSpecimen => 'Espécimen';

  @override
  String get presetsRecordTypeSite => 'Sitio';

  @override
  String get presetsRecordTypeCollEvent => 'Evento de recolección';

  @override
  String get presetsRecordTypeNarrative => 'Narrativa';

  @override
  String get presetsRecordTypeSpecimenParts => 'Partes del espécimen';

  @override
  String get presetsRecordTypeNone => 'Sin registros';

  @override
  String presetsFontReadError(String error) {
    return 'No se pudieron leer las fuentes: $error';
  }

  @override
  String get presetsFonts => 'Fuentes';

  @override
  String presetsFontInstalled(String family) {
    return 'Se instaló $family';
  }

  @override
  String presetsFontInstallError(String error) {
    return 'No se pudo instalar la fuente: $error';
  }

  @override
  String presetsFontInUseTitle(String family) {
    return '$family está en uso';
  }

  @override
  String presetsFontInUseBody(int count, String templates) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'estas plantillas',
      one: 'esta plantilla',
    );
    return 'Quite o cambie esta fuente en $_temp0 antes de eliminarla:\n\n$templates';
  }

  @override
  String presetsFontDeleteTitle(String family) {
    return '¿Eliminar $family?';
  }

  @override
  String get presetsFontDeleteBody =>
      'Los archivos de la fuente se quitan de esta instalación. Las plantillas que la usan en otros lugares no cambian.';

  @override
  String get presetsFontSearch => 'Buscar fuentes';

  @override
  String get presetsFontInstall => 'Instalar fuente';

  @override
  String get presetsFontFind => 'Buscar fuentes en línea';

  @override
  String get presetsFontLicenseNote =>
      'Descargue una fuente en su navegador y luego instale aquí el archivo .ttf u .otf. Usted es responsable de la licencia de cualquier fuente que instale.';

  @override
  String get presetsFontNoMatch => 'Ninguna fuente coincide con su búsqueda';

  @override
  String get presetsFontInstalledByYou => 'Instaladas por usted';

  @override
  String get presetsFontBundledWithNahpu => 'Incluidas con NAHPU';

  @override
  String presetsFontFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count archivos',
      one: '1 archivo',
    );
    return '$_temp0';
  }

  @override
  String presetsFontUsedByCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Usada en $count plantillas',
      one: 'Usada en 1 plantilla',
    );
    return '$_temp0';
  }

  @override
  String get presetsFontDelete => 'Eliminar fuente';

  @override
  String get presetsFontSelectToPreview => 'Seleccione una fuente para verla';

  @override
  String get presetsFontBundled => 'Incluida';

  @override
  String get presetsFontInstalledLabel => 'Instalada';

  @override
  String presetsFontUsedBy(String templates) {
    return 'Usada en $templates';
  }

  @override
  String get presetsFontSize => 'Tamaño';

  @override
  String presetsMaxReached(int max) {
    return 'Se alcanzó el máximo de $max ajustes predefinidos.';
  }

  @override
  String presetsImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se importaron $count ajustes predefinidos',
      one: 'Se importó 1 ajuste predefinido',
    );
    return '$_temp0';
  }

  @override
  String presetsImportFailed(String error) {
    return 'Error al importar los ajustes predefinidos: $error';
  }

  @override
  String get presetsNoneToExport => 'No hay ajustes predefinidos para exportar';

  @override
  String get presetsExportTabularTitle =>
      'Exportar ajustes predefinidos tabulares';

  @override
  String presetsTabularCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ajustes predefinidos tabulares',
      one: '1 ajuste predefinido tabular',
    );
    return '$_temp0';
  }

  @override
  String presetsExportFailed(String error) {
    return 'Error al exportar los ajustes predefinidos: $error';
  }

  @override
  String get presetsTabularTitle =>
      'Ajustes predefinidos de exportación tabular';

  @override
  String get presetsTabPresets => 'Ajustes predefinidos';

  @override
  String get presetsTabEditPreset => 'Editar ajuste predefinido';

  @override
  String get presetsSelectPresets => 'Seleccionar ajustes predefinidos';

  @override
  String get presetsTabularEmpty =>
      'Aún no hay ajustes predefinidos tabulares. Cree o importe uno, o agregue los ajustes predefinidos de su formato de catálogo en Configurar NAHPU.';

  @override
  String presetsMappingSummary(int count, String recordType) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count asignaciones',
      one: '1 asignación',
    );
    return '$_temp0 · $recordType';
  }

  @override
  String get presetsExportThisPreset => 'Exportar este ajuste predefinido';

  @override
  String presetsErrorDetail(String error) {
    return 'Error: $error';
  }

  @override
  String get presetsDeletePresetTitle => 'Eliminar ajuste predefinido';

  @override
  String presetsDeletePresetConfirm(String name) {
    return '¿Está seguro de que desea eliminar el ajuste predefinido \"$name\"?';
  }

  @override
  String get presetsSelectToEdit =>
      'Seleccione un ajuste predefinido para editarlo';

  @override
  String get presetsNotFound => 'No se encontró el ajuste predefinido';

  @override
  String get presetsLoadError => 'Error al cargar el ajuste predefinido';

  @override
  String get presetsNewPreset => 'Nuevo ajuste predefinido';

  @override
  String get presetsName => 'Nombre del ajuste predefinido';

  @override
  String get presetsNameExists =>
      'Ya existe un ajuste predefinido con este nombre';

  @override
  String get presetsNameEmpty => 'El nombre no puede estar vacío';

  @override
  String get presetsNameInvalidChars =>
      'Solo se permiten letras, números, guiones bajos y guiones';

  @override
  String get presetsPreviewEmptyTitle => 'No hay datos para la vista previa';

  @override
  String get presetsPreviewEmptyBody =>
      'Ningún registro coincidió con los filtros seleccionados o no hay asignaciones.';

  @override
  String presetsPreviewFailed(String error) {
    return 'No se pudo generar la vista previa: $error';
  }

  @override
  String presetsSaveError(String error) {
    return 'No se pudo guardar: $error';
  }

  @override
  String get presetsNameRequired =>
      'El nombre del ajuste predefinido no puede estar vacío.';

  @override
  String presetsNameTaken(String name) {
    return 'Ya existe un ajuste predefinido llamado \"$name\".';
  }

  @override
  String presetsUpdateError(String error) {
    return 'No se pudo actualizar: $error';
  }

  @override
  String get presetsDuplicateTitle => 'Duplicar ajuste predefinido';

  @override
  String presetsDuplicateError(String error) {
    return 'No se pudo duplicar: $error';
  }

  @override
  String presetsEditTitle(String name) {
    return 'Editar $name';
  }

  @override
  String get presetsEditFields => 'Editar campos';

  @override
  String get presetsPreviewExportTable =>
      'Vista previa de la tabla de exportación';

  @override
  String get presetsSaving => 'Guardando…';

  @override
  String get presetsSavedAutomatically => 'Se guarda automáticamente';

  @override
  String get presetsRecordType => 'Tipo de registro';

  @override
  String get presetsSpecimenTaxonGroup => 'Grupo taxonómico del espécimen';

  @override
  String get presetsHeaderFormat => 'Formato de encabezado generado';

  @override
  String get presetsHeaderNahpuNamespace =>
      'Espacio de nombres de NAHPU (nahpu:table.field)';

  @override
  String presetsPreviewSites(int count) {
    return 'Vista previa de sitios ($count seleccionados)';
  }

  @override
  String presetsPreviewEvents(int count) {
    return 'Vista previa de eventos ($count seleccionados)';
  }

  @override
  String presetsPreviewNarratives(int count) {
    return 'Vista previa de narrativas ($count seleccionadas)';
  }

  @override
  String presetsPreviewSpecimenParts(int count) {
    return 'Vista previa de partes de espécimen ($count seleccionadas)';
  }

  @override
  String presetsPreviewSpecimens(int count) {
    return 'Vista previa de espécimenes ($count seleccionados)';
  }

  @override
  String get presetsPreviewCurrentProject => 'Proyecto actual (ninguno)';

  @override
  String get presetsDocumentTitle => 'Ajustes predefinidos de documentos';

  @override
  String get presetsPrintLayouts => 'Diseños de impresión';

  @override
  String get presetsTemplates => 'Plantillas';

  @override
  String get presetsDocumentNew => 'Nuevo ajuste predefinido de documento';

  @override
  String presetsRenamed(String name) {
    return 'Se cambió el nombre a $name';
  }

  @override
  String presetsRenameFailed(String error) {
    return 'No se pudo cambiar el nombre: $error';
  }

  @override
  String get presetsExportPrintLayoutsTitle => 'Exportar diseños de impresión';

  @override
  String presetsPrintLayoutCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count diseños de impresión',
      one: '1 diseño de impresión',
    );
    return '$_temp0';
  }

  @override
  String presetsDocumentInvalidFile(String error) {
    return 'Archivo de diseño de documento no válido: $error';
  }

  @override
  String get presetsDocumentEmpty =>
      'Aún no hay diseños de impresión. Cree o importe uno, o cargue los diseños predeterminados.';

  @override
  String get presetsIncompatible => 'Ajuste predefinido incompatible';

  @override
  String get presetsIncompatibleBody =>
      'Este ajuste predefinido no es compatible con la versión actual.';

  @override
  String get presetsPreviewNoRecords =>
      'No hay registros de vista previa para este tipo';

  @override
  String get presetsPreviewSelectSpecimenParts =>
      'Seleccione partes de espécimen para la vista previa';

  @override
  String get presetsPreviewSelectSpecimens =>
      'Seleccione espécimenes para la vista previa';

  @override
  String get presetsTableColumns => 'Columnas de la tabla';

  @override
  String get commonApply => 'Aplicar';

  @override
  String get exportFieldsTitle => 'Editar asignaciones del ajuste';

  @override
  String get exportFieldsAvailableFields => 'Campos disponibles';

  @override
  String get exportFieldsSelectedMappings => 'Asignaciones seleccionadas';

  @override
  String get exportFieldsNoPreviewTitle => 'Sin datos para la vista previa';

  @override
  String get exportFieldsNoPreviewBody =>
      'Ningún registro coincide con los filtros seleccionados o las asignaciones están vacías.';

  @override
  String exportFieldsPreviewFailed(String error) {
    return 'No se pudo generar la vista previa: $error';
  }

  @override
  String get exportFieldsInsertSourceField => 'Insertar campo de origen';

  @override
  String get exportFieldsDisplayTableField => 'Tabla::Campo';

  @override
  String get exportFieldsDisplayFieldOnly => 'Solo el campo';

  @override
  String get exportFieldsOtherFields => 'Otros campos';

  @override
  String get exportFieldsSelectField => 'Seleccionar campo';

  @override
  String get exportFieldsChooseField => 'Elija un campo';

  @override
  String get exportFieldsCloseFieldPicker => 'Cerrar el selector de campos';

  @override
  String get exportFieldsSearchFields => 'Buscar campos o tablas';

  @override
  String get exportFieldsNoMatchingFields => 'No hay campos coincidentes.';

  @override
  String get exportFieldsAddCustomField => 'Agregar campo personalizado';

  @override
  String get exportFieldsAddNested => 'Agregar anidado';

  @override
  String get exportFieldsUnnamed => 'Sin nombre';

  @override
  String exportFieldsCardNested(String name) {
    return 'Anidado: $name';
  }

  @override
  String exportFieldsCardList(String name) {
    return 'Lista: $name';
  }

  @override
  String exportFieldsCardField(String name) {
    return 'Campo: $name';
  }

  @override
  String exportFieldsCardCustom(String name) {
    return 'Personalizado: $name';
  }

  @override
  String exportFieldsCardIndexedColumns(String style) {
    return 'Columnas indexadas · $style';
  }

  @override
  String get exportFieldsCardDarwinCoreSeparator =>
      'Una columna · separador \" | \" de Darwin Core';

  @override
  String exportFieldsCardSeparator(String separator) {
    return 'Una columna · separador $separator';
  }

  @override
  String exportFieldsCardFormat(String format, String options) {
    return 'Formato: $format · Opciones: $options';
  }

  @override
  String get exportFieldsCustomize => 'Personalizar';

  @override
  String get exportFieldsOneColumn => 'Una columna';

  @override
  String get exportFieldsIndexedColumns => 'Columnas indexadas';

  @override
  String get exportFieldsRepeatedRows => 'Filas repetidas';

  @override
  String get exportFieldsFormatConditionalBrackets => 'corchetes condicionales';

  @override
  String get exportFieldsFormatConditionalField => 'campo condicional';

  @override
  String get exportFieldsFormatConditionalValue => 'valor condicional';

  @override
  String get exportFieldsMappingType => 'Tipo de asignación';

  @override
  String get exportFieldsKindSingle => 'Campo único';

  @override
  String get exportFieldsKindCustom => 'Campo personalizado';

  @override
  String get exportFieldsKindList => 'Campo de lista';

  @override
  String get exportFieldsKindNested => 'Registros anidados';

  @override
  String get exportFieldsSourceField => 'Campo de origen';

  @override
  String get exportFieldsSourceFieldHelper =>
      'Elija el campo de NAHPU que proporciona esta columna.';

  @override
  String get exportFieldsColumnNameOptional =>
      'Nombre de la columna (opcional)';

  @override
  String get exportFieldsColumnNameOptionalHelper =>
      'Déjelo en blanco para usar el nombre del campo de origen.';

  @override
  String get exportFieldsListOutput => 'Salida de la lista';

  @override
  String exportFieldsExample(String example) {
    return 'Ejemplo: $example';
  }

  @override
  String get exportFieldsDarwinCoreListSeparator =>
      'Los valores de lista de Darwin Core se separan con \" | \".';

  @override
  String get exportFieldsSeparator => 'Separador';

  @override
  String get exportFieldsSeparatorPipe => 'Barra vertical (A | B)';

  @override
  String get exportFieldsSeparatorComma => 'Coma (A, B)';

  @override
  String get exportFieldsSeparatorSemicolon => 'Punto y coma (A; B)';

  @override
  String get exportFieldsSeparatorSlash => 'Barra (A / B)';

  @override
  String get exportFieldsSeparatorNewLine => 'Nueva línea';

  @override
  String get exportFieldsSeparatorBulleted => 'Con viñetas';

  @override
  String get exportFieldsSeparatorCustom => 'Personalizado';

  @override
  String get exportFieldsCustomSeparator => 'Separador personalizado';

  @override
  String get exportFieldsValueFormat => 'Formato del valor';

  @override
  String get exportFieldsValueNormal => 'Texto normal';

  @override
  String get exportFieldsValueEncoded => 'Texto codificado';

  @override
  String get exportFieldsValueCoordinates => 'Coordenadas';

  @override
  String get exportFieldsValueConditionalBrackets => 'Corchetes condicionales';

  @override
  String get exportFieldsValueConditionalField => 'Campo condicional';

  @override
  String get exportFieldsValueConditionalValue => 'Valor condicional';

  @override
  String get exportFieldsReplacementText => 'Texto de reemplazo';

  @override
  String get exportFieldsReplacementTextHelper =>
      'Se escribe cuando se cumple la condición; de lo contrario, se conserva el valor original.';

  @override
  String get exportFieldsColumnName => 'Nombre de la columna';

  @override
  String get exportFieldsColumnNameHelper =>
      'Asigne un nombre a la columna de salida que contiene el valor personalizado.';

  @override
  String get exportFieldsRelatedRecords => 'Registros relacionados';

  @override
  String get exportFieldsRelatedRecordsHelper =>
      'Seleccione el grupo de registros repetidos que desea exportar.';

  @override
  String get exportFieldsSelectedChildFields =>
      'Campos secundarios seleccionados';

  @override
  String get exportFieldsSelectChildFieldHint =>
      'Seleccione al menos un campo secundario a continuación.';

  @override
  String get exportFieldsMoveUp => 'Subir';

  @override
  String get exportFieldsMoveDown => 'Bajar';

  @override
  String get exportFieldsRemoveField => 'Quitar campo';

  @override
  String get exportFieldsChooseChildFields => 'Elegir campos secundarios';

  @override
  String get exportFieldsColumnPrefixOptional =>
      'Prefijo de columna (opcional)';

  @override
  String get exportFieldsNestedOutput => 'Salida anidada';

  @override
  String get exportFieldsNestedOneColumnHint =>
      'Combina todos los registros secundarios en una sola celda.';

  @override
  String get exportFieldsNestedIndexedHint =>
      'Crea un grupo de columnas para cada registro.';

  @override
  String get exportFieldsNestedRepeatedHint =>
      'Crea una fila de exportación por cada registro secundario.';

  @override
  String get exportFieldsNestedRepeatedTaken =>
      'Otra asignación ya expande las filas de exportación.';

  @override
  String get exportFieldsFieldSeparator => 'Separador de campos';

  @override
  String get exportFieldsRecordSeparator => 'Separador de registros';

  @override
  String get exportFieldsAdvanced => 'Avanzado';

  @override
  String get exportFieldsRawExpression => 'Expresión de origen sin procesar';

  @override
  String get exportFieldsRawFormatOption => 'Opción de formato sin procesar';

  @override
  String get exportFieldsRawFormatOptionHelper =>
      'Por ejemplo: enum, dms o custom_map:0=No.';

  @override
  String get exportFieldsEmptyValue => 'Valor vacío';

  @override
  String get exportFieldsEmptyBlank => 'En blanco';

  @override
  String get exportFieldsEmptyCustomText => 'Texto personalizado';

  @override
  String get exportFieldsCustomEmptyText =>
      'Texto personalizado para valores vacíos';

  @override
  String get exportFieldsRawNamespace =>
      'Espacio de nombres sin procesar de registros relacionados';

  @override
  String exportFieldsErrorReplacement(int number, String error) {
    return 'Reemplazo $number: $error';
  }

  @override
  String get exportFieldsErrorChooseGroup =>
      'Elija un grupo de registros relacionados.';

  @override
  String get exportFieldsErrorChooseChild =>
      'Elija al menos un campo secundario.';

  @override
  String get exportFieldsErrorSeparatorsEmpty =>
      'Los separadores de campos y de registros no pueden estar vacíos.';

  @override
  String get exportFieldsErrorMultiFieldHeader =>
      'Defina un encabezado personalizado para una asignación concatenada de varios campos.';

  @override
  String get exportFieldsErrorAddSegment =>
      'Agregue al menos un campo o segmento de texto.';

  @override
  String get exportFieldsErrorChooseSource => 'Elija un campo de origen.';

  @override
  String get exportFieldsErrorCompositeHeader =>
      'Defina un encabezado personalizado para una asignación compuesta.';

  @override
  String get exportFieldsErrorIndexedSingleSource =>
      'Las listas indexadas requieren exactamente un campo de origen.';

  @override
  String get exportFieldsErrorConditionalSingleSource =>
      'La salida condicional requiere exactamente un campo de origen.';

  @override
  String get exportFieldsErrorAddCondition => 'Agregue al menos una condición.';

  @override
  String get exportFieldsErrorReplacementText =>
      'Ingrese el texto de reemplazo.';

  @override
  String get exportFieldsErrorControllingField =>
      'Elija un campo de control para cada condición de corchetes.';

  @override
  String get exportFieldsErrorComparisonValue =>
      'Ingrese un valor de comparación para cada condición de corchetes.';

  @override
  String get exportFieldsErrorSelfDependency =>
      'Un campo condicional no puede depender de sí mismo.';

  @override
  String get exportFieldsCustomValue => 'Valor personalizado';

  @override
  String get exportFieldsCustomValueHelp =>
      'Los campos y el texto se escriben de izquierda a derecha. Agregue tantos segmentos como necesite.';

  @override
  String get exportFieldsCustomValueEmpty =>
      'Agregue un campo o texto para comenzar.';

  @override
  String get exportFieldsTextOrSeparator => 'Texto o separador';

  @override
  String get exportFieldsShowLabel => 'Mostrar etiqueta';

  @override
  String get exportFieldsEditConditionalText => 'Editar texto condicional';

  @override
  String get exportFieldsMoveSegmentUp => 'Subir segmento';

  @override
  String get exportFieldsMoveSegmentDown => 'Bajar segmento';

  @override
  String get exportFieldsRemoveSegment => 'Quitar segmento';

  @override
  String get exportFieldsAddField => 'Agregar campo';

  @override
  String get exportFieldsAddText => 'Agregar texto';

  @override
  String get exportFieldsAddConditionalText => 'Agregar texto condicional';

  @override
  String exportFieldsExpression(String expression) {
    return 'Expresión: $expression';
  }

  @override
  String get exportFieldsAddSourceField => 'Agregar campo de origen';

  @override
  String get exportFieldsConditionalText => 'Texto condicional';

  @override
  String get exportFieldsTextWhenMatched => 'Texto si se cumple';

  @override
  String exportFieldsTextWhenMatchedHelper(String example) {
    return 'Los campos como $example se completan.';
  }

  @override
  String get exportFieldsTextOtherwise => 'Texto en caso contrario (opcional)';

  @override
  String get exportFieldsTextOtherwiseHelper =>
      'Déjelo vacío para no escribir nada.';

  @override
  String get exportFieldsSummaryOr => 'o';

  @override
  String get exportFieldsSummaryAnd => 'y';

  @override
  String exportFieldsSummaryIf(String conditions, String text) {
    return 'Si $conditions → \"$text\"';
  }

  @override
  String exportFieldsSummaryIfOtherwise(
    String conditions,
    String text,
    String otherwise,
  ) {
    return 'Si $conditions → \"$text\"; si no, \"$otherwise\"';
  }

  @override
  String exportFieldsSummaryEquals(String field, String value) {
    return '$field es igual a \"$value\"';
  }

  @override
  String exportFieldsSummaryNotEquals(String field, String value) {
    return '$field no es igual a \"$value\"';
  }

  @override
  String exportFieldsSummaryContains(String field, String value) {
    return '$field contiene \"$value\"';
  }

  @override
  String exportFieldsSummaryIsNotEmpty(String field) {
    return '$field no está vacío';
  }

  @override
  String exportFieldsSummaryIsEmpty(String field) {
    return '$field está vacío';
  }

  @override
  String get exportFieldsValueConditions => 'Condiciones del valor';

  @override
  String get exportFieldsFieldConditions => 'Condiciones de campo';

  @override
  String get exportFieldsConditionsHelp =>
      'Compara los valores almacenados sin procesar. Los valores de control en blanco nunca coinciden.';

  @override
  String get exportFieldsMatchLogic => 'Lógica de coincidencia';

  @override
  String get exportFieldsMatchAny => 'Cualquier condición (O)';

  @override
  String get exportFieldsMatchAll => 'Todas las condiciones (Y)';

  @override
  String get exportFieldsAddCondition => 'Agregar condición';

  @override
  String get exportFieldsControllingField => 'Campo de control';

  @override
  String get exportFieldsOperatorEquals => 'Es igual a';

  @override
  String get exportFieldsOperatorNotEquals => 'No es igual a';

  @override
  String get exportFieldsOperatorContains => 'Contiene';

  @override
  String get exportFieldsOperatorIsNotEmpty => 'No está vacío';

  @override
  String get exportFieldsOperatorIsEmpty => 'Está vacío';

  @override
  String get exportFieldsValue => 'Valor';

  @override
  String get exportFieldsRemoveCondition => 'Quitar condición';

  @override
  String get exportFieldsIndexedColumnNames => 'Nombres de columnas indexadas';

  @override
  String exportFieldsIndexedUnderscore(String example) {
    return 'Guion bajo: $example';
  }

  @override
  String exportFieldsIndexedCompact(String example) {
    return 'Compacto: $example';
  }

  @override
  String exportFieldsIndexedBrackets(String example) {
    return 'Corchetes: $example';
  }

  @override
  String get exportFieldsOutputExample => 'Ejemplo de salida';

  @override
  String get exportFieldsOutputExampleEmpty =>
      'Complete la asignación para ver la forma de su salida.';

  @override
  String get exportFieldsOutputExampleRows =>
      'Cada registro secundario crea otra fila de exportación.';

  @override
  String get exportFieldsCustomizeNested => 'Personalizar asignación anidada';

  @override
  String get exportFieldsCustomizeField => 'Personalizar asignación de campo';

  @override
  String get exportFieldsPreviewTitle => 'Vista previa de la exportación';

  @override
  String exportFieldsPreviewShowing(int shown, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'Mostrando $shown de $total registros',
      one: 'Mostrando $shown de 1 registro',
    );
    return '$_temp0';
  }

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonYes => 'Sí';

  @override
  String get commonNo => 'No';

  @override
  String get formsChooseOne => 'Elija una opción';

  @override
  String formsErrorDetail(String error) {
    return 'Error: $error';
  }

  @override
  String formsAddValue(String type) {
    return 'Agregar $type';
  }

  @override
  String formsEnterValue(String type) {
    return 'Ingrese $type';
  }

  @override
  String get formsMatchDatabase => 'Coincidir con la base de datos';

  @override
  String formsMatchDatabaseTitle(String plural) {
    return '¿Coincidir $plural con la base de datos?';
  }

  @override
  String get formsMatchAppendMissing => 'Agregar faltantes';

  @override
  String get formsMatchOverrideAll => 'Reemplazar todo';

  @override
  String get formsMatchHelp =>
      'Use esta opción cuando reciba registros de alguien cuyos vocabularios controlados no tiene.';

  @override
  String formsMatchAppendDescription(String plural) {
    return 'Agregue los valores encontrados en la base de datos sin cambiar sus $plural existentes.';
  }

  @override
  String formsMatchOverrideDescription(String plural) {
    return 'Reemplace todos los $plural configurados por los valores que se encuentran actualmente en la base de datos.';
  }

  @override
  String get formsVocabSiteType => 'tipo de sitio';

  @override
  String get formsVocabSiteTypePlural => 'tipos de sitio';

  @override
  String get formsVocabHabitatType => 'tipo de hábitat';

  @override
  String get formsVocabHabitatTypePlural => 'tipos de hábitat';

  @override
  String get formsVocabDatum => 'datum';

  @override
  String get formsVocabDatumPlural => 'datums';

  @override
  String get formsVocabPrimaryActivity => 'actividad principal';

  @override
  String get formsVocabPrimaryActivityPlural => 'actividades principales';

  @override
  String get formsVocabCollectionMethod => 'método de recolección';

  @override
  String get formsVocabCollectionMethodPlural => 'métodos de recolección';

  @override
  String get formsVocabPersonnelRole => 'función del personal';

  @override
  String get formsVocabPersonnelRolePlural => 'funciones del personal';

  @override
  String get formsVocabIdentificationMethod => 'método de identificación';

  @override
  String get formsVocabIdentificationMethodPlural =>
      'métodos de identificación';

  @override
  String get formsVocabLifeStage => 'etapa de vida';

  @override
  String get formsVocabLifeStagePlural => 'etapas de vida';

  @override
  String get formsVocabSpecimenType => 'tipo de espécimen';

  @override
  String get formsVocabSpecimenTypePlural => 'tipos de espécimen';

  @override
  String get formsVocabTreatment => 'tratamiento';

  @override
  String get formsVocabTreatmentPlural => 'tratamientos';

  @override
  String get formsVocabCondition => 'condición';

  @override
  String get formsVocabConditionPlural => 'condiciones';

  @override
  String get formsVocabParasiteCategory => 'categoría';

  @override
  String get formsVocabParasiteCategoryPlural => 'categorías';

  @override
  String get formsVocabDetectionMethod => 'método de detección';

  @override
  String get formsVocabDetectionMethodPlural => 'métodos de detección';

  @override
  String get formsVocabPreparationMethod => 'método de preparación';

  @override
  String get formsVocabPreparationMethodPlural => 'métodos de preparación';

  @override
  String get formsVocabAnatomicalLocation => 'ubicación anatómica';

  @override
  String get formsVocabAnatomicalLocationPlural => 'ubicaciones anatómicas';

  @override
  String get formsVocabStorageValue => 'valor de almacenamiento';

  @override
  String get formsVocabStorageValuePlural => 'valores de almacenamiento';

  @override
  String get formsNextId => 'Siguiente ID';

  @override
  String get formsNextNumber => 'Siguiente número';

  @override
  String get formsNumberedIdNoPreview =>
      'Defina un siguiente número para numerar automáticamente · Se conservan los ceros iniciales';

  @override
  String formsNumberedIdPreview(String label, String preview) {
    return '$label: $preview · Se conservan los ceros iniciales';
  }

  @override
  String get formsBundledDocuments => 'Documentos';

  @override
  String get formsBundledTabularRecords => 'Registros tabulares';

  @override
  String get formsBundledTemplates => 'Plantillas';

  @override
  String formsBundledAdded(String description) {
    return 'Agregado · $description';
  }

  @override
  String get formsDescriptionOptional => 'Descripción (opcional)';

  @override
  String formsDescriptionTooLong(int max) {
    return 'Use $max caracteres o menos.';
  }

  @override
  String get formsShowInfo => 'Mostrar información';

  @override
  String get formsInfo => 'Información';

  @override
  String formsDeleteConfirmPrompt(String text) {
    return 'Escriba `$text` para habilitar la eliminación';
  }

  @override
  String get formsDeleteConfirmHint => 'Ingrese el texto de confirmación';

  @override
  String get formsSearchAll => 'Todo';

  @override
  String get formsSearchFieldNumber => 'Número de campo';

  @override
  String get formsSearchCataloger => 'Catalogador';

  @override
  String get formsSearchPreparator => 'Preparador';

  @override
  String get formsSearchCollector => 'Colector';

  @override
  String get formsSearchCondition => 'Condición';

  @override
  String get formsSearchPrepDate => 'Fecha de preparación';

  @override
  String get formsSearchPrepTime => 'Hora de preparación';

  @override
  String get formsSearchTaxa => 'Taxones';

  @override
  String get formsSearchPrepType => 'Tipo de preparación';

  @override
  String get formsSiteId => 'ID del sitio';

  @override
  String get formsSiteIdHint => 'Ingrese un sitio';

  @override
  String get formsSiteName => 'Nombre del sitio';

  @override
  String get formsPresetDuplicate => 'Duplicar';

  @override
  String get formsPresetName => 'Nombre del ajuste predefinido';

  @override
  String get formsPresetUpdateHelper =>
      'Seleccione Actualizar para guardar el nombre y la descripción';

  @override
  String get formsPresetUpdate => 'Actualizar';

  @override
  String formsCustomFieldLoadError(String error) {
    return 'No se pueden cargar los campos personalizados: $error';
  }

  @override
  String get formsCustomFieldManage => 'Administrar campos personalizados';

  @override
  String get formsEnterNumber => 'Ingrese un número';

  @override
  String get formsCustomFieldUnset => 'Sin definir';

  @override
  String formsCustomFieldArchivedOption(String label) {
    return '$label (archivado)';
  }

  @override
  String sharedPresetCreateTooltip(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'template': 'Crear nueva plantilla',
      'customField': 'Crear nuevo campo personalizado',
      'other': 'Crear nuevo ajuste predefinido',
    });
    return '$_temp0';
  }

  @override
  String sharedPresetOptions(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'template': 'Opciones de plantilla',
      'customField': 'Opciones de campo personalizado',
      'other': 'Opciones de ajuste predefinido',
    });
    return '$_temp0';
  }

  @override
  String get sharedPresetCreateNew => 'Crear nuevo';

  @override
  String get sharedPresetScanQr => 'Escanear QR';

  @override
  String sharedPresetExportSelected(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'template': 'Exportar esta plantilla',
      'customField': 'Exportar este campo personalizado',
      'other': 'Exportar este ajuste predefinido',
    });
    return '$_temp0';
  }

  @override
  String sharedPresetExportAll(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'template': 'Exportar todas las plantillas',
      'customField': 'Exportar todos los campos personalizados',
      'other': 'Exportar todos los ajustes predefinidos',
    });
    return '$_temp0';
  }

  @override
  String get sharedLoadDefaults => 'Cargar valores predeterminados';

  @override
  String get sharedShowMore => 'Mostrar más';

  @override
  String get sharedShowLess => 'Mostrar menos';

  @override
  String get sharedShare => 'Compartir';

  @override
  String get sharedUpdate => 'Actualizar';

  @override
  String get sharedAdd => 'Agregar';

  @override
  String get sharedExportAs => 'Exportar como…';

  @override
  String get sharedFind => 'Buscar';

  @override
  String sharedDeleteSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eliminar $count elementos',
      one: 'Eliminar 1 elemento',
    );
    return '$_temp0';
  }

  @override
  String get sharedDeleteSelectedTitle => 'Eliminar elementos seleccionados';

  @override
  String get sharedDeleteSelectedBody =>
      '¿Está seguro de que desea eliminar los elementos seleccionados?';

  @override
  String get sharedTryAgain => 'Intentar de nuevo';

  @override
  String sharedExportTimeLeft(String duration) {
    return 'quedan unos $duration';
  }

  @override
  String get sharedExportCancelling => 'Cancelando…';

  @override
  String sharedExportFilesOfTotal(int completed, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total archivos',
      one: '1 archivo',
    );
    return '$completed de $_temp0';
  }

  @override
  String sharedExportFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count archivos',
      one: '1 archivo',
    );
    return '$_temp0';
  }

  @override
  String sharedExportBytesOfTotal(String processed, String total) {
    return '$processed de $total';
  }

  @override
  String sharedExportElapsed(String duration) {
    return '$duration transcurridos';
  }

  @override
  String sharedExportUnitsOfTotal(int completed, int total) {
    return '$completed de $total';
  }

  @override
  String get sharedExportCancelledBody =>
      'No se guardó ningún archivo. No se modificó nada en este dispositivo.';

  @override
  String sharedExportStoppedAt(String step) {
    return 'Se detuvo durante: $step';
  }

  @override
  String get sharedExportDidNotFinish => 'La exportación no terminó.';

  @override
  String get sharedExportCancelled => 'Exportación cancelada';

  @override
  String get sharedExportFailed => 'Error en la exportación';

  @override
  String get sharedExportComplete => 'Exportación completada';

  @override
  String get sharedSaved => 'Guardado';

  @override
  String get sharedHideSaveLocation => 'Ocultar ubicación de guardado';

  @override
  String get sharedExportTemporaryNote =>
      'Comparta este archivo ahora para conservarlo. NAHPU lo elimina cuando vuelve a exportar.';

  @override
  String get sharedExportAppStorageNote =>
      'Guardado en el almacenamiento de la aplicación NAHPU. Elija una carpeta la próxima vez para guardar directamente en ella.';

  @override
  String sharedExportFinishedIn(String duration) {
    return 'Terminado en $duration';
  }

  @override
  String sharedExportSizeIn(String size, String duration) {
    return '$size en $duration';
  }

  @override
  String get sharedOpenDirectory => 'Abrir directorio';

  @override
  String get sharedSaveToDevice => 'Guardar en el dispositivo';

  @override
  String sharedSaveCopyTooLarge(String limit) {
    return 'Es demasiado grande para guardarlo con la aplicación Archivos, que admite hasta $limit. Elija una carpeta antes de exportar para escribir archivos de este tamaño directamente en su dispositivo.';
  }

  @override
  String get sharedQrExportImage => 'Exportar código QR como imagen';

  @override
  String get sharedQrImageTooLarge =>
      'Estos datos son demasiado grandes para una imagen de código QR.';

  @override
  String get sharedLoadDefaultsDescription =>
      'Elija los ajustes predefinidos incluidos que desea agregar. Los ajustes predefinidos que ya tiene no se modifican.';

  @override
  String get sharedLoadDefaultsNone =>
      'No hay ajustes predefinidos de este tipo.';

  @override
  String get sharedLoadDefaultsGenericTitle => 'Predeterminados';

  @override
  String get sharedLoadDefaultsGenericMessage =>
      'Ajustes predefinidos adecuados para cualquier formato de catálogo.';

  @override
  String sharedLoadDefaultsForFormat(String format) {
    return 'Para $format';
  }

  @override
  String get sharedLoadDefaultsForFormatMessage =>
      'Ajustes predefinidos opcionales creados para este formato de catálogo.';

  @override
  String get sharedLoadDefaultsLayoutsNote =>
      'Los diseños incluyen las plantillas con las que se imprimen.';

  @override
  String get sharedLoadSelected => 'Cargar seleccionados';

  @override
  String sharedLoadDefaultsLoadError(String error) {
    return 'No se pudieron cargar los ajustes predefinidos incluidos: $error';
  }

  @override
  String sharedLoadDefaultsFailed(String error) {
    return 'No se pudieron cargar los ajustes predefinidos: $error';
  }

  @override
  String get sharedIncludeLinkedTemplates => 'Incluir plantillas vinculadas';

  @override
  String sharedLinkedTemplateList(int count, String names) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plantillas: $names',
      one: '1 plantilla: $names',
    );
    return '$_temp0';
  }

  @override
  String sharedExportedTo(String path) {
    return 'Exportado a $path';
  }

  @override
  String sharedExportFailedError(String error) {
    return 'Error en la exportación: $error';
  }

  @override
  String get sharedExportProjectInfo => 'Exportar información del proyecto';

  @override
  String get sharedExportProjectInfoDescription =>
      'Exporte la información de este proyecto como JSON.';

  @override
  String get sharedSortOrder => 'Orden';

  @override
  String get sharedSortAscending => 'Ascendente';

  @override
  String get sharedSortDescending => 'Descendente';

  @override
  String get sharedSortId => 'ID';

  @override
  String get sharedSortRecordOrder => 'Orden de registro';

  @override
  String get sharedSortSiteId => 'ID del sitio';

  @override
  String get sharedSortStateProvince => 'Estado/provincia';

  @override
  String get sharedSortPreciseLocality => 'Localidad precisa';

  @override
  String get sharedSortEventId => 'ID del evento';

  @override
  String get sharedSortStartDate => 'Fecha de inicio';

  @override
  String get sharedSortFieldId => 'ID de campo';

  @override
  String get sharedSortCataloger => 'Catalogador';

  @override
  String get sharedSortSpecies => 'Especie';

  @override
  String get sharedSortDate => 'Fecha';

  @override
  String get sharedSortWriter => 'Autor';

  @override
  String sharedImportRecordType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'site': 'Importar sitio',
      'event': 'Importar evento',
      'other': 'Importar espécimen',
    });
    return '$_temp0';
  }

  @override
  String sharedCreateNewRecordType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'site': 'Crear nuevo sitio',
      'event': 'Crear nuevo evento',
      'other': 'Crear nuevo espécimen',
    });
    return '$_temp0';
  }

  @override
  String sharedUpdateExistingRecordType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'site': 'Actualizar un sitio existente',
      'event': 'Actualizar un evento existente',
      'other': 'Actualizar un espécimen existente',
    });
    return '$_temp0';
  }

  @override
  String sharedExportRecordType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'site': 'Exportar sitio',
      'event': 'Exportar evento',
      'other': 'Exportar espécimen',
    });
    return '$_temp0';
  }

  @override
  String sharedExportRecordJson(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'site': 'Exporte este registro de sitio como JSON.',
      'event': 'Exporte este registro de evento como JSON.',
      'other': 'Exporte este registro de espécimen como JSON.',
    });
    return '$_temp0';
  }

  @override
  String sharedExportRecordMedia(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Este registro incluye $count archivos multimedia vinculados, que se incluirán en el archivo comprimido.',
      one:
          'Este registro incluye 1 archivo multimedia vinculado, que se incluirá en el archivo comprimido.',
    );
    return '$_temp0';
  }

  @override
  String sharedReusesSavedLocality(String locality) {
    return 'Reutiliza una localidad guardada: $locality';
  }

  @override
  String get sharedContinue => 'Continuar';

  @override
  String get sharedBack => 'Atrás';

  @override
  String get sharedChooseEventSite => 'Elegir sitio del evento';

  @override
  String get sharedChooseEventSiteDescription =>
      'Este evento incluye un sitio vinculado. Elija un sitio existente o cree el sitio incluido como un sitio nuevo.';

  @override
  String get sharedCreateEmbeddedSite => 'Crear sitio incluido';

  @override
  String get sharedCreateEmbeddedEvent => 'Crear evento incluido';

  @override
  String get sharedCreateEmbeddedTaxonomy => 'Crear taxonomía incluida';

  @override
  String get sharedChooseSpecimenEvent => 'Elegir evento del espécimen';

  @override
  String get sharedChooseSpecimenTaxonomy => 'Elegir taxonomía del espécimen';

  @override
  String sharedCoordinateCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count coordenadas',
      one: '1 coordenada',
    );
    return '$_temp0';
  }

  @override
  String sharedPersonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas',
      one: '1 persona',
    );
    return '$_temp0';
  }

  @override
  String sharedCollMethodCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count métodos de colecta',
      one: '1 método de colecta',
    );
    return '$_temp0';
  }

  @override
  String sharedPersonnelAssignmentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count asignaciones de personal',
      one: '1 asignación de personal',
    );
    return '$_temp0';
  }

  @override
  String get sharedEnvironmentalData => 'datos ambientales';

  @override
  String sharedMediaFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count archivos multimedia',
      one: '1 archivo multimedia',
    );
    return '$_temp0';
  }

  @override
  String get sharedNoAssociatedRecords => 'Sin registros asociados';

  @override
  String sharedSiteLabel(String id) {
    return 'Sitio $id';
  }

  @override
  String sharedEventLabel(String id) {
    return 'Evento $id';
  }

  @override
  String sharedSpecimenLabel(String id) {
    return 'Espécimen $id';
  }

  @override
  String sharedTaxonLabel(String id) {
    return 'Taxón $id';
  }

  @override
  String get sharedRecordLabel => 'Registro';

  @override
  String sharedSpecimenImportSummary(
    int partCount,
    int associatedCount,
    int mediaCount,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      partCount,
      locale: localeName,
      other: '$partCount partes',
      one: '1 parte',
    );
    String _temp1 = intl.Intl.pluralLogic(
      associatedCount,
      locale: localeName,
      other: '$associatedCount registros asociados',
      one: '1 registro asociado',
    );
    String _temp2 = intl.Intl.pluralLogic(
      mediaCount,
      locale: localeName,
      other: '$mediaCount archivos multimedia',
      one: '1 archivo multimedia',
    );
    return 'Incluye $_temp0, $_temp1 y $_temp2.';
  }

  @override
  String get sharedSiteQrCode => 'Código QR del sitio';

  @override
  String get sharedEventQrCode => 'Código QR del evento';

  @override
  String get sharedSpecimenImported => 'Espécimen importado correctamente.';

  @override
  String get sharedSiteImported => 'Sitio importado correctamente.';

  @override
  String get sharedEventImported => 'Evento importado correctamente.';

  @override
  String get sharedQrNoData => 'El código QR no contiene datos.';

  @override
  String get sharedRecordQrTooLargeBody =>
      'Este registro contiene demasiados datos para un código QR. Expórtelo como JSON para transferir el registro completo.';

  @override
  String get sharedRecordQrDescription =>
      'Escanee este código desde otro dispositivo con NAHPU para importar el registro.';

  @override
  String sharedRecordExchangeFailed(String error) {
    return 'Error al importar o exportar el registro: $error';
  }

  @override
  String get sharedFileName => 'Nombre del archivo';

  @override
  String sharedSomethingWentWrong(String error) {
    return 'Algo salió mal: $error';
  }

  @override
  String get sharedSelectFile => 'Seleccionar archivo';

  @override
  String get sharedSupportedFormats => 'Formatos admitidos';

  @override
  String sharedSupportedFormatsList(String label, String formats) {
    return '$label:\n$formats';
  }

  @override
  String get sharedAppendDate => 'Añadir la fecha actual';

  @override
  String get sharedAppendDateDescription =>
      'Añade -yyyy-mm-dd al nombre del archivo';

  @override
  String get sharedSaveTo => 'Guardar en';

  @override
  String get sharedSelectDirectory => 'Seleccionar directorio';

  @override
  String get sharedClearDirectory => 'Borrar directorio';

  @override
  String get sharedNoFolderChosen =>
      'No se eligió ninguna carpeta. La exportación se guarda en el almacenamiento de la aplicación NAHPU; examine para elegir otra carpeta.';

  @override
  String get sharedShareAfterExport => 'Compartir después de exportar';

  @override
  String get sharedTemporaryExportNote =>
      'NAHPU conserva el archivo solo hasta la próxima exportación. Compártalo para guardar una copia en Archivos, enviarlo a otra aplicación o ponerlo en una carpeta en la nube.';

  @override
  String get sharedEntireDatabaseContents =>
      'Contenido completo de la base de datos';

  @override
  String get sharedBackupSizeBeforeCompression =>
      'Tamaño de la copia de seguridad antes de comprimir';

  @override
  String sharedWizardStepChip(int number, String label) {
    return '$number. $label';
  }

  @override
  String get sharedNavDashboard => 'Panel';

  @override
  String get sharedNavSites => 'Sitios';

  @override
  String get sharedNavEvents => 'Eventos';

  @override
  String get sharedNavSpecimens => 'Especímenes';

  @override
  String get sharedNavNarrative => 'Narrativa';

  @override
  String get sharedNavCollapse => 'Contraer';

  @override
  String get sharedNavExpand => 'Expandir';

  @override
  String get sharedNavCollapseNavigation => 'Contraer navegación';

  @override
  String get sharedNavExpandNavigation => 'Expandir navegación';

  @override
  String get sharedNavCollapseRail => 'Contraer barra de navegación';

  @override
  String get sharedNavExpandRail => 'Expandir barra de navegación';

  @override
  String get sharedNavMenu => 'Menú';

  @override
  String get sharedNavCloseMenu => 'Cerrar menú';

  @override
  String get sharedNavCloseProjectMenu => 'Cerrar menú del proyecto';

  @override
  String get sharedNavOpenProjectMenu => 'Abrir menú del proyecto';

  @override
  String get sharedNavCloseProject => 'Cerrar proyecto';

  @override
  String get sharedGoToPage => 'Ir a la página';

  @override
  String get sharedGoToPageOrSearch => 'Ir a la página o buscar';

  @override
  String sharedPageOf(int current, int total) {
    return 'Página $current de $total';
  }

  @override
  String get sharedSearch => 'Buscar';

  @override
  String get sharedPageNumber => 'Número de página';

  @override
  String get sharedGo => 'Ir';

  @override
  String get sharedOr => 'o';

  @override
  String get sharedSearchRecords => 'Buscar registros';

  @override
  String sharedPageOutOfRange(int total) {
    return 'Introduce una página del 1 al $total';
  }

  @override
  String get textReplaceErrorEmptyPattern =>
      'El texto a buscar no puede estar vacío.';

  @override
  String textReplaceErrorInvalidRegex(String detail) {
    return 'Expresión regular no válida: $detail';
  }

  @override
  String get textReplaceAdd => 'Agregar reemplazo';

  @override
  String get textReplaceTitle => 'Reemplazar texto';

  @override
  String get textReplaceSubtitle =>
      'Se aplican en orden después de dar formato al valor.';

  @override
  String get textReplaceDialogTitle => 'Buscar y reemplazar';

  @override
  String get textReplaceMatch => 'Coincidencia';

  @override
  String get textReplaceMatchExact => 'Exacta';

  @override
  String get textReplaceMatchRegex => 'Regex';

  @override
  String get textReplaceFind => 'Buscar';

  @override
  String get textReplaceWith => 'Reemplazar con';

  @override
  String get textReplaceIgnoreCase => 'Ignorar mayúsculas';

  @override
  String get textReplaceMoveUp => 'Subir reemplazo';

  @override
  String get textReplaceMoveDown => 'Bajar reemplazo';

  @override
  String get textReplaceRemove => 'Quitar reemplazo';

  @override
  String get textReplaceRegexHelp =>
      'Use \$0 para la coincidencia completa, \$1…\$n para los grupos y \$\$ para \$.';

  @override
  String get documentFontSampleA =>
      'El durián es el rey de las frutas y el mangostán es la reina. Al parecer, nunca es buena idea comerlos al mismo tiempo. Definitivamente no debí comer 12 duriones y una docena de mangostanes de una sentada en el campo.';

  @override
  String get documentFontSampleB =>
      'Solo hay un lugar en el norte de Sumatra donde orangutanes, rinocerontes, elefantes y tigres comparten el mismo hábitat natural. ¿Adivina el nombre del parque nacional?';

  @override
  String get documentFontSampleC =>
      '¿Se siente creativo o inspirado? Envíe al responsable del proyecto sus ideas, un dato interesante sobre biodiversidad, un chiste de campo o un relato breve que valga la pena leer, o publíquelo en github.com/nahpu/nahpu/issues, y podría aparecer aquí mismo. La elección de una fuente no debería depender de un veloz murciélago hindú que comía feliz cardillo y kiwi.';

  @override
  String get documentFontBold => 'Negrita';

  @override
  String get documentFontItalic => 'Cursiva';

  @override
  String get fieldEditorLabel => 'Etiqueta';

  @override
  String get fieldEditorType => 'Tipo';

  @override
  String get fieldEditorCatalogApplicability =>
      'Formatos de catálogo aplicables';

  @override
  String fieldEditorCurrentCatalogOnly(String catalog) {
    return 'Solo el catálogo actual ($catalog)';
  }

  @override
  String get fieldEditorOptions => 'Opciones';

  @override
  String get fieldEditorOptionsHelper => 'Escriba una opción por línea.';

  @override
  String get fieldEditorMapToDwc => 'Asignar a Darwin Core';

  @override
  String fieldEditorDwcOfficialTerms(String version) {
    return 'Términos oficiales $version';
  }

  @override
  String get fieldEditorDwcTarget => 'Destino DWC';

  @override
  String get fieldEditorDwcMappingMode => 'Modo de asignación';

  @override
  String get fieldEditorDwcDirect => 'Campo directo';

  @override
  String get fieldEditorDwcAssertion => 'Medición o hecho repetible';

  @override
  String get fieldEditorDwcField => 'Campo DWC';

  @override
  String get fieldEditorDwcAllowConflict =>
      'Entiendo que habrá valores duplicados';

  @override
  String get fieldEditorDwcAllowConflictNote =>
      'Los valores escalares en conflicto se unirán con “ | ”.';

  @override
  String get fieldEditorEditTitle => 'Editar campo personalizado';

  @override
  String fieldEditorAddTitle(String section) {
    return 'Agregar campo personalizado a $section';
  }

  @override
  String get documentFileSettings => 'Configuración del archivo';

  @override
  String get documentFileFormat => 'Formato de archivo';

  @override
  String get documentFileBundleFormat => 'Formato del paquete';

  @override
  String get documentFileDwcDpZipNote =>
      'ZIP se ofrece por compatibilidad. TAR.GZ es la opción de DwC-DP conforme al estándar.';

  @override
  String get documentFileFormatCsv => 'Separado por comas (.csv)';

  @override
  String get documentFileFormatTsv => 'Separado por tabulaciones (.tsv)';

  @override
  String get documentFileFormatExcel => 'Excel (.xlsx)';

  @override
  String get documentFileFormatJson => 'JSON (.json)';

  @override
  String documentPreviewPdfError(String error) {
    return 'Error al generar el PDF:\n$error';
  }

  @override
  String get documentPreviewUnavailable => 'No hay vista previa disponible.';

  @override
  String get documentPreviewNotGenerated =>
      'La vista previa no se ha generado.';

  @override
  String get documentPreviewNoLayout => 'No se ha cargado ningún diseño.';

  @override
  String get documentPreviewUpdate => 'Actualizar vista previa';

  @override
  String get documentPreviewGenerate => 'Generar vista previa';

  @override
  String get documentPreviewOptionsChanged =>
      'Las opciones de vista previa cambiaron';

  @override
  String documentPreviewPageOf(int current, int total) {
    return 'Página $current de $total';
  }

  @override
  String get documentColumnsDefaults => 'Predeterminadas';

  @override
  String documentColumnsSelectedCount(int selected, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$selected de $total columnas seleccionadas',
      one: '$selected de 1 columna seleccionada',
    );
    return '$_temp0';
  }

  @override
  String get documentPartFilterTitle => 'Filtrar partes de especímenes';

  @override
  String get documentPartFilterNote =>
      'Los filtros solo cambian la lista. Las partes seleccionadas siguen incluidas en la exportación hasta que cambie la selección.';

  @override
  String get documentPartFilterTypes => 'Tipos de parte';

  @override
  String get documentPartFilterTypesHint =>
      'Deje todas sin marcar para incluir todos los tipos.';

  @override
  String get documentPartFilterNumberRange => 'Intervalo de números';

  @override
  String get documentPartFilterFieldNumber => 'Número de campo';

  @override
  String get documentPartFilterProjectNumber => 'Número de proyecto';

  @override
  String get documentPartFilterFrom => 'Desde';

  @override
  String get documentPartFilterTo => 'Hasta';

  @override
  String get documentPartFilterRangeHint =>
      'Incluye ambos extremos. Deje un extremo en blanco para no tener límite.';

  @override
  String get documentPartFilterReset => 'Restablecer filtros';

  @override
  String get documentPartFilterInvalidNumber =>
      'Escriba un número entero no negativo.';

  @override
  String get documentPartFilterFromAfterTo =>
      '“Desde” debe ser menor o igual que “Hasta”.';

  @override
  String documentPartsLoadError(String error) {
    return 'No se pudieron cargar las partes: $error';
  }

  @override
  String get documentPartsSearch => 'Buscar partes o números de especímenes';

  @override
  String get documentPartFilterActive =>
      'Filtrar partes de especímenes (activo)';

  @override
  String documentPartsSummary(int shown, int total, int selected) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total partes',
      one: '1 parte',
    );
    return 'Mostrando $shown de $_temp0 · Seleccionadas: $selected';
  }

  @override
  String documentPartsSummaryHidden(
    int shown,
    int total,
    int selected,
    int hidden,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total partes',
      one: '1 parte',
    );
    return 'Mostrando $shown de $_temp0 · Seleccionadas: $selected ($hidden ocultas)';
  }

  @override
  String get documentPartsEmpty => 'No se encontraron partes de especímenes';

  @override
  String documentPartFallbackTitle(String id) {
    return 'Parte $id';
  }

  @override
  String documentPartFieldNumber(String number) {
    return 'N.º de campo $number';
  }

  @override
  String documentPartProjectNumber(String number) {
    return 'N.º de proyecto $number';
  }

  @override
  String documentPartCatalog(String number) {
    return 'Catálogo $number';
  }

  @override
  String documentPartSpecimenFallback(String uuid) {
    return 'Espécimen $uuid';
  }

  @override
  String get documentSelectionClearAll => 'Borrar todo';

  @override
  String get documentSpecimenSearch =>
      'Buscar n.º de campo, colector, especie...';

  @override
  String documentSpecimenCollectedRange(String start, String end) {
    return 'Colecta: $start - $end';
  }

  @override
  String get documentSpecimenCollectionDate => 'Fecha de colecta';

  @override
  String documentSpecimenPreparedRange(String start, String end) {
    return 'Prep.: $start - $end';
  }

  @override
  String get documentSpecimenPrepDate => 'Fecha de preparación';

  @override
  String documentSelectionSelectedOf(int selected, int total) {
    return 'Seleccionados: $selected de $total';
  }

  @override
  String get documentSpecimenSelectTitle => 'Seleccionar especímenes';

  @override
  String get documentSelectSitePreview =>
      'Seleccionar sitio para la vista previa';

  @override
  String get documentSelectSitesPreview =>
      'Seleccionar sitios para la vista previa';

  @override
  String get documentSelectSites => 'Seleccionar sitios';

  @override
  String get documentSelectEventPreview =>
      'Seleccionar evento para la vista previa';

  @override
  String get documentSelectEventsPreview =>
      'Seleccionar eventos para la vista previa';

  @override
  String get documentSelectEvents => 'Seleccionar eventos';

  @override
  String get documentSelectNarrativePreview =>
      'Seleccionar narrativa para la vista previa';

  @override
  String get documentSelectNarrativesPreview =>
      'Seleccionar narrativas para la vista previa';

  @override
  String get documentSelectNarratives => 'Seleccionar narrativas';

  @override
  String get documentSiteSearch => 'Buscar ID del sitio, localidad...';

  @override
  String get documentSelectionClearSearch => 'Borrar búsqueda';

  @override
  String get documentSitesEmpty => 'No se encontraron sitios';

  @override
  String get documentSiteUnnamed => 'Sitio sin nombre';

  @override
  String get documentSiteNoLocality => 'Sin detalles de localidad';

  @override
  String documentSelectionLoadError(String error) {
    return 'Error: $error';
  }

  @override
  String get documentEventSearch => 'Buscar ID del evento, método...';

  @override
  String get documentEventsEmpty => 'No se encontraron eventos';

  @override
  String documentEventFallbackTitle(String id) {
    return 'ID del evento: $id';
  }

  @override
  String get documentEventNoMethod => 'Sin método';

  @override
  String get documentSelectionNoDate => 'Sin fecha';

  @override
  String get documentNarrativeSearch => 'Buscar fecha, contenido...';

  @override
  String get documentNarrativesEmpty => 'No se encontraron narrativas';

  @override
  String get documentNarrativeNoText => 'Sin texto';

  @override
  String get documentRecordsSpecimens => 'Especímenes';

  @override
  String get documentRecordsSites => 'Sitios';

  @override
  String get documentRecordsEvents => 'Eventos de colecta';

  @override
  String get documentRecordsNarratives => 'Narrativas';

  @override
  String get documentRecordsGeneric => 'Registros';

  @override
  String documentSelectedCount(int selected, int total) {
    return '$selected de $total seleccionados';
  }

  @override
  String get documentPageSizeLetter => 'Carta EE. UU. (8,5 x 11 in)';

  @override
  String get documentPageSizeLegal => 'Oficio EE. UU.';

  @override
  String get documentPageSizeCustom => 'Personalizado';

  @override
  String get documentOrientationPortrait => 'Vertical';

  @override
  String get documentOrientationLandscape => 'Horizontal';

  @override
  String get documentOverrideBlocks => 'Reemplazar los bloques de la plantilla';

  @override
  String get documentTemplateBlocks => 'Bloques de plantilla';

  @override
  String get documentAddBlock => 'Agregar bloque';

  @override
  String get documentMultiBlockMode => 'Modo de varios bloques';

  @override
  String get documentMultiBlockContinuous => 'Continuo (bloque por bloque)';

  @override
  String get documentMultiBlockAlternate => 'Alterno (registro por registro)';

  @override
  String documentBlockNumber(int number) {
    return 'Bloque n.º $number';
  }

  @override
  String get documentShowLess => 'Mostrar menos';

  @override
  String get documentShowMore => 'Mostrar más';

  @override
  String get documentDeleteBlock => 'Eliminar bloque';

  @override
  String get documentBlockTemplate => 'Plantilla';

  @override
  String get documentTemplateMissing => 'Esta plantilla ya no existe';

  @override
  String documentMissingItem(String name) {
    return 'Falta: $name';
  }

  @override
  String get documentEditTemplate => 'Editar plantilla';

  @override
  String get documentBlockCopies => 'Copias';

  @override
  String get documentBlockRows => 'Filas';

  @override
  String get documentBlockCols => 'Col.';

  @override
  String get documentAutoFillPage => 'Rellenar página automáticamente';

  @override
  String get documentTemplatePadding => 'Márgenes de la plantilla (mm)';

  @override
  String get documentPaddingTop => 'Superior';

  @override
  String get documentPaddingLeft => 'Izquierdo';

  @override
  String get documentPaddingRight => 'Derecho';

  @override
  String get documentPaddingBottom => 'Inferior';

  @override
  String get documentPageBreakAfter => 'Salto de página después';

  @override
  String get documentPageBreakAfterHint =>
      'Insertar un salto de página después de este bloque';

  @override
  String get documentCurrentProjectSelection => 'Selección del proyecto actual';

  @override
  String get documentActiveProjectDocument => '1 documento (proyecto activo)';

  @override
  String get documentSelectionSpecimens => 'Selección de especímenes';

  @override
  String get documentSelectionSpecimenParts =>
      'Selección de partes de especímenes';

  @override
  String get documentSelectionSites => 'Selección de sitios';

  @override
  String get documentSelectionEvents => 'Selección de eventos de colecta';

  @override
  String get documentSelectionNarratives => 'Selección de narrativas';

  @override
  String get documentSortDirection => 'Dirección';

  @override
  String get documentSortAscending => 'Ascendente';

  @override
  String get documentSortDescending => 'Descendente';

  @override
  String get documentSortFieldsLoadError =>
      'No se pudieron cargar los campos de ordenación';

  @override
  String get documentSortOriginalOrder => 'Orden original';

  @override
  String get documentSortOrderBy => 'Ordenar por';

  @override
  String get documentSortOrderRecordsBy => 'Ordenar registros por';

  @override
  String get documentSortClosePicker => 'Cerrar el selector de campo de orden';

  @override
  String documentSortFieldUnavailable(String table) {
    return '$table · No disponible para esta plantilla';
  }

  @override
  String documentFieldCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count campos',
      one: '1 campo',
    );
    return '$_temp0';
  }

  @override
  String get documentLayoutTitle => 'Diseño del documento';

  @override
  String get documentLayoutProfile => 'Perfil de diseño';

  @override
  String get documentLayoutProfileHelper =>
      'El perfil define la configuración de página y los bloques de plantilla.';

  @override
  String get documentManagePresets => 'Administrar ajustes predefinidos';

  @override
  String get documentPageSetup => 'Configuración de página';

  @override
  String get documentPageSize => 'Tamaño de página';

  @override
  String get documentPageWidthMm => 'Ancho (mm)';

  @override
  String get documentPageHeightMm => 'Alto (mm)';

  @override
  String get documentOrientation => 'Orientación';

  @override
  String get documentPagePadding => 'Márgenes de página (mm)';

  @override
  String get documentSelectSpecimenParts => 'Seleccionar partes de especímenes';

  @override
  String get labelCatalogFormatOrnithology => 'Ornitología';

  @override
  String get labelCatalogFormatMammalogy => 'Mastozoología';

  @override
  String get labelCatalogFormatHerpetology => 'Herpetología';

  @override
  String get labelCatalogFormatInvertebrateZoology =>
      'Zoología de invertebrados';

  @override
  String get labelCatalogFormatIchthyology => 'Ictiología';

  @override
  String get labelSpecimenRecordTypeAllTaxa => 'Todos los taxones';

  @override
  String get labelSpecimenRecordTypeBirds => 'Aves';

  @override
  String get labelSpecimenRecordTypeMammals => 'Mamíferos';

  @override
  String get labelSpecimenRecordTypeHerpetofauna => 'Herpetofauna';

  @override
  String get labelSpecimenRecordTypeInvertebrates => 'Invertebrados';

  @override
  String get labelSpecimenRecordTypeFishes => 'Peces';

  @override
  String get labelProjectToolCategoryUtilities => 'Utilidades';

  @override
  String get labelProjectToolCategoryProject => 'Proyecto';

  @override
  String get labelProjectToolCategoryRecords => 'Registros';

  @override
  String get labelProjectToolCategoryDatabase => 'Base de datos';

  @override
  String get labelProjectToolCategoryConfiguration => 'Configuración';

  @override
  String get labelProjectToolDataTable => 'Tabla de datos';

  @override
  String get labelProjectToolDataTableDescription =>
      'Explore, ordene y busque los registros del proyecto';

  @override
  String get labelProjectToolTemplates => 'Plantillas';

  @override
  String get labelProjectToolTemplatesDescription =>
      'Cree y edite plantillas de documentos';

  @override
  String get labelProjectToolMergeProject => 'Combinar proyecto';

  @override
  String get labelProjectToolMergeProjectDescription =>
      'Combine otro proyecto con este';

  @override
  String get labelProjectToolExportProject => 'Exportar proyecto';

  @override
  String get labelProjectToolExportProjectDescription =>
      'Exporte este proyecto para transferirlo';

  @override
  String get labelProjectToolBatchImport => 'Importación por lotes';

  @override
  String get labelProjectToolBatchImportDescription =>
      'Importe o actualice registros desde una hoja de cálculo';

  @override
  String get labelProjectToolCuration => 'Curaduría';

  @override
  String get labelProjectToolCurationDescription =>
      'Curaduría de especímenes: escanee tejidos en cajas de almacenamiento';

  @override
  String get labelProjectToolBundleRecords => 'Empaquetar registros';

  @override
  String get labelProjectToolBundleRecordsDescription =>
      'Empaquete los registros con sus archivos multimedia';

  @override
  String get labelProjectToolExportRecords => 'Exportar registros';

  @override
  String get labelProjectToolExportRecordsDescription =>
      'Exporte registros como datos tabulares';

  @override
  String get labelProjectToolExportDocuments => 'Exportar documentos';

  @override
  String get labelProjectToolExportDocumentsDescription =>
      'Exporte registros como documentos';

  @override
  String get labelProjectToolBackupDatabaseDescription =>
      'Respalde la base de datos de la aplicación';

  @override
  String get labelProjectToolSettingsDescription =>
      'Abra la configuración de la aplicación';

  @override
  String get labelProjectToolExportConfigs => 'Exportar configuraciones';

  @override
  String get labelProjectToolImportConfigs => 'Importar configuraciones';

  @override
  String get labelBasemapNone => 'Ninguno';

  @override
  String get labelBasemapNoneDescription => 'Sin capa base geográfica';

  @override
  String get labelBasemapAutomatic => 'Automático';

  @override
  String get labelBasemapAutomaticDescription =>
      'Positron en modo claro y Oscuro en modo oscuro';

  @override
  String get labelBasemapNaturalEarthOffline => 'Natural Earth (sin conexión)';

  @override
  String get labelBasemapNaturalEarthOfflineDescription =>
      'Límites de países incluidos que funcionan sin acceso a internet';

  @override
  String get labelBasemapPositronDescription =>
      'Mapa claro, minimalista y de bajo contraste';

  @override
  String get labelBasemapBrightDescription =>
      'Mapa detallado con colores vivos';

  @override
  String get labelBasemapLibertyDescription =>
      'Mapa detallado con colores equilibrados';

  @override
  String get labelBasemapDark => 'Oscuro';

  @override
  String get labelBasemapDarkDescription =>
      'Mapa oscuro para entornos con poca luz';

  @override
  String get labelMapLayerKindRasterTiles => 'Teselas ráster';

  @override
  String get labelMapLayerKindVectorTiles => 'Teselas vectoriales';

  @override
  String get labelMapLayerKindElevationModel => 'Modelo de elevación';

  @override
  String get labelFieldSectionSpecimenAttributes => 'Atributos del espécimen';

  @override
  String get labelFieldSectionSiteAttributes => 'Atributos del sitio';

  @override
  String get labelFieldSectionEnvironmentalData => 'Datos ambientales';

  @override
  String get labelFieldSectionSpecimenPart => 'Parte del espécimen';

  @override
  String get labelFieldSectionParasite => 'Parásito';

  @override
  String get labelSiteGeographyCountry => 'País';

  @override
  String get labelSiteGeographyIslandGroup => 'Grupo de islas';

  @override
  String get labelSiteGeographyStateProvince => 'Estado/Provincia';

  @override
  String get labelSiteGeographyCounty => 'Condado/Parroquia/Distrito';

  @override
  String get labelSiteGeographyMunicipality => 'Municipio/Ciudad/Pueblo';

  @override
  String get labelEnvironmentalLowestDayTemp => 'Temperatura mínima diurna';

  @override
  String get labelEnvironmentalHighestDayTemp => 'Temperatura máxima diurna';

  @override
  String get labelEnvironmentalLowestNightTemp => 'Temperatura mínima nocturna';

  @override
  String get labelEnvironmentalHighestNightTemp =>
      'Temperatura máxima nocturna';

  @override
  String get labelEnvironmentalAverageHumidity => 'Humedad promedio';

  @override
  String get labelEnvironmentalDewPoint => 'Punto de rocío';

  @override
  String get labelEnvironmentalCloudCover => 'Nubosidad';

  @override
  String get labelEnvironmentalRainfall => 'Precipitación';

  @override
  String get labelEnvironmentalAmbientTemperature => 'Temperatura ambiente';

  @override
  String get labelEnvironmentalAmbientHumidity => 'Humedad ambiente';

  @override
  String get labelEnvironmentalWaterTemperature => 'Temperatura del agua';

  @override
  String get labelEnvironmentalDissolvedOxygen => 'Oxígeno disuelto';

  @override
  String get labelEnvironmentalDissolvedOxygenSaturation =>
      'Saturación de oxígeno disuelto';

  @override
  String get labelEnvironmentalConductivity => 'Conductividad';

  @override
  String get labelEnvironmentalFlowVelocity => 'Velocidad del flujo';

  @override
  String get labelEnvironmentalSunrise => 'Amanecer';

  @override
  String get labelEnvironmentalSunset => 'Atardecer';

  @override
  String get labelEnvironmentalMoonPhase => 'Fase lunar';

  @override
  String get labelEnvironmentalNotes => 'Notas';

  @override
  String labelEnvironmentalWithUnit(String label, String unit) {
    return '$label ($unit)';
  }

  @override
  String get labelTableProject => 'Proyecto';

  @override
  String get labelTableGeography => 'Geografía';

  @override
  String get labelTableSite => 'Sitio';

  @override
  String get labelTableSiteAttribute => 'Atributo del sitio';

  @override
  String get labelTableFossilSite => 'Sitio fósil';

  @override
  String get labelTableCoordinate => 'Coordenada';

  @override
  String get labelTableCollEvent => 'Evento de colecta';

  @override
  String get labelTableEnvironment => 'Ambiente';

  @override
  String get labelTableCollPersonnel => 'Personal de colecta';

  @override
  String get labelTableCollMethod => 'Método de colecta';

  @override
  String get labelTableNarrative => 'Narrativa';

  @override
  String get labelTableMedia => 'Multimedia';

  @override
  String get labelTableNarrativeMedia => 'Multimedia de narrativa';

  @override
  String get labelTableSiteMedia => 'Multimedia del sitio';

  @override
  String get labelTableEventMedia => 'Multimedia del evento';

  @override
  String get labelTableSpecimenMedia => 'Multimedia del espécimen';

  @override
  String get labelTableAssociatedData => 'Datos asociados';

  @override
  String get labelTableSpecimenAssociatedData =>
      'Datos asociados del espécimen';

  @override
  String get labelTableSiteAssociatedData => 'Datos asociados del sitio';

  @override
  String get labelTableEventAssociatedData => 'Datos asociados del evento';

  @override
  String get labelTablePersonnelList => 'Lista de personal';

  @override
  String get labelTablePersonnel => 'Personal';

  @override
  String get labelTableTaxonomy => 'Taxonomía';

  @override
  String get labelTableSpecimen => 'Espécimen';

  @override
  String get labelTableMammalAttribute => 'Atributo de mamífero';

  @override
  String get labelTableBirdAttribute => 'Atributo de ave';

  @override
  String get labelTableHerpAttribute => 'Atributo herpetológico';

  @override
  String get labelTableInvertebrateAttribute => 'Atributo de invertebrado';

  @override
  String get labelTableFishAttribute => 'Atributo de pez';

  @override
  String get labelTableFossilAttribute => 'Atributo fósil';

  @override
  String get labelTableParasiteDetection => 'Detección de parásitos';

  @override
  String get labelTableParasite => 'Parásito';

  @override
  String get labelTableSpecimenPart => 'Parte del espécimen';

  @override
  String get labelTableSpecimenIndividual => 'Individuo del espécimen';

  @override
  String get labelTableSpecimenPartIndividual =>
      'Individuo de la parte del espécimen';

  @override
  String get labelTableParasiteIndividual => 'Individuo parásito';

  @override
  String get labelTableCustomFieldDefinition =>
      'Definición de campo personalizado';

  @override
  String get labelTableCustomFieldValue => 'Valor de campo personalizado';

  @override
  String fileExplorerFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count archivos',
      one: '1 archivo',
    );
    return '$_temp0';
  }

  @override
  String fileExplorerImageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count imágenes',
      one: '1 imagen',
    );
    return '$_temp0';
  }

  @override
  String fileExplorerAudioCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count archivos de audio',
      one: '1 archivo de audio',
    );
    return '$_temp0';
  }

  @override
  String fileExplorerVideoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count videos',
      one: '1 video',
    );
    return '$_temp0';
  }

  @override
  String fileExplorerOtherCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count archivos de otro tipo',
      one: '1 archivo de otro tipo',
    );
    return '$_temp0';
  }

  @override
  String get fileExplorerLockDatabase => 'Base de datos de la aplicación';

  @override
  String get fileExplorerLockDatabaseSidecar =>
      'Archivo de trabajo de la base de datos';

  @override
  String get fileExplorerLockBackup => 'Copia de seguridad de la base de datos';

  @override
  String get fileExplorerLockUserConfig =>
      'Fuentes y capas de mapa personalizadas';

  @override
  String get fileExplorerLockTemplateMedia => 'Multimedia global de plantillas';

  @override
  String get fileExplorerLockMediaRecord =>
      'Vinculado a un registro multimedia';

  @override
  String get fileExplorerLockPersonnelPhoto =>
      'Vinculado a una foto de personal';

  @override
  String get fileExplorerLockAssociatedData => 'Vinculado a datos asociados';

  @override
  String get fileExplorerLockUnresolvedReference =>
      'Un registro apunta aquí, pero no se pudo leer';

  @override
  String get fileExplorerLockRecentlyModified =>
      'Modificado hace un momento; es posible que aún se esté copiando';

  @override
  String get fileExplorerLockUnmanagedLocation =>
      'No está en una carpeta que NAHPU administre';

  @override
  String get fileExplorerLockUnknownProject =>
      'Carpeta de un proyecto que no está en la base de datos';

  @override
  String fileExplorerPruneBlockedUnresolved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'No se pudieron leer $count registros de datos asociados, por lo que algunos archivos no se pueden comprobar. La eliminación de archivos está desactivada hasta que se resuelva.',
      one:
          'No se pudo leer 1 registro de datos asociados, por lo que algunos archivos no se pueden comprobar. La eliminación de archivos está desactivada hasta que se resuelva.',
    );
    return '$_temp0';
  }

  @override
  String get fileExplorerPruneBlockedEmptyIndex =>
      'La base de datos no indica ningún archivo vinculado, lo que suele significar que aún se está abriendo. Vuelva a abrir esta pantalla antes de eliminar algo.';

  @override
  String get progressPrepareBackup => 'Preparar copia de seguridad';

  @override
  String get progressCopyMediaAndFiles => 'Copiar multimedia y archivos';

  @override
  String get progressCompressArchive => 'Comprimir archivo';

  @override
  String get progressExtractArchive => 'Extraer archivo';

  @override
  String get progressRestoreMediaAndFiles => 'Restaurar multimedia y archivos';

  @override
  String get progressBackUpCurrentData => 'Respaldar los datos actuales';

  @override
  String get progressReplaceDatabase => 'Reemplazar base de datos';

  @override
  String get progressWriteRecords => 'Escribir registros';

  @override
  String get progressCopyMedia => 'Copiar multimedia';

  @override
  String get progressCheckContents => 'Comprobar contenido';

  @override
  String get progressCollectRecords => 'Reunir registros';

  @override
  String get progressCheckRecords => 'Comprobar registros';

  @override
  String get progressWriteAndCompressPackage => 'Escribir y comprimir paquete';

  @override
  String get progressProcessMedia => 'Procesar multimedia';

  @override
  String serviceMessagePresetsAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se agregaron $count ajustes predefinidos',
      one: 'Se agregó 1 ajuste predefinido',
    );
    return '$_temp0';
  }

  @override
  String get serviceMessageNoDefaultPresets =>
      'No hay ajustes predefinidos de este tipo';

  @override
  String get serviceMessageDefaultPresetsLoaded =>
      'Los ajustes predefinidos ya están cargados';

  @override
  String serviceMessagePresetsAndTemplatesImported(
    int count,
    int templateCount,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ajustes predefinidos',
      one: '1 ajuste predefinido',
    );
    String _temp1 = intl.Intl.pluralLogic(
      templateCount,
      locale: localeName,
      other: '$templateCount plantillas',
      one: '1 plantilla',
    );
    return 'Se importaron $_temp0 y $_temp1';
  }

  @override
  String serviceMessagePresetImageNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count plantillas usan imágenes, que se referencian por nombre en lugar de guardarse en el archivo. En otra instalación será necesario agregar esas imágenes de nuevo.',
      one:
          '1 plantilla usa imágenes, que se referencian por nombre en lugar de guardarse en el archivo. En otra instalación será necesario agregar esas imágenes de nuevo.',
    );
    return '$_temp0';
  }

  @override
  String deletePersonnelCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eliminar $count personas',
      one: 'Eliminar 1 persona',
    );
    return '$_temp0';
  }

  @override
  String deletePersonnelTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eliminar personas',
      one: 'Eliminar persona',
    );
    return '$_temp0';
  }

  @override
  String deletePersonnelBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Está seguro de que desea eliminar las personas seleccionadas?',
      one: '¿Está seguro de que desea eliminar la persona seleccionada?',
    );
    return '$_temp0';
  }

  @override
  String deleteTaxaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eliminar $count taxones',
      one: 'Eliminar 1 taxón',
    );
    return '$_temp0';
  }

  @override
  String deleteTaxaTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eliminar taxones',
      one: 'Eliminar taxón',
    );
    return '$_temp0';
  }

  @override
  String deleteTaxaBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Está seguro de que desea eliminar los taxones seleccionados?',
      one: '¿Está seguro de que desea eliminar el taxón seleccionado?',
    );
    return '$_temp0';
  }

  @override
  String deleteCoordinatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eliminar $count coordenadas',
      one: 'Eliminar 1 coordenada',
    );
    return '$_temp0';
  }

  @override
  String deleteCoordinatesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eliminar coordenadas',
      one: 'Eliminar coordenada',
    );
    return '$_temp0';
  }

  @override
  String deleteCoordinatesBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '¿Está seguro de que desea eliminar las coordenadas seleccionadas?',
      one: '¿Está seguro de que desea eliminar la coordenada seleccionada?',
    );
    return '$_temp0';
  }

  @override
  String deleteCollMethodsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eliminar $count métodos de colecta',
      one: 'Eliminar 1 método de colecta',
    );
    return '$_temp0';
  }

  @override
  String deleteCollMethodsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eliminar métodos de colecta',
      one: 'Eliminar método de colecta',
    );
    return '$_temp0';
  }

  @override
  String deleteCollMethodsBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '¿Está seguro de que desea eliminar los métodos de colecta seleccionados?',
      one:
          '¿Está seguro de que desea eliminar el método de colecta seleccionado?',
    );
    return '$_temp0';
  }

  @override
  String deleteParasitesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eliminar $count parásitos',
      one: 'Eliminar 1 parásito',
    );
    return '$_temp0';
  }

  @override
  String deleteParasitesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eliminar parásitos',
      one: 'Eliminar parásito',
    );
    return '$_temp0';
  }

  @override
  String deleteParasitesBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Está seguro de que desea eliminar los parásitos seleccionados?',
      one: '¿Está seguro de que desea eliminar el parásito seleccionado?',
    );
    return '$_temp0';
  }

  @override
  String deleteSpecimenPartsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eliminar $count partes del espécimen',
      one: 'Eliminar 1 parte del espécimen',
    );
    return '$_temp0';
  }

  @override
  String deleteSpecimenPartsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eliminar partes del espécimen',
      one: 'Eliminar parte del espécimen',
    );
    return '$_temp0';
  }

  @override
  String deleteSpecimenPartsBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '¿Está seguro de que desea eliminar las partes del espécimen seleccionadas?',
      one:
          '¿Está seguro de que desea eliminar la parte del espécimen seleccionada?',
    );
    return '$_temp0';
  }

  @override
  String deleteAssociatedDataCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quitar $count entradas de datos asociados',
      one: 'Quitar 1 entrada de datos asociados',
    );
    return '$_temp0';
  }

  @override
  String get deleteAssociatedDataTitle => 'Quitar datos asociados';

  @override
  String get deleteAssociatedDataBody =>
      '¿Quitar los datos asociados seleccionados de este registro? Los datos compartidos con otros registros se conservarán.';

  @override
  String removeProjectPersonnelCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quitar $count personas del proyecto',
      one: 'Quitar 1 persona del proyecto',
    );
    return '$_temp0';
  }

  @override
  String get removeProjectPersonnelTitle => 'Quitar personal';

  @override
  String get removeProjectPersonnelBody =>
      '¿Está seguro de que desea quitar del proyecto al personal seleccionado?';

  @override
  String removeEventPersonnelCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quitar $count personas del evento',
      one: 'Quitar 1 persona del evento',
    );
    return '$_temp0';
  }

  @override
  String get removeEventPersonnelTitle => 'Quitar personal del evento';

  @override
  String get removeEventPersonnelBody =>
      '¿Está seguro de que desea quitar de este evento al personal seleccionado?';

  @override
  String get projectDeleteProject => 'Eliminar proyecto';

  @override
  String get projectDeleteProjectTitle => '¿Eliminar proyecto?';

  @override
  String get projectDeleteProjectPrompt =>
      'Eliminará este proyecto y sus datos relacionados. Esta acción no se puede deshacer.';

  @override
  String get projectNoProject => 'Ningún proyecto';

  @override
  String get projectOverview => 'Resumen del proyecto';

  @override
  String projectOverviewLoadError(Object error) {
    return 'No se pudieron obtener los datos de la base de datos. Compruebe que el nombre del proyecto exista. $error';
  }

  @override
  String projectSaveFailed(String error) {
    return 'No se pudo guardar el proyecto: $error';
  }

  @override
  String get projectDetails => 'Detalles del proyecto';

  @override
  String get projectNameLabel => 'Nombre del proyecto*';

  @override
  String get projectNameHint => 'Ingrese el nombre del proyecto (obligatorio)';

  @override
  String get projectDescriptionLabel => 'Descripción del proyecto';

  @override
  String get projectDescriptionHint =>
      'Ingrese una breve descripción del proyecto';

  @override
  String get projectPrincipalInvestigator => 'Investigador principal';

  @override
  String get projectPrincipalInvestigatorHint =>
      'Ingrese el investigador principal';

  @override
  String get projectAccession => 'Número de acceso';

  @override
  String get projectAccessionHint =>
      'Ingrese un número de acceso institucional';

  @override
  String get projectPlaceAndTime => 'Lugar y hora';

  @override
  String get projectLocation => 'Ubicación';

  @override
  String get projectLocationHint => 'Ingrese la ubicación general del proyecto';

  @override
  String get projectTimeZoneNote =>
      'NAHPU guarda las fechas y horas de colecta tal como se ingresan en la hora local de campo. La zona horaria del proyecto registra ese contexto para que los datos intercambiados se interpreten de forma coherente en sistemas de gestión de colecciones de terceros y otras herramientas.';

  @override
  String get projectDates => 'Fechas del proyecto';

  @override
  String get projectStartDate => 'Fecha de inicio';

  @override
  String get projectEndDate => 'Fecha de finalización';

  @override
  String get projectChooseDate => 'Elija una fecha';

  @override
  String projectClearField(String label) {
    return 'Borrar $label';
  }

  @override
  String get projectTimeZone => 'Zona horaria';

  @override
  String get projectChooseTimeZone => 'Elija una zona horaria';

  @override
  String get projectTimeZoneUtc => '(UTC) Tiempo universal coordinado';

  @override
  String get projectMainTaxonGroup => 'Grupo taxonómico principal';

  @override
  String get projectChooseTaxonGroup => 'Elija un grupo taxonómico';

  @override
  String projectTaxonSettingLoadError(String error) {
    return 'No se pudo cargar la configuración del taxón: $error';
  }

  @override
  String get projectIdentity => 'Identidad';

  @override
  String get projectDescription => 'Descripción';

  @override
  String get projectSchedule => 'Calendario';

  @override
  String get projectRecordMetadata => 'Metadatos del registro';

  @override
  String get projectCreated => 'Creado';

  @override
  String get projectLastAccessed => 'Último acceso';

  @override
  String get projectNotProvided => 'No indicado';

  @override
  String get projectUuid => 'UUID';

  @override
  String get projectQrTooltip =>
      'Código QR del proyecto. Toque para verlo completo.';

  @override
  String get projectEditTools => 'Editar herramientas';

  @override
  String get projectEditToolsTooltip =>
      'Elija las herramientas que se muestran aquí';

  @override
  String get projectUtilities => 'Utilidades del proyecto';

  @override
  String get projectDashboard => 'Panel del proyecto';

  @override
  String get projectEditProject => 'Editar proyecto';

  @override
  String get projectPersonnelRoleCataloger => 'Catalogador';

  @override
  String get projectPersonnelRoleDeterminer => 'Solo determinador';

  @override
  String get projectPersonnelRolePreparator => 'Solo preparador';

  @override
  String get projectPersonnelRoleNone => 'Ninguno';

  @override
  String get projectPersonnelSelectExisting => 'Seleccionar existente';

  @override
  String get projectPersonnelSelectFromDatabase =>
      'Seleccionar de la base de datos';

  @override
  String get projectPersonnelAddNew => 'Agregar nuevo';

  @override
  String get projectPersonnelAddNewPersonnel => 'Agregar nuevo personal';

  @override
  String get projectPersonnelImageNotFound => 'Imagen no encontrada';

  @override
  String get projectPersonnelTakePhoto => 'Tomar foto';

  @override
  String get projectPersonnelSelectPhoto => 'Seleccionar foto';

  @override
  String get projectPersonnelEdit => 'Editar personal';

  @override
  String get projectPersonnelManage => 'Gestionar personal';

  @override
  String get projectPersonnelManageButton => 'Gestionar';

  @override
  String get projectPersonnelNoneFound => 'No se encontró personal.';

  @override
  String get projectPersonnelSelectToView =>
      'Seleccione personal para ver los detalles';

  @override
  String get projectPersonnelSearch => 'Buscar personal';

  @override
  String get projectPersonnelUnnamed => 'Personal sin nombre';

  @override
  String get projectPersonnelAssigned =>
      'Este personal está asignado a un proyecto';

  @override
  String projectPersonnelDeleted(int deleted) {
    String _temp0 = intl.Intl.pluralLogic(
      deleted,
      locale: localeName,
      other: 'Se eliminaron $deleted personas.',
      one: 'Se eliminó 1 persona.',
    );
    return '$_temp0';
  }

  @override
  String projectPersonnelDeletedPartly(int deleted, int protected) {
    return 'Se eliminaron $deleted personas. $protected personas no se pudieron eliminar porque están asignadas a un proyecto.';
  }

  @override
  String projectPersonnelNoMatch(String query) {
    return 'Ningún personal coincide con «$query».';
  }

  @override
  String projectSelectedCount(int count) {
    return '$count seleccionados';
  }

  @override
  String get projectPersonnelAdded => 'Agregado';

  @override
  String projectPersonnelAddCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Agregar $count personas',
      one: 'Agregar 1 persona',
    );
    return '$_temp0';
  }

  @override
  String projectPersonnelRemoveBlocked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'No se pudieron quitar $count personas porque las usan registros del proyecto.',
      one: 'No se pudo quitar 1 persona porque la usan registros del proyecto.',
    );
    return '$_temp0';
  }

  @override
  String get projectPersonnelRole => 'Función';

  @override
  String get projectPersonnelRoleHint => 'Ingrese la función';

  @override
  String get projectPersonnelAffiliation => 'Afiliación';

  @override
  String get projectPersonnelAffiliationHint => 'Ingrese la afiliación';

  @override
  String get projectPersonnelOrcid => 'ORCID iD';

  @override
  String get projectPersonnelOrcidInvalid =>
      'Ingrese un ORCID iD válido con guiones';

  @override
  String get projectPersonnelCurrentFieldNumber => 'Número de campo actual';

  @override
  String get projectPersonnelInitials => 'Iniciales';

  @override
  String get projectPersonnelInitialsLabel => 'Iniciales*';

  @override
  String get projectPersonnelInitialsHint => 'p. ej., HH o H-H';

  @override
  String get projectPersonnelEmail => 'Correo electrónico';

  @override
  String get projectPersonnelEmailHint => 'Ingrese el correo electrónico';

  @override
  String get projectPersonnelPhone => 'Teléfono';

  @override
  String get projectPersonnelPhoneHint => 'Ingrese el teléfono';

  @override
  String get projectPersonnelSpecimenCare => 'Cuidado de especímenes';

  @override
  String get projectPersonnelSpecimenCareRole =>
      'Función en el cuidado de especímenes';

  @override
  String get projectPersonnelRegisterFieldNumber => 'Registrar número de campo';

  @override
  String get projectPersonnelRegisterPersonalFieldNumber =>
      'Registrar número de campo personal';

  @override
  String get projectPersonnelRegisterFieldNumberNote =>
      'Las iniciales y el número del catalogador se usarán para generar el ID de campo del espécimen.';

  @override
  String get projectEnabled => 'Activado';

  @override
  String get projectDisabled => 'Desactivado';

  @override
  String get projectPersonnelProfile => 'Perfil';

  @override
  String get projectPersonnelContact => 'Contacto';

  @override
  String get projectPersonnelNotes => 'Notas';

  @override
  String get projectPersonnelNotesHint => 'Escriba notas';

  @override
  String get projectPersonnelNameLabel => 'Nombre*';

  @override
  String get projectPersonnelNameHint => 'Ingrese un nombre (obligatorio)';

  @override
  String get projectPersonnelCatalogerNumberLabel => 'Número del catalogador*';

  @override
  String projectErrorDetail(String error) {
    return 'Error: $error';
  }

  @override
  String get projectLoading => 'Cargando…';

  @override
  String get projectTaxonNew => 'Nuevo taxón';

  @override
  String get projectTaxonEdit => 'Editar taxón';

  @override
  String get projectTaxonAdd => 'Agregar taxón';

  @override
  String get projectTaxonClassification => 'Clasificación';

  @override
  String get projectTaxonRank => 'Rango';

  @override
  String get projectTaxonRankLabel => 'Rango taxonómico';

  @override
  String get projectTaxonRankHint =>
      'Seleccione el rango que representa este registro';

  @override
  String get projectTaxonRankRequired =>
      'Seleccione un rango e ingrese su nombre.';

  @override
  String projectTaxonEnterValue(String field) {
    return 'Ingrese $field';
  }

  @override
  String get projectTaxonKingdom => 'Reino';

  @override
  String get projectTaxonPhylum => 'Filo';

  @override
  String get projectTaxonClass => 'Clase';

  @override
  String get projectTaxonOrder => 'Orden';

  @override
  String get projectTaxonFamily => 'Familia';

  @override
  String get projectTaxonGenus => 'Género';

  @override
  String get projectTaxonSpecies => 'Especie';

  @override
  String get projectTaxonSubspecies => 'Subespecie';

  @override
  String get projectTaxonSpecificEpithet => 'Epíteto específico';

  @override
  String get projectTaxonSubspecificEpithet => 'Epíteto subespecífico';

  @override
  String get projectTaxonAdditionalDetails => 'Detalles adicionales';

  @override
  String get projectTaxonAuthors => 'Autores';

  @override
  String get projectTaxonAuthorsHint => 'Ingrese los autores';

  @override
  String get projectTaxonCommonName => 'Nombre común';

  @override
  String get projectTaxonCommonNameHint => 'Ingrese un nombre común';

  @override
  String get projectTaxonRedListLabel =>
      'Categoría de la Lista Roja de la UICN';

  @override
  String get projectTaxonRedListHint => 'p. ej., En peligro, Vulnerable, etc.';

  @override
  String get projectTaxonRedListCategory => 'Categoría de la Lista Roja';

  @override
  String get projectTaxonCitesStatus => 'Estado CITES';

  @override
  String get projectTaxonCitesHint =>
      'p. ej., Apéndice I, Apéndice II, No CITES, etc.';

  @override
  String get projectTaxonCountryStatusLabel =>
      'Estado de conservación en el país';

  @override
  String get projectTaxonCountryStatusHint => 'p. ej., Protegida, común, etc.';

  @override
  String get projectTaxonCountryStatus => 'Estado en el país';

  @override
  String get projectTaxonSortingOrder => 'Orden de clasificación';

  @override
  String get projectTaxonSortingOrderHint => 'p. ej., 1, 2, 3';

  @override
  String get projectTaxonNotesHint => 'Ingrese notas';

  @override
  String get projectTaxonAllFields => 'Todos los campos';

  @override
  String get projectTaxonConservation => 'Conservación';

  @override
  String get projectTaxonTotalRecords => 'Total de registros';

  @override
  String get projectTaxonCurrentProject => 'Proyecto actual';

  @override
  String get projectTaxonAllProjects => 'Todos los proyectos';

  @override
  String projectTaxonRecordTotalsError(String error) {
    return 'No se pudieron cargar los totales de registros: $error';
  }

  @override
  String get projectTaxonQrTooltip =>
      'Código QR del taxón. Toque para verlo completo.';

  @override
  String get projectTaxonQrCode => 'Código QR del taxón';

  @override
  String get projectTaxonQrDescription =>
      'Escanee este código en NAHPU para importar este taxón.';

  @override
  String get projectTaxonRegistry => 'Registro de taxones';

  @override
  String projectTaxonImported(int taxa, int families) {
    return 'Se importaron $taxa taxones de $families familias.';
  }

  @override
  String get projectTaxonEmpty =>
      'No se encontraron taxones.\nAgregue o importe taxones para comenzar a registrar capturas.';

  @override
  String get projectTaxonMetricOrders => 'órdenes';

  @override
  String get projectTaxonMetricFamilies => 'familias';

  @override
  String get projectTaxonMetricSpecies => 'especies registradas';

  @override
  String get projectTaxonMetricTaxa => 'taxones';

  @override
  String get projectTaxonSpecimenRecords => 'Registros de especímenes';

  @override
  String get projectTaxonSearchSpecimens => 'Buscar especímenes';

  @override
  String get projectTaxonNoSpecimens => 'No se encontraron especímenes';

  @override
  String projectTaxonSpecimensFound(int found, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total especímenes',
      one: '1 espécimen',
    );
    String _temp1 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total especímenes',
      one: '1 espécimen',
    );
    String _temp2 = intl.Intl.pluralLogic(
      found,
      locale: localeName,
      other: 'Encontrados: $found de $_temp0',
      one: 'Encontrado: 1 de $_temp1',
    );
    return '$_temp2';
  }

  @override
  String projectTaxonSpecimenCount(int count) {
    return 'Conteo de especímenes: $count';
  }

  @override
  String get projectTaxonImportFromQr => 'Importar desde QR';

  @override
  String get projectTaxonSingle => 'Un solo taxón';

  @override
  String get projectTaxonMultiple => 'Varios taxones';

  @override
  String get projectTaxonScanQr => 'Escanear QR del taxón';

  @override
  String get projectTaxonScanMultiple => 'Escanear varios taxones';

  @override
  String get projectCameraDenied =>
      'Se denegó el acceso a la cámara. Permita el acceso a la cámara en la configuración del dispositivo y vuelva a intentarlo.';

  @override
  String get projectTaxonCameraUnavailable =>
      'El escaneo con la cámara no está disponible. Vuelva a intentarlo o importe un archivo.';

  @override
  String get projectTaxonCameraError =>
      'No se pudo usar la cámara. Vuelva a intentarlo o importe un archivo.';

  @override
  String projectTaxonReadyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count taxones listos',
      one: '1 taxón listo',
    );
    return '$_temp0';
  }

  @override
  String get projectTaxonScanPrompt =>
      'Escanee un código QR de taxón de NAHPU.';

  @override
  String get projectRetryCamera => 'Reintentar la cámara';

  @override
  String get projectTaxonManage => 'Gestionar taxones';

  @override
  String get projectTaxonNoneFound => 'No se encontraron taxones';

  @override
  String get projectTaxonSelectToView =>
      'Seleccione un taxón para ver los detalles';

  @override
  String projectTaxonSearchIn(String category) {
    return 'Buscar $category';
  }

  @override
  String projectTaxonSearchCategoryTooltip(String category) {
    return 'Categoría de búsqueda: $category';
  }

  @override
  String get projectTaxonSearchCategory => 'Categoría de búsqueda';

  @override
  String get projectTaxonInUse => 'El taxón está en uso por un espécimen';

  @override
  String projectTaxonDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se eliminaron $count taxones.',
      one: 'Se eliminó 1 taxón.',
    );
    return '$_temp0';
  }

  @override
  String projectTaxonDeletedPartly(int deleted, int protected) {
    return 'Se eliminaron $deleted taxones. $protected taxones no se pudieron eliminar porque los usan especímenes.';
  }

  @override
  String projectTaxonNoMatch(String query) {
    return 'Ningún taxón coincide con «$query».';
  }

  @override
  String projectTaxonNoMatchIn(String query, String category) {
    return 'Ningún taxón coincide con «$query» en $category.';
  }

  @override
  String get projectTaxonManual => 'Manual';

  @override
  String get projectImportSetupTab => 'Configuración';

  @override
  String get projectTaxonQrSource => 'QR de taxón de NAHPU';

  @override
  String get projectMapColumns => 'Asignar columnas';

  @override
  String get projectParsingError => 'Error de análisis';

  @override
  String get projectCheckColumns => 'Revise las columnas';

  @override
  String get projectHideAdvancedOptions => 'Ocultar opciones avanzadas';

  @override
  String get projectAdvancedOptions => 'Opciones avanzadas';

  @override
  String get projectTaxonReview => 'Revisar taxones';

  @override
  String get projectTaxonPreviewEmpty =>
      'Seleccione un archivo o escanee un QR de taxón para ver la importación.';

  @override
  String projectTaxonReviewSummary(int registered, int duplicates) {
    return '$registered ya registrados · $duplicates duplicados';
  }

  @override
  String get projectTaxonAlreadyRegistered => 'Ya registrado';

  @override
  String get projectTaxonDuplicate => 'Duplicado';

  @override
  String projectImportSelectedCount(int count) {
    return 'Importar $count seleccionados';
  }

  @override
  String get projectTaxonSelectSharedClass =>
      'Seleccione la clase común a todas las filas';

  @override
  String get projectTaxonClassForAllRows => 'Clase para todas las filas';

  @override
  String projectTaxonKingdomPhylum(String kingdom, String phylum) {
    return 'Reino: $kingdom · Filo: $phylum';
  }

  @override
  String get projectParserExcel => 'Analizador de Excel';

  @override
  String get projectParserDelimited => 'Analizador de texto delimitado';

  @override
  String get projectDelimiterNotApplicable => 'No aplica (archivo de Excel)';

  @override
  String get projectDelimiterTab => 'Tabulación (\"\\t\")';

  @override
  String get projectDelimiterComma => 'Coma (\",\")';

  @override
  String get projectDelimiterSemicolon => 'Punto y coma (\";\")';

  @override
  String get projectDelimiterCustomRaw => 'Personalizado (texto sin formato)';

  @override
  String get projectParsingDetails => 'Detalles del análisis';

  @override
  String projectParserValue(String parser) {
    return 'Analizador: $parser';
  }

  @override
  String projectDelimiterValue(String delimiter) {
    return 'Delimitador: $delimiter';
  }

  @override
  String get projectCustomDelimiterRequired =>
      'Ingrese un delimitador personalizado para continuar.';

  @override
  String get projectParser => 'Analizador';

  @override
  String get projectParserAutoDetect => 'Detectar automáticamente';

  @override
  String get projectCustomDelimiter => 'Delimitador personalizado';

  @override
  String get projectCustomDelimiterHint =>
      'Ingrese el texto sin formato (ejemplo: | o \\t)';

  @override
  String get projectRetryParse => 'Reintentar el análisis';

  @override
  String get projectTaxonSupportedInputs => 'Entradas compatibles:';

  @override
  String get projectTaxonSupportedFormats =>
      'CSV (.csv), TSV (.tsv), Excel (.xlsx), QR de taxón de NAHPU';

  @override
  String get projectReadingFile => 'Leyendo archivo…';

  @override
  String get projectQrUnavailable =>
      'El escaneo de QR no está disponible en esta plataforma.';

  @override
  String get projectClearImport => 'Borrar importación';

  @override
  String get projectWizardWelcome => 'Bienvenida';

  @override
  String get projectWizardMainTaxon => 'Taxón principal';

  @override
  String get projectWizardReview => 'Revisión';

  @override
  String get projectWizardCreateOnce =>
      'Cree una vez para todos los dispositivos';

  @override
  String get projectWizardCreateOnceBody =>
      'Cree un proyecto nuevo solo en el primer dispositivo. Use QR/Importar JSON para transferir la información y la identidad del proyecto.';

  @override
  String get projectWizardCreateNew => 'Crear proyecto nuevo';

  @override
  String get projectScanQr => 'Escanear QR del proyecto';

  @override
  String get projectWizardMainTaxonBody =>
      'Elija el taxón principal para adaptar los formularios de especímenes y los valores predeterminados de NAHPU en este dispositivo. Un proyecto puede contener varios grupos taxonómicos, y puede cambiar el taxón principal más tarde en Configuración.';

  @override
  String get projectWizardFieldIdsTitle => 'Configurar los ID de campo';

  @override
  String projectWizardFieldIdsLoadError(String error) {
    return 'No se pudo cargar la configuración de ID de campo: $error';
  }

  @override
  String get projectWizardFieldIdsBody =>
      'Elija cómo se generan los ID de campo de los especímenes. Puede cambiarlo más tarde en Configuración > Catálogos > Especímenes.';

  @override
  String get projectWizardCatalogerRequired =>
      'Se requiere un catalogador registrado';

  @override
  String get projectWizardCatalogerRequiredBody =>
      'A continuación, elija un catalogador elegible o cree uno con iniciales y un número de campo personal actual.';

  @override
  String projectWizardPrefixHint(String example) {
    return 'p. ej., $example';
  }

  @override
  String get projectCurrentCatalogNumber => 'Número de catálogo actual';

  @override
  String get projectWizardNextNumberHint => 'Ingrese el siguiente número';

  @override
  String get projectWizardCurrentNumberRequired => 'Ingrese un número actual';

  @override
  String get projectWizardAutoIncrementCatalog =>
      'Incrementar automáticamente el número de catálogo';

  @override
  String projectWizardPersonnelLoadError(String error) {
    return 'No se pudo cargar el personal: $error';
  }

  @override
  String get projectWizardCreateCataloger => 'Crear un catalogador';

  @override
  String get projectWizardChooseCataloger => 'Elegir un catalogador';

  @override
  String get projectWizardNoCatalogerBody =>
      'No hay ningún catalogador registrado disponible. Cree uno ahora; la función y el registro del número de campo personal se completan automáticamente.';

  @override
  String get projectWizardCreateAnotherCatalogerBody =>
      'Cree otro catalogador. La función y el registro del número de campo personal se completan automáticamente.';

  @override
  String get projectWizardChooseCatalogerBody =>
      'Elija el catalogador cuyas iniciales y número de campo actual se usarán en los ID de campo del personal.';

  @override
  String get projectWizardCatalogerLabel => 'Catalogador*';

  @override
  String get projectWizardCatalogerNameHint =>
      'Ingrese el nombre del catalogador';

  @override
  String get projectWizardCurrentFieldNumberLabel => 'Número de campo actual*';

  @override
  String get projectWizardCurrentFieldNumberHint =>
      'Ingrese el siguiente número de campo personal';

  @override
  String get projectWizardCatalogerRoleSet =>
      'Función en el cuidado de especímenes: Catalogador';

  @override
  String get projectWizardFieldNumberEnabled =>
      'Registro del número de campo personal activado';

  @override
  String get projectWizardReviewImported => 'Revisar proyecto importado';

  @override
  String get projectWizardReviewProject => 'Revisar proyecto';

  @override
  String get projectWizardImportNote =>
      'Esta transferencia de información del proyecto conserva el UUID de origen. No incluye registros, personal, taxones ni la configuración del dispositivo.';

  @override
  String get projectName => 'Nombre del proyecto';

  @override
  String get projectFieldIdPrefix => 'Prefijo del ID de campo';

  @override
  String get projectFieldIdSuffix => 'Sufijo del ID de campo';

  @override
  String get projectWizardExistingCataloger =>
      'Catalogador existente seleccionado';

  @override
  String get projectWizardNotConfigured => 'No configurado';

  @override
  String get projectWizardDeviceSetup => 'Configuración del dispositivo';

  @override
  String get projectWizardKeepCurrent => 'Mantener la configuración actual';

  @override
  String get projectWizardFieldIdMode => 'Modo de ID de campo';

  @override
  String get projectWizardAutoIncrement => 'Incremento automático';

  @override
  String get projectOn => 'Activado';

  @override
  String get projectOff => 'Desactivado';

  @override
  String get projectWizardTaxonomyReadiness => 'Preparación de la taxonomía';

  @override
  String get projectWizardTaxaCountUnavailable =>
      'El conteo de taxones disponibles no está disponible.';

  @override
  String projectWizardAvailableTaxa(int count) {
    return 'Taxones disponibles: $count';
  }

  @override
  String get projectWizardNoTaxa => 'No hay taxones disponibles';

  @override
  String get projectWizardNoTaxaBody =>
      'Agregue o importe taxones en el Registro de taxones antes de crear un nuevo registro de espécimen.';

  @override
  String get projectWizardSkip => 'Omitir';

  @override
  String get projectWizardCreating => 'Creando…';

  @override
  String get projectWizardCatalogerNameRequired =>
      'El nombre del catalogador es obligatorio';

  @override
  String get projectWizardNameTooShort => 'El nombre es demasiado corto';

  @override
  String get projectWizardInvalidCharacters => 'Caracteres no válidos';

  @override
  String get projectWizardInitialsRequired => 'Las iniciales son obligatorias';

  @override
  String get projectWizardInitialsTooShort =>
      'Las iniciales son demasiado cortas';

  @override
  String get projectWizardFieldNumberRequired =>
      'El número de campo actual es obligatorio';

  @override
  String get projectWizardInvalidFieldNumber => 'Número de campo no válido';

  @override
  String get projectInvalidQr => 'Código QR del proyecto no válido.';

  @override
  String get projectNameRequired => 'El nombre del proyecto es obligatorio';

  @override
  String get projectNameTooShort => 'El nombre del proyecto es demasiado corto';

  @override
  String get projectNameTooLong => 'El nombre del proyecto es demasiado largo';

  @override
  String get projectNameInvalid => 'El nombre del proyecto no es válido';

  @override
  String get projectNameExists => 'Ya existe un proyecto con ese nombre';

  @override
  String get projectUuidExists =>
      'Ya existe un proyecto con este UUID en este dispositivo.';

  @override
  String projectCreateFailed(String error) {
    return 'No se pudo crear el proyecto: $error';
  }

  @override
  String get projectWizardChooseExisting => 'Elegir existente';

  @override
  String get projectWizardCreateNewCataloger => 'Crear nuevo';

  @override
  String projectUuidValue(String uuid) {
    return 'UUID del proyecto: $uuid';
  }

  @override
  String get projectImportInfoJson =>
      'Importar JSON de información del proyecto';

  @override
  String get projectTransferProjectInfo => 'Información del proyecto';

  @override
  String get projectTransferTaxonomy => 'Taxonomía';

  @override
  String get projectTransferSites => 'Sitios';

  @override
  String get projectTransferEvents => 'Eventos';

  @override
  String get projectTransferSpecimens => 'Especímenes';

  @override
  String get projectTransferNarratives => 'Narrativas';

  @override
  String get projectTransferCustomFields => 'Campos personalizados';

  @override
  String get projectTransferMedia => 'Multimedia';

  @override
  String get projectTransferKeepCurrent => 'Mantener actual';

  @override
  String get projectTransferUseImported => 'Usar importado';

  @override
  String get projectTransferImportAsNew => 'Importar como nuevo';

  @override
  String get projectExporting => 'Exportando proyecto';

  @override
  String get projectExportingHint =>
      'Los proyectos con muchas fotos pueden tardar varios minutos. Mantenga NAHPU abierto hasta que termine.';

  @override
  String get projectExportAnother => 'Exportar otro';

  @override
  String get projectExportCancelTitle => '¿Cancelar la exportación?';

  @override
  String get projectExportCancelBody =>
      'La exportación sigue en curso. Si sale ahora, se cancelará y no se guardará ningún archivo.';

  @override
  String get projectExportKeepExporting => 'Seguir exportando';

  @override
  String get projectExportCancel => 'Cancelar exportación';

  @override
  String projectOpenFolderFailed(String error) {
    return 'No se pudo abrir la carpeta: $error';
  }

  @override
  String projectSaveCopyFailed(String error) {
    return 'No se pudo guardar una copia: $error';
  }

  @override
  String get projectExportArchiveTitle => 'Archivo de respaldo y transferencia';

  @override
  String get projectExportArchiveBody =>
      'Use este archivo como respaldo del proyecto o para transferirlo a otro dispositivo y combinarlo allí.';

  @override
  String get projectExportLight => 'Exportación ligera';

  @override
  String get projectExportLightBody =>
      'Exporte el proyecto sin archivos multimedia para cargas con internet limitado. Use TAR.GZ o ZIP para un respaldo completo del proyecto.';

  @override
  String get projectExportArchiveContents => 'Contenido del archivo';

  @override
  String get projectExportExcluded => 'Excluido';

  @override
  String get projectExportMediaSize => 'Tamaño de multimedia';

  @override
  String projectWarningCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count advertencias',
      one: '1 advertencia',
    );
    return '$_temp0';
  }

  @override
  String get projectTransferFileAndSafety => 'Archivo y seguridad';

  @override
  String get projectTransferReviewImport => 'Revisar e importar';

  @override
  String get projectTransferReviewMerge => 'Revisar y combinar';

  @override
  String get projectTransferResult => 'Resultado';

  @override
  String get projectTransferChooseFirst =>
      'Elija primero una transferencia de proyecto';

  @override
  String get projectTransferChooseFirstBody =>
      'Vuelva a Archivo y seguridad para seleccionar un archivo.';

  @override
  String get projectTransferChooseTitle =>
      'Elija una transferencia de proyecto de NAHPU';

  @override
  String get projectTransferChooseBody =>
      'Las transferencias de proyecto pueden ser JSON.GZ, ZIP o TAR.GZ. JSON.GZ solo contiene registros. ZIP y TAR.GZ incluyen multimedia.';

  @override
  String get projectTransferReadingArchive => 'Leyendo archivo';

  @override
  String get projectTransferReadingArchiveHint =>
      'Las transferencias con multimedia pueden tardar varios minutos en descomprimirse. Mantenga NAHPU abierto.';

  @override
  String get projectTransferChooseArchive => 'Elegir archivo';

  @override
  String get projectTransferChooseAnotherArchive => 'Elegir otro archivo';

  @override
  String get projectTransferBackupBeforeImport => 'Respalde antes de importar';

  @override
  String get projectTransferBackupBeforeMerge => 'Respalde antes de combinar';

  @override
  String get projectTransferBackupBody =>
      'Un respaldo de la base de datos le da un punto de recuperación si los cambios importados no son los esperados.';

  @override
  String get projectTransferBackupNow => 'Respaldar ahora';

  @override
  String get projectTransferBackupAckImport =>
      'Entiendo que debo tener un respaldo antes de importar.';

  @override
  String get projectTransferBackupAckMerge =>
      'Entiendo que debo tener un respaldo antes de combinar.';

  @override
  String get projectTransferNewIdentity => 'Nueva identidad del proyecto';

  @override
  String projectTransferArchiveUuid(String uuid) {
    return 'UUID del archivo: $uuid';
  }

  @override
  String get projectTransferDestinationName => 'Nombre del proyecto de destino';

  @override
  String get projectTransferDestinationNameHelper =>
      'Asigna el nombre del nuevo proyecto en este dispositivo. El archivo no cambia.';

  @override
  String projectTransferNameConflict(String name) {
    return 'Ya existe un proyecto llamado «$name». Elija otro nombre. Si son copias del mismo proyecto, cancele y use Combinar proyecto.';
  }

  @override
  String get projectTransferAlreadyExists => 'Este proyecto ya existe';

  @override
  String get projectTransferAlreadyExistsBody =>
      'Los UUID coincidentes identifican el mismo proyecto. La importación está bloqueada. Combine este archivo con el proyecto existente.';

  @override
  String get projectTransferOpenMerge => 'Abrir Combinar proyecto';

  @override
  String get projectTransferUuidMismatch => 'El UUID del proyecto no coincide';

  @override
  String projectTransferUuidMismatchBody(String archive, String active) {
    return 'Archivo: $archive\nProyecto activo: $active';
  }

  @override
  String get projectTransferForceMerge =>
      'Forzar la combinación con el proyecto activo';

  @override
  String get projectTransferForceMergeBody =>
      'Los registros importados del proyecto usarán el UUID del proyecto activo. Los conflictos seguirán requiriendo las opciones que se muestran después.';

  @override
  String projectTransferTypeToConfirm(String name) {
    return 'Escriba «$name» para confirmar';
  }

  @override
  String get projectCatalogNumberPrefix => 'Prefijo del número de catálogo';

  @override
  String get projectCatalogNumberSuffix => 'Sufijo del número de catálogo';

  @override
  String get projectTransferProjectInfoBody =>
      'Los valores actuales se mantienen de forma predeterminada. Seleccione valores importados individuales cuando quiera reemplazarlos.';

  @override
  String get projectTransferKeepAllCurrent => 'Mantener todos los actuales';

  @override
  String get projectTransferUseAllImported => 'Usar todos los importados';

  @override
  String get projectTransferReviewMatches =>
      'Revise las coincidencias antes de continuar. «Mantener actual» vincula las dependencias importadas al registro existente sin reemplazarlo.';

  @override
  String get projectTransferBulkTooltip =>
      'Aplicar una opción a todos los registros coincidentes';

  @override
  String projectTransferActionForAll(String action) {
    return '$action para todos';
  }

  @override
  String get projectTransferBulkAction => 'Acción en lote';

  @override
  String get projectTransferStatusNew => 'Nuevos';

  @override
  String get projectTransferStatusMatched => 'Coincidentes';

  @override
  String get projectTransferNeedsAttention => 'Requiere atención';

  @override
  String get projectTransferSkipped => 'Omitidos';

  @override
  String get projectTransferNoConflicts => 'Sin conflictos';

  @override
  String get projectTransferNoConflictsBody =>
      'Todos los registros de esta sección se pueden importar como nuevos.';

  @override
  String get projectTransferReviewBody =>
      'Todavía no se ha escrito nada. Los cambios en la base de datos se confirmarán juntos; un error los revierte todos.';

  @override
  String get projectTransferSourceProject => 'Proyecto de origen';

  @override
  String get projectTransferDestination => 'Destino';

  @override
  String get projectTransferUuidHandling => 'Manejo del UUID';

  @override
  String projectTransferNewUuid(String uuid) {
    return 'Nuevo UUID del proyecto: $uuid';
  }

  @override
  String get projectTransferForceMergeUuid =>
      'Forzar la combinación con el UUID activo';

  @override
  String get projectTransferMatchingUuid => 'UUID del proyecto coincidente';

  @override
  String get projectTransferConflicts => 'Conflictos';

  @override
  String get projectTransferMediaFiles => 'Archivos multimedia';

  @override
  String get projectTransferResolveConflicts =>
      'Resuelva los conflictos antes de combinar';

  @override
  String projectTransferDuplicateIdentifiers(String sections) {
    return 'Los identificadores duplicados aún necesitan una acción en $sections.';
  }

  @override
  String get projectTransferArchiveWarnings => 'Advertencias del archivo';

  @override
  String get projectTransferImportUnfinished => 'La importación no terminó';

  @override
  String get projectTransferMergeUnfinished => 'La combinación no terminó';

  @override
  String get projectTransferImportRetry =>
      'Vuelva a Revisar e importar e inténtelo de nuevo.';

  @override
  String get projectTransferMergeRetry =>
      'Vuelva a Revisar y combinar e inténtelo de nuevo.';

  @override
  String get projectTransferImported => 'Proyecto importado';

  @override
  String get projectTransferMerged => 'Datos del proyecto combinados';

  @override
  String get projectTransferCountImported => 'Importados';

  @override
  String get projectTransferCountMerged => 'Combinados';

  @override
  String get projectTransferCountUpdated => 'Actualizados';

  @override
  String get projectTransferSkippedOnConflict => 'Omitidos por conflicto';

  @override
  String get projectTransferMediaCopied => 'Multimedia copiado';

  @override
  String get projectTransferWarnings => 'Advertencias';

  @override
  String get projectTransferConflict => 'Conflicto';

  @override
  String get projectTransferCurrent => 'Actual';

  @override
  String get projectTransferConflictAction => 'Acción ante el conflicto';

  @override
  String get projectTransferChooseAction => 'Elija una acción';

  @override
  String get projectTransferChooseActionToContinue =>
      'Elija una acción para continuar';

  @override
  String get projectTransferNotSet => 'Sin definir';

  @override
  String get projectTransferNoDetails => 'Sin detalles';

  @override
  String get projectBatchSpecimenParts => 'Partes de especímenes';

  @override
  String get projectBatchNarrative => 'Narrativa';

  @override
  String get projectBatchModeUpdate => 'Actualizar registros existentes';

  @override
  String get projectBatchModeCreate => 'Importar registros nuevos';

  @override
  String get projectBatchHeaderAuto => 'Automático';

  @override
  String get projectBatchDarwinCore => 'Darwin Core';

  @override
  String get projectBatchHeaderNames => 'Nombres de columnas';

  @override
  String get projectBatchKeySpecimenUuid => 'UUID del espécimen';

  @override
  String get projectBatchKeyCatalogNumber => 'Número de catálogo';

  @override
  String get projectBatchKeyCatalogerFieldNumber =>
      'Catalogador y número de campo';

  @override
  String get projectBatchKeyTissueId => 'ID del tejido';

  @override
  String get projectBatchKeyBarcodeId => 'ID del código de barras';

  @override
  String get projectBatchKeySiteId => 'ID del sitio';

  @override
  String get projectBatchKeyEventId => 'ID del evento';

  @override
  String get projectBatchKeyNarrativeDate => 'Fecha de la narrativa';

  @override
  String get projectBatchStatusReady => 'Listo';

  @override
  String get projectBatchStatusMissingLink => 'Vínculo faltante';

  @override
  String get projectBatchStatusNoMatch => 'Sin coincidencia';

  @override
  String get projectBatchStatusAmbiguous => 'Varias coincidencias';

  @override
  String get projectBatchStatusExists => 'Ya está en el proyecto';

  @override
  String get projectBatchStatusDuplicateInFile => 'Repetido en el archivo';

  @override
  String get projectBatchStatusInvalid => 'Valores no válidos';

  @override
  String get projectBatchUpdateRecords => 'Actualizar registros';

  @override
  String get projectBatchImportRecords => 'Importar registros';

  @override
  String get projectBatchStepMode => 'Modo';

  @override
  String get projectBatchStepFile => 'Archivo';

  @override
  String get projectBatchStepColumns => 'Columnas';

  @override
  String get projectBatchStepGroups => 'Grupos';

  @override
  String get projectBatchUnsupportedFile =>
      'Elija un archivo CSV, TSV o Excel.';

  @override
  String get projectBatchModeTitle => '¿Qué desea hacer?';

  @override
  String get projectBatchModeBody =>
      'Traiga registros desde un archivo CSV, TSV o Excel. Las columnas pueden usar términos Darwin Core o sus propios nombres.';

  @override
  String get projectBatchModeCreateBody =>
      'Agregue un registro por fila. Los taxones, el personal, los sitios y los eventos se vinculan cuando ya están en el proyecto.';

  @override
  String get projectBatchModeUpdateBody =>
      'Asocie cada fila a un registro mediante una columna clave, como el número de catálogo, y escriba las demás columnas. Las celdas vacías no se modifican.';

  @override
  String get projectBatchRecords => 'Registros';

  @override
  String get projectBatchLinkedRecords => 'Registros vinculados';

  @override
  String get projectBatchLinkedRecordsBody =>
      'Cada fila puede describir un sitio, su evento de colecta, un espécimen y una parte. Las filas se agrupan en sitios y eventos, que puede revisar antes de importar.';

  @override
  String get projectBatchChooseFile => 'Elija un archivo';

  @override
  String get projectBatchChooseFileBody =>
      'La primera fila debe contener los nombres de las columnas. Cada fila posterior es un registro.';

  @override
  String get projectBatchSheet => 'Hoja';

  @override
  String projectBatchTableSize(int rows, int columns) {
    String _temp0 = intl.Intl.pluralLogic(
      rows,
      locale: localeName,
      other: '$rows filas',
      one: '1 fila',
    );
    String _temp1 = intl.Intl.pluralLogic(
      columns,
      locale: localeName,
      other: '$columns columnas',
      one: '1 columna',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get projectBatchMatchColumns => 'Asociar columnas';

  @override
  String projectBatchMatchColumnsBody(int mapped, int total) {
    return '$mapped de $total columnas coinciden con un campo. Cambie cualquier coincidencia u omita una columna. Sus cambios se recuerdan para archivos con las mismas columnas.';
  }

  @override
  String get projectBatchKeyColumn => 'Columna clave';

  @override
  String projectBatchKeyColumnMissing(String keys) {
    return 'Asocie una columna a uno de estos: $keys.';
  }

  @override
  String get projectBatchKeyColumnBody =>
      'Las filas actualizan el registro con el mismo valor.';

  @override
  String get projectBatchMatchRecordsBy => 'Asociar registros por';

  @override
  String get projectBatchNoValues => 'Sin valores';

  @override
  String get projectBatchNahpuField => 'Campo de NAHPU';

  @override
  String get projectBatchSkipColumn => 'Omitir columna';

  @override
  String projectBatchFieldInUse(String field) {
    return '$field (en uso)';
  }

  @override
  String get projectBatchNameMatch => 'Coincidencia de nombre';

  @override
  String projectBatchCloseMatch(int percent) {
    return 'Coincidencia cercana $percent %';
  }

  @override
  String get projectBatchSkippedByYou => 'Omitida por usted';

  @override
  String get projectBatchYourChoice => 'Su elección';

  @override
  String get projectBatchSearch => 'Buscar';

  @override
  String projectBatchLoadRecordsFailed(String error) {
    return 'No se pudieron cargar los registros: $error';
  }

  @override
  String get projectBatchNoMatchingRecords => 'No hay registros coincidentes.';

  @override
  String get projectBatchNoOtherGroup =>
      'No hay otro grupo con el cual combinar.';

  @override
  String get projectBatchMoveToNewGroup => 'Mover a un grupo nuevo';

  @override
  String get projectBatchCheckGroups => 'Revisar grupos';

  @override
  String get projectBatchCheckGroupsBody =>
      'Las filas que describen el mismo sitio o evento se agrupan. Vincule un grupo a un registro del proyecto, combine grupos que sean el mismo lugar o visita, o separe filas.';

  @override
  String projectBatchSitesCount(int count) {
    return 'Sitios ($count)';
  }

  @override
  String projectBatchEventsCount(int count) {
    return 'Eventos ($count)';
  }

  @override
  String projectBatchSpecimensCount(int count) {
    return 'Especímenes ($count)';
  }

  @override
  String get projectBatchNoSiteColumns => 'Ninguna columna describe un sitio.';

  @override
  String get projectBatchNoEventColumns =>
      'Ninguna columna describe un evento.';

  @override
  String get projectBatchNoSpecimenColumns =>
      'Ninguna columna describe un espécimen.';

  @override
  String get projectBatchNewSite => 'Sitio nuevo';

  @override
  String projectBatchEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eventos',
      one: '1 evento',
    );
    return '$_temp0';
  }

  @override
  String projectBatchSpecimenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count especímenes',
      one: '1 espécimen',
    );
    return '$_temp0';
  }

  @override
  String projectBatchPartCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partes',
      one: '1 parte',
    );
    return '$_temp0';
  }

  @override
  String get projectBatchSetSiteId => 'Definir ID del sitio';

  @override
  String get projectBatchLinkSite => 'Vincular a un sitio existente';

  @override
  String get projectBatchMergeIntoSite => 'Combinar con el sitio';

  @override
  String get projectBatchMoveRowsToSite => 'Mover filas a un sitio nuevo';

  @override
  String projectBatchRow(String row) {
    return 'Fila $row';
  }

  @override
  String projectBatchRows(String rows) {
    return 'Filas $rows';
  }

  @override
  String projectBatchRowsMore(int count, String rows) {
    return 'Filas $rows y $count más';
  }

  @override
  String get projectBatchNoSite => 'Sin sitio';

  @override
  String get projectBatchNoEvent => 'Sin evento';

  @override
  String projectBatchEventLabel(String event) {
    return 'Evento: $event';
  }

  @override
  String get projectBatchSetIdSuffix => 'Definir sufijo del ID';

  @override
  String get projectBatchLinkEvent => 'Vincular a un evento existente';

  @override
  String get projectBatchSetEventIdSuffix => 'Definir sufijo del ID del evento';

  @override
  String get projectBatchMergeIntoEvent => 'Combinar con el evento';

  @override
  String get projectBatchMoveRowsToEvent => 'Mover filas a un evento nuevo';

  @override
  String get projectBatchExcluded => 'Excluido';

  @override
  String get projectBatchCheck => 'Revisar';

  @override
  String get projectBatchLinksToExisting => 'Vincula a existente';

  @override
  String get projectBatchChangeGroup => 'Cambiar grupo';

  @override
  String get projectBatchLinkExisting => 'Vincular a existente…';

  @override
  String get projectBatchCreateNew => 'Crear uno nuevo';

  @override
  String get projectBatchMergeInto => 'Combinar con…';

  @override
  String get projectBatchSplitRows => 'Separar filas…';

  @override
  String get projectBatchLinkedReviewBody =>
      'Primero se escriben los sitios, luego sus eventos y después los especímenes y sus partes.';

  @override
  String projectBatchSitesSummary(int created, int linked) {
    return 'Sitios: $created nuevos, $linked vinculados';
  }

  @override
  String projectBatchEventsSummary(int created, int linked) {
    return 'Eventos: $created nuevos, $linked vinculados';
  }

  @override
  String projectBatchSpecimensSummary(int count) {
    return 'Especímenes: $count';
  }

  @override
  String projectBatchPartsSummary(int count) {
    return 'Partes: $count';
  }

  @override
  String projectBatchRowsSkipped(int count) {
    return 'Filas omitidas: $count';
  }

  @override
  String get projectBatchImportSpecimensMissingLinks =>
      'Importar especímenes con vínculos faltantes';

  @override
  String get projectBatchImportSpecimensMissingLinksBody =>
      'El taxón o la persona queda vacío. Agréguelo primero al proyecto para vincularlo.';

  @override
  String projectBatchWritingRecords(int done, int total) {
    return 'Escribiendo $done de $total registros';
  }

  @override
  String projectBatchWritingRows(int done, int total) {
    return 'Escribiendo $done de $total filas';
  }

  @override
  String get projectBatchNoProblems => 'No se encontraron problemas.';

  @override
  String projectBatchMoreRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Y $count filas más.',
      one: 'Y 1 fila más.',
    );
    return '$_temp0';
  }

  @override
  String projectBatchSiteProblem(String site, String message) {
    return 'Sitio $site: $message';
  }

  @override
  String projectBatchSpecimenSkipped(String status) {
    return 'Espécimen omitido: $status.';
  }

  @override
  String get projectBatchExcludedRow => 'Excluida.';

  @override
  String get projectBatchDoneWithErrors => 'Listo, con errores';

  @override
  String projectBatchAddedSpecimensParts(int specimens, int parts) {
    String _temp0 = intl.Intl.pluralLogic(
      specimens,
      locale: localeName,
      other: '$specimens especímenes',
      one: '1 espécimen',
    );
    String _temp1 = intl.Intl.pluralLogic(
      parts,
      locale: localeName,
      other: '$parts partes',
      one: '1 parte',
    );
    return 'Se agregaron $_temp0 y $_temp1.';
  }

  @override
  String projectBatchRowsWithErrors(int count) {
    return 'Filas con errores: $count';
  }

  @override
  String get projectBatchOpenSpecimenTable =>
      'Abrir la tabla de registros de especímenes';

  @override
  String projectBatchUpdatedRecords(int count, String records) {
    return 'Se actualizaron $count $records.';
  }

  @override
  String projectBatchAddedRecords(int count, String records) {
    return 'Se agregaron $count $records.';
  }

  @override
  String projectBatchUpdatedCount(int count) {
    return 'Actualizados: $count';
  }

  @override
  String projectBatchAddedCount(int count) {
    return 'Agregados: $count';
  }

  @override
  String projectBatchSkippedInReview(int count) {
    return 'Omitidos en la revisión: $count';
  }

  @override
  String projectBatchFailedCount(int count) {
    return 'Con error: $count';
  }

  @override
  String projectBatchOpenTable(String records) {
    return 'Abrir la tabla de $records';
  }

  @override
  String projectBatchReviewUpdate(int count, int total, String records) {
    return 'Esto actualizará $count de $total $records. Se omiten las filas con problemas.';
  }

  @override
  String projectBatchReviewAdd(int count, int total, String records) {
    return 'Esto agregará $count de $total $records. Se omiten las filas con problemas.';
  }

  @override
  String get projectBatchImportRowsMissingLinks =>
      'Importar filas con vínculos faltantes';

  @override
  String get projectBatchImportRowsMissingLinksBody =>
      'El taxón, la persona, el sitio o el evento queda vacío. Agréguelo primero al proyecto para vincularlo.';

  @override
  String get projectStatsPartQuantity => 'Cantidad de partes';

  @override
  String get projectStatsQuantity => 'Cantidad';

  @override
  String get projectStatsSite => 'Sitio';

  @override
  String get projectStatsDate => 'Fecha';

  @override
  String get projectStatsMethod => 'Método';

  @override
  String get projectStatsSex => 'Sexo';

  @override
  String get projectStatsLifeStage => 'Etapa de vida';

  @override
  String get projectStatsPartType => 'Tipo de parte';

  @override
  String get projectStatsTreatment => 'Tratamiento';

  @override
  String projectStatsTitle(String measure, String category) {
    return '$measure por $category';
  }

  @override
  String projectStatsTitleWithBreakdown(
    String measure,
    String category,
    String breakdown,
  ) {
    return '$measure por $category y $breakdown';
  }

  @override
  String projectStatsTitleAtSite(String title, String site) {
    return '$title en $site';
  }

  @override
  String projectStatsTitleForSpecies(String title, String species) {
    return '$title de $species';
  }

  @override
  String get projectStatsCoordinatesBySpecies => 'Coordenadas por especie';

  @override
  String get projectStatsSpatialSpecimensTitle =>
      'Conteo de especímenes por coordenadas del sitio';

  @override
  String get projectStatsSpatialSpeciesTitle =>
      'Conteo de especies por coordenadas del sitio';

  @override
  String get projectStatsSpatialFamiliesTitle =>
      'Conteo de familias por coordenadas del sitio';

  @override
  String get projectStatsSpatialSelectedSpeciesTitle =>
      'Conteo de la especie seleccionada por coordenadas';

  @override
  String get projectStatsCountSpecimens => 'especímenes';

  @override
  String get projectStatsCountSpecies => 'especies';

  @override
  String get projectStatsCountFamilies => 'familias';

  @override
  String get projectStatsClasses => 'Clases';

  @override
  String get projectStatsOrders => 'Órdenes';

  @override
  String get projectStatsFamilies => 'Familias';

  @override
  String get projectStatsGenera => 'Géneros';

  @override
  String get projectStatsSpecimenMedia => 'Multimedia de especímenes';

  @override
  String get projectStatsSiteMedia => 'Multimedia de sitios';

  @override
  String get projectStatsEventMedia => 'Multimedia de eventos';

  @override
  String get projectStatsNarrativeMedia => 'Multimedia de narrativas';

  @override
  String get projectStatsRecordedSites => 'Sitios registrados';

  @override
  String get projectStatsSampledSites => 'Sitios muestreados';

  @override
  String get projectStatsCaptureDays => 'Días de captura';

  @override
  String get projectStatsProjectDays => 'Días de proyecto';

  @override
  String get projectStatsRecordedElevation => 'Elevación registrada';

  @override
  String get projectStatsSampledElevation => 'Elevación muestreada';

  @override
  String get projectStatsNotRecorded => 'No registrado';

  @override
  String get projectStatsRecordStatistics => 'Estadísticas de registros';

  @override
  String get projectStatsTopSpecies => 'Especies más registradas';

  @override
  String get projectStatsRecordCounts => 'Conteo de registros';

  @override
  String get projectStatsShowRecordCounts => 'Mostrar conteo de registros';

  @override
  String get projectStatsShowTopSpecies => 'Mostrar especies más registradas';

  @override
  String get projectStatsExploreMore => 'Explorar más estadísticas';

  @override
  String projectStatsRecordLoadError(String error) {
    return 'No se pudieron cargar las estadísticas de registros: $error';
  }

  @override
  String get projectStatsSummary => 'Resumen';

  @override
  String get projectStatsExplore => 'Explorar';

  @override
  String get projectStatsTotalAllProjects => 'Total de todos los proyectos';

  @override
  String get projectStatsGroupBy => 'Agrupar por';

  @override
  String get projectStatsSelectSite => 'Seleccione un sitio';

  @override
  String get projectStatsAllSites => 'Todos los sitios';

  @override
  String get projectStatsSelectSpecies => 'Seleccione una especie';

  @override
  String get projectStatsAllSpecies => 'Todas las especies';

  @override
  String get projectStatsChart => 'Gráfico';

  @override
  String get projectStatsTable => 'Tabla';

  @override
  String get projectStatsRecordSummary => 'Resumen de registros';

  @override
  String get projectStatsTaxonomicBreakdown => 'Desglose taxonómico';

  @override
  String get projectStatsMediaBreakdown => 'Desglose de multimedia';

  @override
  String get projectStatsPerProject => 'Por proyecto';

  @override
  String get projectStatsNoProjects => 'Aún no hay proyectos.';

  @override
  String projectStatsProjectLoadError(String error) {
    return 'No se pudieron cargar las estadísticas del proyecto: $error';
  }

  @override
  String get projectStatsViewDetails => 'Ver detalles';

  @override
  String get projectStatsBreakDownBy => 'Desglosar por';

  @override
  String projectStatsLoadError(String error) {
    return 'No se pudieron cargar las estadísticas: $error';
  }

  @override
  String get projectStatsSpecimensBySpecies => 'Especímenes por especie';

  @override
  String get projectStatsSpecimensByFamily => 'Especímenes por familia';

  @override
  String get projectStatsSpecimensBySite => 'Especímenes por sitio';

  @override
  String get projectStatsSpecimensByDate => 'Especímenes por fecha';

  @override
  String get projectStatsSpecimensByMethod => 'Especímenes por método';

  @override
  String get projectStatsSpecimensBySex => 'Especímenes por sexo';

  @override
  String get projectStatsPartQuantityByType => 'Cantidad de partes por tipo';

  @override
  String get projectStatsPartQuantityByTreatment =>
      'Cantidad de partes por tratamiento';

  @override
  String get projectStatsCounts => 'Conteos';

  @override
  String get projectStatsSpatial => 'Espacial';

  @override
  String get projectStatsNoData => 'No hay datos para mostrar';

  @override
  String projectStatsTapToView(String label) {
    return '$label\nToque para ver los registros';
  }

  @override
  String get projectStatsShowBarChart => 'Mostrar gráfico de barras';

  @override
  String get projectStatsShowPieChart => 'Mostrar gráfico circular';

  @override
  String get projectStatsClearSelection => 'Borrar selección';

  @override
  String projectStatsChoicesLoadError(String error) {
    return 'No se pudieron cargar las opciones: $error';
  }

  @override
  String get projectStatsNoMatchingChoices => 'No hay opciones coincidentes';

  @override
  String get projectStatsNoRecordsInGroup => 'No hay registros en este grupo.';

  @override
  String get projectStatsShow => 'Mostrar';

  @override
  String projectStatsSpeciesCountsByCoordinates(String species) {
    return 'Conteo de $species por coordenadas';
  }

  @override
  String get projectStatsMap => 'Mapa';

  @override
  String projectStatsSpatialLoadError(String error) {
    return 'No se pudieron cargar las estadísticas espaciales: $error';
  }

  @override
  String get projectStatsNoSpecimenCoords =>
      'No hay especímenes asignados a las coordenadas del proyecto.';

  @override
  String get projectStatsNoSpeciesCoords =>
      'No hay especies asociadas a las coordenadas del proyecto.';

  @override
  String get projectStatsNoFamilyCoords =>
      'No hay familias asociadas a las coordenadas del proyecto.';

  @override
  String get projectStatsNoSelectedSpeciesCoords =>
      'No hay especímenes de la especie seleccionada asignados a las coordenadas del proyecto.';

  @override
  String projectStatsNoSpeciesCoordsFor(String species) {
    return 'No hay especímenes de $species asignados a las coordenadas del proyecto.';
  }

  @override
  String projectStatsCoordinateLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Coordenadas',
      one: 'Coordenada',
    );
    return '$_temp0';
  }

  @override
  String projectStatsMeanPerCoordinate(String counted) {
    return 'Promedio de $counted por coordenada';
  }

  @override
  String get projectStatsTopCoordinate => 'Coordenada principal';

  @override
  String projectStatsTopValue(String name) {
    return 'Principal: $name';
  }

  @override
  String projectStatsCategoryCount(int count, String category) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Categorías ($category)',
      one: 'Categoría ($category)',
    );
    return '$_temp0';
  }

  @override
  String projectStatsMeanPerCategory(String counted) {
    return 'Promedio de $counted por categoría';
  }

  @override
  String get projectStatsTopCategory => 'Categoría principal';

  @override
  String get projectStatsTopCategoryShare =>
      'Proporción de la categoría principal';

  @override
  String projectStatsTotalCount(String value) {
    return 'Conteo total: $value';
  }

  @override
  String get projectStatsElevation => 'Elevación';

  @override
  String get projectStatsSelectSpeciesPrompt =>
      'Seleccione una especie para ver la abundancia por coordenada.';

  @override
  String get projectStatsCollapseLegend => 'Contraer la leyenda del mapa';

  @override
  String get projectStatsExpandLegend => 'Expandir la leyenda del mapa';

  @override
  String get projectStatsLegend => 'Leyenda';

  @override
  String get projectStatsLegendCircle =>
      'Cada círculo representa\nuna coordenada';

  @override
  String get projectStatsLegendGrouped =>
      'Sitios agrupados,\nacerque para separar';

  @override
  String projectStatsUnmappedRecords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count registros aparecen en la tabla, pero no se pueden mapear porque falta la latitud o la longitud o no es válida.',
      one:
          '1 registro aparece en la tabla, pero no se puede mapear porque falta la latitud o la longitud o no es válida.',
    );
    return '$_temp0';
  }

  @override
  String get projectStatsSpatialMap => 'Mapa de estadísticas espaciales';

  @override
  String get projectStatsMapLayers => 'Capas del mapa';

  @override
  String get projectStatsViewFullScreen => 'Ver el mapa en pantalla completa';

  @override
  String get projectStatsNaturalEarthError =>
      'No se pudo cargar el mapa sin conexión Natural Earth.';

  @override
  String get projectStatsNoValidCoordinates =>
      'No hay coordenadas válidas para mapear.';

  @override
  String projectStatsMapPrepareError(String error) {
    return 'No se pudo preparar el mapa: $error';
  }

  @override
  String get projectStatsZoomIn => 'Acercar';

  @override
  String get projectStatsZoomOut => 'Alejar';

  @override
  String get projectStatsCenterMap => 'Centrar el mapa en las estadísticas';

  @override
  String projectStatsSiteCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sitios',
      one: '1 sitio',
    );
    return '$_temp0';
  }

  @override
  String get projectStatsExportTable => 'Exportar tabla';

  @override
  String get projectStatsColumnName => 'Nombre';

  @override
  String get projectStatsColumnLocality => 'Localidad';

  @override
  String get projectStatsColumnDecimalLatitude => 'Latitud decimal';

  @override
  String get projectStatsColumnDecimalLongitude => 'Longitud decimal';

  @override
  String get projectStatsColumnElevation => 'Elevación (m)';

  @override
  String get projectStatsColumnDatum => 'Datum';

  @override
  String get projectStatsColumnUncertainty => 'Incertidumbre (m)';

  @override
  String get projectStatsColumnGpsUnit => 'Unidad GPS';

  @override
  String get projectStatsColumnLatitude => 'Latitud';

  @override
  String get projectStatsColumnLongitude => 'Longitud';

  @override
  String get projectStatsColumnCount => 'Conteo';

  @override
  String get projectStatsColumnPercent => 'Porcentaje';

  @override
  String get projectStatsColumnCategory => 'Categoría';

  @override
  String get projectStatsViewRecords => 'Ver registros';

  @override
  String get projectStatsExportStatisticsTable =>
      'Exportar tabla de estadísticas';

  @override
  String get projectStatsExportSpatialTable =>
      'Exportar tabla de estadísticas espaciales';

  @override
  String projectStatsExportError(String error) {
    return 'No se pudieron exportar las estadísticas: $error';
  }

  @override
  String get projectStatsExportComplete => 'Exportación completada';

  @override
  String projectStatsShareError(String error) {
    return 'No se pudieron compartir las estadísticas: $error';
  }

  @override
  String get projectTissueMuseumPermanent => 'Colección permanente del museo';

  @override
  String get projectTissueMuseumLoan => 'Préstamo del museo';

  @override
  String get projectTissueIdOrBarcode => 'ID del tejido o código de barras';

  @override
  String get projectTissueFillRows => 'Filas, de izquierda a derecha';

  @override
  String get projectTissueFillColumns => 'Columnas, de arriba abajo';

  @override
  String get projectTissueFillSerpentine => 'Filas en serpentina';

  @override
  String get projectTissueEntryScan => 'Escaneo';

  @override
  String get projectTissueEntryWorkList => 'Lista de trabajo';

  @override
  String get projectTissueTitle => 'Curaduría de especímenes';

  @override
  String projectTissueFilledCount(int filled, int capacity) {
    return '$filled / $capacity ocupadas';
  }

  @override
  String get projectTissueNextCell => 'Siguiente celda';

  @override
  String get projectTissueFull => 'Llena';

  @override
  String get projectTissueNextBox => 'Siguiente caja';

  @override
  String projectTissueCellFilled(String cell) {
    return '$cell · ocupada';
  }

  @override
  String get projectTissueFilled => 'Ocupada';

  @override
  String get projectTissueNext => 'Siguiente';

  @override
  String get projectTissueTapEmptyCell =>
      'Toque una celda vacía para ir a ella';

  @override
  String get projectTissueScanTubes => 'Escanear tubos';

  @override
  String get projectTissueCameraUnavailable =>
      'El escaneo con la cámara no está disponible. Use el campo de escaneo.';

  @override
  String get projectTissueCameraError =>
      'No se pudo usar la cámara. Vuelva a intentarlo o use el campo de escaneo.';

  @override
  String get projectTissueSessionLog => 'Registro de la sesión';

  @override
  String projectTissueSessionLogCount(int count) {
    return 'Registro de la sesión ($count)';
  }

  @override
  String get projectTissueSessionLogEmpty =>
      'Los tubos revisados aparecen aquí.';

  @override
  String projectTissueSeveralMatches(String code) {
    return 'Varias partes coinciden con $code';
  }

  @override
  String projectTissueCount(String count) {
    return 'Cantidad $count';
  }

  @override
  String projectTissueAt(String location) {
    return 'En $location';
  }

  @override
  String get projectTissueFindTubes => 'Buscar tubos';

  @override
  String get projectTissueType => 'Tipo de tejido';

  @override
  String get projectTissuePreservation => 'Preservación';

  @override
  String get projectTissueUpdateField => 'Campo a actualizar';

  @override
  String get projectTissueField => 'Campo';

  @override
  String get projectTissueValue => 'Valor';

  @override
  String get projectTissueMuseumCode => 'Código del museo';

  @override
  String get projectTissueBoxSize => 'Tamaño de la caja';

  @override
  String get projectTissueNumbering => 'Numeración';

  @override
  String get projectTissueFillOrder => 'Orden de llenado';

  @override
  String get projectTissueBoxLabel => 'Etiqueta de la caja';

  @override
  String get projectTissueBoxHint => 'Caja';

  @override
  String get projectTissueBoxNumber => 'Número de caja';

  @override
  String get projectTissueOverwrite => 'Sobrescribir valores existentes';

  @override
  String get projectTissueOverwriteBody =>
      'Reemplaza una ubicación guardada o un valor de campo distinto';

  @override
  String get projectTissueAny => 'Cualquiera';

  @override
  String get projectTissueScanTube => 'Escanear tubo';

  @override
  String get projectTissueScanHint => 'Escanee o escriba y presione Intro';

  @override
  String get projectTissueScanWithCamera => 'Escanear con la cámara';

  @override
  String get projectTissueUndo => 'Deshacer';

  @override
  String get projectTissueReady => 'Listo. Escanee el primer tubo.';

  @override
  String get projectTissueWorkListEmpty =>
      'Ninguna parte sin ubicar coincide con los filtros de tipo de tejido y preservación.';

  @override
  String projectTissueRemaining(int count) {
    return 'Siguiente · quedan $count';
  }

  @override
  String get projectTissuePlace => 'Ubicar';
}
