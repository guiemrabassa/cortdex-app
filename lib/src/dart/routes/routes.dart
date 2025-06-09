import 'package:cortdex/src/dart/helpers/debug.dart';
import 'package:cortdex/src/dart/ui/cortdex_widget.dart';
import 'package:cortdex/src/dart/ui/settings/client_settings.dart';
import 'package:cortdex/src/dart/ui/settings/note_settings.dart';
import 'package:cortdex/src/dart/ui/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cortdex/src/dart/ui/home.dart';
import 'package:cortdex/src/dart/ui/editor/note_editor.dart';

import 'package:cortdex/src/dart/ui/omni_button/omni_button.dart';
import 'package:cortdex/src/dart/settings/settings.dart';
import 'package:uuid/uuid_value.dart';

part 'routes.g.dart';

/* 

INFO: https://canopas.com/how-to-implement-type-safe-navigation-with-go-router-in-flutter-b11315bd183b

https://codewithandrea.com/articles/flutter-bottom-navigation-bar-nested-routes-gorouter/

*/

final GoRouter mainRouter = GoRouter(
    initialLocation: HomeRoute().location,
    routes: $appRoutes,
    navigatorKey: rootNavigatorKey);

final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();



@TypedShellRoute<MainShellRoute>(
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<HomeRoute>(path: '/'),
    TypedGoRoute<NoteRoute>(path: '/note/:id'),
  ],
)
class MainShellRoute extends ShellRouteData {
  const MainShellRoute();

  static final GlobalKey<NavigatorState> $navigatorKey = shellNavigatorKey;

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return MainShell(child: navigator);
  }
}

class MainShell extends HookConsumerWidget {
  const MainShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      floatingActionButton: Omnibutton.basic(context, ref),
      body: child,
    );
  }
}

class HomeRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const Homepage();
  }
}

class NoteRoute extends GoRouteData {
  const NoteRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    Log.i('Entering note route: $id');
    
    return CortdexWidgetWrapper(child: (client) {
      return NoteEditorWidget(id: UuidValue.fromString(id), client: client);
    });
  }
}


@TypedGoRoute<SettingsRoute>(path: '/settings', routes: <TypedRoute<RouteData>>[
  TypedGoRoute<ConnectionSettingsRoute>(path: 'connection'),
  TypedGoRoute<NoteSettingsRoute>(path: 'notes'),
])
class SettingsRoute extends GoRouteData {
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SettingsWidget();
  }
}

class ConnectionSettingsRoute extends GoRouteData {
  const ConnectionSettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ClientSettingsPage();
  }
}

class NoteSettingsRoute extends GoRouteData {
  const NoteSettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return NoteSettingsPage();
  }
}

// https://croxx5f.hashnode.dev/adding-modal-routes-to-your-gorouter
/// A dialog page with Material entrance and exit animations, modal barrier color,
/// and modal barrier behavior (dialog is dismissible with a tap on the barrier).
class DialogPage<T> extends Page<T> {
  final Offset? anchorPoint;
  final Color? barrierColor;
  final bool barrierDismissible;
  final String? barrierLabel;
  final bool useSafeArea;
  final CapturedThemes? themes;
  final WidgetBuilder builder;

  const DialogPage({
    required this.builder,
    this.anchorPoint,
    this.barrierColor = Colors.black54,
    this.barrierDismissible = true,
    this.barrierLabel,
    this.useSafeArea = true,
    this.themes,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route<T> createRoute(BuildContext context) => DialogRoute<T>(
      context: context,
      settings: this,
      builder: builder,
      anchorPoint: anchorPoint,
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      themes: themes);
}

class BottomSheetPage<T> extends Page<T> {
  final Widget child;
  final bool showDragHandle;
  final bool useSafeArea;

  const BottomSheetPage({
    required this.child,
    this.showDragHandle = false,
    this.useSafeArea = true,
    super.key,
  });

  @override
  Route<T> createRoute(BuildContext context) => ModalBottomSheetRoute<T>(
        settings: this,
        isScrollControlled: true,
        showDragHandle: showDragHandle,
        useSafeArea: useSafeArea,
        backgroundColor: Colors.transparent,
        builder: (context) => child,
      );
}
