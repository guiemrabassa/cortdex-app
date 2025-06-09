// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$mainShellRoute, $settingsRoute];

RouteBase get $mainShellRoute => ShellRouteData.$route(
  navigatorKey: MainShellRoute.$navigatorKey,
  factory: $MainShellRouteExtension._fromState,
  routes: [
    GoRouteData.$route(path: '/', factory: $HomeRouteExtension._fromState),
    GoRouteData.$route(
      path: '/note/:id',

      factory: $NoteRouteExtension._fromState,
    ),
  ],
);

extension $MainShellRouteExtension on MainShellRoute {
  static MainShellRoute _fromState(GoRouterState state) =>
      const MainShellRoute();
}

extension $HomeRouteExtension on HomeRoute {
  static HomeRoute _fromState(GoRouterState state) => HomeRoute();

  String get location => GoRouteData.$location('/');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $NoteRouteExtension on NoteRoute {
  static NoteRoute _fromState(GoRouterState state) =>
      NoteRoute(id: state.pathParameters['id']!);

  String get location =>
      GoRouteData.$location('/note/${Uri.encodeComponent(id)}');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $settingsRoute => GoRouteData.$route(
  path: '/settings',

  factory: $SettingsRouteExtension._fromState,
  routes: [
    GoRouteData.$route(
      path: 'connection',

      factory: $ConnectionSettingsRouteExtension._fromState,
    ),
    GoRouteData.$route(
      path: 'notes',

      factory: $NoteSettingsRouteExtension._fromState,
    ),
  ],
);

extension $SettingsRouteExtension on SettingsRoute {
  static SettingsRoute _fromState(GoRouterState state) => const SettingsRoute();

  String get location => GoRouteData.$location('/settings');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ConnectionSettingsRouteExtension on ConnectionSettingsRoute {
  static ConnectionSettingsRoute _fromState(GoRouterState state) =>
      const ConnectionSettingsRoute();

  String get location => GoRouteData.$location('/settings/connection');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $NoteSettingsRouteExtension on NoteSettingsRoute {
  static NoteSettingsRoute _fromState(GoRouterState state) =>
      const NoteSettingsRoute();

  String get location => GoRouteData.$location('/settings/notes');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
