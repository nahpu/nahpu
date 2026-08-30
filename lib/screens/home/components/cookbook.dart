import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/docs/documentation_widgets.dart';
import 'package:nahpu/screens/shared/layout/master_detail.dart';
import 'package:nahpu/services/docs/documentation_repository.dart';
import 'package:nahpu/styles/design_tokens.dart';

class CookbookScreen extends ConsumerStatefulWidget {
  const CookbookScreen({super.key});

  @override
  ConsumerState<CookbookScreen> createState() => _CookbookScreenState();
}

class _CookbookScreenState extends ConsumerState<CookbookScreen> {
  DocsLanguage _language = DocsLanguage.english;

  /// A null selection shows Day One, which opens the Cookbook.
  String? _selectedRecipeId;
  Future<Cookbook>? _cookbook;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cookbook')),
      body: SafeArea(
        child: FutureBuilder<Cookbook>(
          future: _cookbook ??= _loadCookbook(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final cookbook = snapshot.data;
            if (snapshot.hasError ||
                cookbook == null ||
                cookbook.categories.isEmpty) {
              return DocumentationErrorView(onRetry: _retry);
            }
            return _CookbookLayout(
              cookbook: cookbook,
              language: _language,
              selectedRecipeId: _selectedRecipeId,
              onLanguageSelected: _selectLanguage,
              onRecipeSelected: _selectRecipe,
            );
          },
        ),
      ),
    );
  }

  Future<Cookbook> _loadCookbook() {
    return ref.read(documentationRepositoryProvider).loadCookbook(_language);
  }

  void _selectLanguage(DocsLanguage language) {
    setState(() {
      _language = language;
      _cookbook = _loadCookbook();
    });
  }

  void _selectRecipe(String? recipeId) {
    setState(() => _selectedRecipeId = recipeId);
  }

  void _retry() {
    setState(() => _cookbook = _loadCookbook());
  }
}

class _CookbookLayout extends StatefulWidget {
  const _CookbookLayout({
    required this.cookbook,
    required this.language,
    required this.selectedRecipeId,
    required this.onLanguageSelected,
    required this.onRecipeSelected,
  });

  final Cookbook cookbook;
  final DocsLanguage language;
  final String? selectedRecipeId;
  final ValueChanged<DocsLanguage> onLanguageSelected;
  final ValueChanged<String?> onRecipeSelected;

  @override
  State<_CookbookLayout> createState() => _CookbookLayoutState();
}

class _CookbookLayoutState extends State<_CookbookLayout> {
  final Set<String> _collapsedCategoryIds = {};

  @override
  void didUpdateWidget(covariant _CookbookLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    final categoryIds = widget.cookbook.categories
        .map((category) => category.id)
        .toSet();
    _collapsedCategoryIds.retainAll(categoryIds);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= NahpuBreakpoints.compact;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: NahpuContentWidth.settings,
            ),
            child: Padding(
              padding: const EdgeInsets.all(NahpuSpacing.xl),
              child: Column(
                children: [
                  DocsLanguageSelector(
                    selectedLanguage: widget.language,
                    onSelected: widget.onLanguageSelected,
                  ),
                  const SizedBox(height: NahpuSpacing.lg),
                  Expanded(
                    child: isWide
                        ? _wideLayout(
                            context,
                            constraints.maxWidth,
                            _findSelectedDocument(),
                          )
                        : OutlinedSurface(child: _contentList(context, false)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _wideLayout(
    BuildContext context,
    double availableWidth,
    MarkdownDocument selectedDocument,
  ) {
    final listWidth = math.min(380.0, availableWidth * 0.38);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: listWidth,
          child: OutlinedSurface(
            child: Column(
              children: [
                Material(
                  key: const ValueKey('cookbook-list-header'),
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(NahpuSpacing.lg),
                        child: Text(
                          'Contents',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const Divider(height: NahpuStroke.thin),
                    ],
                  ),
                ),
                Expanded(child: ClipRect(child: _contentList(context, true))),
              ],
            ),
          ),
        ),
        const SizedBox(width: NahpuSpacing.lg),
        Expanded(
          child: OutlinedSurface(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(NahpuSpacing.xl),
              child: MarkdownDocumentView(document: selectedDocument),
            ),
          ),
        ),
      ],
    );
  }

