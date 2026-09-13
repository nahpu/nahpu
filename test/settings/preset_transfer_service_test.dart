import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/settings/preset_transfer_service.dart';
import 'package:nahpu/services/templates/document_layout_service.dart';
import 'package:nahpu/services/templates/template_service.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;
import 'package:path/path.dart' as p;

void main() {
  const service = PresetTransferService();
  final cover = DefaultTemplate.defaultTemplate('Cover');
  final site = DefaultTemplate.defaultTemplate('Site');
  final booklet = _layout('Booklet', ['Cover', 'Site', 'Cover']);

  group('layout files', () {
    test('carry the linked templates and read back', () {
      final raw = service.encodeLayouts([booklet], templates: [cover, site]);
      final decoded = jsonDecode(raw) as Map<String, dynamic>;

      expect(decoded[PresetTransferService.documentPresetsKey], 1);
      final bundle = service.decodeLayouts(raw);
      expect(bundle.layouts.single.name, 'Booklet');
      expect(bundle.layouts.single.blocks.map((b) => b.templateName), [
        'Cover',
        'Site',
        'Cover',
      ]);
      expect(bundle.templates.map((template) => template.name), [
        'Cover',
        'Site',
      ]);
    });

    test('leave templates out when none are included', () {
      final raw = service.encodeLayouts([booklet]);

      expect(jsonDecode(raw) as Map, isNot(contains('template_presets')));
      expect(service.decodeLayouts(raw).templates, isEmpty);
    });

    test('older name-keyed and single-layout files still read', () {
      final keyed = service.decodeLayouts(
        jsonEncode({'Old booklet': booklet.toJson()}),
      );
      expect(keyed.layouts.single.name, 'Old booklet');
      expect(keyed.templates, isEmpty);

      final single = service.decodeLayouts(jsonEncode(booklet.toJson()));
      expect(single.layouts.single.name, 'Booklet');
    });

    test('newer file versions are rejected', () {
      expect(
        () => service.decodeLayouts(
          jsonEncode({
            PresetTransferService.documentPresetsKey: 99,
            'document_layouts': {'Booklet': booklet.toJson()},
          }),
        ),
        throwsFormatException,
      );
    });
  });

  test('linked template names keep first-use order without repeats', () {
    expect(
      PresetTransferService.linkedTemplateNames([
        booklet,
        _layout('Tags', ['Skull tag', 'Site']),
      ]),
      ['Cover', 'Site', 'Skull tag'],
    );
  });

  test('file stems keep only safe characters', () {
    expect(
      PresetTransferService.safeFileStem('preset_Mammal field booklet'),
      'preset_Mammal-field-booklet',
    );
    expect(PresetTransferService.safeFileStem('export.json'), 'export');
    expect(PresetTransferService.safeFileStem(' !! '), 'preset');
  });

  group('saving', () {
    late Directory temp;

    setUp(() async {
      temp = await Directory.systemTemp.createTemp('nahpu-preset-transfer-');
    });

    tearDown(() async {
      if (await temp.exists()) await temp.delete(recursive: true);
    });

    test('writes JSON without replacing an existing file', () async {
      final first = await service.save(
        content: '{}',
        fileStem: 'my presets',
        directory: temp,
      );
      final second = await service.save(
        content: '{"again":true}',
        fileStem: 'my presets',
        directory: temp,
      );

      expect(p.basename(first.path), 'my-presets.json');
      expect(p.basename(second.path), 'my-presets(1).json');
      expect(await first.readAsString(), '{}');
    });
  });

  test('importing reuses identical templates and renames clashes', () async {
    final changedSite = Template.fromJson({...site.toJson(), 'widthMm': 99.0});
    final events = DefaultTemplate.defaultTemplate('Events');
    final templates = _FakeTemplateService({'Cover': cover, 'Site': site});
    final layouts = _FakeLayoutService({'Booklet': _layout('Booklet', [])});
    final importer = PresetTransferService(
      layoutService: layouts,
      templateService: templates,
    );
    final bundle = DocumentPresetBundle(
      layouts: [
        _layout('Booklet', ['Cover', 'Site', 'Events']),
      ],
      templates: [cover, changedSite, events],
    );

    final result = await importer.importLayouts(
      bundle,
      templates: bundle.templates,
    );

    expect(result.renamedTemplates, {'Site': 'Site_1'});
    expect(result.addedTemplateCount, 2);
    expect(templates.saved.keys, containsAll(['Site_1', 'Events']));
    expect(templates.saved['Site'], same(site));
    expect(result.layoutNames, ['Booklet_1']);
    expect(
      layouts.saved['Booklet_1']!.blocks.map((block) => block.templateName),
      ['Cover', 'Site_1', 'Events'],
    );
    expect(layouts.current, 'Booklet_1');
    expect(result.message, 'Imported 1 preset and 2 templates');
  });
}

rust_config.DocumentLayoutPreset _layout(String name, List<String> templates) {
  return rust_config.DocumentLayoutPreset(
    name: name,
    layoutType: 'WholePage',
    pageSizeKey: 'Letter',
    pageOrientation: 'portrait',
    customPageWidthMm: null,
    customPageHeightMm: null,
    pagePadTopMm: 8,
    pagePadLeftMm: 8,
    pagePadRightMm: 8,
    pagePadBottomMm: 8,
    blocks: [
      for (final template in templates)
        rust_config.DocumentLayoutBlock(
          templateName: template,
          templateCount: 1,
          rows: 1,
          cols: 1,
          templatePadTopMm: 0,
          templatePadLeftMm: 0,
          templatePadRightMm: 0,
          templatePadBottomMm: 0,
          pageBreakAfter: false,
          sortField: null,
          sortDirection: rust_config.DocumentSortDirection.ascending,
        ),
    ],
    fillPage: false,
    multiBlockMode: 'Continuous',
  );
}

class _FakeTemplateService extends TemplateService {
  _FakeTemplateService(this.saved);

  final Map<String, Template> saved;

  @override
  Future<List<String>> listTemplateNames() async => saved.keys.toList();

  @override
  Future<Template?> getTemplate(String name) async => saved[name];

  @override
  Future<void> updateTemplate(Template template) async {
    saved[template.name] = template;
  }
}

class _FakeLayoutService extends DocumentLayoutService {
  _FakeLayoutService(this.saved);

  final Map<String, rust_config.DocumentLayoutPreset> saved;
  String? current;

  @override
  Future<List<rust_config.DocumentLayoutStatus>> listLayoutStatuses() async {
    return [
      for (final name in saved.keys)
        rust_config.DocumentLayoutStatus(name: name, isCompatible: true),
    ];
  }

  @override
  Future<void> saveLayout(rust_config.DocumentLayoutPreset layout) async {
    saved[layout.name] = layout;
  }

  @override
  Future<void> setCurrentLayoutName(String name) async {
    current = name;
  }
}
