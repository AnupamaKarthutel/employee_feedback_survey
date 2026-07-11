import 'package:flutter/widgets.dart';

import 'auth_service.dart';

class AuthServiceProvider extends InheritedWidget {
  const AuthServiceProvider({
    super.key,
    required this.authService,
    required super.child,
  });

  final AuthService authService;

  static AuthService of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<AuthServiceProvider>();
    assert(provider != null, 'No AuthServiceProvider found in context');
    return provider!.authService;
  }

  @override
  bool updateShouldNotify(AuthServiceProvider oldWidget) =>
      authService != oldWidget.authService;
}
