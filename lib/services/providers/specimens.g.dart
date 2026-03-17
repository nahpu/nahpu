// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'specimens.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$associatedDataHash() => r'4e0e25829cadfca3f664c936d1094a1f0e0614f2';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [associatedData].
@ProviderFor(associatedData)
const associatedDataProvider = AssociatedDataFamily();

/// See also [associatedData].
class AssociatedDataFamily
    extends Family<AsyncValue<List<AssociatedDataData>>> {
  /// See also [associatedData].
  const AssociatedDataFamily();

  /// See also [associatedData].
  AssociatedDataProvider call({
    required String specimenUuid,
  }) {
    return AssociatedDataProvider(
      specimenUuid: specimenUuid,
    );
  }

  @override
  AssociatedDataProvider getProviderOverride(
    covariant AssociatedDataProvider provider,
  ) {
    return call(
      specimenUuid: provider.specimenUuid,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'associatedDataProvider';
}

/// See also [associatedData].
class AssociatedDataProvider
    extends AutoDisposeFutureProvider<List<AssociatedDataData>> {
  /// See also [associatedData].
  AssociatedDataProvider({
    required String specimenUuid,
  }) : this._internal(
          (ref) => associatedData(
            ref as AssociatedDataRef,
            specimenUuid: specimenUuid,
          ),
          from: associatedDataProvider,
          name: r'associatedDataProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$associatedDataHash,
          dependencies: AssociatedDataFamily._dependencies,
          allTransitiveDependencies:
              AssociatedDataFamily._allTransitiveDependencies,
          specimenUuid: specimenUuid,
        );

  AssociatedDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.specimenUuid,
  }) : super.internal();

  final String specimenUuid;

  @override
  Override overrideWith(
    FutureOr<List<AssociatedDataData>> Function(AssociatedDataRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AssociatedDataProvider._internal(
        (ref) => create(ref as AssociatedDataRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        specimenUuid: specimenUuid,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<AssociatedDataData>> createElement() {
    return _AssociatedDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AssociatedDataProvider &&
        other.specimenUuid == specimenUuid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, specimenUuid.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AssociatedDataRef
    on AutoDisposeFutureProviderRef<List<AssociatedDataData>> {
  /// The parameter `specimenUuid` of this provider.
  String get specimenUuid;
}

class _AssociatedDataProviderElement
    extends AutoDisposeFutureProviderElement<List<AssociatedDataData>>
    with AssociatedDataRef {
  _AssociatedDataProviderElement(super.provider);

  @override
  String get specimenUuid => (origin as AssociatedDataProvider).specimenUuid;
}

String _$specimenMediaHash() => r'ee0304c9ec68e62aa92c788bc0f81d9e5aa8227e';

/// See also [specimenMedia].
@ProviderFor(specimenMedia)
const specimenMediaProvider = SpecimenMediaFamily();

/// See also [specimenMedia].
class SpecimenMediaFamily extends Family<AsyncValue<List<MediaData>>> {
  /// See also [specimenMedia].
  const SpecimenMediaFamily();

  /// See also [specimenMedia].
  SpecimenMediaProvider call({
    required String specimenUuid,
  }) {
    return SpecimenMediaProvider(
      specimenUuid: specimenUuid,
    );
  }

  @override
  SpecimenMediaProvider getProviderOverride(
    covariant SpecimenMediaProvider provider,
  ) {
    return call(
      specimenUuid: provider.specimenUuid,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'specimenMediaProvider';
}

/// See also [specimenMedia].
class SpecimenMediaProvider extends AutoDisposeFutureProvider<List<MediaData>> {
  /// See also [specimenMedia].
  SpecimenMediaProvider({
    required String specimenUuid,
  }) : this._internal(
          (ref) => specimenMedia(
            ref as SpecimenMediaRef,
            specimenUuid: specimenUuid,
          ),
          from: specimenMediaProvider,
          name: r'specimenMediaProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$specimenMediaHash,
          dependencies: SpecimenMediaFamily._dependencies,
          allTransitiveDependencies:
              SpecimenMediaFamily._allTransitiveDependencies,
          specimenUuid: specimenUuid,
        );

  SpecimenMediaProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.specimenUuid,
  }) : super.internal();

  final String specimenUuid;

  @override
  Override overrideWith(
    FutureOr<List<MediaData>> Function(SpecimenMediaRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SpecimenMediaProvider._internal(
        (ref) => create(ref as SpecimenMediaRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        specimenUuid: specimenUuid,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<MediaData>> createElement() {
    return _SpecimenMediaProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SpecimenMediaProvider && other.specimenUuid == specimenUuid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, specimenUuid.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SpecimenMediaRef on AutoDisposeFutureProviderRef<List<MediaData>> {
  /// The parameter `specimenUuid` of this provider.
  String get specimenUuid;
}

class _SpecimenMediaProviderElement
    extends AutoDisposeFutureProviderElement<List<MediaData>>
    with SpecimenMediaRef {
  _SpecimenMediaProviderElement(super.provider);

  @override
  String get specimenUuid => (origin as SpecimenMediaProvider).specimenUuid;
}

String _$catalogFmtNotifierHash() =>
    r'9b1919ba48769138f474858cb3c9a9bcd91ad365';

/// See also [CatalogFmtNotifier].
@ProviderFor(CatalogFmtNotifier)
final catalogFmtNotifierProvider =
    AutoDisposeAsyncNotifierProvider<CatalogFmtNotifier, CatalogFmt>.internal(
  CatalogFmtNotifier.new,
  name: r'catalogFmtNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$catalogFmtNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CatalogFmtNotifier = AutoDisposeAsyncNotifier<CatalogFmt>;
String _$specimenEntryHash() => r'7f7a555ee8fb8b97c63d795b4a316a87db1899a5';

/// See also [SpecimenEntry].
@ProviderFor(SpecimenEntry)
final specimenEntryProvider = AutoDisposeAsyncNotifierProvider<SpecimenEntry,
    List<SpecimenData>>.internal(
  SpecimenEntry.new,
  name: r'specimenEntryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$specimenEntryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SpecimenEntry = AutoDisposeAsyncNotifier<List<SpecimenData>>;
String _$specimenTypesHash() => r'8c713b8bea707b9e74b5d7bea4df0ef5e8529abd';

/// See also [SpecimenTypes].
@ProviderFor(SpecimenTypes)
final specimenTypesProvider =
    AutoDisposeAsyncNotifierProvider<SpecimenTypes, List<String>>.internal(
  SpecimenTypes.new,
  name: r'specimenTypesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$specimenTypesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SpecimenTypes = AutoDisposeAsyncNotifier<List<String>>;
String _$treatmentOptionsHash() => r'09e1d4c991cae53564a35a98924b60106c2d8538';

/// See also [TreatmentOptions].
@ProviderFor(TreatmentOptions)
final treatmentOptionsProvider =
    AutoDisposeAsyncNotifierProvider<TreatmentOptions, List<String>>.internal(
  TreatmentOptions.new,
  name: r'treatmentOptionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$treatmentOptionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TreatmentOptions = AutoDisposeAsyncNotifier<List<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
