import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ameen_project/utils/azan_timer_box.dart';
import 'package:ameen_project/screens/place_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class QuranPage extends StatefulWidget {
  String _url, _title;
  QuranPage(this._url, this._title);
  _QuranPageState createState() => _QuranPageState(this._url, this._title);
}

class _QuranPageState extends State<QuranPage> {

  String _url, _title;
  bool _isLoading = true;
  String _prayer_name = "Fajar";
  bool _azanTimeSwitched = true;
  final Completer<WebViewController> _controller = Completer<WebViewController>();

  _QuranPageState(this._url, this._title);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  loadData() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      if (preferences.containsKey('_azanTimeSwitched')) {
      _azanTimeSwitched = preferences.getBool('_azanTimeSwitched');
      }
      _prayer_name = preferences.getString("prayer_name");
      var parts = _prayer_name.split("^");
      _prayer_name = parts[0] + parts[1];
    });
    print('Pray ' + _prayer_name);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(double.infinity, 50),
          child: getAppBar(context, _title, _prayer_name, _azanTimeSwitched)
      ),
      resizeToAvoidBottomPadding: false,
      body: Stack(
        children: <Widget>[
          WebView(
            //https://qiblafinder.withgoogle.com/intl/en/
            //http://quran.ksu.edu.sa/index.php
            initialUrl: _url,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller.complete(webViewController);
            },
            onPageFinished: (finish) {
              setState(() {
                _isLoading = false;
              });
            },
          ),
          _isLoading ? Center( child: CircularProgressIndicator()) : Container(),
        ],
      ),

    );
  }

}