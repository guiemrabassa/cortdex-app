

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SaveButton extends HookConsumerWidget {
  const SaveButton({super.key, required this.onSave, required this.color});

  final Future<void> Function() onSave;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(icon: Icon(Icons.circle), color: color,  onPressed: () async {
      await onSave();
    });
  }

}