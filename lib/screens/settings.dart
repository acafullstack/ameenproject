import 'dart:convert';

import 'package:ameen_project/network/azan_time.dart';
import 'package:ameen_project/utils/notification_alarm.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:ameen_project/home_page.dart';
import 'package:ameen_project/screens/login_page.dart';
import 'package:ameen_project/model/login_status.dart';
import 'package:ameen_project/screens/sign_up_request.dart';
import 'package:ameen_project/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../utils/azan_timer_box.dart';

class SettingsPage extends StatefulWidget {

  _SettingsPageState createState() => _SettingsPageState();

}

class _SettingsPageState extends State<SettingsPage> {
  
  FlutterLocalNotificationsPlugin notificationsPlugin;

  List eventTime = [];
  bool _janazahSwitched = true;
  bool _azanSwitched = false;
  bool _azanTimeSwitched = true;
  bool _notifySwitched = true;
  String _prayer_name = "Fajr";
  String _prayer_time = "05:13 AM";
  String _cityName="";
  int _estimateTs = 0;
  String _name = "";
  String _email = "";
  String _profileLink = "";
  bool _loggedIn = false;

  _loadData() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var token = preferences.getString('token');
    var isJanzahEnabled = preferences.getString('isJanzahEnabled');
    final data = await getJsonData();
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    var prayerTimer = preferences.getString("prayerTimer") ?? "2012-10-19 8:40:23";
    DateTime dateTime = dateFormat.parse(prayerTimer);
    setState(() {
      if (preferences.containsKey('_azanTimeSwitched')) {
      _azanTimeSwitched = preferences.getBool('_azanTimeSwitched');
      }
      if (token != null) _loggedIn = token.isEmpty ? false : true;
      if (isJanzahEnabled != null) _janazahSwitched =  isJanzahEnabled == "1" ? true : false;
      eventTime = data;
      _prayer_name = preferences.getString("prayer_name");
      _cityName = preferences.getString("city");
      var parts = _prayer_name.split("^");
      _prayer_name = parts[0];
      _prayer_time = parts[1];
      _estimateTs = dateTime.millisecondsSinceEpoch ?? 0;
    });
    print('Pray ' + _prayer_name);
  }

  _saveSettings(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();    
    if (key == "_janazahSwitched") {
      var isJanzahEnabled = prefs.getString('isJanzahEnabled') == '1' ? '0' : '1';
      var id = prefs.getInt('id');
      var token = prefs.getString('token');
      Map data = {'is_janzah_enabled': isJanzahEnabled, 'Edit_Id': id.toString()};
      var response = await http.post(
      "http://ameenproject.org/appadmin/public/api/v1/profile/update_janazah_settings",
      body: data,
      headers: {'Authorization': 'Bearer $token'});
      print('url: ${response.request.toString()}');
      if (response.statusCode == 200) {
        print('UserUpdateINfo: ${response.body.toString()}');
        value ? prefs.setString('isJanzahEnabled', '1') : prefs.setString('isJanzahEnabled', '0');
      } else {
        print('1111 ${response.body}');
      }
    } else {
      prefs.setBool(key, value);
    }    
  }

  _retrieveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // if (prefs.containsKey('_janazahSwitched')) {
    //   _janazahSwitched = prefs.getBool('_janazahSwitched');
    // }
    if (prefs.containsKey('_azanSwitched')) {
      _azanSwitched = prefs.getBool('_azanSwitched');
    }
    if (prefs.containsKey('_azanTimeSwitched')) {
      _azanTimeSwitched = prefs.getBool('_azanTimeSwitched');
    }
    if (prefs.containsKey('_notifySwitched')) {
      _notifySwitched = prefs.getBool('_notifySwitched');
    }
  }
  
  _sessionDataLoad() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('email') && prefs.containsKey('name') && prefs.containsKey('profilePic'))  {
      _name = prefs.getString('name');
      _email = prefs.getString('email');
      _profileLink = prefs.getString('profilePic');
    } else {
      prefs.setBool("status", false);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
    _retrieveSettings();
    _sessionDataLoad();
    notificationsPlugin = localNotificationAlarm();

    Future.delayed(Duration.zero, () async {
      // checkNotificationPermission();
    });

    

  }

