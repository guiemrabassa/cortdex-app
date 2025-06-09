// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'omni_button_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(OmniState)
const omniStateProvider = OmniStateProvider._();

final class OmniStateProvider extends $NotifierProvider<OmniState, int> {
  const OmniStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'omniStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$omniStateHash();

  @$internal
  @override
  OmniState create() => OmniState();

  @$internal
  @override
  $NotifierProviderElement<OmniState, int> $createElement(
    $ProviderPointer pointer,
  ) => $NotifierProviderElement(pointer);

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $ValueProvider<int>(value),
    );
  }
}

String _$omniStateHash() => r'a78df32faa0c20c0030b3ba7843a5ea4fbe169aa';

abstract class _$OmniState extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<int>;
    final element =
        ref.element
            as $ClassProviderElement<AnyNotifier<int>, int, Object?, Object?>;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
