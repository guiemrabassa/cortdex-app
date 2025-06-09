import 'package:cortdex/src/dart/client.dart';
import 'package:cortdex/src/dart/helpers/context.dart';
import 'package:cortdex/src/dart/ui/components/tiles.dart';
import 'package:cortdex/src/dart/ui/cortdex_widget.dart';
import 'package:cortdex/src/rust/api.dart';
import 'package:cortdex/src/rust/third_party/cortdex_types/api/attribute.dart';
import 'package:cortdex/src/rust/third_party/cortdex_types/api/note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cortdex/src/dart/helpers/async_snapshot.dart';

import 'package:numberpicker/numberpicker.dart';

abstract class AttributeValueWidget extends CortdexWidget {
  const AttributeValueWidget({super.key, required this.noteAttribute});

  final AttributeWithValue noteAttribute;

  factory AttributeValueWidget.from(AttributeWithValue attribute) {
    return switch (attribute.value) {
      AttributeValue_Object() => throw UnimplementedError(),
      AttributeValue_Text() => _Text(noteAttribute: attribute),
      AttributeValue_Number() => _Number(noteAttribute: attribute),
      AttributeValue_Select() => _Select(noteAttribute: attribute),
      AttributeValue_MultiSelect() => _MultiSelect(noteAttribute: attribute),
      AttributeValue_Checkbox() => _Checkbox(noteAttribute: attribute),
      AttributeValue_Datetime() => _DateTime(noteAttribute: attribute),
      AttributeValue_Date() => _Date(noteAttribute: attribute),
      AttributeValue_Time() => _Time(noteAttribute: attribute),
    };
  }

  void updateValue(CortdexClient client, AttributeValue attributeValue) {
    client.run(
      AttributeCommand.updateValueOnNote(
        noteId: noteAttribute.noteId,
        attributeName: noteAttribute.name,
        attributeValue: attributeValue,
      ),
    );
  }
}

abstract class AttributeValueWidgetPicker<T> extends AttributeValueWidget {
  const AttributeValueWidgetPicker({super.key, required super.noteAttribute});

  T getInitialState() => noteAttribute.value.field0 as T;

  String getText(T content);

  Future<AttributeValue> getNewValue(
    BuildContext context,
    ValueNotifier<T> state,
  );

  @override
  Widget buildWith(BuildContext context, WidgetRef ref, CortdexClient client) {
    final state = useState(getInitialState());
    return ListTile(
      title: Text(getText(state.value), textAlign: TextAlign.center),
      onTap: () async {
        updateValue(client, await getNewValue(context, state));
      },
    );
  }
}

class _Date extends AttributeValueWidgetPicker<DateTime> {
  const _Date({required super.noteAttribute});

  @override
  DateTime getInitialState() =>
      (noteAttribute.value.field0 as DateTime).toLocal();

  @override
  Future<AttributeValue> getNewValue(
    BuildContext context,
    ValueNotifier<DateTime> state,
  ) async {
    state.value =
        await showDatePicker(
          context: context,
          initialDate: state.value,
          firstDate: DateTime(0),
          lastDate: DateTime(3000),
        ) ??
        state.value;

    return AttributeValue.date(state.value.toUtc());
  }

  @override
  String getText(DateTime content) {
    final outputFormat = DateFormat('MM/dd/yyyy');
    return outputFormat.format(content);
  }
}

class _Time extends AttributeValueWidgetPicker<TimeOfDay> {
  const _Time({required super.noteAttribute});

  @override
  TimeOfDay getInitialState() => TimeOfDay.fromDateTime(
    (noteAttribute.value.field0 as DateTime).toLocal(),
  );

  @override
  String getText(TimeOfDay content) {
    return '${content.hour}:${content.minute}';
  }

  @override
  Future<AttributeValue> getNewValue(
    BuildContext context,
    ValueNotifier<TimeOfDay> state,
  ) async {
    state.value =
        await showTimePicker(context: context, initialTime: state.value) ??
        state.value;
    return AttributeValue.time(
      DateTime(
        0,
      ).copyWith(hour: state.value.hour, minute: state.value.minute).toUtc(),
    );
  }
}

