import 'dart:math' as math;

import 'package:cortdex/src/dart/client.dart';
import 'package:cortdex/src/dart/ui/cortdex_widget.dart';
import 'package:cortdex/src/rust/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/src/core.dart';


class ExpandingOmniAction extends StatelessWidget {
  const ExpandingOmniAction({
    super.key,
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (math.pi / 180.0),
          progress.value * maxDistance,
        );
        return Positioned(
          right: 4.0 + offset.dx,
          bottom: 4.0 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * math.pi / 2,
            child: child!,
          ),
        );
      },
      child: FadeTransition(opacity: progress, child: child),
    );
  }
}

@immutable
class OmniAction extends StatelessWidget {
  const OmniAction({super.key, this.onPressed, required this.icon});

  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DragTarget<String>(
      builder: (context, candidateData, rejectedData) {
        return Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          color: theme.colorScheme.secondary,
          elevation: 4,
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon),
            color: theme.colorScheme.onSecondary,
          ),
        );
      },
      onAcceptWithDetails: (details) {
        if (onPressed != null) {
          onPressed!();
        }
      },
    );
  }
}


class OmniActionClient extends CortdexWidget {
  const OmniActionClient({super.key, this.onPressed, required this.icon});

  final void Function(CortdexClient)? onPressed;
  final IconData icon;

  @override
  Widget buildWithout(BuildContext context, WidgetRef ref) {
    return OmniAction(onPressed: null, icon: icon);
  }

  @override
  Widget buildWith(BuildContext context, WidgetRef ref, CortdexClient client) {
    return OmniAction(onPressed: () {
      if (onPressed != null) {
        onPressed!(client);
      }
    }, icon: icon);
  }
  
}