import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final flutterWebViewPlugin = FlutterWebviewPlugin();
    const int WEB_NAVIGATION_BAR_COLOR = 0xFFfdf9f3;

    _launchURL() async {
      var url =
          await flutterWebViewPlugin.evalJavascript("window.location.href");
      if (await canLaunch(url)) {
        await launch(url);
      }
    }

    return new MaterialApp(
      routes: {
        "/": (_) => new Container(
              color: Color(WEB_NAVIGATION_BAR_COLOR),
              child: new SafeArea(
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
            ),
      },
    );
  }
}
