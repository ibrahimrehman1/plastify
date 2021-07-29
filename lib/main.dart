import "package:flutter/material.dart";
import "./widgets/login_widget.dart";

void main() {
  runApp(MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginWidget(),
      navigatorKey: navigatorKey,
    );
  }
}
