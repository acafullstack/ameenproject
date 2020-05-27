import 'dart:convert';
import 'dart:math';

import 'package:ameen_project/screens/business_directory.dart';
import 'package:ameen_project/screens/coming_soon_page_one.dart';
import 'package:ameen_project/screens/coming_soon_page_two.dart';
import 'package:ameen_project/screens/directory_list.dart';
import 'package:ameen_project/screens/each_event_page.dart';
import 'package:ameen_project/screens/janazah_page.dart';
import 'package:ameen_project/screens/jummah_page.dart';
import 'package:ameen_project/screens/settings.dart';
import 'package:ameen_project/screens/youtube_page.dart';
import 'package:ameen_project/utils/calculate_date_time.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ameen_project/utils/azan_timer_box.dart';
import 'package:ameen_project/screens/login_page.dart';
import 'package:ameen_project/screens/event_page.dart';
import 'package:ameen_project/screens/azan_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'model/events_model.dart';
import 'model/message_fcm.dart';
import 'network/azan_time.dart';
import 'utils/location_trace.dart';
import 'utils/notification_alarm.dart';
import 'screens/quran_page.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';

class HomePage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseMessaging _firebase = FirebaseMessaging();
  final List<Messages> messages = [];

  var isLoggedIn = false;
  var login_text = "Log In";
  bool _azanTimeSwitched = true;
  bool _azanSwitched = false;

  List eventTime = [];
  String prayer_name = "Fajr";
  String prayer_time = "05:13 AM";
  String cityName = "New York";
  EventsModels _eventsModels;
  FlutterLocalNotificationsPlugin _notificationsPlugin;
  String _monthName = "Jan";
  String _dayNum = "01";
  var _monthGet;
  int _estimateTimeForAzan = 0;
  int _estimateTimeForEvent = 0;
  String _currentLatitude = "0";
  String _currentLongitude = "0";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _traceLocation();
    _sessionCheck();
    _checkSession();
//    _notificationsPlugin = localNotificationAlarm();
    _loadData();

    firebaseInit();

    var events = List<Events>();
    Data data = Data(events: events);
    _eventsModels = EventsModels(success: true,
        message: "success", data: data);

//    var initializationSettingsAndroid =
//    new AndroidInitializationSettings('@mipmap/ic_launcher');
//    var initializationSettingsIOS = new IOSInitializationSettings();
//    var initializationSettings = new InitializationSettings(
//        initializationSettingsAndroid, initializationSettingsIOS);
//    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
//    flutterLocalNotificationsPlugin.initialize(initializationSettings,
//        onSelectNotification: onSelectNotification);
  }

  Future<void> _checkSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('status')) {
      if (prefs.getBool('status')) {
        setState(() {
          isLoggedIn = true;
          login_text = "Log Out";
        });
      } else {
        setState(() {
          isLoggedIn = prefs.getBool('status');
          ;
          login_text = "Log In";
        });
      }
    }
  }

  Future _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    final data = await getJsonData();
    final pray_name = await showCurrentPrayerTime(data);
    var parts = pray_name.split("^");
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    var prayerTimer = prefs.getString("prayerTimer") ?? "2012-10-19 8:40:23";
    DateTime dateTime = dateFormat.parse(prayerTimer);
    setState(() {
      if (prefs.containsKey('_azanTimeSwitched')) {
      _azanTimeSwitched = prefs.getBool('_azanTimeSwitched');
      }
      if (prefs.containsKey('_azanSwitched')) {
        _azanSwitched = prefs.getBool('_azanSwitched');
      }
      print('azantimeswithed: $_azanTimeSwitched');
    
      eventTime = data;
      prayer_name = parts[0];
      prayer_time = parts[1];
      _estimateTimeForAzan = dateTime.millisecondsSinceEpoch ?? 0;
//      setUpNotificationWithSound(_notificationsPlugin, eventTime);
//      if(_eventsModels.data.events.length > 0) {
//        _monthGet = DateTime.parse(_eventsModels.data.events[0].eventDate);
//        _dayNum = _monthGet.day.toString();
//        print('month date : '+_monthGet.day.toString());
//      }
    });
