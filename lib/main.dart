import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(routes: {"/": (_) => new MyHomePage()});
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final flutterWebViewPlugin = FlutterWebviewPlugin();
  final int WEB_NAVIGATION_BAR_COLOR = 0xFFfdf9f3;
  ConnectivityResult _connectivityResult;

  _launchURL() async {
    var url = await flutterWebViewPlugin.evalJavascript("window.location.href");
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    try {
      _connectivityResult = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(WEB_NAVIGATION_BAR_COLOR),
      body: new SafeArea(
        bottom: false,
        child: new WebviewScaffold(
          url: "https://dev.to",
          userAgent: "DEV-Native-ios"
        ),
      ),
      bottomNavigationBar: new BottomAppBar(
        color: Color(WEB_NAVIGATION_BAR_COLOR),
        child: new Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                flutterWebViewPlugin.goBack();
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () {
                flutterWebViewPlugin.goForward();
              },
            ),
            new Spacer(),
            IconButton(
              icon: const Icon(Icons.open_in_browser),
              onPressed: () {
                _launchURL();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    if (_connectivityResult != result) {
      var text;
      var backgroundColor;
      print(result);
      switch (result) {
        case ConnectivityResult.wifi:
          text = "Re-connected to WiFi";
          backgroundColor = Colors.greenAccent;
          break;
        case ConnectivityResult.mobile:
          text = "Re-connected to Cellular";
          backgroundColor = Colors.greenAccent;
          break;
        case ConnectivityResult.none:
          text = "Network not reachable";
          backgroundColor = Colors.redAccent;
          break;
        default:
          break;
      }
      _scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text(text), backgroundColor: backgroundColor));
    }
    _connectivityResult = result;
  }
}
