// Copyright (C) 2026  oito2
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

/// The slug of the page the showcase shows, or an empty string for none.
///
/// The router writes it when the address changes, such as on a link, an
/// edited address or the browser's back button, and the shell writes it
/// when the user picks a page, which the router turns into a new history
/// entry.
class ShowcaseLocation extends ValueNotifier<String> {
  /// Creates a location at [slug].
  ShowcaseLocation([super.slug = '']);
}

/// Reads the page slug from the address path, as in `#/check-button`.
class ShowcaseRouteParser extends RouteInformationParser<String> {
  /// Creates the parser.
  const ShowcaseRouteParser();

  @override
  Future<String> parseRouteInformation(RouteInformation routeInformation) =>
      SynchronousFuture(
        routeInformation.uri.path.replaceFirst(RegExp('^/+'), ''),
      );

  @override
  RouteInformation restoreRouteInformation(String configuration) =>
      RouteInformation(uri: Uri(path: '/$configuration'));
}

/// Shows the showcase in a single-page navigator and keeps [location] and
/// the address in sync.
class ShowcaseRouterDelegate extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  /// Creates a delegate that builds the showcase with [builder].
  ShowcaseRouterDelegate({required this.location, required this.builder}) {
    location.addListener(notifyListeners);
  }

  /// The page shown.
  final ShowcaseLocation location;

  /// Builds the showcase.
  final WidgetBuilder builder;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  String get currentConfiguration => location.value;

  @override
  Future<void> setNewRoutePath(String configuration) {
    location.value = configuration;
    return SynchronousFuture(null);
  }

  @override
  Widget build(BuildContext context) => Navigator(
    key: navigatorKey,
    pages: [
      MaterialPage<void>(
        key: const ValueKey('showcase'),
        child: Builder(builder: builder),
      ),
    ],
    onDidRemovePage: (_) {},
  );

  @override
  void dispose() {
    location.removeListener(notifyListeners);
    super.dispose();
  }
}
