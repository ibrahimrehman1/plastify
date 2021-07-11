import "package:flutter/material.dart";
import "package:flutter_icons/flutter_icons.dart";
import "./widgets/signup_widget.dart";

void main() {
  runApp(MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SignupWidget(),
      navigatorKey: navigatorKey,
    );
  }
}
