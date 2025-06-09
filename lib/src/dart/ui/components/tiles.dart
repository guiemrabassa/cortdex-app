import 'package:cortdex/src/dart/ui/components/text.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TextTile extends HookConsumerWidget {
  const TextTile({super.key, required this.text, required this.onTap, this.textAlign = TextAlign.center});

  final VoidCallback onTap;
  final String text;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      onTap: onTap,
      title: GoodText(text, type: TextType.button, textAlign: textAlign),
    );
  }
}
