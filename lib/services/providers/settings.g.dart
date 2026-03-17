// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settingHash() => r'b4ffdf1319400e689586e0f3860362fbad56142e';

/// See also [setting].
@ProviderFor(setting)
final settingProvider = Provider<SharedPreferences>.internal(
  setting,
  name: r'settingProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$settingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SettingRef = ProviderRef<SharedPreferences>;
String _$themeSettingHash() => r'6c0fd6288d1348a4a74fd96f16a8d7e40821e875';

/// See also [ThemeSetting].
@ProviderFor(ThemeSetting)
final themeSettingProvider =
    AsyncNotifierProvider<ThemeSetting, ThemeMode>.internal(
  ThemeSetting.new,
  name: r'themeSettingProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$themeSettingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ThemeSetting = AsyncNotifier<ThemeMode>;
String _$textCaseFmtNotifierHash() =>
    r'81bb739ee4cbc4ddbbf686b24778fbe0ee24562e';

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

abstract class _$TextCaseFmtNotifier
    extends BuildlessAutoDisposeAsyncNotifier<TextCaseFmt> {
  late final String prefKey;

  FutureOr<TextCaseFmt> build(
    String prefKey,
  );
}

/// See also [TextCaseFmtNotifier].
@ProviderFor(TextCaseFmtNotifier)
const textCaseFmtNotifierProvider = TextCaseFmtNotifierFamily();

/// See also [TextCaseFmtNotifier].
class TextCaseFmtNotifierFamily extends Family<AsyncValue<TextCaseFmt>> {
  /// See also [TextCaseFmtNotifier].
  const TextCaseFmtNotifierFamily();

  /// See also [TextCaseFmtNotifier].
  TextCaseFmtNotifierProvider call(
    String prefKey,
  ) {
    return TextCaseFmtNotifierProvider(
      prefKey,
    );
  }

  @override
  TextCaseFmtNotifierProvider getProviderOverride(
    covariant TextCaseFmtNotifierProvider provider,
  ) {
    return call(
      provider.prefKey,
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
  String? get name => r'textCaseFmtNotifierProvider';
}

/// See also [TextCaseFmtNotifier].
class TextCaseFmtNotifierProvider extends AutoDisposeAsyncNotifierProviderImpl<
    TextCaseFmtNotifier, TextCaseFmt> {
  /// See also [TextCaseFmtNotifier].
  TextCaseFmtNotifierProvider(
    String prefKey,
  ) : this._internal(
          () => TextCaseFmtNotifier()..prefKey = prefKey,
          from: textCaseFmtNotifierProvider,
          name: r'textCaseFmtNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$textCaseFmtNotifierHash,
          dependencies: TextCaseFmtNotifierFamily._dependencies,
          allTransitiveDependencies:
              TextCaseFmtNotifierFamily._allTransitiveDependencies,
          prefKey: prefKey,
        );

  TextCaseFmtNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.prefKey,
  }) : super.internal();

  final String prefKey;

  @override
  FutureOr<TextCaseFmt> runNotifierBuild(
    covariant TextCaseFmtNotifier notifier,
  ) {
    return notifier.build(
      prefKey,
    );
  }

  @override
  Override overrideWith(TextCaseFmtNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: TextCaseFmtNotifierProvider._internal(
        () => create()..prefKey = prefKey,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        prefKey: prefKey,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<TextCaseFmtNotifier, TextCaseFmt>
      createElement() {
    return _TextCaseFmtNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TextCaseFmtNotifierProvider && other.prefKey == prefKey;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, prefKey.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TextCaseFmtNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<TextCaseFmt> {
  /// The parameter `prefKey` of this provider.
  String get prefKey;
}

class _TextCaseFmtNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<TextCaseFmtNotifier,
        TextCaseFmt> with TextCaseFmtNotifierRef {
  _TextCaseFmtNotifierProviderElement(super.provider);

  @override
  String get prefKey => (origin as TextCaseFmtNotifierProvider).prefKey;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
