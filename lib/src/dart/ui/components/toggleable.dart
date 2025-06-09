import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Toggleable extends HookConsumerWidget {
  const Toggleable(this.child, {super.key, this.enabled = true});

  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return enabled ? child : AbsorbPointer(child: Opacity(opacity: 0.3, child: child));
  }
}