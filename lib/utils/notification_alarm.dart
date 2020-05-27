import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

FlutterLocalNotificationsPlugin localNotificationAlarm()  {
   var initializationSettingsAndroid =
   new AndroidInitializationSettings('@mipmap/ic_launcher');
   var initializationSettingsIOS = new IOSInitializationSettings();
   var initializationSettings = new InitializationSettings(
       initializationSettingsAndroid, initializationSettingsIOS);
   FlutterLocalNotificationsPlugin localNotificationsPlugin =
   new FlutterLocalNotificationsPlugin();
   localNotificationsPlugin.initialize(initializationSettings,
       onSelectNotification: onSelectNotification);
   return localNotificationsPlugin;

 }


Future onSelectNotification(String payload) async {
  print('payload');
  print(payload);
}

Future showNotificationWithSound(FlutterLocalNotificationsPlugin localNotificationsPlugin, String timeDay, String eventTitle, int index) async {
  //var now = new DateTime.now().add(new Duration(minutes: 2+index));
  //DateFormat dateFormat = new DateFormat("yyyy-MM-dd HH:mm:ss");
  bool _azanSwitched = false;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('_azanSwitched')) {
    _azanSwitched = prefs.getBool('_azanSwitched');
  }
  var timeDate = DateFormat.Hm().parse(timeDay);

  //dateFormat.parse("${now.year}-${now.month}-${now.day} $timeDay:14");


  var time = Time(timeDate.hour, timeDate.minute, timeDate.second);

  print("alarm time ::::: ${timeDate.hour} ${timeDate.minute} ${timeDate.second}");
  print('time:::::: ${time.hour}h${time.minute}m${time.second}s');

 // var scheduledNotificationDateTime = new DateTime.now().add(new Duration(minutes: 2+index));
  // var scheduledNotificationDateTime = dateFormat.parse("2020-01-11 16:51:14");
//  new DateTime.now().add(new Duration(minutes: 2+index));
 // print('75765765765 $timeDate ${scheduledNotificationDateTime}');
  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'your channel id', 'your channel name', 'your channel description',
      sound: _azanSwitched ? 'azan' : null,
      importance: Importance.Max,
      priority: Priority.High);
  var iOSPlatformChannelSpecifics =  new IOSNotificationDetails();
  var platformChannelSpecifics = new NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
//  await localNotificationsPlugin.schedule(
//    index,
//    'Alarm',
//    'Prayer Time.',
//    timeDate,
//    platformChannelSpecifics,
//    payload: 'Custom_Sound ${index}',
//  );
  String description = "$eventTitle, \nTime: ${time.hour}:${time.minute}";
    await localNotificationsPlugin.showDailyAtTime(index, 'Alarm for $eventTitle',
        description, time, platformChannelSpecifics, payload: 'Custom_Sound $index');
}

Future setUpNotificationWithSound(FlutterLocalNotificationsPlugin localNotificationsPlugin, List eventTime) async {
  List<String> eventTitle = [
    "Fajr","Dhuhr","Asr","Maghrib","Isha'a"
  ];
  var now = new DateTime.now();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  for(int index = 0; index<eventTime.length; index++) {
    //print("prayer time ::: ${eventTime[index]}");
    showNotificationWithSound(localNotificationsPlugin, eventTime[index], eventTitle[index], index);
    prefs.setBool(eventTitle[index], true);
  }
}

Future setUpEachNotificationWithSound(FlutterLocalNotificationsPlugin localNotificationsPlugin, List eventTime) async {
  List<String> eventTitle = [
    "Fajr","Dhuhr","Asr","Maghrib","Isha'a"
  ];
  var now = new DateTime.now();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  print("eventTitles ::: $eventTitle");
  for(int index = 0; index<eventTime.length; index++) {
    //print("prayer time ::: ${eventTime[index]}");
    if (prefs.containsKey(eventTitle[index])) {
      if(prefs.getBool(eventTitle[index])) {
        showNotificationWithSound(localNotificationsPlugin, eventTime[index], eventTitle[index], index);
      }
    }
  }
}

Future deleteNotification(FlutterLocalNotificationsPlugin localNotificationsPlugin, int index) async {
  await localNotificationsPlugin.cancel(index);
  print('deleted $index');
}

Future deleteAllNotification(FlutterLocalNotificationsPlugin localNotificationsPlugin) async {
  await localNotificationsPlugin.cancelAll();
  List<String> eventTitle = [
    "Fajr","Dhuhr","Asr","Maghrib","Isha'a"
  ];
  SharedPreferences prefs = await SharedPreferences.getInstance();
  for(int index = 0; index<eventTitle.length; index++) {
    if (prefs.containsKey(eventTitle[index])) {
      prefs.setBool(eventTitle[index], false);
    }
  }
  print('deleted all success');
}

Future showNotification(FlutterLocalNotificationsPlugin localNotificationsPlugin, String title, String description) async {

  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'your channel id', 'your channel name', 'your channel description',
      importance: Importance.Max,
      priority: Priority.High);
  var iOSPlatformChannelSpecifics =
  new IOSNotificationDetails();
  var platformChannelSpecifics = new NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

  await localNotificationsPlugin.show(111, title,
      description, platformChannelSpecifics, payload: title);
}