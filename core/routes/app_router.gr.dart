// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:alfares_pro_merchant/features/auth/presentation/screens/login_screen.dart'
    as _i2;
import 'package:alfares_pro_merchant/features/home/presentation/screens/home_screen.dart'
    as _i1;
import 'package:alfares_pro_merchant/features/splash/presentation/screens/splash_screen.dart'
    as _i3;
import 'package:auto_route/auto_route.dart' as _i4;
import 'package:flutter/material.dart' as _i5;

/// generated route for
/// [_i1.HomeScreen]
class HomeScreenRoute extends _i4.PageRouteInfo<void> {
  const HomeScreenRoute({List<_i4.PageRouteInfo>? children})
    : super(HomeScreenRoute.name, initialChildren: children);

  static const String name = 'HomeScreenRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return const _i1.HomeScreen();
    },
  );
}

/// generated route for
/// [_i2.LoginScreen]
class LoginScreenRoute extends _i4.PageRouteInfo<void> {
  const LoginScreenRoute({List<_i4.PageRouteInfo>? children})
    : super(LoginScreenRoute.name, initialChildren: children);

  static const String name = 'LoginScreenRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return const _i2.LoginScreen();
    },
  );
}

/// generated route for
/// [_i3.SplashScreen]
class SplashScreenRoute extends _i4.PageRouteInfo<SplashScreenRouteArgs> {
  SplashScreenRoute({
    _i5.Key? key,
    _i5.VoidCallback? onComplete,
    List<_i4.PageRouteInfo>? children,
  }) : super(
         SplashScreenRoute.name,
         args: SplashScreenRouteArgs(key: key, onComplete: onComplete),
         initialChildren: children,
       );

  static const String name = 'SplashScreenRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SplashScreenRouteArgs>(
        orElse: () => const SplashScreenRouteArgs(),
      );
      return _i3.SplashScreen(key: args.key, onComplete: args.onComplete);
    },
  );
}

class SplashScreenRouteArgs {
  const SplashScreenRouteArgs({this.key, this.onComplete});

  final _i5.Key? key;

  final _i5.VoidCallback? onComplete;

  @override
  String toString() {
    return 'SplashScreenRouteArgs{key: $key, onComplete: $onComplete}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SplashScreenRouteArgs) return false;
    return key == other.key && onComplete == other.onComplete;
  }

  @override
  int get hashCode => key.hashCode ^ onComplete.hashCode;
}
