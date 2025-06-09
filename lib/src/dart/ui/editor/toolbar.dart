import 'package:cortdex/src/dart/ui/components/list.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'package:flutter/material.dart';

/// Custom toolbar that uses the buttons of [`flutter_quill`](https://pub.dev/packages/flutter_quill).
///
/// See also: [Custom toolbar](https://github.com/singerdmx/flutter-quill/blob/master/doc/custom_toolbar.md).
class CustomToolbar extends StatelessWidget {
  const CustomToolbar({super.key, required this.controller});

  final QuillController controller;

  @override
  Widget build(BuildContext context) {
    return VerticalDividedRow(
      children: [
        [
          QuillToolbarHistoryButton(isUndo: true, controller: controller),
          QuillToolbarHistoryButton(isUndo: false, controller: controller),
        ],
        [
          QuillToolbarToggleStyleButton(
            options: const QuillToolbarToggleStyleButtonOptions(),
            controller: controller,
            attribute: Attribute.bold,
          ),
          QuillToolbarToggleStyleButton(
            options: const QuillToolbarToggleStyleButtonOptions(),
            controller: controller,
            attribute: Attribute.italic,
          ),
          QuillToolbarToggleStyleButton(
            controller: controller,
            attribute: Attribute.underline,
          ),
          QuillToolbarClearFormatButton(controller: controller),
        ],
        [
          QuillToolbarSelectHeaderStyleDropdownButton(controller: controller),
          QuillToolbarSelectLineHeightStyleDropdownButton(
            controller: controller,
          ),
        ],
        [
          QuillToolbarToggleCheckListButton(controller: controller),
          QuillToolbarToggleStyleButton(
            controller: controller,
            attribute: Attribute.ol,
          ),
          QuillToolbarToggleStyleButton(
            controller: controller,
            attribute: Attribute.ul,
          ),
        ],
        [
          QuillToolbarIndentButton(controller: controller, isIncrease: true),
          QuillToolbarIndentButton(controller: controller, isIncrease: false),
          QuillToolbarToggleStyleButton(
            controller: controller,
            attribute: Attribute.inlineCode,
          ),
          QuillToolbarToggleStyleButton(
            controller: controller,
            attribute: Attribute.blockQuote,
          ),
          QuillToolbarLinkStyleButton(controller: controller),
        ],
      ],
    );
  }
}
