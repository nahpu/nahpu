import 'package:drift/drift.dart' as db;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/forms/custom_fields.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/services/settings/controlled_vocabulary_services.dart';
import 'package:nahpu/services/sites/site_services.dart';
import 'package:nahpu/services/types/fossils.dart';
import 'package:nahpu/styles/design_tokens.dart';

class Sedimentology extends ConsumerWidget {
  const Sedimentology({
    super.key,
    required this.id,
    required this.useHorizontalLayout,
  });

  final int id;
  final bool useHorizontalLayout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref
        .watch(fossilSiteProvider(id))
        .when(
          data: (data) => SedimentologyFields(
            key: ValueKey(id),
            siteId: id,
            fossilSite: data,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Column(
            children: [
              Text('Could not load sedimentology: $error'),
              TextButton(
                onPressed: () => ref.invalidate(fossilSiteProvider(id)),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
    return FormCard(
      title: 'Sedimentology',
      mainAxisAlignment: MainAxisAlignment.start,
      isExpanded: useHorizontalLayout,
      child: useHorizontalLayout
          ? SingleChildScrollView(child: content)
          : content,
    );
  }
}

class SedimentologyFields extends ConsumerStatefulWidget {
  const SedimentologyFields({
    super.key,
    required this.siteId,
    required this.fossilSite,
  });

  final int siteId;
  final FossilSiteData? fossilSite;

  @override
  ConsumerState<SedimentologyFields> createState() =>
      _SedimentologyFieldsState();
}

class _SedimentologyFieldsState extends ConsumerState<SedimentologyFields> {
  final _rockType = TextEditingController();
  final _remarks = TextEditingController();
  int? _environmentCode;
  String? _continental;
  String? _marine;
  String? _preservation;
  String? _saveError;
  int _pendingWrites = 0;
  int _saveGeneration = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant SedimentologyFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.siteId != widget.siteId) {
      _saveGeneration++;
      _saveError = null;
      _load();
    } else if (_pendingWrites == 0 &&
        _saveError == null &&
        oldWidget.fossilSite != widget.fossilSite) {
      _load();
    }
  }

  @override
  void dispose() {
    _rockType.dispose();
    _remarks.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final environment = getDepositionalEnvironmentType(_environmentCode);
    final subtype = environment == DepositionalEnvironmentType.continental
        ? _continental
        : environment == DepositionalEnvironmentType.marine
        ? _marine
        : null;
    final options = switch (environment) {
      DepositionalEnvironmentType.continental => continentalSubEnvironmentList,
      DepositionalEnvironmentType.marine => marineSubEnvironmentList,
      _ => const <String>[],
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _rockType,
          decoration: const InputDecoration(labelText: 'Rock Type(s)'),
          onChanged: (_) => _save(),
        ),
        DropdownButtonFormField<DepositionalEnvironmentType>(
          key: ValueKey(('environment', _environmentCode)),
          isExpanded: true,
          initialValue: environment,
          decoration: const InputDecoration(
            labelText: 'Depositional Environment Type',
          ),
          items: [
            for (final value in DepositionalEnvironmentType.values)
              DropdownMenuItem(
                value: value,
                child: CommonDropdownText(
                  text: depositionalEnvironmentTypeList[value.index],
                ),
              ),
          ],
          onChanged: (value) {
            if (value == null || value.index == _environmentCode) return;
            setState(() {
              _environmentCode = value.index;
              _continental = null;
              _marine = null;
            });
            _save();
          },
        ),
        DropdownButtonFormField<String>(
          key: ValueKey(('subtype', _environmentCode, subtype)),
          isExpanded: true,
          initialValue: subtype,
          decoration: const InputDecoration(
            labelText: 'Depositional Environment Subtype',
            hintText: 'Select a Continental or Marine type first',
          ),
          items: [
            for (final value in includeCurrentVocabularyValue(options, subtype))
              DropdownMenuItem(
                value: value,
                child: CommonDropdownText(text: value),
              ),
          ],
          onChanged: options.isEmpty
              ? null
              : (value) {
                  setState(() {
                    if (environment ==
                        DepositionalEnvironmentType.continental) {
                      _continental = value;
                    } else {
                      _marine = value;
                    }
                  });
                  _save();
                },
        ),
        DropdownButtonFormField<String>(
          key: ValueKey(('preservation', _preservation)),
          isExpanded: true,
          initialValue: _preservation,
          decoration: const InputDecoration(
            labelText: 'Standard Preservation Type',
          ),
          items: [
            for (final value in includeCurrentVocabularyValue(
              standardPreservationTypeList,
              _preservation,
            ))
              DropdownMenuItem(
                value: value,
                child: CommonDropdownText(text: value),
              ),
          ],
          onChanged: (value) {
            setState(() => _preservation = value);
            _save();
          },
        ),
        TextFormField(
          controller: _remarks,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Comments on sedimentology and paleoenvironment',
          ),
          onChanged: (_) => _save(),
        ),
        if (_saveError != null) ...[
          const SizedBox(height: NahpuSpacing.md),
          Text(
            _saveError!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          TextButton(onPressed: _save, child: const Text('Retry saving')),
        ],
        CustomFieldForm(owner: CustomFieldOwner.site(widget.siteId)),
      ],
    );
  }

  void _load() {
    final data = widget.fossilSite;
    if (_rockType.text != (data?.rockType ?? '')) {
      _rockType.text = data?.rockType ?? '';
    }
    if (_remarks.text != (data?.sedimentologyRemark ?? '')) {
      _remarks.text = data?.sedimentologyRemark ?? '';
    }
    _environmentCode = data?.depositionalEnvironmentType;
    _continental = data?.depositionalContinent;
    _marine = data?.depositionalMarine;
    _preservation = data?.standardPreservationType;
  }

  Future<void> _save() async {
    final generation = ++_saveGeneration;
    _pendingWrites++;
    final entries = FossilSiteCompanion(
      rockType: db.Value(_rockType.text),
      depositionalEnvironmentType: db.Value(_environmentCode),
      depositionalContinent: db.Value(_continental),
      depositionalMarine: db.Value(_marine),
      standardPreservationType: db.Value(_preservation),
      sedimentologyRemark: db.Value(_remarks.text),
    );
    try {
      await FossilSiteServices(
        ref: ref,
      ).updateFossilSite(widget.siteId, entries);
      if (mounted && generation == _saveGeneration) {
        setState(() => _saveError = null);
      }
    } catch (error) {
      if (mounted && generation == _saveGeneration) {
        setState(() => _saveError = 'Could not save sedimentology: $error');
      }
    } finally {
      _pendingWrites--;
    }
  }
}
