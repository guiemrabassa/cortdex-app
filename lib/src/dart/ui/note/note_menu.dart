import 'package:cortdex/src/dart/ui/components/text.dart';
import 'package:cortdex/src/dart/ui/cortdex_widget.dart';
import 'package:cortdex/src/rust/api.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cortdex/src/dart/ui/attributes/attribute_list.dart';
import 'package:uuid/uuid_value.dart';

class NoteMenu extends CortdexWidget {
  const NoteMenu({super.key, required this.id});

  final UuidValue id;

  @override
  Widget buildWith(BuildContext context, WidgetRef ref, CortdexClient client) {
    return Column(
      children: [
        GoodText('Note Menu', type: TextType.subtitle),
        Expanded(child: AttributeList(id: id, client: client))
      ],
    );
  }
  
}