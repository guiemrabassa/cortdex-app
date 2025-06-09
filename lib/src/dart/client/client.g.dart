// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(Client)
const clientProvider = ClientProvider._();

final class ClientProvider extends $NotifierProvider<Client, CortdexClient?> {
  const ClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clientProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clientHash();

  @$internal
  @override
  Client create() => Client();

  @$internal
  @override
  _$ClientElement $createElement($ProviderPointer pointer) =>
      _$ClientElement(pointer);

  ProviderListenable<Client$Start> get start =>
      $LazyProxyListenable<Client$Start, CortdexClient?>(this, (element) {
        element as _$ClientElement;

        return element._$start;
      });

  ProviderListenable<Client$StartSaved> get startSaved =>
      $LazyProxyListenable<Client$StartSaved, CortdexClient?>(this, (element) {
        element as _$ClientElement;

        return element._$startSaved;
      });

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CortdexClient? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $ValueProvider<CortdexClient?>(value),
    );
  }
}

String _$clientHash() => r'95084af29dbd24a6c50a3df9311bfa96e54e6e00';

abstract class _$Client extends $Notifier<CortdexClient?> {
  CortdexClient? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<CortdexClient?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CortdexClient?>,
              CortdexClient?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

class _$ClientElement extends $NotifierProviderElement<Client, CortdexClient?> {
  _$ClientElement(super.pointer) {
    _$start.result = $Result.data(_$Client$Start(this));
    _$startSaved.result = $Result.data(_$Client$StartSaved(this));
  }
  final _$start = $ElementLense<_$Client$Start>();
  final _$startSaved = $ElementLense<_$Client$StartSaved>();
  @override
  void mount() {
    super.mount();
    _$start.result!.value!.reset();
    _$startSaved.result!.value!.reset();
  }

  @override
  void visitListenables(
    void Function($ElementLense element) listenableVisitor,
  ) {
    super.visitListenables(listenableVisitor);

    listenableVisitor(_$start);
    listenableVisitor(_$startSaved);
  }
}

sealed class Client$Start extends MutationBase<void> {
  /// Starts the mutation.
  ///
  /// This will first set the state to [PendingMutation], then
  /// will call [Client.start] with the provided parameters.
  ///
  /// After the method completes, the mutation state will be updated to either
  /// [SuccessMutation] or [ErrorMutation] based on if the method
  /// threw or not.
  ///
  /// **Note**:
  /// If the notifier threw in its constructor, the mutation won't start
  /// and [call] will throw.
  /// This should generally never happen though, as Notifiers are not supposed
  /// to have logic in their constructors.
  Future<void> call(ConnectionSettings settings);
}

final class _$Client$Start
    extends $AsyncMutationBase<void, _$Client$Start, Client>
    implements Client$Start {
  _$Client$Start(this.element, {super.state, super.key});

  @override
  final _$ClientElement element;

  @override
  $ElementLense<_$Client$Start> get listenable => element._$start;

  @override
  Future<void> call(ConnectionSettings settings) {
    return mutate(
      Invocation.method(#start, [settings]),
      ($notifier) => $notifier.start(settings),
    );
  }

  @override
  _$Client$Start copyWith(MutationState<void> state, {Object? key}) =>
      _$Client$Start(element, state: state, key: key);
}

sealed class Client$StartSaved extends MutationBase<void> {
  /// Starts the mutation.
  ///
  /// This will first set the state to [PendingMutation], then
  /// will call [Client.startSaved] with the provided parameters.
  ///
  /// After the method completes, the mutation state will be updated to either
  /// [SuccessMutation] or [ErrorMutation] based on if the method
  /// threw or not.
  ///
  /// **Note**:
  /// If the notifier threw in its constructor, the mutation won't start
  /// and [call] will throw.
  /// This should generally never happen though, as Notifiers are not supposed
  /// to have logic in their constructors.
  Future<void> call();
}

final class _$Client$StartSaved
    extends $AsyncMutationBase<void, _$Client$StartSaved, Client>
    implements Client$StartSaved {
  _$Client$StartSaved(this.element, {super.state, super.key});

  @override
  final _$ClientElement element;

  @override
  $ElementLense<_$Client$StartSaved> get listenable => element._$startSaved;

  @override
  Future<void> call() {
    return mutate(
      Invocation.method(#startSaved, []),
      ($notifier) => $notifier.startSaved(),
    );
  }

  @override
  _$Client$StartSaved copyWith(MutationState<void> state, {Object? key}) =>
      _$Client$StartSaved(element, state: state, key: key);
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