  Widget _contentList(BuildContext context, bool isWide) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: NahpuSpacing.sm),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            NahpuSpacing.lg,
            NahpuSpacing.lg,
            NahpuSpacing.lg,
            NahpuSpacing.xs,
          ),
          child: _entryTile(
            context,
            isWide: isWide,
            title: widget.cookbook.dayOne.title,
            isSelected: widget.selectedRecipeId == null,
            onTap: () {
              widget.onRecipeSelected(null);
              if (!isWide) _showDocumentSheet(context, null);
            },
          ),
        ),
        for (final category in widget.cookbook.categories) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              NahpuSpacing.lg,
              NahpuSpacing.lg,
              NahpuSpacing.lg,
              NahpuSpacing.xs,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    category.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: _isCategoryExpanded(category)
                      ? 'Collapse ${category.title}'
                      : 'Expand ${category.title}',
                  icon: Icon(
                    _isCategoryExpanded(category) ? Icons.remove : Icons.add,
                  ),
                  onPressed: () {
                    setState(() {
                      if (_isCategoryExpanded(category)) {
                        _collapsedCategoryIds.add(category.id);
                      } else {
                        _collapsedCategoryIds.remove(category.id);
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          if (_isCategoryExpanded(category))
            for (final recipe in category.recipes)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: NahpuSpacing.xl,
                  vertical: NahpuSpacing.xs,
                ),
                child: _entryTile(
                  context,
                  isWide: isWide,
                  title: recipe.document.title,
                  isSelected: recipe.id == widget.selectedRecipeId,
                  onTap: () {
                    widget.onRecipeSelected(recipe.id);
                    if (!isWide) _showDocumentSheet(context, recipe.id);
                  },
                ),
              ),
        ],
      ],
    );
  }

  Widget _entryTile(
    BuildContext context, {
    required bool isWide,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      selected: isWide && isSelected,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NahpuRadius.md),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      title: Text(title),
      trailing: isWide ? null : const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }

  bool _isCategoryExpanded(CookbookCategory category) {
    return !_collapsedCategoryIds.contains(category.id);
  }

  MarkdownDocument _findSelectedDocument() {
    final selectedId = widget.selectedRecipeId;
    if (selectedId == null) return widget.cookbook.dayOne;
    final recipes = widget.cookbook.categories.expand(
      (category) => category.recipes,
    );
    for (final recipe in recipes) {
      if (recipe.id == selectedId) return recipe.document;
    }
    return widget.cookbook.dayOne;
  }

  Future<void> _showDocumentSheet(
    BuildContext context,
    String? recipeId,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.92,
        child: _CookbookBottomSheet(
          recipeId: recipeId,
          initialLanguage: widget.language,
          onLanguageSelected: widget.onLanguageSelected,
        ),
      ),
    );
  }
}

class _CookbookBottomSheet extends ConsumerStatefulWidget {
  const _CookbookBottomSheet({
    required this.recipeId,
    required this.initialLanguage,
    required this.onLanguageSelected,
  });

  /// A null recipe shows Day One.
  final String? recipeId;
  final DocsLanguage initialLanguage;
  final ValueChanged<DocsLanguage> onLanguageSelected;

  @override
  ConsumerState<_CookbookBottomSheet> createState() =>
      _CookbookBottomSheetState();
}

class _CookbookBottomSheetState extends ConsumerState<_CookbookBottomSheet> {
  late DocsLanguage _language = widget.initialLanguage;
  Future<Cookbook>? _cookbook;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DocsLanguageSelector(
          selectedLanguage: _language,
          onSelected: _selectLanguage,
        ),
        const Divider(),
        Expanded(
          child: FutureBuilder<Cookbook>(
            future: _cookbook ??= _loadCookbook(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final cookbook = snapshot.data;
              if (snapshot.hasError || cookbook == null) {
                return DocumentationErrorView(onRetry: _retry);
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(NahpuSpacing.xl),
                child: MarkdownDocumentView(document: _document(cookbook)),
              );
            },
          ),
        ),
      ],
    );
  }

  MarkdownDocument _document(Cookbook cookbook) {
    final recipeId = widget.recipeId;
    if (recipeId == null) return cookbook.dayOne;
    final recipes = cookbook.categories.expand((category) => category.recipes);
    for (final recipe in recipes) {
      if (recipe.id == recipeId) return recipe.document;
    }
    return cookbook.dayOne;
  }

  Future<Cookbook> _loadCookbook() {
    return ref.read(documentationRepositoryProvider).loadCookbook(_language);
  }

  void _selectLanguage(DocsLanguage language) {
    setState(() {
      _language = language;
      _cookbook = _loadCookbook();
    });
    widget.onLanguageSelected(language);
  }

  void _retry() {
    setState(() => _cookbook = _loadCookbook());
  }
}
