import 'package:cortdex/src/dart/client.dart';
import 'package:cortdex/src/rust/third_party/cortdex_types/api/note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cortdex/src/dart/ui/search/search.dart';
import 'package:cortdex/src/dart/ui/omni_button/omni_action.dart';
import 'package:cortdex/src/dart/ui/omni_button/omni_button_provider.dart';
import 'package:cortdex/src/dart/routes/routes.dart';
import 'package:uuid/uuid.dart';

@immutable
class Omnibutton extends HookConsumerWidget {
  const Omnibutton({
    super.key,
    required this.distance,
    required this.children,
  });

  factory Omnibutton.basic(BuildContext context, WidgetRef ref) {
    return Omnibutton(
      distance: 112,
      children: [
        OmniActionClient(
          onPressed: (client) => showNoteDrawer(context),
          icon: Icons.search,
        ),
        OmniActionClient(
          onPressed: (client) async {
            UuidValue? id = (await client.run<Note>(NoteCommand.create()))?.id;
            if (id != null) {
              NoteRoute(id: id.toString()).push(context);
            }
          },
          icon: Icons.add,
        ),
        OmniAction(
          onPressed: () => HomeRoute().go(context),
          icon: Icons.home,
        ),
        OmniAction(
          onPressed: () => SettingsRoute().push(context),
          icon: Icons.settings,
        ),
        /* OmniAction(
          onPressed: () => notificationPlatform.showNotificationIn(),
          icon: Icons.alarm,
        ), */
      ],
    );
  }

  final double distance;
  final List<Widget> children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = ref.watch(omniStateProvider);

    final controller = useAnimationController(
        initialValue: 0.0,
        duration: const Duration(milliseconds: 250),
        vsync: useSingleTickerProvider());

    final Animation<double> expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: controller,
    );

    switch (open) {
      case 0:
        controller.reverse();
        break;
      case 1:
        controller.forward();
        break;
    }

    useAnimation(expandAnimation);

    // TODO: maybe move this outside? To avoid changing the state
    return TapRegion(
        onTapOutside: (event) {
          if (open == 1) {
            ref.read(omniStateProvider.notifier).hide();
          }
        },
        onTapInside: (event) {
          if (open == 1) {
            ref.read(omniStateProvider.notifier).hide();
          }
        },
        child: SizedBox.expand(
          child: Stack(
            alignment: Alignment.bottomRight,
            clipBehavior: Clip.none,
            children: [
              _buildTapToCloseFab(context, ref),
              ..._buildExpandingActionButtons(expandAnimation),
              _buildTapToOpenFab(open == 1, ref),
            ],
          ),
        ));
  }

  Widget _buildTapToCloseFab(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          child: InkWell(
            onTap: ref.read(omniStateProvider.notifier).hide,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.close,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons(Animation<double> expandAnimation) {
    final innerChildren = <Widget>[];
    final count = children.length;
    final step = 90.0 / (count - 1);
    for (var i = 0, angleInDegrees = 0.0;
        i < count;
        i++, angleInDegrees += step) {
      innerChildren.add(
        ExpandingOmniAction(
          directionInDegrees: angleInDegrees,
          maxDistance: distance,
          progress: expandAnimation,
          child: children[i],
        ),
      );
    }
    return innerChildren;
  }

  Widget _buildTapToOpenFab(bool open, WidgetRef ref) {
    return IgnorePointer(
      ignoring: open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          open ? 0.7 : 1.0,
          open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: LongPressDraggable<String>(
            delay: const Duration(milliseconds: 100),
            data: 'Hola',
            onDragStarted: ref.read(omniStateProvider.notifier).show,
            onDragCompleted: ref.read(omniStateProvider.notifier).hide,
            feedback: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.create),
            ),
            child: FloatingActionButton(
              onPressed: ref.read(omniStateProvider.notifier).show,
              child: const Icon(Icons.create),
            ),
          ),
        ),
      ),
    );
  }

  static void showNoteDrawer(BuildContext context) {
    showModalBottomSheet(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (context) {
        return SearchDrawer();
      },
      context: context,
      isDismissible: true,
    );
  }
}
