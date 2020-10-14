
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'dart:collection';

class RouteObserver extends NavigatorObserver {

  final Set<Route> routes = HashSet();

  @override
  void didPush(Route route, Route previousRoute) {
    routes.add(route);
  }

  @override
  void didPop(Route route, Route previousRoute) {
    routes.remove(route);
  }

  @override
  void didReplace({Route newRoute, Route oldRoute}) {
    routes.add(newRoute);
    routes.remove(oldRoute);
  }

  @override
  void didRemove(Route route, Route previousRoute) {
    routes.remove(route);
  }
}

typedef RouteNamePredicate = bool Function(String name);

class RouteUtils {

  static RouteObserver get observer => _observer;
  static RouteObserver _observer = RouteObserver();

  static Future<T> push<T>(
      BuildContext context,
      Widget widget, {
        bool fullscreenDialog = false,
        String routeName,
        Duration transitionDuration = const Duration(milliseconds: 300)
      }) {

    return Navigator.of(context).push(AppPageRoute(
        fullscreenDialog: fullscreenDialog,
        routeName: routeName ?? widget.runtimeType.toString(),
        duration: transitionDuration,
        builder: (_) => widget)
    );
  }

  static Future<T> pushAndRemoveUntil<T>(BuildContext context, Widget widget, String untilRouteName, {bool fullscreenDialog = false}) {
    assert(untilRouteName != null);

    bool enable = false;
    return Navigator.of(context).pushAndRemoveUntil(
      AppPageRoute(
          fullscreenDialog: fullscreenDialog,
          routeName: widget.runtimeType.toString(),
          builder: (_) => widget),
      (route) {
        if(enable){
          return true;
        }
        if (route is AppPageRoute) {
          AppPageRoute appPageRoute = route;
          if(appPageRoute.routeName == untilRouteName){
            enable = true;
          }
        } else {
          if(route.settings.name != untilRouteName){
            enable = true;
          }
        }
        return false;
      },
    );
  }

  static Future<T> pushAndRemove<T>(BuildContext context, Widget widget, RouteNamePredicate predicate, {bool fullscreenDialog = false}) {
    assert(predicate != null);

    var navigator = Navigator.of(context);

    Set<Route> routes = HashSet();
    routes.addAll(_observer.routes);
    for(var route in routes){
      String name;
      if (route is AppPageRoute) {
        AppPageRoute appPageRoute = route;
        name = appPageRoute.routeName;
      } else {
        name = route.settings.name;
      }
      if(predicate(name)){
        navigator.removeRoute(route);
      }
    }

    return Navigator.of(context).push(AppPageRoute(
        fullscreenDialog: fullscreenDialog,
        routeName: widget.runtimeType.toString(),
        builder: (_) => widget)
    );
  }

  static Future<T> showDialogFromBottom<T>({
    @required BuildContext context,
    @required Widget widget,
    ImageFilter filter,
    bool useRootNavigator = true,
    bool barrierDismissible = true,
    Color barrierColor,
  }) {
    assert(useRootNavigator != null);
    return Navigator.of(context, rootNavigator: useRootNavigator).push(
      _CupertinoModalPopupRoute<T>(
        barrierColor: barrierColor ?? CupertinoDynamicColor.resolve(_kModalBarrierColor, context),
        barrierLabel: 'Dismiss',
        builder: (_) => widget,
        settings: RouteSettings(name: widget.runtimeType.toString()),
        filter: filter,
        semanticsDismissible: false,
        barrierDismissible: barrierDismissible
      ),
    );
  }
}

class AppPageRoute<T> extends CupertinoPageRoute<T> {

  String routeName;
  final Duration duration;

  @override
  Duration get transitionDuration => duration ?? super.transitionDuration;

  AppPageRoute({
    @required WidgetBuilder builder,
    String title,
    RouteSettings settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
    this.routeName,
    this.duration,
  }): super(builder: builder, title: title, settings: settings, maintainState: maintainState, fullscreenDialog: fullscreenDialog);
}

class _CupertinoModalPopupRoute<T> extends PopupRoute<T> {
  _CupertinoModalPopupRoute({
    this.barrierColor,
    this.barrierLabel,
    this.builder,
    bool semanticsDismissible,
    ImageFilter filter,
    RouteSettings settings,
    bool barrierDismissible,
  }) : super(
    filter: filter,
    settings: settings,
  ) {
    _barrierDismissible = barrierDismissible;
    _semanticsDismissible = semanticsDismissible;
  }

  final WidgetBuilder builder;
  bool _semanticsDismissible;

  @override
  final String barrierLabel;

  @override
  final Color barrierColor;

  @override
  bool get barrierDismissible => _barrierDismissible ?? true;
  bool _barrierDismissible;

  @override
  bool get semanticsDismissible => _semanticsDismissible ?? false;

  @override
  Duration get transitionDuration => _kModalPopupTransitionDuration;

  Animation<double> _animation;

  Tween<Offset> _offsetTween;

  @override
  Animation<double> createAnimation() {
    assert(_animation == null);
    _animation = CurvedAnimation(
      parent: super.createAnimation(),

      // These curves were initially measured from native iOS horizontal page
      // route animations and seemed to be a good match here as well.
      curve: Curves.linearToEaseOut,
      reverseCurve: Curves.linearToEaseOut.flipped,
    );
    _offsetTween = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: const Offset(0.0, 0.0),
    );
    return _animation;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return CupertinoUserInterfaceLevel(
      data: CupertinoUserInterfaceLevelData.elevated,
      child: Builder(builder: builder),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionalTranslation(
        translation: _offsetTween.evaluate(_animation),
        child: child,
      ),
    );
  }
}

// The duration of the transition used when a modal popup is shown.
const Duration _kModalPopupTransitionDuration = Duration(milliseconds: 335);

const Color _kModalBarrierColor = CupertinoDynamicColor.withBrightness(
  color: Color(0x33000000),
  darkColor: Color(0x7A000000),
);

