import 'package:cortdex/src/dart/helpers/debug.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SearchField extends HookConsumerWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final possibles = ['has', 'is'];

    final list = useState(<String>[]);

    var suggestions = useState([]);

    final focus = useFocusNode();

    void onChipDeleted(String topping) {
      list.value = list.value..remove(topping);
      suggestions.value = <String>[];
    }

    void onSubmitted(String text) {
    if (text.trim().isNotEmpty) {
      list.value = <String>[...list.value, text.trim()];
    } else {
      list.value = <String>[];
    }
  }

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
          child: ChipsInput<String>(
            focus: focus,
            onChipTapped: (value) {
              
            },
            onSubmitted: onSubmitted,
              values: list.value,
              chipBuilder: (context, data) {
                return TextFieldChipInput(
                    title: data,
                    onTap: () {
                      focus.unfocus();
                    },
                    onChanged: (String value) {

                    },
                    onDeleted: onChipDeleted);
              },
              onTextChanged: (value) {
                Log.d('Text changed $value');
                if (value.isNotEmpty) {
                  suggestions.value = possibles.where((String s) {
                    return s.toLowerCase().contains(value.toLowerCase()) &&
                        !list.value.contains(s.toLowerCase());
                  }).toList();
                }
              },
              onChanged: (value) {
                list.value = value;
                Log.d('Changed $value');
              }),
        ),
        if (suggestions.value.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: suggestions.value.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(suggestions.value[index]),
                  onTap: () {
                    list.value = list.value..add(suggestions.value[index]);
                    suggestions.value = [];
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}

class TextFieldChipInput extends HookWidget {
  final String title;
  final double minWidth;
  final double maxWidth;

  final ValueChanged<String> onChanged;
  final ValueChanged<String> onDeleted;
  final void Function() onTap;

  const TextFieldChipInput( 
      {super.key,
      required this.title,
      this.minWidth = 50.0,
      this.maxWidth = 300.0,
      required this.onChanged,
      required this.onDeleted,
      required this.onTap
      });

  @override
  Widget build(BuildContext context) {

    Log.d('Rebuilt');

    final focus = useFocusNode();

    final textController = useTextEditingController();
    final textWidth = useState(minWidth);

    // Update the width dynamically when the text changes
    void updateWidth() {
      final text = textController.text;

      Log.d(text);

      if (text.isEmpty) {
        textWidth.value = minWidth;
        return;
      }

      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(fontSize: 14.0),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      textWidth.value = textPainter.width.clamp(minWidth, maxWidth);
    }

    useEffect(() {
      textController.addListener(updateWidth);
      return () => textController.removeListener(updateWidth);
    }, [textController]);

    

    return Container(
        margin: const EdgeInsets.only(right: 3),
        child: InputChip(
          key: ObjectKey(title),
          onDeleted: () => onDeleted(title),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title),
              SizedBox(
                width: textWidth.value,
                child: TextField(
                  focusNode: focus,
                  controller: textController,
                  onTap: () {
                    onTap();
                    focus.requestFocus();
                  },
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                  style:
                      const TextStyle(fontSize: 14.0), // Match Chip text style
                  onChanged: (value) {
                    onChanged(value);
                  },
                ),
              ),
            ],
          ),
        ));
  }
}

class ChipsInput<T> extends HookConsumerWidget {
  const ChipsInput({
    super.key,
    required this.values,
    this.decoration = const InputDecoration(),
    this.style,
    this.strutStyle,
    required this.chipBuilder,
    required this.onChanged,
    this.onChipTapped,
    this.onSubmitted,
    this.onTextChanged,
    this.focus,
  });

  final List<T> values;
  final InputDecoration decoration;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final FocusNode? focus;

  final ValueChanged<List<T>> onChanged;
  final ValueChanged<T>? onChipTapped;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onTextChanged;

  final Widget Function(BuildContext context, T data) chipBuilder;

  static int countReplacements(String text) {
    return text.codeUnits
        .where(
            (int u) => u == ChipsInputEditingController.kObjectReplacementChar)
        .length;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useMemoized(() {
      return ChipsInputEditingController<T>([...values], chipBuilder);
    }, [values.length]);

    final ValueNotifier<String> previousText = useState('');
    final ValueNotifier<TextSelection?> previousSelection = useState(null);

    void textListener() {
      final String currentText = controller.value.text;

      if (previousSelection.value != null) {
        final int currentNumber = countReplacements(currentText);
        final int previousNumber = countReplacements(previousText.value);

        final int cursorEnd = previousSelection.value!.extentOffset;
        final int cursorStart = previousSelection.value!.baseOffset;

        final List<T> innerValues = <T>[...values];

        // If the current number and the previous number of replacements are different, then
        // the user has deleted the InputChip using the keyboard. In this case, we trigger
        // the onChanged callback. We need to be sure also that the current number of
        // replacements is different from the input chip to avoid double-deletion.
        if (currentNumber < previousNumber &&
            currentNumber != innerValues.length) {
          if (cursorStart == cursorEnd) {
            innerValues.removeRange(cursorStart - 1, cursorEnd);
          } else {
            if (cursorStart > cursorEnd) {
              innerValues.removeRange(cursorEnd, cursorStart);
            } else {
              innerValues.removeRange(cursorStart, cursorEnd);
            }
          }
          onChanged(innerValues);
        }
      }

      previousText.value = currentText;
      previousSelection.value = controller.value.selection;
    }

    useEffect(() {
      controller.addListener(textListener);

      return () {
        controller.removeListener(textListener);
      };
    }, [controller]);

    return TextField(
      minLines: 1,
      maxLines: 3,
      focusNode: focus,
      textInputAction: TextInputAction.done,
      style: style,
      strutStyle: strutStyle,
      controller: controller,
      onChanged: (String value) =>
          onTextChanged?.call(controller.textWithoutReplacements),
      onSubmitted: (String value) =>
          onSubmitted?.call(controller.textWithoutReplacements),
    );
  }
}

class ChipsInputEditingController<T> extends TextEditingController {
  ChipsInputEditingController(this.values, this.chipBuilder)
      : super(
          text: String.fromCharCode(kObjectReplacementChar) * values.length,
        );

  // This constant character acts as a placeholder in the TextField text value.
  // There will be one character for each of the InputChip displayed.
  static const int kObjectReplacementChar = 0xFFFE;

  List<T> values;

  final Widget Function(BuildContext context, T data) chipBuilder;

  /// Called whenever chip is either added or removed
  /// from the outside the context of the text field.
  void updateValues(List<T> values) {
    if (values.length != this.values.length) {
      final String char = String.fromCharCode(kObjectReplacementChar);
      final int length = values.length;
      value = TextEditingValue(
        text: char * length,
        selection: TextSelection.collapsed(offset: length),
      );
      this.values = values;
    }
  }

  String get textWithoutReplacements {
    final String char = String.fromCharCode(kObjectReplacementChar);
    return text.replaceAll(RegExp(char), '');
  }

  String get textWithReplacements => text;

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    final Iterable<WidgetSpan> chipWidgets =
        values.map((T v) => WidgetSpan(child: chipBuilder(context, v)));

    return TextSpan(
      style: style,
      children: <InlineSpan>[
        ...chipWidgets,
        if (textWithoutReplacements.isNotEmpty)
          TextSpan(text: textWithoutReplacements)
      ],
    );
  }
}
