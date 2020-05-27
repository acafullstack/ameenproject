import 'package:ameen_project/utils/azan_timer_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DemoPage extends StatefulWidget {

  _DemoPageState createState() => _DemoPageState();

}

class _DemoPageState extends State<DemoPage> {

  String _prayer_name = "";
  bool _azanTimeSwitched = true;
  int _flex_value = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  loadData() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      _prayer_name = preferences.getString("prayer_name");
      var parts = _prayer_name.split("^");
      _prayer_name = parts[0] + parts[1];
      _azanTimeSwitched = preferences.getBool("_azanTimeSwitched") ?? true;
      _flex_value = _azanTimeSwitched ? 1 : 0;

    });
    print('Pray ' + _prayer_name);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('Dua Request'),
        backgroundColor: Colors.pinkAccent,
      ),
      resizeToAvoidBottomPadding: false,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Expanded(
              flex: _flex_value,
              child: _azanTimeSwitched ? getAlarm(context, _prayer_name) : Container(),
            ),
            Expanded(
              flex: 1,
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: Color(0xffEFEFEF),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 5.0),
                      child: Text(
                        'Dua Request',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 0.0),
                      child: Text(
                        'Coming Soon',
                        style: TextStyle(
                          color: Colors.pink,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 5.0),
                child: Image.asset(
                  'assets/soon.png',
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: ListTile(
                title: Text(
                  'This feature will allow public to post a dua in the community.\n',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                  ),
                ),
                subtitle: Text(
                  'You will get notified immediately once the feature is available',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/download.png"), fit: BoxFit.cover),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