class _DateTime extends AttributeValueWidgetPicker<DateTime> {
  const _DateTime({required super.noteAttribute});

  @override
  DateTime getInitialState() =>
      (noteAttribute.value.field0 as DateTime).toLocal();

  @override
  Future<AttributeValue> getNewValue(
    BuildContext context,
    ValueNotifier<DateTime> state,
  ) async {
    state.value =
        await showDatePicker(
          context: context,
          initialDate: state.value,
          firstDate: DateTime(0),
          lastDate: DateTime(3000),
        ) ??
        state.value;

    TimeOfDay time =
        await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(state.value),
        ) ??
        TimeOfDay.fromDateTime(state.value);

    state.value = state.value.copyWith(hour: time.hour, minute: time.minute);

    return AttributeValue.datetime(state.value.toUtc());
  }

  @override
  String getText(DateTime content) {
    final outputFormat = DateFormat('MM/dd/yyyy HH:mm');
    return outputFormat.format(content);
  }
}

class _Text extends AttributeValueWidget {
  const _Text({required super.noteAttribute});

  @override
  Widget buildWith(BuildContext context, WidgetRef ref, CortdexClient client) {
    final controller = useTextEditingController(
      text: noteAttribute.value.field0 as String,
    );

    return Expanded(
      child: TextField(
        controller: controller,
        onChanged: (value) {
          updateValue(client, AttributeValue.text(value));
        },
      ),
    );
  }
}

class _Number extends AttributeValueWidget {
  const _Number({required super.noteAttribute});

  @override
  Widget buildWith(BuildContext context, WidgetRef ref, CortdexClient client) {
    final numberValue = useState(noteAttribute.value.field0 as double);

    return DecimalNumberPicker(
      value: numberValue.value,
      minValue: 0,
      maxValue: 100,
      onChanged: (value) {
        numberValue.value = value;
        updateValue(client, AttributeValue.number(value));
      },
    );
  }
}

class _Checkbox extends AttributeValueWidget {
  const _Checkbox({required super.noteAttribute});

  @override
  Widget buildWith(BuildContext context, WidgetRef ref, CortdexClient client) {
    final boolValue = useState(noteAttribute.value.field0 as bool);

    return Checkbox(
      value: boolValue.value,
      onChanged: (value) {
        boolValue.value = value ?? false;
        updateValue(client, AttributeValue.checkbox(value ?? false));
      },
    );
  }
}

class _Select extends AttributeValueWidget {
  const _Select({required super.noteAttribute});

  @override
  Widget buildWith(BuildContext context, WidgetRef ref, CortdexClient client) {
    final selectValue = useState(noteAttribute.value.field0 as String);

    return ListTile(
      title: Text(selectValue.value),
      onTap: () async {
        final String selected =
            await showSelectPicker(
              context,
              Attribute(name: noteAttribute.name, kind: noteAttribute.kind),
              client,
            ) ??
            '';

        selectValue.value = selected;
      },
    );
  }

