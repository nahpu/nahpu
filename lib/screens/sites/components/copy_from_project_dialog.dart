import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/project_queries.dart';
import 'package:nahpu/services/sites/site_copy_services.dart';
import 'package:nahpu/services/types/sites.dart';

Future<SiteCopyResult?> showCopyFromProjectDialog({
  required BuildContext context,
  required int targetSiteId,
}) {
  return showDialog<SiteCopyResult>(
    context: context,
    builder: (context) => SiteCopyDialog(targetSiteId: targetSiteId),
  );
}

class SiteCopyDialog extends ConsumerStatefulWidget {
  const SiteCopyDialog({super.key, required this.targetSiteId});

  final int targetSiteId;

  @override
  ConsumerState<SiteCopyDialog> createState() => _SiteCopyDialogState();
}

class _SiteCopyDialogState extends ConsumerState<SiteCopyDialog> {
  int _step = 0;
  bool _loading = true;
  bool _saving = false;
  String? _blockingMessage;
  String? _blockingTitle;
  List<ProjectSummary> _projects = [];
  ProjectSummary? _project;
  List<SiteData> _sites = [];
  SiteData? _site;
  SiteCopySource? _source;
  Set<SiteCopyField> _selectedFields = {};

  SiteCopyServices get _service => SiteCopyServices(ref: ref);

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_title),
      content: SizedBox(
        width: 520,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 560),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _blockingMessage != null
              ? _BlockingContent(message: _blockingMessage!)
              : _stepContent,
        ),
      ),
      actions: _blockingMessage != null
          ? [
              TextButton(
                onPressed: _saving ? null : () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ]
          : _loading
          ? null
          : _actions,
    );
  }

  String get _title =>
      _blockingTitle ??
      switch (_step) {
        0 => 'Copy from project',
        1 => 'Choose a site',
        _ => 'Choose data to copy',
      };

  Widget get _stepContent {
    if (_step == 0) return _projectContent;
    if (_step == 1) return _siteContent;
    return _fieldContent;
  }

  List<Widget> get _actions {
    final canContinue = _step == 0
        ? _project != null
        : _step == 1
        ? _site != null
        : _selectedFields.isNotEmpty;
    return [
      if (_step > 0)
        TextButton(
          onPressed: _saving ? null : _back,
          child: const Text('Back'),
        ),
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _saving || !canContinue ? null : _continue,
        child: _saving
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(_step == 2 ? 'Copy' : 'Continue'),
      ),
    ];
  }

  Widget get _projectContent {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Select the project that contains the site to copy.'),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            children: [
              RadioGroup<String>(
                groupValue: _project?.uuid,
                onChanged: (value) {
                  if (_saving || value == null) return;
                  setState(
                    () => _project = _projects.firstWhere(
                      (project) => project.uuid == value,
                    ),
                  );
                },
                child: Column(
                  children: [
                    for (final project in _projects)
                      RadioListTile<String>(
                        value: project.uuid,
                        contentPadding: EdgeInsets.zero,
                        title: Text(project.name),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget get _siteContent {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Select a site from ${_project!.name}.'),
        const SizedBox(height: 12),
        Expanded(
          child: _sites.isEmpty
              ? const Center(child: Text('No sites found in this project.'))
              : ListView(
                  children: [
                    for (final site in _sites)
                      _CopySelectionTile(
                        key: ValueKey('copy-source-site-tile-${site.id}'),
                        selected: _site?.id == site.id,
                        title: _siteLabel(site),
                        subtitle: _siteSubtitle(site),
                        onChanged: (_) => setState(() => _site = site),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget get _fieldContent {
    final source = _source!;
    final fields = SiteCopyField.values;
    final availableFields = fields
        .where((field) => _hasSourceValue(field, source))
        .toSet();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('${source.project.name} · ${source.siteLabel}'),
        const SizedBox(height: 4),
        const Text('Select the data to copy into the empty site.'),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton(
              onPressed: availableFields.isEmpty
                  ? null
                  : () => setState(() => _selectedFields = availableFields),
              child: const Text('Select all'),
            ),
            TextButton(
              onPressed: _selectedFields.isEmpty
                  ? null
                  : () => setState(() => _selectedFields.clear()),
              child: const Text('Clear all'),
            ),
          ],
        ),
        Expanded(
          child: availableFields.isEmpty
              ? const Center(
                  child: Text('The selected site has no copyable data.'),
                )
              : ListView(
                  children: [
                    for (final field in fields)
                      _CopySelectionTile(
                        key: ValueKey('copy-field-tile-${field.name}'),
                        selected: _selectedFields.contains(field),
                        title: field.label,
                        subtitle: _hasSourceValue(field, source)
                            ? _fieldSubtitle(field, source)
                            : 'No data in source',
                        enabled: availableFields.contains(field),
                        onChanged: (value) => setState(() {
                          if (value) {
                            _selectedFields.add(field);
                          } else {
                            _selectedFields.remove(field);
                          }
                        }),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _loadProjects() async {
    try {
      final targetEmpty = await _service.isTargetEmpty(widget.targetSiteId);
      if (!targetEmpty) {
        _setBlocking(
          'The current site must be empty before copying data. Clear its site information, coordinates, media, and linked data first.',
          title: 'Site must be empty',
        );
        return;
      }
      final projects = await _service.getSourceProjects();
      if (!mounted) return;
      setState(() {
        _projects = projects;
        _loading = false;
        if (projects.isEmpty) {
          _blockingMessage =
              'Create or import another project before copying site data.';
          _blockingTitle = 'Multiple projects required';
        }
      });
    } catch (error) {
      _setBlocking(error.toString());
    }
  }

  void _setBlocking(String message, {String? title}) {
    if (!mounted) return;
    setState(() {
      _loading = false;
      _blockingMessage = message;
      _blockingTitle = title;
    });
  }

  Future<void> _continue() async {
    if (_step == 0) {
      setState(() => _loading = true);
      try {
        final sites = await _service.getSourceSites(_project!.uuid);
        if (!mounted) return;
        setState(() {
          _sites = sites;
          _loading = false;
          _step = 1;
        });
      } catch (error) {
        _setBlocking(error.toString());
      }
      return;
    }
    if (_step == 1) {
      setState(() => _loading = true);
      try {
        final source = await _service.loadSource(
          projectUuid: _project!.uuid,
          siteId: _site!.id,
        );
        if (!mounted) return;
        final available = SiteCopyField.values
            .where((field) => _hasSourceValue(field, source))
            .toSet();
        setState(() {
          _source = source;
          _selectedFields = available;
          _loading = false;
          _step = 2;
        });
      } catch (error) {
        _setBlocking(error.toString());
      }
      return;
    }
    await _copy();
  }

  Future<void> _copy() async {
    setState(() => _saving = true);
    try {
      final result = await _service.copy(
        SiteCopyRequest(
          targetSiteId: widget.targetSiteId,
          sourceProjectUuid: _source!.project.uuid,
          sourceSiteId: _source!.site.id,
          fields: _selectedFields,
        ),
      );
      if (!mounted) return;
      Navigator.pop(context, result);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  void _back() {
    setState(() {
      _loading = false;
      if (_step == 2) {
        _step = 1;
      } else {
        _step = 0;
      }
    });
  }

  bool _hasSourceValue(SiteCopyField field, SiteCopySource source) {
    final value = switch (field) {
      SiteCopyField.siteId => source.site.siteID,
      SiteCopyField.leadStaff => source.site.leadStaffId,
      SiteCopyField.siteType => source.site.siteType,
      SiteCopyField.country => source.site.country,
      SiteCopyField.stateProvince => source.site.stateProvince,
      SiteCopyField.county => source.site.county,
      SiteCopyField.municipality => source.site.municipality,
      SiteCopyField.locality => source.site.locality,
      SiteCopyField.remark => source.site.remark,
      SiteCopyField.habitatType => source.site.habitatType,
      SiteCopyField.habitatCondition => source.site.habitatCondition,
      SiteCopyField.habitatDescription => source.site.habitatDescription,
      SiteCopyField.coordinates => source.coordinates.isNotEmpty ? 'yes' : null,
    };
    return value?.trim().isNotEmpty == true;
  }

  String _fieldSubtitle(SiteCopyField field, SiteCopySource source) {
    if (field == SiteCopyField.coordinates) {
      final count = source.coordinates.length;
      return '$count ${count == 1 ? 'coordinate' : 'coordinates'}';
    }
    if (field == SiteCopyField.leadStaff) {
      return source.leaderName ?? source.site.leadStaffId ?? '';
    }
    final value = switch (field) {
      SiteCopyField.siteId => source.site.siteID,
      SiteCopyField.siteType => source.site.siteType,
      SiteCopyField.country => source.site.country,
      SiteCopyField.stateProvince => source.site.stateProvince,
      SiteCopyField.county => source.site.county,
      SiteCopyField.municipality => source.site.municipality,
      SiteCopyField.locality => source.site.locality,
      SiteCopyField.remark => source.site.remark,
      SiteCopyField.habitatType => source.site.habitatType,
      SiteCopyField.habitatCondition => source.site.habitatCondition,
      SiteCopyField.habitatDescription => source.site.habitatDescription,
      SiteCopyField.leadStaff => source.site.leadStaffId,
      SiteCopyField.coordinates => null,
    };
    return value ?? '';
  }

  String _siteLabel(SiteData site) {
    final value = site.siteID?.trim();
    return value == null || value.isEmpty ? 'Unnamed site #${site.id}' : value;
  }

  String _siteSubtitle(SiteData site) {
    return [
      site.siteType,
      site.locality,
    ].where((value) => value?.trim().isNotEmpty == true).join(' · ');
  }
}

class _BlockingContent extends StatelessWidget {
  const _BlockingContent({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message));
  }
}

class _CopySelectionTile extends StatelessWidget {
  const _CopySelectionTile({
    super.key,
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onChanged,
    this.enabled = true,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Opacity(
          opacity: selected ? 1 : 0.55,
          child: ListTile(
            leading: Checkbox(
              value: enabled && selected,
              onChanged: enabled ? (value) => onChanged(value ?? false) : null,
            ),
            title: Text(title),
            subtitle: subtitle.isEmpty ? null : Text(subtitle),
            onTap: enabled ? () => onChanged(!selected) : null,
          ),
        ),
      ),
    );
  }
}
