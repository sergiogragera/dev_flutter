import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flushbar/flushbar.dart';

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
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return;
    }

    _updateConnectionStatus(result);
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
          userAgent: "DEV-Native-ios",
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
        ),
      ),
    );
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.none:
          _scaffoldKey.currentState.showSnackBar(new SnackBar(
              content: new Text(result.toString())
          ));
        break;
      default:
        break;
    }
  }
}
