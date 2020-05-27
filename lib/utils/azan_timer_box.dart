import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home_page.dart';

Widget getAlarmBox(BuildContext context, String prayer_name, String prayer_time, int estimateTs, {String city_name = "New York"}) {
    var alarmContainer = Container(
    //width: MediaQuery.of(context).size.width,
    //height: MediaQuery.of(context).size.height / 4,
    decoration: BoxDecoration(
      image: DecorationImage(
          image: AssetImage("assets/mosque.jpg"), fit: BoxFit.cover),
    ),
    child: Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text(
            prayer_name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text(
            prayer_time,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
          child:
              StreamBuilder(
              stream: Stream.periodic(Duration(seconds: 1), (i) => i),

              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                DateFormat format = DateFormat("mm:ss");
                int now = DateTime
                    .now()
                    .millisecondsSinceEpoch;
                Duration remaining = Duration(milliseconds: estimateTs - now);
                var dateString = "—"+'${remaining.inHours}:${format.format(
                    DateTime.fromMillisecondsSinceEpoch(remaining.inMilliseconds))}';
                return Container(
                  alignment: Alignment.center,
                  child: Text(dateString, style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),));
              })
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FlatButton.icon(
              onPressed: null,
              icon: Icon(
                Icons.location_on,
                color: Colors.white,
              ),
              label: Text(
                city_name,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            FlatButton.icon(
              color: Colors.black12,
              icon: Icon(
                Icons.volume_off,
                color: Colors.white,
              ),
              label: Text(
                '',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () {

              },
            ),
          ],

        ),
      ],
    ),
  );

  return alarmContainer;
}

Widget getAppBar(BuildContext context, String title, String prayer_name, bool _azanTimeSwitched) {
  var alarmContainer = Container(
    height: 100,
    decoration:  BoxDecoration(
      image: DecorationImage(
          image: AssetImage("assets/mosque.jpg"), fit: BoxFit.cover),
    ),
    child: Container(
      margin: EdgeInsets.fromLTRB(0, 20, 10, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.navigate_before,size: 40,color: Colors.white,),
                onPressed: () {
                  if(title == "Settings") {
                    Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HomePage()));
                  } else {
                    Navigator.of(context).pop(true);
                  }
                },
              ),
              Text(title,style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.bold),),
            ],
          ),
          _azanTimeSwitched
          ? Text(prayer_name,style: TextStyle(fontSize: 13,color: Colors.white),)
          : Container(),
        ],
      ),
    ),
  );

  return alarmContainer;
}

Widget getAlarm(BuildContext context, String prayer_name) {

  var prayerName =  "";
  try {
    prayerName = prayer_name.substring(7,prayer_name.length);
  } catch (e) {
    print(e);
  }
  print(prayer_name);
  var alarmContainer = Container(
    //width: MediaQuery.of(context).size.width,
    //height: MediaQuery.of(context).size.height / 4,
    decoration: BoxDecoration(
      image: DecorationImage(
          image: AssetImage("assets/mosque.jpg"), fit: BoxFit.cover),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Text(
              prayerName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  return alarmContainer;
}
