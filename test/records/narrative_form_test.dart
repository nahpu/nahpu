import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/narrative/narrative_form.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/styles/themes.dart';

void main() {
  for (final theme in [NahpuTheme.lightTheme(), NahpuTheme.darkTheme()]) {
    testWidgets(
      'narrative Markdown preview uses ${theme.brightness.name} theme colors',
      (tester) async {
        final narrativeCtr = NarrativeFormCtrModel.empty();
        narrativeCtr.narrativeCtr.text =
            '# Heading\n\nBody **bold** _emphasis_ ~~deleted~~\n\n`code`';

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: theme,
              home: Scaffold(
                body: NarrativeText(narrativeId: 1, narrativeCtr: narrativeCtr),
              ),
            ),
          ),
        );

        await tester.tap(find.byTooltip('Preview'));
        await tester.pump();

        final markdown = tester.widget<MarkdownBody>(find.byType(MarkdownBody));
        final styleSheet = markdown.styleSheet;
        final onSurface = theme.colorScheme.onSurface;

        expect(styleSheet, isNotNull);
        expect(styleSheet!.p!.color, onSurface);
        expect(styleSheet.h1!.color, onSurface);
        expect(styleSheet.strong!.color, onSurface);
        expect(styleSheet.em!.color, onSurface);
        expect(styleSheet.del!.color, onSurface);
        expect(styleSheet.listBullet!.color, onSurface);
        expect(styleSheet.tableBody!.color, onSurface);
        expect(styleSheet.code!.color, onSurface);
        expect(
          styleSheet.code!.backgroundColor,
          theme.colorScheme.surfaceContainerHighest,
        );
      },
    );
  }
}
