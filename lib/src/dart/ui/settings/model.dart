import 'package:cortdex/src/dart/helpers/debug.dart';
import 'package:cortdex/src/dart/settings/model.dart';
import 'package:cortdex/src/dart/ui/cortdex_widget.dart';
import 'package:cortdex/src/rust/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ModelSelector extends CortdexWidget {
  const ModelSelector({super.key});

  @override
  Widget buildWith(BuildContext context, WidgetRef ref, CortdexClient client) {
    Log.d('Opened model selector!');

    return Column(
      children: [
        ModelDownloader(client: client),
        ModelList(client: client),
      ],
    );
  }
}

class ModelDownloader extends HookWidget {
  const ModelDownloader({super.key, required this.client});

  final CortdexClient client;

  @override
  Widget build(BuildContext context) {
    final query = useState("");

    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (value) {
              query.value = value;
            },
          ),
        ),
        IconButton(
          onPressed: () async {
            /* await Connection()
                  .runCommand(ModelManagerCommand.downloadNew(id: query.value), res: false); */

            Log.d('Downloading new model: ${query.value}');

            try {
              // await copyAssetModels();
              await client.local().downloadNewModel(modelId: query.value);
            } catch (e) {
              Log.d('Error while downloading model: $e');
            }
          },
          icon: Icon(Icons.search),
        ),
      ],
    );
  }
}

class ModelList extends AsyncValueWidget<List<String>> {
  const ModelList({super.key, required this.client});

  final CortdexClient client;

  @override
  Future<List<String>?> buildValue() async {
    // return List.empty();
    return await client.local().getAllModels();
    /* return Connection()
        .runCommand<List<dynamic>>(ModelManagerCommand.getAll())
        .then((value) => List<String>.from(value ?? [])); */
  }

  @override
  Widget onLoading(BuildContext context, WidgetRef ref) {
    // Let's try to copy model, in case none is loaded

    Log.d('Loading model list!');

    return super.onLoading(context, ref);
  }

  @override
  Widget onValue(BuildContext context, WidgetRef ref, List<String> value) {
    if (value.isEmpty) copyAssetModels();

    return Column(
      children: value.map((e) => Model(name: e, client: client)).toList(),
    );
  }
}

class Model extends StatelessWidget {
  const Model({super.key, required this.name, required this.client});

  final CortdexClient client;

  final String name;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Text(name),
          IconButton.filledTonal(
            onPressed: () async {
              await client.local().removeModel(modelId: name);
            },
            icon: Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
