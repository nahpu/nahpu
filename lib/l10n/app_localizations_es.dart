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
  String get homeMoreActions => 'Más';

  @override
  String get homeGallery => 'Galería';

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
  String get drawerMediaGallery => 'Galería multimedia';

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
  String get settingsLanguageHelpTranslate => 'Ayude a traducir NAHPU';

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
  String get presetsRecordTypeParasites => 'Parásitos';

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
  String presetsPreviewParasites(int count) {
    return 'Vista previa de parásitos ($count seleccionados)';
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
  String get presetsPreviewSelectParasites =>
      'Seleccione parásitos para la vista previa';

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
  String documentParasitesLoadError(String error) {
    return 'No se pudieron cargar los parásitos: $error';
  }

  @override
  String get documentParasitesSearch =>
      'Buscar parásitos o números de especímenes';

  @override
  String documentParasitesSummary(int shown, int total, int selected) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total parásitos',
      one: '1 parásito',
    );
    return 'Mostrando $shown de $_temp0 · Seleccionados: $selected';
  }

  @override
  String documentParasitesSummaryHidden(
    int shown,
    int total,
    int selected,
    int hidden,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total parásitos',
      one: '1 parásito',
    );
    return 'Mostrando $shown de $_temp0 · Seleccionados: $selected ($hidden ocultos)';
  }

  @override
  String get documentParasitesEmpty => 'No se encontraron parásitos';

  @override
  String documentParasiteFallbackTitle(String id) {
    return 'Parásito $id';
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
  String get documentSelectionParasites => 'Selección de parásitos';

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
  String get documentSelectParasites => 'Seleccionar parásitos';

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
  String get projectEditTools => 'Editar lista';

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
  String get projectBatchParasites => 'Parásitos';

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
  String get projectBatchKeyParasiteId => 'ID del parásito';

  @override
  String get projectBatchKeyParasiteUuid => 'UUID del parásito';

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
  String projectBatchParasiteCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parásitos',
      one: '1 parásito',
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
  String projectBatchParasitesSummary(int count) {
    return 'Parásitos: $count';
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
  String get projectStatsParasiteTaxon => 'Taxón del parásito';

  @override
  String get projectStatsParasiteCategory => 'Categoría';

  @override
  String get projectStatsAnatomicalLocation => 'Ubicación anatómica';

  @override
  String get projectStatsHostSpecies => 'Especie hospedera';

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
  String get projectStatsNetwork => 'Red';

  @override
  String get projectStatsNetworkTitle => 'Registros vinculados por especímenes';

  @override
  String get projectStatsNetworkHint =>
      'Toca un registro para ver qué se vincula con él.';

  @override
  String get projectStatsNetworkRadial => 'Radial';

  @override
  String get projectStatsNetworkLayered => 'Por capas';

  @override
  String get projectStatsNetworkStartFrom => 'Empezar desde';

  @override
  String get projectStatsNetworkColumns => 'Columnas';

  @override
  String get projectStatsNetworkFields => 'Campos';

  @override
  String projectStatsNetworkMaxColumns(int count) {
    return 'Hasta $count columnas';
  }

  @override
  String get projectStatsNetworkYear => 'Año';

  @override
  String get projectStatsNetworkLinked => 'Registros vinculados';

  @override
  String get projectStatsNetworkFit => 'Ajustar a la vista';

  @override
  String get projectStatsNetworkReset => 'Restablecer';

  @override
  String get projectStatsNetworkFullScreen => 'Ver la red en pantalla completa';

  @override
  String projectStatsNetworkLoadError(String error) {
    return 'No se pudo cargar la red: $error';
  }

  @override
  String get projectStatsNetworkEmpty =>
      'Aún no hay especímenes para vincular.';

  @override
  String projectStatsNetworkMore(int count) {
    return '+$count más';
  }

  @override
  String projectStatsNetworkSpecimens(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count especímenes',
      one: '1 espécimen',
    );
    return '$_temp0';
  }

  @override
  String projectStatsNetworkShared(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count especímenes compartidos',
      one: '1 espécimen compartido',
    );
    return '$_temp0';
  }

  @override
  String projectStatsNetworkRecords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros',
      one: '1 registro',
    );
    return '$_temp0';
  }

  @override
  String get projectStatsNetworkShowLinks => 'Mostrar vínculos';

  @override
  String get projectStatsNetworkHideLinks => 'Ocultar vínculos';

  @override
  String get projectStatsNetworkShowMore => 'Mostrar más';

  @override
  String get projectStatsNetworkSites => 'Sitios';

  @override
  String get projectStatsNetworkEvents => 'Eventos';

  @override
  String get projectStatsNetworkSpecimenType => 'Especímenes';

  @override
  String get projectStatsNetworkTaxa => 'Especies';

  @override
  String get projectStatsNetworkMedia => 'Multimedia';

  @override
  String get projectStatsNetworkParts => 'Partes';

  @override
  String get projectStatsNetworkParasites => 'Parásitos';

  @override
  String get projectStatsNetworkLegend => 'Tipos de registro';

  @override
  String get projectStatsNetworkAllProjects => 'Todos los proyectos';

  @override
  String get projectStatsNetworkOptions => 'Opciones';

  @override
  String get projectStatsNetworkShowOptions => 'Mostrar opciones';

  @override
  String get projectStatsNetworkHideOptions => 'Ocultar opciones';

  @override
  String get projectStatsNetworkDetails => 'Detalles';

  @override
  String get projectStatsNetworkExitFullScreen => 'Salir de pantalla completa';

  @override
  String projectStatsNetworkSummaryRadial(String layout, String type) {
    return '$layout · desde $type';
  }

  @override
  String projectStatsNetworkSummaryLayered(String layout, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count columnas',
      one: '1 columna',
    );
    return '$layout · $_temp0';
  }

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
  String get projectTissueFilled => 'Ocupada';

  @override
  String get projectTissueNext => 'Siguiente';

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
  String get projectTissueTabBox => 'Caja';

  @override
  String get projectTissueTabSetup => 'Configuración';

  @override
  String projectTissueTabLog(int count) {
    return 'Registro ($count)';
  }

  @override
  String get projectTissueFindTubesBody =>
      'Qué tubos coinciden con el escaneo y la lista de trabajo.';

  @override
  String get projectTissueUpdateFieldBody =>
      'Se escribe en cada tubo que coloque.';

  @override
  String get projectTissueBoxSectionBody =>
      'Tamaño, orden de llenado y la caja que se llena.';

  @override
  String get projectTissueAdvanced => 'Etiquetas y sobrescritura';

  @override
  String get projectTissueAdvancedBody =>
      'Formato de etiquetas de celda y cómo se tratan los valores guardados.';

  @override
  String get projectTissueExportLog => 'Exportar registro';

  @override
  String get projectTissueExportLogTitle => 'Exportar registro de la sesión';

  @override
  String projectTissueExportSummary(int checked, int skipped) {
    return '$checked revisados, $skipped omitidos';
  }

  @override
  String get projectTissueLogStatusChecked => 'Revisado';

  @override
  String get projectTissueLogStatusSkipped => 'Omitido';

  @override
  String get projectTissuePart => 'Parte';

  @override
  String get projectTissueColStatus => 'Estado';

  @override
  String get projectTissueColOrder => 'Orden';

  @override
  String get projectTissueColFieldId => 'ID de campo';

  @override
  String get projectTissueColTubeId => 'ID del tubo';

  @override
  String get projectTissueColKind => 'Clase';

  @override
  String get projectTissueColType => 'Tipo';

  @override
  String get projectTissueColTreatment => 'Tratamiento';

  @override
  String get projectTissueColField => 'Campo actualizado';

  @override
  String get projectTissueColValue => 'Valor';

  @override
  String get projectTissueColLocation => 'Ubicación';

  @override
  String get projectTissueColBox => 'Caja';

  @override
  String get projectTissueColCell => 'Celda';

  @override
  String get projectTissueColPreviousValue => 'Valor anterior';

  @override
  String get projectTissueColPreviousLocation => 'Ubicación anterior';

  @override
  String get projectTissueLogColumns => 'Columnas';

  @override
  String get projectTissueLogColumnsBody =>
      'Las columnas de curación siempre van primero. Agregue después campos de partes, especímenes y registros vinculados.';

  @override
  String get projectTissueLogAddColumns => 'Agregar columnas';

  @override
  String get projectTissueLogAddedColumns => 'Columnas agregadas';

  @override
  String get projectTissueLogNoAddedColumns =>
      'Sin columnas agregadas. La exportación solo tiene las columnas de curación.';

  @override
  String get projectTissueLogHeaderStyle => 'Encabezados de columnas agregadas';

  @override
  String get projectTissueLogHeaderFieldName => 'Nombres de campo';

  @override
  String get projectTissueLogHeaderKey => 'Claves NAHPU';

  @override
  String get projectTissueLogChooseColumns => 'Elegir columnas';

  @override
  String projectTissueLogRemoveColumn(String name) {
    return 'Quitar $name';
  }

  @override
  String projectTissueLogSelectedCount(int count) {
    return '$count seleccionadas';
  }

  @override
  String get projectTissueReplace => 'Reemplazar';

  @override
  String projectTissueReplaceTitle(String cell) {
    return '¿Reemplazar $cell?';
  }

  @override
  String projectTissueReplaceMessage(int count, String cell, String labels) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'El próximo tubo que escanee o coloque irá a $cell. $labels pierden su ubicación y vuelven a la lista de trabajo. Deshacer los devuelve.',
      one:
          'El próximo tubo que escanee o coloque irá a $cell. $labels pierde su ubicación y vuelve a la lista de trabajo. Deshacer lo devuelve.',
    );
    return '$_temp0';
  }

  @override
  String projectTissueReplacing(String labels) {
    return 'Reemplaza $labels';
  }

  @override
  String projectTissueReplacedLog(String labels) {
    return 'Reemplazó $labels';
  }

  @override
  String get projectTissueColReplaced => 'Reemplazados';

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
  String get projectTissueSuggestionsLabel => '¿Quiso decir?';

  @override
  String get projectTissueWorkListEmpty =>
      'Ninguna parte sin ubicar coincide con los filtros de tipo de tejido y preservación.';

  @override
  String projectTissueRemaining(int count) {
    return 'Siguiente · quedan $count';
  }

  @override
  String get projectTissuePlace => 'Ubicar';

  @override
  String get projectTissueIncludeParasites => 'Incluir parásitos';

  @override
  String get projectTissueWorkListSearch => 'Buscar en la lista de trabajo';

  @override
  String get projectTissueNoMatches => 'Ningún tubo coincide';

  @override
  String get projectTissueParasite => 'Parásito';

  @override
  String get projectTissueParasiteCategory => 'Categoría de parásito';

  @override
  String get projectTissueIdParasiteIdOrBarcode =>
      'ID del tejido, ID del parásito o código de barras';

  @override
  String get projectTissueFieldIdOrParasiteId =>
      'ID de campo o ID del parásito';

  @override
  String get projectTissueSearchByFieldId => 'Buscar por ID de campo';

  @override
  String projectTissueLogChecked(int count) {
    return 'Registrados ($count)';
  }

  @override
  String projectTissueLogSkipped(int count) {
    return 'Omitidos ($count)';
  }

  @override
  String get projectTissueLogSkippedEmpty =>
      'Los tubos omitidos aparecen aquí hasta que se ubican.';

  @override
  String get projectTissuePreviousBox => 'Caja anterior';

  @override
  String get projectTissueDetails => 'Detalles';

  @override
  String get projectTissueOpenRecord => 'Abrir registro';

  @override
  String projectTissueSharedCell(int count) {
    return '$count tubos comparten esta celda';
  }

  @override
  String get projectTissueBarcode => 'Código de barras';

  @override
  String get projectTissueStorageLocation => 'Ubicación de almacenamiento';

  @override
  String get projectTissueCountLabel => 'Cantidad';

  @override
  String get projectTissueTapCellHint =>
      'Toque una celda vacía para saltar a ella, o una llena para ver su tubo';

  @override
  String get parasiteRecords => 'Registros de parásitos';

  @override
  String get parasiteUnidentified => 'Parásito no identificado';

  @override
  String parasiteIndividuals(String ids) {
    return 'Ind.: $ids';
  }

  @override
  String parasiteCount(String count) {
    return 'Cantidad: $count';
  }

  @override
  String get parasiteNoneAdded => 'No se agregaron parásitos';

  @override
  String get parasiteAdd => 'Agregar parásito';

  @override
  String get parasiteEdit => 'Editar parásito';

  @override
  String get parasiteDetails => 'Detalles del parásito';

  @override
  String get parasiteCountLabel => 'Cantidad';

  @override
  String get parasiteCountHint => 'Ingrese la cantidad de parásitos';

  @override
  String get parasiteCategory => 'Categoría';

  @override
  String get parasiteAnatomicalLocation => 'Ubicación anatómica';

  @override
  String get parasiteCollectionIdentification => 'Colecta e identificación';

  @override
  String get parasiteCollector => 'Colector';

  @override
  String get parasiteCollectorHint => 'Seleccione quién colectó el parásito';

  @override
  String get parasiteDetectionMethod => 'Método de detección';

  @override
  String get parasiteDateCollected => 'Fecha de colecta';

  @override
  String get parasiteDateCollectedHint => 'Ingrese la fecha de colecta';

  @override
  String get parasiteTimeCollected => 'Hora de colecta';

  @override
  String get parasiteTimeCollectedHint => 'Ingrese la hora de colecta';

  @override
  String get parasiteDeterminer => 'Determinador';

  @override
  String get parasiteDeterminerHint =>
      'Seleccione quién identificó el parásito';

  @override
  String get parasiteDateDetermined => 'Fecha de determinación';

  @override
  String get parasiteDateDeterminedHint => 'Ingrese la fecha de identificación';

  @override
  String get parasiteDeterminationMethod => 'Método de determinación';

  @override
  String parasiteSaveError(String error) {
    return 'No se pudo guardar el parásito: $error';
  }

  @override
  String get parasiteTaxon => 'Taxón del parásito';

  @override
  String get parasiteTaxonHint => 'Seleccione un taxón registrado';

  @override
  String get parasiteNotIdentified => 'No identificado';

  @override
  String parasiteTaxaLoadError(String error) {
    return 'No se pudieron cargar los taxones: $error';
  }

  @override
  String get parasiteAddTaxon => 'Agregar taxón';

  @override
  String get parasiteNotAssigned => 'Sin asignar';

  @override
  String get parasitePreparationPreservation => 'Preparación y preservación';

  @override
  String get parasitePreparationMethod => 'Método de preparación';

  @override
  String get parasiteTreatment => 'Tratamiento';

  @override
  String get parasiteDatePreserved => 'Fecha de preservación';

  @override
  String get parasiteDatePreservedHint => 'Ingrese la fecha de preservación';

  @override
  String get parasiteTimePreserved => 'Hora de preservación';

  @override
  String get parasiteTimePreservedHint => 'Ingrese la hora de preservación';

  @override
  String get parasiteCuration => 'Curaduría';

  @override
  String get parasiteStorage => 'Almacenamiento';

  @override
  String get parasiteStorageLocation => 'Ubicación de almacenamiento';

  @override
  String get parasiteStorageLocationHint =>
      'Ingrese el congelador, gabinete, estante o contenedor';

  @override
  String get parasiteMuseumPermanent => 'Colección permanente del museo';

  @override
  String get parasiteMuseumHint =>
      'Ingrese el nombre o la abreviatura del museo';

  @override
  String get parasiteMuseumLoan => 'Préstamo del museo';

  @override
  String get parasiteRemarks => 'Observaciones';

  @override
  String get parasiteRemarksHint => 'Ingrese observaciones sobre el parásito';

  @override
  String get parasiteLifeStage => 'Etapa de vida';

  @override
  String get parasiteLifeStageHint =>
      'Seleccione la etapa de vida del parásito';

  @override
  String get parasiteAssociationStatus => 'Estado de la asociación';

  @override
  String get parasiteAssociationStatusHint =>
      'Seleccione el estado de la asociación';

  @override
  String parasiteFieldLoadError(String field, String error) {
    return 'No se pudo cargar $field: $error';
  }

  @override
  String get parasiteSetOptionsInSettings =>
      'Configure las opciones en la configuración de especímenes';

  @override
  String parasiteSelectField(String field) {
    return 'Seleccione $field';
  }

  @override
  String get parasiteIds => 'ID';

  @override
  String parasiteUuid(String uuid) {
    return 'UUID: $uuid';
  }

  @override
  String get parasiteId => 'ID del parásito';

  @override
  String get parasiteIdHint =>
      'Ingrese un ID de parásito definido por el usuario';

  @override
  String get parasiteIdOptions => 'Opciones del ID del parásito';

  @override
  String get parasiteScanCode => 'Escanear QR/código de barras';

  @override
  String get parasiteNewNumber => 'Número nuevo';

  @override
  String get parasiteSettings => 'Configuración';

  @override
  String get parasiteIdSettings => 'Configuración del ID del parásito';

  @override
  String get parasitePrefix => 'Prefijo';

  @override
  String get parasitePrefixHint => 'Ingrese el prefijo del ID del parásito';

  @override
  String get parasiteNumber => 'Número';

  @override
  String get parasiteNumberHint =>
      'Ingrese el siguiente número de ID del parásito';

  @override
  String get specimenShowOutlierWarnings =>
      'Mostrar advertencias de valores atípicos';

  @override
  String get mammalTotalLength => 'Longitud total (mm)';

  @override
  String get mammalTotalLengthHint => 'Ingrese LT';

  @override
  String get mammalTailLength => 'Longitud de la cola (mm)';

  @override
  String get mammalTailLengthHint => 'Ingrese LC';

  @override
  String get specimenAutoCalculated => 'Calculado automáticamente';

  @override
  String get mammalHeadBodyLength => 'Longitud de cabeza y cuerpo (mm)';

  @override
  String get mammalHeadBodyLengthHint => 'Ingrese LCC';

  @override
  String get mammalTailHeadBodyRatio => 'Longitud cola/CC';

  @override
  String get mammalTailHeadBodyRatioHint => 'Ingrese LC/LCC';

  @override
  String get mammalHindFootLength => 'Longitud de la pata trasera (mm)';

  @override
  String get mammalHindFootLengthHint => 'Ingrese la longitud de PT';

  @override
  String get mammalEarLength => 'Longitud de la oreja (mm)';

  @override
  String get mammalEarLengthHint => 'Ingrese la longitud de OR';

  @override
  String get mammalShowBatFields => 'Mostrar campos de murciélagos';

  @override
  String get specimenRemarks => 'Observaciones';

  @override
  String get specimenMeasurementRemarksHint =>
      'Escriba notas sobre las medidas (opcional)';

  @override
  String get specimenUnusualMeasurement => 'Medida inusual';

  @override
  String get mammalChangeSexTitle => '¿Cambiar el sexo?';

  @override
  String get mammalChangeSexBody =>
      'Cambiar el sexo borrará los datos reproductivos que no correspondan a la nueva selección.';

  @override
  String get specimenAccuracy => 'Precisión';

  @override
  String get specimenAccuracyHint => 'Seleccione la precisión de la medida';

  @override
  String get specimenNoInaccurateSelected =>
      'No se seleccionaron medidas imprecisas';

  @override
  String specimenInaccurateList(String labels) {
    return '*Imprecisas: $labels';
  }

  @override
  String specimenAccuracyRemarkValue(String remark) {
    return 'Observación:\n$remark';
  }

  @override
  String get specimenSelectInaccurate => 'Seleccionar medidas imprecisas';

  @override
  String get specimenInaccurateMeasurements => 'Medidas imprecisas';

  @override
  String get specimenSelectEveryInaccurate =>
      'Seleccione cada medida que sea imprecisa.';

  @override
  String get specimenSelectAtLeastOneInaccurate =>
      'Seleccione al menos una medida imprecisa.';

  @override
  String get specimenAccuracyRemark => 'Observación de precisión';

  @override
  String get specimenAccuracyRemarkHint =>
      'Describa por qué las medidas son imprecisas';

  @override
  String get mammalTestes => 'Testículos';

  @override
  String get mammalTestisPosition => 'Posición';

  @override
  String get mammalTestisPositionHint => 'Seleccione la posición del testículo';

  @override
  String get specimenLengthMm => 'Longitud (mm)';

  @override
  String get mammalTestisLengthHint =>
      'Ingrese la longitud del testículo derecho';

  @override
  String get specimenWidthMm => 'Ancho (mm)';

  @override
  String get mammalTestisWidthHint => 'Ingrese el ancho del testículo derecho';

  @override
  String get mammalEpididymis => 'Epidídimo';

  @override
  String get mammalEpididymisHint => 'Seleccione la apariencia del epidídimo';

  @override
  String get mammalVaginaOpening => 'Abertura vaginal';

  @override
  String get mammalVaginaOpeningHint => 'Seleccione la abertura vaginal';

  @override
  String get mammalPubicSymphysis => 'Sínfisis púbica';

  @override
  String get mammalPubicSymphysisHint =>
      'Seleccione la condición de la sínfisis púbica';

  @override
  String get mammalFemaleReproductive => 'Atributos reproductivos de la hembra';

  @override
  String get mammalReproductiveStage => 'Etapa reproductiva';

  @override
  String get mammalReproductiveStageHint => 'Seleccione la etapa reproductiva';

  @override
  String get mammalMammaeCounts => 'Conteo de mamas (pares)';

  @override
  String get mammalMammaeCondition => 'Condición de las mamas';

  @override
  String get mammalMammaeConditionHint =>
      'Seleccione la condición de las mamas';

  @override
  String get mammalEmbryo => 'Embrión';

  @override
  String get mammalCrownRumpLength => 'Longitud CR (mm)';

  @override
  String get mammalCrownRumpLengthHint =>
      'Ingrese la longitud corona-rabadilla';

  @override
  String get mammalPlacentalScars => 'Cicatrices placentarias';

  @override
  String get mammalAxillary => 'Axilar';

  @override
  String get mammalAxillaryHint => 'Ingrese el número de pares axilares';

  @override
  String get mammalAbdominal => 'Abdominal';

  @override
  String get mammalAbdominalHint => 'Ingrese el número de pares abdominales';

  @override
  String get mammalInguinal => 'Inguinal';

  @override
  String get mammalInguinalHint => 'Ingrese el número de pares inguinales';

  @override
  String get specimenLeft => 'Izquierda';

  @override
  String get specimenRight => 'Derecha';

  @override
  String get mammalForearmLength => 'Longitud del antebrazo (mm)';

  @override
  String get mammalForearmLengthHint => 'Ingrese la longitud del AB';

  @override
  String get mammalTibiaLength => 'Longitud de la tibia (mm)';

  @override
  String get mammalTibiaLengthHint => 'Ingrese la longitud de la tibia';

  @override
  String get mammalEcholocate => '¿Ecolocaliza?';

  @override
  String get mammalEcholocation => 'Ecolocalización';

  @override
  String get mammalEcholocationHint => 'Seleccione el tipo de ecolocalización';

  @override
  String get mammalFrequencyMax => 'Frecuencia máxima (kHz)';

  @override
  String get mammalFrequencyMaxHint =>
      'Ingrese la frecuencia máxima de ecolocalización';

  @override
  String get mammalFrequencyMin => 'Frecuencia mínima (kHz)';

  @override
  String get mammalFrequencyMinHint =>
      'Ingrese la frecuencia mínima de ecolocalización';

  @override
  String get mammalFrequencyMaxEnergy => 'Frecuencia de máxima energía (kHz)';

  @override
  String get mammalFrequencyMaxEnergyHint =>
      'Ingrese la frecuencia de ecolocalización de máxima energía';

  @override
  String get mammalEcholocationDuration => 'Duración (segundos)';

  @override
  String get mammalEcholocationDurationHint =>
      'Ingrese la duración de la ecolocalización';

  @override
  String get birdWingspan => 'Envergadura (mm)';

  @override
  String get birdWingspanHint => 'Ingrese la envergadura';

  @override
  String get birdBillColor => 'Color del pico';

  @override
  String get birdBillColorHint => 'Ingrese el color del pico';

  @override
  String get birdMaxillaColor => 'Color de la maxila';

  @override
  String get birdMaxillaColorHint => 'Ingrese el color de la maxila';

  @override
  String get birdMandibleColor => 'Color de la mandíbula';

  @override
  String get birdMandibleColorHint => 'Ingrese el color de la mandíbula';

  @override
  String get birdIrisColor => 'Color del iris';

  @override
  String get birdIrisColorHint => 'Ingrese el color del iris';

  @override
  String get birdTarsusColor => 'Color del tarso';

  @override
  String get birdTarsusColorHint => 'Ingrese el color del tarso';

  @override
  String get birdToeColor => 'Color de los dedos';

  @override
  String get birdToeColorHint => 'Ingrese el color de los dedos';

  @override
  String get birdBroodPatch => 'Parche de incubación';

  @override
  String get birdBursaPresent => 'Bursa presente';

  @override
  String get birdStomachContents => 'Contenido estomacal';

  @override
  String get birdStomachContentsHint => 'Ingrese el contenido estomacal';

  @override
  String get birdBursaLength => 'Longitud de la bursa (mm)';

  @override
  String get birdBursaLengthHint => 'Ingrese la longitud de la bursa';

  @override
  String get birdBursaWidth => 'Ancho de la bursa (mm)';

  @override
  String get birdBursaWidthHint => 'Ingrese el ancho de la bursa';

  @override
  String get birdMaleGonads => 'Gónadas masculinas';

  @override
  String get birdLeftTestisSize => 'Tamaño del testículo izquierdo (mm)';

  @override
  String get birdSize => 'Tamaño';

  @override
  String get birdMinute => 'diminuto';

  @override
  String get birdOneMmOrGreater => '1 mm o más';

  @override
  String get birdLength => 'Longitud';

  @override
  String get specimenEnterLength => 'Ingrese la longitud';

  @override
  String get birdWidth => 'Ancho';

  @override
  String get specimenEnterWidth => 'Ingrese el ancho';

  @override
  String get birdTestisRemarksHint =>
      'Ingrese observaciones, p. ej., tamaño del testículo derecho';

  @override
  String get birdFemaleGonads => 'Gónadas femeninas';

  @override
  String get birdOvarySize => 'Tamaño del ovario';

  @override
  String get birdAppearance => 'Apariencia';

  @override
  String get birdOviduct => 'Oviducto';

  @override
  String get birdGonadRemarksHint =>
      'Agregue información adicional sobre las gónadas';

  @override
  String get birdSkullOssification => 'Osificación del cráneo (%)';

  @override
  String get birdSkullOssificationHint => 'Ingrese el porcentaje';

  @override
  String get birdFat => 'Grasa';

  @override
  String get birdLargestOva => 'Diámetro de los tres óvulos más grandes (mm)';

  @override
  String get birdFirst => 'Primero';

  @override
  String get birdEnterSize => 'Ingrese el tamaño';

  @override
  String get birdSecond => 'Segundo';

  @override
  String get birdThird => 'Tercero';

  @override
  String get birdMolt => 'Muda';

  @override
  String get birdWingMolt => 'Muda de alas';

  @override
  String get birdTailMolt => 'Muda de cola';

  @override
  String get birdMoltRemarksHint =>
      'Agregue información adicional sobre la muda';

  @override
  String get birdWingMoltHint => 'Ingrese la muda de alas';

  @override
  String get birdTailMoltHint => 'Ingrese la muda de cola';

  @override
  String get birdBodyMolt => 'Muda corporal';

  @override
  String get specimenNotes => 'Notas';

  @override
  String get birdHabitat => 'Hábitat';

  @override
  String get birdHabitatHint =>
      'Agregue información adicional sobre el hábitat';

  @override
  String get specimenSpecimen => 'Espécimen';

  @override
  String get specimenRemarksHint =>
      'Agregue información adicional sobre el espécimen';

  @override
  String get fishStandardLength => 'Longitud estándar (mm)';

  @override
  String get fishStandardLengthHint => 'Ingrese la longitud estándar';

  @override
  String get fishTotalLengthHint => 'Ingrese la longitud total';

  @override
  String get fishTotalIndividuals => 'Total de individuos';

  @override
  String get fishTotalIndividualsHint =>
      'Ingrese el número de individuos del lote';

  @override
  String get fishAutoUpdateRanges => 'Actualizar mín. y máx. automáticamente';

  @override
  String get fishAutoUpdateRangesBody =>
      'Completar los rangos con los individuos medidos abajo';

  @override
  String get fishMinStandardLength => 'Longitud estándar mín. (mm)';

  @override
  String get fishMinStandardLengthHint => 'Ingrese la longitud estándar mínima';

  @override
  String get fishMaxStandardLength => 'Longitud estándar máx. (mm)';

  @override
  String get fishMaxStandardLengthHint => 'Ingrese la longitud estándar máxima';

  @override
  String get fishMinTotalLength => 'Longitud total mín. (mm)';

  @override
  String get fishMinTotalLengthHint => 'Ingrese la longitud total mínima';

  @override
  String get fishMaxTotalLength => 'Longitud total máx. (mm)';

  @override
  String get fishMaxTotalLengthHint => 'Ingrese la longitud total máxima';

  @override
  String get fishMinWeight => 'Peso mín.';

  @override
  String get fishMinWeightHint => 'Ingrese el peso mínimo';

  @override
  String get fishMaxWeight => 'Peso máx.';

  @override
  String get fishMaxWeightHint => 'Ingrese el peso máximo';

  @override
  String get fishSpecimenType => 'Tipo de espécimen';

  @override
  String get fishTypeIndividual => 'Individuo';

  @override
  String get fishTypeLot => 'Lote';

  @override
  String get fishTypeIndividualDescription => 'Un pez con sus propias medidas';

  @override
  String get fishTypeLotDescription => 'Muchos individuos almacenados juntos';

  @override
  String get invertCaste => 'Casta';

  @override
  String get invertCasteHint => 'Seleccione la casta';

  @override
  String get invertEcologicalInteractions => 'Interacciones ecológicas';

  @override
  String get invertShowMorphometrics => 'Mostrar morfometría del espécimen';

  @override
  String get invertMorphometrics => 'Morfometría del espécimen';

  @override
  String get invertHostOrganism => 'Organismo hospedador';

  @override
  String get invertHostOrganismHint => 'Ingrese el taxón hospedador asociado';

  @override
  String get invertHostPart => 'Parte del hospedador';

  @override
  String get invertHostPartHint => 'Ingrese la parte ocupada del hospedador';

  @override
  String get invertHeadWidth => 'Ancho de la cabeza (mm)';

  @override
  String get invertHeadWidthHint => 'Ingrese el ancho de la cabeza';

  @override
  String get invertBodyLength => 'Longitud del cuerpo (mm)';

  @override
  String get invertBodyLengthHint => 'Ingrese la longitud del cuerpo';

  @override
  String get invertUpperWingspan => 'Envergadura superior (mm)';

  @override
  String get invertUpperWingspanHint => 'Ingrese la envergadura superior';

  @override
  String get invertLowerWingspan => 'Envergadura inferior (mm)';

  @override
  String get invertLowerWingspanHint => 'Ingrese la envergadura inferior';

  @override
  String get herpSnoutVentLength => 'LHC (cm)';

  @override
  String get herpSnoutVentLengthHint => 'Ingrese la longitud hocico-cloaca';

  @override
  String get partSpecimenParts => 'Partes del espécimen';

  @override
  String get partAdd => 'Agregar parte del espécimen';

  @override
  String get partNoneAdded => 'No se agregaron partes';

  @override
  String get partUnknown => 'Parte desconocida';

  @override
  String get partNoCount => 'Sin cantidad';

  @override
  String get partNoTreatment => 'Ninguno';

  @override
  String get partHasRemark => 'tiene observación';

  @override
  String partPmi(String pmi) {
    return 'IPM $pmi';
  }

  @override
  String get partAddParts => 'Agregar partes del espécimen';

  @override
  String get partEditParts => 'Editar partes del espécimen';

  @override
  String get partPreparation => 'Preparación';

  @override
  String get partSampling => 'Muestreo';

  @override
  String partSaveError(String error) {
    return 'No se pudo guardar la parte del espécimen: $error';
  }

  @override
  String get partCounts => 'Cantidades';

  @override
  String get partCountsHint => 'Ingrese la cantidad de partes';

  @override
  String get partPreparationType => 'Tipo de preparación';

  @override
  String get partPreparationTypeHint => 'Ingrese el tipo de preparación';

  @override
  String get partTreatmentHint => 'Ingrese el tratamiento';

  @override
  String get partAdditionalTreatment => 'Tratamiento adicional';

  @override
  String get partAdditionalTreatmentHint => 'Ingrese el tratamiento adicional';

  @override
  String get partPreparatorHint =>
      'Si es diferente del preparador del ejemplar de referencia';

  @override
  String get partDateTaken => 'Fecha de toma';

  @override
  String get partTimeTaken => 'Hora de toma';

  @override
  String get partRecommendedFresh => 'Recomendado para tejidos frescos';

  @override
  String get partStorageType => 'Tipo de almacenamiento';

  @override
  String get partStorageTypeHint => 'Ingrese el tipo de almacenamiento';

  @override
  String get partStorageLocationHint =>
      'Puede ser el ID de celda o frasco, según la convención de su museo';

  @override
  String get partMuseumHint => 'Ingrese un nombre o abreviatura de museo';

  @override
  String get partRemarksHint =>
      'Ingrese una observación específica para esta parte';

  @override
  String get partBarcodeId => 'ID de QR/código de barras';

  @override
  String get partBarcodeIdHint =>
      'Ingrese el ID del código de barras (si corresponde)';

  @override
  String get partBarcodeIdOptions => 'Opciones del ID de QR/código de barras';

  @override
  String get partGenerateUuid => 'Generar UUID';

  @override
  String get partInvalidBarcode => 'QR/código de barras no válido';

  @override
  String get partBarcodeIdExists =>
      'El ID de QR/código de barras ya existe. Borre el campo para generar un UUID nuevo';

  @override
  String get partTissueIdHint => 'Ingrese el ID del tejido';

  @override
  String get partRepeatTissueFailed => 'No se pudo repetir el número de tejido';

  @override
  String get partTissueIdOptions => 'Opciones del ID del tejido';

  @override
  String get partTissueIdSettings => 'Configuración del ID del tejido';

  @override
  String get specimenCollectionIdentification => 'Colecta e identificación';

  @override
  String get specimenTaxaLoadError => 'Error al cargar los taxones';

  @override
  String get specimenIdConfidence => 'Confianza de la identificación';

  @override
  String get specimenIdConfidenceHint => 'Elija un nivel de confianza';

  @override
  String get specimenDeterminerHint =>
      'Elija un determinador (por defecto, el catalogador)';

  @override
  String get specimenIdMethod => 'Método de identificación';

  @override
  String get specimenIdMethodHint => 'Elija un método de identificación';

  @override
  String get specimenCollectionDate => 'Fecha de colecta';

  @override
  String get specimenCollectionTime => 'Hora de colecta';

  @override
  String get specimenConditionHint => 'Elija una condición';

  @override
  String get specimenPrepDate => 'Fecha de prep.';

  @override
  String get specimenPrepTime => 'Hora de prep.';

  @override
  String get specimenPreparatorHint =>
      'Elija un preparador (por defecto, el catalogador)';

  @override
  String specimenUuid(String uuid) {
    return 'UUID del espécimen: $uuid';
  }

  @override
  String get specimenMuseumId => 'ID del museo';

  @override
  String get specimenMuseumIdHint => 'Ingrese el ID del museo (si corresponde)';

  @override
  String specimenFieldIdValue(String id) {
    return 'ID de campo: $id';
  }

  @override
  String get specimenFieldIdLoading => 'ID de campo: cargando…';

  @override
  String get specimenFieldIdUnavailable => 'ID de campo: no disponible';

  @override
  String get specimenFieldIdSelectCataloger =>
      'ID de campo: seleccione un catalogador';

  @override
  String get specimenFieldIdCatalogerNotSetUp =>
      'ID de campo: el catalogador no está configurado para números de campo';

  @override
  String get specimenEditFieldId => 'Editar ID de campo';

  @override
  String get specimenFieldIdPersonnel => 'Personal';

  @override
  String get specimenFieldIdProject => 'Proyecto';

  @override
  String get specimenFieldIdPersonnelUnavailable =>
      'Seleccione un catalogador con el registro de números de campo personales activado antes de asignar un ID de campo personal.';

  @override
  String get specimenPersonnelFieldNumber => 'Número de campo personal';

  @override
  String get specimenProjectCatalogNumber => 'Número de catálogo del proyecto';

  @override
  String get specimenFieldIdTypeChangeAck =>
      'Entiendo que cambiar el tipo de identificador elimina el ID de campo anterior del espécimen y que puede aparecer ya en exportaciones o en etiquetas de especímenes.';

  @override
  String get specimenSaving => 'Guardando…';

  @override
  String get fishStandardLengthShort => 'Longitud estándar';

  @override
  String get fishTotalLengthShort => 'Longitud total';

  @override
  String get fishWeight => 'Peso';

  @override
  String get fishLotSummary => 'Resumen del lote';

  @override
  String fishMeasuredCount(int count) {
    return '$count medidos';
  }

  @override
  String fishMeasuredOfTotal(int count, int total) {
    return '$count de $total individuos medidos';
  }

  @override
  String get fishNotMeasured => 'Sin medir';

  @override
  String fishStandardDeviation(String value) {
    return '± $value DE';
  }

  @override
  String fishRange(String min, String max, String unit) {
    return 'Rango $min–$max $unit';
  }

  @override
  String get fishIndividuals => 'Individuos';

  @override
  String fishIndividualsLoadError(String error) {
    return 'No se pudieron cargar los individuos: $error';
  }

  @override
  String get fishAddIndividual => 'Agregar individuo';

  @override
  String get fishDeleteIndividual => 'Eliminar individuo';

  @override
  String fishStandardLengthValue(String value) {
    return 'LE $value mm';
  }

  @override
  String fishTotalLengthValue(String value) {
    return 'LT $value mm';
  }

  @override
  String get fishNoMeasurements => 'Sin medidas';

  @override
  String fishDeleteIndividualTitle(String name) {
    return '¿Eliminar $name?';
  }

  @override
  String get fishDeleteIndividualBody =>
      'Esto elimina el individuo y lo desvincula de todas las partes del espécimen y parásitos.';

  @override
  String get fishStandardLengthMm => 'LE (mm)';

  @override
  String get fishTotalLengthMm => 'LT (mm)';

  @override
  String fishWeightWithUnit(String unit) {
    return 'Peso ($unit)';
  }

  @override
  String get fishEnterWeight => 'Ingrese el peso';

  @override
  String get fishIndividualRemarksHint => 'Agregue notas sobre este individuo';

  @override
  String get fishEditIndividual => 'Editar individuo';

  @override
  String fishEnteredCount(int count) {
    return '$count ingresados';
  }

  @override
  String fishEnteredOfTotal(int count, int total) {
    return '$count de $total ingresados';
  }

  @override
  String get fishSaveAndAddAnother => 'Guardar y agregar otro';

  @override
  String get fishMeasurements => 'Medidas';

  @override
  String get fishTagId => 'ID de etiqueta';

  @override
  String get fishTagIdHint => 'Ingrese el ID del individuo o de la etiqueta';

  @override
  String get fishAutoNumbered =>
      'Numerado automáticamente. Edítelo para cambiarlo.';

  @override
  String get fishTagIdOptions => 'Opciones del ID de etiqueta';

  @override
  String get fishTagIdSettings => 'Configuración del ID de etiqueta';

  @override
  String get specimenCaptureRecords => 'Registros de captura';

  @override
  String get specimenChooseSite => 'Elija un sitio';

  @override
  String get specimenChangeSiteTitle => '¿Cambiar el sitio?';

  @override
  String get specimenChangeSiteBody =>
      'Excepto la fecha y la hora de captura, todos los campos de la sección del registro de colecta se vaciarán de nuevo.';

  @override
  String get specimenChooseEvent => 'Elija un ID de evento de colecta';

  @override
  String get specimenChangeEventTitle =>
      '¿Cambiar el ID del evento de colecta?';

  @override
  String get specimenChangeEventBody =>
      'Excepto la fecha y la hora de captura, todos los campos de la sección del registro de colecta se vaciarán de nuevo. La coordenada se conserva si pertenece al mismo sitio.';

  @override
  String get specimenChooseMethod => 'Elija un tipo de método';

  @override
  String get specimenRelativeTime => 'Hora relativa';

  @override
  String get specimenMethodId => 'ID del método';

  @override
  String get specimenMethodIdHint =>
      'Ingrese el ID, p. ej., número de trampa/red, etc.';

  @override
  String get specimenCaptureDate => 'Fecha de captura';

  @override
  String get specimenCoordinateId => 'ID de coordenada';

  @override
  String get specimenChooseCoordinate => 'Elija una coordenada';

  @override
  String get specimenCoordinateExtent => 'Extensión de la coordenada (m)';

  @override
  String get specimenCoordinateExtentHint =>
      'Agregue la extensión de la coordenada';

  @override
  String get specimenExtentInvalid =>
      'La extensión debe ser un número mayor que cero';

  @override
  String get specimenCaptureTime => 'Hora de captura';

  @override
  String get specimenChoosePerson => 'Elija una persona';

  @override
  String get specimenSexHint => 'Seleccione el sexo del espécimen';

  @override
  String get specimenLifeStageHint => 'Seleccione la etapa de vida';

  @override
  String specimenLifeStagesLoadError(String error) {
    return 'No se pudieron cargar las etapas de vida: $error';
  }

  @override
  String specimenParasiteDetectionLoadError(String error) {
    return 'No se pudo cargar la detección de parásitos: $error';
  }

  @override
  String get specimenParasitesExamined => 'Parásitos examinados';

  @override
  String get specimenParasitesDetected => 'Parásitos detectados';

  @override
  String get specimenDetectionRemarks => 'Observaciones de detección';

  @override
  String get specimenDetectionRemarksHint =>
      'Ingrese observaciones sobre el examen o la detección de parásitos';

  @override
  String get specimenCreate => 'Crear espécimen';

  @override
  String get specimenActions => 'Acciones del espécimen';

  @override
  String get specimenDuplicatePart => 'Duplicar parte';

  @override
  String get specimenExport => 'Exportar espécimen';

  @override
  String get specimenImport => 'Importar espécimen';

  @override
  String specimenDuplicatePartError(String error) {
    return 'Error al duplicar la parte: $error';
  }

  @override
  String get specimenDeleteTitle => '¿Eliminar espécimen?';

  @override
  String get specimenDeleteBody =>
      'Eliminará este registro de espécimen, todas las medidas y las partes del espécimen.\nDeberá actualizar manualmente el número de campo.';

  @override
  String specimenDeleteError(String error) {
    return 'Error al eliminar el espécimen: $error';
  }

  @override
  String get specimenDeleteAllTitle => '¿Eliminar todos los especímenes?';

  @override
  String get specimenDeleteAllBody =>
      'Se eliminarán todos los registros de especímenes, las medidas y las partes de especímenes';

  @override
  String specimenDeleteAllError(String error) {
    return 'Error al eliminar todos los especímenes: $error';
  }

  @override
  String get specimenTaxonInfo => 'Información del taxón';

  @override
  String get specimenNoSpeciesSelected => 'No se seleccionó ninguna especie';

  @override
  String get specimenTaxonTooltip =>
      'Escriba el nombre del taxón y selecciónelo de la lista';

  @override
  String get specimenTaxon => 'Taxón';

  @override
  String get specimenTaxonHint => 'Escriba el nombre del taxón';

  @override
  String get specimenEnterTaxon => 'Ingrese el taxón';

  @override
  String get specimenNoneSelected => 'Ninguno seleccionado';

  @override
  String specimenRemoveIndividualTooltip(String name) {
    return 'Quitar $name';
  }

  @override
  String get specimenAllIndividualsAdded => 'Se agregaron todos los individuos';

  @override
  String get specimenSelectIndividual => 'Seleccione un individuo';

  @override
  String specimenRemoveIndividualTitle(String name) {
    return '¿Quitar $name?';
  }

  @override
  String specimenRemoveIndividualBody(String name) {
    return 'Este registro ya no estará vinculado al individuo $name. El individuo se conserva.';
  }

  @override
  String get specimenRecordsTitle => 'Registros de especímenes';

  @override
  String get specimenSearchOptions => 'Opciones de búsqueda';

  @override
  String get specimenRecordTitle => 'Registro de espécimen';

  @override
  String get specimenNoneFound => 'No se encontró ningún espécimen';

  @override
  String get specimenWeightHint => 'Ingrese el peso del espécimen';

  @override
  String get specimenChangeWeightUnit => 'Cambiar la unidad de peso';

  @override
  String get templateDeleteTextBox => 'Eliminar cuadro de texto';

  @override
  String get templateHeightMm => 'Alto (mm)';

  @override
  String get templatePictureTypeOptions => 'Opciones del tipo de imagen';

  @override
  String get templateRotation => 'Rotación';

  @override
  String get templateQrCode => 'Código QR';

  @override
  String get templateQrSize => 'Tamaño del QR (mm)';

  @override
  String get templateContentFormattingOptions =>
      'Opciones de formato del contenido';

  @override
  String get templateShape => 'Forma';

  @override
  String get templateSquare => 'Cuadrado';

  @override
  String get templateCircle => 'Círculo';

  @override
  String get templateDynamic => 'Dinámico';

  @override
  String get templateSizePt => 'Tamaño (pt)';

  @override
  String get templateDecreaseFontSize => 'Reducir el tamaño de fuente';

  @override
  String get templateIncreaseFontSize => 'Aumentar el tamaño de fuente';

  @override
  String get templateTextFormattingOptions => 'Opciones de formato del texto';

  @override
  String get templateTextStylingOptions => 'Opciones de estilo del texto';

  @override
  String get templateMaxWidth => 'Ancho máximo (mm)';

  @override
  String get templateMaxHeight => 'Alto máximo (mm)';

  @override
  String get templateFont => 'Fuente';

  @override
  String templateFontNotInstalled(String font) {
    return '$font (no instalada)';
  }

  @override
  String get templateUnderline => 'Subrayado';

  @override
  String get templateStrikethrough => 'Tachado';

  @override
  String get templateForeground => 'Primer plano';

  @override
  String get templateQrForegroundColor =>
      'Seleccione el color de primer plano del QR';

  @override
  String get templateBackground => 'Fondo';

  @override
  String get templateQrBackgroundColor => 'Seleccione el color de fondo del QR';

  @override
  String get templateConditionalOutput => 'Salida condicional';

  @override
  String get templateFormat => 'Formato';

  @override
  String get templateMapEncodedValues => 'Asignar valores codificados';

  @override
  String get templateHeaderCase => 'Mayúsculas del encabezado';

  @override
  String get templateUppercase => 'Mayúsculas';

  @override
  String get templateLowercase => 'Minúsculas';

  @override
  String get templateMissing => 'Faltante';

  @override
  String get templateTextColor => 'Seleccione el color del texto';

  @override
  String get templateTextBackgroundColor =>
      'Seleccione el color de fondo del texto';

  @override
  String get templateStroke => 'Trazo';

  @override
  String get templateTextStrokeColor =>
      'Seleccione el color del trazo del texto';

  @override
  String get templateStyle => 'Estilo';

  @override
  String get templateRadius => 'Radio';

  @override
  String get templatePadding => 'Relleno';

  @override
  String get templateAlignLeft => 'Alinear a la izquierda';

  @override
  String get templateAlignCenter => 'Centrar';

  @override
  String get templateAlignRight => 'Alinear a la derecha';

  @override
  String templateClearColor(String label) {
    return 'Borrar $label';
  }

  @override
  String get templateNoContentPlaceholder => 'Marcador sin contenido';

  @override
  String get templateCustomText => 'Texto personalizado';

  @override
  String get templateCustomTextHint =>
      'Ingrese el texto alternativo personalizado';

  @override
  String get templateConditionalType => 'Tipo condicional';

  @override
  String get templateTargetField => 'Campo objetivo';

  @override
  String get templateConditionalTextHelper =>
      'Los campos como [mammalAttribute::testisWidth] se completan.';

  @override
  String get templateReplacementHelper =>
      'Se escribe cuando hay coincidencia; de lo contrario, se conserva el valor original. Déjelo vacío para ocultar el valor.';

  @override
  String get templateTypeNormalText => 'Texto normal';

  @override
  String get templateTypePicture => 'Imagen';

  @override
  String get templateTypeMarkdown => 'Markdown';

  @override
  String get templateTypeCoordinates => 'Coordenadas';

  @override
  String get templateTypeList => 'Valores de lista';

  @override
  String get templateTypeNestedList => 'Lista anidada';

  @override
  String get templateTypeDates => 'Fechas';

  @override
  String get templateTypeDateTime => 'Fecha y hora';

  @override
  String get templateTypeTime => 'Hora';

  @override
  String get templateTypeSex => 'Sexo';

  @override
  String get templateTypeNumber => 'Número';

  @override
  String get templateTypeEncoded => 'Texto codificado';

  @override
  String get templateFormatDefaultMapping => 'Asignación predeterminada';

  @override
  String get templateFormatCustomMapping => 'Asignación personalizada…';

  @override
  String get templateFormatDecimal => 'Decimal (45.123, -122.543)';

  @override
  String get templateFormatCardinalDecimal =>
      'Decimal cardinal (45.123° N, 122.543° O)';

  @override
  String get templateFormatPipe => 'Separado por barras verticales (A | B | C)';

  @override
  String get templateFormatComma => 'Separado por comas (A, B, C)';

  @override
  String get templateFormatSemicolon => 'Separado por punto y coma (A; B; C)';

  @override
  String get templateFormatSlash => 'Separado por barras (A / B / C)';

  @override
  String get templateFormatNewline => 'Nueva línea (A\nB\nC)';

  @override
  String get templateFormatBullet => 'Con viñetas (• A\n• B)';

  @override
  String get templateFormatCustomSeparator => 'Separador personalizado…';

  @override
  String get templateFormatTable => 'Tabla';

  @override
  String get templateFormatCardList => 'Lista de tarjetas';

  @override
  String get templateFormatMonthDdYyyy => 'Mes DD, AAAA (junio 28, 2026)';

  @override
  String get templateFormatDdMonthYyyy => 'DD Mes AAAA (28 junio 2026)';

  @override
  String get templateFormatDdMonthAbbr => 'DD Mes (abrev.) (28 jun 2026)';

  @override
  String get templateFormatYmdSeconds =>
      'AAAA-MM-DD segundos (2026-06-28 14:05:09)';

  @override
  String get templateFormatIsoMinutes => 'ISO minutos (2026-06-28T14:05)';

  @override
  String get templateFormatIsoSeconds => 'ISO segundos (2026-06-28T14:05:09)';

  @override
  String get templateFormatDdMonthYyyyTime =>
      'DD Mes AAAA 24 h (28 junio 2026 14:05)';

  @override
  String get templateFormatMonthDdYyyyTime =>
      'Mes DD, AAAA 12 h (junio 28, 2026 2:05 PM)';

  @override
  String get templateFormatDdMonYyyyTime =>
      'DD Mes AAAA 24 h (28 jun 2026 14:05)';

  @override
  String get templateFormatMonDdYyyyTime =>
      'Mes DD, AAAA 12 h (jun 28, 2026 2:05 PM)';

  @override
  String get templateFormatTime24 => 'Hora 24 h (14:05)';

  @override
  String get templateFormatTime24Seconds => 'Hora 24 h con segundos (14:05:09)';

  @override
  String get templateFormatTime12 => 'Hora 12 h (2:05 PM)';

  @override
  String get templateFormatTime12Padded =>
      'Hora 12 h con cero inicial (02:05 PM)';

  @override
  String get templateFormatOriginal => 'Original';

  @override
  String get templateFormatDecimals0 => '0 decimales (p. ej., 12)';

  @override
  String get templateFormatDecimals1 => '1 decimal (p. ej., 12.3)';

  @override
  String get templateFormatDecimals2 => '2 decimales (p. ej., 12.34)';

  @override
  String get templateFormatDecimals3 => '3 decimales (p. ej., 12.345)';

  @override
  String get templateFormatNormal => 'Normal';

  @override
  String get templateFormatCapitalize => 'Capitalizar';

  @override
  String get templateSexSymbol => 'Símbolo (♂/♀)';

  @override
  String get templateSexLetter => 'Letra (M/H)';

  @override
  String get templateSexText => 'Texto (Macho/Hembra)';

  @override
  String get templateSexUnknown => 'Desconocido';

  @override
  String get templateSexNa => 'N/D';

  @override
  String get templateSexNone => 'Ninguno';

  @override
  String get templateSizeLabel => 'Tamaño de la plantilla:';

  @override
  String get templateAddImage => 'Agregar imagen';

  @override
  String get templateAddLine => 'Agregar línea';

  @override
  String get templateAddShape => 'Agregar forma';

  @override
  String get templateFront => 'Anverso';

  @override
  String get templateBack => 'Reverso';

  @override
  String get templateSave => 'Guardar plantilla';

  @override
  String get templateRedo => 'Rehacer';

  @override
  String get templateBorder => 'Borde de la plantilla';

  @override
  String get templateElements => 'Elementos';

  @override
  String get templateHideGrid => 'Ocultar cuadrícula';

  @override
  String get templateShowGrid => 'Mostrar cuadrícula';

  @override
  String get templateDisableSnap => 'Desactivar ajuste';

  @override
  String get templateEnableSnap => 'Activar ajuste';

  @override
  String get templateUnlockCanvas => 'Desbloquear el movimiento del lienzo';

  @override
  String get templateLockCanvas => 'Bloquear el movimiento del lienzo';

  @override
  String get templateSelectPreviewRecord =>
      'Seleccionar espécimen para la vista previa del texto';

  @override
  String get templateSettings => 'Configuración de la plantilla';

  @override
  String get templateToolPage => 'Página';

  @override
  String get templateToolView => 'Vista';

  @override
  String get templatePresetTemplate => 'Plantilla predefinida';

  @override
  String templateMirrorOn(String side) {
    return '$side: girado 180° para imprimir (toque para desactivar)';
  }

  @override
  String templateMirrorOff(String side) {
    return '$side: toque para girar la plantilla 180° al imprimir';
  }

  @override
  String get templateOneSided => '1 cara';

  @override
  String templateEditSide(String side) {
    return 'Editar el lado $side';
  }

  @override
  String templateElementsForSide(String side) {
    return 'Elementos · $side';
  }

  @override
  String get templateNoElements =>
      'Aún no hay elementos en este lado. Agregue uno con las herramientas de Agregar.';

  @override
  String get templateHidden => 'Oculto';

  @override
  String get templateLocked => 'Bloqueado';

  @override
  String get templateNoSaved => 'Aún no hay plantillas guardadas.';

  @override
  String get templateFitToScreen => 'Ajustar a la pantalla';

  @override
  String get templateRemoveImage => 'Quitar imagen';

  @override
  String get templateDragToRotate => 'Arrastre para girar';

  @override
  String get templateRemoveLine => 'Quitar línea';

  @override
  String get templateDragToMove => 'Arrastre para mover';

  @override
  String get templateRemoveShape => 'Quitar forma';

  @override
  String get templateDeleteImage => 'Eliminar imagen';

  @override
  String get templateLineStrokeOptions => 'Opciones del trazo de línea';

  @override
  String get templateThickness => 'Grosor';

  @override
  String get templateColor => 'Color';

  @override
  String get templateSelectColor => 'Seleccionar color';

  @override
  String get templateDeleteLine => 'Eliminar línea';

  @override
  String get templateDismissToolbar => 'Cerrar barra de herramientas';

  @override
  String get templateBorderFillOptions => 'Opciones de borde y relleno';

  @override
  String get templateSelectStrokeColor => 'Seleccionar color del trazo';

  @override
  String get templateFill => 'Relleno';

  @override
  String get templateClearFill => 'Quitar relleno';

  @override
  String get templateDeleteShape => 'Eliminar forma';

  @override
  String get templateRectangle => 'Rectángulo';

  @override
  String get templateEllipse => 'Elipse';

  @override
  String get templateTriangle => 'Triángulo';

  @override
  String get templatePolygon => 'Polígono';

  @override
  String get templateCorners => 'Esquinas';

  @override
  String get templateSelectFillColor => 'Seleccionar color de relleno';

  @override
  String get templateBorderTitle => 'Borde';

  @override
  String get templateSelectBorderColor => 'Seleccionar color del borde';

  @override
  String get templateSelectColorShade => 'Seleccionar tono de color';

  @override
  String get templateSelectedColorShades => 'Color seleccionado y sus tonos';

  @override
  String get templateSendToBack => 'Enviar al fondo';

  @override
  String get templateSendBackward => 'Enviar atrás';

  @override
  String get templateBringForward => 'Traer adelante';

  @override
  String get templateBringToFront => 'Traer al frente';

  @override
  String get templateUnlockPosition => 'Desbloquear posición';

  @override
  String get templateLockPosition => 'Bloquear posición';

  @override
  String get templateHideElement => 'Ocultar elemento';

  @override
  String get templateShowElement => 'Mostrar elemento';

  @override
  String get templateDuplicateElement => 'Duplicar elemento';

  @override
  String get templateCopyElement => 'Copiar elemento';

  @override
  String get templatePasteElement => 'Pegar elemento';

  @override
  String templateMapEncodedValuesBody(String field) {
    return 'Defina etiquetas personalizadas para los valores de [$field]:';
  }

  @override
  String get templateFontsNotInstalled => 'Fuentes no instaladas';

  @override
  String templateMissingFontOne(int templates) {
    String _temp0 = intl.Intl.pluralLogic(
      templates,
      locale: localeName,
      other:
          'Esta instalación no tiene 1 fuente usada por las plantillas importadas. Elija un reemplazo.',
      one:
          'Esta instalación no tiene 1 fuente usada por la plantilla importada. Elija un reemplazo.',
    );
    return '$_temp0';
  }

  @override
  String templateMissingFontMany(int templates, int fonts) {
    String _temp0 = intl.Intl.pluralLogic(
      templates,
      locale: localeName,
      other:
          'Esta instalación no tiene $fonts fuentes usadas por las plantillas importadas. Elija un reemplazo para cada una.',
      one:
          'Esta instalación no tiene $fonts fuentes usadas por la plantilla importada. Elija un reemplazo para cada una.',
    );
    return '$_temp0';
  }

  @override
  String get templateInstallOriginalFonts =>
      'Instale las fuentes originales en Documentos > Fuentes si necesita una coincidencia exacta.';

  @override
  String templateFontPreview(String font) {
    return 'Vista previa: $font';
  }

  @override
  String get templateCancelImport => 'Cancelar importación';

  @override
  String get templateReplaceAndImport => 'Reemplazar e importar';

  @override
  String get templateExistsTitle => 'La plantilla ya existe';

  @override
  String templateExistsBody(String name) {
    return 'Ya existe una plantilla llamada \"$name\". ¿Reemplazar la copia guardada?';
  }

  @override
  String get templateNewName => 'Nombre nuevo';

  @override
  String get templateUploadFromDevice => 'Subir desde el dispositivo';

  @override
  String get templateUploadFromDeviceBody =>
      'Copia el archivo en su carpeta de imágenes de plantillas';

  @override
  String get templateSavedImages => 'Imágenes guardadas';

  @override
  String get templateNoSavedImages =>
      'Aún no hay imágenes guardadas; suba una primero.';

  @override
  String get templateName => 'Nombre de la plantilla';

  @override
  String get templateEnterName => 'Ingrese un nombre';

  @override
  String get templateSaveImportedAs => 'Guardar plantilla importada como';

  @override
  String templateMustDiffer(String name) {
    return 'Debe ser distinto de \"$name\"';
  }

  @override
  String get templateNameExists => 'Ya existe una plantilla con este nombre';

  @override
  String templateRecordTypeValue(String type) {
    return 'Tipo de registro: $type';
  }

  @override
  String get templateSides => 'Caras';

  @override
  String get templateOneSidedBody => 'Cree una plantilla solo con anverso.';

  @override
  String get templateTwoSided => '2 caras';

  @override
  String get templateTwoSidedBody =>
      'Cree diseños separados para el anverso y el reverso.';

  @override
  String get templateCreateNew => 'Crear plantilla nueva';

  @override
  String get templateOptions => 'Opciones de la plantilla';

  @override
  String get templateSaveAs => 'Guardar como…';

  @override
  String get templateChoose => 'Elegir plantilla';

  @override
  String get templateUntitled => 'Plantilla sin título';

  @override
  String get templateInsertField => 'Insertar campo';

  @override
  String get templateAllTaxa => 'Todos los taxones';

  @override
  String get templateEditCustomText => 'Editar texto personalizado';

  @override
  String get templateTextInput => 'Entrada de texto';

  @override
  String get templateTextInputHint => 'Ingrese texto o inserte campos…';

  @override
  String get templateAvailableSymbols => 'Símbolos disponibles';

  @override
  String get templateEnterText => 'Ingrese texto…';

  @override
  String templateRenamedTo(String name) {
    return 'Se cambió el nombre a $name';
  }

  @override
  String templateRenameFailed(String error) {
    return 'No se pudo cambiar el nombre: $error';
  }

  @override
  String templateSavedName(String name) {
    return 'Plantilla \"$name\" guardada';
  }

  @override
  String templateSavedFile(String file) {
    return 'Se guardó $file';
  }

  @override
  String templateReplacementInvalid(int index, String text, String message) {
    return 'El reemplazo de texto $index en \"$text\" no es válido: $message';
  }

  @override
  String templateImportedAndSaved(String name) {
    return '\"$name\" importada y guardada';
  }

  @override
  String get templateImportFailed =>
      'La importación falló o el archivo no es válido';

  @override
  String get templateUnsavedChanges => 'Cambios sin guardar';

  @override
  String get templateUnsavedChangesBody =>
      '¿Desea guardar los cambios de la plantilla antes de salir?';

  @override
  String get templateDiscard => 'Descartar';

  @override
  String get templatePreviewPartSelection =>
      'Selección de parte del espécimen para la vista previa';

  @override
  String get templatePreviewParasiteSelection =>
      'Selección de parásito para la vista previa';

  @override
  String get templatePreviewSpecimenSelection =>
      'Selección de espécimen para la vista previa';

  @override
  String get templateSizePreset => 'Tamaño predefinido de la plantilla';

  @override
  String get templateSizePaper => 'Papel';

  @override
  String get templateSizeCryotubes => 'Criotubos';

  @override
  String get templateSizeRangeHelper => 'Ingrese un valor entre 10 y 500 mm';

  @override
  String get templateSizeEnterWidth => 'Ingrese un ancho';

  @override
  String get templateSizeInvalidNumber => 'Ingrese un número válido';

  @override
  String get templateSizeOutOfRange => 'Debe estar entre 10 y 500';

  @override
  String get templateSizeEnterHeight => 'Ingrese un alto';

  @override
  String get templateSizeApplyCustom => 'Aplicar tamaño personalizado';

  @override
  String get templatePresetLetter => 'Carta';

  @override
  String get templatePresetLegal => 'Oficio';

  @override
  String get templatePresetVialSideLarge => 'Lateral de vial de 1.5 - 2.0 mL';

  @override
  String get templatePresetVialSideSmall => 'Lateral de vial de 0.5 - 1.0 mL';

  @override
  String get templatePresetCapDotSmall => 'Punto pequeño para tapa de vial';

  @override
  String get templatePresetCapDotLarge => 'Punto grande para tapa de vial';

  @override
  String get templatePresetSelfLaminating => 'Envoltura autolaminante';

  @override
  String get templatePresetPinnedLocality =>
      'Invertebrado montado en alfiler (localidad)';

  @override
  String get templatePresetPinnedTaxon =>
      'Invertebrado montado en alfiler (ID del taxón)';

  @override
  String get templatePresetJarInsert =>
      'Colección en fluido (inserto de frasco)';

  @override
  String get templatePresetVertebrateTag =>
      'Etiqueta de espécimen vertebrado (mediana)';

  @override
  String get templatePresetSkullBox => 'Caja de cráneo / microvial';

  @override
  String get templatePresetA4Description =>
      'Estándar internacional predeterminado para catálogos, informes y hojas de etiquetas.';

  @override
  String get templatePresetLetterDescription =>
      'Estándar norteamericano predeterminado para documentación e impresión matricial.';

  @override
  String get templatePresetLegalDescription =>
      'Lienzo extendido para bitácoras de campo largas, hojas de historial o tablas grandes.';

  @override
  String get templatePresetA5Description =>
      'Tamaño compacto ideal para libretas de campo de bolsillo e insertos pequeños.';

  @override
  String get templatePresetA3Description =>
      'Hoja grande para mapas, diseños de cajones de colección y cuadrículas del sistema.';

  @override
  String get templatePresetVialSideLargeDescription =>
      'Etiqueta lateral estándar. Caben 3-4 líneas de texto y un código de barras.';

  @override
  String get templatePresetVialSideSmallDescription =>
      'Perfil lateral compacto para alícuotas pequeñas de tejido o ADN.';

  @override
  String get templatePresetCapDotSmallDescription =>
      'Punto circular superior para tapas de tubos de 0.5–1.5 mL, para escaneo desde arriba.';

  @override
  String get templatePresetCapDotLargeDescription =>
      'Punto circular superior para tapas roscadas de criovial de 2.0 mL o más.';

  @override
  String get templatePresetSelfLaminatingDescription =>
      'El texto se imprime en una zona de 25.4x12.7 mm; la cola transparente lo envuelve y protege del nitrógeno líquido.';

  @override
  String get templatePresetPinnedLocalityDescription =>
      'Límite rígido para insectos montados en alfiler; caben 5-6 líneas de metadatos muy compactos.';

  @override
  String get templatePresetPinnedTaxonDescription =>
      'Tamaño mínimo; contiene género y especie, autor y datos del determinador.';

  @override
  String get templatePresetJarInsertDescription =>
      'Se coloca dentro de frascos húmedos (alcohol/formol). Alta legibilidad a través del vidrio curvo.';

  @override
  String get templatePresetVertebrateTagDescription =>
      'Etiqueta colgante estándar de tamaño mediano para curaduría de vertebrados.';

  @override
  String get templatePresetSkullBoxDescription =>
      'Optimizada para viales de vidrio de 1 a 2 dracmas o cajas osteológicas pequeñas de cartón.';

  @override
  String get templateElementImage => 'Imagen';

  @override
  String templateElementImageDetail(String width, String height) {
    return 'Imagen · $width × $height mm';
  }

  @override
  String get templateElementLine => 'Línea';

  @override
  String get templateElementEmptyText => 'Texto vacío';

  @override
  String get mediaGallery => 'Galería';

  @override
  String get mediaActions => 'Acciones';

  @override
  String get mediaDeleteSelectedTitle =>
      '¿Eliminar los archivos multimedia seleccionados?';

  @override
  String get mediaDeleteSelectedBody =>
      '¿Eliminar los archivos multimedia seleccionados de todos los registros de NAHPU y del disco? Esta acción no se puede deshacer.';

  @override
  String mediaSelectedCount(int count) {
    return '$count seleccionados';
  }

  @override
  String get mediaNoneAdded => 'No se agregaron archivos multimedia';

  @override
  String get mediaAdd => 'Agregar multimedia';

  @override
  String get mediaTakePhotosVideos => 'Tomar fotos/videos';

  @override
  String get mediaRecordAudio => 'Grabar audio';

  @override
  String get mediaAddFromGallery => 'Agregar desde la galería';

  @override
  String get mediaAddFromFile => 'Agregar desde un archivo';

  @override
  String get mediaUnavailable => 'Multimedia no disponible';

  @override
  String get mediaFileMissing => 'Falta el archivo';

  @override
  String get mediaImageUnavailable => 'Imagen no disponible';

  @override
  String get mediaNone => 'Sin multimedia';

  @override
  String get mediaMenuActions => 'Acciones de multimedia';

  @override
  String get mediaShowInfo => 'Mostrar información';

  @override
  String get mediaEdit => 'Editar multimedia';

  @override
  String get mediaInfo => 'Información del archivo multimedia';

  @override
  String get mediaDeleteFileTitle => '¿Eliminar archivo multimedia?';

  @override
  String mediaDeleteFileBody(String name) {
    return '¿Eliminar $name de todos los registros de NAHPU y del disco? Esta acción no se puede deshacer.';
  }

  @override
  String get mediaDeleteThisFileBody =>
      '¿Eliminar este archivo multimedia de todos los registros de NAHPU y del disco? Esta acción no se puede deshacer.';

  @override
  String get mediaFileAlreadyExists => 'El archivo ya existe';

  @override
  String get mediaFileName => 'Nombre del archivo';

  @override
  String get mediaFileNameHint => 'Ingrese un nombre de archivo';

  @override
  String get mediaCaption => 'Leyenda';

  @override
  String get mediaCaptionHint => 'Ingrese una leyenda';

  @override
  String get mediaTag => 'Etiqueta';

  @override
  String get mediaTagHint => 'Ingrese una etiqueta';

  @override
  String get mediaPhotographer => 'Fotógrafo';

  @override
  String get mediaSelectPersonnel => 'Seleccione personal';

  @override
  String get mediaClearPhotographer => 'Quitar fotógrafo';

  @override
  String get mediaExportSelected => 'Exportar multimedia seleccionada';

  @override
  String get mediaExporting => 'Exportando multimedia';

  @override
  String get mediaExportingHint =>
      'Las selecciones grandes pueden tardar varios minutos. Mantenga NAHPU abierto hasta que termine.';

  @override
  String get mediaExport => 'Exportar multimedia';

  @override
  String get mediaExportLeaveBody =>
      'La exportación sigue en curso. Si sale ahora, se cancelará y no se guardará ningún archivo.';

  @override
  String get mediaArchive => 'Archivo de multimedia';

  @override
  String get mediaImageFormat => 'Formato de imagen';

  @override
  String get mediaLimitDimensions => 'Limitar las dimensiones de la imagen';

  @override
  String get mediaLimitDimensionsBody => 'Limita el lado más largo sin ampliar';

  @override
  String get mediaMaxDimension => 'Ancho o alto máximo (px)';

  @override
  String get mediaMaxDimensionHelper => 'Se aplica al lado más largo.';

  @override
  String get mediaJpegQuality => 'Calidad JPEG';

  @override
  String get mediaImages => 'Imágenes';

  @override
  String get mediaAudio => 'Audio';

  @override
  String get mediaVideo => 'Video';

  @override
  String get mediaOther => 'Otros';

  @override
  String get mediaSourceSize => 'Tamaño de origen';

  @override
  String get mediaExported => 'Exportados';

  @override
  String mediaWarningCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count advertencias',
      one: '1 advertencia',
    );
    return '$_temp0';
  }

  @override
  String mediaCannotConvert(String format) {
    return '$format no se puede convertir y se mantendrá en su formato original.';
  }

  @override
  String get mediaPause => 'Pausar';

  @override
  String get mediaPlay => 'Reproducir';

  @override
  String mediaPlaybackUnavailable(String error) {
    return 'La vista previa de reproducción no está disponible: $error';
  }

  @override
  String get mediaCameraAccessRequired =>
      'Se requiere acceso a la cámara para tomar fotos y videos.';

  @override
  String get mediaMicrophoneAccessRequired =>
      'Se requiere acceso al micrófono para grabar video.';

  @override
  String get mediaCameraError => 'No se pudo usar la cámara.';

  @override
  String get mediaPhoto => 'Foto';

  @override
  String get mediaSwitchCamera => 'Cambiar de cámara';

  @override
  String get mediaStopRecording => 'Detener grabación';

  @override
  String get mediaRecordVideo => 'Grabar video';

  @override
  String get mediaRetake => 'Repetir';

  @override
  String get mediaUse => 'Usar';

  @override
  String get mediaDetailFile => 'Archivo';

  @override
  String get mediaCategory => 'Categoría';

  @override
  String get mediaCaptureEquipment => 'Captura y equipo';

  @override
  String get mediaTaken => 'Tomada';

  @override
  String get mediaCamera => 'Cámara';

  @override
  String get mediaLenses => 'Lentes';

  @override
  String get mediaAdditionalExif => 'EXIF adicional';

  @override
  String get mediaId => 'ID del archivo multimedia';

  @override
  String get mediaSecondaryId => 'ID secundario';

  @override
  String get mediaPhotographerId => 'ID del fotógrafo';

  @override
  String get mediaLinkedInformation => 'Información vinculada';

  @override
  String mediaLinkedInformationError(String error) {
    return 'La información vinculada no está disponible: $error';
  }

  @override
  String get mediaResume => 'Reanudar';

  @override
  String get mediaPausePlayback => 'Pausar reproducción';

  @override
  String get mediaPlayRecording => 'Reproducir grabación';

  @override
  String get mediaRecordingNotSaved => 'La grabación de audio no se guardó.';

  @override
  String get mediaImageSettings => 'Configuración de imagen';

  @override
  String mediaOriginalSize(int width, int height) {
    return 'Original: $width × $height px';
  }

  @override
  String get mediaResizeImage => 'Cambiar tamaño de la imagen';

  @override
  String get mediaAspectLocked => 'La relación de aspecto está bloqueada';

  @override
  String get mediaWidthPx => 'Ancho (px)';

  @override
  String mediaMaxValue(int value) {
    return 'Máx. $value';
  }

  @override
  String get mediaHeightPx => 'Alto (px)';

  @override
  String get mediaSearchMetadata => 'Buscar en los metadatos multimedia';

  @override
  String get mediaGalleryTitle => 'Galería multimedia';

  @override
  String get mediaGalleryAllProjectsTitle => 'Todos los medios';

  @override
  String get mediaFilterProject => 'Filtrar por proyecto';

  @override
  String get mediaAllProjects => 'Todos los proyectos';

  @override
  String get mediaSearch => 'Buscar multimedia';

  @override
  String get mediaDeleteSelected => 'Eliminar multimedia seleccionada';

  @override
  String get mediaCategoryEvent => 'Evento';

  @override
  String get mediaSort => 'Ordenar multimedia';

  @override
  String get mediaNoMatching => 'Ningún archivo multimedia coincide';

  @override
  String get mediaSortAddedNewest => 'Agregados recientemente';

  @override
  String get mediaSortAddedOldest => 'Agregados hace más tiempo';

  @override
  String get mediaSortFileNameAsc => 'Nombre de archivo A–Z';

  @override
  String get mediaSortFileNameDesc => 'Nombre de archivo Z–A';

  @override
  String get mediaSortTakenNewest => 'Fecha de toma, más reciente';

  @override
  String get mediaSortTakenOldest => 'Fecha de toma, más antigua';

  @override
  String get mediaHideDetails => 'Ocultar detalles';

  @override
  String get mediaShowDetails => 'Mostrar detalles';

  @override
  String get mediaPrevious => 'Anterior';

  @override
  String get mediaMute => 'Silenciar';

  @override
  String get mediaUnmute => 'Activar sonido';

  @override
  String get mediaPlaybackSpeed => 'Velocidad de reproducción';

  @override
  String get mediaExitFullscreen => 'Salir de pantalla completa';

  @override
  String get mediaFullscreen => 'Pantalla completa';

  @override
  String mediaCannotDisplay(String kind) {
    return 'No se puede mostrar este archivo de $kind';
  }

  @override
  String get mediaBarcode => 'Código de barras';

  @override
  String get mediaScanQrCode => 'Escanear código QR';

  @override
  String get mediaScanBarcode => 'Escanear código de barras';

  @override
  String get mediaAlignQrCode => 'Alinee el código QR dentro del marco';

  @override
  String get mediaAlignBarcode => 'Alinee el código de barras dentro del marco';

  @override
  String get mediaQrTooLarge =>
      'Los datos son demasiado grandes para un código QR.\nExpórtelos como archivo.';

  @override
  String get associatedUnnamed => 'Datos asociados sin nombre';

  @override
  String get associatedFileUnavailable => 'Archivo no disponible';

  @override
  String get associatedTypeLink => 'Enlace';

  @override
  String get associatedUnknownType => 'Tipo desconocido';

  @override
  String get associatedNoResource => 'Sin recurso';

  @override
  String get associatedActions => 'Acciones de datos asociados';

  @override
  String get associatedOpenInDefaultApp =>
      'Abrir en la aplicación predeterminada';

  @override
  String get associatedOpenLink => 'Abrir enlace';

  @override
  String get associatedNoUriToShare => 'No hay ningún URI para compartir.';

  @override
  String get associatedFileNotFound => 'No se encontró el archivo';

  @override
  String get associatedInvalidUri => 'URI no válido.';

  @override
  String associatedCouldNotOpen(String uri) {
    return 'No se pudo abrir $uri';
  }

  @override
  String get associatedAdd => 'Agregar datos asociados';

  @override
  String get associatedNoneAdded => 'No se agregaron datos asociados';

  @override
  String get associatedEdit => 'Editar datos asociados';

  @override
  String get associatedDataType => 'Tipo de datos';

  @override
  String get associatedDataTypeHint => 'Seleccione el tipo de datos';

  @override
  String get associatedNameHint => 'p. ej., GenBank o MorphoSource';

  @override
  String get associatedDescriptionHint => 'Describa los datos asociados';

  @override
  String get associatedResource => 'Recurso';

  @override
  String get associatedNonMediaFiles => 'Archivos que no son multimedia';

  @override
  String get associatedCopyToProject => 'Copiar al proyecto';

  @override
  String get associatedLinkOriginal => 'Vincular original';

  @override
  String get associatedLinkOriginalWarning =>
      'El vínculo dejará de funcionar si el archivo original se mueve o elimina.';

  @override
  String get associatedSelectDataType => 'Seleccione un tipo de datos.';

  @override
  String get associatedEnterValidUri => 'Ingrese un URI válido.';

  @override
  String get associatedSelectFile => 'Seleccione un archivo.';

  @override
  String get associatedNoIdentifier =>
      'Los datos asociados no tienen identificador.';

  @override
  String get associatedInfo => 'Información de los datos asociados';

  @override
  String get associatedOriginStoragePath => 'Ruta de almacenamiento de origen';

  @override
  String get associatedLinkedOriginal => 'Original vinculado';

  @override
  String get associatedProjectCopy => 'Copia en el proyecto';

  @override
  String get associatedAvailability => 'Disponibilidad';

  @override
  String get associatedChecking => 'Comprobando…';

  @override
  String get legalReadThe => 'Lea los ';

  @override
  String get legalTermsAndConditions => 'Términos y condiciones';

  @override
  String get legalAndThe => ' y la ';

  @override
  String get legalPrivacyPolicy => 'Política de privacidad';

  @override
  String get legalBeforeYouStart =>
      ' antes de comenzar. Al usar NAHPU, los acepta.';

  @override
  String get legalTermsTile => 'Términos y condiciones';

  @override
  String get legalPrivacyTile => 'Política de privacidad';

  @override
  String get mapCenterOnCoordinates => 'Centrar el mapa en las coordenadas';

  @override
  String mapMoreCount(int count) {
    return '+$count más';
  }

  @override
  String get mapTapToZoomIn => 'Toque para acercar';

  @override
  String get mapNaturalEarthOffline => 'Natural Earth · sin conexión';

  @override
  String get mapRetryDetailed => 'Volver a intentar el mapa detallado';

  @override
  String get siteAddCoordinates => 'Agregar coordenadas';

  @override
  String get siteViewMap => 'Ver mapa';

  @override
  String siteAddSelected(int count) {
    return 'Agregar $count seleccionadas';
  }

  @override
  String get siteNewCoordinate => 'Coordenada nueva';

  @override
  String get siteSupportedFiles => 'Archivos compatibles:';

  @override
  String get siteSupportedFileTypes =>
      'CSV, TSV, Excel, GeoJSON/JSON, KML, Shapefile comprimido y GPX.';

  @override
  String get siteSelectCoordinateFile => 'Seleccionar archivo de coordenadas';

  @override
  String siteRowsSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filas omitidas',
      one: '1 fila omitida',
    );
    return '$_temp0';
  }

  @override
  String get siteEditColumnMapping => 'Editar asignación de columnas';

  @override
  String get siteChooseAnotherFile => 'Elegir otro archivo';

  @override
  String get siteCoordinateChanged =>
      'La coordenada cambió. Actualice el mapa para ver la vista previa.';

  @override
  String get siteEnterValidCoordinate =>
      'Ingrese una latitud y longitud WGS84 válidas y actualice el mapa.';

  @override
  String get siteRefreshMap => 'Actualizar mapa';

  @override
  String get siteEditCoordinates => 'Editar coordenadas';

  @override
  String get siteAddName => 'Agregue un nombre';

  @override
  String get siteDeviceGps => 'GPS del dispositivo';

  @override
  String get siteDeviceGpsBody =>
      'Use el sensor del dispositivo para completar las coordenadas';

  @override
  String get siteGetLocation => 'Obtener ubicación';

  @override
  String get siteCoordinateFormat => 'Formato de coordenadas';

  @override
  String get siteDecimalDegrees => 'Grados decimales';

  @override
  String get siteDdm => 'Grados y minutos decimales (GMD)';

  @override
  String get siteDms => 'Grados, minutos y segundos (GMS)';

  @override
  String get siteUtm => 'UTM (WGS84)';

  @override
  String get siteUtmCoordinate => 'Coordenada UTM';

  @override
  String get siteDecimalLatitude => 'Latitud decimal';

  @override
  String get siteAddLatitude => 'Agregue una latitud';

  @override
  String get siteDecimalLongitude => 'Longitud decimal';

  @override
  String get siteAddLongitude => 'Agregue una longitud';

  @override
  String get siteAddElevation => 'Agregue una elevación';

  @override
  String get siteSpecifyDatum => 'Especifique el datum';

  @override
  String get siteAddUncertainty => 'Agregue una incertidumbre';

  @override
  String get siteGpsUnit => 'Unidad GPS';

  @override
  String get siteSpecifyGpsUnit => 'Especifique la unidad GPS';

  @override
  String get siteAddNotes => 'Agregue notas (opcional)';

  @override
  String get siteChangeFormatTitle => '¿Cambiar el formato de coordenadas?';

  @override
  String get siteChangeFormatBody =>
      'Cambiar el formato borra los valores de coordenadas ingresados. Se conservan el nombre, la elevación, el datum, la incertidumbre, la unidad GPS y las notas.';

  @override
  String get siteClearAndSwitch => 'Borrar y cambiar';

  @override
  String siteInvalidVerbatim(String axis, String value) {
    return 'No se pudo leer esta $axis textual y puede haberse modificado fuera de NAHPU. Vuelva a ingresarla antes de guardar.\nOriginal: $value';
  }

  @override
  String get siteMissingValue => '(falta)';

  @override
  String get siteDegree => 'Grado';

  @override
  String get siteMinute => 'Minuto';

  @override
  String get siteSecond => 'Segundo';

  @override
  String get siteManageCoordinates => 'Administrar coordenadas';

  @override
  String get siteCoordinateMap => 'Mapa de coordenadas';

  @override
  String siteExportCoordinatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Exportar $count coordenadas',
      one: 'Exportar 1 coordenada',
    );
    return '$_temp0';
  }

  @override
  String get siteFormatGeoJson => 'GeoJSON (.geojson)';

  @override
  String get siteFormatShapefile => 'Paquete Shapefile (.zip)';

  @override
  String get siteShowCoordinates => 'Mostrar coordenadas';

  @override
  String get siteAllCoordinates => 'Todas las coordenadas';

  @override
  String siteLoadSitesError(String error) {
    return 'No se pudieron cargar los sitios: $error';
  }

  @override
  String siteLoadCoordinatesError(String error) {
    return 'No se pudieron cargar las coordenadas: $error';
  }

  @override
  String siteExportSelectedCoordinates(int count) {
    return 'Exportar coordenadas ($count)';
  }

  @override
  String get siteNoCoordinates => 'No se agregaron coordenadas';

  @override
  String siteSelectedOfCoordinates(int count, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total coordenadas',
      one: '1 coordenada',
    );
    return '$count de $_temp0';
  }

  @override
  String siteUnnamedCoordinateId(String id) {
    return 'Coordenada sin nombre ($id)';
  }

  @override
  String siteCoordinatesNotShown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count coordenadas no se muestran porque falta la latitud o la longitud o no es válida.',
      one:
          '1 coordenada no se muestra porque falta la latitud o la longitud o no es válida.',
    );
    return '$_temp0';
  }

  @override
  String get siteCoordinateActions => 'Acciones de coordenadas';

  @override
  String get siteCopy => 'Copiar';

  @override
  String get siteOpenInMap => 'Abrir en el mapa';

  @override
  String get siteCoordinateDetails => 'Detalles de la coordenada';

  @override
  String get siteCopiedToClipboard =>
      'Latitud y longitud copiadas al portapapeles';

  @override
  String get siteNoName => 'Sin nombre';

  @override
  String get siteOriginalCoordinate => 'Coordenada original';

  @override
  String get siteOriginalFormat => 'Formato original';

  @override
  String get siteUncertainty => 'Incertidumbre';

  @override
  String get siteUnnamedCoordinate => 'Coordenada sin nombre';

  @override
  String get siteAddCoordinate => 'Agregar coordenada';

  @override
  String get siteNoId => 'Sin ID';

  @override
  String siteColumnsDetected(int columns, int rows) {
    return 'Se detectaron $columns columnas y $rows filas de datos. NAHPU dedujo las coincidencias de abajo. La latitud y la longitud son obligatorias; los demás campos son opcionales.';
  }

  @override
  String siteColumnsDetectedInWorksheet(
    int columns,
    int rows,
    String worksheet,
  ) {
    return 'Se detectaron $columns columnas y $rows filas de datos en la hoja \"$worksheet\". NAHPU dedujo las coincidencias de abajo. La latitud y la longitud son obligatorias; los demás campos son opcionales.';
  }

  @override
  String get siteNotIncluded => 'No incluido';

  @override
  String siteHeaderColumn(String header, int index) {
    return '$header (columna $index)';
  }

  @override
  String get siteReviewCoordinates => 'Revisar coordenadas';

  @override
  String get siteImportFieldNameId => 'Nombre / ID';

  @override
  String get siteCopyFromProject => 'Copiar desde un proyecto';

  @override
  String get siteChooseDataToCopy => 'Elegir datos para copiar';

  @override
  String get siteSelectSourceProject =>
      'Seleccione el proyecto que contiene el sitio que desea copiar.';

  @override
  String siteSelectFromProject(String project) {
    return 'Seleccione un sitio de $project.';
  }

  @override
  String get siteNoSitesInProject =>
      'No se encontraron sitios en este proyecto.';

  @override
  String get siteSelectDataToCopy =>
      'Seleccione los datos que desea copiar en el sitio vacío.';

  @override
  String get siteNoCopyableData =>
      'El sitio seleccionado no tiene datos que se puedan copiar.';

  @override
  String get siteNoDataInSource => 'Sin datos en el origen';

  @override
  String get siteMustBeEmptyBody =>
      'El sitio actual debe estar vacío antes de copiar datos. Primero borre su información, coordenadas, multimedia y datos vinculados.';

  @override
  String get siteMustBeEmpty => 'El sitio debe estar vacío';

  @override
  String get siteNeedAnotherProject =>
      'Cree o importe otro proyecto antes de copiar datos del sitio.';

  @override
  String get siteMultipleProjectsRequired => 'Se requieren varios proyectos';

  @override
  String siteUnnamedSite(String id) {
    return 'Sitio sin nombre n.º $id';
  }

  @override
  String siteGeographySettingsError(String error) {
    return 'No se pudo cargar la configuración geográfica: $error';
  }

  @override
  String get siteFindLocalityTooltip =>
      'Escriba una localidad y seleccione una guardada para completar todos los campos geográficos';

  @override
  String get siteFindLocality => 'Buscar una localidad existente';

  @override
  String get siteFindLocalityHint =>
      'Escriba para reutilizar una localidad guardada';

  @override
  String get siteEnterCountry => 'Ingrese un país';

  @override
  String get siteEnterIslandGroup => 'Ingrese un grupo de islas';

  @override
  String get siteEnterStateProvince => 'Ingrese un estado/provincia';

  @override
  String get siteEnterCounty => 'Ingrese un condado/parroquia/distrito';

  @override
  String get siteEnterMunicipality => 'Ingrese un municipio/ciudad/pueblo';

  @override
  String get sitePreciseLocality => 'Localidad precisa';

  @override
  String get sitePreciseLocalityHint =>
      'Ingrese una localidad precisa de nivel inferior al municipio';

  @override
  String get siteRemarksHint =>
      'Ingrese más información sobre el sitio (opcional)';

  @override
  String get siteHabitatType => 'Tipo de hábitat';

  @override
  String get siteHabitatTypeHint => 'Seleccione un tipo de hábitat';

  @override
  String get siteHabitatCondition => 'Condición del hábitat';

  @override
  String get siteHabitatConditionHint =>
      'P. ej., \"Prístino\", \"Perturbado\", etc.';

  @override
  String get siteHabitatDescription => 'Descripción del hábitat';

  @override
  String get siteHabitatDescriptionHint =>
      'Describa el sitio, p. ej., \"Un campamento en medio del bosque\".';

  @override
  String get siteCanopyCover => 'Cobertura del dosel';

  @override
  String get siteCanopyCoverHint => 'Ingrese la cobertura del dosel';

  @override
  String get siteCreate => 'Crear sitio';

  @override
  String get siteActions => 'Acciones del sitio';

  @override
  String get siteDuplicate => 'Duplicar sitio';

  @override
  String get siteCopyFromProjectMenu => 'Copiar desde un proyecto…';

  @override
  String get siteExport => 'Exportar sitio';

  @override
  String get siteImport => 'Importar sitio';

  @override
  String siteCopiedSummary(
    String fields,
    String coordinates,
    String site,
    String project,
  ) {
    return 'Se copiaron $fields y $coordinates de $site en $project.';
  }

  @override
  String siteFieldCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count campos',
      one: '1 campo',
    );
    return '$_temp0';
  }

  @override
  String get siteDeleteTitle => '¿Eliminar sitio?';

  @override
  String get siteDeleteBody =>
      'Eliminará todos los registros de este formulario de sitio';

  @override
  String get siteDeleteAllTitle => '¿Eliminar todos los sitios?';

  @override
  String get siteDeleteAllBody => 'Eliminará todos los registros de sitios';

  @override
  String get siteDeleteInUse =>
      'No se pueden eliminar los sitios. Otros registros los usan.';

  @override
  String get siteIdentity => 'Identidad del sitio';

  @override
  String get siteIdHint =>
      'Ingrese un ID de sitio (máx. 40 caracteres), p. ej., \"CAMP-01\", \"LINE-1\"';

  @override
  String get siteLeader => 'Responsable del sitio';

  @override
  String get siteType => 'Tipo de sitio';

  @override
  String get siteTypeHint => 'Elija un tipo de sitio';

  @override
  String get siteSearch => 'Buscar sitios';

  @override
  String get siteRecordTitle => 'Registro de sitio';

  @override
  String get siteNoneFound => 'No se encontró ningún sitio';

  @override
  String get siteCopyFieldSiteLeader => 'Responsable del sitio';

  @override
  String get siteCopyFieldSiteType => 'Tipo de sitio';

  @override
  String get siteCopyFieldPreciseLocality => 'Localidad precisa';

  @override
  String get siteCopyFieldHabitatType => 'Tipo de hábitat';

  @override
  String get siteCopyFieldHabitatCondition => 'Condición del hábitat';

  @override
  String get siteCopyFieldHabitatDescription => 'Descripción del hábitat';

  @override
  String get siteCopyFieldCanopyCover => 'Cobertura del dosel';

  @override
  String eventEnvironmentLoadError(String error) {
    return 'No se pudieron cargar los datos ambientales: $error';
  }

  @override
  String get eventDayLowest => 'Mínima diurna';

  @override
  String get eventDayHighest => 'Máxima diurna';

  @override
  String get eventNightLowest => 'Mínima nocturna';

  @override
  String get eventNightHighest => 'Máxima nocturna';

  @override
  String get eventAverage => 'Promedio';

  @override
  String get eventDewPoint => 'Punto de rocío';

  @override
  String get eventEnterLowestTemp => 'Ingrese la temperatura mínima';

  @override
  String get eventEnterHighestTemp => 'Ingrese la temperatura máxima';

  @override
  String get eventEnterAverageHumidity => 'Ingrese la humedad promedio';

  @override
  String get eventEnterDewPoint => 'Ingrese el punto de rocío';

  @override
  String get eventCloudCover => 'Nubosidad (octas)';

  @override
  String get eventCloudCoverHint => 'Seleccione la nubosidad';

  @override
  String get eventCloudCoverHelper =>
      'Una octa representa un octavo del cielo visible.';

  @override
  String eventInvalidStoredValue(String value) {
    return '$value — Valor guardado no válido';
  }

  @override
  String get eventEnterRainfall => 'Ingrese la precipitación';

  @override
  String get eventEnterAmbientTemp => 'Ingrese la temperatura ambiente';

  @override
  String get eventEnterRelativeHumidity => 'Ingrese la humedad relativa';

  @override
  String get eventEnterWaterTemp => 'Ingrese la temperatura del agua';

  @override
  String get eventEnterPh => 'Ingrese el pH';

  @override
  String get eventEnterDissolvedOxygen => 'Ingrese el oxígeno disuelto';

  @override
  String get eventEnterOxygenSaturation =>
      'Ingrese la saturación de oxígeno disuelto';

  @override
  String get eventEnterConductivity => 'Ingrese la conductividad';

  @override
  String get eventEnterFlowVelocity => 'Ingrese la velocidad del flujo';

  @override
  String get eventEnterSunrise => 'Ingrese la hora del amanecer';

  @override
  String get eventEnterSunset => 'Ingrese la hora del atardecer';

  @override
  String get eventMoonPhaseHint => 'Seleccione la fase lunar';

  @override
  String eventRecoveryTitle(int count) {
    return 'Algunos valores ambientales guardados requieren atención ($count)';
  }

  @override
  String get eventRecoveryBody =>
      'Corrija o borre los campos resaltados. Los demás valores no se modificarán.';

  @override
  String eventSaveValueError(String error) {
    return 'No se pudo guardar este valor: $error';
  }

  @override
  String get eventEnterValidNumber => 'Ingrese un número válido.';

  @override
  String eventValueRange(String minimum, String maximum) {
    return 'Ingrese un valor de $minimum a $maximum';
  }

  @override
  String eventValueMinimum(String minimum) {
    return 'Ingrese un valor de $minimum o más';
  }

  @override
  String get eventOkta0 => '0 — Cielo despejado';

  @override
  String get eventOkta1 => '1 — Hasta 1/8 cubierto';

  @override
  String get eventOkta2 => '2 — 2/8 cubierto';

  @override
  String get eventOkta3 => '3 — 3/8 cubierto';

  @override
  String get eventOkta4 => '4 — Medio cubierto';

  @override
  String get eventOkta5 => '5 — 5/8 cubierto';

  @override
  String get eventOkta6 => '6 — 6/8 cubierto';

  @override
  String get eventOkta7 => '7 — Al menos 7/8, sin cubrir por completo';

  @override
  String get eventOkta8 => '8 — Completamente cubierto';

  @override
  String get eventOkta9 => '9 — Cielo oculto';

  @override
  String get eventMoonNew => 'Luna nueva';

  @override
  String get eventMoonWaxingCrescent => 'Luna creciente';

  @override
  String get eventMoonFirstQuarter => 'Cuarto creciente';

  @override
  String get eventMoonWaxingGibbous => 'Gibosa creciente';

  @override
  String get eventMoonFull => 'Luna llena';

  @override
  String get eventMoonWaningGibbous => 'Gibosa menguante';

  @override
  String get eventMoonLastQuarter => 'Cuarto menguante';

  @override
  String get eventMoonWaningCrescent => 'Luna menguante';

  @override
  String get eventActivity => 'Actividad';

  @override
  String get eventPrimaryActivity => 'Actividad principal';

  @override
  String get eventSelectActivity => 'Seleccione una actividad';

  @override
  String eventActivitiesLoadError(String error) {
    return 'No se pudieron cargar las actividades principales: $error';
  }

  @override
  String get eventActivityNotesHint => 'Ingrese notas sobre la actividad';

  @override
  String get eventAddCollMethod => 'Agregar método de colecta';

  @override
  String get eventNoCollMethods => 'No se agregaron métodos de colecta';

  @override
  String get eventAddCollMethodTitle => 'Agregar método de colecta';

  @override
  String get eventEditCollMethod => 'Editar método de colecta';

  @override
  String get eventCollMethod => 'Método de colecta';

  @override
  String get eventCountHint =>
      '¿Cuántas unidades de esta herramienta se usaron (si corresponde)?';

  @override
  String get eventMethodDetails => 'Detalles del método';

  @override
  String get eventBrandModel => 'Marca y modelo';

  @override
  String get eventBrandModelHint =>
      'Ingrese la marca y el modelo de la herramienta (si corresponde)';

  @override
  String get eventSizeHint =>
      'Ingrese el tamaño de la herramienta (si corresponde)';

  @override
  String get eventToolNotesHint =>
      'Ingrese notas sobre la herramienta (si corresponde)';

  @override
  String get eventSelectMethod => 'Seleccione un método';

  @override
  String get eventIdentity => 'Identidad del evento';

  @override
  String get eventStartDate => 'Fecha de inicio';

  @override
  String get eventEndDate => 'Fecha de fin';

  @override
  String get eventEditId => 'Editar ID del evento';

  @override
  String get eventIdSuffix => 'Sufijo del ID';

  @override
  String get eventIdSuffixHint => 'Ingrese el sufijo del ID';

  @override
  String get eventIdLabel => 'ID del evento: ';

  @override
  String get eventStartTime => 'Hora de inicio';

  @override
  String get eventEndTime => 'Hora de fin';

  @override
  String get eventCreate => 'Crear evento';

  @override
  String get eventDeleteInUse =>
      'No se pudieron eliminar los eventos. Otros registros los están usando.';

  @override
  String get eventActions => 'Acciones del evento';

  @override
  String get eventDuplicate => 'Duplicar evento';

  @override
  String get eventExport => 'Exportar evento';

  @override
  String get eventImport => 'Importar evento';

  @override
  String get eventDeleteTitle => '¿Eliminar el evento de colecta?';

  @override
  String get eventDeleteBody =>
      'También eliminará los métodos de colecta, el personal de colecta, los datos ambientales y la multimedia de este evento.';

  @override
  String get eventDeleteAllTitle => '¿Eliminar todos los eventos de colecta?';

  @override
  String get eventDeleteAllBody =>
      'Al eliminar todos los eventos de colecta también se eliminarán de la base de datos los métodos de colecta, el personal de colecta, los datos ambientales y la multimedia asociados.';

  @override
  String get eventPersonnel => 'Personal del evento';

  @override
  String get eventNoPersonnel => 'No se agregó personal';

  @override
  String get eventUnknownPersonnel => 'Personal desconocido';

  @override
  String get eventEnterRole => 'Ingrese un rol';

  @override
  String get eventSearch => 'Buscar eventos';

  @override
  String get eventRecordTitle => 'Registro de evento de colecta';

  @override
  String get eventNoneFound => 'No se encontró ningún evento de colecta';

  @override
  String exportPresetsLoadError(String error) {
    return 'No se pudieron cargar los ajustes de exportación: $error';
  }

  @override
  String get exportPreset => 'Ajuste de exportación';

  @override
  String get exportNoPresets =>
      'No se encontraron ajustes de exportación. Administre los ajustes en la configuración para crear uno.';

  @override
  String get exportManagePresetsButton => 'Administrar ajustes';

  @override
  String get exportPresetHelper =>
      'El tipo de registro, los encabezados y las asignaciones de campos los define el ajuste.';

  @override
  String get exportPresetDetails => 'Detalles del ajuste';

  @override
  String get exportSelectPresetPrompt =>
      'Seleccione un ajuste de exportación para ver los detalles y la vista previa.';

  @override
  String exportPresetName(String name) {
    return 'Ajuste: $name';
  }

  @override
  String exportPresetRecord(String type) {
    return 'Registro: $type';
  }

  @override
  String exportPresetTaxon(String taxon) {
    return 'Taxón: $taxon';
  }

  @override
  String exportPresetHeader(String format) {
    return 'Encabezado: $format';
  }

  @override
  String exportSelectedColumns(int count) {
    return 'Columnas seleccionadas ($count):';
  }

  @override
  String get exportPreviewTable => 'Vista previa de la tabla';

  @override
  String get exportNoFieldsMapped => 'Este ajuste no tiene campos asignados.';

  @override
  String exportNestedFields(String namespace, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count campos',
      one: '1 campo',
    );
    return '$namespace ($_temp0)';
  }

  @override
  String get exportTablePreview => 'Vista previa de la tabla';

  @override
  String get exportNoRecordsForPreset =>
      'No se encontraron registros para este ajuste.';

  @override
  String exportShowingRecords(int start, int end, int total) {
    return 'Mostrando $start-$end de $total registros';
  }

  @override
  String exportPageOf(int page, int total) {
    return 'Página $page de $total';
  }

  @override
  String get exportBundling => 'Empaquetando registros';

  @override
  String get exportBundlingHint =>
      'El empaquetado escribe los registros, copia la multimedia, comprime el paquete y luego lo verifica. Mantenga NAHPU abierto.';

  @override
  String get exportCreateBundle => 'Crear paquete';

  @override
  String get exportBundleAnother => 'Empaquetar otro';

  @override
  String get exportCancelBundleTitle => '¿Cancelar el paquete?';

  @override
  String get exportCancelBundleBody =>
      'El paquete aún se está escribiendo. Si sale ahora, se cancelará y no se guardará ningún paquete.';

  @override
  String get exportKeepBundling => 'Seguir empaquetando';

  @override
  String get exportCancelBundle => 'Cancelar paquete';

  @override
  String exportCreatedFile(String file) {
    return 'Se creó $file';
  }

  @override
  String get exportBundleComplete => '¡Paquete completo!';

  @override
  String get exportCompleteData => 'Datos completos de NAHPU';

  @override
  String get exportCompleteDataBody =>
      'Este paquete incluye todas las tablas de la base de datos de NAHPU, una instantánea restaurable del proyecto, las configuraciones del usuario, la multimedia disponible y las fuentes personalizadas.';

  @override
  String get exportFrictionless =>
      'La exportación está en formato Frictionless Data.';

  @override
  String get exportRecordedTaxa => 'Taxones registrados';

  @override
  String get exportSelectedTaxa => 'Taxones seleccionados';

  @override
  String get exportNoTaxaRecorded =>
      'Aún no se han registrado taxones de especímenes.';

  @override
  String exportTaxonGroupsIncluded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se incluirán $count grupos taxonómicos registrados.',
      one: 'Se incluirá 1 grupo taxonómico registrado.',
    );
    return '$_temp0';
  }

  @override
  String get exportPackageContents => 'Contenido del paquete';

  @override
  String get exportSelectTaxonPrompt =>
      'Seleccione al menos un taxón registrado para ver el contenido del paquete.';

  @override
  String get exportPackageContentsBody =>
      'La lista refleja exactamente lo que se empaquetará. Se omiten los campos y tablas opcionales vacíos.';

  @override
  String exportRecordsAndFields(int records, int fields) {
    String _temp0 = intl.Intl.pluralLogic(
      records,
      locale: localeName,
      other: '$records registros',
      one: '1 registro',
    );
    String _temp1 = intl.Intl.pluralLogic(
      fields,
      locale: localeName,
      other: '$fields campos',
      one: '1 campo',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get exportBackingUp => 'Respaldando la base de datos';

  @override
  String get exportBackingUpHint =>
      'Las bibliotecas multimedia grandes pueden tardar varios minutos. Mantenga NAHPU abierto hasta que termine.';

  @override
  String get exportSaveBackup => 'Guardar respaldo';

  @override
  String get exportSaveAnother => 'Guardar otro';

  @override
  String get exportCancelBackupTitle => '¿Cancelar el respaldo?';

  @override
  String get exportCancelBackupBody =>
      'El respaldo sigue en curso. Si sale ahora, se cancelará y no se guardará ningún archivo.';

  @override
  String get exportKeepBackingUp => 'Seguir respaldando';

  @override
  String get exportCancelBackup => 'Cancelar respaldo';

  @override
  String get exportBackupArchive => 'Archivo de respaldo';

  @override
  String get exportBackupBody =>
      'Esto crea un respaldo completo de la base de datos de NAHPU. Para respaldar solo un proyecto, use Exportar proyecto.';

  @override
  String get exportBackupDetail =>
      'Copia todos los proyectos y cada archivo de los datos de NAHPU, esté o no vinculado a un proyecto. Ejecútelo de vez en cuando en el campo, cuando el consumo de batería no sea un problema.';

  @override
  String get exportWillExport => 'Se exportará';

  @override
  String exportUserConfigsExportedTo(String path) {
    return 'Configuraciones de usuario exportadas a $path';
  }

  @override
  String get exportCustomFieldTemplates =>
      'Plantillas de campos personalizados';

  @override
  String get exportNoCustomFields => 'No hay campos personalizados disponibles';

  @override
  String get exportNoPrintLayouts =>
      'Aún no hay diseños de impresión. Cargue los diseños predeterminados o cree uno en Ajustes de documentos.';

  @override
  String get exportEnterFileNameFirst =>
      'Primero ingrese un nombre de archivo.';

  @override
  String exportShareFailed(String error) {
    return 'No se pudo compartir la exportación: $error';
  }

  @override
  String get exportFormatOptionsTitle => 'Opciones de formato';

  @override
  String get exportFormatOptions => 'Opciones de formato';

  @override
  String get exportConcatenateMultiEntry =>
      'Concatenar registros de varias entradas';

  @override
  String get exportFieldNamesOnly => 'Solo nombres de campo en los encabezados';

  @override
  String get exportSelectFieldsTitle => 'Seleccionar campos';

  @override
  String get exportClearAll => 'Borrar todo';

  @override
  String get exportRequired => 'Obligatorio';

  @override
  String get dataTableMoreActions => 'Más acciones';

  @override
  String dataTableNoMatches(String records) {
    return 'Ningún registro de $records coincide con la búsqueda y los filtros.';
  }

  @override
  String dataTableNoRecordsYet(String records) {
    return 'Aún no hay $records.';
  }

  @override
  String dataTableNoRecordsForTaxaYet(String records, String taxa) {
    return 'Aún no hay $records de $taxa.';
  }

  @override
  String dataTableProjectNoRecordsForTaxa(String records, String taxa) {
    return 'Este proyecto no tiene $records de $taxa.';
  }

  @override
  String dataTableProjectNoRecordsYet(String records) {
    return 'Este proyecto aún no tiene $records.';
  }

  @override
  String get dataTableSaved => 'Guardado.';

  @override
  String dataTableLoadError(String records) {
    return 'No se pudieron cargar $records.';
  }

  @override
  String get dataTableSomeChangesFailed =>
      'Algunos cambios no se pudieron guardar. Revise las celdas marcadas.';

  @override
  String get dataTableNoMoreMatches => 'No hay más coincidencias.';

  @override
  String get dataTableNoEarlierMatches => 'No hay coincidencias anteriores.';

  @override
  String get dataTableCellCannotBeReplaced =>
      'Esta celda no se puede reemplazar.';

  @override
  String dataTableReadForReplaceError(String error) {
    return 'No se pudieron leer los registros para reemplazar: $error';
  }

  @override
  String get dataTableNothingToReplace => 'No hay nada que reemplazar.';

  @override
  String get dataTableReplaceAllTitle => '¿Reemplazar todo?';

  @override
  String dataTableReplaceAllBody(String values, String records) {
    return '¿Reemplazar $values en $records?';
  }

  @override
  String dataTableValueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count valores',
      one: '1 valor',
    );
    return '$_temp0';
  }

  @override
  String dataTableRecordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros',
      one: '1 registro',
    );
    return '$_temp0';
  }

  @override
  String get dataTableAutoSaveWrites =>
      'El guardado automático los escribe de inmediato.';

  @override
  String get dataTableWaitForSave => 'Esperan a que pulse Guardar.';

  @override
  String dataTableReplaced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se reemplazaron $count valores.',
      one: 'Se reemplazó 1 valor.',
    );
    return '$_temp0';
  }

  @override
  String dataTableSkippedChoices(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se omitieron $count valores de lista; elíjalos de su lista.',
      one: 'Se omitió 1 valor de lista; elíjalo de su lista.',
    );
    return '$_temp0';
  }

  @override
  String dataTableInvalidValues(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count valores no cabrían en sus campos.',
      one: '1 valor no cabría en su campo.',
    );
    return '$_temp0';
  }

  @override
  String get dataTablePickDate => 'Elegir una fecha';

  @override
  String get dataTablePickTime => 'Elegir una hora';

  @override
  String get dataTableSaveChangesTitle => '¿Guardar los cambios?';

  @override
  String dataTableUnsavedChanges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tiene $count cambios sin guardar en esta tabla.',
      one: 'Tiene 1 cambio sin guardar en esta tabla.',
    );
    return '$_temp0';
  }

  @override
  String get dataTableFindField => 'Buscar un campo';

  @override
  String dataTableFieldsShown(int count, int total) {
    return '$count de $total campos visibles';
  }

  @override
  String get dataTableComputedNotSearchable =>
      'Se calcula durante la exportación: no se puede buscar ni ordenar';

  @override
  String get dataTableShowAll => 'Mostrar todo';

  @override
  String get dataTableAutoSaveTooltip =>
      'Guarda cada cambio al confirmarlo. Deshaga con Ctrl+Z o ⌘Z mientras la tabla esté abierta.';

  @override
  String get dataTableAutoSave => 'Guardado automático';

  @override
  String get dataTableDiscardChanges => 'Descartar cambios';

  @override
  String get dataTableRetrySave => 'Reintentar guardado';

  @override
  String get dataTableEditModeOn =>
      'El modo de edición está activado (Ctrl+E o ⌘E)';

  @override
  String get dataTableEditModeOff =>
      'El modo de edición está desactivado (Ctrl+E o ⌘E)';

  @override
  String dataTableCellsNeedAttention(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count celdas requieren atención',
      one: '1 celda requiere atención',
    );
    return '$_temp0';
  }

  @override
  String dataTableUnsavedChangeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cambios sin guardar',
      one: '1 cambio sin guardar',
    );
    return '$_temp0';
  }

  @override
  String get dataTableAllChangesSaved => 'Todos los cambios guardados';

  @override
  String dataTableColumnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count columnas',
      one: '1 columna',
    );
    return '$_temp0';
  }

  @override
  String dataTableExportSummary(String records, String columns) {
    return '$records × $columns, con la búsqueda, los filtros, el orden y las columnas visibles actuales.';
  }

  @override
  String get dataTableColumnHeaders => 'Encabezados de columna';

  @override
  String get dataTableDwcOnly => 'Solo columnas asignadas a Darwin Core';

  @override
  String get dataTableDwcOnlyBody =>
      'Omite las columnas sin un término de Darwin Core. De lo contrario, conservan su clave de NAHPU.';

  @override
  String dataTableReadProgress(int count, int total) {
    return 'Leídos $count de $total registros';
  }

  @override
  String dataTableScopeChip(String label, int count) {
    return '$label ($count)';
  }

  @override
  String get dataTableClearFilters => 'Borrar filtros';

  @override
  String dataTableBetweenValues(String low, String high) {
    return '$low y $high';
  }

  @override
  String get dataTableFilterRules => 'Reglas de filtro';

  @override
  String get dataTableFilterRulesBody =>
      'Muestra los registros que cumplen todas las reglas.';

  @override
  String get dataTableAddRule => 'Agregar regla';

  @override
  String get dataTableEnterValueEveryRule =>
      'Ingrese un valor para cada regla.';

  @override
  String get dataTableEnterDates => 'Ingrese las fechas como AAAA-MM-DD.';

  @override
  String get dataTableEnterTimes => 'Ingrese las horas como HH:MM.';

  @override
  String get dataTableChooseListed => 'Elija uno de los valores de la lista.';

  @override
  String get dataTableEnterNumber => 'Ingrese un número.';

  @override
  String get dataTableComputedNotFilterable =>
      'Se calcula durante la exportación; no se puede filtrar';

  @override
  String get dataTableRemoveRule => 'Quitar regla';

  @override
  String get dataTableReplacingNeedsEditMode =>
      'Para reemplazar se necesita el modo de edición.';

  @override
  String get dataTableMatchCase => 'Coincidir mayúsculas';

  @override
  String get dataTableWholeCell => 'Celda completa';

  @override
  String get dataTablePreviousMatch => 'Coincidencia anterior';

  @override
  String get dataTableNextMatch => 'Coincidencia siguiente';

  @override
  String get dataTableTurnOnEditMode => 'Activar el modo de edición';

  @override
  String get dataTableReplaceAll => 'Reemplazar todo';

  @override
  String get dataTableNoMatchesShort => 'Sin coincidencias';

  @override
  String dataTableFoundCount(int count) {
    return '$count encontrados';
  }

  @override
  String dataTableMatchOf(int current, int total) {
    return '$current de $total';
  }

  @override
  String get dataTableAllVisibleColumns => 'Todas las columnas visibles';

  @override
  String dataTableColumnReadOnly(String column) {
    return '$column es de solo lectura aquí.';
  }

  @override
  String dataTableSkippedOffList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se omitieron $count valores que no están en sus listas.',
      one: 'Se omitió 1 valor que no está en su lista.',
    );
    return '$_temp0';
  }

  @override
  String get dataTableChangeFishTypeTitle =>
      '¿Cambiar el tipo de registro de pez?';

  @override
  String dataTableSexClears(String fields) {
    return 'Esto borra $fields, que ya no se aplican al nuevo sexo.';
  }

  @override
  String get dataTableFishTypeChangeBody =>
      'Cambiar entre individuo y lote modifica las medidas que se aplican.';

  @override
  String dataTableSkippedReadOnly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se omitieron $count celdas de solo lectura o vinculadas.',
      one: 'Se omitió 1 celda de solo lectura o vinculada.',
    );
    return '$_temp0';
  }

  @override
  String dataTableCopiedCells(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se copiaron $count celdas.',
      one: 'Se copió 1 celda.',
    );
    return '$_temp0';
  }

  @override
  String get dataTableSwitchToEditToPaste =>
      'Cambie al modo de edición para pegar.';

  @override
  String dataTablePastedSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pegado; se omitieron $count celdas de solo lectura o vinculadas.',
      one: 'Pegado; se omitió 1 celda de solo lectura o vinculada.',
    );
    return '$_temp0';
  }

  @override
  String get dataTablePastedCutOff =>
      'Pegado; se recortó en el borde de la página.';

  @override
  String dataTablePastedSkippedAndCutOff(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Pegado; se omitieron $count celdas de solo lectura o vinculadas y se recortó en el borde de la página.',
      one:
          'Pegado; se omitió 1 celda de solo lectura o vinculada y se recortó en el borde de la página.',
    );
    return '$_temp0';
  }

  @override
  String get dataTableComputedField =>
      'Se calcula durante la exportación: no se puede buscar, ordenar ni filtrar.';

  @override
  String get dataTableLinkedDataHint =>
      'Datos vinculados: haga doble clic o presione F2 para editar.';

  @override
  String get dataTableReadOnlyHere => 'Solo lectura aquí.';

  @override
  String get dataTableOpenForm => 'Abrir formulario';

  @override
  String dataTableLinkCurrent(String value) {
    return 'Ahora: $value.';
  }

  @override
  String get dataTableLoadChoicesError => 'No se pudieron cargar las opciones.';

  @override
  String get dataTableLinkCatalogerNote =>
      'El número de campo sigue al nuevo catalogador. El determinador y el preparador también cambian si eran el catalogador anterior.';

  @override
  String get dataTableLinkEventNote =>
      'Se borran el método de colecta y el personal, y la coordenada sigue al sitio del nuevo evento.';

  @override
  String get dataTableLinkTaxonNote =>
      'El orden, la familia, el género y el epíteto provienen del taxón elegido.';

  @override
  String dataTableSaveError(String error) {
    return 'No se pudo guardar: $error';
  }

  @override
  String get dataTableNothingMatches => 'Nada coincide.';

  @override
  String dataTableNotLinked(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'site': 'Este registro aún no está vinculado a un sitio.',
      'other': 'Este registro aún no está vinculado a un evento.',
    });
    return '$_temp0';
  }

  @override
  String dataTableLinkedLoadError(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'site': 'No se pudo cargar el sitio.',
      'other': 'No se pudo cargar el evento.',
    });
    return '$_temp0';
  }

  @override
  String dataTableLinkShared(String noun, int count) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'site':
          'Los cambios se aplican a todos los registros vinculados a este sitio ($count).',
      'other':
          'Los cambios se aplican a todos los registros vinculados a este evento ($count).',
    });
    return '$_temp0';
  }

  @override
  String get dataTableSomeChangesNotSaved =>
      'Algunos cambios no se pudieron guardar.';

  @override
  String get dataTablePageRangeEmpty => '0 de 0';

  @override
  String dataTablePageRange(String first, String last, String total) {
    return '$first–$last de $total';
  }

  @override
  String get dataTableRowsPerPage => 'Filas por página';

  @override
  String get dataTableFirstPage => 'Primera página';

  @override
  String get dataTablePreviousPage => 'Página anterior';

  @override
  String get dataTableNextPage => 'Página siguiente';

  @override
  String get dataTableLastPage => 'Última página';

  @override
  String dataTableSearchIn(String target) {
    return 'Buscar en $target';
  }

  @override
  String get dataTableRefresh => 'Actualizar';

  @override
  String get dataTableAddFieldRules => 'Agregar reglas de campo';

  @override
  String get dataTableEditFieldRules => 'Editar reglas de campo';

  @override
  String get dataTableFilters => 'Filtros';

  @override
  String get dataTableAllVisibleFields => 'Todos los campos visibles';

  @override
  String get dataTableSearchingAllFields =>
      'Buscando en todos los campos visibles';

  @override
  String dataTableSearchingField(String field) {
    return 'Buscando en $field';
  }

  @override
  String get dataTableFilterOpIs => 'es';

  @override
  String get dataTableFilterOpContains => 'contiene';

  @override
  String get dataTableFilterOpStartsWith => 'empieza con';

  @override
  String get dataTableFilterOpGreaterThan => 'mayor que';

  @override
  String get dataTableFilterOpLessThan => 'menor que';

  @override
  String get dataTableFilterOpBetween => 'entre';

  @override
  String get dataTableFilterOpIsEmpty => 'está vacío';

  @override
  String get dataTableFilterOpIsNotEmpty => 'no está vacío';

  @override
  String get dataTableQuickMissingTaxon => 'Sin taxón';

  @override
  String get dataTableQuickNoFieldNumber => 'Sin número de campo';

  @override
  String get dataTableQuickNoEvent => 'Sin evento';

  @override
  String get dataTableQuickHasParts => 'Tiene partes';

  @override
  String get dataTableQuickHasMedia => 'Tiene multimedia';

  @override
  String get dataTableQuickNoTissueId => 'Sin ID de tejido';

  @override
  String get dataTableQuickNoParasiteId => 'Sin ID de parásito';

  @override
  String get dataTableQuickNoCoordinates => 'Sin coordenadas';

  @override
  String get dataTableQuickNoLocality => 'Sin localidad';

  @override
  String get dataTableQuickNoSpecimens => 'Sin especímenes';

  @override
  String get dataTableQuickNoEndDate => 'Sin fecha de fin';

  @override
  String get dataTableQuickNoSite => 'Sin sitio';

  @override
  String dataTableProjectScopeOne(String name) {
    return 'Proyecto: $name';
  }

  @override
  String dataTableProjectScopeTwo(String first, String second) {
    return 'Proyectos: $first, $second';
  }

  @override
  String dataTableProjectScopeMany(int count) {
    return '$count proyectos';
  }

  @override
  String get siteImportFieldGpsUnit => 'Unidad GPS';

  @override
  String get projectTissueCustomLabels => 'Personalizar etiquetas de celda';

  @override
  String get projectTissueBoxSeparator => 'Separador de caja';

  @override
  String get projectTissueRowColumnSeparator => 'Separador fila–columna';

  @override
  String get projectTissueZeroPad => 'Rellenar números con ceros';

  @override
  String projectTissueLabelExample(String example) {
    return 'Ejemplo: $example';
  }
}