//   Future<void> checkNotificationPermission() async {
//     try {
//       await NotificationPermissions.getNotificationPermissionStatus()
//           .then((status) {
//         if (mounted) {
//           setState(() {
//             _janazahSwitched = status == PermissionStatus.granted;
//           });
//           print('_janazahSwitched: $_janazahSwitched');
//         }
//       });
//     } catch (err) {
// //      print(err);
//     }
//   }
  

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(double.infinity, 50),
          child: getAppBar(context, "Settings", _prayer_name+_prayer_time, _azanTimeSwitched)
      ),
      resizeToAvoidBottomPadding: false,
      body: Builder(
        builder: (BuildContext buildContext) {
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Container(
                            width: 100.0,
                            height: 60.0,
                            decoration: new BoxDecoration(
                                shape: BoxShape.circle,
                                image: new DecorationImage(
                                    fit: BoxFit.fill,
                                    image: new NetworkImage(
                                        _profileLink.isNotEmpty ? _profileLink :
                                        "https://pecb.com/conferences/wp-content/uploads/2017/10/no-profile-picture.jpg"),
                                ),
                            )),
                      ),
                      Expanded(
                        flex: 4,
                        child: _name.isNotEmpty || _email.isNotEmpty ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: <Widget>[
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  _name,
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  _email,
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ) : GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                                  return LoginPage();
                                }));
                          },
                          child: Text(
                            "Tap to login."
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Divider(
                  height: 5.0,
                  color: Colors.black12,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'FEATURES',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.0),
                  child: Text(
                      'You can optionally turn on or off any feature.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
                _loggedIn ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Janazah Notification',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                        ),
                      ),
                      Switch(
                        value: _janazahSwitched,
                        onChanged: (value) {
                          setState(() {
                            _janazahSwitched = value;
                            _saveSettings("_janazahSwitched", _janazahSwitched);
                            print(_janazahSwitched);
                          });
                        },
                        activeTrackColor: Colors.lightBlueAccent,
                        activeColor: Colors.blue,
                      ),
                    ],
                  ),
                )
                : Container(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                          'Show Azan Time in Each Screen',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                        ),
                      ),
                      Switch(
                        value: _azanTimeSwitched,
                        onChanged: (value) {
                          setState(() {
                            _azanTimeSwitched = value;
                            _saveSettings("_azanTimeSwitched", _azanTimeSwitched);
                            print(_azanTimeSwitched);
                          });
                        },
                        activeTrackColor: Colors.lightBlueAccent,
                        activeColor: Colors.blue,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  // child: getAlarmBox(context, _prayer_name, _prayer_time, _estimateTs, city_name:_cityName),
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/mosque.jpg"), fit: BoxFit.cover),
                    ),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          child: Text(
                            _prayer_name,
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
                            _prayer_time,
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
                              _azanTimeSwitched ? StreamBuilder(
                              stream: Stream.periodic(Duration(seconds: 1), (i) => i),

                              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                                DateFormat format = DateFormat("mm:ss");
                                int now = DateTime
                                    .now()
                                    .millisecondsSinceEpoch;
                                Duration remaining = Duration(milliseconds: _estimateTs - now);
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
                            : Container()
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
                                _cityName,
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            FlatButton.icon(
                              color: Colors.black12,
                              icon: Icon(
                                _azanSwitched ? Icons.volume_up : Icons.volume_off,
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
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                          'Play Azan During Azan Time',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                        ),
                      ),
                      Switch(
                        value: _azanSwitched,
                        onChanged: (value) {
                          setState(() {
                            _azanSwitched = value;
                            _saveSettings("_azanSwitched", _azanSwitched);
                            setUpEachNotificationWithSound(notificationsPlugin,eventTime);
                            print(_azanSwitched);
                          });
                        },
                        activeTrackColor: Colors.lightBlueAccent,
                        activeColor: Colors.blue,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                          'All Notifications',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                        ),
                      ),
                      Switch(
                        value: _notifySwitched,
                        onChanged: (bool value) {
                          setState(() {
                            _notifySwitched = value;
                            _saveSettings("_notifySwitched", _notifySwitched);
                            if(_notifySwitched) {
                               setUpNotificationWithSound(notificationsPlugin,eventTime);
                            } else {
                              deleteAllNotification(notificationsPlugin);                               
                            }
                            print(_notifySwitched);
                          });
                        },
                        activeTrackColor: Colors.lightBlueAccent,
                        activeColor: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },

      ),
    );
  }
}
