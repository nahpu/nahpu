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
}
