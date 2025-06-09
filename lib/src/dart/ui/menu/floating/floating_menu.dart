import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cortdex/src/dart/ui/menu/floating/floating_item.dart';

// https://medium.com/snapp-x/creating-custom-dropdowns-with-overlayportal-in-flutter-4f09b217cfce

class FloatingMenu<T> extends HookConsumerWidget {
  const FloatingMenu(
      {super.key,
      this.options,
      this.onSelection,
      required this.title,
      this.children});

  final String title;
  final List<(String, T)>? options;
  final ValueChanged<(String, T)>? onSelection;
  final List<Widget>? children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OverlayPortalController tooltipController =
        OverlayPortalController();

    final link = LayerLink();

    final state = useState<T?>(null);

    double? buttonWidth;

    return CompositedTransformTarget(
      link: link,
      child: OverlayPortal(
        controller: tooltipController,
        overlayChildBuilder: (BuildContext context) {
          return CompositedTransformFollower(
            link: link,
            targetAnchor: Alignment.bottomLeft,
            child: Align(
                alignment: AlignmentDirectional.topStart,
                child: Container(
                  width: buttonWidth ?? 200,
                  // height: 300,
                  decoration: ShapeDecoration(
                    color: Colors.black26,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1.5,
                        color: Colors.black26,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x11000000),
                        blurRadius: 32,
                        offset: Offset(0, 20),
                        spreadRadius: -8,
                      ),
                    ],
                  ),
                  child: ListView(
                      children: (children ?? [])
                        ..addAll(options?.map<FloatingMenuButton>((option) {
                              return FloatingMenuButton(
                                title: option.$1,
                                onPressed: () {
                                  state.value = option.$2;
                                  if (onSelection != null) {
                                    onSelection!(option);
                                    tooltipController.toggle();
                                  }
                                },
                              );
                            }).toList() ??
                            [])),
                )),
          );
        },
        child: TextButton(
          onPressed: () {
            buttonWidth = context.size?.width;
            tooltipController.toggle();
          },
          child: Text(title),
        ),
      ),
    );
  }
}


class NewFloatingMenu<T> extends HookConsumerWidget {
  const NewFloatingMenu(
      {super.key,
      this.options,
      this.onSelection,
      required this.title,
      this.children});

  final String title;
  final List<(String, T)>? options;
  final ValueChanged<T>? onSelection;
  final List<Widget>? children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OverlayPortalController tooltipController =
        OverlayPortalController();

    final link = LayerLink();

    double? buttonWidth;

    return CompositedTransformTarget(
      link: link,
      child: OverlayPortal(
        controller: tooltipController,
        overlayChildBuilder: (BuildContext context) {
          return CompositedTransformFollower(
            link: link,
            targetAnchor: Alignment.bottomLeft,
            child: Align(
                alignment: AlignmentDirectional.topStart,
                child: Container(
                  width: buttonWidth ?? 200,
                  // height: 300,
                  decoration: ShapeDecoration(
                    color: Colors.black26,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1.5,
                        color: Colors.black26,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x11000000),
                        blurRadius: 32,
                        offset: Offset(0, 20),
                        spreadRadius: -8,
                      ),
                    ],
                  ),
                  child: ListView(
                      children: (children ?? [])
                        ..addAll(options?.map<NewFloatingMenuButton>((option) {
                              return NewFloatingMenuButton<T>(
                                valueChanged: (p0) {
                                  onSelection!(p0);
                                  tooltipController.toggle();
                                },
                                valueGen: () => option.$2,
                                title: option.$1,
                              );
                            }).toList() ??
                            [])),
                )),
          );
        },
        child: TextButton(
          onPressed: () {
            buttonWidth = context.size?.width;
            tooltipController.toggle();
          },
          child: Text(title),
        ),
      ),
    );
  }
}
