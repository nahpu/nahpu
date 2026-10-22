/// A group of related project tools. The tool dock draws a divider wherever
/// two neighboring tools belong to different categories.
enum ProjectToolCategory {
  utilities('Utilities'),
  project('Project'),
  records('Records'),
  database('Database'),
  configuration('Configuration');

  const ProjectToolCategory(this.label);

  final String label;
}

/// A tool the project dashboard dock can launch.
///
/// Covers the dock's own utilities and every project menu drawer item except
/// closing and deleting the project. Declaration order is the dock order,
/// grouped by [category], so the dividers follow the drawer's sections.
enum ProjectTool {
  dataTable(
    ProjectToolCategory.utilities,
    'Data table',
    'Browse, sort, and search project records',
  ),
  templates(
    ProjectToolCategory.utilities,
    'Templates',
    'Create and edit document templates',
  ),
  mergeProject(
    ProjectToolCategory.project,
    'Merge project',
    'Merge another project into this one',
  ),
  exportProject(
    ProjectToolCategory.project,
    'Export project',
    'Export this project for transfer',
  ),
  batchImport(
    ProjectToolCategory.records,
    'Batch import',
    'Import or update records from a spreadsheet',
  ),
  bundleRecords(
    ProjectToolCategory.records,
    'Bundle records',
    'Bundle records with their media',
  ),
  exportRecords(
    ProjectToolCategory.records,
    'Export records',
    'Export records as tabular data',
  ),
  exportDocuments(
    ProjectToolCategory.records,
    'Export documents',
    'Export records as documents',
  ),
  backupDatabase(
    ProjectToolCategory.database,
    'Backup database',
    'Back up the application database',
  ),
  settings(
    ProjectToolCategory.configuration,
    'Settings',
    'Open application settings',
  ),
  exportUserConfigs(
    ProjectToolCategory.configuration,
    'Export configs',
    'Export user configs',
  ),
  importUserConfigs(
    ProjectToolCategory.configuration,
    'Import configs',
    'Import user configs',
  );

  const ProjectTool(this.category, this.label, this.description);

  final ProjectToolCategory category;
  final String label;
  final String description;

  /// The tools shown before the user edits the list.
  static const List<ProjectTool> defaults = [
    ProjectTool.dataTable,
    ProjectTool.templates,
  ];

  /// Reads a saved tool list. Null means never edited, so [defaults] apply.
  /// Unknown names, such as tools removed in a later version, are skipped.
  static List<ProjectTool> decode(List<String>? names) {
    if (names == null) {
      return defaults;
    }
    final saved = names.toSet();
    return ProjectTool.values.where((e) => saved.contains(e.name)).toList();
  }

  static List<String> encode(Iterable<ProjectTool> tools) {
    return sortTools(tools).map((e) => e.name).toList();
  }

  /// Puts [tools] in dock order without duplicates.
  static List<ProjectTool> sortTools(Iterable<ProjectTool> tools) {
    final selected = tools.toSet();
    return ProjectTool.values.where(selected.contains).toList();
  }
}
