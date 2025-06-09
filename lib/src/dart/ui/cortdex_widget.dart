import 'package:cortdex/src/dart/client/client.dart';
import 'package:cortdex/src/dart/helpers/debug.dart';
import 'package:cortdex/src/rust/api.dart';
import 'package:cortdex/src/rust/frb_generated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cortdex/src/dart/helpers/async_snapshot.dart';


abstract class AsyncValueWidget<T> extends HookConsumerWidget {
  const AsyncValueWidget({super.key});

  Future<T?> buildValue();

  List<Object?> conditions() {
    return [];
  }

  Widget onValue(BuildContext context, WidgetRef ref, T value);

  Widget onNullValue(BuildContext context, WidgetRef ref) {
    return Center(child: Text("Loading failed"));
  }

  Widget onError(BuildContext context, WidgetRef ref, Object error) {
    String message = error.toString();
    if (error is CortdexErrorImpl) {
      message = error.getMessage();
    }

    return Center(child: Text(message));
  }

  Widget onLoading(BuildContext context, WidgetRef ref) {
    return const Center(child: CircularProgressIndicator());
  }

  Widget switchValue(BuildContext context, WidgetRef ref, T? nullableValue) {
    if (nullableValue == null) {
      return onNullValue(context, ref);
    } else {
      return onValue(context, ref, nullableValue);
    }
  }

  Widget switchAsyncValue(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<T?> nullableValue,
  ) {
    return switch (nullableValue) {
      AsyncData(value: final value) => switchValue(context, ref, value),
      AsyncError(:final error) => onError(context, ref, error),
      _ => onLoading(context, ref),
    };
  }

  void customInit() {}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var a = useState('initialData');

    ref = ref;
    customInit();
    Log.d('Conditions: ${conditions()}');
    final memo = useMemoized(() => buildValue(), conditions());
    final future = useFuture(memo);

    return switchAsyncValue(context, ref, future.asAsyncValue());
  }
}

abstract class CortdexWidget extends HookConsumerWidget {
  const CortdexWidget({super.key});

  Widget buildWith(BuildContext context, WidgetRef ref, CortdexClient client);

  Widget buildWithout(BuildContext context, WidgetRef ref) {
    return Text('Disconnected');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mainClient = ref.watch(clientProvider);

    Log.d('Client changed to: ${mainClient?.toString()}');

    return (mainClient != null)
        ? buildWith(context, ref, mainClient)
        : buildWithout(context, ref);
  }
}

class CortdexWidgetWrapper extends CortdexWidget {
  const CortdexWidgetWrapper({super.key, required this.child});

  final Widget Function(CortdexClient) child;

  @override
  Widget buildWith(BuildContext context, WidgetRef ref, CortdexClient client) {
    return child(client);
  }
}

/* abstract class ClientWidget extends AsyncValueWidget<CortdexClient> {
  const ClientWidget({super.key});

  @override
  Future<CortdexClient?> buildValue() async {
    return Client().client;
  }
  
} */

Widget _onLoading(Controller controller) =>
    const Center(child: CircularProgressIndicator());
Widget onNullValue(Controller controller) =>
    const Center(child: Text("Loading failed"));
Widget _onError(Controller controller, Object error) =>
    const Center(child: Text("Loading failed"));

void _onStartup(Controller controller) => ();

class Controller {
  final BuildContext context;
  final WidgetRef ref;
  final ValueNotifier<int> _rebuilds;

  const Controller(this._rebuilds, {required this.context, required this.ref});

  void rebuild() {
    _rebuilds.value++;
    Log.d('Rebuilding counter: ${_rebuilds.value}!');
  }
}

class AsyncValueBuilder<T> extends HookConsumerWidget {
  const AsyncValueBuilder({
    super.key,
    this.conditions = const [],
    required this.buildValue,
    required this.onValue,
    this.onError = _onError,
    this.onNull = onNullValue,
    this.onLoading = _onLoading,
    this.onStartup = _onStartup
  });

  final List<Object?> conditions;

  final Future<T?> Function(Controller controller) buildValue;

  final void Function(Controller controller) onStartup;

  final Widget Function(Controller controller, T value) onValue;

  final Widget Function(Controller controller, Object error) onError;

  final Widget Function(Controller controller) onNull;

  final Widget Function(Controller controller) onLoading;

  Widget switchValue(Controller controller, T? nullableValue) {
    if (nullableValue == null) {
      return onNull(controller);
    } else {
      return onValue(controller, nullableValue);
    }
  }

  Widget switchAsyncValue(Controller controller, AsyncValue<T?> nullableValue) {
    return switch (nullableValue) {
      AsyncData(value: final value) => switchValue(controller, value),
      AsyncError(:final error) => onError(controller, error),
      _ => onLoading(controller),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rebuilds = useState(0);
    final controller = Controller(rebuilds, context: context, ref: ref);

    // Correct way to handle startup logic
    useEffect(() {
      onStartup(controller);
      Log.d('Running on startup');
      // The empty list [] means this effect runs only once.
      return null;
    }, []);

    final memo = useMemoized(() => buildValue(controller), [
      rebuilds.value,
      ...conditions,
    ]);

    final future = useFuture(memo);

    return switchAsyncValue(controller, future.asAsyncValue());
  }
}
