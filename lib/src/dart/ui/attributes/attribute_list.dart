import 'package:cortdex/src/dart/client.dart';
import 'package:cortdex/src/dart/helpers/context.dart';
import 'package:cortdex/src/dart/helpers/debug.dart';
import 'package:cortdex/src/dart/ui/components/list.dart';
import 'package:cortdex/src/dart/ui/components/text.dart';
import 'package:cortdex/src/dart/ui/components/tiles.dart';
import 'package:cortdex/src/rust/api.dart';
import 'package:cortdex/src/rust/third_party/cortdex_types/api/attribute.dart';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cortdex/src/dart/helpers/files.dart';
import 'package:cortdex/src/dart/ui/attributes/attribute_value.dart';
import 'package:cortdex/src/dart/ui/cortdex_widget.dart';

import 'package:uuid/uuid.dart';
import 'package:uuid/v7.dart';

/* class AttributeList extends HookConsumerWidget {
  const AttributeList({super.key, required this.id});

  final UuidValue id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    // If I use memoized, it won't reload when a note is deleted, 
    // and it will reloaded on add, but not very well...
    final result = useMemoized(() => Connection().client?.getAllAttributesFromNote(noteId: id));
    final noteAtts = useFuture(result);

    
  }
} */

class NewAttributeList extends HookConsumerWidget {
  const NewAttributeList({super.key, required this.id, required this.client});

  final CortdexClient client;

