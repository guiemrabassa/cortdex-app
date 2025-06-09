


import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DividedList<T> extends HookConsumerWidget {
  const DividedList({super.key, required this.items, required this.builder, this.divider = const Divider()});

  final List<T> items;
  final Widget Function(int, T) builder;
  final Widget divider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    var list = List.empty(growable: true);

    for (var (index, item) in items.indexed) {
      list.add(builder(index, item));
      if (index != items.length -1) list.add(Divider());
    }

    

    return Expanded(
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          return list[index];
        },
      ),
    );
  }

}


class VerticalDividedRow extends StatelessWidget {
  const VerticalDividedRow({super.key, required this.children});

  final List<List<Widget>> children;

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetsWithDividers = [];

    for (int i = 0; i < children.length; i++) {
      widgetsWithDividers.addAll(children[i]);

      if (i < children.length - 1) {
        widgetsWithDividers.add(
          SizedBox(height: 40.0, child: const VerticalDivider(
            width: 20.0,
            thickness: 1.0,
            color: Colors.grey,
          ))
        );
      }
    }

    return DefaultTextStyle(
      style: Theme.of(context).textTheme.bodyMedium!,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: viewportConstraints.maxWidth),
              child: IntrinsicHeight(
                child: Wrap(
                  children: widgetsWithDividers,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}