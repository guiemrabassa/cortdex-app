



import 'package:flutter/material.dart';

class GoodText extends StatelessWidget {
  const GoodText(this.data, {super.key, required this.type, this.textAlign = TextAlign.center});

  final String data;
  final TextType type;

  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Padding(padding: type.insets(), child: Text(data, textAlign: textAlign, textScaler: TextScaler.linear(type.fontSize())));
  }

}

enum TextType {
  title,
  subtitle,
  button 
}

extension on TextType {

  EdgeInsetsGeometry insets() {
    return switch (this) {
      TextType.title => EdgeInsetsGeometry.directional(start: 5.0, end: 5.0),
      TextType.subtitle => EdgeInsetsGeometry.directional(start: 3.0, end: 3.0),
      TextType.button => EdgeInsetsGeometry.directional(start: 4.0, end: 4.0, bottom: 2.0, top: 2.0),
    };
  }

  double fontSize() {
    return switch (this) {
      TextType.title => 1.6,
      TextType.subtitle => 1.4,
      TextType.button => 1,
    };
  }

}