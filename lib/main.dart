import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      routes: {
        "/": (_) => new SafeArea(
              bottom: false,
              child: new WebviewScaffold(url: "https://dev.to"),
            )
      },
    );
  }
}
