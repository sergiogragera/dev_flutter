import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
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
  final int _webNavigationBarColor = 0xFFfdf9f3;
  final Connectivity _connectivity = Connectivity();

  WebViewController _webViewController;
  ConnectivityResult _connectivityResult;
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Color(_webNavigationBarColor),
      body: new SafeArea(
          bottom: false,
          child: new WebView(
              initialUrl: 'https://dev.to',
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _webViewController = webViewController;
              })),
      bottomNavigationBar: new BottomAppBar(
        color: Color(_webNavigationBarColor),
        child: new Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () async {
                if (await _webViewController.canGoBack()) {
                  _webViewController.goBack();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () async {
                if (await _webViewController.canGoForward()) {
                  _webViewController.goForward();
                }
              },
            ),
            new Spacer(),
            IconButton(
              icon: const Icon(Icons.open_in_browser),
              onPressed: () async {
                var url = await _webViewController.currentUrl();
                if (await canLaunch(url)) {
                  await launch(url);
                }
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
      Flushbar(flushbarPosition: FlushbarPosition.TOP)
        ..message = text
        ..backgroundColor = backgroundColor
        ..duration = Duration(seconds: 3)
        ..show(context);
    }
    _connectivityResult = result;
  }
}
