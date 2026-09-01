import 'package:nahpu/screens/templates/template_fonts.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/templates/font_registry.dart';

/// Finds and repairs font families that an incoming template references but
/// this installation cannot render.
///
/// Templates travel between installations as JSON that names fonts by family.
/// A template built elsewhere can name a font the receiving installation has
/// never had, so imports resolve those names before anything is stored.
class TemplateFontResolutionService {
  const TemplateFontResolutionService();

  /// Families referenced by [templates] that [registry] cannot render.
  Set<String> missingFamilies(
    Iterable<Template> templates,
    FontRegistry registry,
  ) {
    final referenced = <String>{};
    for (final template in templates) {
      referenced.addAll(collectTemplateTextFontKeys(template));
    }
    return registry.missingFrom(
      referenced.map(
        (family) => normalizeTemplateFontFamily(family, registry: registry),
      ),
    );
  }

  /// Rewrites every text element whose family appears in [substitutions].
  ///
  /// Keys are matched case-insensitively and ignoring spacing, so a legacy
  /// compact key resolves to the same substitution as its spelled-out name.
  Template applySubstitutions(
    Template template,
    Map<String, String> substitutions,
  ) {
    if (substitutions.isEmpty) return template;
    final lookup = {
      for (final entry in substitutions.entries) _key(entry.key): entry.value,
    };
    return template.copyWith(
      page1: _resolvePage(template.page1, lookup),
      page2: _resolvePage(template.page2, lookup),
    );
  }

  List<Template> applySubstitutionsToAll(
    Iterable<Template> templates,
    Map<String, String> substitutions,
  ) => [
    for (final template in templates)
      applySubstitutions(template, substitutions),
  ];

  TemplatePage _resolvePage(TemplatePage page, Map<String, String> lookup) {
    var changed = false;
    final texts = <CustomTextElement>[];
    for (final text in page.customTexts) {
      final replacement = lookup[_key(text.fontFamily)];
      if (replacement == null) {
        texts.add(text);
        continue;
      }
      texts.add(text.copyWith(fontFamily: replacement));
      changed = true;
    }
    return changed ? page.copyWith(customTexts: texts) : page;
  }

  String _key(String family) => family.trim().replaceAll(' ', '').toLowerCase();
}