//    _monthName = await returnMonth(_monthGet.month);
  }

  _logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('name');
    prefs.remove('email');
    prefs.remove('profilePic');
    prefs.remove('status');
    isLoggedIn = false;
    login_text = "Log In";
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomePage()),
        (Route<dynamic> route) => false);
  }

  Future _traceLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var currentLocation = await locationTrace();
    final coordinates = new Coordinates(currentLocation.latitude, currentLocation.longitude);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var address = addresses.first;
    setState(() {
      if (currentLocation != null) {
        cityName = address.locality;
        _currentLatitude = "${currentLocation.latitude}";
        _currentLongitude = "${currentLocation.longitude}";
        prefs.setString("latitude", "${currentLocation.latitude}");
        prefs.setString("longitude", "${currentLocation.longitude}");
        prefs.setString("city", cityName);
        prefs.setString("country", address.countryName);
        _getUpcomingEvent();
      }
    });
  }

  Future _sessionCheck() async {
    var token;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('token')) {
      token = prefs.getString('token');
      prefs.setBool("status", true);
    } else {
      prefs.setBool("status", false);
    }
  }

  _getUpcomingEvent() async {
    var events = List<Events>();
    Data data = Data(events: events);
    _eventsModels = EventsModels(success: true, message: "success", data: data);
    var jsonData = null;
    final response = await http.get(
      "http://ameenproject.org/appadmin/public/api/v1/events/homepage",
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      }
    );
    print(_currentLatitude +" " + _currentLongitude);
    if (response.statusCode == 200) {
      jsonData = json.decode(response.body);
      setState(() {
        _eventsModels = new EventsModels.fromJson(jsonData);
        if (_eventsModels.data.events.length > 0)
        _estimateTimeForEvent = timeDateToLong(_eventsModels.data.events[0].timer);
    });
    }
    print(jsonData.toString());
  }

  firebaseInit() {
    _firebase.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        final notification = message['notification'];
        setState(() {
//          messages.add(Messages(title: notification['title'],
//              body: notification['body']));
          messages.add(Messages(
              title: "Push Notification Title",
              body: "Push Notification Description"));
        });
        //showNotification(_notificationsPlugin, "Push Notification Title", "Push Notification Description");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");

        final notification = message['data'];
        setState(() {
//          messages.add(Messages(
//            title: '${notification['title']}',
//            body: '${notification['body']}',
//          ));
          messages.add(Messages(
            title: "Push Notification Title",
            body: "Push Notification Description",
          ));
        });
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
    _firebase.subscribeToTopic('all');
    _firebase.requestNotificationPermissions(IosNotificationSettings(
      sound: true,
      badge: true,
      alert: true,
    ));
    _firebase.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print('Hello');
    });
    _firebase.getToken().then((token) {
      _saveUserToken(token);
      print('TOKEN:: $token'); // Print the Token in Console
    });
  }

  _saveUserToken(String tokenFCM) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("fcm_token", tokenFCM);
    if (isLoggedIn) {
      var id = sharedPreferences.getInt('id');
      var token = sharedPreferences.getString('token');
      Map data = {
        'firebase_token': sharedPreferences.getString('fcm_token'), 
        'Edit_Id': id.toString()
      };
      var response = await http.post(
        "http://ameenproject.org/appadmin/public/api/v1/profile/update_token",
        body: data,
        headers: {'Authorization': 'Bearer $token'}
      );
      if (response.statusCode == 200) {
        print('UserUpdateINfo: ${response.body.toString()}');
      } else {
        print('1111 ${response.body}');
      }
    } else {
      Map data = {
        'firebase_token': sharedPreferences.getString('fcm_token'),
      };
      var response = await http.post(
        "http://ameenproject.org/appadmin/public/api/v1/static/update_token",
        body: data,
      );
      if (response.statusCode == 200) {
        print('FCMTokenUpdateforUnregisteredUser: ${response.body.toString()}');
      } else {
        print('1111 ${response.body}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xff132035), //or set color with: Color(0xFF0000FF)
    ));
    // TODO: implement build
    return Scaffold(
//      appBar: AppBar(
//        // Here we take the value from the MyHomePage object that was created by
//        // the App.build method, and use it to set our appbar title.
//        title: Text('Ameen Project'),
//        backgroundColor: Colors.pinkAccent,
//      ),
      resizeToAvoidBottomPadding: false,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 9,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: <Widget>[
                        // getAlarmBox(
                        //     context, prayer_name, prayer_time, _estimateTimeForAzan,
                        //     city_name: cityName),
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage("assets/mosque.jpg"), fit: BoxFit.cover),
                          ),
                          child: Column(
                            children: <Widget>[
                              _azanTimeSwitched ? Padding(
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
                              )
                              : Container(),
                              _azanTimeSwitched ? Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                child: Text(
                                  prayer_time,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                              : Container(),
                              _azanTimeSwitched ? Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
                                child: StreamBuilder(
                                    stream: Stream.periodic(Duration(seconds: 1), (i) => i),

                                    builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                                      DateFormat format = DateFormat("mm:ss");
                                      int now = DateTime
                                          .now()
                                          .millisecondsSinceEpoch;
                                      Duration remaining = Duration(milliseconds: _estimateTimeForAzan - now);
                                      var dateString = "—"+'${remaining.inHours}:${format.format(
                                          DateTime.fromMillisecondsSinceEpoch(remaining.inMilliseconds))}';
                                      return Container(
                                        alignment: Alignment.center,
                                        child: Text(dateString, style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),));
                                    }),
                              )
                              : Container(),
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
                                      cityName,
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
                      ],
                    ),
                  ),
                  _eventsModels.data.events.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return EachEventPage(_eventsModels.data.events[
                                  _eventsModels.data.events.length - 1]);
                            }));
                          },
                          child: Column(
                            children: <Widget>[
                              SizedBox(height: 2.0,),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical:3.0),
                                  child: Text(
                                    "Upcoming Event:",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                decoration: new BoxDecoration (
                                  color:  Color.fromRGBO(90, 178, 249, 1)
                                ),
                              ),
                              Container(
                                color: Color(0xffEFEFEF),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 8),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Expanded(
                                          flex: 2,
                                          child: GradientCard(
                                            child: Padding(
                                              padding: const EdgeInsets.all(4.0),
                                              child: Column(
                                                children: <Widget>[
                                                  Text(
                                                    returnDate(_eventsModels
                                                        .data
                                                        .events[_eventsModels.data
                                                                .events.length -
                                                            1]
                                                        .eventDate),
                                                    style: TextStyle(
                                                      fontSize: 24,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                    returnMonth(_eventsModels
                                                        .data
                                                        .events[_eventsModels.data
                                                                .events.length -
                                                            1]
                                                        .eventDate),
                                                    style: TextStyle(
                                                      fontSize: 17,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            gradient: Gradients.backToFuture,
                                            shadowColor: Gradients
                                                .backToFuture.colors.last
                                                .withOpacity(0.5),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 5,
                                          child: Column(
                                            children: <Widget>[
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal:4.0),
                                                  child: Text(
                                                    _eventsModels.data.events.isNotEmpty
                                                        ? _eventsModels.data.events[_eventsModels.data.events.length - 1].name
                                                        :"Event Name",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 17,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(4.0),
                                                    child: Image.asset(
                                                      'assets/maps.png',
                                                      height: 15,
                                                      width: 15,
                                                    ),
                                                  ),
                                                  Flexible(
                                                    child: Text(
                                                      _eventsModels.data.events
                                                              .isNotEmpty
                                                          ? _eventsModels
                                                              .data
                                                              .events[_eventsModels
                                                                      .data
                                                                      .events
                                                                      .length -
                                                                  1]
                                                              .location
                                                          : "Location",
                                                      style: TextStyle(
                                                        color: Colors.black87,
                                                        fontSize: 13,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(4.0),
                                                    child: Image.asset(
                                                      'assets/watch.png',
                                                      height: 15,
                                                      width: 15,
                                                    ),
                                                  ),
                                                  Text(
                                                    _eventsModels
                                                            .data.events.isNotEmpty
                                                        ? _eventsModels
                                                            .data
                                                            .events[_eventsModels
                                                                    .data
                                                                    .events
                                                                    .length -
                                                                1]
                                                            .eventTime
                                                        : "Time",
                                                    style: TextStyle(
                                                      color: Colors.black87,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(4.0),
                                                    child: Image.asset(
                                                      'assets/calenders.png',
                                                      height: 15,
                                                      width: 15,
                                                    ),
                                                  ),
                                                  Text(
                                                    _eventsModels
                                                            .data.events.isNotEmpty
                                                        ? _eventsModels
                                                            .data
                                                            .events[_eventsModels
                                                                    .data
                                                                    .events
                                                                    .length -
                                                                1]
                                                            .eventDate
                                                        : "Date",
                                                    style: TextStyle(
                                                      color: Colors.black87,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                child: StreamBuilder(
                                                    stream: Stream.periodic(Duration(seconds: 1), (i) => i),

                                                    builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                                                      DateFormat format = DateFormat("mm:ss");
                                                      int now = DateTime
                                                          .now()
                                                          .millisecondsSinceEpoch;
                                                      Duration remaining = Duration(milliseconds: _estimateTimeForEvent - now);
                                                      var dateString = "—"+'${remaining.inHours}h:${format.format(
                                                          DateTime.fromMillisecondsSinceEpoch(remaining.inMilliseconds))}';
                                                      return Container(
                                                          alignment: Alignment.center,
                                                          child: Align(
                                                            alignment: Alignment.topLeft,
                                                            child: GradientCard(
                                                              child: Padding(
                                                                padding: const EdgeInsets.all(4.0),
                                                                child: Text(dateString, style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize: 13,
                                                                  fontWeight: FontWeight.bold,
                                                                ),),
                                                              ),
                                                              gradient: Gradients.cosmicFusion,
                                                              shadowColor: Gradients
                                                                  .cosmicFusion.colors.last
                                                                  .withOpacity(0.5),
                                                            ),
                                                          ));
                                                    }),
                                              ),
                                            ],
                                          ),
                                        ),
                                        //\nDar Al-Hijrah\n\n12/08/2019, Monday at 12:00 AM
                                        Expanded(
                                          flex: 3,
                                          child:
                                          _eventsModels.data.events.isNotEmpty ? Container(
                                              width: 100.0,
                                              height: 100.0,
                                              decoration: new BoxDecoration(
                                                shape: BoxShape.rectangle,
                                                borderRadius: new BorderRadius.only(
                                                  topLeft: const Radius.circular(10.0),
                                                  topRight: const Radius.circular(10.0),
                                                  bottomLeft: const Radius.circular(10.0),
                                                  bottomRight: const Radius.circular(10.0),
                                                ),
                                                image: new DecorationImage(
                                                  fit: BoxFit.fill,
                                                  image: new NetworkImage(
                                                      _eventsModels.data.events[_eventsModels.data.events.length - 1].image),
                                                ),
                                              )) :
                                          SizedBox(
                                            child: Image.asset('assets/kaba.png'),
                                          ),
                                        ),
                                      ]),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
//                  Divider(
//                    height: 5.0,
//                    color: Colors.black12,
//                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Center(
                      child: Wrap(
                        //mainAxisAlignment: MainAxisAlignment.spaceAround,
                        spacing: 4.0,
                        // gap between adjacent chips
                        runSpacing: 4.0,
                        // gap between lines
                        direction: Axis.horizontal,
                        // main axis (rows or columns)
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: <Widget>[
                                    CircularGradientButton(
                                      child: Image.asset(
                                        'assets/event_n.png',
                                        height: 25,
                                        width: 25,
                                      ),
                                      callback: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return EventPage();
                                        }));
                                      },
                                      gradient: Gradients.rainbowBlue,
                                      shadowColor: Gradients
                                          .rainbowBlue.colors.last
                                          .withOpacity(0.5),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Text(
                                        'Events',
                                        style: TextStyle(
                                          fontSize: 11.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: <Widget>[
                                    CircularGradientButton(
                                      child: Image.asset(
                                        'assets/janazah_n.png',
                                        height: 25,
                                        width: 25,
                                      ),
                                      callback: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return JanazahsPage();
                                        }));
                                      },
                                      gradient: Gradients.rainbowBlue,
                                      shadowColor: Gradients
                                          .rainbowBlue.colors.last
                                          .withOpacity(0.5),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Text(
                                        'Janazah',
                                        style: TextStyle(
                                          fontSize: 11.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: <Widget>[
                                    Stack(
                                      children: <Widget>[
                                        CircularGradientButton(
                                          child: Image.asset(
                                            'assets/dua_n.png',
                                            height: 25,
                                            width: 25,
                                          ),
                                          callback: () {
//                                            Navigator.push(context,
//                                                MaterialPageRoute(
//                                                    builder: (context) {
//                                                      return DemoPage();
//                                                    }));
                                          },
                                          gradient: Gradients.rainbowBlue,
                                          shadowColor: Gradients
                                              .rainbowBlue.colors.last
                                              .withOpacity(0.5),
                                        ),
                                        Positioned.fill(
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Color(0xffFF6600),
                                                  shape: BoxShape.rectangle,
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(15.0),
                                                      bottomRight: Radius.circular(15.0),
                                                    topRight: Radius.circular(15.0),
                                                    bottomLeft: Radius.circular(15.0)
                                                  )
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(4.0),
                                                child: Text(
                                                  'Coming soon',
                                                  style: TextStyle(
                                                    fontSize: 10.0,
                                                    color: Colors.white
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Text(
                                        'Dua Board',
                                        style: TextStyle(
                                          fontSize: 11.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: <Widget>[
                                    CircularGradientButton(
                                      child: Image.asset(
                                        'assets/jummah.png',
                                        height: 25,
                                        width: 25,
                                      ),
                                      callback: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                                  return JummahPage();
                                                }));
                                      },
                                      gradient: Gradients.rainbowBlue,
                                      shadowColor: Gradients
                                          .rainbowBlue.colors.last
                                          .withOpacity(0.5),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Text(
                                        'Jummah',
                                        style: TextStyle(
                                          fontSize: 11.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: <Widget>[
                                    CircularGradientButton(
                                      child: Image.asset(
                                        'assets/azan.png',
                                        height: 25,
                                        width: 25,
                                      ),
                                      callback: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return AzanPage();
                                        }));
                                      },
                                      gradient: Gradients.rainbowBlue,
                                      shadowColor: Gradients
                                          .rainbowBlue.colors.last
                                          .withOpacity(0.5),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 2.0, horizontal: 2.0),
                                      child: Text(
                                        'Azan',
                                        style: TextStyle(
                                          fontSize: 11.0,
                                        ),
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: <Widget>[
                                    CircularGradientButton(
                                      child: Image.asset(
                                        'assets/qibla_n.png',
                                        height: 25,
                                        width: 25,
                                      ),
                                      callback: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return QuranPage(
                                              "https://qiblafinder.withgoogle."
                                                  "com/intl/en/",
                                              "Qibla");
                                        }));
                                      },
                                      gradient: Gradients.rainbowBlue,
                                      shadowColor: Gradients
                                          .rainbowBlue.colors.last
                                          .withOpacity(0.5),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Text(
                                        'Qibla',
                                        style: TextStyle(
                                          fontSize: 11.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: <Widget>[
                                    CircularGradientButton(
                                      child: Image.asset(
                                        'assets/quran_n.png',
                                        height: 25,
                                        width: 25,
                                      ),
                                      callback: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return QuranPage(
                                              "http://quran.ksu.edu"
                                                  ".sa/index.php",
                                              "Quran");
                                        }));
                                      },
                                      gradient: Gradients.rainbowBlue,
                                      shadowColor: Gradients
                                          .rainbowBlue.colors.last
                                          .withOpacity(0.5),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 2.0, horizontal: 2.0),
                                      child: Text(
                                        'Quran',
                                        style: TextStyle(
                                          fontSize: 11.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: <Widget>[
                                    CircularGradientButton(
                                      child: Image.asset(
                                        'assets/live.png',
                                        height: 25,
                                        width: 25,
                                      ),
                                      callback: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return YoutubePage();
                                        }));
                                      },
                                      gradient: Gradients.rainbowBlue,
                                      shadowColor: Gradients
                                          .rainbowBlue.colors.last
                                          .withOpacity(0.5),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Text(
                                        '  Live  ',
                                        style: TextStyle(
                                          fontSize: 11.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: <Widget>[
                                    CircularGradientButton(
                                      child: Image.asset(
                                        'assets/business.png',
                                        height: 25,
                                        width: 25,
                                      ),
                                      callback: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return DirectoryListPage();
                                        }));
                                      },
                                      gradient: Gradients.rainbowBlue,
                                      shadowColor: Gradients
                                          .rainbowBlue.colors.last
                                          .withOpacity(0.5),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Text(
                                        'Business\nDirectory',
                                        style: TextStyle(
                                          fontSize: 11.0,
                                        ),
                                      ),
                                    ),
                                    /*FlatButton(
                                  onPressed: () {},
                                  child: Icon(
                                    Icons.email,
                                    color: Colors.white,
                                    size: 15.0,
                                  ),
                                  shape: CircleBorder(),
                                  color: Colors.blueAccent,
                                  padding: EdgeInsets.all(25.0),
                                ),
                                Text('Business\nDirectory'),*/
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: <Widget>[
                                    Stack(
                                      children: <Widget>[
                                        CircularGradientButton(
                                          child: Image.asset(
                                            'assets/community_n.png',
                                            height: 25,
                                            width: 25,
                                          ),
                                          callback: () {
//                                            Navigator.push(context,
//                                                MaterialPageRoute(
//                                                    builder: (context) {
//                                                      return DemoPageTwo();
//                                                    }));
                                          },
                                          gradient: Gradients.rainbowBlue,
                                          shadowColor: Gradients
                                              .rainbowBlue.colors.last
                                              .withOpacity(0.5),
                                        ),
                                        Positioned.fill(
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Color(0xffFF6600),
                                                  shape: BoxShape.rectangle,
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(15.0),
                                                      bottomRight: Radius.circular(15.0),
                                                      topRight: Radius.circular(15.0),
                                                      bottomLeft: Radius.circular(15.0)
                                                  )
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(4.0),
                                                child: Text(
                                                  'Coming soon',
                                                  style: TextStyle(
                                                      fontSize: 10.0,
                                                      color: Colors.white
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Text(
                                        'Community',
                                        style: TextStyle(
                                          fontSize:11.0,
                                        ),
                                      ),
                                    ),
                                    /*FlatButton(
                                  onPressed: () {},
                                  child: Icon(
                                    Icons.email,
                                    color: Colors.white,
                                    size: 15.0,
                                  ),
                                  shape: CircleBorder(),
                                  color: Colors.blueAccent,
                                  padding: EdgeInsets.all(25.0),
                                ),
                                Text('Community'),*/
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: <Widget>[
                                    CircularGradientButton(
                                      child: Image.asset(
                                        'assets/settings_n.png',
                                        height: 25,
                                        width: 25,
                                      ),
                                      callback: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return SettingsPage();
                                        }));
                                      },
                                      gradient: Gradients.rainbowBlue,
                                      shadowColor: Gradients
                                          .rainbowBlue.colors.last
                                          .withOpacity(0.5),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Text(
                                        'Settings',
                                        style: TextStyle(
                                          fontSize: 11.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: <Widget>[
                                    CircularGradientButton(
                                      child: Image.asset(
                                        'assets/login.png',
                                        height: 25,
                                        width: 25,
                                      ),
                                      callback: () {
                                        if (isLoggedIn) {
                                          //logOut();
                                          _logOut();
                                        } else {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return LoginPage();
                                          }));
                                        }
                                      },
                                      gradient: Gradients.rainbowBlue,
                                      shadowColor: Gradients
                                          .rainbowBlue.colors.last
                                          .withOpacity(0.5),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Text(
                                        login_text,
                                        style: TextStyle(
                                          fontSize: 11.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.black,
                  ),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Image.asset(
                                  'assets/dollar.png',
                                  height: 25,
                                  width: 25,
                                ),
                                flex: 1,
                              ),
                              Expanded(
                                child: Center(
                                  child: Column(
                                    children: <Widget>[
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Support Our Mission',
                                          style: TextStyle(
                                            color: Color(0xffA1A1A1),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Donate Today',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                flex: 4,
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
