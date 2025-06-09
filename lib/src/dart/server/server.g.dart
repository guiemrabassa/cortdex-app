// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(Server)
const serverProvider = ServerProvider._();

final class ServerProvider extends $NotifierProvider<Server, CortdexServer?> {
  const ServerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverHash();

  @$internal
  @override
  Server create() => Server();

  @$internal
  @override
  _$ServerElement $createElement($ProviderPointer pointer) =>
      _$ServerElement(pointer);

  ProviderListenable<Server$Start> get start =>
      $LazyProxyListenable<Server$Start, CortdexServer?>(this, (element) {
        element as _$ServerElement;

        return element._$start;
      });

  ProviderListenable<Server$Stop> get stop =>
      $LazyProxyListenable<Server$Stop, CortdexServer?>(this, (element) {
        element as _$ServerElement;

        return element._$stop;
      });

  ProviderListenable<Server$StartSaved> get startSaved =>
      $LazyProxyListenable<Server$StartSaved, CortdexServer?>(this, (element) {
        element as _$ServerElement;

        return element._$startSaved;
      });

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CortdexServer? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $ValueProvider<CortdexServer?>(value),
    );
  }
}

String _$serverHash() => r'cf3db9cd2ae48a928fb4b694c6d35409434ca329';

abstract class _$Server extends $Notifier<CortdexServer?> {
  CortdexServer? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<CortdexServer?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CortdexServer?>,
              CortdexServer?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

class _$ServerElement extends $NotifierProviderElement<Server, CortdexServer?> {
  _$ServerElement(super.pointer) {
    _$start.result = $Result.data(_$Server$Start(this));
    _$stop.result = $Result.data(_$Server$Stop(this));
    _$startSaved.result = $Result.data(_$Server$StartSaved(this));
  }
  final _$start = $ElementLense<_$Server$Start>();
  final _$stop = $ElementLense<_$Server$Stop>();
  final _$startSaved = $ElementLense<_$Server$StartSaved>();
  @override
  void mount() {
    super.mount();
    _$start.result!.value!.reset();
    _$stop.result!.value!.reset();
    _$startSaved.result!.value!.reset();
  }

  @override
  void visitListenables(
    void Function($ElementLense element) listenableVisitor,
  ) {
    super.visitListenables(listenableVisitor);

    listenableVisitor(_$start);
    listenableVisitor(_$stop);
    listenableVisitor(_$startSaved);
  }
}

sealed class Server$Start extends MutationBase<void> {
  /// Starts the mutation.
  ///
  /// This will first set the state to [PendingMutation], then
  /// will call [Server.start] with the provided parameters.
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
  Future<void> call(ServerSettings settings);
}

final class _$Server$Start
    extends $AsyncMutationBase<void, _$Server$Start, Server>
    implements Server$Start {
  _$Server$Start(this.element, {super.state, super.key});

  @override
  final _$ServerElement element;

  @override
  $ElementLense<_$Server$Start> get listenable => element._$start;

  @override
  Future<void> call(ServerSettings settings) {
    return mutate(
      Invocation.method(#start, [settings]),
      ($notifier) => $notifier.start(settings),
    );
  }

  @override
  _$Server$Start copyWith(MutationState<void> state, {Object? key}) =>
      _$Server$Start(element, state: state, key: key);
}

sealed class Server$Stop extends MutationBase<void> {
  /// Starts the mutation.
  ///
  /// This will first set the state to [PendingMutation], then
  /// will call [Server.stop] with the provided parameters.
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

final class _$Server$Stop
    extends $AsyncMutationBase<void, _$Server$Stop, Server>
    implements Server$Stop {
  _$Server$Stop(this.element, {super.state, super.key});

  @override
  final _$ServerElement element;

  @override
  $ElementLense<_$Server$Stop> get listenable => element._$stop;

  @override
  Future<void> call() {
    return mutate(
      Invocation.method(#stop, []),
      ($notifier) => $notifier.stop(),
    );
  }

  @override
  _$Server$Stop copyWith(MutationState<void> state, {Object? key}) =>
      _$Server$Stop(element, state: state, key: key);
}

sealed class Server$StartSaved extends MutationBase<void> {
  /// Starts the mutation.
  ///
  /// This will first set the state to [PendingMutation], then
  /// will call [Server.startSaved] with the provided parameters.
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

final class _$Server$StartSaved
    extends $AsyncMutationBase<void, _$Server$StartSaved, Server>
    implements Server$StartSaved {
  _$Server$StartSaved(this.element, {super.state, super.key});

  @override
  final _$ServerElement element;

  @override
  $ElementLense<_$Server$StartSaved> get listenable => element._$startSaved;

  @override
  Future<void> call() {
    return mutate(
      Invocation.method(#startSaved, []),
      ($notifier) => $notifier.startSaved(),
    );
  }

  @override
  _$Server$StartSaved copyWith(MutationState<void> state, {Object? key}) =>
      _$Server$StartSaved(element, state: state, key: key);
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