  Future<String?> showSelectPicker(
    BuildContext context,
    Attribute noteAttribute,
    CortdexClient client,
  ) async {
    return await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return HookBuilder(
          builder: (context) {
            final query = useState('');

            final future = useMemoized(() {
              return client.run(
                AttributeCommand.getAllFromSelectable(
                  attributeName: noteAttribute.name,
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
                              var attribute =
                                  /* await Connection().client?.addToSelectable(
                                          attributeName: noteAttribute.name,
                                          newSelectable: query.value); */
                                  Navigator.pop(context, query.value);
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
                          title: Text(attribute, textAlign: TextAlign.center),
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

class _MultiSelect extends AttributeValueWidget {
  const _MultiSelect({required super.noteAttribute});

  @override
  Widget buildWith(BuildContext context, WidgetRef ref, CortdexClient client) {
    final selectValue = useState(noteAttribute.value.field0 as Set<String>);

    return ListTile(
      title: Text(selectValue.value.join(', ')),
      onTap: () async {
        await showSelectPicker(
          context,
          Attribute(name: noteAttribute.name, kind: noteAttribute.kind),
          client,
        );
        // TODO: Check if this is ok
        selectValue.value =
            (await client.run(
                  AttributeCommand.getAllFromSelectable(
                    attributeName: noteAttribute.name,
                  ),
                ))
                as Set<String>;
      },
    );
  }

  Future<List<String>?> showSelectPicker(
    BuildContext context,
    Attribute noteAttribute,
    CortdexClient client,
  ) async {
    return await showModalBottomSheet<List<String>>(
      context: context,
      builder: (context) {
        return HookBuilder(
          builder: (context) {
            final query = useState('');
            final selected = useState(noteAttribute.options as Set<String>);

            final future = useMemoized(() {
              return client.run(
                AttributeCommand.getAllFromSelectable(
                  attributeName: noteAttribute.name,
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
                              var newSelectable = query.value;

                              // Forces detection of change and rebuilds the selectable list
                              query.value = ' ';

                              /* await Connection().client?.addToSelectable(
                                      attributeName: noteAttribute.name,
                                      newSelectable: newSelectable); */
                              selected.value = selected.value.union({
                                newSelectable,
                              });

                              // TODO: FIX
                              /* await Connection().client?.updateValueOnNote(
                                    attributeName: noteAttribute.name, attributeValue: AttributeValue.multiSelect(
                                              selected.value), noteId: noteAttribute.); */

                              // Waits so the value notifier notices the change
                              Future.delayed(Duration(milliseconds: 10), () {
                                query.value = newSelectable;
                              });
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
                          selected: selected.value.contains(attribute),
                          title: Text(attribute, textAlign: TextAlign.center),
                          onTap: () async {
                            if (selected.value.contains(attribute)) {
                              selected.value = selected.value.difference({
                                attribute,
                              });
                            } else {
                              selected.value = selected.value.union({
                                attribute,
                              });
                            }

                            // TODO: Fix
                            /* await Connection().client?.updateValueOnNote(attributeName: noteAttribute.name, attributeValue: AttributeValue.multiSelect(
                                            selected.value)); */
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

class _Object extends AttributeValueWidget {
  const _Object({required super.noteAttribute});

  @override
  Widget buildWith(BuildContext context, WidgetRef ref, CortdexClient client) {
    final searchQuery = useState('');
    final noteList = useFuture(
      client.run(
        NoteQuery.basic(amount: BigInt.from(5), text: searchQuery.value),
      ),
    );

    return SizedBox(
      height: MediaQuery.sizeOf(context).height, // Set your desired height
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0),
            child: TextField(onChanged: (value) => searchQuery.value = value),
          ),
          Expanded(
            child: switch (noteList.asAsyncValue()) {
              AsyncData(:final value) => ListView.builder(
                itemCount: value.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(value[index].title),
                    onTap: () {},
                  );
                },
              ),
              AsyncError(:final error) => Center(
                child: Text(context.lang.error(': $error')),
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ],
      ),
    );
  }
}

/* 
class SearchList<T> extends HookConsumerWidget {



  final Future<List<T>> futureList;


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = useState('');

    final future = useMemoized(() {
      return futureList;
    }, [query.value]);

    final allAttributes = useFuture(future);

    return SizedBox(
        height: MediaQuery.sizeOf(context).height, // Set your desired height
        child: Column(
          children: [
            /* Container(
                        padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0),
                        child: Column(
                          children: [
                            TextField(onChanged: (value) {
                              query.value = value;
                            }),
                            if (query.value.isNotEmpty)
                              ListTile(
                                titleAlignment: ListTileTitleAlignment.center,
                                title: Text('Create ${query.value}',
                                    textAlign: TextAlign.center),
                                onTap: () async {
                                  var attribute = await showAttributeCreator(
                                      context, query.value);

                                  Navigator.pop(context, attribute);
                                },
                              )
                          ],
                        )), */
            Expanded(
              child: ListView.builder(
                  itemCount: allAttributes.data?.length ?? 0,
                  itemBuilder: (context, index) {
                    var value = allAttributes.data![index];
                    return ListTile(
                      titleAlignment: ListTileTitleAlignment.center,
                      title: Text(value, textAlign: TextAlign.center),
                      onTap: () {
                        Navigator.pop(context, value);
                      },
                    );
                  }),
            ),
          ],
        ));
  }
} */
