import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/templates/template_fonts.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Sample texts used wherever a font is previewed.
const String kFontPreviewSampleA =
    'Durians are the king of fruits, and mangosteen is the queen of fruit. '
    'Apparently, it is never a good idea to eat them at the same time. I '
    'definitely should not have eaten 12 durians and a dozen mangosteens in '
    'one sitting out in the fields.';

const String kFontPreviewSampleB =
    'There is only one place in northern Sumatra where orangutans, rhinos, '
    'elephants, and tigers share the same natural habitat. Guess the name of '
    'the National Park?';

const String kFontPreviewSampleC =
    'Feeling creative or inspired? Send the maintainer your thoughts, an '
    'interesting biodiversity fact, a field joke, or a short story worth '
    'reading, or post it at github.com/nahpu/nahpu/issues, and it may show up '
    'right here. A font choice should not be decided by a quick brown fox.';

const List<String> kFontPreviewSamples = [
  kFontPreviewSampleA,
  kFontPreviewSampleB,
  kFontPreviewSampleC,
];

/// Renders the preview samples in [family].
///
/// When [showStyles] is set, each sample is repeated in bold and italic so a
/// family that is missing those files is visible at a glance.
class FontSamplePreview extends StatelessWidget {
  const FontSamplePreview({
    super.key,
    required this.family,
    this.fontSize = 16,
    this.showStyles = false,
    this.samples = kFontPreviewSamples,
  });

  final String family;
  final double fontSize;
  final bool showStyles;
  final List<String> samples;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < samples.length; index++) ...[
          if (index > 0) ...[
            SizedBox(height: NahpuSpacing.xl),
            Divider(color: scheme.outlineVariant),
            SizedBox(height: NahpuSpacing.xl),
          ],
          _sample(samples[index]),
          if (showStyles) ...[
            SizedBox(height: NahpuSpacing.lg),
            _sample(
              samples[index],
              weight: FontWeight.bold,
              label: 'Bold',
              context: context,
            ),
            SizedBox(height: NahpuSpacing.lg),
            _sample(
              samples[index],
              style: FontStyle.italic,
              label: 'Italic',
              context: context,
            ),
          ],
        ],
      ],
    );
  }

  Widget _sample(
    String text, {
    FontWeight weight = FontWeight.normal,
    FontStyle style = FontStyle.normal,
    String? label,
    BuildContext? context,
  }) {
    final sample = Text(
      text,
      style: customTemplateCanvasTextStyle(
        fontFamilyRaw: family,
        fontSize: fontSize,
        fontWeight: weight,
        fontStyle: style,
      ),
    );
    if (label == null || context == null) return sample;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        SizedBox(height: NahpuSpacing.xs),
        sample,
      ],
    );
  }
}
