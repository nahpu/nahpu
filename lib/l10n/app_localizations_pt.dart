// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get commonBeta => 'Beta';

  @override
  String get commonRetry => 'Tentar novamente';

  @override
  String get commonUnavailable => 'Indisponível';

  @override
  String get commonError => 'Erro';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonPreview => 'Visualizar';

  @override
  String get commonSortRecords => 'Ordenar registros';

  @override
  String get commonDeleteRecord => 'Excluir registro';

  @override
  String get commonDeleteAllRecords => 'Excluir todos os registros';

  @override
  String get homeDatabaseErrorTitle =>
      'Não foi possível abrir o banco de dados do NAHPU.';

  @override
  String get homeDatabaseErrorBody =>
      'Seus dados não foram excluídos. Tente a migração do banco de dados novamente ou reinicie o NAHPU.';

  @override
  String get homeExistingProjects => 'Projetos existentes';

  @override
  String get homeNoProjectsTitle => 'Nenhum projeto encontrado.';

  @override
  String get homeNoProjectsBody => 'Crie ou importe um projeto para começar.';

  @override
  String get homeSetupHint =>
      'Novo no NAHPU? Execute Configurar o NAHPU para escolher o formato de catálogo, os identificadores, os vocabulários e as predefinições de exportação.';

  @override
  String get homeSetupNahpu => 'Configurar o NAHPU';

  @override
  String get homeStatistics => 'Estatísticas';

  @override
  String get homeSearchRecords => 'Pesquisar registros';

  @override
  String get homeMoreActions => 'Mais';

  @override
  String get homeGallery => 'Galeria';

  @override
  String get homeSearchReset => 'Redefinir';

  @override
  String get homeSearchShowResults => 'Mostrar resultados';

  @override
  String get homeSearchHint =>
      'Número de campo, táxon, local ou qualquer valor';

  @override
  String get homeSearchRecordType => 'Tipo de registro';

  @override
  String get homeSearchIn => 'Pesquisar em';

  @override
  String get homeSearchAllFields => 'Todos os campos';

  @override
  String get homeSearchProjects => 'Projetos';

  @override
  String get homeSearchAllProjects => 'Todos os projetos';

  @override
  String get homeSearchTaxa => 'Táxons';

  @override
  String get homeSearchQuickFilters => 'Filtros rápidos';

  @override
  String homeProjectAccessed(String date) {
    return 'Acessado em: $date';
  }

  @override
  String homeProjectCreated(String date) {
    return 'Criado em: $date';
  }

  @override
  String get homeProjectActions => 'Ações do projeto';

  @override
  String get homeProjectEditInfo => 'Editar informações';

  @override
  String get homeProjectShowQr => 'Mostrar QR';

  @override
  String get homeProjectExportInfo => 'Exportar informações';

  @override
  String get homeProjectDetails => 'Detalhes';

  @override
  String get homeProjectInformation => 'Informações do projeto';

  @override
  String get homeProjectQrCode => 'Código QR do projeto';

  @override
  String get homeProjectQrDescription =>
      'Leia este código ao criar um novo projeto para transferir as informações do projeto.';

  @override
  String aboutTitle(String appName) {
    return 'Sobre o $appName';
  }

  @override
  String get aboutTagline =>
      'Repensando inventários de biodiversidade na era digital';

  @override
  String get aboutLicenses => 'Licenças';

  @override
  String get aboutAppVersion => 'Versão do aplicativo';

  @override
  String aboutVersionBuild(String version, String build) {
    return 'v$version (compilação $build)';
  }

  @override
  String get aboutCodename => 'Codinome';

  @override
  String get aboutCodenameNote =>
      'Do primeiro teste de campo real do NAHPU no Monte Gede, Java Ocidental, Indonésia.';

  @override
  String get aboutDatabaseSchema => 'Esquema do banco de dados';

  @override
  String aboutSchemaSupported(String version) {
    return 'O aplicativo suporta a v$version';
  }

  @override
  String aboutDescription(String appName) {
    return 'O $appName é um aplicativo de catálogo digital multiplataforma criado para a coleta e o gerenciamento de dados de espécimes de história natural, oferecendo informações no momento da coleta.';
  }

  @override
  String get drawerCreateProject => 'Criar projeto';

  @override
  String get drawerImportProject => 'Importar projeto';

  @override
  String get drawerDatabaseStatistics => 'Estatísticas do banco de dados';

  @override
  String get drawerMediaGallery => 'Galeria de mídias';

  @override
  String get drawerBackupDatabase => 'Fazer backup do banco de dados';

  @override
  String get drawerSettings => 'Configurações';

  @override
  String get drawerExportUserConfigs => 'Exportar configurações do usuário';

  @override
  String get drawerImportUserConfigs => 'Importar configurações do usuário';

  @override
  String get drawerAbout => 'Sobre';

  @override
  String get drawerWebsite => 'Site do NAHPU';

  @override
  String get drawerCookbook => 'Livro de receitas';

  @override
  String get settingsApplications => 'Aplicativo';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeLabel => 'Defina a aparência clara ou escura';

  @override
  String get settingsThemeDark => 'Escuro';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsTools => 'Ferramentas';

  @override
  String get settingsToolsLabel =>
      'Escolha as ferramentas exibidas no painel do projeto';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Padrão do sistema';

  @override
  String settingsLanguageSystemLabel(String language) {
    return 'Segue o idioma do dispositivo ($language)';
  }

  @override
  String get settingsLanguageBetaNote =>
      'O suporte a idiomas está em beta. Algumas telas ainda estão em inglês, e as traduções podem ser rascunhos automáticos.';

  @override
  String get settingsLanguageHelpTranslate => 'Ajude a traduzir o NAHPU';

  @override
  String get settingsRegionalFormat => 'Formato regional';

  @override
  String get settingsRegionalFormatMatchLanguage => 'Igual ao idioma';

  @override
  String get settingsRegionalFormatNote =>
      'Altera apenas como datas e números são exibidos. Registros salvos e exportações mantêm os formatos padrão.';

  @override
  String settingsRegionalFormatPreview(String date, String number) {
    return 'Exemplo: $date · $number';
  }

  @override
  String get docsContents => 'Conteúdo';

  @override
  String docsCollapse(String title) {
    return 'Recolher $title';
  }

  @override
  String docsExpand(String title) {
    return 'Expandir $title';
  }

  @override
  String get docsLoadError => 'Não foi possível carregar esta documentação.';

  @override
  String get docsOnlineLinks =>
      'Estes links abrem a documentação do NAHPU e exigem conexão com a internet.';

  @override
  String get docsAsideNote => 'Nota';

  @override
  String get docsAsideCaution => 'Cuidado';

  @override
  String get docsAsideTip => 'Dica';

  @override
  String get docsAiTranslation => 'Tradução assistida por IA.';

  @override
  String get docsAiCheck => 'Verifique a precisão';

  @override
  String docsReviewedBy(String reviewers) {
    return 'Verificada e revisada por $reviewers.';
  }

  @override
  String docsReviewerPair(String first, String second) {
    return '$first e $second';
  }

  @override
  String docsReviewerList(String leading, String last) {
    return '$leading e $last';
  }

  @override
  String get narrativeTitle => 'Narrativa';

  @override
  String get narrativeRecordTitle => 'Registro de narrativa';

  @override
  String get narrativeSearchHint => 'Pesquisar narrativa';

  @override
  String get narrativeEmpty => 'Nenhuma narrativa encontrada';

  @override
  String get narrativeCreate => 'Criar narrativa';

  @override
  String get narrativeActions => 'Ações da narrativa';

  @override
  String get narrativeDeleteTitle => 'Excluir narrativa?';

  @override
  String get narrativeDeletePrompt => 'Você excluirá esta narrativa';

  @override
  String get narrativeDeleteAllTitle => 'Excluir todas as narrativas?';

  @override
  String get narrativeDeleteAllPrompt =>
      'Você excluirá todas as narrativas deste projeto';

  @override
  String narrativeDeleteError(String error) {
    return 'Erro ao excluir a narrativa: $error';
  }

  @override
  String get narrativeDeleted => 'Narrativa excluída';

  @override
  String get narrativeTextLabel => 'Narrativa';

  @override
  String get narrativeTextHint =>
      'Digite a narrativa (compatível com Markdown)';

  @override
  String get narrativeTextEmpty =>
      'Nenhuma narrativa. Use o botão Editar acima para começar a escrever.';

  @override
  String get narrativeDate => 'Data';

  @override
  String get narrativeDateHint => 'Insira a data';

  @override
  String get narrativeTime => 'Hora';

  @override
  String get narrativeTimeHint => 'Insira a hora';

  @override
  String get narrativeWriter => 'Autor';

  @override
  String get narrativeWriterHint => 'Escolha o nome de uma pessoa';

  @override
  String get commonDelete => 'Excluir';

  @override
  String get commonDone => 'Concluído';

  @override
  String get commonExport => 'Exportar';

  @override
  String get commonRemove => 'Remover';

  @override
  String get commonReset => 'Redefinir';

  @override
  String get settingsNavCatalogs => 'Catálogos';

  @override
  String get settingsNavCatalogFormat => 'Formato';

  @override
  String get settingsNavCatalogFormatLabel => 'Defina o formato do catálogo';

  @override
  String settingsNavCatalogFormatLoadError(String error) {
    return 'Não foi possível carregar o formato do catálogo: $error';
  }

  @override
  String get settingsNavSites => 'Locais';

  @override
  String get settingsNavSitesLabel =>
      'Gerencie tipos de local, tipos de hábitat e data de coordenadas';

  @override
  String get settingsNavEvents => 'Eventos';

  @override
  String get settingsNavEventsLabel =>
      'Gerencie atividades, métodos de coleta, funções da equipe e campos ambientais';

  @override
  String get settingsNavSpecimens => 'Espécimes';

  @override
  String get settingsNavSpecimensLabel =>
      'Gerencie as configurações de campos e de ID de tecido e os vocabulários controlados dos formulários de espécimes';

  @override
  String get settingsNavCustomFields => 'Campos personalizados';

  @override
  String get settingsNavCustomFieldsLabel =>
      'Gerencie campos para locais, dados ambientais, espécimes, partes e parasitas';

  @override
  String get settingsNavDatabase => 'Banco de dados';

  @override
  String get settingsNavTaxa => 'Táxons';

  @override
  String get settingsNavTaxaLabel => 'Gerencie os registros taxonômicos';

  @override
  String get settingsNavPersonnel => 'Equipe';

  @override
  String get settingsNavPersonnelLabel => 'Gerencie os registros da equipe';

  @override
  String get settingsNavBackupDatabaseLabel =>
      'Backup completo do banco de dados com todos os registros e configurações';

  @override
  String get settingsNavReplaceDatabase => 'Substituir banco de dados';

  @override
  String get settingsNavReplaceDatabaseLabel =>
      'Substitua o banco de dados atual por outro arquivo de banco de dados';

  @override
  String get settingsNavExports => 'Exportações';

  @override
  String get settingsNavTabularData => 'Dados tabulares';

  @override
  String get settingsNavTabularDataLabel =>
      'Gerencie predefinições para exportar em formatos tabulares';

  @override
  String get settingsNavDocuments => 'Documentos';

  @override
  String get settingsNavDocumentsLabel =>
      'Gerencie predefinições para exportar documentos';

  @override
  String get settingsNavTemplateEditor => 'Editor de modelos';

  @override
  String get settingsNavTemplateEditorLabel =>
      'Crie e edite modelos de documentos';

  @override
  String get settingsCommonSetCaseFormat => 'Definir maiúsculas e minúsculas';

  @override
  String get settingsFileTreeEmpty => 'A pasta do aplicativo está vazia.';

  @override
  String settingsFileTreeUnlinkedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count não vinculados',
      one: '1 não vinculado',
    );
    return '$_temp0';
  }

  @override
  String get settingsFileTreeRemoveEmptyFolder => 'Remover esta pasta vazia';

  @override
  String get settingsFileTreeSelectFolder => 'Selecionar esta pasta';

  @override
  String settingsFileTreeSelectRemovable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Selecionar os $count arquivos removíveis aqui',
      one: 'Selecionar o arquivo removível aqui',
    );
    return '$_temp0';
  }

  @override
  String get settingsFileTreeSaveCopy => 'Salvar uma cópia';

  @override
  String get settingsFileTreeRemoveFile => 'Remover este arquivo';

  @override
  String get settingsFileTreeKept => 'Mantido';

  @override
  String get settingsSelectionApplicationFolder => 'Pasta do aplicativo';

  @override
  String settingsSelectionTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count arquivos selecionados',
      one: '1 arquivo selecionado',
    );
    return '$_temp0';
  }

  @override
  String get settingsSelectionArchiveFormat => 'Formato do arquivo compactado';

  @override
  String get settingsSelectionNoFolder =>
      'Exportar uma seleção exige uma pasta para gravar, e este dispositivo não oferece uma. Você ainda pode excluir os arquivos selecionados depois de revisá-los.';

  @override
  String get settingsSelectionExportNote =>
      'A exportação grava esses arquivos em um único arquivo compactado e depois oferece remover os originais. A exclusão os remove imediatamente e não pode ser desfeita.';

  @override
  String get settingsSelectionDeleteNote =>
      'A exclusão remove os arquivos selecionados imediatamente e não pode ser desfeita.';

  @override
  String get settingsSelectionDeletePermanently => 'Excluir permanentemente';

  @override
  String get settingsMapLayers => 'Camadas do mapa';

  @override
  String get settingsMapPmtilesType => 'Tipo de camada PMTiles';

  @override
  String settingsMapImportError(String error) {
    return 'Não foi possível importar a camada do mapa: $error';
  }

  @override
  String get settingsMapBaseLayer => 'Camada base';

  @override
  String get settingsMapCustomLayers => 'Camadas personalizadas';

  @override
  String settingsMapLoadError(String error) {
    return 'Não foi possível carregar as camadas personalizadas do mapa: $error';
  }

  @override
  String get settingsMapNoCustomLayers =>
      'Nenhuma camada personalizada foi importada.';

  @override
  String get settingsMapImportCustomLayer => 'Importar camada personalizada';

  @override
  String settingsMapKindUnavailableOnDesktop(String kind) {
    return '$kind · indisponível no desktop';
  }

  @override
  String get settingsMapConfigureLayer => 'Configurar camada';

  @override
  String get settingsMapShowLayer => 'Mostrar camada';

  @override
  String get settingsMapLayerUnavailableOnDesktop =>
      'Esta camada está indisponível no desktop';

  @override
  String get settingsMapLayerTypeUnavailableOnDesktop =>
      'Este tipo de camada está indisponível no desktop.';

  @override
  String get settingsMapOpacity => 'Opacidade';

  @override
  String get settingsMapUseTerrain => 'Usar para o terreno 3D';

  @override
  String get settingsMapHillshadeNote =>
      'O sombreamento do relevo continua visível quando o terreno está desativado.';

  @override
  String get settingsMapLayerOrder => 'Ordem das camadas';

  @override
  String get settingsMapMoveEarlier => 'Mover para antes';

  @override
  String get settingsMapMoveLater => 'Mover para depois';

  @override
  String get settingsMapDeleteLayer => 'Excluir camada';

  @override
  String get settingsMapDeleteLayerTitle => 'Excluir a camada do mapa?';

  @override
  String settingsMapDeleteLayerBody(String name) {
    return 'Excluir $name e os dados de mapa armazenados?';
  }

  @override
  String get settingsMapSupportedFormatsDesktop =>
      'No desktop, aceita GeoJSON, Shapefiles WGS84 compactados em ZIP e PMTiles raster.';

  @override
  String get settingsMapSupportedFormats =>
      'Aceita GeoJSON, Shapefiles WGS84 compactados em ZIP e PMTiles.';

  @override
  String get settingsDataUsage => 'Uso de dados';

  @override
  String get settingsDataUsageLabel => 'Navegue e limpe a pasta do aplicativo';

  @override
  String get settingsDataUsageRescan => 'Verificar novamente';

  @override
  String get settingsDataUsageFiles => 'Arquivos';

  @override
  String get settingsDataUsageFilesLabel => 'Inclui imagens e outros arquivos';

  @override
  String get settingsDataUsageMediaFiles => 'Arquivos de mídia';

  @override
  String get settingsDataUsageMediaFilesLabel => 'Imagens, áudio, vídeo';

  @override
  String get settingsDataUsageTotal => 'Uso total';

  @override
  String get settingsDataUsageReclaimable => 'Recuperável';

  @override
  String get settingsDataUsageReclaimableLabel =>
      'Arquivos não vinculados que podem ser removidos';

  @override
  String get settingsDataUsageNone => 'Nenhum';

  @override
  String get settingsDataUsageRemoveOriginalsTitle => 'Remover os originais?';

  @override
  String settingsDataUsageArchiveWritten(
    int count,
    String archive,
    String size,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count arquivos foram gravados em $archive ($size).',
      one: '1 arquivo foi gravado em $archive ($size).',
    );
    return '$_temp0';
  }

  @override
  String get settingsDataUsageRemoveOriginalsBody =>
      'Removê-los do NAHPU libera o espaço. O arquivo compactado mantém sua cópia, e isso não pode ser desfeito.';

  @override
  String settingsDataUsageExportedTo(String path) {
    return 'Exportado para $path';
  }

  @override
  String settingsDataUsageExportFailed(String error) {
    return 'Falha na exportação: $error';
  }

  @override
  String settingsDataUsageSaveCopyFailed(String name, String error) {
    return 'Não foi possível salvar $name: $error';
  }

  @override
  String get settingsDataUsageRemoveFileTitle => 'Remover este arquivo?';

  @override
  String settingsDataUsageRemoveFileBody(String name, String size) {
    return '$name ($size) não está vinculado a nenhum registro. Isso não pode ser desfeito.';
  }

  @override
  String get settingsDataUsageRemoveFolderTitle => 'Remover esta pasta vazia?';

  @override
  String settingsDataUsageRemoveFolderBody(String name) {
    return '$name não contém arquivos. Removê-la não afeta nenhum registro.';
  }

  @override
  String settingsDataUsageRemovedFolder(String name) {
    return '$name removida.';
  }

  @override
  String settingsDataUsageRemoveFolderFailed(String name) {
    return 'Não foi possível remover $name.';
  }

  @override
  String settingsDataUsageDeleteSelectionTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Excluir $count arquivos selecionados?',
      one: 'Excluir 1 arquivo selecionado?',
    );
    return '$_temp0';
  }

  @override
  String get settingsDataUsageDeleteSelectionBody =>
      'Esses arquivos não estão vinculados a nenhum registro. Isso não pode ser desfeito.';

  @override
  String get settingsDataUsageCollapseAll => 'Recolher tudo';

  @override
  String get settingsDataUsageExpandAll => 'Expandir tudo';

  @override
  String get settingsDataUsageSelectAll => 'Selecionar tudo';

  @override
  String get settingsDataUsageSelect => 'Selecionar';

  @override
  String get settingsDataUsageClear => 'Limpar';

  @override
  String settingsDataUsageReview(int count) {
    return 'Revisar $count';
  }

  @override
  String get settingsDataUsageScanError =>
      'Não foi possível ler a pasta do aplicativo';

  @override
  String get settingsDataUsagePruneTitle => 'Remover arquivos não vinculados';

  @override
  String get settingsDataUsagePruneDescription =>
      'Arquivos que não são mais usados por nenhum registro, como sobras de mídias excluídas ou importações canceladas. Arquivos vinculados, bancos de dados e backups, fontes personalizadas, camadas do mapa e arquivos fora das pastas gerenciadas pelo NAHPU não são afetados.';

  @override
  String get settingsDataUsageNothingToReclaim => 'Nada a recuperar.';

  @override
  String settingsDataUsagePruneButton(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Remover $count arquivos não vinculados ($size)',
      one: 'Remover 1 arquivo não vinculado ($size)',
    );
    return '$_temp0';
  }

  @override
  String settingsDataUsagePruneConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Remover $count arquivos não vinculados?',
      one: 'Remover 1 arquivo não vinculado?',
    );
    return '$_temp0';
  }

  @override
  String settingsDataUsagePruneConfirmBody(String size) {
    return 'Isso libera $size. Arquivos ainda vinculados aos seus registros, seu banco de dados e os backups dele, e suas fontes personalizadas e camadas do mapa não são afetados.\n\nIsso não pode ser desfeito.';
  }

  @override
  String settingsDataUsageRemovedSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count arquivos removidos ($size).',
      one: '1 arquivo removido ($size).',
    );
    return '$_temp0';
  }

  @override
  String settingsDataUsageKeptChanged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count arquivos foram mantidos porque mudaram durante a verificação.',
      one: '1 arquivo foi mantido porque mudou durante a verificação.',
    );
    return '$_temp0';
  }

  @override
  String get commonOk => 'OK';

  @override
  String get recordsCatalogFormat => 'Formato de catálogo';

  @override
  String get recordsCatalogMeasurementRecords => 'Registros de medidas';

  @override
  String get recordsCatalogAlwaysShowBatFields =>
      'Sempre mostrar os campos de morcegos';

  @override
  String get recordsCatalogBatFieldsNote =>
      'Se ativado, os campos específicos de morcegos são sempre mostrados nos campos de medidas de mamíferos. Você também pode mostrar ou ocultar os campos específicos de morcegos para cada registro de espécime na tela do registro de espécime.';

  @override
  String get recordsVocabularyCaseFormat => 'Formato de maiúsculas';

  @override
  String recordsVocabularyCaseFormatLoadError(String error) {
    return 'Não foi possível carregar o formato de maiúsculas: $error';
  }

  @override
  String get recordsVocabularyCaseAny => 'Sem formato fixo';

  @override
  String get recordsVocabularyCaseSentence => 'Tipo frase';

  @override
  String get recordsVocabularyCaseTitle => 'Tipo título';

  @override
  String get recordsVocabularyCaseUpper => 'Maiúsculas';

  @override
  String get recordsVocabularyCaseLower => 'Minúsculas';

  @override
  String get recordsSiteSettings => 'Configurações de locais';

  @override
  String get recordsSiteTypes => 'Tipos de local';

  @override
  String get recordsSiteHabitatTypes => 'Tipos de hábitat';

  @override
  String get recordsSiteDatums => 'Datums';

  @override
  String get recordsSiteGeographyFields => 'Campos geográficos';

  @override
  String recordsSiteGeographyFieldsLoadError(String error) {
    return 'Não foi possível carregar os campos geográficos: $error';
  }

  @override
  String get recordsSiteMaps => 'Mapas';

  @override
  String get recordsSiteMapLayers => 'Camadas do mapa';

  @override
  String get recordsSiteMapLayersLabel =>
      'Escolha uma camada base ou importe e gerencie camadas personalizadas';

  @override
  String get recordsCollEventSettings => 'Configurações de eventos de coleta';

  @override
  String get recordsCollEventPrimaryActivities => 'Atividades principais';

  @override
  String get recordsCollEventCollectionMethods => 'Métodos de coleta';

  @override
  String get recordsCollEventPersonnelRoles => 'Funções da equipe';

  @override
  String get recordsCollEventEnvironmentalDataFields =>
      'Campos de dados ambientais';

  @override
  String recordsCollEventEnvironmentalDataFieldsLoadError(String error) {
    return 'Não foi possível carregar os campos de dados ambientais: $error';
  }

  @override
  String get recordsCollEventTemperature => 'Temperatura';

  @override
  String get recordsCollEventHumidity => 'Umidade';

  @override
  String get recordsCollEventEnvironmentalMeasurements => 'Medições ambientais';

  @override
  String get recordsCollEventAquaticData => 'Dados aquáticos';

  @override
  String get recordsCollEventAstronomy => 'Astronomia';

  @override
  String get recordsSpecimenSettings => 'Configurações de espécimes';

  @override
  String get recordsSpecimenCaptureRecords => 'Registros de captura';

  @override
  String get recordsSpecimenAlwaysShowCollector =>
      'Sempre mostrar o campo de coletor';

  @override
  String get recordsSpecimenIdentificationMethods => 'Métodos de identificação';

  @override
  String get recordsSpecimenLifeStages => 'Estágios de vida';

  @override
  String get recordsSpecimenTypes => 'Tipos de espécime';

  @override
  String get recordsSpecimenTreatments => 'Tratamentos';

  @override
  String get recordsSpecimenConditions => 'Condições';

  @override
  String get recordsSpecimenSex => 'Sexo';

  @override
  String recordsSpecimenSexNote(String male, String female, String unknown) {
    return '$male, $female e $unknown estão sempre disponíveis. Adicione termos opcionais com +. Um ponto de interrogação registra a incerteza do examinador.';
  }

  @override
  String recordsSpecimenSexLoadError(String error) {
    return 'Não foi possível carregar as opções de sexo: $error';
  }

  @override
  String get recordsSpecimenSexSelected => 'Selecionados';

  @override
  String get recordsSpecimenSexAdditional => 'Opções adicionais';

  @override
  String get recordsSpecimenSexRemoveBlockedTitle =>
      'Não é possível remover o sexo';

  @override
  String recordsSpecimenSexRemoveBlockedBody(String sex) {
    return '$sex é usado em um ou mais registros de espécime. Altere esses registros antes de remover esta opção.';
  }

  @override
  String get recordsSpecimenParasites => 'Parasitas';

  @override
  String get recordsSpecimenParasiteIdentification => 'Identificação';

  @override
  String get recordsSpecimenParasiteCategories => 'Categorias';

  @override
  String get recordsSpecimenParasiteDetectionMethods => 'Métodos de detecção';

  @override
  String get recordsSpecimenParasitePreparationMethods =>
      'Métodos de preparação';

  @override
  String get recordsSpecimenParasiteAnatomicalLocations =>
      'Localizações anatômicas';

  @override
  String get recordsSpecimenParasiteStorage => 'Armazenamento';

  @override
  String get recordsSpecimenParasiteIdPrefix => 'Prefixo do ID de parasita';

  @override
  String recordsSpecimenParasiteIdPrefixHint(String example) {
    return 'Digite um prefixo, p. ex. $example';
  }

  @override
  String get recordsSpecimenParasiteIdNumber => 'Número do ID de parasita';

  @override
  String get recordsSpecimenNextNumberHint => 'Digite o próximo número';

  @override
  String get recordsSpecimenFieldId => 'ID de campo';

  @override
  String recordsSpecimenFieldIdModeLoadError(String error) {
    return 'Não foi possível carregar o modo de ID de campo: $error';
  }

  @override
  String get recordsSpecimenPersonnelId => 'ID da equipe';

  @override
  String get recordsSpecimenPersonnelIdDescription =>
      'O ID é formado pelas iniciais de uma pessoa e um número sequencial. Você o definirá ao cadastrar um membro da equipe com a função de catalogador.';

  @override
  String get recordsSpecimenProjectId => 'ID do projeto';

  @override
  String get recordsSpecimenProjectIdDescription =>
      'O projeto mantém um único número sequencial com prefixo e sufixo compartilhados.';

  @override
  String get recordsSpecimenPersonnelFieldIdNoteTitle =>
      'IDs de campo da equipe exigem um catalogador';

  @override
  String get recordsSpecimenPersonnelFieldIdNoteBody =>
      'Adicione uma pessoa com a função de catalogador no projeto e atribua um número de campo atual a essa função.';

  @override
  String get recordsSpecimenAddPersonnel => 'Adicionar membro da equipe';

  @override
  String get recordsSpecimenPrefix => 'Prefixo';

  @override
  String get recordsSpecimenSuffix => 'Sufixo';

  @override
  String recordsSpecimenExampleHint(String example) {
    return 'p. ex. $example';
  }

  @override
  String get recordsSpecimenCurrentCatalogNumber => 'Número de catálogo atual';

  @override
  String recordsSpecimenFieldIdPreview(String id) {
    return 'Pré-visualização: $id';
  }

  @override
  String get recordsSpecimenAutoIncrement =>
      'Incrementar automaticamente o número de catálogo';

  @override
  String get recordsSpecimenSaveFieldIdSettings =>
      'Salvar configurações de ID de campo';

  @override
  String get recordsSpecimenFieldIdSettingsSaved =>
      'Configurações de ID de campo salvas.';

  @override
  String get recordsSpecimenNoProjectFieldIdTitle =>
      'Abra um projeto para definir os IDs de campo do projeto';

  @override
  String get recordsSpecimenNoProjectFieldIdBody =>
      'O prefixo, o número atual e o sufixo são salvos por projeto.';

  @override
  String get recordsSpecimenFieldIdChangeTitle =>
      'Alterar o formato de ID de campo do projeto?';

  @override
  String get recordsSpecimenFieldIdChangeBody =>
      'Alterar o prefixo ou o sufixo do ID de campo do projeto altera os IDs existentes do projeto. Esses identificadores podem já ter sido usados em exportações ou escritos em etiquetas de espécimes. Confira os novos valores antes de alterá-los.';

  @override
  String get recordsSpecimenIUnderstand => 'Entendi';

  @override
  String get recordsSpecimenTissueId => 'ID de tecido';

  @override
  String get recordsSpecimenNextTissueId => 'Próximo ID de tecido';

  @override
  String get recordsSpecimenIndividualTagId => 'ID de etiqueta individual';

  @override
  String get recordsSpecimenNextTag => 'Próxima etiqueta';

  @override
  String get recordsCustomFieldTitle => 'Campos personalizados';

  @override
  String get recordsCustomFieldFieldsTab => 'Campos';

  @override
  String get recordsCustomFieldEditField => 'Editar campo';

  @override
  String recordsCustomFieldLoadError(String error) {
    return 'Não foi possível carregar os campos: $error';
  }

  @override
  String recordsCustomFieldSaved(String name) {
    return '“$name” salvo.';
  }

  @override
  String recordsCustomFieldImportQrError(String error) {
    return 'Não foi possível importar o código QR: $error';
  }

  @override
  String recordsCustomFieldImportError(String error) {
    return 'Não foi possível importar os campos personalizados: $error';
  }

  @override
  String get recordsCustomFieldImportEmpty =>
      'Esta configuração de usuário não contém modelos de campos personalizados.';

  @override
  String recordsCustomFieldImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count definições de campos personalizados importadas.',
      one: '1 definição de campo personalizado importada.',
    );
    return '$_temp0';
  }

  @override
  String recordsCustomFieldExportError(String error) {
    return 'Não foi possível exportar os campos personalizados: $error';
  }

  @override
  String recordsCustomFieldExportedTo(String path) {
    return 'Campos personalizados exportados para $path';
  }

  @override
  String get recordsCustomFieldExported => 'Campos personalizados exportados';

  @override
  String get recordsCustomFieldQrTooLargeTitle => 'O código QR é grande demais';

  @override
  String get recordsCustomFieldQrTooLargeBody =>
      'Os campos personalizados selecionados contêm dados demais para um único código QR. Exporte-os como arquivo.';

  @override
  String get recordsCustomFieldExportFile => 'Exportar arquivo';

  @override
  String get recordsCustomFieldDiscardLegacyTitle =>
      'Descartar os valores legados?';

  @override
  String recordsCustomFieldDiscardLegacyBody(String name) {
    return 'Os valores legados de “$name” não podem ser recuperados depois de descartados.';
  }

  @override
  String get recordsCustomFieldDiscardValues => 'Descartar valores';

  @override
  String get recordsCustomFieldDeleteTitle => 'Excluir o campo personalizado?';

  @override
  String recordsCustomFieldDeleteBody(String name) {
    return 'Excluir “$name” permanentemente? Esta ação não pode ser desfeita.';
  }

  @override
  String get recordsCustomFieldSelectFields => 'Selecionar campos';

  @override
  String get recordsCustomFieldShowArchived => 'Mostrar campos arquivados';

  @override
  String recordsCustomFieldAllArchived(String location) {
    return 'Todos os campos personalizados de $location estão arquivados.';
  }

  @override
  String recordsCustomFieldEmpty(String location) {
    return 'Ainda não há campos personalizados em $location.';
  }

  @override
  String get recordsCustomFieldAdd => 'Adicionar campo personalizado';

  @override
  String get recordsCustomFieldArchived => 'Arquivado';

  @override
  String get recordsCustomFieldActive => 'Ativo';

  @override
  String get recordsCustomFieldDefinitionActions => 'Ações da definição';

  @override
  String get recordsCustomFieldMoveUp => 'Mover para cima';

  @override
  String get recordsCustomFieldMoveDown => 'Mover para baixo';

  @override
  String get recordsCustomFieldRestore => 'Restaurar';

  @override
  String get recordsCustomFieldArchive => 'Arquivar';

  @override
  String get recordsCustomFieldDiscardLegacy => 'Descartar valores legados';

  @override
  String get recordsCustomFieldDeleteInUse => 'Excluir (valores em uso)';

  @override
  String get recordsCustomFieldSelectPrompt =>
      'Selecione um campo personalizado para editar ou adicione um novo.';

  @override
  String get recordsCustomFieldNew => 'Novo campo personalizado';

  @override
  String recordsCustomFieldEditName(String name) {
    return 'Editar $name';
  }

  @override
  String recordsCustomFieldShownIn(String location) {
    return 'Exibido em $location';
  }

  @override
  String get recordsCustomFieldDetails => 'Detalhes';

  @override
  String get recordsCustomFieldStatus => 'Status';

  @override
  String get recordsCustomFieldScope => 'Escopo';

  @override
  String get recordsCustomFieldStoredValues => 'Valores armazenados';

  @override
  String get recordsCustomFieldLegacyValues => 'Valores legados';

  @override
  String get recordsCustomFieldDeletion => 'Exclusão';

  @override
  String get recordsCustomFieldDeletionAvailable => 'Disponível';

  @override
  String get recordsCustomFieldDeletionUnavailable =>
      'Indisponível até que todos os valores armazenados sejam apagados';

  @override
  String recordsCustomFieldUsageLoadError(String error) {
    return 'Não foi possível carregar o uso: $error';
  }

  @override
  String get recordsCustomFieldProjectUuid => 'UUID do projeto';

  @override
  String get recordsCustomFieldDefinitionUuid => 'UUID da definição';

  @override
  String get recordsCustomFieldSourceTemplateUuid => 'UUID do modelo de origem';

  @override
  String get recordsCustomFieldNotFromTemplate => 'Não importado de um modelo';

  @override
  String get recordsCustomFieldTypeText => 'Texto';

  @override
  String get recordsCustomFieldTypeNumber => 'Número';

  @override
  String get recordsCustomFieldTypeBoolean => 'Sim / Não';

  @override
  String get recordsCustomFieldTypeDropdown => 'Lista suspensa';

  @override
  String get recordsCustomFieldScopeGlobal => 'Global';

  @override
  String get recordsCustomFieldScopeProject => 'Projeto atual';

  @override
  String get recordsCustomFieldAllCatalogs => 'Todos os formatos de catálogo';

  @override
  String recordsCustomFieldCatalogOnly(String catalog) {
    return 'Somente $catalog';
  }

  @override
  String get commonSelectAll => 'Selecionar tudo';

  @override
  String get commonClear => 'Limpar';

  @override
  String get commonImport => 'Importar';

  @override
  String get databaseSelectFileFailed =>
      'Não foi possível selecionar o arquivo.';

  @override
  String get databaseReplaceConfirmTitle => 'Substituir o banco de dados?';

  @override
  String get databaseReplace => 'Substituir';

  @override
  String get databaseRestoreCancelled =>
      'Restauração cancelada. O banco de dados não foi substituído.';

  @override
  String get databaseRestoreCannotStop =>
      'A restauração está substituindo seus dados e não pode ser interrompida agora.';

  @override
  String get databaseCancelRestoreTitle => 'Cancelar a restauração?';

  @override
  String get databaseCancelRestoreBody =>
      'O arquivo compactado ainda está sendo lido. Sair agora cancela a restauração e seus dados atuais permanecem intactos.';

  @override
  String get databaseKeepRestoring => 'Continuar restaurando';

  @override
  String get databaseCancelRestore => 'Cancelar restauração';

  @override
  String databaseReplaceFailed(String error) {
    return 'Não foi possível substituir o banco de dados: $error';
  }

  @override
  String get databaseReplaceDatabase => 'Substituir banco de dados';

  @override
  String get databaseReplaceWith => 'Substituir por';

  @override
  String get databaseSourceDescription =>
      'Um arquivo de backup do NAHPU ou um arquivo de banco de dados SQLite.';

  @override
  String get databaseNoFileSelected => 'Nenhum arquivo selecionado';

  @override
  String get databaseBrowse => 'Procurar';

  @override
  String get databaseChangeFile => 'Alterar';

  @override
  String get databaseClearFile => 'Remover arquivo';

  @override
  String get databaseSupportedFormats => 'ZIP, TAR.GZ ou SQLITE3';

  @override
  String get databaseCannotRestore => 'Não pode ser restaurado';

  @override
  String get databaseSqliteDatabase => 'Banco de dados SQLite';

  @override
  String get databaseBackupArchive => 'Arquivo de backup do NAHPU';

  @override
  String databaseBackupArchiveRestores(String database) {
    return 'Arquivo de backup do NAHPU · restaura $database';
  }

  @override
  String get databaseBeforeReplacing => 'Antes de substituir';

  @override
  String get databaseReplaceWarning =>
      'Esta ação substituirá todos os registros do NAHPU. Arquivos de mídia ou de configuração que correspondam ao arquivo de backup serão sobrescritos. Esta ação não pode ser desfeita.';

  @override
  String get databaseBackupFirst => 'Fazer backup dos dados atuais primeiro';

  @override
  String get databaseBackupFirstSubtitle =>
      'Salva um arquivo completo, incluindo as mídias, na pasta de backup do NAHPU';

  @override
  String get databaseNoSafetyBackup =>
      'Sem backup de segurança. Seus registros e mídias atuais não são salvos antes de serem substituídos.';

  @override
  String get databaseComparisonTitle => 'Atual e substituto';

  @override
  String get databaseChooseFileToCompare => 'Escolha um arquivo para comparar.';

  @override
  String get databaseArchiveIncludesConfigs =>
      'Este arquivo também inclui configurações do usuário, que a restauração importa.';

  @override
  String get databaseSchemaVersion => 'Versão do esquema';

  @override
  String get databaseAssociatedFiles => 'Arquivos associados';

  @override
  String get databaseSize => 'Tamanho';

  @override
  String databaseSchemaUpgraded(int version, int current) {
    return 'O esquema v$version do substituto será atualizado para a v$current após a restauração.';
  }

  @override
  String databaseSchemaNewer(int version) {
    return 'O esquema v$version do substituto é mais recente que este aplicativo.';
  }

  @override
  String get databaseTableProjects => 'Projetos';

  @override
  String get databaseTablePersonnel => 'Equipe';

  @override
  String get databaseTableTaxa => 'Táxons';

  @override
  String get databaseTableSites => 'Locais';

  @override
  String get databaseTableCollectionEvents => 'Eventos de coleta';

  @override
  String get databaseTableSpecimens => 'Espécimes';

  @override
  String get databaseTableNarratives => 'Narrativas';

  @override
  String get databaseTableMediaRecords => 'Registros de mídia';

  @override
  String get databaseIssueNotNahpu =>
      'Este arquivo não é um banco de dados do NAHPU. Escolha um arquivo de backup ou de banco de dados do NAHPU.';

  @override
  String get databaseIssueNewerSchema =>
      'Este banco de dados foi criado por uma versão mais recente do NAHPU. Atualize o NAHPU e depois restaure-o.';

  @override
  String get databaseIssueUnreadable =>
      'Não foi possível ler este banco de dados. O arquivo pode estar danificado.';

  @override
  String get databaseColumnCurrent => 'Atual';

  @override
  String get databaseColumnReplacement => 'Substituto';

  @override
  String get databaseColumnChange => 'Diferença';

  @override
  String get databaseRestoring => 'Restaurando o banco de dados';

  @override
  String get databaseRestoreHint =>
      'Restaurar um backup com muitas fotos pode levar vários minutos. Mantenha o NAHPU aberto até terminar.';

  @override
  String get databaseChooseDatabase => 'Escolher banco de dados';

  @override
  String get databaseChooseDatabaseBody =>
      'Este arquivo contém vários arquivos de banco de dados na raiz. Escolha o banco de dados a restaurar.';

  @override
  String get databaseConfirmWithBackup =>
      'Um backup completo dos seus dados atuais será salvo primeiro. Continuar?';

  @override
  String get databaseConfirmWithoutBackup =>
      'Nenhum backup será feito, então seus dados atuais não poderão ser recuperados. Continuar?';

  @override
  String get databaseReplaceSuccess => 'Sucesso 🎉';

  @override
  String get databaseReplaced => 'O banco de dados foi substituído!';

  @override
  String get databaseBackupFilePath => 'Caminho do arquivo de backup:';

  @override
  String get databaseBackToHome => 'Voltar ao início';

  @override
  String databaseIosBackupPath(
    String appDir,
    String backupDir,
    String fileName,
  ) {
    return 'App Arquivos/No meu dispositivo/$appDir/$backupDir/$fileName';
  }

  @override
  String get transferCustomFieldsQrTitle =>
      'Código QR dos campos personalizados';

  @override
  String transferCustomFieldsQrDescription(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Leia este código em outro dispositivo com o NAHPU para importar $count definições de campos personalizados.',
      one:
          'Leia este código em outro dispositivo com o NAHPU para importar 1 definição de campo personalizado.',
    );
    return '$_temp0';
  }

  @override
  String get transferExportCustomFields => 'Exportar campos personalizados';

  @override
  String get transferShowQr => 'Mostrar QR';

  @override
  String get transferExportFile => 'Exportar arquivo';

  @override
  String get transferNoCustomFields =>
      'Nenhum campo personalizado disponível para exportar.';

  @override
  String transferSelectedCount(int selected, int total) {
    return '$selected de $total selecionados';
  }

  @override
  String get transferScopeGlobal => 'Global';

  @override
  String get transferScopeCurrentProject => 'Projeto atual';

  @override
  String get transferArchived => 'Arquivado';

  @override
  String get transferImportCustomFields => 'Importar campos personalizados';

  @override
  String transferReusableDefinitions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count definições reutilizáveis',
      one: '1 definição reutilizável',
    );
    return '$_temp0';
  }

  @override
  String get transferDestination => 'Destino';

  @override
  String get transferCustomFieldImportNote =>
      'As definições são verificadas antes da importação. As que correspondem pelo ID do modelo são atualizadas com segurança; os demais campos permanecem inalterados.';

  @override
  String get transferImportSelectedConfigs =>
      'Importar configurações selecionadas';

  @override
  String get transferWillImport => 'Será importado';

  @override
  String get transferImportSelectedConfigsConfirm =>
      'Importar as configurações selecionadas?';

  @override
  String get transferConfigsImported =>
      'As configurações do usuário selecionadas foram importadas.';

  @override
  String get transferImportConfirmationBody =>
      'Os grupos selecionados serão substituídos. Os campos personalizados são correspondidos pelo ID do modelo e mesclados, então as definições existentes são mantidas. Os grupos não selecionados permanecem inalterados.';

  @override
  String get transferCustomFieldDestination =>
      'Destino dos campos personalizados';

  @override
  String get transferSectionUserConfigs =>
      'Vocabulários controlados e configurações';

  @override
  String get transferSectionRecordExportPresets =>
      'Predefinições de exportação tabular';

  @override
  String get transferSectionTemplatePresets => 'Modelos de documentos';

  @override
  String get transferSectionDocumentLayouts =>
      'Predefinições de layout de documentos';

  @override
  String get transferSectionTemplateTablePreview =>
      'Colunas de visualização da tabela de modelos';

  @override
  String get transferSectionCustomFields => 'Campos personalizados';

  @override
  String get transferConfigSections => 'Seções de configuração';

  @override
  String get transferChooseFileToPreview =>
      'Escolha um arquivo de configurações do usuário para visualizar o conteúdo.';

  @override
  String get transferSelectAtLeastOneSection =>
      'Selecione pelo menos uma seção de configuração.';

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
  String get transferNoSavedEntries => 'Nenhuma entrada salva';

  @override
  String get transferOtherSettings => 'Outras configurações';

  @override
  String get transferNoItems => 'Nenhum item';

  @override
  String transferMappingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mapeamentos',
      one: '1 mapeamento',
    );
    return '$_temp0';
  }

  @override
  String get transferIncompatiblePreset => 'Predefinição incompatível';

  @override
  String transferBlockCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count blocos',
      one: '1 bloco',
    );
    return '$_temp0';
  }

  @override
  String get setupReviewSetup => 'Revisar configuração';

  @override
  String get setupSkipSetup => 'Pular configuração';

  @override
  String get setupStepWelcome => 'Boas-vindas';

  @override
  String get setupCatalogFormat => 'Formato de catálogo';

  @override
  String get setupIdentifiers => 'Identificadores';

  @override
  String get setupStepSites => 'Locais';

  @override
  String get setupStepEvents => 'Eventos';

  @override
  String get setupStepSpecimens => 'Espécimes';

  @override
  String get setupParasites => 'Parasitas';

  @override
  String get setupExportPresets => 'Predefinições de exportação';

  @override
  String get setupStepFinish => 'Concluir';

  @override
  String get setupWelcomeTitle => 'Configure o NAHPU';

  @override
  String get setupWelcomeMessage =>
      'O NAHPU registra espécimes usando as suas próprias convenções. Aqui você define o formato do número de catálogo e os vocabulários controlados para locais, eventos e espécimes.';

  @override
  String get setupWelcomeCatalogFormat =>
      'O grupo taxonômico que você cataloga.';

  @override
  String get setupWelcomeIdentifiers =>
      'Como os números de campo e de tecido são formados.';

  @override
  String get setupControlledVocabularies => 'Vocabulários controlados';

  @override
  String get setupWelcomeVocabularies =>
      'Os vocabulários para locais, eventos e espécimes.';

  @override
  String get setupWelcomeExportPresets =>
      'Layouts de impressão e predefinições tabulares incluídos para exportações.';

  @override
  String get setupWelcomeNotPermanent =>
      'Isso leva alguns minutos e nada aqui é permanente. Todas as respostas podem ser alteradas depois em Configurações ou executando este assistente novamente.';

  @override
  String get setupImportTitle => 'Já tem as configurações da sua equipe?';

  @override
  String get setupImportMessage =>
      'Uma equipe só precisa configurar isso uma vez. Se a sua equipe já configurou o NAHPU, importe o arquivo de configurações do usuário dela e você poderá pular o restante deste assistente. No final, você pode exportar as suas para os demais.';

  @override
  String get setupCatalogFormatMessage =>
      'O formato define quais campos de medidas aparecem nos registros de espécimes.';

  @override
  String get setupCatalogFormatNote =>
      'Você pode alterar o formato de catálogo a qualquer momento, e um mesmo projeto pode conter registros em mais de um formato. Escolha o formato que você usará com mais frequência.';

  @override
  String setupCatalogFormatLoadError(String error) {
    return 'Não foi possível carregar o formato de catálogo: $error';
  }

  @override
  String get setupFieldIdsTitle => 'IDs de campo dos espécimes';

  @override
  String get setupFieldIdsMessage =>
      'Escolha a sua estratégia de ID de campo. Você concluirá a configuração de IDs ao criar um novo projeto.';

  @override
  String get setupIdentifiersNote =>
      'Essas configurações de identificadores podem ser alteradas para outro projeto. Você pode defini-las em Configurações > Catálogos.';

  @override
  String get setupTissueIdsTitle => 'IDs de tecidos';

  @override
  String get setupTissueIdsMessage =>
      'Algumas coleções numeram os tecidos separadamente do espécime. Defina aqui se a sua coleção usa isso. Se você não definir um ID de tecido, o NAHPU usa automaticamente o ID de campo do espécime.';

  @override
  String get setupUseSeparateTissueId => 'Usar um ID de tecido separado';

  @override
  String get setupNextTissueId => 'Próximo ID de tecido';

  @override
  String get setupSitesTitle => 'Vocabulários de locais';

  @override
  String get setupSitesMessage =>
      'Os vocabulários controlados para os formulários de locais e coordenadas. Adicione os seus próprios termos, remova os que não usará ou mantenha os padrões. Você pode atualizar essas listas depois em Configurações > Locais.';

  @override
  String get setupSiteTypes => 'Tipos de local';

  @override
  String get setupHabitatTypes => 'Tipos de hábitat';

  @override
  String get setupDatums => 'Datums';

  @override
  String get setupEventsTitle => 'Vocabulários de eventos de coleta';

  @override
  String get setupEventsMessage =>
      'Os vocabulários controlados para os eventos de coleta. Você pode atualizar essas listas depois em Configurações > Eventos.';

  @override
  String get setupPrimaryActivities => 'Atividades principais';

  @override
  String get setupCollectionMethods => 'Métodos de coleta';

  @override
  String get setupPersonnelRoles => 'Funções da equipe';

  @override
  String get setupSpecimensTitle => 'Vocabulários de espécimes';

  @override
  String get setupSpecimensMessage =>
      'Os vocabulários controlados para os registros de espécimes. Você pode atualizar essas listas depois em Configurações > Espécimes.';

  @override
  String get setupIdentificationMethods => 'Métodos de identificação';

  @override
  String get setupLifeStages => 'Estágios de vida';

  @override
  String get setupSpecimenTypes => 'Tipos de espécime';

  @override
  String get setupTreatments => 'Tratamentos';

  @override
  String get setupConditions => 'Condições';

  @override
  String get setupParasitesMessage =>
      'O NAHPU tem um formulário de parasitas separado para associar registros de parasitas a espécimes. A chave abaixo permite configurar os vocabulários controlados para registros de parasitas.';

  @override
  String get setupCollectsParasites => 'Vou coletar parasitas';

  @override
  String get setupParasiteCategories => 'Categorias';

  @override
  String get setupDetectionMethods => 'Métodos de detecção';

  @override
  String get setupPreparationMethods => 'Métodos de preparação';

  @override
  String get setupAnatomicalLocations => 'Localizações anatômicas';

  @override
  String get setupStorage => 'Armazenamento';

  @override
  String get setupFinishTitle => 'Tudo configurado';

  @override
  String get setupFinishMessage =>
      'O NAHPU usará essas convenções para novos registros.';

  @override
  String get setupNotSet => 'Não definido';

  @override
  String get setupFieldId => 'ID de campo';

  @override
  String get setupProjectId => 'ID do projeto';

  @override
  String get setupPersonnelId => 'ID do pessoal';

  @override
  String get setupTissueId => 'ID de tecido';

  @override
  String get setupTissueNumberedSeparately => 'Numerado separadamente';

  @override
  String get setupTissueFollowsSpecimen => 'Segue o espécime';

  @override
  String get setupParasitesCollected => 'Coletados';

  @override
  String get setupParasitesNotCollected => 'Não coletados';

  @override
  String get setupShareTitle =>
      'Compartilhe esta configuração com a sua equipe';

  @override
  String get setupShareMessage =>
      'A sua equipe só precisa fazer isso uma vez. Exporte essas configurações do usuário e compartilhe com os membros da equipe ou colaboradores para que todos trabalhem com os mesmos vocabulários e configurações.';

  @override
  String get setupFinishNote =>
      'Nada aqui é definitivo. Altere qualquer configuração em Configurações ou execute Configurar o NAHPU novamente pelo menu.';

  @override
  String get setupExportPresetsMessage =>
      'Estas são as predefinições padrão para exportar registros. Os layouts de impressão serão usados para etiquetas, rótulos e cadernetas de campo. As predefinições tabulares serão usadas para planilhas. Você pode gerenciar ou criar as suas próprias predefinições no menu Configurações.';

  @override
  String get setupPresetDefaults => 'Padrões';

  @override
  String get setupPresetDefaultsMessage =>
      'Predefinições adequadas a qualquer formato de catálogo.';

  @override
  String setupPresetsForFormat(String catalogFormat) {
    return 'Para $catalogFormat';
  }

  @override
  String get setupPresetsForFormatMessage =>
      'Predefinições opcionais criadas para este formato de catálogo.';

  @override
  String get setupAddSelectedPresets => 'Adicionar predefinições selecionadas';

  @override
  String setupBundledPresetsLoadError(String error) {
    return 'Não foi possível carregar as predefinições incluídas: $error';
  }

  @override
  String setupAddPresetsError(String error) {
    return 'Falha ao adicionar as predefinições: $error';
  }

  @override
  String setupExportPresetCounts(int documentCount, int tabularCount) {
    return '$documentCount de documento, $tabularCount tabulares';
  }

  @override
  String get commonClose => 'Fechar';

  @override
  String get commonCreate => 'Criar';

  @override
  String get commonSelect => 'Selecionar';

  @override
  String get presetsTemplateDeleteTitle => 'Excluir modelo';

  @override
  String presetsDeleteNamePrompt(String name) {
    return 'Excluir \"$name\"?';
  }

  @override
  String get presetsTemplateUnusedDelete =>
      'Este modelo não está em uso e será removido permanentemente.';

  @override
  String presetsTemplateInUse(int blockCount, int layoutCount) {
    String _temp0 = intl.Intl.pluralLogic(
      blockCount,
      locale: localeName,
      other: '$blockCount blocos',
      one: '1 bloco',
    );
    String _temp1 = intl.Intl.pluralLogic(
      layoutCount,
      locale: localeName,
      other: '$layoutCount layouts de impressão',
      one: '1 layout de impressão',
    );
    return 'Este modelo é usado por $_temp0 em $_temp1. Escolha um substituto antes de excluí-lo.';
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
      other: 'blocos',
      one: 'bloco',
    );
    return '$layoutName: $_temp0 $blocks';
  }

  @override
  String get presetsTemplateNoReplacement =>
      'Crie outro modelo com o mesmo tipo de registro ou altere os blocos de layout afetados antes de excluir este.';

  @override
  String get presetsTemplateReplacement => 'Modelo substituto';

  @override
  String get presetsTemplateReplacementNote =>
      'O tamanho da página, as margens, a grade e o espaçamento interno não serão alterados. Revise os layouts de impressão afetados após a substituição.';

  @override
  String get presetsTemplateEmpty =>
      'Ainda não há modelos. Os modelos definem o conteúdo colocado nos blocos dos layouts de impressão.';

  @override
  String get presetsTemplateNoMatch =>
      'Nenhum modelo corresponde à sua pesquisa.';

  @override
  String get presetsTemplateNoneToExport => 'Não há modelos para exportar';

  @override
  String get presetsTemplateExportTitle => 'Exportar modelos';

  @override
  String presetsTemplateCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modelos',
      one: '1 modelo',
    );
    return '$_temp0';
  }

  @override
  String presetsTemplateInvalidFile(String error) {
    return 'Arquivo de modelo inválido: $error';
  }

  @override
  String presetsTemplateImportFailed(String error) {
    return 'Erro ao importar os modelos: $error';
  }

  @override
  String presetsTemplateImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modelos importados',
      one: '1 modelo importado',
    );
    return '$_temp0';
  }

  @override
  String presetsTemplateImportedPartial(int imported, int offered, int limit) {
    return '$imported de $offered modelos importados (limite: $limit)';
  }

  @override
  String presetsTemplateLoadError(String error) {
    return 'Não foi possível carregar os modelos: $error';
  }

  @override
  String presetsTemplateDeleted(String name) {
    return '\"$name\" excluído';
  }

  @override
  String presetsTemplateDeletedUpdated(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count blocos atualizados',
      one: '1 bloco atualizado',
    );
    return '\"$name\" excluído e $_temp0';
  }

  @override
  String presetsTemplateDeleteError(String error) {
    return 'Não foi possível excluir o modelo: $error';
  }

  @override
  String get presetsTemplateSearchHint => 'Pesquisar modelos';

  @override
  String get presetsUnused => 'Sem uso';

  @override
  String presetsTemplateLayoutCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count layouts',
      one: '1 layout',
    );
    return '$_temp0';
  }

  @override
  String get presetsTemplateOptions => 'Opções do modelo';

  @override
  String get presetsRecordTypeSpecimen => 'Espécime';

  @override
  String get presetsRecordTypeSite => 'Local';

  @override
  String get presetsRecordTypeCollEvent => 'Evento de coleta';

  @override
  String get presetsRecordTypeNarrative => 'Narrativa';

  @override
  String get presetsRecordTypeSpecimenParts => 'Partes do espécime';

  @override
  String get presetsRecordTypeParasites => 'Parasitas';

  @override
  String get presetsRecordTypeNone => 'Sem registros';

  @override
  String presetsFontReadError(String error) {
    return 'Não foi possível ler as fontes: $error';
  }

  @override
  String get presetsFonts => 'Fontes';

  @override
  String presetsFontInstalled(String family) {
    return '$family instalada';
  }

  @override
  String presetsFontInstallError(String error) {
    return 'Não foi possível instalar a fonte: $error';
  }

  @override
  String presetsFontInUseTitle(String family) {
    return '$family está em uso';
  }

  @override
  String presetsFontInUseBody(int count, String templates) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'nestes modelos',
      one: 'neste modelo',
    );
    return 'Remova ou altere esta fonte $_temp0 antes de excluí-la:\n\n$templates';
  }

  @override
  String presetsFontDeleteTitle(String family) {
    return 'Excluir $family?';
  }

  @override
  String get presetsFontDeleteBody =>
      'Os arquivos da fonte são removidos desta instalação. Os modelos que a usam em outros lugares não são alterados.';

  @override
  String get presetsFontSearch => 'Pesquisar fontes';

  @override
  String get presetsFontInstall => 'Instalar fonte';

  @override
  String get presetsFontFind => 'Encontrar fontes';

  @override
  String get presetsFontLicenseNote =>
      'Baixe uma fonte no navegador e depois instale o arquivo .ttf ou .otf aqui. Você é responsável pela licença de qualquer fonte que instalar.';

  @override
  String get presetsFontNoMatch => 'Nenhuma fonte corresponde à sua pesquisa';

  @override
  String get presetsFontInstalledByYou => 'Instaladas por você';

  @override
  String get presetsFontBundledWithNahpu => 'Incluídas no NAHPU';

  @override
  String presetsFontFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count arquivos',
      one: '1 arquivo',
    );
    return '$_temp0';
  }

  @override
  String presetsFontUsedByCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Usada por $count modelos',
      one: 'Usada por 1 modelo',
    );
    return '$_temp0';
  }

  @override
  String get presetsFontDelete => 'Excluir fonte';

  @override
  String get presetsFontSelectToPreview =>
      'Selecione uma fonte para visualizá-la';

  @override
  String get presetsFontBundled => 'Incluída';

  @override
  String get presetsFontInstalledLabel => 'Instalada';

  @override
  String presetsFontUsedBy(String templates) {
    return 'Usada por $templates';
  }

  @override
  String get presetsFontSize => 'Tamanho';

  @override
  String presetsMaxReached(int max) {
    return 'O máximo de $max predefinições foi atingido.';
  }

  @override
  String presetsImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count predefinições importadas',
      one: '1 predefinição importada',
    );
    return '$_temp0';
  }

  @override
  String presetsImportFailed(String error) {
    return 'Erro ao importar as predefinições: $error';
  }

  @override
  String get presetsNoneToExport => 'Não há predefinições para exportar';

  @override
  String get presetsExportTabularTitle => 'Exportar predefinições tabulares';

  @override
  String presetsTabularCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count predefinições tabulares',
      one: '1 predefinição tabular',
    );
    return '$_temp0';
  }

  @override
  String presetsExportFailed(String error) {
    return 'Erro ao exportar as predefinições: $error';
  }

  @override
  String get presetsTabularTitle => 'Predefinições de exportação tabular';

  @override
  String get presetsTabPresets => 'Predefinições';

  @override
  String get presetsTabEditPreset => 'Editar predefinição';

  @override
  String get presetsSelectPresets => 'Selecionar predefinições';

  @override
  String get presetsTabularEmpty =>
      'Ainda não há predefinições tabulares. Crie ou importe uma, ou adicione as predefinições do seu formato de catálogo em Configurar o NAHPU.';

  @override
  String presetsMappingSummary(int count, String recordType) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mapeamentos',
      one: '1 mapeamento',
    );
    return '$_temp0 · $recordType';
  }

  @override
  String get presetsExportThisPreset => 'Exportar esta predefinição';

  @override
  String presetsErrorDetail(String error) {
    return 'Erro: $error';
  }

  @override
  String get presetsDeletePresetTitle => 'Excluir predefinição';

  @override
  String presetsDeletePresetConfirm(String name) {
    return 'Tem certeza de que deseja excluir a predefinição \"$name\"?';
  }

  @override
  String get presetsSelectToEdit => 'Selecione uma predefinição para editar';

  @override
  String get presetsNotFound => 'Predefinição não encontrada';

  @override
  String get presetsLoadError => 'Erro ao carregar a predefinição';

  @override
  String get presetsNewPreset => 'Nova predefinição';

  @override
  String get presetsName => 'Nome da predefinição';

  @override
  String get presetsNameExists => 'Já existe uma predefinição com este nome';

  @override
  String get presetsNameEmpty => 'O nome não pode ficar vazio';

  @override
  String get presetsNameInvalidChars =>
      'Somente letras, números, sublinhados e hifens são permitidos';

  @override
  String get presetsPreviewEmptyTitle => 'Sem dados para visualização';

  @override
  String get presetsPreviewEmptyBody =>
      'Nenhum registro correspondeu aos filtros selecionados ou não há mapeamentos.';

  @override
  String presetsPreviewFailed(String error) {
    return 'Erro ao gerar a visualização: $error';
  }

  @override
  String presetsSaveError(String error) {
    return 'Não foi possível salvar: $error';
  }

  @override
  String get presetsNameRequired =>
      'O nome da predefinição não pode ficar vazio.';

  @override
  String presetsNameTaken(String name) {
    return 'Já existe uma predefinição chamada \"$name\".';
  }

  @override
  String presetsUpdateError(String error) {
    return 'Não foi possível atualizar: $error';
  }

  @override
  String get presetsDuplicateTitle => 'Duplicar predefinição';

  @override
  String presetsDuplicateError(String error) {
    return 'Não foi possível duplicar: $error';
  }

  @override
  String presetsEditTitle(String name) {
    return 'Editar $name';
  }

  @override
  String get presetsEditFields => 'Editar campos';

  @override
  String get presetsPreviewExportTable => 'Visualizar tabela de exportação';

  @override
  String get presetsSaving => 'Salvando…';

  @override
  String get presetsSavedAutomatically => 'Salvo automaticamente';

  @override
  String get presetsRecordType => 'Tipo de registro';

  @override
  String get presetsSpecimenTaxonGroup => 'Grupo taxonômico do espécime';

  @override
  String get presetsHeaderFormat => 'Formato do cabeçalho gerado';

  @override
  String get presetsHeaderNahpuNamespace =>
      'Namespace do NAHPU (nahpu:table.field)';

  @override
  String presetsPreviewSites(int count) {
    return 'Visualizar locais ($count selecionados)';
  }

  @override
  String presetsPreviewEvents(int count) {
    return 'Visualizar eventos ($count selecionados)';
  }

  @override
  String presetsPreviewNarratives(int count) {
    return 'Visualizar narrativas ($count selecionadas)';
  }

  @override
  String presetsPreviewSpecimenParts(int count) {
    return 'Visualizar partes de espécime ($count selecionadas)';
  }

  @override
  String presetsPreviewParasites(int count) {
    return 'Visualizar parasitas ($count selecionados)';
  }

  @override
  String presetsPreviewSpecimens(int count) {
    return 'Visualizar espécimes ($count selecionados)';
  }

  @override
  String get presetsPreviewCurrentProject => 'Projeto atual (nenhum)';

  @override
  String get presetsDocumentTitle => 'Predefinições de documentos';

  @override
  String get presetsPrintLayouts => 'Layouts de impressão';

  @override
  String get presetsTemplates => 'Modelos';

  @override
  String get presetsDocumentNew => 'Nova predefinição de documento';

  @override
  String presetsRenamed(String name) {
    return 'Renomeada para $name';
  }

  @override
  String presetsRenameFailed(String error) {
    return 'Erro ao renomear: $error';
  }

  @override
  String get presetsExportPrintLayoutsTitle => 'Exportar layouts de impressão';

  @override
  String presetsPrintLayoutCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count layouts de impressão',
      one: '1 layout de impressão',
    );
    return '$_temp0';
  }

  @override
  String presetsDocumentInvalidFile(String error) {
    return 'Arquivo de layout de documento inválido: $error';
  }

  @override
  String get presetsDocumentEmpty =>
      'Ainda não há layouts de impressão. Crie ou importe um, ou carregue os layouts padrão.';

  @override
  String get presetsIncompatible => 'Predefinição incompatível';

  @override
  String get presetsIncompatibleBody =>
      'Esta predefinição não é compatível com a versão atual.';

  @override
  String get presetsPreviewNoRecords =>
      'Não há registros de visualização para este tipo';

  @override
  String get presetsPreviewSelectSpecimenParts =>
      'Selecione partes de espécime para visualização';

  @override
  String get presetsPreviewSelectParasites =>
      'Selecione parasitas para visualização';

  @override
  String get presetsPreviewSelectSpecimens =>
      'Selecione espécimes para visualização';

  @override
  String get presetsTableColumns => 'Colunas da tabela';

  @override
  String get commonApply => 'Aplicar';

  @override
  String get exportFieldsTitle => 'Editar mapeamentos da predefinição';

  @override
  String get exportFieldsAvailableFields => 'Campos disponíveis';

  @override
  String get exportFieldsSelectedMappings => 'Mapeamentos selecionados';

  @override
  String get exportFieldsNoPreviewTitle => 'Sem dados para visualizar';

  @override
  String get exportFieldsNoPreviewBody =>
      'Nenhum registro corresponde aos filtros selecionados ou os mapeamentos estão vazios.';

  @override
  String exportFieldsPreviewFailed(String error) {
    return 'Falha ao gerar a visualização: $error';
  }

  @override
  String get exportFieldsInsertSourceField => 'Inserir campo de origem';

  @override
  String get exportFieldsDisplayTableField => 'Tabela::Campo';

  @override
  String get exportFieldsDisplayFieldOnly => 'Somente o campo';

  @override
  String get exportFieldsOtherFields => 'Outros campos';

  @override
  String get exportFieldsSelectField => 'Selecionar campo';

  @override
  String get exportFieldsChooseField => 'Escolha um campo';

  @override
  String get exportFieldsCloseFieldPicker => 'Fechar o seletor de campos';

  @override
  String get exportFieldsSearchFields => 'Pesquisar campos ou tabelas';

  @override
  String get exportFieldsNoMatchingFields => 'Nenhum campo correspondente.';

  @override
  String get exportFieldsAddCustomField => 'Adicionar campo personalizado';

  @override
  String get exportFieldsAddNested => 'Adicionar aninhado';

  @override
  String get exportFieldsUnnamed => 'Sem nome';

  @override
  String exportFieldsCardNested(String name) {
    return 'Aninhado: $name';
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
    return 'Colunas indexadas · $style';
  }

  @override
  String get exportFieldsCardDarwinCoreSeparator =>
      'Uma coluna · separador \" | \" do Darwin Core';

  @override
  String exportFieldsCardSeparator(String separator) {
    return 'Uma coluna · separador $separator';
  }

  @override
  String exportFieldsCardFormat(String format, String options) {
    return 'Formato: $format · Opções: $options';
  }

  @override
  String get exportFieldsCustomize => 'Personalizar';

  @override
  String get exportFieldsOneColumn => 'Uma coluna';

  @override
  String get exportFieldsIndexedColumns => 'Colunas indexadas';

  @override
  String get exportFieldsRepeatedRows => 'Linhas repetidas';

  @override
  String get exportFieldsFormatConditionalBrackets => 'colchetes condicionais';

  @override
  String get exportFieldsFormatConditionalField => 'campo condicional';

  @override
  String get exportFieldsFormatConditionalValue => 'valor condicional';

  @override
  String get exportFieldsMappingType => 'Tipo de mapeamento';

  @override
  String get exportFieldsKindSingle => 'Campo único';

  @override
  String get exportFieldsKindCustom => 'Campo personalizado';

  @override
  String get exportFieldsKindList => 'Campo de lista';

  @override
  String get exportFieldsKindNested => 'Registros aninhados';

  @override
  String get exportFieldsSourceField => 'Campo de origem';

  @override
  String get exportFieldsSourceFieldHelper =>
      'Escolha o campo do NAHPU que fornece esta coluna.';

  @override
  String get exportFieldsColumnNameOptional => 'Nome da coluna (opcional)';

  @override
  String get exportFieldsColumnNameOptionalHelper =>
      'Deixe em branco para usar o nome do campo de origem.';

  @override
  String get exportFieldsListOutput => 'Saída da lista';

  @override
  String exportFieldsExample(String example) {
    return 'Exemplo: $example';
  }

  @override
  String get exportFieldsDarwinCoreListSeparator =>
      'Os valores de lista do Darwin Core são separados por \" | \".';

  @override
  String get exportFieldsSeparator => 'Separador';

  @override
  String get exportFieldsSeparatorPipe => 'Barra vertical (A | B)';

  @override
  String get exportFieldsSeparatorComma => 'Vírgula (A, B)';

  @override
  String get exportFieldsSeparatorSemicolon => 'Ponto e vírgula (A; B)';

  @override
  String get exportFieldsSeparatorSlash => 'Barra (A / B)';

  @override
  String get exportFieldsSeparatorNewLine => 'Nova linha';

  @override
  String get exportFieldsSeparatorBulleted => 'Com marcadores';

  @override
  String get exportFieldsSeparatorCustom => 'Personalizado';

  @override
  String get exportFieldsCustomSeparator => 'Separador personalizado';

  @override
  String get exportFieldsValueFormat => 'Formato do valor';

  @override
  String get exportFieldsValueNormal => 'Texto normal';

  @override
  String get exportFieldsValueEncoded => 'Texto codificado';

  @override
  String get exportFieldsValueCoordinates => 'Coordenadas';

  @override
  String get exportFieldsValueConditionalBrackets => 'Colchetes condicionais';

  @override
  String get exportFieldsValueConditionalField => 'Campo condicional';

  @override
  String get exportFieldsValueConditionalValue => 'Valor condicional';

  @override
  String get exportFieldsReplacementText => 'Texto de substituição';

  @override
  String get exportFieldsReplacementTextHelper =>
      'Escrito quando a condição é atendida; caso contrário, o valor original é mantido.';

  @override
  String get exportFieldsColumnName => 'Nome da coluna';

  @override
  String get exportFieldsColumnNameHelper =>
      'Dê um nome à coluna de saída que contém o valor personalizado.';

  @override
  String get exportFieldsRelatedRecords => 'Registros relacionados';

  @override
  String get exportFieldsRelatedRecordsHelper =>
      'Selecione o grupo de registros repetidos a exportar.';

  @override
  String get exportFieldsSelectedChildFields => 'Campos filhos selecionados';

  @override
  String get exportFieldsSelectChildFieldHint =>
      'Selecione pelo menos um campo filho abaixo.';

  @override
  String get exportFieldsMoveUp => 'Mover para cima';

  @override
  String get exportFieldsMoveDown => 'Mover para baixo';

  @override
  String get exportFieldsRemoveField => 'Remover campo';

  @override
  String get exportFieldsChooseChildFields => 'Escolher campos filhos';

  @override
  String get exportFieldsColumnPrefixOptional => 'Prefixo da coluna (opcional)';

  @override
  String get exportFieldsNestedOutput => 'Saída aninhada';

  @override
  String get exportFieldsNestedOneColumnHint =>
      'Combina todos os registros filhos em uma única célula.';

  @override
  String get exportFieldsNestedIndexedHint =>
      'Cria um grupo de colunas para cada registro.';

  @override
  String get exportFieldsNestedRepeatedHint =>
      'Cria uma linha de exportação para cada registro filho.';

  @override
  String get exportFieldsNestedRepeatedTaken =>
      'Outro mapeamento já expande as linhas de exportação.';

  @override
  String get exportFieldsFieldSeparator => 'Separador de campos';

  @override
  String get exportFieldsRecordSeparator => 'Separador de registros';

  @override
  String get exportFieldsAdvanced => 'Avançado';

  @override
  String get exportFieldsRawExpression => 'Expressão de origem bruta';

  @override
  String get exportFieldsRawFormatOption => 'Opção de formato bruta';

  @override
  String get exportFieldsRawFormatOptionHelper =>
      'Por exemplo: enum, dms ou custom_map:0=No.';

  @override
  String get exportFieldsEmptyValue => 'Valor vazio';

  @override
  String get exportFieldsEmptyBlank => 'Em branco';

  @override
  String get exportFieldsEmptyCustomText => 'Texto personalizado';

  @override
  String get exportFieldsCustomEmptyText =>
      'Texto personalizado para valores vazios';

  @override
  String get exportFieldsRawNamespace =>
      'Namespace bruto dos registros relacionados';

  @override
  String exportFieldsErrorReplacement(int number, String error) {
    return 'Substituição $number: $error';
  }

  @override
  String get exportFieldsErrorChooseGroup =>
      'Escolha um grupo de registros relacionados.';

  @override
  String get exportFieldsErrorChooseChild =>
      'Escolha pelo menos um campo filho.';

  @override
  String get exportFieldsErrorSeparatorsEmpty =>
      'Os separadores de campos e de registros não podem ficar vazios.';

  @override
  String get exportFieldsErrorMultiFieldHeader =>
      'Defina um cabeçalho personalizado para um mapeamento concatenado de vários campos.';

  @override
  String get exportFieldsErrorAddSegment =>
      'Adicione pelo menos um campo ou segmento de texto.';

  @override
  String get exportFieldsErrorChooseSource => 'Escolha um campo de origem.';

  @override
  String get exportFieldsErrorCompositeHeader =>
      'Defina um cabeçalho personalizado para um mapeamento composto.';

  @override
  String get exportFieldsErrorIndexedSingleSource =>
      'Listas indexadas exigem exatamente um campo de origem.';

  @override
  String get exportFieldsErrorConditionalSingleSource =>
      'A saída condicional exige exatamente um campo de origem.';

  @override
  String get exportFieldsErrorAddCondition =>
      'Adicione pelo menos uma condição.';

  @override
  String get exportFieldsErrorReplacementText =>
      'Insira o texto de substituição.';

  @override
  String get exportFieldsErrorControllingField =>
      'Escolha um campo de controle para cada condição de colchetes.';

  @override
  String get exportFieldsErrorComparisonValue =>
      'Insira um valor de comparação para cada condição de colchetes.';

  @override
  String get exportFieldsErrorSelfDependency =>
      'Um campo condicional não pode depender de si mesmo.';

  @override
  String get exportFieldsCustomValue => 'Valor personalizado';

  @override
  String get exportFieldsCustomValueHelp =>
      'Os campos e o texto são escritos da esquerda para a direita. Adicione quantos segmentos forem necessários.';

  @override
  String get exportFieldsCustomValueEmpty =>
      'Adicione um campo ou texto para começar.';

  @override
  String get exportFieldsTextOrSeparator => 'Texto ou separador';

  @override
  String get exportFieldsShowLabel => 'Mostrar rótulo';

  @override
  String get exportFieldsEditConditionalText => 'Editar texto condicional';

  @override
  String get exportFieldsMoveSegmentUp => 'Mover segmento para cima';

  @override
  String get exportFieldsMoveSegmentDown => 'Mover segmento para baixo';

  @override
  String get exportFieldsRemoveSegment => 'Remover segmento';

  @override
  String get exportFieldsAddField => 'Adicionar campo';

  @override
  String get exportFieldsAddText => 'Adicionar texto';

  @override
  String get exportFieldsAddConditionalText => 'Adicionar texto condicional';

  @override
  String exportFieldsExpression(String expression) {
    return 'Expressão: $expression';
  }

  @override
  String get exportFieldsAddSourceField => 'Adicionar campo de origem';

  @override
  String get exportFieldsConditionalText => 'Texto condicional';

  @override
  String get exportFieldsTextWhenMatched => 'Texto quando corresponder';

  @override
  String exportFieldsTextWhenMatchedHelper(String example) {
    return 'Campos como $example são preenchidos.';
  }

  @override
  String get exportFieldsTextOtherwise => 'Texto caso contrário (opcional)';

  @override
  String get exportFieldsTextOtherwiseHelper =>
      'Deixe vazio para não escrever nada.';

  @override
  String get exportFieldsSummaryOr => 'ou';

  @override
  String get exportFieldsSummaryAnd => 'e';

  @override
  String exportFieldsSummaryIf(String conditions, String text) {
    return 'Se $conditions → \"$text\"';
  }

  @override
  String exportFieldsSummaryIfOtherwise(
    String conditions,
    String text,
    String otherwise,
  ) {
    return 'Se $conditions → \"$text\"; caso contrário, \"$otherwise\"';
  }

  @override
  String exportFieldsSummaryEquals(String field, String value) {
    return '$field é igual a \"$value\"';
  }

  @override
  String exportFieldsSummaryNotEquals(String field, String value) {
    return '$field não é igual a \"$value\"';
  }

  @override
  String exportFieldsSummaryContains(String field, String value) {
    return '$field contém \"$value\"';
  }

  @override
  String exportFieldsSummaryIsNotEmpty(String field) {
    return '$field não está vazio';
  }

  @override
  String exportFieldsSummaryIsEmpty(String field) {
    return '$field está vazio';
  }

  @override
  String get exportFieldsValueConditions => 'Condições do valor';

  @override
  String get exportFieldsFieldConditions => 'Condições de campo';

  @override
  String get exportFieldsConditionsHelp =>
      'Compara os valores brutos armazenados. Valores de controle em branco nunca correspondem.';

  @override
  String get exportFieldsMatchLogic => 'Lógica de correspondência';

  @override
  String get exportFieldsMatchAny => 'Qualquer condição (OU)';

  @override
  String get exportFieldsMatchAll => 'Todas as condições (E)';

  @override
  String get exportFieldsAddCondition => 'Adicionar condição';

  @override
  String get exportFieldsControllingField => 'Campo de controle';

  @override
  String get exportFieldsOperatorEquals => 'É igual a';

  @override
  String get exportFieldsOperatorNotEquals => 'Não é igual a';

  @override
  String get exportFieldsOperatorContains => 'Contém';

  @override
  String get exportFieldsOperatorIsNotEmpty => 'Não está vazio';

  @override
  String get exportFieldsOperatorIsEmpty => 'Está vazio';

  @override
  String get exportFieldsValue => 'Valor';

  @override
  String get exportFieldsRemoveCondition => 'Remover condição';

  @override
  String get exportFieldsIndexedColumnNames => 'Nomes das colunas indexadas';

  @override
  String exportFieldsIndexedUnderscore(String example) {
    return 'Sublinhado: $example';
  }

  @override
  String exportFieldsIndexedCompact(String example) {
    return 'Compacto: $example';
  }

  @override
  String exportFieldsIndexedBrackets(String example) {
    return 'Colchetes: $example';
  }

  @override
  String get exportFieldsOutputExample => 'Exemplo de saída';

  @override
  String get exportFieldsOutputExampleEmpty =>
      'Conclua o mapeamento para ver o formato da saída.';

  @override
  String get exportFieldsOutputExampleRows =>
      'Cada registro filho cria outra linha de exportação.';

  @override
  String get exportFieldsCustomizeNested => 'Personalizar mapeamento aninhado';

  @override
  String get exportFieldsCustomizeField => 'Personalizar mapeamento de campo';

  @override
  String get exportFieldsPreviewTitle => 'Visualização da exportação';

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
  String get commonSave => 'Salvar';

  @override
  String get commonYes => 'Sim';

  @override
  String get commonNo => 'Não';

  @override
  String get formsChooseOne => 'Escolha uma opção';

  @override
  String formsErrorDetail(String error) {
    return 'Erro: $error';
  }

  @override
  String formsAddValue(String type) {
    return 'Adicionar $type';
  }

  @override
  String formsEnterValue(String type) {
    return 'Insira $type';
  }

  @override
  String get formsMatchDatabase => 'Corresponder ao banco de dados';

  @override
  String formsMatchDatabaseTitle(String plural) {
    return 'Corresponder $plural ao banco de dados?';
  }

  @override
  String get formsMatchAppendMissing => 'Adicionar ausentes';

  @override
  String get formsMatchOverrideAll => 'Substituir tudo';

  @override
  String get formsMatchHelp =>
      'Use esta opção ao receber registros de alguém cujos vocabulários controlados você não tem.';

  @override
  String formsMatchAppendDescription(String plural) {
    return 'Adicione os valores encontrados no banco de dados sem alterar seus $plural existentes.';
  }

  @override
  String formsMatchOverrideDescription(String plural) {
    return 'Substitua todos os $plural configurados pelos valores encontrados atualmente no banco de dados.';
  }

  @override
  String get formsVocabSiteType => 'tipo de local';

  @override
  String get formsVocabSiteTypePlural => 'tipos de local';

  @override
  String get formsVocabHabitatType => 'tipo de hábitat';

  @override
  String get formsVocabHabitatTypePlural => 'tipos de hábitat';

  @override
  String get formsVocabDatum => 'datum';

  @override
  String get formsVocabDatumPlural => 'datums';

  @override
  String get formsVocabPrimaryActivity => 'atividade principal';

  @override
  String get formsVocabPrimaryActivityPlural => 'atividades principais';

  @override
  String get formsVocabCollectionMethod => 'método de coleta';

  @override
  String get formsVocabCollectionMethodPlural => 'métodos de coleta';

  @override
  String get formsVocabPersonnelRole => 'função da equipe';

  @override
  String get formsVocabPersonnelRolePlural => 'funções da equipe';

  @override
  String get formsVocabIdentificationMethod => 'método de identificação';

  @override
  String get formsVocabIdentificationMethodPlural => 'métodos de identificação';

  @override
  String get formsVocabLifeStage => 'estágio de vida';

  @override
  String get formsVocabLifeStagePlural => 'estágios de vida';

  @override
  String get formsVocabSpecimenType => 'tipo de espécime';

  @override
  String get formsVocabSpecimenTypePlural => 'tipos de espécime';

  @override
  String get formsVocabTreatment => 'tratamento';

  @override
  String get formsVocabTreatmentPlural => 'tratamentos';

  @override
  String get formsVocabCondition => 'condição';

  @override
  String get formsVocabConditionPlural => 'condições';

  @override
  String get formsVocabParasiteCategory => 'categoria';

  @override
  String get formsVocabParasiteCategoryPlural => 'categorias';

  @override
  String get formsVocabDetectionMethod => 'método de detecção';

  @override
  String get formsVocabDetectionMethodPlural => 'métodos de detecção';

  @override
  String get formsVocabPreparationMethod => 'método de preparação';

  @override
  String get formsVocabPreparationMethodPlural => 'métodos de preparação';

  @override
  String get formsVocabAnatomicalLocation => 'localização anatômica';

  @override
  String get formsVocabAnatomicalLocationPlural => 'localizações anatômicas';

  @override
  String get formsVocabStorageValue => 'valor de armazenamento';

  @override
  String get formsVocabStorageValuePlural => 'valores de armazenamento';

  @override
  String get formsNextId => 'Próximo ID';

  @override
  String get formsNextNumber => 'Próximo número';

  @override
  String get formsNumberedIdNoPreview =>
      'Defina um próximo número para numerar automaticamente · Os zeros à esquerda são mantidos';

  @override
  String formsNumberedIdPreview(String label, String preview) {
    return '$label: $preview · Os zeros à esquerda são mantidos';
  }

  @override
  String get formsBundledDocuments => 'Documentos';

  @override
  String get formsBundledTabularRecords => 'Registros tabulares';

  @override
  String get formsBundledTemplates => 'Modelos';

  @override
  String formsBundledAdded(String description) {
    return 'Adicionado · $description';
  }

  @override
  String get formsDescriptionOptional => 'Descrição (opcional)';

  @override
  String formsDescriptionTooLong(int max) {
    return 'Use $max caracteres ou menos.';
  }

  @override
  String get formsShowInfo => 'Mostrar informações';

  @override
  String get formsInfo => 'Informações';

  @override
  String formsDeleteConfirmPrompt(String text) {
    return 'Digite `$text` para habilitar a exclusão';
  }

  @override
  String get formsDeleteConfirmHint => 'Insira o texto de confirmação';

  @override
  String get formsSearchAll => 'Tudo';

  @override
  String get formsSearchFieldNumber => 'Número de campo';

  @override
  String get formsSearchCataloger => 'Catalogador';

  @override
  String get formsSearchPreparator => 'Preparador';

  @override
  String get formsSearchCollector => 'Coletor';

  @override
  String get formsSearchCondition => 'Condição';

  @override
  String get formsSearchPrepDate => 'Data de preparação';

  @override
  String get formsSearchPrepTime => 'Hora de preparação';

  @override
  String get formsSearchTaxa => 'Táxons';

  @override
  String get formsSearchPrepType => 'Tipo de preparação';

  @override
  String get formsSiteId => 'ID do local';

  @override
  String get formsSiteIdHint => 'Insira um local';

  @override
  String get formsSiteName => 'Nome do local';

  @override
  String get formsPresetDuplicate => 'Duplicar';

  @override
  String get formsPresetName => 'Nome da predefinição';

  @override
  String get formsPresetUpdateHelper =>
      'Selecione Atualizar para salvar o nome e a descrição';

  @override
  String get formsPresetUpdate => 'Atualizar';

  @override
  String formsCustomFieldLoadError(String error) {
    return 'Não foi possível carregar os campos personalizados: $error';
  }

  @override
  String get formsCustomFieldManage => 'Gerenciar campos personalizados';

  @override
  String get formsEnterNumber => 'Insira um número';

  @override
  String get formsCustomFieldUnset => 'Não definido';

  @override
  String formsCustomFieldArchivedOption(String label) {
    return '$label (arquivado)';
  }

  @override
  String sharedPresetCreateTooltip(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'template': 'Criar novo modelo',
      'customField': 'Criar novo campo personalizado',
      'other': 'Criar nova predefinição',
    });
    return '$_temp0';
  }

  @override
  String sharedPresetOptions(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'template': 'Opções do modelo',
      'customField': 'Opções do campo personalizado',
      'other': 'Opções da predefinição',
    });
    return '$_temp0';
  }

  @override
  String get sharedPresetCreateNew => 'Criar novo';

  @override
  String get sharedPresetScanQr => 'Ler QR';

  @override
  String sharedPresetExportSelected(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'template': 'Exportar este modelo',
      'customField': 'Exportar este campo personalizado',
      'other': 'Exportar esta predefinição',
    });
    return '$_temp0';
  }

  @override
  String sharedPresetExportAll(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'template': 'Exportar todos os modelos',
      'customField': 'Exportar todos os campos personalizados',
      'other': 'Exportar todas as predefinições',
    });
    return '$_temp0';
  }

  @override
  String get sharedLoadDefaults => 'Carregar padrões';

  @override
  String get sharedShowMore => 'Mostrar mais';

  @override
  String get sharedShowLess => 'Mostrar menos';

  @override
  String get sharedShare => 'Compartilhar';

  @override
  String get sharedUpdate => 'Atualizar';

  @override
  String get sharedAdd => 'Adicionar';

  @override
  String get sharedExportAs => 'Exportar como…';

  @override
  String get sharedFind => 'Localizar';

  @override
  String sharedDeleteSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Excluir $count itens',
      one: 'Excluir 1 item',
    );
    return '$_temp0';
  }

  @override
  String get sharedDeleteSelectedTitle => 'Excluir itens selecionados';

  @override
  String get sharedDeleteSelectedBody =>
      'Tem certeza de que deseja excluir os itens selecionados?';

  @override
  String get sharedTryAgain => 'Tentar novamente';

  @override
  String sharedExportTimeLeft(String duration) {
    return 'faltam cerca de $duration';
  }

  @override
  String get sharedExportCancelling => 'Cancelando…';

  @override
  String sharedExportFilesOfTotal(int completed, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total arquivos',
      one: '1 arquivo',
    );
    return '$completed de $_temp0';
  }

  @override
  String sharedExportFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count arquivos',
      one: '1 arquivo',
    );
    return '$_temp0';
  }

  @override
  String sharedExportBytesOfTotal(String processed, String total) {
    return '$processed de $total';
  }

  @override
  String sharedExportElapsed(String duration) {
    return '$duration decorridos';
  }

  @override
  String sharedExportUnitsOfTotal(int completed, int total) {
    return '$completed de $total';
  }

  @override
  String get sharedExportCancelledBody =>
      'Nenhum arquivo foi salvo. Nada foi alterado neste dispositivo.';

  @override
  String sharedExportStoppedAt(String step) {
    return 'Interrompido durante: $step';
  }

  @override
  String get sharedExportDidNotFinish => 'A exportação não terminou.';

  @override
  String get sharedExportCancelled => 'Exportação cancelada';

  @override
  String get sharedExportFailed => 'Falha na exportação';

  @override
  String get sharedExportComplete => 'Exportação concluída';

  @override
  String get sharedSaved => 'Salvo';

  @override
  String get sharedHideSaveLocation => 'Ocultar local de salvamento';

  @override
  String get sharedExportTemporaryNote =>
      'Compartilhe este arquivo agora para mantê-lo. O NAHPU o remove quando você exportar novamente.';

  @override
  String get sharedExportAppStorageNote =>
      'Salvo no armazenamento do app NAHPU. Escolha uma pasta da próxima vez para salvar diretamente nela.';

  @override
  String sharedExportFinishedIn(String duration) {
    return 'Concluído em $duration';
  }

  @override
  String sharedExportSizeIn(String size, String duration) {
    return '$size em $duration';
  }

  @override
  String get sharedOpenDirectory => 'Abrir diretório';

  @override
  String get sharedSaveToDevice => 'Salvar no dispositivo';

  @override
  String sharedSaveCopyTooLarge(String limit) {
    return 'Grande demais para salvar pelo app Arquivos, que tem limite de $limit. Escolha uma pasta antes de exportar para gravar arquivos desse tamanho diretamente no seu dispositivo.';
  }

  @override
  String get sharedQrExportImage => 'Exportar código QR como imagem';

  @override
  String get sharedQrImageTooLarge =>
      'Estes dados são grandes demais para uma imagem de código QR.';

  @override
  String get sharedLoadDefaultsDescription =>
      'Escolha as predefinições incluídas a adicionar. As predefinições que você já tem não são alteradas.';

  @override
  String get sharedLoadDefaultsNone =>
      'Não há predefinições padrão deste tipo.';

  @override
  String get sharedLoadDefaultsGenericTitle => 'Padrões';

  @override
  String get sharedLoadDefaultsGenericMessage =>
      'Predefinições adequadas a qualquer formato de catálogo.';

  @override
  String sharedLoadDefaultsForFormat(String format) {
    return 'Para $format';
  }

  @override
  String get sharedLoadDefaultsForFormatMessage =>
      'Predefinições opcionais criadas para este formato de catálogo.';

  @override
  String get sharedLoadDefaultsLayoutsNote =>
      'Os layouts trazem os modelos com que são impressos.';

  @override
  String get sharedLoadSelected => 'Carregar selecionados';

  @override
  String sharedLoadDefaultsLoadError(String error) {
    return 'Não foi possível carregar as predefinições incluídas: $error';
  }

  @override
  String sharedLoadDefaultsFailed(String error) {
    return 'Falha ao carregar as predefinições padrão: $error';
  }

  @override
  String get sharedIncludeLinkedTemplates => 'Incluir modelos vinculados';

  @override
  String sharedLinkedTemplateList(int count, String names) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modelos: $names',
      one: '1 modelo: $names',
    );
    return '$_temp0';
  }

  @override
  String sharedExportedTo(String path) {
    return 'Exportado para $path';
  }

  @override
  String sharedExportFailedError(String error) {
    return 'Falha na exportação: $error';
  }

  @override
  String get sharedExportProjectInfo => 'Exportar informações do projeto';

  @override
  String get sharedExportProjectInfoDescription =>
      'Exporte as informações deste projeto como JSON.';

  @override
  String get sharedSortOrder => 'Ordem';

  @override
  String get sharedSortAscending => 'Crescente';

  @override
  String get sharedSortDescending => 'Decrescente';

  @override
  String get sharedSortId => 'ID';

  @override
  String get sharedSortRecordOrder => 'Ordem dos registros';

  @override
  String get sharedSortSiteId => 'ID do local';

  @override
  String get sharedSortStateProvince => 'Estado/província';

  @override
  String get sharedSortPreciseLocality => 'Localidade precisa';

  @override
  String get sharedSortEventId => 'ID do evento';

  @override
  String get sharedSortStartDate => 'Data de início';

  @override
  String get sharedSortFieldId => 'ID de campo';

  @override
  String get sharedSortCataloger => 'Catalogador';

  @override
  String get sharedSortSpecies => 'Espécie';

  @override
  String get sharedSortDate => 'Data';

  @override
  String get sharedSortWriter => 'Autor';

  @override
  String sharedImportRecordType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'site': 'Importar local',
      'event': 'Importar evento',
      'other': 'Importar espécime',
    });
    return '$_temp0';
  }

  @override
  String sharedCreateNewRecordType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'site': 'Criar novo local',
      'event': 'Criar novo evento',
      'other': 'Criar novo espécime',
    });
    return '$_temp0';
  }

  @override
  String sharedUpdateExistingRecordType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'site': 'Atualizar um local existente',
      'event': 'Atualizar um evento existente',
      'other': 'Atualizar um espécime existente',
    });
    return '$_temp0';
  }

  @override
  String sharedExportRecordType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'site': 'Exportar local',
      'event': 'Exportar evento',
      'other': 'Exportar espécime',
    });
    return '$_temp0';
  }

  @override
  String sharedExportRecordJson(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'site': 'Exporte este registro de local como JSON.',
      'event': 'Exporte este registro de evento como JSON.',
      'other': 'Exporte este registro de espécime como JSON.',
    });
    return '$_temp0';
  }

  @override
  String sharedExportRecordMedia(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Este registro inclui $count arquivos de mídia vinculados, que serão incluídos no arquivo compactado.',
      one:
          'Este registro inclui 1 arquivo de mídia vinculado, que será incluído no arquivo compactado.',
    );
    return '$_temp0';
  }

  @override
  String sharedReusesSavedLocality(String locality) {
    return 'Reutiliza uma localidade salva: $locality';
  }

  @override
  String get sharedContinue => 'Continuar';

  @override
  String get sharedBack => 'Voltar';

  @override
  String get sharedChooseEventSite => 'Escolher local do evento';

  @override
  String get sharedChooseEventSiteDescription =>
      'Este evento inclui um local vinculado. Escolha um local existente ou crie o local incluído como um novo local.';

  @override
  String get sharedCreateEmbeddedSite => 'Criar local incluído';

  @override
  String get sharedCreateEmbeddedEvent => 'Criar evento incluído';

  @override
  String get sharedCreateEmbeddedTaxonomy => 'Criar taxonomia incluída';

  @override
  String get sharedChooseSpecimenEvent => 'Escolher evento do espécime';

  @override
  String get sharedChooseSpecimenTaxonomy => 'Escolher taxonomia do espécime';

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
      other: '$count pessoas',
      one: '1 pessoa',
    );
    return '$_temp0';
  }

  @override
  String sharedCollMethodCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count métodos de coleta',
      one: '1 método de coleta',
    );
    return '$_temp0';
  }

  @override
  String sharedPersonnelAssignmentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count atribuições de pessoal',
      one: '1 atribuição de pessoal',
    );
    return '$_temp0';
  }

  @override
  String get sharedEnvironmentalData => 'dados ambientais';

  @override
  String sharedMediaFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count arquivos de mídia',
      one: '1 arquivo de mídia',
    );
    return '$_temp0';
  }

  @override
  String get sharedNoAssociatedRecords => 'Nenhum registro associado';

  @override
  String sharedSiteLabel(String id) {
    return 'Local $id';
  }

  @override
  String sharedEventLabel(String id) {
    return 'Evento $id';
  }

  @override
  String sharedSpecimenLabel(String id) {
    return 'Espécime $id';
  }

  @override
  String sharedTaxonLabel(String id) {
    return 'Táxon $id';
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
      other: '$associatedCount registros associados',
      one: '1 registro associado',
    );
    String _temp2 = intl.Intl.pluralLogic(
      mediaCount,
      locale: localeName,
      other: '$mediaCount arquivos de mídia',
      one: '1 arquivo de mídia',
    );
    return 'Inclui $_temp0, $_temp1 e $_temp2.';
  }

  @override
  String get sharedSiteQrCode => 'Código QR do local';

  @override
  String get sharedEventQrCode => 'Código QR do evento';

  @override
  String get sharedSpecimenImported => 'Espécime importado com sucesso.';

  @override
  String get sharedSiteImported => 'Local importado com sucesso.';

  @override
  String get sharedEventImported => 'Evento importado com sucesso.';

  @override
  String get sharedQrNoData => 'O código QR não contém dados.';

  @override
  String get sharedRecordQrTooLargeBody =>
      'Este registro contém dados demais para um código QR. Exporte-o como JSON para transferir o registro completo.';

  @override
  String get sharedRecordQrDescription =>
      'Leia este código em outro dispositivo com o NAHPU para importar o registro.';

  @override
  String sharedRecordExchangeFailed(String error) {
    return 'Falha ao importar ou exportar o registro: $error';
  }

  @override
  String get sharedFileName => 'Nome do arquivo';

  @override
  String sharedSomethingWentWrong(String error) {
    return 'Algo deu errado: $error';
  }

  @override
  String get sharedSelectFile => 'Selecionar arquivo';

  @override
  String get sharedSupportedFormats => 'Formatos compatíveis';

  @override
  String sharedSupportedFormatsList(String label, String formats) {
    return '$label:\n$formats';
  }

  @override
  String get sharedAppendDate => 'Acrescentar a data atual';

  @override
  String get sharedAppendDateDescription =>
      'Adiciona -yyyy-mm-dd ao nome do arquivo';

  @override
  String get sharedSaveTo => 'Salvar em';

  @override
  String get sharedSelectDirectory => 'Selecionar diretório';

  @override
  String get sharedClearDirectory => 'Limpar diretório';

  @override
  String get sharedNoFolderChosen =>
      'Nenhuma pasta escolhida. A exportação vai para o armazenamento do app NAHPU — procure uma pasta para salvá-la onde preferir.';

  @override
  String get sharedShareAfterExport => 'Compartilhar após exportar';

  @override
  String get sharedTemporaryExportNote =>
      'O NAHPU mantém o arquivo só até a próxima exportação. Compartilhe-o para salvar uma cópia em Arquivos, enviá-lo a outro app ou colocá-lo em uma pasta na nuvem.';

  @override
  String get sharedEntireDatabaseContents =>
      'Conteúdo completo do banco de dados';

  @override
  String get sharedBackupSizeBeforeCompression =>
      'Tamanho do backup antes da compactação';

  @override
  String sharedWizardStepChip(int number, String label) {
    return '$number. $label';
  }

  @override
  String get sharedNavDashboard => 'Painel';

  @override
  String get sharedNavSites => 'Locais';

  @override
  String get sharedNavEvents => 'Eventos';

  @override
  String get sharedNavSpecimens => 'Espécimes';

  @override
  String get sharedNavNarrative => 'Narrativa';

  @override
  String get sharedNavCollapse => 'Recolher';

  @override
  String get sharedNavExpand => 'Expandir';

  @override
  String get sharedNavCollapseNavigation => 'Recolher navegação';

  @override
  String get sharedNavExpandNavigation => 'Expandir navegação';

  @override
  String get sharedNavCollapseRail => 'Recolher barra de navegação';

  @override
  String get sharedNavExpandRail => 'Expandir barra de navegação';

  @override
  String get sharedNavMenu => 'Menu';

  @override
  String get sharedNavCloseMenu => 'Fechar menu';

  @override
  String get sharedNavCloseProjectMenu => 'Fechar menu do projeto';

  @override
  String get sharedNavOpenProjectMenu => 'Abrir menu do projeto';

  @override
  String get sharedNavCloseProject => 'Fechar projeto';

  @override
  String get sharedGoToPage => 'Ir para a página';

  @override
  String get sharedGoToPageOrSearch => 'Ir para a página ou pesquisar';

  @override
  String sharedPageOf(int current, int total) {
    return 'Página $current de $total';
  }

  @override
  String get sharedSearch => 'Pesquisar';

  @override
  String get sharedPageNumber => 'Número da página';

  @override
  String get sharedGo => 'Ir';

  @override
  String get sharedOr => 'ou';

  @override
  String get sharedSearchRecords => 'Pesquisar registros';

  @override
  String sharedPageOutOfRange(int total) {
    return 'Digite uma página de 1 a $total';
  }

  @override
  String get textReplaceErrorEmptyPattern =>
      'O texto a localizar não pode estar vazio.';

  @override
  String textReplaceErrorInvalidRegex(String detail) {
    return 'Expressão regular inválida: $detail';
  }

  @override
  String get textReplaceAdd => 'Adicionar substituição';

  @override
  String get textReplaceTitle => 'Substituir texto';

  @override
  String get textReplaceSubtitle =>
      'Aplicadas em ordem após a formatação do valor.';

  @override
  String get textReplaceDialogTitle => 'Localizar e substituir';

  @override
  String get textReplaceMatch => 'Correspondência';

  @override
  String get textReplaceMatchExact => 'Exata';

  @override
  String get textReplaceMatchRegex => 'Regex';

  @override
  String get textReplaceFind => 'Localizar';

  @override
  String get textReplaceWith => 'Substituir por';

  @override
  String get textReplaceIgnoreCase => 'Ignorar maiúsculas';

  @override
  String get textReplaceMoveUp => 'Mover substituição para cima';

  @override
  String get textReplaceMoveDown => 'Mover substituição para baixo';

  @override
  String get textReplaceRemove => 'Remover substituição';

  @override
  String get textReplaceRegexHelp =>
      'Use \$0 para a correspondência completa, \$1…\$n para os grupos e \$\$ para \$.';

  @override
  String get documentFontSampleA =>
      'O durião é o rei das frutas, e o mangostão é a rainha. Ao que parece, nunca é uma boa ideia comê-los ao mesmo tempo. Eu definitivamente não deveria ter comido 12 duriões e uma dúzia de mangostões de uma só vez no campo.';

  @override
  String get documentFontSampleB =>
      'Só existe um lugar no norte de Sumatra onde orangotangos, rinocerontes, elefantes e tigres compartilham o mesmo hábitat natural. Adivinhe o nome do parque nacional?';

  @override
  String get documentFontSampleC =>
      'Sentindo-se criativo ou inspirado? Envie ao mantenedor suas ideias, um fato interessante sobre biodiversidade, uma piada de campo ou um conto que valha a pena ler, ou publique em github.com/nahpu/nahpu/issues, e ele pode aparecer bem aqui. A escolha de uma fonte não deveria ser decidida por uma raposa marrom que pula sobre um cão preguiçoso.';

  @override
  String get documentFontBold => 'Negrito';

  @override
  String get documentFontItalic => 'Itálico';

  @override
  String get fieldEditorLabel => 'Rótulo';

  @override
  String get fieldEditorType => 'Tipo';

  @override
  String get fieldEditorCatalogApplicability => 'Aplicabilidade do catálogo';

  @override
  String fieldEditorCurrentCatalogOnly(String catalog) {
    return 'Somente o catálogo atual ($catalog)';
  }

  @override
  String get fieldEditorOptions => 'Opções';

  @override
  String get fieldEditorOptionsHelper => 'Digite uma opção por linha.';

  @override
  String get fieldEditorMapToDwc => 'Mapear para Darwin Core';

  @override
  String fieldEditorDwcOfficialTerms(String version) {
    return 'Termos oficiais $version';
  }

  @override
  String get fieldEditorDwcTarget => 'Destino DWC';

  @override
  String get fieldEditorDwcMappingMode => 'Modo de mapeamento';

  @override
  String get fieldEditorDwcDirect => 'Campo direto';

  @override
  String get fieldEditorDwcAssertion => 'Medição / fato repetível';

  @override
  String get fieldEditorDwcField => 'Campo DWC';

  @override
  String get fieldEditorDwcAllowConflict =>
      'Entendo que haverá valores duplicados';

  @override
  String get fieldEditorDwcAllowConflictNote =>
      'Valores escalares conflitantes serão unidos com “ | ”.';

  @override
  String get fieldEditorEditTitle => 'Editar campo personalizado';

  @override
  String fieldEditorAddTitle(String section) {
    return 'Adicionar campo personalizado a $section';
  }

  @override
  String get documentFileSettings => 'Configurações do arquivo';

  @override
  String get documentFileFormat => 'Formato do arquivo';

  @override
  String get documentFileBundleFormat => 'Formato do pacote';

  @override
  String get documentFileDwcDpZipNote =>
      'ZIP é oferecido por compatibilidade. TAR.GZ é a opção DwC-DP orientada a padrões.';

  @override
  String get documentFileFormatCsv => 'Separado por vírgulas (.csv)';

  @override
  String get documentFileFormatTsv => 'Separado por tabulações (.tsv)';

  @override
  String get documentFileFormatExcel => 'Excel (.xlsx)';

  @override
  String get documentFileFormatJson => 'JSON (.json)';

  @override
  String documentPreviewPdfError(String error) {
    return 'Erro ao gerar o PDF:\n$error';
  }

  @override
  String get documentPreviewUnavailable => 'Nenhuma visualização disponível.';

  @override
  String get documentPreviewNotGenerated =>
      'A visualização ainda não foi gerada.';

  @override
  String get documentPreviewNoLayout => 'Nenhum layout carregado.';

  @override
  String get documentPreviewUpdate => 'Atualizar visualização';

  @override
  String get documentPreviewGenerate => 'Gerar visualização';

  @override
  String get documentPreviewOptionsChanged =>
      'As opções de visualização mudaram';

  @override
  String documentPreviewPageOf(int current, int total) {
    return 'Página $current de $total';
  }

  @override
  String get documentColumnsDefaults => 'Padrões';

  @override
  String documentColumnsSelectedCount(int selected, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$selected de $total colunas selecionadas',
      one: '$selected de 1 coluna selecionada',
    );
    return '$_temp0';
  }

  @override
  String get documentPartFilterTitle => 'Filtrar partes de espécimes';

  @override
  String get documentPartFilterNote =>
      'Os filtros mudam apenas a lista. As partes selecionadas continuam incluídas na exportação até que você altere a seleção.';

  @override
  String get documentPartFilterTypes => 'Tipos de parte';

  @override
  String get documentPartFilterTypesHint =>
      'Deixe todas desmarcadas para incluir todos os tipos.';

  @override
  String get documentPartFilterNumberRange => 'Intervalo de números';

  @override
  String get documentPartFilterFieldNumber => 'Número de campo';

  @override
  String get documentPartFilterProjectNumber => 'Número do projeto';

  @override
  String get documentPartFilterFrom => 'De';

  @override
  String get documentPartFilterTo => 'Até';

  @override
  String get documentPartFilterRangeHint =>
      'Inclui ambos os extremos. Deixe um dos extremos em branco para não ter limite.';

  @override
  String get documentPartFilterReset => 'Redefinir filtros';

  @override
  String get documentPartFilterInvalidNumber =>
      'Digite um número inteiro não negativo.';

  @override
  String get documentPartFilterFromAfterTo =>
      '“De” deve ser menor ou igual a “Até”.';

  @override
  String documentPartsLoadError(String error) {
    return 'Não foi possível carregar as partes: $error';
  }

  @override
  String get documentPartsSearch => 'Pesquisar partes ou números de espécimes';

  @override
  String get documentPartFilterActive => 'Filtrar partes de espécimes (ativo)';

  @override
  String documentPartsSummary(int shown, int total, int selected) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total partes',
      one: '1 parte',
    );
    return 'Exibindo $shown de $_temp0 · Selecionadas: $selected';
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
    return 'Exibindo $shown de $_temp0 · Selecionadas: $selected ($hidden ocultas)';
  }

  @override
  String get documentPartsEmpty => 'Nenhuma parte de espécime encontrada';

  @override
  String documentPartFallbackTitle(String id) {
    return 'Parte $id';
  }

  @override
  String documentParasitesLoadError(String error) {
    return 'Não foi possível carregar os parasitas: $error';
  }

  @override
  String get documentParasitesSearch =>
      'Pesquisar parasitas ou números de espécimes';

  @override
  String documentParasitesSummary(int shown, int total, int selected) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total parasitas',
      one: '1 parasita',
    );
    return 'Mostrando $shown de $_temp0 · Selecionados: $selected';
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
      other: '$total parasitas',
      one: '1 parasita',
    );
    return 'Mostrando $shown de $_temp0 · Selecionados: $selected ($hidden ocultos)';
  }

  @override
  String get documentParasitesEmpty => 'Nenhum parasita encontrado';

  @override
  String documentParasiteFallbackTitle(String id) {
    return 'Parasita $id';
  }

  @override
  String documentPartFieldNumber(String number) {
    return 'N.º de campo $number';
  }

  @override
  String documentPartProjectNumber(String number) {
    return 'N.º do projeto $number';
  }

  @override
  String documentPartCatalog(String number) {
    return 'Catálogo $number';
  }

  @override
  String documentPartSpecimenFallback(String uuid) {
    return 'Espécime $uuid';
  }

  @override
  String get documentSelectionClearAll => 'Limpar tudo';

  @override
  String get documentSpecimenSearch =>
      'Pesquisar n.º de campo, coletor, espécie...';

  @override
  String documentSpecimenCollectedRange(String start, String end) {
    return 'Coleta: $start - $end';
  }

  @override
  String get documentSpecimenCollectionDate => 'Data de coleta';

  @override
  String documentSpecimenPreparedRange(String start, String end) {
    return 'Prep.: $start - $end';
  }

  @override
  String get documentSpecimenPrepDate => 'Data de preparação';

  @override
  String documentSelectionSelectedOf(int selected, int total) {
    return 'Selecionados: $selected de $total';
  }

  @override
  String get documentSpecimenSelectTitle => 'Selecionar espécimes';

  @override
  String get documentSelectSitePreview => 'Selecionar local para visualização';

  @override
  String get documentSelectSitesPreview =>
      'Selecionar locais para visualização';

  @override
  String get documentSelectSites => 'Selecionar locais';

  @override
  String get documentSelectEventPreview =>
      'Selecionar evento para visualização';

  @override
  String get documentSelectEventsPreview =>
      'Selecionar eventos para visualização';

  @override
  String get documentSelectEvents => 'Selecionar eventos';

  @override
  String get documentSelectNarrativePreview =>
      'Selecionar narrativa para visualização';

  @override
  String get documentSelectNarrativesPreview =>
      'Selecionar narrativas para visualização';

  @override
  String get documentSelectNarratives => 'Selecionar narrativas';

  @override
  String get documentSiteSearch => 'Pesquisar ID do local, localidade...';

  @override
  String get documentSelectionClearSearch => 'Limpar pesquisa';

  @override
  String get documentSitesEmpty => 'Nenhum local encontrado';

  @override
  String get documentSiteUnnamed => 'Local sem nome';

  @override
  String get documentSiteNoLocality => 'Sem detalhes de localidade';

  @override
  String documentSelectionLoadError(String error) {
    return 'Erro: $error';
  }

  @override
  String get documentEventSearch => 'Pesquisar ID do evento, método...';

  @override
  String get documentEventsEmpty => 'Nenhum evento encontrado';

  @override
  String documentEventFallbackTitle(String id) {
    return 'ID do evento: $id';
  }

  @override
  String get documentEventNoMethod => 'Sem método';

  @override
  String get documentSelectionNoDate => 'Sem data';

  @override
  String get documentNarrativeSearch => 'Pesquisar data, conteúdo...';

  @override
  String get documentNarrativesEmpty => 'Nenhuma narrativa encontrada';

  @override
  String get documentNarrativeNoText => 'Sem texto';

  @override
  String get documentRecordsSpecimens => 'Espécimes';

  @override
  String get documentRecordsSites => 'Locais';

  @override
  String get documentRecordsEvents => 'Eventos de coleta';

  @override
  String get documentRecordsNarratives => 'Narrativas';

  @override
  String get documentRecordsGeneric => 'Registros';

  @override
  String documentSelectedCount(int selected, int total) {
    return '$selected de $total selecionados';
  }

  @override
  String get documentPageSizeLetter => 'Carta EUA (8,5 x 11 pol.)';

  @override
  String get documentPageSizeLegal => 'Ofício EUA';

  @override
  String get documentPageSizeCustom => 'Personalizado';

  @override
  String get documentOrientationPortrait => 'Retrato';

  @override
  String get documentOrientationLandscape => 'Paisagem';

  @override
  String get documentOverrideBlocks => 'Substituir os blocos do modelo';

  @override
  String get documentTemplateBlocks => 'Blocos do modelo';

  @override
  String get documentAddBlock => 'Adicionar bloco';

  @override
  String get documentMultiBlockMode => 'Modo de vários blocos';

  @override
  String get documentMultiBlockContinuous => 'Contínuo (bloco a bloco)';

  @override
  String get documentMultiBlockAlternate => 'Alternado (registro a registro)';

  @override
  String documentBlockNumber(int number) {
    return 'Bloco n.º $number';
  }

  @override
  String get documentShowLess => 'Mostrar menos';

  @override
  String get documentShowMore => 'Mostrar mais';

  @override
  String get documentDeleteBlock => 'Excluir bloco';

  @override
  String get documentBlockTemplate => 'Modelo';

  @override
  String get documentTemplateMissing => 'Este modelo não existe mais';

  @override
  String documentMissingItem(String name) {
    return 'Ausente: $name';
  }

  @override
  String get documentEditTemplate => 'Editar modelo';

  @override
  String get documentBlockCopies => 'Cópias';

  @override
  String get documentBlockRows => 'Linhas';

  @override
  String get documentBlockCols => 'Col.';

  @override
  String get documentAutoFillPage => 'Preencher página automaticamente';

  @override
  String get documentTemplatePadding => 'Margens do modelo (mm)';

  @override
  String get documentPaddingTop => 'Superior';

  @override
  String get documentPaddingLeft => 'Esquerda';

  @override
  String get documentPaddingRight => 'Direita';

  @override
  String get documentPaddingBottom => 'Inferior';

  @override
  String get documentPageBreakAfter => 'Quebra de página depois';

  @override
  String get documentPageBreakAfterHint =>
      'Inserir quebra de página depois deste bloco';

  @override
  String get documentCurrentProjectSelection => 'Seleção do projeto atual';

  @override
  String get documentActiveProjectDocument => '1 documento (projeto ativo)';

  @override
  String get documentSelectionSpecimens => 'Seleção de espécimes';

  @override
  String get documentSelectionSpecimenParts => 'Seleção de partes de espécimes';

  @override
  String get documentSelectionParasites => 'Seleção de parasitas';

  @override
  String get documentSelectionSites => 'Seleção de locais';

  @override
  String get documentSelectionEvents => 'Seleção de eventos de coleta';

  @override
  String get documentSelectionNarratives => 'Seleção de narrativas';

  @override
  String get documentSortDirection => 'Direção';

  @override
  String get documentSortAscending => 'Crescente';

  @override
  String get documentSortDescending => 'Decrescente';

  @override
  String get documentSortFieldsLoadError =>
      'Não foi possível carregar os campos de ordenação';

  @override
  String get documentSortOriginalOrder => 'Ordem original';

  @override
  String get documentSortOrderBy => 'Ordenar por';

  @override
  String get documentSortOrderRecordsBy => 'Ordenar registros por';

  @override
  String get documentSortClosePicker =>
      'Fechar o seletor de campo de ordenação';

  @override
  String documentSortFieldUnavailable(String table) {
    return '$table · Indisponível para este modelo';
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
  String get documentLayoutTitle => 'Layout do documento';

  @override
  String get documentLayoutProfile => 'Perfil de layout';

  @override
  String get documentLayoutProfileHelper =>
      'As configurações de página e os blocos do modelo são definidos pelo perfil.';

  @override
  String get documentManagePresets => 'Gerenciar predefinições';

  @override
  String get documentPageSetup => 'Configuração da página';

  @override
  String get documentPageSize => 'Tamanho da página';

  @override
  String get documentPageWidthMm => 'Largura (mm)';

  @override
  String get documentPageHeightMm => 'Altura (mm)';

  @override
  String get documentOrientation => 'Orientação';

  @override
  String get documentPagePadding => 'Margens da página (mm)';

  @override
  String get documentSelectSpecimenParts => 'Selecionar partes de espécimes';

  @override
  String get documentSelectParasites => 'Selecionar parasitas';

  @override
  String get labelCatalogFormatOrnithology => 'Ornitologia';

  @override
  String get labelCatalogFormatMammalogy => 'Mastozoologia';

  @override
  String get labelCatalogFormatHerpetology => 'Herpetologia';

  @override
  String get labelCatalogFormatInvertebrateZoology =>
      'Zoologia de invertebrados';

  @override
  String get labelCatalogFormatIchthyology => 'Ictiologia';

  @override
  String get labelSpecimenRecordTypeAllTaxa => 'Todos os táxons';

  @override
  String get labelSpecimenRecordTypeBirds => 'Aves';

  @override
  String get labelSpecimenRecordTypeMammals => 'Mamíferos';

  @override
  String get labelSpecimenRecordTypeHerpetofauna => 'Herpetofauna';

  @override
  String get labelSpecimenRecordTypeInvertebrates => 'Invertebrados';

  @override
  String get labelSpecimenRecordTypeFishes => 'Peixes';

  @override
  String get labelProjectToolCategoryUtilities => 'Utilitários';

  @override
  String get labelProjectToolCategoryProject => 'Projeto';

  @override
  String get labelProjectToolCategoryRecords => 'Registros';

  @override
  String get labelProjectToolCategoryDatabase => 'Banco de dados';

  @override
  String get labelProjectToolCategoryConfiguration => 'Configuração';

  @override
  String get labelProjectToolDataTable => 'Tabela de dados';

  @override
  String get labelProjectToolDataTableDescription =>
      'Navegue, ordene e pesquise os registros do projeto';

  @override
  String get labelProjectToolTemplates => 'Modelos';

  @override
  String get labelProjectToolTemplatesDescription =>
      'Crie e edite modelos de documentos';

  @override
  String get labelProjectToolMergeProject => 'Mesclar projeto';

  @override
  String get labelProjectToolMergeProjectDescription =>
      'Mescle outro projeto neste';

  @override
  String get labelProjectToolExportProject => 'Exportar projeto';

  @override
  String get labelProjectToolExportProjectDescription =>
      'Exporte este projeto para transferência';

  @override
  String get labelProjectToolBatchImport => 'Importação em lote';

  @override
  String get labelProjectToolBatchImportDescription =>
      'Importe ou atualize registros de uma planilha';

  @override
  String get labelProjectToolCuration => 'Curadoria';

  @override
  String get labelProjectToolCurationDescription =>
      'Curadoria de espécimes: escaneie tecidos em caixas de armazenamento';

  @override
  String get labelProjectToolBundleRecords => 'Empacotar registros';

  @override
  String get labelProjectToolBundleRecordsDescription =>
      'Empacote os registros com suas mídias';

  @override
  String get labelProjectToolExportRecords => 'Exportar registros';

  @override
  String get labelProjectToolExportRecordsDescription =>
      'Exporte registros como dados tabulares';

  @override
  String get labelProjectToolExportDocuments => 'Exportar documentos';

  @override
  String get labelProjectToolExportDocumentsDescription =>
      'Exporte registros como documentos';

  @override
  String get labelProjectToolBackupDatabaseDescription =>
      'Faça backup do banco de dados do aplicativo';

  @override
  String get labelProjectToolSettingsDescription =>
      'Abra as configurações do aplicativo';

  @override
  String get labelProjectToolExportConfigs => 'Exportar configurações';

  @override
  String get labelProjectToolImportConfigs => 'Importar configurações';

  @override
  String get labelBasemapNone => 'Nenhum';

  @override
  String get labelBasemapNoneDescription => 'Sem camada base geográfica';

  @override
  String get labelBasemapAutomatic => 'Automático';

  @override
  String get labelBasemapAutomaticDescription =>
      'Positron no modo claro e Escuro no modo escuro';

  @override
  String get labelBasemapNaturalEarthOffline => 'Natural Earth (offline)';

  @override
  String get labelBasemapNaturalEarthOfflineDescription =>
      'Limites de países incluídos que funcionam sem acesso à internet';

  @override
  String get labelBasemapPositronDescription =>
      'Mapa claro, minimalista e de baixo contraste';

  @override
  String get labelBasemapBrightDescription => 'Mapa detalhado com cores vivas';

  @override
  String get labelBasemapLibertyDescription =>
      'Mapa detalhado com cores equilibradas';

  @override
  String get labelBasemapDark => 'Escuro';

  @override
  String get labelBasemapDarkDescription =>
      'Mapa escuro para ambientes com pouca luz';

  @override
  String get labelMapLayerKindRasterTiles => 'Blocos raster';

  @override
  String get labelMapLayerKindVectorTiles => 'Blocos vetoriais';

  @override
  String get labelMapLayerKindElevationModel => 'Modelo de elevação';

  @override
  String get labelFieldSectionSpecimenAttributes => 'Atributos do espécime';

  @override
  String get labelFieldSectionSiteAttributes => 'Atributos do local';

  @override
  String get labelFieldSectionEnvironmentalData => 'Dados ambientais';

  @override
  String get labelFieldSectionSpecimenPart => 'Parte do espécime';

  @override
  String get labelFieldSectionParasite => 'Parasita';

  @override
  String get labelSiteGeographyCountry => 'País';

  @override
  String get labelSiteGeographyIslandGroup => 'Grupo de ilhas';

  @override
  String get labelSiteGeographyStateProvince => 'Estado/Província';

  @override
  String get labelSiteGeographyCounty => 'Condado/Paróquia/Distrito';

  @override
  String get labelSiteGeographyMunicipality => 'Município/Cidade/Vila';

  @override
  String get labelEnvironmentalLowestDayTemp => 'Temperatura mínima diurna';

  @override
  String get labelEnvironmentalHighestDayTemp => 'Temperatura máxima diurna';

  @override
  String get labelEnvironmentalLowestNightTemp => 'Temperatura mínima noturna';

  @override
  String get labelEnvironmentalHighestNightTemp => 'Temperatura máxima noturna';

  @override
  String get labelEnvironmentalAverageHumidity => 'Umidade média';

  @override
  String get labelEnvironmentalDewPoint => 'Ponto de orvalho';

  @override
  String get labelEnvironmentalCloudCover => 'Cobertura de nuvens';

  @override
  String get labelEnvironmentalRainfall => 'Precipitação';

  @override
  String get labelEnvironmentalAmbientTemperature => 'Temperatura ambiente';

  @override
  String get labelEnvironmentalAmbientHumidity => 'Umidade ambiente';

  @override
  String get labelEnvironmentalWaterTemperature => 'Temperatura da água';

  @override
  String get labelEnvironmentalDissolvedOxygen => 'Oxigênio dissolvido';

  @override
  String get labelEnvironmentalDissolvedOxygenSaturation =>
      'Saturação de oxigênio dissolvido';

  @override
  String get labelEnvironmentalConductivity => 'Condutividade';

  @override
  String get labelEnvironmentalFlowVelocity => 'Velocidade do fluxo';

  @override
  String get labelEnvironmentalSunrise => 'Nascer do sol';

  @override
  String get labelEnvironmentalSunset => 'Pôr do sol';

  @override
  String get labelEnvironmentalMoonPhase => 'Fase da lua';

  @override
  String get labelEnvironmentalNotes => 'Notas';

  @override
  String labelEnvironmentalWithUnit(String label, String unit) {
    return '$label ($unit)';
  }

  @override
  String get labelTableProject => 'Projeto';

  @override
  String get labelTableGeography => 'Geografia';

  @override
  String get labelTableSite => 'Local';

  @override
  String get labelTableSiteAttribute => 'Atributo do local';

  @override
  String get labelTableFossilSite => 'Local fóssil';

  @override
  String get labelTableCoordinate => 'Coordenada';

  @override
  String get labelTableCollEvent => 'Evento de coleta';

  @override
  String get labelTableEnvironment => 'Ambiente';

  @override
  String get labelTableCollPersonnel => 'Equipe de coleta';

  @override
  String get labelTableCollMethod => 'Método de coleta';

  @override
  String get labelTableNarrative => 'Narrativa';

  @override
  String get labelTableMedia => 'Mídia';

  @override
  String get labelTableNarrativeMedia => 'Mídia da narrativa';

  @override
  String get labelTableSiteMedia => 'Mídia do local';

  @override
  String get labelTableEventMedia => 'Mídia do evento';

  @override
  String get labelTableSpecimenMedia => 'Mídia do espécime';

  @override
  String get labelTableAssociatedData => 'Dados associados';

  @override
  String get labelTableSpecimenAssociatedData => 'Dados associados do espécime';

  @override
  String get labelTableSiteAssociatedData => 'Dados associados do local';

  @override
  String get labelTableEventAssociatedData => 'Dados associados do evento';

  @override
  String get labelTablePersonnelList => 'Lista da equipe';

  @override
  String get labelTablePersonnel => 'Equipe';

  @override
  String get labelTableTaxonomy => 'Taxonomia';

  @override
  String get labelTableSpecimen => 'Espécime';

  @override
  String get labelTableMammalAttribute => 'Atributo de mamífero';

  @override
  String get labelTableBirdAttribute => 'Atributo de ave';

  @override
  String get labelTableHerpAttribute => 'Atributo herpetológico';

  @override
  String get labelTableInvertebrateAttribute => 'Atributo de invertebrado';

  @override
  String get labelTableFishAttribute => 'Atributo de peixe';

  @override
  String get labelTableFossilAttribute => 'Atributo fóssil';

  @override
  String get labelTableParasiteDetection => 'Detecção de parasitas';

  @override
  String get labelTableParasite => 'Parasita';

  @override
  String get labelTableSpecimenPart => 'Parte do espécime';

  @override
  String get labelTableSpecimenIndividual => 'Indivíduo do espécime';

  @override
  String get labelTableSpecimenPartIndividual =>
      'Indivíduo da parte do espécime';

  @override
  String get labelTableParasiteIndividual => 'Indivíduo parasita';

  @override
  String get labelTableCustomFieldDefinition =>
      'Definição de campo personalizado';

  @override
  String get labelTableCustomFieldValue => 'Valor de campo personalizado';

  @override
  String fileExplorerFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count arquivos',
      one: '1 arquivo',
    );
    return '$_temp0';
  }

  @override
  String fileExplorerImageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count imagens',
      one: '1 imagem',
    );
    return '$_temp0';
  }

  @override
  String fileExplorerAudioCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count arquivos de áudio',
      one: '1 arquivo de áudio',
    );
    return '$_temp0';
  }

  @override
  String fileExplorerVideoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vídeos',
      one: '1 vídeo',
    );
    return '$_temp0';
  }

  @override
  String fileExplorerOtherCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count arquivos de outro tipo',
      one: '1 arquivo de outro tipo',
    );
    return '$_temp0';
  }

  @override
  String get fileExplorerLockDatabase => 'Banco de dados do aplicativo';

  @override
  String get fileExplorerLockDatabaseSidecar =>
      'Arquivo de trabalho do banco de dados';

  @override
  String get fileExplorerLockBackup => 'Backup do banco de dados';

  @override
  String get fileExplorerLockUserConfig =>
      'Fontes e camadas de mapa personalizadas';

  @override
  String get fileExplorerLockTemplateMedia => 'Mídia global de modelos';

  @override
  String get fileExplorerLockMediaRecord => 'Vinculado a um registro de mídia';

  @override
  String get fileExplorerLockPersonnelPhoto =>
      'Vinculado a uma foto de pessoal';

  @override
  String get fileExplorerLockAssociatedData => 'Vinculado a dados associados';

  @override
  String get fileExplorerLockUnresolvedReference =>
      'Um registro aponta para cá, mas não pôde ser lido';

  @override
  String get fileExplorerLockRecentlyModified =>
      'Alterado agora mesmo; talvez ainda esteja sendo copiado';

  @override
  String get fileExplorerLockUnmanagedLocation =>
      'Não está em uma pasta gerenciada pelo NAHPU';

  @override
  String get fileExplorerLockUnknownProject =>
      'Pasta de um projeto que não está no banco de dados';

  @override
  String fileExplorerPruneBlockedUnresolved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Não foi possível ler $count registros de dados associados, então alguns arquivos não podem ser verificados. A remoção de arquivos fica desativada até que isso seja resolvido.',
      one:
          'Não foi possível ler 1 registro de dados associados, então alguns arquivos não podem ser verificados. A remoção de arquivos fica desativada até que isso seja resolvido.',
    );
    return '$_temp0';
  }

  @override
  String get fileExplorerPruneBlockedEmptyIndex =>
      'O banco de dados não informa nenhum arquivo vinculado, o que normalmente significa que ainda está sendo aberto. Reabra esta tela antes de remover qualquer coisa.';

  @override
  String get progressPrepareBackup => 'Preparar backup';

  @override
  String get progressCopyMediaAndFiles => 'Copiar mídia e arquivos';

  @override
  String get progressCompressArchive => 'Compactar arquivo';

  @override
  String get progressExtractArchive => 'Extrair arquivo compactado';

  @override
  String get progressRestoreMediaAndFiles => 'Restaurar mídia e arquivos';

  @override
  String get progressBackUpCurrentData => 'Fazer backup dos dados atuais';

  @override
  String get progressReplaceDatabase => 'Substituir banco de dados';

  @override
  String get progressWriteRecords => 'Gravar registros';

  @override
  String get progressCopyMedia => 'Copiar mídia';

  @override
  String get progressCheckContents => 'Verificar conteúdo';

  @override
  String get progressCollectRecords => 'Reunir registros';

  @override
  String get progressCheckRecords => 'Verificar registros';

  @override
  String get progressWriteAndCompressPackage => 'Gravar e compactar pacote';

  @override
  String get progressProcessMedia => 'Processar mídia';

  @override
  String serviceMessagePresetsAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count predefinições adicionadas',
      one: '1 predefinição adicionada',
    );
    return '$_temp0';
  }

  @override
  String get serviceMessageNoDefaultPresets =>
      'Não há predefinições padrão deste tipo';

  @override
  String get serviceMessageDefaultPresetsLoaded =>
      'As predefinições padrão já estão carregadas';

  @override
  String serviceMessagePresetsAndTemplatesImported(
    int count,
    int templateCount,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count predefinições',
      one: '1 predefinição',
    );
    String _temp1 = intl.Intl.pluralLogic(
      templateCount,
      locale: localeName,
      other: '$templateCount modelos',
      one: '1 modelo',
    );
    return 'Importados: $_temp0 e $_temp1';
  }

  @override
  String serviceMessagePresetImageNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count modelos usam imagens, que são referenciadas pelo nome em vez de armazenadas no arquivo. Em outra instalação, essas imagens precisam ser adicionadas novamente.',
      one:
          '1 modelo usa imagens, que são referenciadas pelo nome em vez de armazenadas no arquivo. Em outra instalação, essas imagens precisam ser adicionadas novamente.',
    );
    return '$_temp0';
  }

  @override
  String deletePersonnelCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Excluir $count pessoas',
      one: 'Excluir 1 pessoa',
    );
    return '$_temp0';
  }

  @override
  String deletePersonnelTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Excluir pessoas',
      one: 'Excluir pessoa',
    );
    return '$_temp0';
  }

  @override
  String deletePersonnelBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tem certeza de que deseja excluir as pessoas selecionadas?',
      one: 'Tem certeza de que deseja excluir a pessoa selecionada?',
    );
    return '$_temp0';
  }

  @override
  String deleteTaxaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Excluir $count táxons',
      one: 'Excluir 1 táxon',
    );
    return '$_temp0';
  }

  @override
  String deleteTaxaTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Excluir táxons',
      one: 'Excluir táxon',
    );
    return '$_temp0';
  }

  @override
  String deleteTaxaBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tem certeza de que deseja excluir os táxons selecionados?',
      one: 'Tem certeza de que deseja excluir o táxon selecionado?',
    );
    return '$_temp0';
  }

  @override
  String deleteCoordinatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Excluir $count coordenadas',
      one: 'Excluir 1 coordenada',
    );
    return '$_temp0';
  }

  @override
  String deleteCoordinatesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Excluir coordenadas',
      one: 'Excluir coordenada',
    );
    return '$_temp0';
  }

  @override
  String deleteCoordinatesBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tem certeza de que deseja excluir as coordenadas selecionadas?',
      one: 'Tem certeza de que deseja excluir a coordenada selecionada?',
    );
    return '$_temp0';
  }

  @override
  String deleteCollMethodsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Excluir $count métodos de coleta',
      one: 'Excluir 1 método de coleta',
    );
    return '$_temp0';
  }

  @override
  String deleteCollMethodsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Excluir métodos de coleta',
      one: 'Excluir método de coleta',
    );
    return '$_temp0';
  }

  @override
  String deleteCollMethodsBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Tem certeza de que deseja excluir os métodos de coleta selecionados?',
      one: 'Tem certeza de que deseja excluir o método de coleta selecionado?',
    );
    return '$_temp0';
  }

  @override
  String deleteParasitesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Excluir $count parasitas',
      one: 'Excluir 1 parasita',
    );
    return '$_temp0';
  }

  @override
  String deleteParasitesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Excluir parasitas',
      one: 'Excluir parasita',
    );
    return '$_temp0';
  }

  @override
  String deleteParasitesBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tem certeza de que deseja excluir os parasitas selecionados?',
      one: 'Tem certeza de que deseja excluir o parasita selecionado?',
    );
    return '$_temp0';
  }

  @override
  String deleteSpecimenPartsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Excluir $count partes do espécimen',
      one: 'Excluir 1 parte do espécimen',
    );
    return '$_temp0';
  }

  @override
  String deleteSpecimenPartsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Excluir partes do espécimen',
      one: 'Excluir parte do espécimen',
    );
    return '$_temp0';
  }

  @override
  String deleteSpecimenPartsBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Tem certeza de que deseja excluir as partes do espécimen selecionadas?',
      one:
          'Tem certeza de que deseja excluir a parte do espécimen selecionada?',
    );
    return '$_temp0';
  }

  @override
  String deleteAssociatedDataCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Remover $count entradas de dados associados',
      one: 'Remover 1 entrada de dados associados',
    );
    return '$_temp0';
  }

  @override
  String get deleteAssociatedDataTitle => 'Remover dados associados';

  @override
  String get deleteAssociatedDataBody =>
      'Remover os dados associados selecionados deste registro? Os dados compartilhados com outros registros serão preservados.';

  @override
  String removeProjectPersonnelCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Remover $count pessoas do projeto',
      one: 'Remover 1 pessoa do projeto',
    );
    return '$_temp0';
  }

  @override
  String get removeProjectPersonnelTitle => 'Remover pessoal';

  @override
  String get removeProjectPersonnelBody =>
      'Tem certeza de que deseja remover do projeto as pessoas selecionadas?';

  @override
  String removeEventPersonnelCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Remover $count pessoas do evento',
      one: 'Remover 1 pessoa do evento',
    );
    return '$_temp0';
  }

  @override
  String get removeEventPersonnelTitle => 'Remover pessoal do evento';

  @override
  String get removeEventPersonnelBody =>
      'Tem certeza de que deseja remover deste evento as pessoas selecionadas?';

  @override
  String get projectDeleteProject => 'Excluir projeto';

  @override
  String get projectDeleteProjectTitle => 'Excluir projeto?';

  @override
  String get projectDeleteProjectPrompt =>
      'Você excluirá este projeto e os dados relacionados. Isso não pode ser desfeito.';

  @override
  String get projectNoProject => 'Nenhum projeto';

  @override
  String get projectOverview => 'Visão geral do projeto';

  @override
  String projectOverviewLoadError(Object error) {
    return 'Falha ao obter dados do banco de dados. Verifique se o nome do projeto existe. $error';
  }

  @override
  String projectSaveFailed(String error) {
    return 'Não foi possível salvar o projeto: $error';
  }

  @override
  String get projectDetails => 'Detalhes do projeto';

  @override
  String get projectNameLabel => 'Nome do projeto*';

  @override
  String get projectNameHint => 'Digite o nome do projeto (obrigatório)';

  @override
  String get projectDescriptionLabel => 'Descrição do projeto';

  @override
  String get projectDescriptionHint => 'Digite uma breve descrição do projeto';

  @override
  String get projectPrincipalInvestigator => 'Pesquisador principal';

  @override
  String get projectPrincipalInvestigatorHint =>
      'Digite o pesquisador principal';

  @override
  String get projectAccession => 'Tombo';

  @override
  String get projectAccessionHint => 'Digite um tombo institucional';

  @override
  String get projectPlaceAndTime => 'Local e horário';

  @override
  String get projectLocation => 'Localização';

  @override
  String get projectLocationHint => 'Digite a localização geral do projeto';

  @override
  String get projectTimeZoneNote =>
      'O NAHPU armazena datas e horários de coleta conforme inseridos no horário local de campo. O fuso horário do projeto registra esse contexto para que os dados trocados sejam interpretados de forma consistente por sistemas de gestão de coleções de terceiros e outras ferramentas.';

  @override
  String get projectDates => 'Datas do projeto';

  @override
  String get projectStartDate => 'Data de início';

  @override
  String get projectEndDate => 'Data de término';

  @override
  String get projectChooseDate => 'Escolha uma data';

  @override
  String projectClearField(String label) {
    return 'Limpar $label';
  }

  @override
  String get projectTimeZone => 'Fuso horário';

  @override
  String get projectChooseTimeZone => 'Escolha um fuso horário';

  @override
  String get projectTimeZoneUtc => '(UTC) Tempo Universal Coordenado';

  @override
  String get projectMainTaxonGroup => 'Grupo taxonômico principal';

  @override
  String get projectChooseTaxonGroup => 'Escolha um grupo taxonômico';

  @override
  String projectTaxonSettingLoadError(String error) {
    return 'Não foi possível carregar a configuração de táxon: $error';
  }

  @override
  String get projectIdentity => 'Identidade';

  @override
  String get projectDescription => 'Descrição';

  @override
  String get projectSchedule => 'Cronograma';

  @override
  String get projectRecordMetadata => 'Metadados do registro';

  @override
  String get projectCreated => 'Criado';

  @override
  String get projectLastAccessed => 'Último acesso';

  @override
  String get projectNotProvided => 'Não informado';

  @override
  String get projectUuid => 'UUID';

  @override
  String get projectQrTooltip => 'Código QR do projeto. Toque para ampliar.';

  @override
  String get projectEditTools => 'Editar lista';

  @override
  String get projectEditToolsTooltip => 'Escolha as ferramentas exibidas aqui';

  @override
  String get projectUtilities => 'Utilitários do projeto';

  @override
  String get projectDashboard => 'Painel do projeto';

  @override
  String get projectEditProject => 'Editar projeto';

  @override
  String get projectPersonnelRoleCataloger => 'Catalogador';

  @override
  String get projectPersonnelRoleDeterminer => 'Somente identificador';

  @override
  String get projectPersonnelRolePreparator => 'Somente preparador';

  @override
  String get projectPersonnelRoleNone => 'Nenhuma';

  @override
  String get projectPersonnelSelectExisting => 'Selecionar existente';

  @override
  String get projectPersonnelSelectFromDatabase =>
      'Selecionar do banco de dados';

  @override
  String get projectPersonnelAddNew => 'Adicionar nova';

  @override
  String get projectPersonnelAddNewPersonnel => 'Adicionar nova pessoa';

  @override
  String get projectPersonnelImageNotFound => 'Imagem não encontrada';

  @override
  String get projectPersonnelTakePhoto => 'Tirar foto';

  @override
  String get projectPersonnelSelectPhoto => 'Selecionar foto';

  @override
  String get projectPersonnelEdit => 'Editar pessoa';

  @override
  String get projectPersonnelManage => 'Gerenciar pessoal';

  @override
  String get projectPersonnelManageButton => 'Gerenciar';

  @override
  String get projectPersonnelNoneFound => 'Nenhuma pessoa encontrada.';

  @override
  String get projectPersonnelSelectToView =>
      'Selecione uma pessoa para ver os detalhes';

  @override
  String get projectPersonnelSearch => 'Pesquisar pessoal';

  @override
  String get projectPersonnelUnnamed => 'Pessoa sem nome';

  @override
  String get projectPersonnelAssigned =>
      'Esta pessoa está atribuída a um projeto';

  @override
  String projectPersonnelDeleted(int deleted) {
    String _temp0 = intl.Intl.pluralLogic(
      deleted,
      locale: localeName,
      other: '$deleted pessoas excluídas.',
      one: '1 pessoa excluída.',
    );
    return '$_temp0';
  }

  @override
  String projectPersonnelDeletedPartly(int deleted, int protected) {
    return '$deleted pessoas excluídas. $protected pessoas não puderam ser excluídas porque estão atribuídas a um projeto.';
  }

  @override
  String projectPersonnelNoMatch(String query) {
    return 'Nenhuma pessoa corresponde a “$query”.';
  }

  @override
  String projectSelectedCount(int count) {
    return '$count selecionados';
  }

  @override
  String get projectPersonnelAdded => 'Adicionada';

  @override
  String projectPersonnelAddCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Adicionar $count pessoas',
      one: 'Adicionar 1 pessoa',
    );
    return '$_temp0';
  }

  @override
  String projectPersonnelRemoveBlocked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count pessoas não puderam ser removidas porque são usadas por registros do projeto.',
      one:
          '1 pessoa não pôde ser removida porque é usada por registros do projeto.',
    );
    return '$_temp0';
  }

  @override
  String get projectPersonnelRole => 'Função';

  @override
  String get projectPersonnelRoleHint => 'Digite a função';

  @override
  String get projectPersonnelAffiliation => 'Afiliação';

  @override
  String get projectPersonnelAffiliationHint => 'Digite a afiliação';

  @override
  String get projectPersonnelOrcid => 'ORCID iD';

  @override
  String get projectPersonnelOrcidInvalid =>
      'Digite um ORCID iD válido com hífens';

  @override
  String get projectPersonnelCurrentFieldNumber => 'Número de campo atual';

  @override
  String get projectPersonnelInitials => 'Iniciais';

  @override
  String get projectPersonnelInitialsLabel => 'Iniciais*';

  @override
  String get projectPersonnelInitialsHint => 'ex.: HH ou H-H';

  @override
  String get projectPersonnelEmail => 'E-mail';

  @override
  String get projectPersonnelEmailHint => 'Digite o e-mail';

  @override
  String get projectPersonnelPhone => 'Telefone';

  @override
  String get projectPersonnelPhoneHint => 'Digite o telefone';

  @override
  String get projectPersonnelSpecimenCare => 'Cuidado de espécimes';

  @override
  String get projectPersonnelSpecimenCareRole =>
      'Função no cuidado de espécimes';

  @override
  String get projectPersonnelRegisterFieldNumber => 'Registrar número de campo';

  @override
  String get projectPersonnelRegisterPersonalFieldNumber =>
      'Registrar número de campo pessoal';

  @override
  String get projectPersonnelRegisterFieldNumberNote =>
      'As iniciais e o número do catalogador serão usados para gerar o ID de campo do espécime.';

  @override
  String get projectEnabled => 'Ativado';

  @override
  String get projectDisabled => 'Desativado';

  @override
  String get projectPersonnelProfile => 'Perfil';

  @override
  String get projectPersonnelContact => 'Contato';

  @override
  String get projectPersonnelNotes => 'Notas';

  @override
  String get projectPersonnelNotesHint => 'Escreva notas';

  @override
  String get projectPersonnelNameLabel => 'Nome*';

  @override
  String get projectPersonnelNameHint => 'Digite um nome (obrigatório)';

  @override
  String get projectPersonnelCatalogerNumberLabel => 'Número do catalogador*';

  @override
  String projectErrorDetail(String error) {
    return 'Erro: $error';
  }

  @override
  String get projectLoading => 'Carregando…';

  @override
  String get projectTaxonNew => 'Novo táxon';

  @override
  String get projectTaxonEdit => 'Editar táxon';

  @override
  String get projectTaxonAdd => 'Adicionar táxon';

  @override
  String get projectTaxonClassification => 'Classificação';

  @override
  String get projectTaxonRank => 'Categoria';

  @override
  String get projectTaxonRankLabel => 'Categoria taxonômica';

  @override
  String get projectTaxonRankHint =>
      'Selecione a categoria representada por este registro';

  @override
  String get projectTaxonRankRequired =>
      'Selecione uma categoria e digite seu nome.';

  @override
  String projectTaxonEnterValue(String field) {
    return 'Digite $field';
  }

  @override
  String get projectTaxonKingdom => 'Reino';

  @override
  String get projectTaxonPhylum => 'Filo';

  @override
  String get projectTaxonClass => 'Classe';

  @override
  String get projectTaxonOrder => 'Ordem';

  @override
  String get projectTaxonFamily => 'Família';

  @override
  String get projectTaxonGenus => 'Gênero';

  @override
  String get projectTaxonSpecies => 'Espécie';

  @override
  String get projectTaxonSubspecies => 'Subespécie';

  @override
  String get projectTaxonSpecificEpithet => 'Epíteto específico';

  @override
  String get projectTaxonSubspecificEpithet => 'Epíteto subespecífico';

  @override
  String get projectTaxonAdditionalDetails => 'Detalhes adicionais';

  @override
  String get projectTaxonAuthors => 'Autores';

  @override
  String get projectTaxonAuthorsHint => 'Digite os autores';

  @override
  String get projectTaxonCommonName => 'Nome comum';

  @override
  String get projectTaxonCommonNameHint => 'Digite um nome comum';

  @override
  String get projectTaxonRedListLabel => 'Categoria da Lista Vermelha da IUCN';

  @override
  String get projectTaxonRedListHint => 'ex.: Em perigo, Vulnerável etc.';

  @override
  String get projectTaxonRedListCategory => 'Categoria da Lista Vermelha';

  @override
  String get projectTaxonCitesStatus => 'Status CITES';

  @override
  String get projectTaxonCitesHint =>
      'ex.: Apêndice I, Apêndice II, Não CITES etc.';

  @override
  String get projectTaxonCountryStatusLabel => 'Status de conservação no país';

  @override
  String get projectTaxonCountryStatusHint => 'ex.: Protegida, comum etc.';

  @override
  String get projectTaxonCountryStatus => 'Status no país';

  @override
  String get projectTaxonSortingOrder => 'Ordem de classificação';

  @override
  String get projectTaxonSortingOrderHint => 'ex.: 1, 2, 3';

  @override
  String get projectTaxonNotesHint => 'Digite notas';

  @override
  String get projectTaxonAllFields => 'Todos os campos';

  @override
  String get projectTaxonConservation => 'Conservação';

  @override
  String get projectTaxonTotalRecords => 'Total de registros';

  @override
  String get projectTaxonCurrentProject => 'Projeto atual';

  @override
  String get projectTaxonAllProjects => 'Todos os projetos';

  @override
  String projectTaxonRecordTotalsError(String error) {
    return 'Não foi possível carregar os totais de registros: $error';
  }

  @override
  String get projectTaxonQrTooltip => 'Código QR do táxon. Toque para ampliar.';

  @override
  String get projectTaxonQrCode => 'Código QR do táxon';

  @override
  String get projectTaxonQrDescription =>
      'Leia este código no NAHPU para importar este táxon.';

  @override
  String get projectTaxonRegistry => 'Registro de táxons';

  @override
  String projectTaxonImported(int taxa, int families) {
    return '$taxa táxons importados em $families famílias.';
  }

  @override
  String get projectTaxonEmpty =>
      'Nenhum táxon encontrado.\nAdicione ou importe táxons para começar a registrar capturas.';

  @override
  String get projectTaxonMetricOrders => 'ordens';

  @override
  String get projectTaxonMetricFamilies => 'famílias';

  @override
  String get projectTaxonMetricSpecies => 'espécies registradas';

  @override
  String get projectTaxonMetricTaxa => 'táxons';

  @override
  String get projectTaxonSpecimenRecords => 'Registros de espécimes';

  @override
  String get projectTaxonSearchSpecimens => 'Pesquisar espécimes';

  @override
  String get projectTaxonNoSpecimens => 'Nenhum espécime encontrado';

  @override
  String projectTaxonSpecimensFound(int found, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total espécimes',
      one: '1 espécime',
    );
    String _temp1 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total espécimes',
      one: '1 espécime',
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
    return 'Contagem de espécimes: $count';
  }

  @override
  String get projectTaxonImportFromQr => 'Importar de QR';

  @override
  String get projectTaxonSingle => 'Táxon único';

  @override
  String get projectTaxonMultiple => 'Vários táxons';

  @override
  String get projectTaxonScanQr => 'Ler QR do táxon';

  @override
  String get projectTaxonScanMultiple => 'Ler vários táxons';

  @override
  String get projectCameraDenied =>
      'O acesso à câmera foi negado. Permita o acesso à câmera nas configurações do dispositivo e tente novamente.';

  @override
  String get projectTaxonCameraUnavailable =>
      'A leitura pela câmera não está disponível. Tente novamente ou importe um arquivo.';

  @override
  String get projectTaxonCameraError =>
      'Não foi possível usar a câmera. Tente novamente ou importe um arquivo.';

  @override
  String projectTaxonReadyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count táxons prontos',
      one: '1 táxon pronto',
    );
    return '$_temp0';
  }

  @override
  String get projectTaxonScanPrompt => 'Leia um código QR de táxon do NAHPU.';

  @override
  String get projectRetryCamera => 'Tentar a câmera novamente';

  @override
  String get projectTaxonManage => 'Gerenciar táxons';

  @override
  String get projectTaxonNoneFound => 'Nenhum táxon encontrado';

  @override
  String get projectTaxonSelectToView =>
      'Selecione um táxon para ver os detalhes';

  @override
  String projectTaxonSearchIn(String category) {
    return 'Pesquisar $category';
  }

  @override
  String projectTaxonSearchCategoryTooltip(String category) {
    return 'Categoria de pesquisa: $category';
  }

  @override
  String get projectTaxonSearchCategory => 'Categoria de pesquisa';

  @override
  String get projectTaxonInUse => 'O táxon está sendo usado por um espécime';

  @override
  String projectTaxonDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count táxons excluídos.',
      one: '1 táxon excluído.',
    );
    return '$_temp0';
  }

  @override
  String projectTaxonDeletedPartly(int deleted, int protected) {
    return '$deleted táxons excluídos. $protected táxons não puderam ser excluídos porque são usados por espécimes.';
  }

  @override
  String projectTaxonNoMatch(String query) {
    return 'Nenhum táxon corresponde a “$query”.';
  }

  @override
  String projectTaxonNoMatchIn(String query, String category) {
    return 'Nenhum táxon corresponde a “$query” em $category.';
  }

  @override
  String get projectTaxonManual => 'Manual';

  @override
  String get projectImportSetupTab => 'Configuração';

  @override
  String get projectTaxonQrSource => 'QR de táxon do NAHPU';

  @override
  String get projectMapColumns => 'Mapear colunas';

  @override
  String get projectParsingError => 'Erro de leitura';

  @override
  String get projectCheckColumns => 'Verifique as colunas';

  @override
  String get projectHideAdvancedOptions => 'Ocultar opções avançadas';

  @override
  String get projectAdvancedOptions => 'Opções avançadas';

  @override
  String get projectTaxonReview => 'Revisar táxons';

  @override
  String get projectTaxonPreviewEmpty =>
      'Selecione um arquivo ou leia um QR de táxon para pré-visualizar a importação.';

  @override
  String projectTaxonReviewSummary(int registered, int duplicates) {
    return '$registered já registrados · $duplicates duplicados';
  }

  @override
  String get projectTaxonAlreadyRegistered => 'Já registrado';

  @override
  String get projectTaxonDuplicate => 'Duplicado';

  @override
  String projectImportSelectedCount(int count) {
    return 'Importar $count selecionados';
  }

  @override
  String get projectTaxonSelectSharedClass =>
      'Selecione a classe comum a todas as linhas';

  @override
  String get projectTaxonClassForAllRows => 'Classe para todas as linhas';

  @override
  String projectTaxonKingdomPhylum(String kingdom, String phylum) {
    return 'Reino: $kingdom · Filo: $phylum';
  }

  @override
  String get projectParserExcel => 'Leitor de Excel';

  @override
  String get projectParserDelimited => 'Leitor de texto delimitado';

  @override
  String get projectDelimiterNotApplicable =>
      'Não se aplica (arquivo do Excel)';

  @override
  String get projectDelimiterTab => 'Tabulação (\"\\t\")';

  @override
  String get projectDelimiterComma => 'Vírgula (\",\")';

  @override
  String get projectDelimiterSemicolon => 'Ponto e vírgula (\";\")';

  @override
  String get projectDelimiterCustomRaw => 'Personalizado (texto bruto)';

  @override
  String get projectParsingDetails => 'Detalhes da leitura';

  @override
  String projectParserValue(String parser) {
    return 'Leitor: $parser';
  }

  @override
  String projectDelimiterValue(String delimiter) {
    return 'Delimitador: $delimiter';
  }

  @override
  String get projectCustomDelimiterRequired =>
      'Digite um delimitador personalizado para continuar.';

  @override
  String get projectParser => 'Leitor';

  @override
  String get projectParserAutoDetect => 'Detectar automaticamente';

  @override
  String get projectCustomDelimiter => 'Delimitador personalizado';

  @override
  String get projectCustomDelimiterHint =>
      'Digite o texto bruto (exemplo: | ou \\t)';

  @override
  String get projectRetryParse => 'Ler novamente';

  @override
  String get projectTaxonSupportedInputs => 'Entradas compatíveis:';

  @override
  String get projectTaxonSupportedFormats =>
      'CSV (.csv), TSV (.tsv), Excel (.xlsx), QR de táxon do NAHPU';

  @override
  String get projectReadingFile => 'Lendo arquivo…';

  @override
  String get projectQrUnavailable =>
      'A leitura de QR não está disponível nesta plataforma.';

  @override
  String get projectClearImport => 'Limpar importação';

  @override
  String get projectWizardWelcome => 'Boas-vindas';

  @override
  String get projectWizardMainTaxon => 'Táxon principal';

  @override
  String get projectWizardReview => 'Revisão';

  @override
  String get projectWizardCreateOnce =>
      'Crie uma vez para todos os dispositivos';

  @override
  String get projectWizardCreateOnceBody =>
      'Crie um novo projeto apenas no primeiro dispositivo. Use QR/Importar JSON para transferir as informações e a identidade do projeto.';

  @override
  String get projectWizardCreateNew => 'Criar novo projeto';

  @override
  String get projectScanQr => 'Ler QR do projeto';

  @override
  String get projectWizardMainTaxonBody =>
      'Escolha o táxon principal para ajustar os formulários de espécimes e os padrões do NAHPU neste dispositivo. Um projeto pode conter vários grupos taxonômicos, e você pode alterar o táxon principal depois em Configurações.';

  @override
  String get projectWizardFieldIdsTitle => 'Configurar IDs de campo';

  @override
  String projectWizardFieldIdsLoadError(String error) {
    return 'Não foi possível carregar as configurações de ID de campo: $error';
  }

  @override
  String get projectWizardFieldIdsBody =>
      'Escolha como os IDs de campo dos espécimes são gerados. Você pode alterar isso depois em Configurações > Catálogos > Espécimes.';

  @override
  String get projectWizardCatalogerRequired =>
      'É necessário um catalogador registrado';

  @override
  String get projectWizardCatalogerRequiredBody =>
      'Em seguida, escolha um catalogador elegível ou crie um com iniciais e um número de campo pessoal atual.';

  @override
  String projectWizardPrefixHint(String example) {
    return 'ex.: $example';
  }

  @override
  String get projectCurrentCatalogNumber => 'Número de catálogo atual';

  @override
  String get projectWizardNextNumberHint => 'Digite o próximo número';

  @override
  String get projectWizardCurrentNumberRequired => 'Digite um número atual';

  @override
  String get projectWizardAutoIncrementCatalog =>
      'Incrementar o número de catálogo automaticamente';

  @override
  String projectWizardPersonnelLoadError(String error) {
    return 'Não foi possível carregar o pessoal: $error';
  }

  @override
  String get projectWizardCreateCataloger => 'Criar um catalogador';

  @override
  String get projectWizardChooseCataloger => 'Escolher um catalogador';

  @override
  String get projectWizardNoCatalogerBody =>
      'Nenhum catalogador registrado está disponível. Crie um agora; a função e o registro do número de campo pessoal são preenchidos automaticamente.';

  @override
  String get projectWizardCreateAnotherCatalogerBody =>
      'Crie outro catalogador. A função e o registro do número de campo pessoal são preenchidos automaticamente.';

  @override
  String get projectWizardChooseCatalogerBody =>
      'Escolha o catalogador cujas iniciais e número de campo atual serão usados nos IDs de campo do pessoal.';

  @override
  String get projectWizardCatalogerLabel => 'Catalogador*';

  @override
  String get projectWizardCatalogerNameHint => 'Digite o nome do catalogador';

  @override
  String get projectWizardCurrentFieldNumberLabel => 'Número de campo atual*';

  @override
  String get projectWizardCurrentFieldNumberHint =>
      'Digite o próximo número de campo pessoal';

  @override
  String get projectWizardCatalogerRoleSet =>
      'Função no cuidado de espécimes: Catalogador';

  @override
  String get projectWizardFieldNumberEnabled =>
      'Registro do número de campo pessoal ativado';

  @override
  String get projectWizardReviewImported => 'Revisar projeto importado';

  @override
  String get projectWizardReviewProject => 'Revisar projeto';

  @override
  String get projectWizardImportNote =>
      'Esta transferência de informações do projeto preserva o UUID de origem. Registros, pessoal, táxons e configurações do dispositivo não estão incluídos.';

  @override
  String get projectName => 'Nome do projeto';

  @override
  String get projectFieldIdPrefix => 'Prefixo do ID de campo';

  @override
  String get projectFieldIdSuffix => 'Sufixo do ID de campo';

  @override
  String get projectWizardExistingCataloger =>
      'Catalogador existente selecionado';

  @override
  String get projectWizardNotConfigured => 'Não configurado';

  @override
  String get projectWizardDeviceSetup => 'Configuração do dispositivo';

  @override
  String get projectWizardKeepCurrent => 'Manter configuração atual';

  @override
  String get projectWizardFieldIdMode => 'Modo de ID de campo';

  @override
  String get projectWizardAutoIncrement => 'Incremento automático';

  @override
  String get projectOn => 'Ativado';

  @override
  String get projectOff => 'Desativado';

  @override
  String get projectWizardTaxonomyReadiness => 'Preparação da taxonomia';

  @override
  String get projectWizardTaxaCountUnavailable =>
      'A contagem de táxons disponíveis não está disponível.';

  @override
  String projectWizardAvailableTaxa(int count) {
    return 'Táxons disponíveis: $count';
  }

  @override
  String get projectWizardNoTaxa => 'Nenhum táxon disponível';

  @override
  String get projectWizardNoTaxaBody =>
      'Adicione ou importe táxons no Registro de táxons antes de criar um novo registro de espécime.';

  @override
  String get projectWizardSkip => 'Pular';

  @override
  String get projectWizardCreating => 'Criando…';

  @override
  String get projectWizardCatalogerNameRequired =>
      'O nome do catalogador é obrigatório';

  @override
  String get projectWizardNameTooShort => 'O nome é muito curto';

  @override
  String get projectWizardInvalidCharacters => 'Caracteres inválidos';

  @override
  String get projectWizardInitialsRequired => 'As iniciais são obrigatórias';

  @override
  String get projectWizardInitialsTooShort => 'As iniciais são muito curtas';

  @override
  String get projectWizardFieldNumberRequired =>
      'O número de campo atual é obrigatório';

  @override
  String get projectWizardInvalidFieldNumber => 'Número de campo inválido';

  @override
  String get projectInvalidQr => 'Código QR do projeto inválido.';

  @override
  String get projectNameRequired => 'O nome do projeto é obrigatório';

  @override
  String get projectNameTooShort => 'O nome do projeto é muito curto';

  @override
  String get projectNameTooLong => 'O nome do projeto é muito longo';

  @override
  String get projectNameInvalid => 'O nome do projeto é inválido';

  @override
  String get projectNameExists => 'Já existe um projeto com esse nome';

  @override
  String get projectUuidExists =>
      'Já existe um projeto com este UUID neste dispositivo.';

  @override
  String projectCreateFailed(String error) {
    return 'Não foi possível criar o projeto: $error';
  }

  @override
  String get projectWizardChooseExisting => 'Escolher existente';

  @override
  String get projectWizardCreateNewCataloger => 'Criar novo';

  @override
  String projectUuidValue(String uuid) {
    return 'UUID do projeto: $uuid';
  }

  @override
  String get projectImportInfoJson => 'Importar JSON de informações do projeto';

  @override
  String get projectTransferProjectInfo => 'Informações do projeto';

  @override
  String get projectTransferTaxonomy => 'Taxonomia';

  @override
  String get projectTransferSites => 'Locais';

  @override
  String get projectTransferEvents => 'Eventos';

  @override
  String get projectTransferSpecimens => 'Espécimes';

  @override
  String get projectTransferNarratives => 'Narrativas';

  @override
  String get projectTransferCustomFields => 'Campos personalizados';

  @override
  String get projectTransferMedia => 'Mídia';

  @override
  String get projectTransferKeepCurrent => 'Manter atual';

  @override
  String get projectTransferUseImported => 'Usar importado';

  @override
  String get projectTransferImportAsNew => 'Importar como novo';

  @override
  String get projectExporting => 'Exportando projeto';

  @override
  String get projectExportingHint =>
      'Projetos com muitas fotos podem levar vários minutos. Mantenha o NAHPU aberto até terminar.';

  @override
  String get projectExportAnother => 'Exportar outro';

  @override
  String get projectExportCancelTitle => 'Cancelar a exportação?';

  @override
  String get projectExportCancelBody =>
      'A exportação ainda está em andamento. Sair agora a cancela e nenhum arquivo será salvo.';

  @override
  String get projectExportKeepExporting => 'Continuar exportando';

  @override
  String get projectExportCancel => 'Cancelar exportação';

  @override
  String projectOpenFolderFailed(String error) {
    return 'Não foi possível abrir a pasta: $error';
  }

  @override
  String projectSaveCopyFailed(String error) {
    return 'Não foi possível salvar uma cópia: $error';
  }

  @override
  String get projectExportArchiveTitle => 'Arquivo de backup e transferência';

  @override
  String get projectExportArchiveBody =>
      'Use este arquivo como backup do projeto ou para transferi-lo a outro dispositivo e mesclá-lo lá.';

  @override
  String get projectExportLight => 'Exportação leve';

  @override
  String get projectExportLightBody =>
      'Exporte o projeto sem arquivos de mídia para envios com internet limitada. Use TAR.GZ ou ZIP para um backup completo do projeto.';

  @override
  String get projectExportArchiveContents => 'Conteúdo do arquivo';

  @override
  String get projectExportExcluded => 'Excluída';

  @override
  String get projectExportMediaSize => 'Tamanho da mídia';

  @override
  String projectWarningCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count avisos',
      one: '1 aviso',
    );
    return '$_temp0';
  }

  @override
  String get projectTransferFileAndSafety => 'Arquivo e segurança';

  @override
  String get projectTransferReviewImport => 'Revisar e importar';

  @override
  String get projectTransferReviewMerge => 'Revisar e mesclar';

  @override
  String get projectTransferResult => 'Resultado';

  @override
  String get projectTransferChooseFirst =>
      'Escolha primeiro uma transferência de projeto';

  @override
  String get projectTransferChooseFirstBody =>
      'Volte para Arquivo e segurança para selecionar um arquivo.';

  @override
  String get projectTransferChooseTitle =>
      'Escolha uma transferência de projeto do NAHPU';

  @override
  String get projectTransferChooseBody =>
      'As transferências de projeto podem ser JSON.GZ, ZIP ou TAR.GZ. JSON.GZ contém apenas registros. ZIP e TAR.GZ incluem mídia.';

  @override
  String get projectTransferReadingArchive => 'Lendo arquivo';

  @override
  String get projectTransferReadingArchiveHint =>
      'Transferências com mídia podem levar vários minutos para serem descompactadas. Mantenha o NAHPU aberto.';

  @override
  String get projectTransferChooseArchive => 'Escolher arquivo';

  @override
  String get projectTransferChooseAnotherArchive => 'Escolher outro arquivo';

  @override
  String get projectTransferBackupBeforeImport =>
      'Faça backup antes de importar';

  @override
  String get projectTransferBackupBeforeMerge => 'Faça backup antes de mesclar';

  @override
  String get projectTransferBackupBody =>
      'Um backup do banco de dados oferece um ponto de recuperação caso as alterações importadas não sejam as esperadas.';

  @override
  String get projectTransferBackupNow => 'Fazer backup agora';

  @override
  String get projectTransferBackupAckImport =>
      'Entendo que devo manter um backup antes de importar.';

  @override
  String get projectTransferBackupAckMerge =>
      'Entendo que devo manter um backup antes de mesclar.';

  @override
  String get projectTransferNewIdentity => 'Nova identidade do projeto';

  @override
  String projectTransferArchiveUuid(String uuid) {
    return 'UUID do arquivo: $uuid';
  }

  @override
  String get projectTransferDestinationName => 'Nome do projeto de destino';

  @override
  String get projectTransferDestinationNameHelper =>
      'Dá nome ao novo projeto neste dispositivo. O arquivo não é alterado.';

  @override
  String projectTransferNameConflict(String name) {
    return 'Já existe um projeto chamado “$name”. Escolha outro nome. Se forem cópias do mesmo projeto, cancele e use Mesclar projeto.';
  }

  @override
  String get projectTransferAlreadyExists => 'Este projeto já existe';

  @override
  String get projectTransferAlreadyExistsBody =>
      'UUIDs iguais identificam o mesmo projeto. A importação está bloqueada. Mescle este arquivo ao projeto existente.';

  @override
  String get projectTransferOpenMerge => 'Abrir Mesclar projeto';

  @override
  String get projectTransferUuidMismatch => 'O UUID do projeto não corresponde';

  @override
  String projectTransferUuidMismatchBody(String archive, String active) {
    return 'Arquivo: $archive\nProjeto ativo: $active';
  }

  @override
  String get projectTransferForceMerge => 'Forçar mesclagem no projeto ativo';

  @override
  String get projectTransferForceMergeBody =>
      'Os registros importados do projeto usarão o UUID do projeto ativo. Os conflitos ainda exigirão as escolhas mostradas depois.';

  @override
  String projectTransferTypeToConfirm(String name) {
    return 'Digite “$name” para confirmar';
  }

  @override
  String get projectCatalogNumberPrefix => 'Prefixo do número de catálogo';

  @override
  String get projectCatalogNumberSuffix => 'Sufixo do número de catálogo';

  @override
  String get projectTransferProjectInfoBody =>
      'Os valores atuais são mantidos por padrão. Selecione valores importados individuais quando quiser substituí-los.';

  @override
  String get projectTransferKeepAllCurrent => 'Manter todos os atuais';

  @override
  String get projectTransferUseAllImported => 'Usar todos os importados';

  @override
  String get projectTransferReviewMatches =>
      'Revise as correspondências antes de continuar. “Manter atual” vincula as dependências importadas ao registro existente sem substituí-lo.';

  @override
  String get projectTransferBulkTooltip =>
      'Aplicar uma escolha a todos os registros correspondentes';

  @override
  String projectTransferActionForAll(String action) {
    return '$action para todos';
  }

  @override
  String get projectTransferBulkAction => 'Ação em lote';

  @override
  String get projectTransferStatusNew => 'Novos';

  @override
  String get projectTransferStatusMatched => 'Correspondentes';

  @override
  String get projectTransferNeedsAttention => 'Requer atenção';

  @override
  String get projectTransferSkipped => 'Ignorados';

  @override
  String get projectTransferNoConflicts => 'Nenhum conflito';

  @override
  String get projectTransferNoConflictsBody =>
      'Todos os registros desta seção podem ser importados como novos.';

  @override
  String get projectTransferReviewBody =>
      'Nada foi gravado ainda. As alterações no banco de dados serão confirmadas juntas; uma falha desfaz todas.';

  @override
  String get projectTransferSourceProject => 'Projeto de origem';

  @override
  String get projectTransferDestination => 'Destino';

  @override
  String get projectTransferUuidHandling => 'Tratamento do UUID';

  @override
  String projectTransferNewUuid(String uuid) {
    return 'Novo UUID do projeto: $uuid';
  }

  @override
  String get projectTransferForceMergeUuid => 'Forçar mesclagem no UUID ativo';

  @override
  String get projectTransferMatchingUuid => 'UUID do projeto correspondente';

  @override
  String get projectTransferConflicts => 'Conflitos';

  @override
  String get projectTransferMediaFiles => 'Arquivos de mídia';

  @override
  String get projectTransferResolveConflicts =>
      'Resolva os conflitos antes de mesclar';

  @override
  String projectTransferDuplicateIdentifiers(String sections) {
    return 'Identificadores duplicados ainda precisam de uma ação em $sections.';
  }

  @override
  String get projectTransferArchiveWarnings => 'Avisos do arquivo';

  @override
  String get projectTransferImportUnfinished => 'A importação não terminou';

  @override
  String get projectTransferMergeUnfinished => 'A mesclagem não terminou';

  @override
  String get projectTransferImportRetry =>
      'Volte para Revisar e importar e tente novamente.';

  @override
  String get projectTransferMergeRetry =>
      'Volte para Revisar e mesclar e tente novamente.';

  @override
  String get projectTransferImported => 'Projeto importado';

  @override
  String get projectTransferMerged => 'Dados do projeto mesclados';

  @override
  String get projectTransferCountImported => 'Importados';

  @override
  String get projectTransferCountMerged => 'Mesclados';

  @override
  String get projectTransferCountUpdated => 'Atualizados';

  @override
  String get projectTransferSkippedOnConflict => 'Ignorados por conflito';

  @override
  String get projectTransferMediaCopied => 'Mídia copiada';

  @override
  String get projectTransferWarnings => 'Avisos';

  @override
  String get projectTransferConflict => 'Conflito';

  @override
  String get projectTransferCurrent => 'Atual';

  @override
  String get projectTransferConflictAction => 'Ação para o conflito';

  @override
  String get projectTransferChooseAction => 'Escolha uma ação';

  @override
  String get projectTransferChooseActionToContinue =>
      'Escolha uma ação para continuar';

  @override
  String get projectTransferNotSet => 'Não definido';

  @override
  String get projectTransferNoDetails => 'Sem detalhes';

  @override
  String get projectBatchSpecimenParts => 'Partes de espécimes';

  @override
  String get projectBatchParasites => 'Parasitas';

  @override
  String get projectBatchNarrative => 'Narrativa';

  @override
  String get projectBatchModeUpdate => 'Atualizar registros existentes';

  @override
  String get projectBatchModeCreate => 'Importar novos registros';

  @override
  String get projectBatchHeaderAuto => 'Automático';

  @override
  String get projectBatchDarwinCore => 'Darwin Core';

  @override
  String get projectBatchHeaderNames => 'Nomes das colunas';

  @override
  String get projectBatchKeySpecimenUuid => 'UUID do espécime';

  @override
  String get projectBatchKeyCatalogNumber => 'Número de catálogo';

  @override
  String get projectBatchKeyCatalogerFieldNumber =>
      'Catalogador e número de campo';

  @override
  String get projectBatchKeyTissueId => 'ID do tecido';

  @override
  String get projectBatchKeyBarcodeId => 'ID do código de barras';

  @override
  String get projectBatchKeyParasiteId => 'ID do parasita';

  @override
  String get projectBatchKeyParasiteUuid => 'UUID do parasita';

  @override
  String get projectBatchKeySiteId => 'ID do local';

  @override
  String get projectBatchKeyEventId => 'ID do evento';

  @override
  String get projectBatchKeyNarrativeDate => 'Data da narrativa';

  @override
  String get projectBatchStatusReady => 'Pronto';

  @override
  String get projectBatchStatusMissingLink => 'Vínculo ausente';

  @override
  String get projectBatchStatusNoMatch => 'Sem correspondência';

  @override
  String get projectBatchStatusAmbiguous => 'Várias correspondências';

  @override
  String get projectBatchStatusExists => 'Já está no projeto';

  @override
  String get projectBatchStatusDuplicateInFile => 'Repetido no arquivo';

  @override
  String get projectBatchStatusInvalid => 'Valores inválidos';

  @override
  String get projectBatchUpdateRecords => 'Atualizar registros';

  @override
  String get projectBatchImportRecords => 'Importar registros';

  @override
  String get projectBatchStepMode => 'Modo';

  @override
  String get projectBatchStepFile => 'Arquivo';

  @override
  String get projectBatchStepColumns => 'Colunas';

  @override
  String get projectBatchStepGroups => 'Grupos';

  @override
  String get projectBatchUnsupportedFile =>
      'Escolha um arquivo CSV, TSV ou Excel.';

  @override
  String get projectBatchModeTitle => 'O que você deseja fazer?';

  @override
  String get projectBatchModeBody =>
      'Traga registros de um arquivo CSV, TSV ou Excel. As colunas podem usar termos Darwin Core ou nomes próprios.';

  @override
  String get projectBatchModeCreateBody =>
      'Adicione um registro por linha. Táxons, pessoal, locais e eventos são vinculados quando já estão no projeto.';

  @override
  String get projectBatchModeUpdateBody =>
      'Associe cada linha a um registro por uma coluna-chave, como o número de catálogo, e grave as demais colunas. Células vazias não são alteradas.';

  @override
  String get projectBatchRecords => 'Registros';

  @override
  String get projectBatchLinkedRecords => 'Registros vinculados';

  @override
  String get projectBatchLinkedRecordsBody =>
      'Cada linha pode descrever um local, seu evento de coleta, um espécime e uma parte. As linhas são agrupadas em locais e eventos, que você pode conferir antes de importar.';

  @override
  String get projectBatchChooseFile => 'Escolha um arquivo';

  @override
  String get projectBatchChooseFileBody =>
      'A primeira linha deve conter os nomes das colunas. Cada linha seguinte é um registro.';

  @override
  String get projectBatchSheet => 'Planilha';

  @override
  String projectBatchTableSize(int rows, int columns) {
    String _temp0 = intl.Intl.pluralLogic(
      rows,
      locale: localeName,
      other: '$rows linhas',
      one: '1 linha',
    );
    String _temp1 = intl.Intl.pluralLogic(
      columns,
      locale: localeName,
      other: '$columns colunas',
      one: '1 coluna',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get projectBatchMatchColumns => 'Associar colunas';

  @override
  String projectBatchMatchColumnsBody(int mapped, int total) {
    return '$mapped de $total colunas correspondem a um campo. Altere qualquer correspondência ou ignore uma coluna. Suas alterações são lembradas para arquivos com as mesmas colunas.';
  }

  @override
  String get projectBatchKeyColumn => 'Coluna-chave';

  @override
  String projectBatchKeyColumnMissing(String keys) {
    return 'Associe uma coluna a um destes: $keys.';
  }

  @override
  String get projectBatchKeyColumnBody =>
      'As linhas atualizam o registro com o mesmo valor.';

  @override
  String get projectBatchMatchRecordsBy => 'Associar registros por';

  @override
  String get projectBatchNoValues => 'Sem valores';

  @override
  String get projectBatchNahpuField => 'Campo do NAHPU';

  @override
  String get projectBatchSkipColumn => 'Ignorar coluna';

  @override
  String projectBatchFieldInUse(String field) {
    return '$field (em uso)';
  }

  @override
  String get projectBatchNameMatch => 'Nome correspondente';

  @override
  String projectBatchCloseMatch(int percent) {
    return 'Correspondência próxima $percent%';
  }

  @override
  String get projectBatchSkippedByYou => 'Ignorada por você';

  @override
  String get projectBatchYourChoice => 'Sua escolha';

  @override
  String get projectBatchSearch => 'Pesquisar';

  @override
  String projectBatchLoadRecordsFailed(String error) {
    return 'Não foi possível carregar os registros: $error';
  }

  @override
  String get projectBatchNoMatchingRecords => 'Nenhum registro correspondente.';

  @override
  String get projectBatchNoOtherGroup => 'Não há outro grupo para mesclar.';

  @override
  String get projectBatchMoveToNewGroup => 'Mover para novo grupo';

  @override
  String get projectBatchCheckGroups => 'Conferir grupos';

  @override
  String get projectBatchCheckGroupsBody =>
      'As linhas que descrevem o mesmo local ou evento são agrupadas. Vincule um grupo a um registro do projeto, mescle grupos que sejam o mesmo lugar ou visita, ou separe linhas.';

  @override
  String projectBatchSitesCount(int count) {
    return 'Locais ($count)';
  }

  @override
  String projectBatchEventsCount(int count) {
    return 'Eventos ($count)';
  }

  @override
  String projectBatchSpecimensCount(int count) {
    return 'Espécimes ($count)';
  }

  @override
  String get projectBatchNoSiteColumns => 'Nenhuma coluna descreve um local.';

  @override
  String get projectBatchNoEventColumns => 'Nenhuma coluna descreve um evento.';

  @override
  String get projectBatchNoSpecimenColumns =>
      'Nenhuma coluna descreve um espécime.';

  @override
  String get projectBatchNewSite => 'Novo local';

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
      other: '$count espécimes',
      one: '1 espécime',
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
      other: '$count parasitas',
      one: '1 parasita',
    );
    return '$_temp0';
  }

  @override
  String get projectBatchSetSiteId => 'Definir ID do local';

  @override
  String get projectBatchLinkSite => 'Vincular a um local existente';

  @override
  String get projectBatchMergeIntoSite => 'Mesclar no local';

  @override
  String get projectBatchMoveRowsToSite => 'Mover linhas para um novo local';

  @override
  String projectBatchRow(String row) {
    return 'Linha $row';
  }

  @override
  String projectBatchRows(String rows) {
    return 'Linhas $rows';
  }

  @override
  String projectBatchRowsMore(int count, String rows) {
    return 'Linhas $rows e mais $count';
  }

  @override
  String get projectBatchNoSite => 'Sem local';

  @override
  String get projectBatchNoEvent => 'Sem evento';

  @override
  String projectBatchEventLabel(String event) {
    return 'Evento: $event';
  }

  @override
  String get projectBatchSetIdSuffix => 'Definir sufixo do ID';

  @override
  String get projectBatchLinkEvent => 'Vincular a um evento existente';

  @override
  String get projectBatchSetEventIdSuffix => 'Definir sufixo do ID do evento';

  @override
  String get projectBatchMergeIntoEvent => 'Mesclar no evento';

  @override
  String get projectBatchMoveRowsToEvent => 'Mover linhas para um novo evento';

  @override
  String get projectBatchExcluded => 'Excluído';

  @override
  String get projectBatchCheck => 'Verificar';

  @override
  String get projectBatchLinksToExisting => 'Vincula a existente';

  @override
  String get projectBatchChangeGroup => 'Alterar grupo';

  @override
  String get projectBatchLinkExisting => 'Vincular a existente…';

  @override
  String get projectBatchCreateNew => 'Criar novo';

  @override
  String get projectBatchMergeInto => 'Mesclar em…';

  @override
  String get projectBatchSplitRows => 'Separar linhas…';

  @override
  String get projectBatchLinkedReviewBody =>
      'Os locais são gravados primeiro, depois os eventos neles, e então os espécimes e suas partes.';

  @override
  String projectBatchSitesSummary(int created, int linked) {
    return 'Locais: $created novos, $linked vinculados';
  }

  @override
  String projectBatchEventsSummary(int created, int linked) {
    return 'Eventos: $created novos, $linked vinculados';
  }

  @override
  String projectBatchSpecimensSummary(int count) {
    return 'Espécimes: $count';
  }

  @override
  String projectBatchPartsSummary(int count) {
    return 'Partes: $count';
  }

  @override
  String projectBatchParasitesSummary(int count) {
    return 'Parasitas: $count';
  }

  @override
  String projectBatchRowsSkipped(int count) {
    return 'Linhas ignoradas: $count';
  }

  @override
  String get projectBatchImportSpecimensMissingLinks =>
      'Importar espécimes com vínculos ausentes';

  @override
  String get projectBatchImportSpecimensMissingLinksBody =>
      'O táxon ou a pessoa fica vazio. Adicione-o ao projeto primeiro para vinculá-lo.';

  @override
  String projectBatchWritingRecords(int done, int total) {
    return 'Gravando $done de $total registros';
  }

  @override
  String projectBatchWritingRows(int done, int total) {
    return 'Gravando $done de $total linhas';
  }

  @override
  String get projectBatchNoProblems => 'Nenhum problema encontrado.';

  @override
  String projectBatchMoreRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'E mais $count linhas.',
      one: 'E mais 1 linha.',
    );
    return '$_temp0';
  }

  @override
  String projectBatchSiteProblem(String site, String message) {
    return 'Local $site: $message';
  }

  @override
  String projectBatchSpecimenSkipped(String status) {
    return 'Espécime ignorado: $status.';
  }

  @override
  String get projectBatchExcludedRow => 'Excluída.';

  @override
  String get projectBatchDoneWithErrors => 'Concluído, com erros';

  @override
  String projectBatchAddedSpecimensParts(int specimens, int parts) {
    String _temp0 = intl.Intl.pluralLogic(
      specimens,
      locale: localeName,
      other: '$specimens espécimes adicionados',
      one: '1 espécime adicionado',
    );
    String _temp1 = intl.Intl.pluralLogic(
      parts,
      locale: localeName,
      other: '$parts partes',
      one: '1 parte',
    );
    return '$_temp0 e $_temp1.';
  }

  @override
  String projectBatchRowsWithErrors(int count) {
    return 'Linhas com erros: $count';
  }

  @override
  String get projectBatchOpenSpecimenTable =>
      'Abrir tabela de registros de espécimes';

  @override
  String projectBatchUpdatedRecords(int count, String records) {
    return '$count $records atualizados.';
  }

  @override
  String projectBatchAddedRecords(int count, String records) {
    return '$count $records adicionados.';
  }

  @override
  String projectBatchUpdatedCount(int count) {
    return 'Atualizados: $count';
  }

  @override
  String projectBatchAddedCount(int count) {
    return 'Adicionados: $count';
  }

  @override
  String projectBatchSkippedInReview(int count) {
    return 'Ignorados na revisão: $count';
  }

  @override
  String projectBatchFailedCount(int count) {
    return 'Com falha: $count';
  }

  @override
  String projectBatchOpenTable(String records) {
    return 'Abrir tabela de $records';
  }

  @override
  String projectBatchReviewUpdate(int count, int total, String records) {
    return 'Isto atualizará $count de $total $records. Linhas com problemas são ignoradas.';
  }

  @override
  String projectBatchReviewAdd(int count, int total, String records) {
    return 'Isto adicionará $count de $total $records. Linhas com problemas são ignoradas.';
  }

  @override
  String get projectBatchImportRowsMissingLinks =>
      'Importar linhas com vínculos ausentes';

  @override
  String get projectBatchImportRowsMissingLinksBody =>
      'O táxon, a pessoa, o local ou o evento fica vazio. Adicione-o ao projeto primeiro para vinculá-lo.';

  @override
  String get projectStatsPartQuantity => 'Quantidade de partes';

  @override
  String get projectStatsQuantity => 'Quantidade';

  @override
  String get projectStatsSite => 'Local';

  @override
  String get projectStatsDate => 'Data';

  @override
  String get projectStatsMethod => 'Método';

  @override
  String get projectStatsSex => 'Sexo';

  @override
  String get projectStatsLifeStage => 'Estágio de vida';

  @override
  String get projectStatsPartType => 'Tipo de parte';

  @override
  String get projectStatsTreatment => 'Tratamento';

  @override
  String get projectStatsParasiteTaxon => 'Táxon do parasita';

  @override
  String get projectStatsParasiteCategory => 'Categoria';

  @override
  String get projectStatsAnatomicalLocation => 'Localização anatômica';

  @override
  String get projectStatsHostSpecies => 'Espécie hospedeira';

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
    return '$measure por $category e $breakdown';
  }

  @override
  String projectStatsTitleAtSite(String title, String site) {
    return '$title em $site';
  }

  @override
  String projectStatsTitleForSpecies(String title, String species) {
    return '$title de $species';
  }

  @override
  String get projectStatsCoordinatesBySpecies => 'Coordenadas por espécie';

  @override
  String get projectStatsSpatialSpecimensTitle =>
      'Contagem de espécimes por coordenadas do local';

  @override
  String get projectStatsSpatialSpeciesTitle =>
      'Contagem de espécies por coordenadas do local';

  @override
  String get projectStatsSpatialFamiliesTitle =>
      'Contagem de famílias por coordenadas do local';

  @override
  String get projectStatsSpatialSelectedSpeciesTitle =>
      'Contagem da espécie selecionada por coordenadas';

  @override
  String get projectStatsCountSpecimens => 'espécimes';

  @override
  String get projectStatsCountSpecies => 'espécies';

  @override
  String get projectStatsCountFamilies => 'famílias';

  @override
  String get projectStatsClasses => 'Classes';

  @override
  String get projectStatsOrders => 'Ordens';

  @override
  String get projectStatsFamilies => 'Famílias';

  @override
  String get projectStatsGenera => 'Gêneros';

  @override
  String get projectStatsSpecimenMedia => 'Mídia de espécimes';

  @override
  String get projectStatsSiteMedia => 'Mídia de locais';

  @override
  String get projectStatsEventMedia => 'Mídia de eventos';

  @override
  String get projectStatsNarrativeMedia => 'Mídia de narrativas';

  @override
  String get projectStatsRecordedSites => 'Locais registrados';

  @override
  String get projectStatsSampledSites => 'Locais amostrados';

  @override
  String get projectStatsCaptureDays => 'Dias de captura';

  @override
  String get projectStatsProjectDays => 'Dias de projeto';

  @override
  String get projectStatsRecordedElevation => 'Altitude registrada';

  @override
  String get projectStatsSampledElevation => 'Altitude amostrada';

  @override
  String get projectStatsNotRecorded => 'Não registrado';

  @override
  String get projectStatsRecordStatistics => 'Estatísticas de registros';

  @override
  String get projectStatsTopSpecies => 'Espécies mais registradas';

  @override
  String get projectStatsRecordCounts => 'Contagem de registros';

  @override
  String get projectStatsShowRecordCounts => 'Mostrar contagem de registros';

  @override
  String get projectStatsShowTopSpecies => 'Mostrar espécies mais registradas';

  @override
  String get projectStatsExploreMore => 'Explorar mais estatísticas';

  @override
  String projectStatsRecordLoadError(String error) {
    return 'Não foi possível carregar as estatísticas de registros: $error';
  }

  @override
  String get projectStatsSummary => 'Resumo';

  @override
  String get projectStatsExplore => 'Explorar';

  @override
  String get projectStatsTotalAllProjects => 'Total de todos os projetos';

  @override
  String get projectStatsGroupBy => 'Agrupar por';

  @override
  String get projectStatsSelectSite => 'Selecione um local';

  @override
  String get projectStatsAllSites => 'Todos os locais';

  @override
  String get projectStatsSelectSpecies => 'Selecione uma espécie';

  @override
  String get projectStatsAllSpecies => 'Todas as espécies';

  @override
  String get projectStatsChart => 'Gráfico';

  @override
  String get projectStatsTable => 'Tabela';

  @override
  String get projectStatsRecordSummary => 'Resumo de registros';

  @override
  String get projectStatsTaxonomicBreakdown => 'Distribuição taxonômica';

  @override
  String get projectStatsMediaBreakdown => 'Distribuição de mídia';

  @override
  String get projectStatsPerProject => 'Por projeto';

  @override
  String get projectStatsNoProjects => 'Nenhum projeto ainda.';

  @override
  String projectStatsProjectLoadError(String error) {
    return 'Não foi possível carregar as estatísticas do projeto: $error';
  }

  @override
  String get projectStatsViewDetails => 'Ver detalhes';

  @override
  String get projectStatsBreakDownBy => 'Detalhar por';

  @override
  String projectStatsLoadError(String error) {
    return 'Não foi possível carregar as estatísticas: $error';
  }

  @override
  String get projectStatsSpecimensBySpecies => 'Espécimes por espécie';

  @override
  String get projectStatsSpecimensByFamily => 'Espécimes por família';

  @override
  String get projectStatsSpecimensBySite => 'Espécimes por local';

  @override
  String get projectStatsSpecimensByDate => 'Espécimes por data';

  @override
  String get projectStatsSpecimensByMethod => 'Espécimes por método';

  @override
  String get projectStatsSpecimensBySex => 'Espécimes por sexo';

  @override
  String get projectStatsPartQuantityByType => 'Quantidade de partes por tipo';

  @override
  String get projectStatsPartQuantityByTreatment =>
      'Quantidade de partes por tratamento';

  @override
  String get projectStatsCounts => 'Contagens';

  @override
  String get projectStatsSpatial => 'Espacial';

  @override
  String get projectStatsNetwork => 'Grafo';

  @override
  String get projectStatsNetworkTitle => 'Registros ligados por espécimes';

  @override
  String get projectStatsNetworkHint =>
      'Toque em um registro para ver o que se liga a ele.';

  @override
  String get projectStatsNetworkRadial => 'Radial';

  @override
  String get projectStatsNetworkLayered => 'Em camadas';

  @override
  String get projectStatsNetworkStartFrom => 'Começar por';

  @override
  String get projectStatsNetworkColumns => 'Colunas';

  @override
  String get projectStatsNetworkFields => 'Campos';

  @override
  String projectStatsNetworkMaxColumns(int count) {
    return 'Até $count colunas';
  }

  @override
  String get projectStatsNetworkYear => 'Ano';

  @override
  String get projectStatsNetworkLinked => 'Registros ligados';

  @override
  String get projectStatsNetworkFit => 'Ajustar à tela';

  @override
  String get projectStatsNetworkReset => 'Redefinir';

  @override
  String get projectStatsNetworkFullScreen => 'Ver grafo em tela cheia';

  @override
  String projectStatsNetworkLoadError(String error) {
    return 'Não foi possível carregar o grafo: $error';
  }

  @override
  String get projectStatsNetworkEmpty => 'Ainda não há espécimes para ligar.';

  @override
  String projectStatsNetworkMore(int count) {
    return '+$count mais';
  }

  @override
  String projectStatsNetworkSpecimens(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count espécimes',
      one: '1 espécime',
    );
    return '$_temp0';
  }

  @override
  String projectStatsNetworkShared(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count espécimes compartilhados',
      one: '1 espécime compartilhado',
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
  String get projectStatsNetworkShowLinks => 'Mostrar ligações';

  @override
  String get projectStatsNetworkHideLinks => 'Ocultar ligações';

  @override
  String get projectStatsNetworkShowMore => 'Mostrar mais';

  @override
  String get projectStatsNetworkSites => 'Locais';

  @override
  String get projectStatsNetworkEvents => 'Eventos';

  @override
  String get projectStatsNetworkSpecimenType => 'Espécimes';

  @override
  String get projectStatsNetworkTaxa => 'Espécies';

  @override
  String get projectStatsNetworkMedia => 'Mídia';

  @override
  String get projectStatsNetworkParts => 'Partes';

  @override
  String get projectStatsNetworkParasites => 'Parasitas';

  @override
  String get projectStatsNetworkLegend => 'Tipos de registro';

  @override
  String get projectStatsNetworkAllProjects => 'Todos os projetos';

  @override
  String get projectStatsNetworkOptions => 'Opções';

  @override
  String get projectStatsNetworkShowOptions => 'Mostrar opções';

  @override
  String get projectStatsNetworkHideOptions => 'Ocultar opções';

  @override
  String get projectStatsNetworkDetails => 'Detalhes';

  @override
  String get projectStatsNetworkExitFullScreen => 'Sair da tela cheia';

  @override
  String projectStatsNetworkSummaryRadial(String layout, String type) {
    return '$layout · a partir de $type';
  }

  @override
  String projectStatsNetworkSummaryLayered(String layout, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count colunas',
      one: '1 coluna',
    );
    return '$layout · $_temp0';
  }

  @override
  String get projectStatsNoData => 'Nenhum dado para exibir';

  @override
  String projectStatsTapToView(String label) {
    return '$label\nToque para ver os registros';
  }

  @override
  String get projectStatsShowBarChart => 'Mostrar gráfico de barras';

  @override
  String get projectStatsShowPieChart => 'Mostrar gráfico de pizza';

  @override
  String get projectStatsClearSelection => 'Limpar seleção';

  @override
  String projectStatsChoicesLoadError(String error) {
    return 'Não foi possível carregar as opções: $error';
  }

  @override
  String get projectStatsNoMatchingChoices => 'Nenhuma opção correspondente';

  @override
  String get projectStatsNoRecordsInGroup => 'Nenhum registro neste grupo.';

  @override
  String get projectStatsShow => 'Mostrar';

  @override
  String projectStatsSpeciesCountsByCoordinates(String species) {
    return 'Contagem de $species por coordenadas';
  }

  @override
  String get projectStatsMap => 'Mapa';

  @override
  String projectStatsSpatialLoadError(String error) {
    return 'Não foi possível carregar as estatísticas espaciais: $error';
  }

  @override
  String get projectStatsNoSpecimenCoords =>
      'Nenhum espécime está atribuído às coordenadas do projeto.';

  @override
  String get projectStatsNoSpeciesCoords =>
      'Nenhuma espécie está associada às coordenadas do projeto.';

  @override
  String get projectStatsNoFamilyCoords =>
      'Nenhuma família está associada às coordenadas do projeto.';

  @override
  String get projectStatsNoSelectedSpeciesCoords =>
      'Nenhum espécime da espécie selecionada está atribuído às coordenadas do projeto.';

  @override
  String projectStatsNoSpeciesCoordsFor(String species) {
    return 'Nenhum espécime de $species está atribuído às coordenadas do projeto.';
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
    return 'Média de $counted por coordenada';
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
      other: 'Categorias ($category)',
      one: 'Categoria ($category)',
    );
    return '$_temp0';
  }

  @override
  String projectStatsMeanPerCategory(String counted) {
    return 'Média de $counted por categoria';
  }

  @override
  String get projectStatsTopCategory => 'Categoria principal';

  @override
  String get projectStatsTopCategoryShare =>
      'Participação da categoria principal';

  @override
  String projectStatsTotalCount(String value) {
    return 'Contagem total: $value';
  }

  @override
  String get projectStatsElevation => 'Altitude';

  @override
  String get projectStatsSelectSpeciesPrompt =>
      'Selecione uma espécie para ver a abundância por coordenada.';

  @override
  String get projectStatsCollapseLegend => 'Recolher legenda do mapa';

  @override
  String get projectStatsExpandLegend => 'Expandir legenda do mapa';

  @override
  String get projectStatsLegend => 'Legenda';

  @override
  String get projectStatsLegendCircle =>
      'Cada círculo representa\numa coordenada';

  @override
  String get projectStatsLegendGrouped =>
      'Locais agrupados,\naproxime para separar';

  @override
  String projectStatsUnmappedRecords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count registros estão na tabela, mas não podem ser mapeados porque a latitude ou a longitude está ausente ou é inválida.',
      one:
          '1 registro está na tabela, mas não pode ser mapeado porque a latitude ou a longitude está ausente ou é inválida.',
    );
    return '$_temp0';
  }

  @override
  String get projectStatsSpatialMap => 'Mapa de estatísticas espaciais';

  @override
  String get projectStatsMapLayers => 'Camadas do mapa';

  @override
  String get projectStatsViewFullScreen => 'Ver mapa em tela cheia';

  @override
  String get projectStatsNaturalEarthError =>
      'Não foi possível carregar o mapa offline Natural Earth.';

  @override
  String get projectStatsNoValidCoordinates =>
      'Não há coordenadas válidas para mapear.';

  @override
  String projectStatsMapPrepareError(String error) {
    return 'Não foi possível preparar o mapa: $error';
  }

  @override
  String get projectStatsZoomIn => 'Aproximar';

  @override
  String get projectStatsZoomOut => 'Afastar';

  @override
  String get projectStatsCenterMap => 'Centralizar o mapa nas estatísticas';

  @override
  String projectStatsSiteCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count locais',
      one: '1 local',
    );
    return '$_temp0';
  }

  @override
  String get projectStatsExportTable => 'Exportar tabela';

  @override
  String get projectStatsColumnName => 'Nome';

  @override
  String get projectStatsColumnLocality => 'Localidade';

  @override
  String get projectStatsColumnDecimalLatitude => 'Latitude decimal';

  @override
  String get projectStatsColumnDecimalLongitude => 'Longitude decimal';

  @override
  String get projectStatsColumnElevation => 'Altitude (m)';

  @override
  String get projectStatsColumnDatum => 'Datum';

  @override
  String get projectStatsColumnUncertainty => 'Incerteza (m)';

  @override
  String get projectStatsColumnGpsUnit => 'Aparelho de GPS';

  @override
  String get projectStatsColumnLatitude => 'Latitude';

  @override
  String get projectStatsColumnLongitude => 'Longitude';

  @override
  String get projectStatsColumnCount => 'Contagem';

  @override
  String get projectStatsColumnPercent => 'Porcentagem';

  @override
  String get projectStatsColumnCategory => 'Categoria';

  @override
  String get projectStatsViewRecords => 'Ver registros';

  @override
  String get projectStatsExportStatisticsTable =>
      'Exportar tabela de estatísticas';

  @override
  String get projectStatsExportSpatialTable =>
      'Exportar tabela de estatísticas espaciais';

  @override
  String projectStatsExportError(String error) {
    return 'Não foi possível exportar as estatísticas: $error';
  }

  @override
  String get projectStatsExportComplete => 'Exportação concluída';

  @override
  String projectStatsShareError(String error) {
    return 'Não foi possível compartilhar as estatísticas: $error';
  }

  @override
  String get projectTissueMuseumPermanent => 'Acervo permanente do museu';

  @override
  String get projectTissueMuseumLoan => 'Empréstimo do museu';

  @override
  String get projectTissueIdOrBarcode => 'ID do tecido ou código de barras';

  @override
  String get projectTissueFillRows => 'Linhas, da esquerda para a direita';

  @override
  String get projectTissueFillColumns => 'Colunas, de cima para baixo';

  @override
  String get projectTissueFillSerpentine => 'Linhas em serpentina';

  @override
  String get projectTissueEntryScan => 'Leitura';

  @override
  String get projectTissueEntryWorkList => 'Lista de trabalho';

  @override
  String get projectTissueTitle => 'Curadoria de espécimes';

  @override
  String projectTissueFilledCount(int filled, int capacity) {
    return '$filled / $capacity preenchidas';
  }

  @override
  String get projectTissueNextCell => 'Próxima célula';

  @override
  String get projectTissueFull => 'Cheia';

  @override
  String get projectTissueNextBox => 'Próxima caixa';

  @override
  String get projectTissueFilled => 'Preenchida';

  @override
  String get projectTissueNext => 'Próxima';

  @override
  String get projectTissueScanTubes => 'Ler tubos';

  @override
  String get projectTissueCameraUnavailable =>
      'A leitura pela câmera não está disponível. Use o campo de leitura.';

  @override
  String get projectTissueCameraError =>
      'Não foi possível usar a câmera. Tente novamente ou use o campo de leitura.';

  @override
  String get projectTissueSessionLog => 'Registro da sessão';

  @override
  String projectTissueSessionLogCount(int count) {
    return 'Registro da sessão ($count)';
  }

  @override
  String get projectTissueSessionLogEmpty =>
      'Os tubos verificados aparecem aqui.';

  @override
  String projectTissueSeveralMatches(String code) {
    return 'Várias partes correspondem a $code';
  }

  @override
  String projectTissueCount(String count) {
    return 'Quantidade $count';
  }

  @override
  String projectTissueAt(String location) {
    return 'Em $location';
  }

  @override
  String get projectTissueFindTubes => 'Encontrar tubos';

  @override
  String get projectTissueType => 'Tipo de tecido';

  @override
  String get projectTissuePreservation => 'Preservação';

  @override
  String get projectTissueUpdateField => 'Campo a atualizar';

  @override
  String get projectTissueField => 'Campo';

  @override
  String get projectTissueValue => 'Valor';

  @override
  String get projectTissueMuseumCode => 'Código do museu';

  @override
  String get projectTissueBoxSize => 'Tamanho da caixa';

  @override
  String get projectTissueNumbering => 'Numeração';

  @override
  String get projectTissueFillOrder => 'Ordem de preenchimento';

  @override
  String get projectTissueBoxLabel => 'Rótulo da caixa';

  @override
  String get projectTissueBoxHint => 'Caixa';

  @override
  String get projectTissueBoxNumber => 'Número da caixa';

  @override
  String get projectTissueOverwrite => 'Substituir valores existentes';

  @override
  String get projectTissueOverwriteBody =>
      'Substitui uma localização armazenada ou um valor de campo diferente';

  @override
  String get projectTissueTabBox => 'Caixa';

  @override
  String get projectTissueTabSetup => 'Configuração';

  @override
  String projectTissueTabLog(int count) {
    return 'Registro ($count)';
  }

  @override
  String get projectTissueFindTubesBody =>
      'Quais tubos o escaneamento e a lista de trabalho encontram.';

  @override
  String get projectTissueUpdateFieldBody => 'Gravado em cada tubo colocado.';

  @override
  String get projectTissueBoxSectionBody =>
      'Tamanho, ordem de preenchimento e a caixa sendo preenchida.';

  @override
  String get projectTissueAdvanced => 'Rótulos e substituição';

  @override
  String get projectTissueAdvancedBody =>
      'Formato dos rótulos das células e como tratar valores guardados.';

  @override
  String get projectTissueExportLog => 'Exportar registro';

  @override
  String get projectTissueExportLogTitle => 'Exportar registro da sessão';

  @override
  String projectTissueExportSummary(int checked, int skipped) {
    return '$checked verificados, $skipped ignorados';
  }

  @override
  String get projectTissueLogStatusChecked => 'Verificado';

  @override
  String get projectTissueLogStatusSkipped => 'Ignorado';

  @override
  String get projectTissuePart => 'Parte';

  @override
  String get projectTissueColStatus => 'Status';

  @override
  String get projectTissueColOrder => 'Ordem';

  @override
  String get projectTissueColFieldId => 'ID de campo';

  @override
  String get projectTissueColTubeId => 'ID do tubo';

  @override
  String get projectTissueColKind => 'Tipo de item';

  @override
  String get projectTissueColType => 'Tipo';

  @override
  String get projectTissueColTreatment => 'Tratamento';

  @override
  String get projectTissueColField => 'Campo atualizado';

  @override
  String get projectTissueColValue => 'Valor';

  @override
  String get projectTissueColLocation => 'Localização';

  @override
  String get projectTissueColBox => 'Caixa';

  @override
  String get projectTissueColCell => 'Célula';

  @override
  String get projectTissueColPreviousValue => 'Valor anterior';

  @override
  String get projectTissueColPreviousLocation => 'Localização anterior';

  @override
  String get projectTissueLogColumns => 'Colunas';

  @override
  String get projectTissueLogColumnsBody =>
      'As colunas de curadoria vêm sempre primeiro. Adicione depois campos de partes, espécimes e registros vinculados.';

  @override
  String get projectTissueLogAddColumns => 'Adicionar colunas';

  @override
  String get projectTissueLogAddedColumns => 'Colunas adicionadas';

  @override
  String get projectTissueLogNoAddedColumns =>
      'Nenhuma coluna adicionada. A exportação tem apenas as colunas de curadoria.';

  @override
  String get projectTissueLogHeaderStyle =>
      'Cabeçalhos das colunas adicionadas';

  @override
  String get projectTissueLogHeaderFieldName => 'Nomes de campo';

  @override
  String get projectTissueLogHeaderKey => 'Chaves NAHPU';

  @override
  String get projectTissueLogChooseColumns => 'Escolher colunas';

  @override
  String projectTissueLogRemoveColumn(String name) {
    return 'Remover $name';
  }

  @override
  String projectTissueLogSelectedCount(int count) {
    return '$count selecionadas';
  }

  @override
  String get projectTissueReplace => 'Substituir';

  @override
  String projectTissueReplaceTitle(String cell) {
    return 'Substituir $cell?';
  }

  @override
  String projectTissueReplaceMessage(int count, String cell, String labels) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'O próximo tubo escaneado ou colocado vai para $cell. $labels perdem a localização e voltam para a lista de trabalho. Desfazer os devolve.',
      one:
          'O próximo tubo escaneado ou colocado vai para $cell. $labels perde a localização e volta para a lista de trabalho. Desfazer o devolve.',
    );
    return '$_temp0';
  }

  @override
  String projectTissueReplacing(String labels) {
    return 'Substitui $labels';
  }

  @override
  String projectTissueReplacedLog(String labels) {
    return 'Substituiu $labels';
  }

  @override
  String get projectTissueColReplaced => 'Substituídos';

  @override
  String get projectTissueAny => 'Qualquer';

  @override
  String get projectTissueScanTube => 'Ler tubo';

  @override
  String get projectTissueScanHint => 'Leia ou digite e pressione Enter';

  @override
  String get projectTissueScanWithCamera => 'Ler com a câmera';

  @override
  String get projectTissueUndo => 'Desfazer';

  @override
  String get projectTissueReady => 'Pronto. Leia o primeiro tubo.';

  @override
  String get projectTissueSuggestionsLabel => 'Você quis dizer';

  @override
  String get projectTissueWorkListEmpty =>
      'Nenhuma parte sem localização corresponde aos filtros de tipo de tecido e preservação.';

  @override
  String projectTissueRemaining(int count) {
    return 'Próxima · $count restantes';
  }

  @override
  String get projectTissuePlace => 'Posicionar';

  @override
  String get projectTissueIncludeParasites => 'Incluir parasitas';

  @override
  String get projectTissueWorkListSearch => 'Pesquisar na lista de trabalho';

  @override
  String get projectTissueNoMatches => 'Nenhum tubo corresponde';

  @override
  String get projectTissueParasite => 'Parasita';

  @override
  String get projectTissueParasiteCategory => 'Categoria de parasita';

  @override
  String get projectTissueIdParasiteIdOrBarcode =>
      'ID do tecido, ID do parasita ou código de barras';

  @override
  String get projectTissueFieldIdOrParasiteId =>
      'ID de campo ou ID do parasita';

  @override
  String get projectTissueSearchByFieldId => 'Pesquisar por ID de campo';

  @override
  String projectTissueLogChecked(int count) {
    return 'Registrados ($count)';
  }

  @override
  String projectTissueLogSkipped(int count) {
    return 'Ignorados ($count)';
  }

  @override
  String get projectTissueLogSkippedEmpty =>
      'Os tubos ignorados aparecem aqui até serem colocados.';

  @override
  String get projectTissuePreviousBox => 'Caixa anterior';

  @override
  String get projectTissueDetails => 'Detalhes';

  @override
  String get projectTissueOpenRecord => 'Abrir registro';

  @override
  String projectTissueSharedCell(int count) {
    return '$count tubos dividem esta célula';
  }

  @override
  String get projectTissueBarcode => 'Código de barras';

  @override
  String get projectTissueStorageLocation => 'Local de armazenamento';

  @override
  String get projectTissueCountLabel => 'Quantidade';

  @override
  String get projectTissueTapCellHint =>
      'Toque numa célula vazia para ir até ela, ou numa preenchida para ver o tubo';

  @override
  String get parasiteRecords => 'Registros de parasitas';

  @override
  String get parasiteUnidentified => 'Parasita não identificado';

  @override
  String parasiteIndividuals(String ids) {
    return 'Ind.: $ids';
  }

  @override
  String parasiteCount(String count) {
    return 'Quantidade: $count';
  }

  @override
  String get parasiteNoneAdded => 'Nenhum parasita adicionado';

  @override
  String get parasiteAdd => 'Adicionar parasita';

  @override
  String get parasiteEdit => 'Editar parasita';

  @override
  String get parasiteDetails => 'Detalhes do parasita';

  @override
  String get parasiteCountLabel => 'Quantidade';

  @override
  String get parasiteCountHint => 'Insira a quantidade de parasitas';

  @override
  String get parasiteCategory => 'Categoria';

  @override
  String get parasiteAnatomicalLocation => 'Localização anatômica';

  @override
  String get parasiteCollectionIdentification => 'Coleta e identificação';

  @override
  String get parasiteCollector => 'Coletor';

  @override
  String get parasiteCollectorHint => 'Selecione quem coletou o parasita';

  @override
  String get parasiteDetectionMethod => 'Método de detecção';

  @override
  String get parasiteDateCollected => 'Data de coleta';

  @override
  String get parasiteDateCollectedHint => 'Insira a data de coleta';

  @override
  String get parasiteTimeCollected => 'Hora de coleta';

  @override
  String get parasiteTimeCollectedHint => 'Insira a hora de coleta';

  @override
  String get parasiteDeterminer => 'Determinador';

  @override
  String get parasiteDeterminerHint => 'Selecione quem identificou o parasita';

  @override
  String get parasiteDateDetermined => 'Data de determinação';

  @override
  String get parasiteDateDeterminedHint => 'Insira a data de identificação';

  @override
  String get parasiteDeterminationMethod => 'Método de determinação';

  @override
  String parasiteSaveError(String error) {
    return 'Não foi possível salvar o parasita: $error';
  }

  @override
  String get parasiteTaxon => 'Táxon do parasita';

  @override
  String get parasiteTaxonHint => 'Selecione um táxon registrado';

  @override
  String get parasiteNotIdentified => 'Não identificado';

  @override
  String parasiteTaxaLoadError(String error) {
    return 'Não foi possível carregar os táxons: $error';
  }

  @override
  String get parasiteAddTaxon => 'Adicionar táxon';

  @override
  String get parasiteNotAssigned => 'Não atribuído';

  @override
  String get parasitePreparationPreservation => 'Preparação e preservação';

  @override
  String get parasitePreparationMethod => 'Método de preparação';

  @override
  String get parasiteTreatment => 'Tratamento';

  @override
  String get parasiteDatePreserved => 'Data de preservação';

  @override
  String get parasiteDatePreservedHint => 'Insira a data de preservação';

  @override
  String get parasiteTimePreserved => 'Hora de preservação';

  @override
  String get parasiteTimePreservedHint => 'Insira a hora de preservação';

  @override
  String get parasiteCuration => 'Curadoria';

  @override
  String get parasiteStorage => 'Armazenamento';

  @override
  String get parasiteStorageLocation => 'Local de armazenamento';

  @override
  String get parasiteStorageLocationHint =>
      'Insira o freezer, armário, prateleira ou recipiente';

  @override
  String get parasiteMuseumPermanent => 'Acervo permanente do museu';

  @override
  String get parasiteMuseumHint => 'Insira o nome ou a sigla do museu';

  @override
  String get parasiteMuseumLoan => 'Empréstimo do museu';

  @override
  String get parasiteRemarks => 'Observações';

  @override
  String get parasiteRemarksHint => 'Insira observações sobre o parasita';

  @override
  String get parasiteLifeStage => 'Estágio de vida';

  @override
  String get parasiteLifeStageHint => 'Selecione o estágio de vida do parasita';

  @override
  String get parasiteAssociationStatus => 'Status da associação';

  @override
  String get parasiteAssociationStatusHint =>
      'Selecione o status da associação';

  @override
  String parasiteFieldLoadError(String field, String error) {
    return 'Não foi possível carregar $field: $error';
  }

  @override
  String get parasiteSetOptionsInSettings =>
      'Defina as opções nas configurações de espécimes';

  @override
  String parasiteSelectField(String field) {
    return 'Selecione $field';
  }

  @override
  String get parasiteIds => 'IDs';

  @override
  String parasiteUuid(String uuid) {
    return 'UUID: $uuid';
  }

  @override
  String get parasiteId => 'ID do parasita';

  @override
  String get parasiteIdHint => 'Insira um ID de parasita definido pelo usuário';

  @override
  String get parasiteIdOptions => 'Opções do ID do parasita';

  @override
  String get parasiteScanCode => 'Ler QR/código de barras';

  @override
  String get parasiteNewNumber => 'Novo número';

  @override
  String get parasiteSettings => 'Configurações';

  @override
  String get parasiteIdSettings => 'Configurações do ID do parasita';

  @override
  String get parasitePrefix => 'Prefixo';

  @override
  String get parasitePrefixHint => 'Insira o prefixo do ID do parasita';

  @override
  String get parasiteNumber => 'Número';

  @override
  String get parasiteNumberHint => 'Insira o próximo número de ID do parasita';

  @override
  String get specimenShowOutlierWarnings =>
      'Mostrar avisos de valores atípicos';

  @override
  String get mammalTotalLength => 'Comprimento total (mm)';

  @override
  String get mammalTotalLengthHint => 'Insira CT';

  @override
  String get mammalTailLength => 'Comprimento da cauda (mm)';

  @override
  String get mammalTailLengthHint => 'Insira CC';

  @override
  String get specimenAutoCalculated => 'Calculado automaticamente';

  @override
  String get mammalHeadBodyLength => 'Comprimento da cabeça e corpo (mm)';

  @override
  String get mammalHeadBodyLengthHint => 'Insira CCC';

  @override
  String get mammalTailHeadBodyRatio => 'Comprimento cauda/CC';

  @override
  String get mammalTailHeadBodyRatioHint => 'Insira CC/CCC';

  @override
  String get mammalHindFootLength => 'Comprimento do pé posterior (mm)';

  @override
  String get mammalHindFootLengthHint => 'Insira o comprimento do PP';

  @override
  String get mammalEarLength => 'Comprimento da orelha (mm)';

  @override
  String get mammalEarLengthHint => 'Insira o comprimento da orelha';

  @override
  String get mammalShowBatFields => 'Mostrar campos de morcegos';

  @override
  String get specimenRemarks => 'Observações';

  @override
  String get specimenMeasurementRemarksHint =>
      'Escreva notas sobre as medidas (opcional)';

  @override
  String get specimenUnusualMeasurement => 'Medida incomum';

  @override
  String get mammalChangeSexTitle => 'Alterar o sexo?';

  @override
  String get mammalChangeSexBody =>
      'Alterar o sexo apagará os dados reprodutivos que não se aplicam à nova seleção.';

  @override
  String get specimenAccuracy => 'Precisão';

  @override
  String get specimenAccuracyHint => 'Selecione a precisão da medida';

  @override
  String get specimenNoInaccurateSelected =>
      'Nenhuma medida imprecisa selecionada';

  @override
  String specimenInaccurateList(String labels) {
    return '*Imprecisas: $labels';
  }

  @override
  String specimenAccuracyRemarkValue(String remark) {
    return 'Observação:\n$remark';
  }

  @override
  String get specimenSelectInaccurate => 'Selecionar medidas imprecisas';

  @override
  String get specimenInaccurateMeasurements => 'Medidas imprecisas';

  @override
  String get specimenSelectEveryInaccurate =>
      'Selecione cada medida imprecisa.';

  @override
  String get specimenSelectAtLeastOneInaccurate =>
      'Selecione pelo menos uma medida imprecisa.';

  @override
  String get specimenAccuracyRemark => 'Observação de precisão';

  @override
  String get specimenAccuracyRemarkHint =>
      'Descreva por que as medidas são imprecisas';

  @override
  String get mammalTestes => 'Testículos';

  @override
  String get mammalTestisPosition => 'Posição';

  @override
  String get mammalTestisPositionHint => 'Selecione a posição do testículo';

  @override
  String get specimenLengthMm => 'Comprimento (mm)';

  @override
  String get mammalTestisLengthHint =>
      'Insira o comprimento do testículo direito';

  @override
  String get specimenWidthMm => 'Largura (mm)';

  @override
  String get mammalTestisWidthHint => 'Insira a largura do testículo direito';

  @override
  String get mammalEpididymis => 'Epidídimo';

  @override
  String get mammalEpididymisHint => 'Selecione a aparência do epidídimo';

  @override
  String get mammalVaginaOpening => 'Abertura vaginal';

  @override
  String get mammalVaginaOpeningHint => 'Selecione a abertura vaginal';

  @override
  String get mammalPubicSymphysis => 'Sínfise púbica';

  @override
  String get mammalPubicSymphysisHint =>
      'Selecione a condição da sínfise púbica';

  @override
  String get mammalFemaleReproductive => 'Atributos reprodutivos da fêmea';

  @override
  String get mammalReproductiveStage => 'Estágio reprodutivo';

  @override
  String get mammalReproductiveStageHint => 'Selecione o estágio reprodutivo';

  @override
  String get mammalMammaeCounts => 'Contagem de mamas (pares)';

  @override
  String get mammalMammaeCondition => 'Condição das mamas';

  @override
  String get mammalMammaeConditionHint => 'Selecione a condição das mamas';

  @override
  String get mammalEmbryo => 'Embrião';

  @override
  String get mammalCrownRumpLength => 'Comprimento CR (mm)';

  @override
  String get mammalCrownRumpLengthHint => 'Insira o comprimento cabeça-nádega';

  @override
  String get mammalPlacentalScars => 'Cicatrizes placentárias';

  @override
  String get mammalAxillary => 'Axilar';

  @override
  String get mammalAxillaryHint => 'Insira o número de pares axilares';

  @override
  String get mammalAbdominal => 'Abdominal';

  @override
  String get mammalAbdominalHint => 'Insira o número de pares abdominais';

  @override
  String get mammalInguinal => 'Inguinal';

  @override
  String get mammalInguinalHint => 'Insira o número de pares inguinais';

  @override
  String get specimenLeft => 'Esquerda';

  @override
  String get specimenRight => 'Direita';

  @override
  String get mammalForearmLength => 'Comprimento do antebraço (mm)';

  @override
  String get mammalForearmLengthHint => 'Insira o comprimento do AB';

  @override
  String get mammalTibiaLength => 'Comprimento da tíbia (mm)';

  @override
  String get mammalTibiaLengthHint => 'Insira o comprimento da tíbia';

  @override
  String get mammalEcholocate => 'Ecolocaliza?';

  @override
  String get mammalEcholocation => 'Ecolocalização';

  @override
  String get mammalEcholocationHint => 'Selecione o tipo de ecolocalização';

  @override
  String get mammalFrequencyMax => 'Frequência máxima (kHz)';

  @override
  String get mammalFrequencyMaxHint =>
      'Insira a frequência máxima de ecolocalização';

  @override
  String get mammalFrequencyMin => 'Frequência mínima (kHz)';

  @override
  String get mammalFrequencyMinHint =>
      'Insira a frequência mínima de ecolocalização';

  @override
  String get mammalFrequencyMaxEnergy => 'Frequência de energia máxima (kHz)';

  @override
  String get mammalFrequencyMaxEnergyHint =>
      'Insira a frequência de ecolocalização de energia máxima';

  @override
  String get mammalEcholocationDuration => 'Duração (segundos)';

  @override
  String get mammalEcholocationDurationHint =>
      'Insira a duração da ecolocalização';

  @override
  String get birdWingspan => 'Envergadura (mm)';

  @override
  String get birdWingspanHint => 'Insira a envergadura';

  @override
  String get birdBillColor => 'Cor do bico';

  @override
  String get birdBillColorHint => 'Insira a cor do bico';

  @override
  String get birdMaxillaColor => 'Cor da maxila';

  @override
  String get birdMaxillaColorHint => 'Insira a cor da maxila';

  @override
  String get birdMandibleColor => 'Cor da mandíbula';

  @override
  String get birdMandibleColorHint => 'Insira a cor da mandíbula';

  @override
  String get birdIrisColor => 'Cor da íris';

  @override
  String get birdIrisColorHint => 'Insira a cor da íris';

  @override
  String get birdTarsusColor => 'Cor do tarso';

  @override
  String get birdTarsusColorHint => 'Insira a cor do tarso';

  @override
  String get birdToeColor => 'Cor dos dedos';

  @override
  String get birdToeColorHint => 'Insira a cor dos dedos';

  @override
  String get birdBroodPatch => 'Placa de incubação';

  @override
  String get birdBursaPresent => 'Bursa presente';

  @override
  String get birdStomachContents => 'Conteúdo estomacal';

  @override
  String get birdStomachContentsHint => 'Insira o conteúdo estomacal';

  @override
  String get birdBursaLength => 'Comprimento da bursa (mm)';

  @override
  String get birdBursaLengthHint => 'Insira o comprimento da bursa';

  @override
  String get birdBursaWidth => 'Largura da bursa (mm)';

  @override
  String get birdBursaWidthHint => 'Insira a largura da bursa';

  @override
  String get birdMaleGonads => 'Gônadas masculinas';

  @override
  String get birdLeftTestisSize => 'Tamanho do testículo esquerdo (mm)';

  @override
  String get birdSize => 'Tamanho';

  @override
  String get birdMinute => 'diminuto';

  @override
  String get birdOneMmOrGreater => '1 mm ou mais';

  @override
  String get birdLength => 'Comprimento';

  @override
  String get specimenEnterLength => 'Insira o comprimento';

  @override
  String get birdWidth => 'Largura';

  @override
  String get specimenEnterWidth => 'Insira a largura';

  @override
  String get birdTestisRemarksHint =>
      'Insira observações, p. ex., tamanho do testículo direito';

  @override
  String get birdFemaleGonads => 'Gônadas femininas';

  @override
  String get birdOvarySize => 'Tamanho do ovário';

  @override
  String get birdAppearance => 'Aparência';

  @override
  String get birdOviduct => 'Oviduto';

  @override
  String get birdGonadRemarksHint =>
      'Adicione informações adicionais sobre as gônadas';

  @override
  String get birdSkullOssification => 'Ossificação do crânio (%)';

  @override
  String get birdSkullOssificationHint => 'Insira a porcentagem';

  @override
  String get birdFat => 'Gordura';

  @override
  String get birdLargestOva => 'Diâmetro dos três maiores óvulos (mm)';

  @override
  String get birdFirst => 'Primeiro';

  @override
  String get birdEnterSize => 'Insira o tamanho';

  @override
  String get birdSecond => 'Segundo';

  @override
  String get birdThird => 'Terceiro';

  @override
  String get birdMolt => 'Muda';

  @override
  String get birdWingMolt => 'Muda das asas';

  @override
  String get birdTailMolt => 'Muda da cauda';

  @override
  String get birdMoltRemarksHint =>
      'Adicione informações adicionais sobre a muda';

  @override
  String get birdWingMoltHint => 'Insira a muda das asas';

  @override
  String get birdTailMoltHint => 'Insira a muda da cauda';

  @override
  String get birdBodyMolt => 'Muda corporal';

  @override
  String get specimenNotes => 'Notas';

  @override
  String get birdHabitat => 'Hábitat';

  @override
  String get birdHabitatHint =>
      'Adicione informações adicionais sobre o hábitat';

  @override
  String get specimenSpecimen => 'Espécime';

  @override
  String get specimenRemarksHint =>
      'Adicione informações adicionais sobre o espécime';

  @override
  String get fishStandardLength => 'Comprimento padrão (mm)';

  @override
  String get fishStandardLengthHint => 'Insira o comprimento padrão';

  @override
  String get fishTotalLengthHint => 'Insira o comprimento total';

  @override
  String get fishTotalIndividuals => 'Total de indivíduos';

  @override
  String get fishTotalIndividualsHint =>
      'Insira o número de indivíduos no lote';

  @override
  String get fishAutoUpdateRanges => 'Atualizar mín. e máx. automaticamente';

  @override
  String get fishAutoUpdateRangesBody =>
      'Preencher os intervalos com os indivíduos medidos abaixo';

  @override
  String get fishMinStandardLength => 'Comprimento padrão mín. (mm)';

  @override
  String get fishMinStandardLengthHint => 'Insira o comprimento padrão mínimo';

  @override
  String get fishMaxStandardLength => 'Comprimento padrão máx. (mm)';

  @override
  String get fishMaxStandardLengthHint => 'Insira o comprimento padrão máximo';

  @override
  String get fishMinTotalLength => 'Comprimento total mín. (mm)';

  @override
  String get fishMinTotalLengthHint => 'Insira o comprimento total mínimo';

  @override
  String get fishMaxTotalLength => 'Comprimento total máx. (mm)';

  @override
  String get fishMaxTotalLengthHint => 'Insira o comprimento total máximo';

  @override
  String get fishMinWeight => 'Peso mín.';

  @override
  String get fishMinWeightHint => 'Insira o peso mínimo';

  @override
  String get fishMaxWeight => 'Peso máx.';

  @override
  String get fishMaxWeightHint => 'Insira o peso máximo';

  @override
  String get fishSpecimenType => 'Tipo de espécime';

  @override
  String get fishTypeIndividual => 'Indivíduo';

  @override
  String get fishTypeLot => 'Lote';

  @override
  String get fishTypeIndividualDescription =>
      'Um peixe com suas próprias medidas';

  @override
  String get fishTypeLotDescription => 'Muitos indivíduos armazenados juntos';

  @override
  String get invertCaste => 'Casta';

  @override
  String get invertCasteHint => 'Selecione a casta';

  @override
  String get invertEcologicalInteractions => 'Interações ecológicas';

  @override
  String get invertShowMorphometrics => 'Mostrar morfometria do espécime';

  @override
  String get invertMorphometrics => 'Morfometria do espécime';

  @override
  String get invertHostOrganism => 'Organismo hospedeiro';

  @override
  String get invertHostOrganismHint => 'Insira o táxon hospedeiro associado';

  @override
  String get invertHostPart => 'Parte do hospedeiro';

  @override
  String get invertHostPartHint => 'Insira a parte ocupada do hospedeiro';

  @override
  String get invertHeadWidth => 'Largura da cabeça (mm)';

  @override
  String get invertHeadWidthHint => 'Insira a largura da cabeça';

  @override
  String get invertBodyLength => 'Comprimento do corpo (mm)';

  @override
  String get invertBodyLengthHint => 'Insira o comprimento do corpo';

  @override
  String get invertUpperWingspan => 'Envergadura superior (mm)';

  @override
  String get invertUpperWingspanHint => 'Insira a envergadura superior';

  @override
  String get invertLowerWingspan => 'Envergadura inferior (mm)';

  @override
  String get invertLowerWingspanHint => 'Insira a envergadura inferior';

  @override
  String get herpSnoutVentLength => 'CRC (cm)';

  @override
  String get herpSnoutVentLengthHint => 'Insira o comprimento rostro-cloacal';

  @override
  String get partSpecimenParts => 'Partes do espécime';

  @override
  String get partAdd => 'Adicionar parte do espécime';

  @override
  String get partNoneAdded => 'Nenhuma parte adicionada';

  @override
  String get partUnknown => 'Parte desconhecida';

  @override
  String get partNoCount => 'Sem quantidade';

  @override
  String get partNoTreatment => 'Nenhum';

  @override
  String get partHasRemark => 'tem observação';

  @override
  String partPmi(String pmi) {
    return 'IPM $pmi';
  }

  @override
  String get partAddParts => 'Adicionar partes do espécime';

  @override
  String get partEditParts => 'Editar partes do espécime';

  @override
  String get partPreparation => 'Preparação';

  @override
  String get partSampling => 'Amostragem';

  @override
  String partSaveError(String error) {
    return 'Não foi possível salvar a parte do espécime: $error';
  }

  @override
  String get partCounts => 'Quantidades';

  @override
  String get partCountsHint => 'Insira a quantidade de partes';

  @override
  String get partPreparationType => 'Tipo de preparação';

  @override
  String get partPreparationTypeHint => 'Insira o tipo de preparação';

  @override
  String get partTreatmentHint => 'Insira o tratamento';

  @override
  String get partAdditionalTreatment => 'Tratamento adicional';

  @override
  String get partAdditionalTreatmentHint => 'Insira o tratamento adicional';

  @override
  String get partPreparatorHint => 'Se for diferente do preparador do voucher';

  @override
  String get partDateTaken => 'Data da coleta';

  @override
  String get partTimeTaken => 'Hora da coleta';

  @override
  String get partRecommendedFresh => 'Recomendado para tecidos frescos';

  @override
  String get partStorageType => 'Tipo de armazenamento';

  @override
  String get partStorageTypeHint => 'Insira o tipo de armazenamento';

  @override
  String get partStorageLocationHint =>
      'Pode ser o ID da célula ou do frasco, conforme a convenção do seu museu';

  @override
  String get partMuseumHint => 'Insira um nome ou sigla de museu';

  @override
  String get partRemarksHint =>
      'Insira uma observação específica para esta parte';

  @override
  String get partBarcodeId => 'ID de QR/código de barras';

  @override
  String get partBarcodeIdHint =>
      'Insira o ID do código de barras (se aplicável)';

  @override
  String get partBarcodeIdOptions => 'Opções do ID de QR/código de barras';

  @override
  String get partGenerateUuid => 'Gerar UUID';

  @override
  String get partInvalidBarcode => 'QR/código de barras inválido';

  @override
  String get partBarcodeIdExists =>
      'O ID de QR/código de barras já existe. Limpe o campo para gerar um novo UUID';

  @override
  String get partTissueIdHint => 'Insira o ID do tecido';

  @override
  String get partRepeatTissueFailed => 'Falha ao repetir o número do tecido';

  @override
  String get partTissueIdOptions => 'Opções do ID do tecido';

  @override
  String get partTissueIdSettings => 'Configurações do ID do tecido';

  @override
  String get specimenCollectionIdentification => 'Coleta e identificação';

  @override
  String get specimenTaxaLoadError => 'Erro ao carregar os táxons';

  @override
  String get specimenIdConfidence => 'Confiança da identificação';

  @override
  String get specimenIdConfidenceHint => 'Escolha um nível de confiança';

  @override
  String get specimenDeterminerHint =>
      'Escolha um determinador (padrão: catalogador)';

  @override
  String get specimenIdMethod => 'Método de identificação';

  @override
  String get specimenIdMethodHint => 'Escolha um método de identificação';

  @override
  String get specimenCollectionDate => 'Data de coleta';

  @override
  String get specimenCollectionTime => 'Hora de coleta';

  @override
  String get specimenConditionHint => 'Escolha uma condição';

  @override
  String get specimenPrepDate => 'Data de prep.';

  @override
  String get specimenPrepTime => 'Hora de prep.';

  @override
  String get specimenPreparatorHint =>
      'Escolha um preparador (padrão: catalogador)';

  @override
  String specimenUuid(String uuid) {
    return 'UUID do espécime: $uuid';
  }

  @override
  String get specimenMuseumId => 'ID do museu';

  @override
  String get specimenMuseumIdHint => 'Insira o ID do museu (se aplicável)';

  @override
  String specimenFieldIdValue(String id) {
    return 'ID de campo: $id';
  }

  @override
  String get specimenFieldIdLoading => 'ID de campo: carregando…';

  @override
  String get specimenFieldIdUnavailable => 'ID de campo: indisponível';

  @override
  String get specimenFieldIdSelectCataloger =>
      'ID de campo: selecione um catalogador';

  @override
  String get specimenFieldIdCatalogerNotSetUp =>
      'ID de campo: o catalogador não está configurado para números de campo';

  @override
  String get specimenEditFieldId => 'Editar ID de campo';

  @override
  String get specimenFieldIdPersonnel => 'Pessoal';

  @override
  String get specimenFieldIdProject => 'Projeto';

  @override
  String get specimenFieldIdPersonnelUnavailable =>
      'Selecione um catalogador com o registro de números de campo pessoais ativado antes de atribuir um ID de campo pessoal.';

  @override
  String get specimenPersonnelFieldNumber => 'Número de campo pessoal';

  @override
  String get specimenProjectCatalogNumber => 'Número de catálogo do projeto';

  @override
  String get specimenFieldIdTypeChangeAck =>
      'Entendo que alterar o tipo de identificador remove o ID de campo anterior do espécime e que ele pode já aparecer em exportações ou em etiquetas de espécimes.';

  @override
  String get specimenSaving => 'Salvando…';

  @override
  String get fishStandardLengthShort => 'Comprimento padrão';

  @override
  String get fishTotalLengthShort => 'Comprimento total';

  @override
  String get fishWeight => 'Peso';

  @override
  String get fishLotSummary => 'Resumo do lote';

  @override
  String fishMeasuredCount(int count) {
    return '$count medidos';
  }

  @override
  String fishMeasuredOfTotal(int count, int total) {
    return '$count de $total indivíduos medidos';
  }

  @override
  String get fishNotMeasured => 'Não medido';

  @override
  String fishStandardDeviation(String value) {
    return '± $value DP';
  }

  @override
  String fishRange(String min, String max, String unit) {
    return 'Intervalo $min–$max $unit';
  }

  @override
  String get fishIndividuals => 'Indivíduos';

  @override
  String fishIndividualsLoadError(String error) {
    return 'Não foi possível carregar os indivíduos: $error';
  }

  @override
  String get fishAddIndividual => 'Adicionar indivíduo';

  @override
  String get fishDeleteIndividual => 'Excluir indivíduo';

  @override
  String fishStandardLengthValue(String value) {
    return 'CP $value mm';
  }

  @override
  String fishTotalLengthValue(String value) {
    return 'CT $value mm';
  }

  @override
  String get fishNoMeasurements => 'Sem medidas';

  @override
  String fishDeleteIndividualTitle(String name) {
    return 'Excluir $name?';
  }

  @override
  String get fishDeleteIndividualBody =>
      'Isso exclui o indivíduo e o desvincula de todas as partes do espécime e parasitas.';

  @override
  String get fishStandardLengthMm => 'CP (mm)';

  @override
  String get fishTotalLengthMm => 'CT (mm)';

  @override
  String fishWeightWithUnit(String unit) {
    return 'Peso ($unit)';
  }

  @override
  String get fishEnterWeight => 'Insira o peso';

  @override
  String get fishIndividualRemarksHint => 'Adicione notas sobre este indivíduo';

  @override
  String get fishEditIndividual => 'Editar indivíduo';

  @override
  String fishEnteredCount(int count) {
    return '$count inseridos';
  }

  @override
  String fishEnteredOfTotal(int count, int total) {
    return '$count de $total inseridos';
  }

  @override
  String get fishSaveAndAddAnother => 'Salvar e adicionar outro';

  @override
  String get fishMeasurements => 'Medidas';

  @override
  String get fishTagId => 'ID da etiqueta';

  @override
  String get fishTagIdHint => 'Insira o ID do indivíduo ou da etiqueta';

  @override
  String get fishAutoNumbered =>
      'Numerado automaticamente. Edite para substituir.';

  @override
  String get fishTagIdOptions => 'Opções do ID da etiqueta';

  @override
  String get fishTagIdSettings => 'Configurações do ID da etiqueta';

  @override
  String get specimenCaptureRecords => 'Registros de captura';

  @override
  String get specimenChooseSite => 'Escolha um local';

  @override
  String get specimenChangeSiteTitle => 'Alterar o local?';

  @override
  String get specimenChangeSiteBody =>
      'Exceto a data e a hora de captura, todos os campos da seção do registro de coleta ficarão vazios novamente.';

  @override
  String get specimenChooseEvent => 'Escolha um ID de evento de coleta';

  @override
  String get specimenChangeEventTitle => 'Alterar o ID do evento de coleta?';

  @override
  String get specimenChangeEventBody =>
      'Exceto a data e a hora de captura, todos os campos da seção do registro de coleta ficarão vazios novamente. A coordenada é mantida quando pertence ao mesmo local.';

  @override
  String get specimenChooseMethod => 'Escolha um tipo de método';

  @override
  String get specimenRelativeTime => 'Hora relativa';

  @override
  String get specimenMethodId => 'ID do método';

  @override
  String get specimenMethodIdHint =>
      'Insira o ID, p. ex., número da armadilha/rede etc.';

  @override
  String get specimenCaptureDate => 'Data de captura';

  @override
  String get specimenCoordinateId => 'ID da coordenada';

  @override
  String get specimenChooseCoordinate => 'Escolha uma coordenada';

  @override
  String get specimenCoordinateExtent => 'Extensão da coordenada (m)';

  @override
  String get specimenCoordinateExtentHint =>
      'Adicione a extensão da coordenada';

  @override
  String get specimenExtentInvalid =>
      'A extensão deve ser um número maior que zero';

  @override
  String get specimenCaptureTime => 'Hora de captura';

  @override
  String get specimenChoosePerson => 'Escolha uma pessoa';

  @override
  String get specimenSexHint => 'Selecione o sexo do espécime';

  @override
  String get specimenLifeStageHint => 'Selecione o estágio de vida';

  @override
  String specimenLifeStagesLoadError(String error) {
    return 'Não foi possível carregar os estágios de vida: $error';
  }

  @override
  String specimenParasiteDetectionLoadError(String error) {
    return 'Não foi possível carregar a detecção de parasitas: $error';
  }

  @override
  String get specimenParasitesExamined => 'Parasitas examinados';

  @override
  String get specimenParasitesDetected => 'Parasitas detectados';

  @override
  String get specimenDetectionRemarks => 'Observações de detecção';

  @override
  String get specimenDetectionRemarksHint =>
      'Insira observações sobre o exame ou a detecção de parasitas';

  @override
  String get specimenCreate => 'Criar espécime';

  @override
  String get specimenActions => 'Ações do espécime';

  @override
  String get specimenDuplicatePart => 'Duplicar parte';

  @override
  String get specimenExport => 'Exportar espécime';

  @override
  String get specimenImport => 'Importar espécime';

  @override
  String specimenDuplicatePartError(String error) {
    return 'Erro ao duplicar a parte: $error';
  }

  @override
  String get specimenDeleteTitle => 'Excluir espécime?';

  @override
  String get specimenDeleteBody =>
      'Você excluirá este registro de espécime, todas as medidas e as partes do espécime.\nSerá necessário atualizar manualmente o número de campo.';

  @override
  String specimenDeleteError(String error) {
    return 'Erro ao excluir o espécime: $error';
  }

  @override
  String get specimenDeleteAllTitle => 'Excluir todos os espécimes?';

  @override
  String get specimenDeleteAllBody =>
      'Isso removerá todos os registros de espécimes, as medidas e as partes de espécimes';

  @override
  String specimenDeleteAllError(String error) {
    return 'Erro ao excluir todos os espécimes: $error';
  }

  @override
  String get specimenTaxonInfo => 'Informações do táxon';

  @override
  String get specimenNoSpeciesSelected => 'Nenhuma espécie selecionada';

  @override
  String get specimenTaxonTooltip =>
      'Digite o nome do táxon e selecione na lista';

  @override
  String get specimenTaxon => 'Táxon';

  @override
  String get specimenTaxonHint => 'Digite o nome do táxon';

  @override
  String get specimenEnterTaxon => 'Insira o táxon';

  @override
  String get specimenNoneSelected => 'Nenhum selecionado';

  @override
  String specimenRemoveIndividualTooltip(String name) {
    return 'Remover $name';
  }

  @override
  String get specimenAllIndividualsAdded =>
      'Todos os indivíduos foram adicionados';

  @override
  String get specimenSelectIndividual => 'Selecione um indivíduo';

  @override
  String specimenRemoveIndividualTitle(String name) {
    return 'Remover $name?';
  }

  @override
  String specimenRemoveIndividualBody(String name) {
    return 'Este registro não ficará mais vinculado ao indivíduo $name. O indivíduo em si é mantido.';
  }

  @override
  String get specimenRecordsTitle => 'Registros de espécimes';

  @override
  String get specimenSearchOptions => 'Opções de pesquisa';

  @override
  String get specimenRecordTitle => 'Registro de espécime';

  @override
  String get specimenNoneFound => 'Nenhum espécime encontrado';

  @override
  String get specimenWeightHint => 'Insira o peso do espécime';

  @override
  String get specimenChangeWeightUnit => 'Alterar a unidade de peso';

  @override
  String get templateDeleteTextBox => 'Excluir caixa de texto';

  @override
  String get templateHeightMm => 'Altura (mm)';

  @override
  String get templatePictureTypeOptions => 'Opções do tipo de imagem';

  @override
  String get templateRotation => 'Rotação';

  @override
  String get templateQrCode => 'Código QR';

  @override
  String get templateQrSize => 'Tamanho do QR (mm)';

  @override
  String get templateContentFormattingOptions =>
      'Opções de formatação do conteúdo';

  @override
  String get templateShape => 'Forma';

  @override
  String get templateSquare => 'Quadrado';

  @override
  String get templateCircle => 'Círculo';

  @override
  String get templateDynamic => 'Dinâmico';

  @override
  String get templateSizePt => 'Tamanho (pt)';

  @override
  String get templateDecreaseFontSize => 'Diminuir o tamanho da fonte';

  @override
  String get templateIncreaseFontSize => 'Aumentar o tamanho da fonte';

  @override
  String get templateTextFormattingOptions => 'Opções de formatação do texto';

  @override
  String get templateTextStylingOptions => 'Opções de estilo do texto';

  @override
  String get templateMaxWidth => 'Largura máxima (mm)';

  @override
  String get templateMaxHeight => 'Altura máxima (mm)';

  @override
  String get templateFont => 'Fonte';

  @override
  String templateFontNotInstalled(String font) {
    return '$font (não instalada)';
  }

  @override
  String get templateUnderline => 'Sublinhado';

  @override
  String get templateStrikethrough => 'Tachado';

  @override
  String get templateForeground => 'Primeiro plano';

  @override
  String get templateQrForegroundColor =>
      'Selecione a cor de primeiro plano do QR';

  @override
  String get templateBackground => 'Fundo';

  @override
  String get templateQrBackgroundColor => 'Selecione a cor de fundo do QR';

  @override
  String get templateConditionalOutput => 'Saída condicional';

  @override
  String get templateFormat => 'Formato';

  @override
  String get templateMapEncodedValues => 'Mapear valores codificados';

  @override
  String get templateHeaderCase => 'Maiúsculas do cabeçalho';

  @override
  String get templateUppercase => 'Maiúsculas';

  @override
  String get templateLowercase => 'Minúsculas';

  @override
  String get templateMissing => 'Ausente';

  @override
  String get templateTextColor => 'Selecione a cor do texto';

  @override
  String get templateTextBackgroundColor => 'Selecione a cor de fundo do texto';

  @override
  String get templateStroke => 'Traço';

  @override
  String get templateTextStrokeColor => 'Selecione a cor do traço do texto';

  @override
  String get templateStyle => 'Estilo';

  @override
  String get templateRadius => 'Raio';

  @override
  String get templatePadding => 'Preenchimento';

  @override
  String get templateAlignLeft => 'Alinhar à esquerda';

  @override
  String get templateAlignCenter => 'Centralizar';

  @override
  String get templateAlignRight => 'Alinhar à direita';

  @override
  String templateClearColor(String label) {
    return 'Limpar $label';
  }

  @override
  String get templateNoContentPlaceholder => 'Marcador sem conteúdo';

  @override
  String get templateCustomText => 'Texto personalizado';

  @override
  String get templateCustomTextHint =>
      'Insira o texto alternativo personalizado';

  @override
  String get templateConditionalType => 'Tipo condicional';

  @override
  String get templateTargetField => 'Campo de destino';

  @override
  String get templateConditionalTextHelper =>
      'Campos como [mammalAttribute::testisWidth] são preenchidos.';

  @override
  String get templateReplacementHelper =>
      'Escrito quando houver correspondência; caso contrário, o valor original é mantido. Deixe vazio para ocultar o valor.';

  @override
  String get templateTypeNormalText => 'Texto normal';

  @override
  String get templateTypePicture => 'Imagem';

  @override
  String get templateTypeMarkdown => 'Markdown';

  @override
  String get templateTypeCoordinates => 'Coordenadas';

  @override
  String get templateTypeList => 'Valores de lista';

  @override
  String get templateTypeNestedList => 'Lista aninhada';

  @override
  String get templateTypeDates => 'Datas';

  @override
  String get templateTypeDateTime => 'Data e hora';

  @override
  String get templateTypeTime => 'Hora';

  @override
  String get templateTypeSex => 'Sexo';

  @override
  String get templateTypeNumber => 'Número';

  @override
  String get templateTypeEncoded => 'Texto codificado';

  @override
  String get templateFormatDefaultMapping => 'Mapeamento padrão';

  @override
  String get templateFormatCustomMapping => 'Mapeamento personalizado…';

  @override
  String get templateFormatDecimal => 'Decimal (45.123, -122.543)';

  @override
  String get templateFormatCardinalDecimal =>
      'Decimal cardinal (45.123° N, 122.543° O)';

  @override
  String get templateFormatPipe => 'Separado por barras verticais (A | B | C)';

  @override
  String get templateFormatComma => 'Separado por vírgulas (A, B, C)';

  @override
  String get templateFormatSemicolon =>
      'Separado por ponto e vírgula (A; B; C)';

  @override
  String get templateFormatSlash => 'Separado por barras (A / B / C)';

  @override
  String get templateFormatNewline => 'Nova linha (A\nB\nC)';

  @override
  String get templateFormatBullet => 'Com marcadores (• A\n• B)';

  @override
  String get templateFormatCustomSeparator => 'Separador personalizado…';

  @override
  String get templateFormatTable => 'Tabela';

  @override
  String get templateFormatCardList => 'Lista de cartões';

  @override
  String get templateFormatMonthDdYyyy => 'Mês DD, AAAA (junho 28, 2026)';

  @override
  String get templateFormatDdMonthYyyy => 'DD Mês AAAA (28 junho 2026)';

  @override
  String get templateFormatDdMonthAbbr => 'DD Mês (abrev.) (28 jun 2026)';

  @override
  String get templateFormatYmdSeconds =>
      'AAAA-MM-DD segundos (2026-06-28 14:05:09)';

  @override
  String get templateFormatIsoMinutes => 'ISO minutos (2026-06-28T14:05)';

  @override
  String get templateFormatIsoSeconds => 'ISO segundos (2026-06-28T14:05:09)';

  @override
  String get templateFormatDdMonthYyyyTime =>
      'DD Mês AAAA 24 h (28 junho 2026 14:05)';

  @override
  String get templateFormatMonthDdYyyyTime =>
      'Mês DD, AAAA 12 h (junho 28, 2026 2:05 PM)';

  @override
  String get templateFormatDdMonYyyyTime =>
      'DD Mês AAAA 24 h (28 jun 2026 14:05)';

  @override
  String get templateFormatMonDdYyyyTime =>
      'Mês DD, AAAA 12 h (jun 28, 2026 2:05 PM)';

  @override
  String get templateFormatTime24 => 'Hora 24 h (14:05)';

  @override
  String get templateFormatTime24Seconds => 'Hora 24 h com segundos (14:05:09)';

  @override
  String get templateFormatTime12 => 'Hora 12 h (2:05 PM)';

  @override
  String get templateFormatTime12Padded =>
      'Hora 12 h com zero à esquerda (02:05 PM)';

  @override
  String get templateFormatOriginal => 'Original';

  @override
  String get templateFormatDecimals0 => '0 casas decimais (p. ex., 12)';

  @override
  String get templateFormatDecimals1 => '1 casa decimal (p. ex., 12.3)';

  @override
  String get templateFormatDecimals2 => '2 casas decimais (p. ex., 12.34)';

  @override
  String get templateFormatDecimals3 => '3 casas decimais (p. ex., 12.345)';

  @override
  String get templateFormatNormal => 'Normal';

  @override
  String get templateFormatCapitalize => 'Capitalizar';

  @override
  String get templateSexSymbol => 'Símbolo (♂/♀)';

  @override
  String get templateSexLetter => 'Letra (M/F)';

  @override
  String get templateSexText => 'Texto (Macho/Fêmea)';

  @override
  String get templateSexUnknown => 'Desconhecido';

  @override
  String get templateSexNa => 'N/D';

  @override
  String get templateSexNone => 'Nenhum';

  @override
  String get templateSizeLabel => 'Tamanho do modelo:';

  @override
  String get templateAddImage => 'Adicionar imagem';

  @override
  String get templateAddLine => 'Adicionar linha';

  @override
  String get templateAddShape => 'Adicionar forma';

  @override
  String get templateFront => 'Frente';

  @override
  String get templateBack => 'Verso';

  @override
  String get templateSave => 'Salvar modelo';

  @override
  String get templateRedo => 'Refazer';

  @override
  String get templateBorder => 'Borda do modelo';

  @override
  String get templateElements => 'Elementos';

  @override
  String get templateHideGrid => 'Ocultar grade';

  @override
  String get templateShowGrid => 'Mostrar grade';

  @override
  String get templateDisableSnap => 'Desativar encaixe';

  @override
  String get templateEnableSnap => 'Ativar encaixe';

  @override
  String get templateUnlockCanvas => 'Desbloquear movimento da tela';

  @override
  String get templateLockCanvas => 'Bloquear movimento da tela';

  @override
  String get templateSelectPreviewRecord =>
      'Selecionar espécime para a prévia do texto';

  @override
  String get templateSettings => 'Configurações do modelo';

  @override
  String get templateToolPage => 'Página';

  @override
  String get templateToolView => 'Visualização';

  @override
  String get templatePresetTemplate => 'Modelo predefinido';

  @override
  String templateMirrorOn(String side) {
    return '$side: girado 180° para impressão (toque para desativar)';
  }

  @override
  String templateMirrorOff(String side) {
    return '$side: toque para girar o modelo 180° na impressão';
  }

  @override
  String get templateOneSided => '1 face';

  @override
  String templateEditSide(String side) {
    return 'Editar o lado $side';
  }

  @override
  String templateElementsForSide(String side) {
    return 'Elementos · $side';
  }

  @override
  String get templateNoElements =>
      'Ainda não há elementos neste lado. Adicione um com as ferramentas de Adicionar.';

  @override
  String get templateHidden => 'Oculto';

  @override
  String get templateLocked => 'Bloqueado';

  @override
  String get templateNoSaved => 'Ainda não há modelos salvos.';

  @override
  String get templateFitToScreen => 'Ajustar à tela';

  @override
  String get templateRemoveImage => 'Remover imagem';

  @override
  String get templateDragToRotate => 'Arraste para girar';

  @override
  String get templateRemoveLine => 'Remover linha';

  @override
  String get templateDragToMove => 'Arraste para mover';

  @override
  String get templateRemoveShape => 'Remover forma';

  @override
  String get templateDeleteImage => 'Excluir imagem';

  @override
  String get templateLineStrokeOptions => 'Opções do traço da linha';

  @override
  String get templateThickness => 'Espessura';

  @override
  String get templateColor => 'Cor';

  @override
  String get templateSelectColor => 'Selecionar cor';

  @override
  String get templateDeleteLine => 'Excluir linha';

  @override
  String get templateDismissToolbar => 'Fechar barra de ferramentas';

  @override
  String get templateBorderFillOptions => 'Opções de borda e preenchimento';

  @override
  String get templateSelectStrokeColor => 'Selecionar cor do traço';

  @override
  String get templateFill => 'Preenchimento';

  @override
  String get templateClearFill => 'Remover preenchimento';

  @override
  String get templateDeleteShape => 'Excluir forma';

  @override
  String get templateRectangle => 'Retângulo';

  @override
  String get templateEllipse => 'Elipse';

  @override
  String get templateTriangle => 'Triângulo';

  @override
  String get templatePolygon => 'Polígono';

  @override
  String get templateCorners => 'Cantos';

  @override
  String get templateSelectFillColor => 'Selecionar cor de preenchimento';

  @override
  String get templateBorderTitle => 'Borda';

  @override
  String get templateSelectBorderColor => 'Selecionar cor da borda';

  @override
  String get templateSelectColorShade => 'Selecionar tom de cor';

  @override
  String get templateSelectedColorShades => 'Cor selecionada e seus tons';

  @override
  String get templateSendToBack => 'Enviar para trás';

  @override
  String get templateSendBackward => 'Recuar';

  @override
  String get templateBringForward => 'Avançar';

  @override
  String get templateBringToFront => 'Trazer para a frente';

  @override
  String get templateUnlockPosition => 'Desbloquear posição';

  @override
  String get templateLockPosition => 'Bloquear posição';

  @override
  String get templateHideElement => 'Ocultar elemento';

  @override
  String get templateShowElement => 'Mostrar elemento';

  @override
  String get templateDuplicateElement => 'Duplicar elemento';

  @override
  String get templateCopyElement => 'Copiar elemento';

  @override
  String get templatePasteElement => 'Colar elemento';

  @override
  String templateMapEncodedValuesBody(String field) {
    return 'Defina rótulos personalizados para os valores de [$field]:';
  }

  @override
  String get templateFontsNotInstalled => 'Fontes não instaladas';

  @override
  String templateMissingFontOne(int templates) {
    String _temp0 = intl.Intl.pluralLogic(
      templates,
      locale: localeName,
      other:
          'Esta instalação não tem 1 fonte usada pelos modelos importados. Escolha uma substituta.',
      one:
          'Esta instalação não tem 1 fonte usada pelo modelo importado. Escolha uma substituta.',
    );
    return '$_temp0';
  }

  @override
  String templateMissingFontMany(int templates, int fonts) {
    String _temp0 = intl.Intl.pluralLogic(
      templates,
      locale: localeName,
      other:
          'Esta instalação não tem $fonts fontes usadas pelos modelos importados. Escolha uma substituta para cada uma.',
      one:
          'Esta instalação não tem $fonts fontes usadas pelo modelo importado. Escolha uma substituta para cada uma.',
    );
    return '$_temp0';
  }

  @override
  String get templateInstallOriginalFonts =>
      'Instale as fontes originais em Documentos > Fontes se precisar de uma correspondência exata.';

  @override
  String templateFontPreview(String font) {
    return 'Prévia: $font';
  }

  @override
  String get templateCancelImport => 'Cancelar importação';

  @override
  String get templateReplaceAndImport => 'Substituir e importar';

  @override
  String get templateExistsTitle => 'O modelo já existe';

  @override
  String templateExistsBody(String name) {
    return 'Já existe um modelo chamado \"$name\". Substituir a cópia salva?';
  }

  @override
  String get templateNewName => 'Novo nome';

  @override
  String get templateUploadFromDevice => 'Enviar do dispositivo';

  @override
  String get templateUploadFromDeviceBody =>
      'Copia o arquivo para a sua pasta de imagens de modelos';

  @override
  String get templateSavedImages => 'Imagens salvas';

  @override
  String get templateNoSavedImages =>
      'Ainda não há imagens salvas; envie uma primeiro.';

  @override
  String get templateName => 'Nome do modelo';

  @override
  String get templateEnterName => 'Insira um nome';

  @override
  String get templateSaveImportedAs => 'Salvar modelo importado como';

  @override
  String templateMustDiffer(String name) {
    return 'Deve ser diferente de \"$name\"';
  }

  @override
  String get templateNameExists => 'Já existe um modelo com este nome';

  @override
  String templateRecordTypeValue(String type) {
    return 'Tipo de registro: $type';
  }

  @override
  String get templateSides => 'Faces';

  @override
  String get templateOneSidedBody => 'Crie um modelo apenas com a frente.';

  @override
  String get templateTwoSided => '2 faces';

  @override
  String get templateTwoSidedBody =>
      'Crie designs separados para a frente e o verso.';

  @override
  String get templateCreateNew => 'Criar novo modelo';

  @override
  String get templateOptions => 'Opções do modelo';

  @override
  String get templateSaveAs => 'Salvar como…';

  @override
  String get templateChoose => 'Escolher modelo';

  @override
  String get templateUntitled => 'Modelo sem título';

  @override
  String get templateInsertField => 'Inserir campo';

  @override
  String get templateAllTaxa => 'Todos os táxons';

  @override
  String get templateEditCustomText => 'Editar texto personalizado';

  @override
  String get templateTextInput => 'Entrada de texto';

  @override
  String get templateTextInputHint => 'Insira texto ou campos…';

  @override
  String get templateAvailableSymbols => 'Símbolos disponíveis';

  @override
  String get templateEnterText => 'Insira o texto…';

  @override
  String templateRenamedTo(String name) {
    return 'Renomeado para $name';
  }

  @override
  String templateRenameFailed(String error) {
    return 'Falha ao renomear: $error';
  }

  @override
  String templateSavedName(String name) {
    return 'Modelo \"$name\" salvo';
  }

  @override
  String templateSavedFile(String file) {
    return '$file salvo';
  }

  @override
  String templateReplacementInvalid(int index, String text, String message) {
    return 'A substituição de texto $index em \"$text\" é inválida: $message';
  }

  @override
  String templateImportedAndSaved(String name) {
    return '\"$name\" importado e salvo';
  }

  @override
  String get templateImportFailed =>
      'A importação falhou ou o arquivo é inválido';

  @override
  String get templateUnsavedChanges => 'Alterações não salvas';

  @override
  String get templateUnsavedChangesBody =>
      'Deseja salvar as alterações do modelo antes de sair?';

  @override
  String get templateDiscard => 'Descartar';

  @override
  String get templatePreviewPartSelection =>
      'Seleção de parte do espécime para a prévia';

  @override
  String get templatePreviewParasiteSelection =>
      'Seleção de parasita para a prévia';

  @override
  String get templatePreviewSpecimenSelection =>
      'Seleção de espécime para a prévia';

  @override
  String get templateSizePreset => 'Tamanho predefinido do modelo';

  @override
  String get templateSizePaper => 'Papel';

  @override
  String get templateSizeCryotubes => 'Criotubos';

  @override
  String get templateSizeRangeHelper => 'Insira um valor entre 10 e 500 mm';

  @override
  String get templateSizeEnterWidth => 'Insira uma largura';

  @override
  String get templateSizeInvalidNumber => 'Insira um número válido';

  @override
  String get templateSizeOutOfRange => 'Deve estar entre 10 e 500';

  @override
  String get templateSizeEnterHeight => 'Insira uma altura';

  @override
  String get templateSizeApplyCustom => 'Aplicar tamanho personalizado';

  @override
  String get templatePresetLetter => 'Carta';

  @override
  String get templatePresetLegal => 'Ofício';

  @override
  String get templatePresetVialSideLarge => 'Lateral de frasco de 1,5 - 2,0 mL';

  @override
  String get templatePresetVialSideSmall => 'Lateral de frasco de 0,5 - 1,0 mL';

  @override
  String get templatePresetCapDotSmall => 'Ponto pequeno para tampa de frasco';

  @override
  String get templatePresetCapDotLarge => 'Ponto grande para tampa de frasco';

  @override
  String get templatePresetSelfLaminating => 'Envoltório autolaminante';

  @override
  String get templatePresetPinnedLocality =>
      'Invertebrado alfinetado (localidade)';

  @override
  String get templatePresetPinnedTaxon =>
      'Invertebrado alfinetado (ID do táxon)';

  @override
  String get templatePresetJarInsert => 'Coleção em fluido (inserto de frasco)';

  @override
  String get templatePresetVertebrateTag =>
      'Etiqueta de espécime vertebrado (média)';

  @override
  String get templatePresetSkullBox => 'Caixa de crânio / microfrasco';

  @override
  String get templatePresetA4Description =>
      'Padrão internacional para catálogos, relatórios e folhas de etiquetas.';

  @override
  String get templatePresetLetterDescription =>
      'Padrão norte-americano para documentação e impressão matricial.';

  @override
  String get templatePresetLegalDescription =>
      'Tela estendida para cadernos de campo longos, folhas de histórico ou tabelas grandes.';

  @override
  String get templatePresetA5Description =>
      'Tamanho compacto ideal para cadernos de campo de bolso e pequenos insertos.';

  @override
  String get templatePresetA3Description =>
      'Folha grande para mapas, layouts de gavetas de coleção e grades do sistema.';

  @override
  String get templatePresetVialSideLargeDescription =>
      'Etiqueta lateral padrão. Cabem 3-4 linhas de texto e um código de barras.';

  @override
  String get templatePresetVialSideSmallDescription =>
      'Perfil lateral compacto para alíquotas menores de tecido ou DNA.';

  @override
  String get templatePresetCapDotSmallDescription =>
      'Ponto circular superior para tampas de tubos de 0,5–1,5 mL, para leitura de cima.';

  @override
  String get templatePresetCapDotLargeDescription =>
      'Ponto circular superior para tampas de rosca de criofrascos de 2,0 mL ou maiores.';

  @override
  String get templatePresetSelfLaminatingDescription =>
      'O texto é impresso em uma área de 25,4x12,7 mm; a cauda transparente envolve e protege contra nitrogênio líquido.';

  @override
  String get templatePresetPinnedLocalityDescription =>
      'Limite rígido para insetos alfinetados; cabem 5-6 linhas de metadados ultracompactos.';

  @override
  String get templatePresetPinnedTaxonDescription =>
      'Menor tamanho; contém gênero e espécie, autor e dados do determinador.';

  @override
  String get templatePresetJarInsertDescription =>
      'Colocada dentro de frascos úmidos (álcool/formol). Alta legibilidade através do vidro curvo.';

  @override
  String get templatePresetVertebrateTagDescription =>
      'Etiqueta pendurada padrão de tamanho médio para curadoria de vertebrados.';

  @override
  String get templatePresetSkullBoxDescription =>
      'Otimizada para frascos de vidro de 1 a 2 dracmas ou pequenas caixas osteológicas de papelão.';

  @override
  String get templateElementImage => 'Imagem';

  @override
  String templateElementImageDetail(String width, String height) {
    return 'Imagem · $width × $height mm';
  }

  @override
  String get templateElementLine => 'Linha';

  @override
  String get templateElementEmptyText => 'Texto vazio';

  @override
  String get mediaGallery => 'Galeria';

  @override
  String get mediaActions => 'Ações';

  @override
  String get mediaDeleteSelectedTitle => 'Excluir as mídias selecionadas?';

  @override
  String get mediaDeleteSelectedBody =>
      'Excluir as mídias selecionadas de todos os registros do NAHPU e do disco? Esta ação não pode ser desfeita.';

  @override
  String mediaSelectedCount(int count) {
    return '$count selecionados';
  }

  @override
  String get mediaNoneAdded => 'Nenhuma mídia adicionada';

  @override
  String get mediaAdd => 'Adicionar mídia';

  @override
  String get mediaTakePhotosVideos => 'Tirar fotos/vídeos';

  @override
  String get mediaRecordAudio => 'Gravar áudio';

  @override
  String get mediaAddFromGallery => 'Adicionar da galeria';

  @override
  String get mediaAddFromFile => 'Adicionar de arquivo';

  @override
  String get mediaUnavailable => 'Mídia indisponível';

  @override
  String get mediaFileMissing => 'Arquivo ausente';

  @override
  String get mediaImageUnavailable => 'Imagem indisponível';

  @override
  String get mediaNone => 'Sem mídia';

  @override
  String get mediaMenuActions => 'Ações de mídia';

  @override
  String get mediaShowInfo => 'Mostrar informações';

  @override
  String get mediaEdit => 'Editar mídia';

  @override
  String get mediaInfo => 'Informações da mídia';

  @override
  String get mediaDeleteFileTitle => 'Excluir arquivo de mídia?';

  @override
  String mediaDeleteFileBody(String name) {
    return 'Excluir $name de todos os registros do NAHPU e do disco? Esta ação não pode ser desfeita.';
  }

  @override
  String get mediaDeleteThisFileBody =>
      'Excluir este arquivo de mídia de todos os registros do NAHPU e do disco? Esta ação não pode ser desfeita.';

  @override
  String get mediaFileAlreadyExists => 'O arquivo já existe';

  @override
  String get mediaFileName => 'Nome do arquivo';

  @override
  String get mediaFileNameHint => 'Insira um nome de arquivo';

  @override
  String get mediaCaption => 'Legenda';

  @override
  String get mediaCaptionHint => 'Insira uma legenda';

  @override
  String get mediaTag => 'Etiqueta';

  @override
  String get mediaTagHint => 'Insira uma etiqueta';

  @override
  String get mediaPhotographer => 'Fotógrafo';

  @override
  String get mediaSelectPersonnel => 'Selecione o pessoal';

  @override
  String get mediaClearPhotographer => 'Remover fotógrafo';

  @override
  String get mediaExportSelected => 'Exportar mídias selecionadas';

  @override
  String get mediaExporting => 'Exportando mídias';

  @override
  String get mediaExportingHint =>
      'Seleções grandes podem levar vários minutos. Mantenha o NAHPU aberto até terminar.';

  @override
  String get mediaExport => 'Exportar mídias';

  @override
  String get mediaExportLeaveBody =>
      'A exportação ainda está em andamento. Sair agora a cancela e nenhum arquivo será salvo.';

  @override
  String get mediaArchive => 'Arquivo de mídias';

  @override
  String get mediaImageFormat => 'Formato de imagem';

  @override
  String get mediaLimitDimensions => 'Limitar as dimensões da imagem';

  @override
  String get mediaLimitDimensionsBody => 'Limita o lado maior sem ampliar';

  @override
  String get mediaMaxDimension => 'Largura ou altura máxima (px)';

  @override
  String get mediaMaxDimensionHelper => 'Aplica-se ao lado mais longo.';

  @override
  String get mediaJpegQuality => 'Qualidade JPEG';

  @override
  String get mediaImages => 'Imagens';

  @override
  String get mediaAudio => 'Áudio';

  @override
  String get mediaVideo => 'Vídeo';

  @override
  String get mediaOther => 'Outros';

  @override
  String get mediaSourceSize => 'Tamanho de origem';

  @override
  String get mediaExported => 'Exportados';

  @override
  String mediaWarningCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count avisos',
      one: '1 aviso',
    );
    return '$_temp0';
  }

  @override
  String mediaCannotConvert(String format) {
    return '$format não pode ser convertido e permanecerá no formato original.';
  }

  @override
  String get mediaPause => 'Pausar';

  @override
  String get mediaPlay => 'Reproduzir';

  @override
  String mediaPlaybackUnavailable(String error) {
    return 'A prévia de reprodução não está disponível: $error';
  }

  @override
  String get mediaCameraAccessRequired =>
      'É necessário acesso à câmera para tirar fotos e gravar vídeos.';

  @override
  String get mediaMicrophoneAccessRequired =>
      'É necessário acesso ao microfone para gravar vídeo.';

  @override
  String get mediaCameraError => 'Não foi possível usar a câmera.';

  @override
  String get mediaPhoto => 'Foto';

  @override
  String get mediaSwitchCamera => 'Trocar de câmera';

  @override
  String get mediaStopRecording => 'Parar gravação';

  @override
  String get mediaRecordVideo => 'Gravar vídeo';

  @override
  String get mediaRetake => 'Refazer';

  @override
  String get mediaUse => 'Usar';

  @override
  String get mediaDetailFile => 'Arquivo';

  @override
  String get mediaCategory => 'Categoria';

  @override
  String get mediaCaptureEquipment => 'Captura e equipamento';

  @override
  String get mediaTaken => 'Tirada';

  @override
  String get mediaCamera => 'Câmera';

  @override
  String get mediaLenses => 'Lentes';

  @override
  String get mediaAdditionalExif => 'EXIF adicional';

  @override
  String get mediaId => 'ID da mídia';

  @override
  String get mediaSecondaryId => 'ID secundário';

  @override
  String get mediaPhotographerId => 'ID do fotógrafo';

  @override
  String get mediaLinkedInformation => 'Informações vinculadas';

  @override
  String mediaLinkedInformationError(String error) {
    return 'As informações vinculadas não estão disponíveis: $error';
  }

  @override
  String get mediaResume => 'Retomar';

  @override
  String get mediaPausePlayback => 'Pausar reprodução';

  @override
  String get mediaPlayRecording => 'Reproduzir gravação';

  @override
  String get mediaRecordingNotSaved => 'A gravação de áudio não foi salva.';

  @override
  String get mediaImageSettings => 'Configurações de imagem';

  @override
  String mediaOriginalSize(int width, int height) {
    return 'Original: $width × $height px';
  }

  @override
  String get mediaResizeImage => 'Redimensionar imagem';

  @override
  String get mediaAspectLocked => 'A proporção está bloqueada';

  @override
  String get mediaWidthPx => 'Largura (px)';

  @override
  String mediaMaxValue(int value) {
    return 'Máx. $value';
  }

  @override
  String get mediaHeightPx => 'Altura (px)';

  @override
  String get mediaSearchMetadata => 'Pesquisar metadados de mídia';

  @override
  String get mediaGalleryTitle => 'Galeria de mídias';

  @override
  String get mediaGalleryAllProjectsTitle => 'Todas as mídias';

  @override
  String get mediaFilterProject => 'Filtrar por projeto';

  @override
  String get mediaAllProjects => 'Todos os projetos';

  @override
  String get mediaSearch => 'Pesquisar mídias';

  @override
  String get mediaDeleteSelected => 'Excluir mídias selecionadas';

  @override
  String get mediaCategoryEvent => 'Evento';

  @override
  String get mediaSort => 'Ordenar mídias';

  @override
  String get mediaNoMatching => 'Nenhuma mídia corresponde';

  @override
  String get mediaSortAddedNewest => 'Adicionadas recentemente';

  @override
  String get mediaSortAddedOldest => 'Adicionadas há mais tempo';

  @override
  String get mediaSortFileNameAsc => 'Nome do arquivo A–Z';

  @override
  String get mediaSortFileNameDesc => 'Nome do arquivo Z–A';

  @override
  String get mediaSortTakenNewest => 'Data da foto, mais recente';

  @override
  String get mediaSortTakenOldest => 'Data da foto, mais antiga';

  @override
  String get mediaHideDetails => 'Ocultar detalhes';

  @override
  String get mediaShowDetails => 'Mostrar detalhes';

  @override
  String get mediaPrevious => 'Anterior';

  @override
  String get mediaMute => 'Silenciar';

  @override
  String get mediaUnmute => 'Ativar som';

  @override
  String get mediaPlaybackSpeed => 'Velocidade de reprodução';

  @override
  String get mediaExitFullscreen => 'Sair da tela cheia';

  @override
  String get mediaFullscreen => 'Tela cheia';

  @override
  String mediaCannotDisplay(String kind) {
    return 'Não é possível exibir este arquivo de $kind';
  }

  @override
  String get mediaBarcode => 'Código de barras';

  @override
  String get mediaScanQrCode => 'Ler código QR';

  @override
  String get mediaScanBarcode => 'Ler código de barras';

  @override
  String get mediaAlignQrCode => 'Alinhe o código QR dentro da moldura';

  @override
  String get mediaAlignBarcode => 'Alinhe o código de barras dentro da moldura';

  @override
  String get mediaQrTooLarge =>
      'Os dados são grandes demais para um código QR.\nExporte-os como arquivo.';

  @override
  String get associatedUnnamed => 'Dados associados sem nome';

  @override
  String get associatedFileUnavailable => 'Arquivo indisponível';

  @override
  String get associatedTypeLink => 'Link';

  @override
  String get associatedUnknownType => 'Tipo desconhecido';

  @override
  String get associatedNoResource => 'Sem recurso';

  @override
  String get associatedActions => 'Ações de dados associados';

  @override
  String get associatedOpenInDefaultApp => 'Abrir no aplicativo padrão';

  @override
  String get associatedOpenLink => 'Abrir link';

  @override
  String get associatedNoUriToShare => 'Não há URI para compartilhar.';

  @override
  String get associatedFileNotFound => 'Arquivo não encontrado';

  @override
  String get associatedInvalidUri => 'URI inválido.';

  @override
  String associatedCouldNotOpen(String uri) {
    return 'Não foi possível abrir $uri';
  }

  @override
  String get associatedAdd => 'Adicionar dados associados';

  @override
  String get associatedNoneAdded => 'Nenhum dado associado adicionado';

  @override
  String get associatedEdit => 'Editar dados associados';

  @override
  String get associatedDataType => 'Tipo de dado';

  @override
  String get associatedDataTypeHint => 'Selecione o tipo de dado';

  @override
  String get associatedNameHint => 'p. ex., GenBank ou MorphoSource';

  @override
  String get associatedDescriptionHint => 'Descreva os dados associados';

  @override
  String get associatedResource => 'Recurso';

  @override
  String get associatedNonMediaFiles => 'Arquivos que não são mídia';

  @override
  String get associatedCopyToProject => 'Copiar para o projeto';

  @override
  String get associatedLinkOriginal => 'Vincular original';

  @override
  String get associatedLinkOriginalWarning =>
      'O vínculo deixará de funcionar se o arquivo original for movido ou excluído.';

  @override
  String get associatedSelectDataType => 'Selecione um tipo de dado.';

  @override
  String get associatedEnterValidUri => 'Insira um URI válido.';

  @override
  String get associatedSelectFile => 'Selecione um arquivo.';

  @override
  String get associatedNoIdentifier =>
      'Os dados associados não têm identificador.';

  @override
  String get associatedInfo => 'Informações dos dados associados';

  @override
  String get associatedOriginStoragePath =>
      'Caminho de armazenamento de origem';

  @override
  String get associatedLinkedOriginal => 'Original vinculado';

  @override
  String get associatedProjectCopy => 'Cópia no projeto';

  @override
  String get associatedAvailability => 'Disponibilidade';

  @override
  String get associatedChecking => 'Verificando…';

  @override
  String get legalReadThe => 'Leia os ';

  @override
  String get legalTermsAndConditions => 'Termos e Condições';

  @override
  String get legalAndThe => ' e a ';

  @override
  String get legalPrivacyPolicy => 'Política de Privacidade';

  @override
  String get legalBeforeYouStart =>
      ' antes de começar. Ao usar o NAHPU, você os aceita.';

  @override
  String get legalTermsTile => 'Termos e condições';

  @override
  String get legalPrivacyTile => 'Política de privacidade';

  @override
  String get mapCenterOnCoordinates => 'Centralizar o mapa nas coordenadas';

  @override
  String mapMoreCount(int count) {
    return '+$count mais';
  }

  @override
  String get mapTapToZoomIn => 'Toque para aproximar';

  @override
  String get mapNaturalEarthOffline => 'Natural Earth · offline';

  @override
  String get mapRetryDetailed => 'Tentar o mapa detalhado novamente';

  @override
  String get siteAddCoordinates => 'Adicionar coordenadas';

  @override
  String get siteViewMap => 'Ver mapa';

  @override
  String siteAddSelected(int count) {
    return 'Adicionar $count selecionadas';
  }

  @override
  String get siteNewCoordinate => 'Nova coordenada';

  @override
  String get siteSupportedFiles => 'Arquivos compatíveis:';

  @override
  String get siteSupportedFileTypes =>
      'CSV, TSV, Excel, GeoJSON/JSON, KML, Shapefile compactado e GPX.';

  @override
  String get siteSelectCoordinateFile => 'Selecionar arquivo de coordenadas';

  @override
  String siteRowsSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count linhas ignoradas',
      one: '1 linha ignorada',
    );
    return '$_temp0';
  }

  @override
  String get siteEditColumnMapping => 'Editar mapeamento de colunas';

  @override
  String get siteChooseAnotherFile => 'Escolher outro arquivo';

  @override
  String get siteCoordinateChanged =>
      'A coordenada mudou. Atualize o mapa para ver a prévia.';

  @override
  String get siteEnterValidCoordinate =>
      'Insira uma latitude e longitude WGS84 válidas e atualize o mapa.';

  @override
  String get siteRefreshMap => 'Atualizar mapa';

  @override
  String get siteEditCoordinates => 'Editar coordenadas';

  @override
  String get siteAddName => 'Adicione um nome';

  @override
  String get siteDeviceGps => 'GPS do dispositivo';

  @override
  String get siteDeviceGpsBody =>
      'Use o sensor do dispositivo para preencher as coordenadas';

  @override
  String get siteGetLocation => 'Obter localização';

  @override
  String get siteCoordinateFormat => 'Formato de coordenadas';

  @override
  String get siteDecimalDegrees => 'Graus decimais';

  @override
  String get siteDdm => 'Graus e minutos decimais (GMD)';

  @override
  String get siteDms => 'Graus, minutos e segundos (GMS)';

  @override
  String get siteUtm => 'UTM (WGS84)';

  @override
  String get siteUtmCoordinate => 'Coordenada UTM';

  @override
  String get siteDecimalLatitude => 'Latitude decimal';

  @override
  String get siteAddLatitude => 'Adicione uma latitude';

  @override
  String get siteDecimalLongitude => 'Longitude decimal';

  @override
  String get siteAddLongitude => 'Adicione uma longitude';

  @override
  String get siteAddElevation => 'Adicione uma elevação';

  @override
  String get siteSpecifyDatum => 'Especifique o datum';

  @override
  String get siteAddUncertainty => 'Adicione uma incerteza';

  @override
  String get siteGpsUnit => 'Unidade GPS';

  @override
  String get siteSpecifyGpsUnit => 'Especifique a unidade GPS';

  @override
  String get siteAddNotes => 'Adicione notas (opcional)';

  @override
  String get siteChangeFormatTitle => 'Alterar o formato de coordenadas?';

  @override
  String get siteChangeFormatBody =>
      'Alterar o formato apaga os valores de coordenadas inseridos. Nome, elevação, datum, incerteza, unidade GPS e notas são mantidos.';

  @override
  String get siteClearAndSwitch => 'Limpar e trocar';

  @override
  String siteInvalidVerbatim(String axis, String value) {
    return 'Não foi possível ler esta $axis textual, que pode ter sido alterada fora do NAHPU. Insira-a novamente antes de salvar.\nOriginal: $value';
  }

  @override
  String get siteMissingValue => '(ausente)';

  @override
  String get siteDegree => 'Grau';

  @override
  String get siteMinute => 'Minuto';

  @override
  String get siteSecond => 'Segundo';

  @override
  String get siteManageCoordinates => 'Gerenciar coordenadas';

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
  String get siteFormatShapefile => 'Pacote Shapefile (.zip)';

  @override
  String get siteShowCoordinates => 'Mostrar coordenadas';

  @override
  String get siteAllCoordinates => 'Todas as coordenadas';

  @override
  String siteLoadSitesError(String error) {
    return 'Não foi possível carregar os locais: $error';
  }

  @override
  String siteLoadCoordinatesError(String error) {
    return 'Não foi possível carregar as coordenadas: $error';
  }

  @override
  String siteExportSelectedCoordinates(int count) {
    return 'Exportar coordenadas ($count)';
  }

  @override
  String get siteNoCoordinates => 'Nenhuma coordenada adicionada';

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
    return 'Coordenada sem nome ($id)';
  }

  @override
  String siteCoordinatesNotShown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count coordenadas não são exibidas porque a latitude ou a longitude está ausente ou é inválida.',
      one:
          '1 coordenada não é exibida porque a latitude ou a longitude está ausente ou é inválida.',
    );
    return '$_temp0';
  }

  @override
  String get siteCoordinateActions => 'Ações de coordenadas';

  @override
  String get siteCopy => 'Copiar';

  @override
  String get siteOpenInMap => 'Abrir no mapa';

  @override
  String get siteCoordinateDetails => 'Detalhes da coordenada';

  @override
  String get siteCopiedToClipboard =>
      'Latitude e longitude copiadas para a área de transferência';

  @override
  String get siteNoName => 'Sem nome';

  @override
  String get siteOriginalCoordinate => 'Coordenada original';

  @override
  String get siteOriginalFormat => 'Formato original';

  @override
  String get siteUncertainty => 'Incerteza';

  @override
  String get siteUnnamedCoordinate => 'Coordenada sem nome';

  @override
  String get siteAddCoordinate => 'Adicionar coordenada';

  @override
  String get siteNoId => 'Sem ID';

  @override
  String siteColumnsDetected(int columns, int rows) {
    return 'Foram detectadas $columns colunas e $rows linhas de dados. O NAHPU inferiu as correspondências abaixo. Latitude e longitude são obrigatórias; os demais campos são opcionais.';
  }

  @override
  String siteColumnsDetectedInWorksheet(
    int columns,
    int rows,
    String worksheet,
  ) {
    return 'Foram detectadas $columns colunas e $rows linhas de dados na planilha \"$worksheet\". O NAHPU inferiu as correspondências abaixo. Latitude e longitude são obrigatórias; os demais campos são opcionais.';
  }

  @override
  String get siteNotIncluded => 'Não incluído';

  @override
  String siteHeaderColumn(String header, int index) {
    return '$header (coluna $index)';
  }

  @override
  String get siteReviewCoordinates => 'Revisar coordenadas';

  @override
  String get siteImportFieldNameId => 'Nome / ID';

  @override
  String get siteCopyFromProject => 'Copiar de um projeto';

  @override
  String get siteChooseDataToCopy => 'Escolher dados para copiar';

  @override
  String get siteSelectSourceProject =>
      'Selecione o projeto que contém o local a copiar.';

  @override
  String siteSelectFromProject(String project) {
    return 'Selecione um local de $project.';
  }

  @override
  String get siteNoSitesInProject => 'Nenhum local encontrado neste projeto.';

  @override
  String get siteSelectDataToCopy =>
      'Selecione os dados a copiar para o local vazio.';

  @override
  String get siteNoCopyableData =>
      'O local selecionado não tem dados que possam ser copiados.';

  @override
  String get siteNoDataInSource => 'Sem dados na origem';

  @override
  String get siteMustBeEmptyBody =>
      'O local atual deve estar vazio antes de copiar dados. Primeiro apague as informações do local, as coordenadas, as mídias e os dados vinculados.';

  @override
  String get siteMustBeEmpty => 'O local deve estar vazio';

  @override
  String get siteNeedAnotherProject =>
      'Crie ou importe outro projeto antes de copiar dados do local.';

  @override
  String get siteMultipleProjectsRequired => 'São necessários vários projetos';

  @override
  String siteUnnamedSite(String id) {
    return 'Local sem nome nº $id';
  }

  @override
  String siteGeographySettingsError(String error) {
    return 'Não foi possível carregar as configurações de geografia: $error';
  }

  @override
  String get siteFindLocalityTooltip =>
      'Digite uma localidade e selecione uma salva para preencher todos os campos de geografia';

  @override
  String get siteFindLocality => 'Buscar localidade existente';

  @override
  String get siteFindLocalityHint =>
      'Digite para reutilizar uma localidade salva';

  @override
  String get siteEnterCountry => 'Insira um país';

  @override
  String get siteEnterIslandGroup => 'Insira um grupo de ilhas';

  @override
  String get siteEnterStateProvince => 'Insira um estado/província';

  @override
  String get siteEnterCounty => 'Insira um condado/paróquia/distrito';

  @override
  String get siteEnterMunicipality => 'Insira um município/cidade/vila';

  @override
  String get sitePreciseLocality => 'Localidade precisa';

  @override
  String get sitePreciseLocalityHint =>
      'Insira uma localidade precisa abaixo do nível de município';

  @override
  String get siteRemarksHint =>
      'Insira mais informações sobre o local (opcional)';

  @override
  String get siteHabitatType => 'Tipo de hábitat';

  @override
  String get siteHabitatTypeHint => 'Selecione um tipo de hábitat';

  @override
  String get siteHabitatCondition => 'Condição do hábitat';

  @override
  String get siteHabitatConditionHint =>
      'P. ex., \"Intocado\", \"Perturbado\" etc.';

  @override
  String get siteHabitatDescription => 'Descrição do hábitat';

  @override
  String get siteHabitatDescriptionHint =>
      'Descreva o local, p. ex., \"Um acampamento no meio da floresta.\"';

  @override
  String get siteCanopyCover => 'Cobertura do dossel';

  @override
  String get siteCanopyCoverHint => 'Insira a cobertura do dossel';

  @override
  String get siteCreate => 'Criar local';

  @override
  String get siteActions => 'Ações do local';

  @override
  String get siteDuplicate => 'Duplicar local';

  @override
  String get siteCopyFromProjectMenu => 'Copiar de um projeto…';

  @override
  String get siteExport => 'Exportar local';

  @override
  String get siteImport => 'Importar local';

  @override
  String siteCopiedSummary(
    String fields,
    String coordinates,
    String site,
    String project,
  ) {
    return 'Foram copiados $fields e $coordinates de $site em $project.';
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
  String get siteDeleteTitle => 'Excluir local?';

  @override
  String get siteDeleteBody =>
      'Você excluirá todos os registros deste formulário de local';

  @override
  String get siteDeleteAllTitle => 'Excluir todos os locais?';

  @override
  String get siteDeleteAllBody => 'Você excluirá todos os registros de locais';

  @override
  String get siteDeleteInUse =>
      'Não é possível excluir os locais. Estão sendo usados por outros registros.';

  @override
  String get siteIdentity => 'Identidade do local';

  @override
  String get siteIdHint =>
      'Insira um ID de local (máx. 40 caracteres), p. ex., \"CAMP-01\", \"LINE-1\"';

  @override
  String get siteLeader => 'Responsável pelo local';

  @override
  String get siteType => 'Tipo de local';

  @override
  String get siteTypeHint => 'Escolha um tipo de local';

  @override
  String get siteSearch => 'Pesquisar locais';

  @override
  String get siteRecordTitle => 'Registro de local';

  @override
  String get siteNoneFound => 'Nenhum local encontrado';

  @override
  String get siteCopyFieldSiteLeader => 'Responsável pelo local';

  @override
  String get siteCopyFieldSiteType => 'Tipo de local';

  @override
  String get siteCopyFieldPreciseLocality => 'Localidade precisa';

  @override
  String get siteCopyFieldHabitatType => 'Tipo de hábitat';

  @override
  String get siteCopyFieldHabitatCondition => 'Condição do hábitat';

  @override
  String get siteCopyFieldHabitatDescription => 'Descrição do hábitat';

  @override
  String get siteCopyFieldCanopyCover => 'Cobertura do dossel';

  @override
  String eventEnvironmentLoadError(String error) {
    return 'Não foi possível carregar os dados ambientais: $error';
  }

  @override
  String get eventDayLowest => 'Mínima diurna';

  @override
  String get eventDayHighest => 'Máxima diurna';

  @override
  String get eventNightLowest => 'Mínima noturna';

  @override
  String get eventNightHighest => 'Máxima noturna';

  @override
  String get eventAverage => 'Média';

  @override
  String get eventDewPoint => 'Ponto de orvalho';

  @override
  String get eventEnterLowestTemp => 'Insira a temperatura mínima';

  @override
  String get eventEnterHighestTemp => 'Insira a temperatura máxima';

  @override
  String get eventEnterAverageHumidity => 'Insira a umidade média';

  @override
  String get eventEnterDewPoint => 'Insira o ponto de orvalho';

  @override
  String get eventCloudCover => 'Nebulosidade (oktas)';

  @override
  String get eventCloudCoverHint => 'Selecione a nebulosidade';

  @override
  String get eventCloudCoverHelper =>
      'Uma okta representa um oitavo do céu visível.';

  @override
  String eventInvalidStoredValue(String value) {
    return '$value — Valor salvo inválido';
  }

  @override
  String get eventEnterRainfall => 'Insira a precipitação';

  @override
  String get eventEnterAmbientTemp => 'Insira a temperatura ambiente';

  @override
  String get eventEnterRelativeHumidity => 'Insira a umidade relativa';

  @override
  String get eventEnterWaterTemp => 'Insira a temperatura da água';

  @override
  String get eventEnterPh => 'Insira o pH';

  @override
  String get eventEnterDissolvedOxygen => 'Insira o oxigênio dissolvido';

  @override
  String get eventEnterOxygenSaturation =>
      'Insira a saturação de oxigênio dissolvido';

  @override
  String get eventEnterConductivity => 'Insira a condutividade';

  @override
  String get eventEnterFlowVelocity => 'Insira a velocidade do fluxo';

  @override
  String get eventEnterSunrise => 'Insira a hora do nascer do sol';

  @override
  String get eventEnterSunset => 'Insira a hora do pôr do sol';

  @override
  String get eventMoonPhaseHint => 'Selecione a fase da lua';

  @override
  String eventRecoveryTitle(int count) {
    return 'Alguns valores ambientais salvos precisam de atenção ($count)';
  }

  @override
  String get eventRecoveryBody =>
      'Corrija ou apague os campos destacados. Os demais valores não serão alterados.';

  @override
  String eventSaveValueError(String error) {
    return 'Não foi possível salvar este valor: $error';
  }

  @override
  String get eventEnterValidNumber => 'Insira um número válido.';

  @override
  String eventValueRange(String minimum, String maximum) {
    return 'Insira um valor de $minimum a $maximum';
  }

  @override
  String eventValueMinimum(String minimum) {
    return 'Insira um valor de $minimum ou mais';
  }

  @override
  String get eventOkta0 => '0 — Céu limpo';

  @override
  String get eventOkta1 => '1 — Até 1/8 coberto';

  @override
  String get eventOkta2 => '2 — 2/8 coberto';

  @override
  String get eventOkta3 => '3 — 3/8 coberto';

  @override
  String get eventOkta4 => '4 — Metade coberto';

  @override
  String get eventOkta5 => '5 — 5/8 coberto';

  @override
  String get eventOkta6 => '6 — 6/8 coberto';

  @override
  String get eventOkta7 => '7 — Pelo menos 7/8, sem encobrir totalmente';

  @override
  String get eventOkta8 => '8 — Totalmente encoberto';

  @override
  String get eventOkta9 => '9 — Céu obscurecido';

  @override
  String get eventMoonNew => 'Lua nova';

  @override
  String get eventMoonWaxingCrescent => 'Lua crescente';

  @override
  String get eventMoonFirstQuarter => 'Quarto crescente';

  @override
  String get eventMoonWaxingGibbous => 'Gibosa crescente';

  @override
  String get eventMoonFull => 'Lua cheia';

  @override
  String get eventMoonWaningGibbous => 'Gibosa minguante';

  @override
  String get eventMoonLastQuarter => 'Quarto minguante';

  @override
  String get eventMoonWaningCrescent => 'Lua minguante';

  @override
  String get eventActivity => 'Atividade';

  @override
  String get eventPrimaryActivity => 'Atividade principal';

  @override
  String get eventSelectActivity => 'Selecione uma atividade';

  @override
  String eventActivitiesLoadError(String error) {
    return 'Não foi possível carregar as atividades principais: $error';
  }

  @override
  String get eventActivityNotesHint => 'Insira notas sobre a atividade';

  @override
  String get eventAddCollMethod => 'Adicionar método de coleta';

  @override
  String get eventNoCollMethods => 'Nenhum método de coleta adicionado';

  @override
  String get eventAddCollMethodTitle => 'Adicionar método de coleta';

  @override
  String get eventEditCollMethod => 'Editar método de coleta';

  @override
  String get eventCollMethod => 'Método de coleta';

  @override
  String get eventCountHint =>
      'Quantas unidades desta ferramenta foram usadas (se aplicável)?';

  @override
  String get eventMethodDetails => 'Detalhes do método';

  @override
  String get eventBrandModel => 'Marca e modelo';

  @override
  String get eventBrandModelHint =>
      'Insira a marca e o modelo da ferramenta (se aplicável)';

  @override
  String get eventSizeHint => 'Insira o tamanho da ferramenta (se aplicável)';

  @override
  String get eventToolNotesHint =>
      'Insira notas sobre a ferramenta (se aplicável)';

  @override
  String get eventSelectMethod => 'Selecione um método';

  @override
  String get eventIdentity => 'Identidade do evento';

  @override
  String get eventStartDate => 'Data de início';

  @override
  String get eventEndDate => 'Data de término';

  @override
  String get eventEditId => 'Editar ID do evento';

  @override
  String get eventIdSuffix => 'Sufixo do ID';

  @override
  String get eventIdSuffixHint => 'Insira o sufixo do ID';

  @override
  String get eventIdLabel => 'ID do evento: ';

  @override
  String get eventStartTime => 'Hora de início';

  @override
  String get eventEndTime => 'Hora de término';

  @override
  String get eventCreate => 'Criar evento';

  @override
  String get eventDeleteInUse =>
      'Falha ao excluir os eventos. Eles estão sendo usados por outros registros.';

  @override
  String get eventActions => 'Ações do evento';

  @override
  String get eventDuplicate => 'Duplicar evento';

  @override
  String get eventExport => 'Exportar evento';

  @override
  String get eventImport => 'Importar evento';

  @override
  String get eventDeleteTitle => 'Excluir o evento de coleta?';

  @override
  String get eventDeleteBody =>
      'Você também excluirá os métodos de coleta, o pessoal de coleta, os dados ambientais e as mídias deste evento.';

  @override
  String get eventDeleteAllTitle => 'Excluir todos os eventos de coleta?';

  @override
  String get eventDeleteAllBody =>
      'Excluir todos os eventos de coleta também excluirá do banco de dados todos os métodos de coleta, o pessoal de coleta, os dados ambientais e as mídias associados.';

  @override
  String get eventPersonnel => 'Pessoal do evento';

  @override
  String get eventNoPersonnel => 'Nenhum pessoal adicionado';

  @override
  String get eventUnknownPersonnel => 'Pessoal desconhecido';

  @override
  String get eventEnterRole => 'Insira uma função';

  @override
  String get eventSearch => 'Pesquisar eventos';

  @override
  String get eventRecordTitle => 'Registro de evento de coleta';

  @override
  String get eventNoneFound => 'Nenhum evento de coleta encontrado';

  @override
  String exportPresetsLoadError(String error) {
    return 'Não foi possível carregar as predefinições de exportação: $error';
  }

  @override
  String get exportPreset => 'Predefinição de exportação';

  @override
  String get exportNoPresets =>
      'Nenhuma predefinição de exportação encontrada. Gerencie as predefinições nas configurações para criar uma.';

  @override
  String get exportManagePresetsButton => 'Gerenciar predefinições';

  @override
  String get exportPresetHelper =>
      'O tipo de registro, os cabeçalhos e os mapeamentos de campos são definidos pela predefinição.';

  @override
  String get exportPresetDetails => 'Detalhes da predefinição';

  @override
  String get exportSelectPresetPrompt =>
      'Selecione uma predefinição de exportação para ver os detalhes e a prévia.';

  @override
  String exportPresetName(String name) {
    return 'Predefinição: $name';
  }

  @override
  String exportPresetRecord(String type) {
    return 'Registro: $type';
  }

  @override
  String exportPresetTaxon(String taxon) {
    return 'Táxon: $taxon';
  }

  @override
  String exportPresetHeader(String format) {
    return 'Cabeçalho: $format';
  }

  @override
  String exportSelectedColumns(int count) {
    return 'Colunas selecionadas ($count):';
  }

  @override
  String get exportPreviewTable => 'Prévia da tabela';

  @override
  String get exportNoFieldsMapped => 'Nenhum campo mapeado nesta predefinição.';

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
  String get exportTablePreview => 'Prévia da tabela';

  @override
  String get exportNoRecordsForPreset =>
      'Nenhum registro encontrado para esta predefinição.';

  @override
  String exportShowingRecords(int start, int end, int total) {
    return 'Mostrando $start-$end de $total registros';
  }

  @override
  String exportPageOf(int page, int total) {
    return 'Página $page de $total';
  }

  @override
  String get exportBundling => 'Empacotando registros';

  @override
  String get exportBundlingHint =>
      'O empacotamento grava os registros, copia as mídias, compacta o pacote e depois o verifica. Mantenha o NAHPU aberto.';

  @override
  String get exportCreateBundle => 'Criar pacote';

  @override
  String get exportBundleAnother => 'Empacotar outro';

  @override
  String get exportCancelBundleTitle => 'Cancelar o pacote?';

  @override
  String get exportCancelBundleBody =>
      'O pacote ainda está sendo gravado. Sair agora o cancela e nenhum pacote será salvo.';

  @override
  String get exportKeepBundling => 'Continuar empacotando';

  @override
  String get exportCancelBundle => 'Cancelar pacote';

  @override
  String exportCreatedFile(String file) {
    return '$file criado';
  }

  @override
  String get exportBundleComplete => 'Pacote concluído!';

  @override
  String get exportCompleteData => 'Dados completos do NAHPU';

  @override
  String get exportCompleteDataBody =>
      'Este pacote inclui todas as tabelas do banco de dados do NAHPU, um instantâneo restaurável do projeto, as configurações do usuário, as mídias disponíveis e as fontes personalizadas.';

  @override
  String get exportFrictionless =>
      'A exportação está no formato Frictionless Data.';

  @override
  String get exportRecordedTaxa => 'Táxons registrados';

  @override
  String get exportSelectedTaxa => 'Táxons selecionados';

  @override
  String get exportNoTaxaRecorded =>
      'Ainda não foram registrados táxons de espécimes.';

  @override
  String exportTaxonGroupsIncluded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count grupos taxonômicos registrados serão incluídos.',
      one: '1 grupo taxonômico registrado será incluído.',
    );
    return '$_temp0';
  }

  @override
  String get exportPackageContents => 'Conteúdo do pacote';

  @override
  String get exportSelectTaxonPrompt =>
      'Selecione pelo menos um táxon registrado para listar o conteúdo do pacote.';

  @override
  String get exportPackageContentsBody =>
      'A lista mostra exatamente o que será empacotado. Campos e tabelas opcionais vazios são omitidos.';

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
  String get exportBackingUp => 'Fazendo backup do banco de dados';

  @override
  String get exportBackingUpHint =>
      'Bibliotecas de mídia grandes podem levar vários minutos. Mantenha o NAHPU aberto até terminar.';

  @override
  String get exportSaveBackup => 'Salvar backup';

  @override
  String get exportSaveAnother => 'Salvar outro';

  @override
  String get exportCancelBackupTitle => 'Cancelar o backup?';

  @override
  String get exportCancelBackupBody =>
      'O backup ainda está em andamento. Sair agora o cancela e nenhum arquivo será salvo.';

  @override
  String get exportKeepBackingUp => 'Continuar o backup';

  @override
  String get exportCancelBackup => 'Cancelar backup';

  @override
  String get exportBackupArchive => 'Arquivo de backup';

  @override
  String get exportBackupBody =>
      'Isso cria um backup completo do banco de dados do NAHPU. Para fazer backup de apenas um projeto, use Exportar projeto.';

  @override
  String get exportBackupDetail =>
      'Copia todos os projetos e cada arquivo dos dados do NAHPU, vinculados ou não a um projeto. Execute-o de vez em quando em campo, quando o consumo de bateria não for um problema.';

  @override
  String get exportWillExport => 'Será exportado';

  @override
  String exportUserConfigsExportedTo(String path) {
    return 'Configurações do usuário exportadas para $path';
  }

  @override
  String get exportCustomFieldTemplates => 'Modelos de campos personalizados';

  @override
  String get exportNoCustomFields => 'Nenhum campo personalizado disponível';

  @override
  String get exportNoPrintLayouts =>
      'Ainda não há layouts de impressão. Carregue os layouts padrão ou crie um em Predefinições de documentos.';

  @override
  String get exportEnterFileNameFirst => 'Insira primeiro um nome de arquivo.';

  @override
  String exportShareFailed(String error) {
    return 'Não foi possível compartilhar a exportação: $error';
  }

  @override
  String get exportFormatOptionsTitle => 'Opções de formato';

  @override
  String get exportFormatOptions => 'Opções de formato';

  @override
  String get exportConcatenateMultiEntry =>
      'Concatenar registros de várias entradas';

  @override
  String get exportFieldNamesOnly => 'Apenas nomes de campos nos cabeçalhos';

  @override
  String get exportSelectFieldsTitle => 'Selecionar campos';

  @override
  String get exportClearAll => 'Limpar tudo';

  @override
  String get exportRequired => 'Obrigatório';

  @override
  String get dataTableMoreActions => 'Mais ações';

  @override
  String dataTableNoMatches(String records) {
    return 'Nenhum registro de $records corresponde à pesquisa e aos filtros.';
  }

  @override
  String dataTableNoRecordsYet(String records) {
    return 'Ainda não há $records.';
  }

  @override
  String dataTableNoRecordsForTaxaYet(String records, String taxa) {
    return 'Ainda não há $records de $taxa.';
  }

  @override
  String dataTableProjectNoRecordsForTaxa(String records, String taxa) {
    return 'Este projeto não tem $records de $taxa.';
  }

  @override
  String dataTableProjectNoRecordsYet(String records) {
    return 'Este projeto ainda não tem $records.';
  }

  @override
  String get dataTableSaved => 'Salvo.';

  @override
  String dataTableLoadError(String records) {
    return 'Não foi possível carregar $records.';
  }

  @override
  String get dataTableSomeChangesFailed =>
      'Algumas alterações não puderam ser salvas. Verifique as células marcadas.';

  @override
  String get dataTableNoMoreMatches => 'Não há mais correspondências.';

  @override
  String get dataTableNoEarlierMatches => 'Não há correspondências anteriores.';

  @override
  String get dataTableCellCannotBeReplaced =>
      'Esta célula não pode ser substituída.';

  @override
  String dataTableReadForReplaceError(String error) {
    return 'Não foi possível ler os registros para substituir: $error';
  }

  @override
  String get dataTableNothingToReplace => 'Nada para substituir.';

  @override
  String get dataTableReplaceAllTitle => 'Substituir tudo?';

  @override
  String dataTableReplaceAllBody(String values, String records) {
    return 'Substituir $values em $records?';
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
      'O salvamento automático os grava imediatamente.';

  @override
  String get dataTableWaitForSave => 'Elas aguardam Salvar.';

  @override
  String dataTableReplaced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count valores substituídos.',
      one: '1 valor substituído.',
    );
    return '$_temp0';
  }

  @override
  String dataTableSkippedChoices(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count valores de lista ignorados; escolha-os na lista.',
      one: '1 valor de lista ignorado; escolha-o na lista.',
    );
    return '$_temp0';
  }

  @override
  String dataTableInvalidValues(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count valores não caberiam nos seus campos.',
      one: '1 valor não caberia no seu campo.',
    );
    return '$_temp0';
  }

  @override
  String get dataTablePickDate => 'Escolher uma data';

  @override
  String get dataTablePickTime => 'Escolher uma hora';

  @override
  String get dataTableSaveChangesTitle => 'Salvar as alterações?';

  @override
  String dataTableUnsavedChanges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Você tem $count alterações não salvas nesta tabela.',
      one: 'Você tem 1 alteração não salva nesta tabela.',
    );
    return '$_temp0';
  }

  @override
  String get dataTableFindField => 'Buscar um campo';

  @override
  String dataTableFieldsShown(int count, int total) {
    return '$count de $total campos exibidos';
  }

  @override
  String get dataTableComputedNotSearchable =>
      'Calculado durante a exportação: não pode ser pesquisado nem ordenado';

  @override
  String get dataTableShowAll => 'Mostrar tudo';

  @override
  String get dataTableAutoSaveTooltip =>
      'Salva cada alteração ao confirmá-la. Desfaça com Ctrl+Z ou ⌘Z enquanto esta tabela estiver aberta.';

  @override
  String get dataTableAutoSave => 'Salvamento automático';

  @override
  String get dataTableDiscardChanges => 'Descartar alterações';

  @override
  String get dataTableRetrySave => 'Tentar salvar novamente';

  @override
  String get dataTableEditModeOn =>
      'O modo de edição está ativado (Ctrl+E ou ⌘E)';

  @override
  String get dataTableEditModeOff =>
      'O modo de edição está desativado (Ctrl+E ou ⌘E)';

  @override
  String dataTableCellsNeedAttention(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count células precisam de atenção',
      one: '1 célula precisa de atenção',
    );
    return '$_temp0';
  }

  @override
  String dataTableUnsavedChangeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alterações não salvas',
      one: '1 alteração não salva',
    );
    return '$_temp0';
  }

  @override
  String get dataTableAllChangesSaved => 'Todas as alterações salvas';

  @override
  String dataTableColumnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count colunas',
      one: '1 coluna',
    );
    return '$_temp0';
  }

  @override
  String dataTableExportSummary(String records, String columns) {
    return '$records × $columns, com a pesquisa, os filtros, a ordenação e as colunas visíveis atuais.';
  }

  @override
  String get dataTableColumnHeaders => 'Cabeçalhos de coluna';

  @override
  String get dataTableDwcOnly => 'Apenas colunas mapeadas para Darwin Core';

  @override
  String get dataTableDwcOnlyBody =>
      'Omite as colunas sem um termo Darwin Core. Caso contrário, mantêm sua chave do NAHPU.';

  @override
  String dataTableReadProgress(int count, int total) {
    return 'Lidos $count de $total registros';
  }

  @override
  String dataTableScopeChip(String label, int count) {
    return '$label ($count)';
  }

  @override
  String get dataTableClearFilters => 'Limpar filtros';

  @override
  String dataTableBetweenValues(String low, String high) {
    return '$low e $high';
  }

  @override
  String get dataTableFilterRules => 'Regras de filtro';

  @override
  String get dataTableFilterRulesBody =>
      'Mostra os registros que atendem a todas as regras.';

  @override
  String get dataTableAddRule => 'Adicionar regra';

  @override
  String get dataTableEnterValueEveryRule => 'Insira um valor para cada regra.';

  @override
  String get dataTableEnterDates => 'Insira as datas como AAAA-MM-DD.';

  @override
  String get dataTableEnterTimes => 'Insira as horas como HH:MM.';

  @override
  String get dataTableChooseListed => 'Escolha um dos valores listados.';

  @override
  String get dataTableEnterNumber => 'Insira um número.';

  @override
  String get dataTableComputedNotFilterable =>
      'Calculado durante a exportação; não pode ser filtrado';

  @override
  String get dataTableRemoveRule => 'Remover regra';

  @override
  String get dataTableReplacingNeedsEditMode =>
      'Substituir requer o modo de edição.';

  @override
  String get dataTableMatchCase => 'Diferenciar maiúsculas';

  @override
  String get dataTableWholeCell => 'Célula inteira';

  @override
  String get dataTablePreviousMatch => 'Correspondência anterior';

  @override
  String get dataTableNextMatch => 'Próxima correspondência';

  @override
  String get dataTableTurnOnEditMode => 'Ativar o modo de edição';

  @override
  String get dataTableReplaceAll => 'Substituir tudo';

  @override
  String get dataTableNoMatchesShort => 'Nenhuma correspondência';

  @override
  String dataTableFoundCount(int count) {
    return '$count encontrados';
  }

  @override
  String dataTableMatchOf(int current, int total) {
    return '$current de $total';
  }

  @override
  String get dataTableAllVisibleColumns => 'Todas as colunas visíveis';

  @override
  String dataTableColumnReadOnly(String column) {
    return '$column é somente leitura aqui.';
  }

  @override
  String dataTableSkippedOffList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count valores que não estão nas listas foram ignorados.',
      one: '1 valor que não está na lista foi ignorado.',
    );
    return '$_temp0';
  }

  @override
  String get dataTableChangeFishTypeTitle =>
      'Alterar o tipo de registro de peixe?';

  @override
  String dataTableSexClears(String fields) {
    return 'Isso apaga $fields, que não se aplicam mais ao novo sexo.';
  }

  @override
  String get dataTableFishTypeChangeBody =>
      'Alternar entre indivíduo e lote altera as medidas que se aplicam.';

  @override
  String dataTableSkippedReadOnly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count células somente leitura ou vinculadas foram ignoradas.',
      one: '1 célula somente leitura ou vinculada foi ignorada.',
    );
    return '$_temp0';
  }

  @override
  String dataTableCopiedCells(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count células copiadas.',
      one: '1 célula copiada.',
    );
    return '$_temp0';
  }

  @override
  String get dataTableSwitchToEditToPaste =>
      'Mude para o modo de edição para colar.';

  @override
  String dataTablePastedSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Colado; $count células somente leitura ou vinculadas foram ignoradas.',
      one: 'Colado; 1 célula somente leitura ou vinculada foi ignorada.',
    );
    return '$_temp0';
  }

  @override
  String get dataTablePastedCutOff => 'Colado; cortado na borda da página.';

  @override
  String dataTablePastedSkippedAndCutOff(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Colado; $count células somente leitura ou vinculadas foram ignoradas e cortado na borda da página.',
      one:
          'Colado; 1 célula somente leitura ou vinculada foi ignorada e cortado na borda da página.',
    );
    return '$_temp0';
  }

  @override
  String get dataTableComputedField =>
      'Calculado durante a exportação: não pode ser pesquisado, ordenado nem filtrado.';

  @override
  String get dataTableLinkedDataHint =>
      'Dados vinculados: clique duas vezes ou pressione F2 para editar.';

  @override
  String get dataTableReadOnlyHere => 'Somente leitura aqui.';

  @override
  String get dataTableOpenForm => 'Abrir formulário';

  @override
  String dataTableLinkCurrent(String value) {
    return 'Agora: $value.';
  }

  @override
  String get dataTableLoadChoicesError =>
      'Não foi possível carregar as opções.';

  @override
  String get dataTableLinkCatalogerNote =>
      'O número de campo acompanha o novo catalogador. O determinador e o preparador também mudam quando eram o catalogador anterior.';

  @override
  String get dataTableLinkEventNote =>
      'O método de coleta e o pessoal são apagados, e a coordenada acompanha o local do novo evento.';

  @override
  String get dataTableLinkTaxonNote =>
      'Ordem, família, gênero e epíteto vêm do táxon escolhido.';

  @override
  String dataTableSaveError(String error) {
    return 'Não foi possível salvar: $error';
  }

  @override
  String get dataTableNothingMatches => 'Nada corresponde.';

  @override
  String dataTableNotLinked(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'site': 'Este registro ainda não está vinculado a um local.',
      'other': 'Este registro ainda não está vinculado a um evento.',
    });
    return '$_temp0';
  }

  @override
  String dataTableLinkedLoadError(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'site': 'Não foi possível carregar o local.',
      'other': 'Não foi possível carregar o evento.',
    });
    return '$_temp0';
  }

  @override
  String dataTableLinkShared(String noun, int count) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'site':
          'As alterações se aplicam a todos os registros vinculados a este local ($count).',
      'other':
          'As alterações se aplicam a todos os registros vinculados a este evento ($count).',
    });
    return '$_temp0';
  }

  @override
  String get dataTableSomeChangesNotSaved =>
      'Algumas alterações não puderam ser salvas.';

  @override
  String get dataTablePageRangeEmpty => '0 de 0';

  @override
  String dataTablePageRange(String first, String last, String total) {
    return '$first–$last de $total';
  }

  @override
  String get dataTableRowsPerPage => 'Linhas por página';

  @override
  String get dataTableFirstPage => 'Primeira página';

  @override
  String get dataTablePreviousPage => 'Página anterior';

  @override
  String get dataTableNextPage => 'Próxima página';

  @override
  String get dataTableLastPage => 'Última página';

  @override
  String dataTableSearchIn(String target) {
    return 'Pesquisar $target';
  }

  @override
  String get dataTableRefresh => 'Atualizar';

  @override
  String get dataTableAddFieldRules => 'Adicionar regras de campo';

  @override
  String get dataTableEditFieldRules => 'Editar regras de campo';

  @override
  String get dataTableFilters => 'Filtros';

  @override
  String get dataTableAllVisibleFields => 'Todos os campos visíveis';

  @override
  String get dataTableSearchingAllFields =>
      'Pesquisando todos os campos visíveis';

  @override
  String dataTableSearchingField(String field) {
    return 'Pesquisando $field';
  }

  @override
  String get dataTableFilterOpIs => 'é';

  @override
  String get dataTableFilterOpContains => 'contém';

  @override
  String get dataTableFilterOpStartsWith => 'começa com';

  @override
  String get dataTableFilterOpGreaterThan => 'maior que';

  @override
  String get dataTableFilterOpLessThan => 'menor que';

  @override
  String get dataTableFilterOpBetween => 'entre';

  @override
  String get dataTableFilterOpIsEmpty => 'está vazio';

  @override
  String get dataTableFilterOpIsNotEmpty => 'não está vazio';

  @override
  String get dataTableQuickMissingTaxon => 'Sem táxon';

  @override
  String get dataTableQuickNoFieldNumber => 'Sem número de campo';

  @override
  String get dataTableQuickNoEvent => 'Sem evento';

  @override
  String get dataTableQuickHasParts => 'Tem partes';

  @override
  String get dataTableQuickHasMedia => 'Tem mídia';

  @override
  String get dataTableQuickNoTissueId => 'Sem ID de tecido';

  @override
  String get dataTableQuickNoParasiteId => 'Sem ID de parasita';

  @override
  String get dataTableQuickNoCoordinates => 'Sem coordenadas';

  @override
  String get dataTableQuickNoLocality => 'Sem localidade';

  @override
  String get dataTableQuickNoSpecimens => 'Sem espécimes';

  @override
  String get dataTableQuickNoEndDate => 'Sem data de término';

  @override
  String get dataTableQuickNoSite => 'Sem local';

  @override
  String dataTableProjectScopeOne(String name) {
    return 'Projeto: $name';
  }

  @override
  String dataTableProjectScopeTwo(String first, String second) {
    return 'Projetos: $first, $second';
  }

  @override
  String dataTableProjectScopeMany(int count) {
    return '$count projetos';
  }

  @override
  String get siteImportFieldGpsUnit => 'Unidade GPS';

  @override
  String get projectTissueCustomLabels => 'Personalizar rótulos das células';

  @override
  String get projectTissueBoxSeparator => 'Separador da caixa';

  @override
  String get projectTissueRowColumnSeparator => 'Separador linha–coluna';

  @override
  String get projectTissueZeroPad => 'Preencher números com zeros';

  @override
  String projectTissueLabelExample(String example) {
    return 'Exemplo: $example';
  }
}
