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
  String settingsMapKindUnavailableOnLinux(String kind) {
    return '$kind · indisponível no Linux';
  }

  @override
  String get settingsMapConfigureLayer => 'Configurar camada';

  @override
  String get settingsMapShowLayer => 'Mostrar camada';

  @override
  String get settingsMapLayerUnavailableOnLinux =>
      'Esta camada está indisponível no Linux';

  @override
  String get settingsMapLayerTypeUnavailableOnLinux =>
      'Este tipo de camada está indisponível no Linux.';

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
  String get settingsMapSupportedFormatsLinux =>
      'No Linux, aceita GeoJSON, Shapefiles WGS84 compactados em ZIP e PMTiles raster.';

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
}
