import 'package:flutter/material.dart';
import 'package:music_app/tabs/home.dart';
import 'package:music_app/tabs/library.dart';
import 'package:music_app/tabs/search.dart';

class TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState>? navigatorKey;
  final dynamic tabItem;
  final bool showNavigationBar;

  const TabNavigator({
    super.key,
    required this.navigatorKey,
    required this.tabItem,
    required this.showNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) {
            if (showNavigationBar) {
              return _buildTabItem(tabItem);
            } else {
              // Return an empty scaffold without navigation bar
              return Scaffold(
                body: _buildTabItem(tabItem),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildTabItem(dynamic tabItem) {
    if (tabItem == 'home') {
      return const Home();
    } else if (tabItem == 'search') {
      return const Search();
    } else if (tabItem == 'library') {
      return const Library();
    } else {
      // Handle unknown tab items
      return Container(); // You can return any default widget here
    }
  }
}
