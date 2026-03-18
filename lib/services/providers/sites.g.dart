// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sites.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$siteMediaHash() => r'6fef1803e85c8f887c7e5ee2413cf20434763f9d';

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

/// See also [siteMedia].
@ProviderFor(siteMedia)
const siteMediaProvider = SiteMediaFamily();

/// See also [siteMedia].
class SiteMediaFamily extends Family<AsyncValue<List<MediaData>>> {
  /// See also [siteMedia].
  const SiteMediaFamily();

  /// See also [siteMedia].
  SiteMediaProvider call({
    required int siteId,
  }) {
    return SiteMediaProvider(
      siteId: siteId,
    );
  }

  @override
  SiteMediaProvider getProviderOverride(
    covariant SiteMediaProvider provider,
  ) {
    return call(
      siteId: provider.siteId,
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
  String? get name => r'siteMediaProvider';
}

/// See also [siteMedia].
class SiteMediaProvider extends AutoDisposeFutureProvider<List<MediaData>> {
  /// See also [siteMedia].
  SiteMediaProvider({
    required int siteId,
  }) : this._internal(
          (ref) => siteMedia(
            ref as SiteMediaRef,
            siteId: siteId,
          ),
          from: siteMediaProvider,
          name: r'siteMediaProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$siteMediaHash,
          dependencies: SiteMediaFamily._dependencies,
          allTransitiveDependencies: SiteMediaFamily._allTransitiveDependencies,
          siteId: siteId,
        );

  SiteMediaProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.siteId,
  }) : super.internal();

  final int siteId;

  @override
  Override overrideWith(
    FutureOr<List<MediaData>> Function(SiteMediaRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SiteMediaProvider._internal(
        (ref) => create(ref as SiteMediaRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        siteId: siteId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<MediaData>> createElement() {
    return _SiteMediaProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SiteMediaProvider && other.siteId == siteId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, siteId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SiteMediaRef on AutoDisposeFutureProviderRef<List<MediaData>> {
  /// The parameter `siteId` of this provider.
  int get siteId;
}

class _SiteMediaProviderElement
    extends AutoDisposeFutureProviderElement<List<MediaData>>
    with SiteMediaRef {
  _SiteMediaProviderElement(super.provider);

  @override
  int get siteId => (origin as SiteMediaProvider).siteId;
}

String _$siteInEventHash() => r'ceb819c4b5d481d81f5df18170061602aef1ff6d';

/// See also [siteInEvent].
@ProviderFor(siteInEvent)
final siteInEventProvider = AutoDisposeFutureProvider<List<SiteData>>.internal(
  siteInEvent,
  name: r'siteInEventProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$siteInEventHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SiteInEventRef = AutoDisposeFutureProviderRef<List<SiteData>>;
String _$siteEntryHash() => r'de7c968d0f594ec4fbaf6661642d45cf60ba40e3';

/// See also [SiteEntry].
@ProviderFor(SiteEntry)
final siteEntryProvider =
    AutoDisposeAsyncNotifierProvider<SiteEntry, List<SiteData>>.internal(
  SiteEntry.new,
  name: r'siteEntryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$siteEntryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SiteEntry = AutoDisposeAsyncNotifier<List<SiteData>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
