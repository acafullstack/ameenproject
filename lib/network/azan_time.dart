import 'package:ameen_project/model/Timing.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List> getJsonData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String city = "New York";
  String country = "USA";
  if (prefs.containsKey("city") & prefs.containsKey("country")) {
    city = prefs.getString("city");
    country = prefs.getString("country");
  }

  List eventTime = [];
  //http://api.aladhan.com/v1/timingsByCity?city=Dhaka&method=8
  var response = await http.get(Uri.encodeFull(
      "http://api.aladhan.com/v1/timingsByCity?city=${city}&country=${country}&method=8"));
  final jsonResponse = json.decode(response.body);
 
  AzanTime azan_time = new AzanTime.fromJson(jsonResponse);

  eventTime.add(azan_time.data.timings.fajr);
  eventTime.add(azan_time.data.timings.dhuhr);
  eventTime.add(azan_time.data.timings.asr);
  eventTime.add(azan_time.data.timings.maghrib);
  eventTime.add(azan_time.data.timings.isha);

  return eventTime;
}

Future<String> showCurrentPrayerTime(List eventTime) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  //2020-02-01 05:17:00.000  2020-02-01 12:13:00.000

  final currentTime = DateTime.now();
  DateFormat dateFormat = new DateFormat.Hm();

  DateTime prayerTimer;
  print('Prayer Time: ${eventTime.length}');
  String prayer_name = "Fajar";
  for (var i = 0; i < eventTime.length - 1; i++) {
    DateTime prayer_time_start = dateFormat.parse(eventTime[i]);
    prayer_time_start = new DateTime(currentTime.year, currentTime.month,
        currentTime.day, prayer_time_start.hour, prayer_time_start.minute);

    DateTime prayer_time_end = dateFormat.parse(eventTime[i + 1]);
    prayer_time_end = new DateTime(currentTime.year, currentTime.month,
        currentTime.day, prayer_time_end.hour, prayer_time_end.minute);

    print('Prayer Time dif: ${i} ${prayer_time_start}  ${prayer_time_end}');
    if (currentTime.isAfter(prayer_time_start) &&
        currentTime.isBefore(prayer_time_end)) {
      final df = new DateFormat('h:mm a').format(prayer_time_end);
      prayer_name = (i == 0)
              ? "Dhuhr ^" + df.toString()
              : (i == 1)
                  ? "Asr ^" + df.toString()
                  : (i == 2)
                      ? "Maghrib ^" + df.toString()
                      : "Isha'a ^" + df.toString();
      prayerTimer = prayer_time_end;

      print('Prayer Time dif: ${i} ${prayer_time_start}  ${prayer_time_end}');
      break;
    } else {
      DateTime prayer_time_start = dateFormat.parse(eventTime[0]);
      prayerTimer = prayer_time_start;
      final df = new DateFormat('h:mm a').format(prayer_time_start);
      prayer_name = "Fajr ^" + df.toString();
    }
  }
  var time = new DateTime(currentTime.year, currentTime.month,
      currentTime.day, prayerTimer.hour, prayerTimer.minute);
  preferences.setString("prayerTimer", time.toString());
  preferences.setString("prayer_name", prayer_name);
  //print('Prayer Time: ${prayer_name}');
  return prayer_name;
}
