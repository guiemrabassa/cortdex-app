


import 'package:flutter/material.dart';

class LabelWithField extends StatelessWidget {
  const LabelWithField({
    super.key,
    required this.label,
    this.hint,
    this.value,
    required this.onChanged,
  });

  final String label;
  final String? hint;
  final String? value;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label),
        Expanded(
          child: TextField(
            controller: TextEditingController(text: value),
            decoration: InputDecoration(hintText: hint),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}