  final UuidValue id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncValueBuilder<List<AttributeWithValue>>(
      buildValue: (controller) async {
        return await client.run(AttributeCommand.getAllFromNote(noteId: id)) ??
            List.empty();
      },
      onValue: (Controller controller, List<AttributeWithValue> value) {
        return Column(
          children: [
            TextTile(
              text: '${context.lang.addNew} ${context.lang.attribute}',
              onTap: () async {
                var att = await showAttributePicker(context);
                if (att != null) {
                  client.run(
                    AttributeCommand.addToNote(
                      noteId: id,
                      attributeName: att.name,
                      attributeValue: getValue(att.kind),
                    ),
                  );
                  controller.rebuild();
                }
              },
            ),
            DividedList(
              items: value,
              builder: (p0, noteAttribute) => AttributeTile(
                noteAttribute: noteAttribute,
                onDelete: controller.rebuild,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<Attribute?> showAttributePicker(BuildContext context) async {
    return await showModalBottomSheet<Attribute>(
      context: context,
      builder: (context) {
        return HookBuilder(
          builder: (context) {
            final query = useState('');

            final future = useMemoized(() {
              return client.run<List<Attribute>>(
                AttributeCommand.search(
                  amount: BigInt.from(10),
                  query: query.value,
                  desc: true,
                ),
              );
            }, [query.value]);

            final allAttributes = useFuture(future);

            return SizedBox(
              height: MediaQuery.sizeOf(
                context,
              ).height, // Set your desired height
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0),
                    child: Column(
                      children: [
                        TextField(
                          onChanged: (value) {
                            query.value = value;
                          },
                        ),
                        if (query.value.isNotEmpty)
                          TextTile(
                            text: context.lang.create_(query.value),
                            onTap: () async {
                              var attribute = await showAttributeCreator(
                                context,
                                query.value,
                              );

                              Navigator.pop(context, attribute);
                            },
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: allAttributes.data?.length ?? 0,
                      itemBuilder: (context, index) {
                        var attribute = allAttributes.data![index];
                        return ListTile(
                          titleAlignment: ListTileTitleAlignment.center,
                          title: Text(
                            attribute.name,
                            textAlign: TextAlign.center,
                          ),
                          onTap: () {
                            Navigator.pop(context, attribute);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class AttributeList extends AsyncValueWidget<List<AttributeWithValue>> {
  const AttributeList({super.key, required this.id, required this.client});

  final CortdexClient client;

  final UuidValue id;

  @override
  Future<List<AttributeWithValue>?> buildValue() async {
    return await client.run(AttributeCommand.getAllFromNote(noteId: id)) ??
        List.empty();
  }

  @override
  Widget onValue(
    BuildContext context,
    WidgetRef ref,
    List<AttributeWithValue> value,
  ) {
    return Column(
      children: [
        TextTile(
          text: '${context.lang.addNew} ${context.lang.attribute}',
          onTap: () async {
            var att = await showAttributePicker(context);
            if (att != null) {
              client.run(
                AttributeCommand.addToNote(
                  noteId: id,
                  attributeName: att.name,
                  attributeValue: getValue(att.kind),
                ),
              );
            }
          },
        ),
        DividedList(
          items: value,
          builder: (p0, noteAttribute) =>
              AttributeTile(noteAttribute: noteAttribute),
        ),
      ],
    );
  }

  Future<Attribute?> showAttributePicker(BuildContext context) async {
    return await showModalBottomSheet<Attribute>(
      context: context,
      builder: (context) {
        return HookBuilder(
          builder: (context) {
            final query = useState('');

            final future = useMemoized(() {
              return client.run<List<Attribute>>(
                AttributeCommand.search(
                  amount: BigInt.from(10),
                  query: query.value,
                  desc: true,
                ),
              );
            }, [query.value]);

            final allAttributes = useFuture(future);

            return SizedBox(
              height: MediaQuery.sizeOf(
                context,
              ).height, // Set your desired height
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0),
                    child: Column(
                      children: [
                        TextField(
                          onChanged: (value) {
                            query.value = value;
                          },
                        ),
                        if (query.value.isNotEmpty)
                          TextTile(
                            text: context.lang.create_(query.value),
                            onTap: () async {
                              var attribute = await showAttributeCreator(
                                context,
                                query.value,
                              );

                              Navigator.pop(context, attribute);
                            },
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: allAttributes.data?.length ?? 0,
                      itemBuilder: (context, index) {
                        var attribute = allAttributes.data![index];
                        return ListTile(
                          titleAlignment: ListTileTitleAlignment.center,
                          title: Text(
                            attribute.name,
                            textAlign: TextAlign.center,
                          ),
                          onTap: () {
                            Navigator.pop(context, attribute);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

AttributeValue getValue(AttributeKind kind) {
  return switch (kind) {
    AttributeKind.object => AttributeValue.object(
      UuidValue.fromString(UuidV7().toString()),
    ),
    AttributeKind.text => AttributeValue.text(''),
    AttributeKind.number => AttributeValue.number(0),
    AttributeKind.select => AttributeValue.select(''),
    AttributeKind.multiSelect => AttributeValue.multiSelect({}),
    AttributeKind.checkbox => AttributeValue.checkbox(false),
    AttributeKind.datetime => AttributeValue.datetime(DateTime.now()),
    AttributeKind.date => AttributeValue.date(DateTime.now()),
    AttributeKind.time => AttributeValue.time(DateTime.now()),
  };
}

Future<Attribute?> showAttributeCreator(
  BuildContext context,
  String name,
) async {
  return await showDialog<Attribute>(
    context: context,
    builder: (BuildContext context) =>
        Dialog(child: CreateAttributeDialog(name: name)),
  );
}

class AttributeTile extends CortdexWidget {
  const AttributeTile({super.key, required this.noteAttribute, this.onDelete});

  final AttributeWithValue noteAttribute;

  final VoidCallback? onDelete;

  @override
  Widget buildWith(BuildContext context, WidgetRef ref, CortdexClient client) {
    void remove() async {
      Log.d('Removing attribute $noteAttribute');
      await client.run(
        AttributeCommand.removeFromNote(
          name: noteAttribute.name,
          noteId: noteAttribute.noteId,
        ),
      );
      if (onDelete != null) {
        Log.d('Running onDelete');
        onDelete!();
      }
    }

    return Slidable(
      key: const ValueKey(0),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(onDismissed: remove),
        children: [
          SlidableAction(
            onPressed: (context) => remove(),
            backgroundColor: Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: ListTile(
        titleAlignment: ListTileTitleAlignment.center,
        title: Flex(
          direction: Axis.horizontal,
          children: [
            GoodText(noteAttribute.name, type: TextType.button),
            VerticalDivider(),
            // Expanded(child: AttributeValueWidget.from(noteAttribute)),
            AttributeValueWidget.from(noteAttribute),
          ],
        ),
      ),
    );
  }
}

class CreateAttributeDialog extends CortdexWidget {
  const CreateAttributeDialog({super.key, required this.name});

  final String name;

  @override
  Widget buildWith(BuildContext context, WidgetRef ref, CortdexClient client) {
    final searchedAttributeKind = useState(AttributeKind.checkbox);
    final searchedAttributeName = useState(name);

    TextEditingController controller = TextEditingController(
      text: searchedAttributeName.value,
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('Create new attribute.'),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: TextField(controller: controller)),
              DropdownButton<AttributeKind>(
                value: searchedAttributeKind.value,
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                underline: Container(height: 2, color: Colors.deepPurpleAccent),
                onChanged: (AttributeKind? value) {
                  if (value != null) {
                    searchedAttributeKind.value = value;
                    searchedAttributeName.value = controller.text;
                  }
                },
                items: AttributeKind.values
                    .map<DropdownMenuItem<AttributeKind>>((
                      AttributeKind value,
                    ) {
                      return DropdownMenuItem<AttributeKind>(
                        value: value,
                        child: Text(value.name.toTitleCase),
                      );
                    })
                    .toList(),
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              var def = Attribute(
                kind: searchedAttributeKind.value,
                name: controller.text,
              );
              client.run(AttributeCommand.create(def: def));
              Navigator.pop(context, def);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
