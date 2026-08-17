import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/docs/documentation_widgets.dart';
import 'package:nahpu/screens/shared/layout/master_detail.dart';
import 'package:nahpu/services/docs/documentation_repository.dart';
import 'package:nahpu/styles/design_tokens.dart';

class HowToRecipesScreen extends ConsumerStatefulWidget {
  const HowToRecipesScreen({super.key});

  @override
  ConsumerState<HowToRecipesScreen> createState() => _HowToRecipesScreenState();
}

class _HowToRecipesScreenState extends ConsumerState<HowToRecipesScreen> {
  DocsLanguage _language = DocsLanguage.english;
  String? _selectedRecipeId;
  Future<List<CookbookCategory>>? _categories;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('How-to Recipes')),
      body: SafeArea(
        child: FutureBuilder<List<CookbookCategory>>(
          future: _categories ??= _loadCategories(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final categories = snapshot.data;
            if (snapshot.hasError || categories == null || categories.isEmpty) {
              return DocumentationErrorView(onRetry: _retry);
            }
            return _CookbookLayout(
              categories: categories,
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

  Future<List<CookbookCategory>> _loadCategories() {
    return ref.read(documentationRepositoryProvider).loadCookbook(_language);
  }

  void _selectLanguage(DocsLanguage language) {
    setState(() {
      _language = language;
      _categories = _loadCategories();
    });
  }

  void _selectRecipe(String recipeId) {
    setState(() => _selectedRecipeId = recipeId);
  }

  void _retry() {
    setState(() => _categories = _loadCategories());
  }
}

class _CookbookLayout extends StatefulWidget {
  const _CookbookLayout({
    required this.categories,
    required this.language,
    required this.selectedRecipeId,
    required this.onLanguageSelected,
    required this.onRecipeSelected,
  });

  final List<CookbookCategory> categories;
  final DocsLanguage language;
  final String? selectedRecipeId;
  final ValueChanged<DocsLanguage> onLanguageSelected;
  final ValueChanged<String> onRecipeSelected;

  @override
  State<_CookbookLayout> createState() => _CookbookLayoutState();
}

class _CookbookLayoutState extends State<_CookbookLayout> {
  final Set<String> _collapsedCategoryIds = {};

  @override
  void didUpdateWidget(covariant _CookbookLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    final categoryIds = widget.categories
        .map((category) => category.id)
        .toSet();
    _collapsedCategoryIds.retainAll(categoryIds);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= NahpuBreakpoints.compact;
        final selectedRecipe = _findSelectedRecipe();
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
                            selectedRecipe,
                          )
                        : OutlinedSurface(child: _recipeList(context, false)),
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
    CookbookRecipe selectedRecipe,
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
                Padding(
                  padding: const EdgeInsets.all(NahpuSpacing.lg),
                  child: Text(
                    'Recipes',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const Divider(height: NahpuStroke.thin),
                Expanded(child: _recipeList(context, true)),
              ],
            ),
          ),
        ),
        const SizedBox(width: NahpuSpacing.lg),
        Expanded(
          child: OutlinedSurface(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(NahpuSpacing.xl),
              child: MarkdownDocumentView(document: selectedRecipe.document),
            ),
          ),
        ),
      ],
    );
  }

  Widget _recipeList(BuildContext context, bool isWide) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: NahpuSpacing.sm),
      children: [
        for (final category in widget.categories) ...[
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
                child: ListTile(
                  selected: isWide && recipe.id == _findSelectedRecipe().id,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(NahpuRadius.medium),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  title: Text(recipe.document.title),
                  trailing: isWide
                      ? null
                      : const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    widget.onRecipeSelected(recipe.id);
                    if (!isWide) {
                      _showRecipeSheet(context, recipe.id);
                    }
                  },
                ),
              ),
        ],
      ],
    );
  }

  bool _isCategoryExpanded(CookbookCategory category) {
    return !_collapsedCategoryIds.contains(category.id);
  }

  CookbookRecipe _findSelectedRecipe() {
    final recipes = widget.categories.expand((category) => category.recipes);
    return recipes.firstWhere(
      (recipe) => recipe.id == widget.selectedRecipeId,
      orElse: () => widget.categories.first.recipes.first,
    );
  }

  Future<void> _showRecipeSheet(BuildContext context, String recipeId) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.92,
        child: _RecipeBottomSheet(
          recipeId: recipeId,
          initialLanguage: widget.language,
          onLanguageSelected: widget.onLanguageSelected,
        ),
      ),
    );
  }
}

class _RecipeBottomSheet extends ConsumerStatefulWidget {
  const _RecipeBottomSheet({
    required this.recipeId,
    required this.initialLanguage,
    required this.onLanguageSelected,
  });

  final String recipeId;
  final DocsLanguage initialLanguage;
  final ValueChanged<DocsLanguage> onLanguageSelected;

  @override
  ConsumerState<_RecipeBottomSheet> createState() => _RecipeBottomSheetState();
}

class _RecipeBottomSheetState extends ConsumerState<_RecipeBottomSheet> {
  late DocsLanguage _language = widget.initialLanguage;
  Future<List<CookbookCategory>>? _categories;

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
          child: FutureBuilder<List<CookbookCategory>>(
            future: _categories ??= _loadCategories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final categories = snapshot.data;
              if (snapshot.hasError || categories == null) {
                return DocumentationErrorView(onRetry: _retry);
              }
              final recipes = categories.expand((category) => category.recipes);
              final recipe = recipes.firstWhere(
                (recipe) => recipe.id == widget.recipeId,
              );
              return SingleChildScrollView(
                padding: const EdgeInsets.all(NahpuSpacing.xl),
                child: MarkdownDocumentView(document: recipe.document),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<List<CookbookCategory>> _loadCategories() {
    return ref.read(documentationRepositoryProvider).loadCookbook(_language);
  }

  void _selectLanguage(DocsLanguage language) {
    setState(() {
      _language = language;
      _categories = _loadCategories();
    });
    widget.onLanguageSelected(language);
  }

  void _retry() {
    setState(() => _categories = _loadCategories());
  }
}
