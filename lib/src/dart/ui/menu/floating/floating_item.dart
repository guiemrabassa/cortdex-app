





import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';



abstract class FloatingMenuEntry<T> {

}

class FloatingMenuButton<T> extends HookConsumerWidget implements FloatingMenuEntry<T> {
  const FloatingMenuButton({super.key, required this.title, required this.onPressed});

  final void Function() onPressed;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {    
    return ListTile(
      title: Text(title),
      onTap: () {
        onPressed();
      },
    );
  }

}

class NewFloatingMenuButton<T> extends HookConsumerWidget implements FloatingMenuEntry<T> {
  const NewFloatingMenuButton({super.key, required this.title, required this.valueChanged, required this.valueGen});

  final String title;

  final void Function(T) valueChanged;
  final T Function() valueGen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {    
    return ListTile(
      title: Text(title),
      onTap: () {
        valueChanged(valueGen());
      },
    );
  }

}