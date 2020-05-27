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

import 'directory_list.dart';

class BusinessDirectoryPage extends StatefulWidget {
  _BusinessDirectoryPageState createState() => _BusinessDirectoryPageState();
}

class _BusinessDirectoryPageState extends State<BusinessDirectoryPage> {
  List eventTime = [];

  String _prayer_name = "Fajar";
  bool _azanTimeSwitched = true;

  List event_name_list = [
    "Car Sales, Repair, Rental",
    "Smartphones",
    "Computer Service & Training",
    "Handy Man",
    "Law Firms & Immigration",
    "Grocery",
    "Travels",
    "Housing",
    "Children Clothing",
    "Men Clothing"
  ];

  _loadData() async {
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
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(double.infinity, 50),
          child: getAppBar(context, "Business Directory", _prayer_name, _azanTimeSwitched)
      ),
      resizeToAvoidBottomPadding: false,
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 8,
            child: ListView.builder(
                itemCount: event_name_list.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 16.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                                  return DirectoryListPage();
                                }));
                          },
                          child: Text(
                            event_name_list[index],
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      Divider(
                        height: 5.0,
                        color: Colors.black12,
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
