import 'package:ameen_project/model/Timing.dart';
import 'package:ameen_project/network/azan_time.dart';
import 'package:ameen_project/screens/each_event_page.dart';
import 'package:ameen_project/utils/notification_alarm.dart';
import 'package:flutter/material.dart';
import 'package:ameen_project/utils/azan_timer_box.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AzanPage extends StatefulWidget {
  _AzanPageState createState() => _AzanPageState();
}

class _AzanPageState extends State<AzanPage> {
  List eventTime = [];

  String _prayer_name = "Fajr";
  bool _azanTimeSwitched = true;

  FlutterLocalNotificationsPlugin notificationsPlugin;
  SharedPreferences prefs;

  List event_name_list = [
    "Fajr",
    "Dhuhr",
    "Asr",
    "Maghrib",
    "Isha'a",
  ];

  List event_status = [
    "Turn Off",
    "Turn Off",
    "Turn Off",
    "Turn Off",
    "Turn Off",
  ];

  List event_icons = [
    'assets/sunrise.png',
    'assets/day_circle.png',
    'assets/day_circle.png',
    'assets/sunset.png',
    'assets/night.png'
  ];

  List event_icons_bg = [
    'assets/morning.png',
    'assets/day.png',
    'assets/afternoon.png',
    'assets/evening.png',
    'assets/night_view.jpeg'
  ];

  Future loadData() async {
    prefs = await SharedPreferences.getInstance();
    final data = await getJsonData();
    final pray_name = await showCurrentPrayerTime(data);
    setState(() {
      if (prefs.containsKey('_azanTimeSwitched')) {
      _azanTimeSwitched = prefs.getBool('_azanTimeSwitched');
      }
      eventTime = data;
      _prayer_name = pray_name;
      var parts = _prayer_name.split("^");
      _prayer_name = parts[0] + parts[1];
      if(prefs != null) {
        for(int index = 0; index<event_status.length; index++) {
          bool status = prefs.getBool(event_name_list[index]) ?? false;
          event_status[index] = status ? "Turn Off" : "Turn On";
        }
      }

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
    notificationsPlugin = localNotificationAlarm();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(double.infinity, 50),
          child: getAppBar(context, "Azan", _prayer_name, _azanTimeSwitched)
      ),
      resizeToAvoidBottomPadding: false,
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 6,
            child: ListView.builder(
                itemCount: event_name_list.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(event_icons_bg[index]), fit: BoxFit.fill),
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 2,
                                child: FlatButton(
                                  onPressed: () {},
                                  child: Image.asset(
                                    event_icons[index],
                                    height: 25,
                                    width: 25,
                                  ),
                                  shape: CircleBorder(),
//                              color: Color(event_icons_color[index]),
                                  padding: EdgeInsets.all(15.0),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: ListTile(
                                  title: Text(
                                    event_name_list[index],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    eventTime.length > 4
                                        ? eventTime[index]
                                        : "Azan Time",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onTap: () {
                                    print('');
                                  },
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 4.0, vertical: 0.0),
                                  child: Container(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (event_status[index] == "Turn Off") {
                                            event_status[index] = "Turn On";
                                           deleteNotification(
                                               notificationsPlugin, index);
                                            prefs.setBool(event_name_list[index], false);
                                          } else {
                                            event_status[index] = "Turn Off";
                                           showNotificationWithSound(
                                               notificationsPlugin,
                                               eventTime[index],
                                               event_name_list[index],
                                               index);
                                            prefs.setBool(event_name_list[index], true);
                                          }
                                        });
                                      },
                                      child: Material(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(0.0),
                                        child: Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                            child: Text(
                                              event_status[index],
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 8.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
          ),
        ],
      ),
    );
  }
}


