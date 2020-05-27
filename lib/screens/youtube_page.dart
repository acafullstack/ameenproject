import 'package:ameen_project/model/Timing.dart';
import 'package:ameen_project/network/azan_time.dart';
import 'package:ameen_project/network/video_list.dart';
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
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePage extends StatefulWidget {
  _YoutubePageState createState() => _YoutubePageState();
}

class _YoutubePageState extends State<YoutubePage> {

  List videoIds = [];
  List<YoutubePlayerController> _controllers;
  String _prayer_name = "";
  bool _azanTimeSwitched = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
  }

  Future _loadData() async {
    final data = await getVideoList();
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

    setState(() {
      videoIds = data;
      _controllers = videoIds.map<YoutubePlayerController>(
            (videoId) => YoutubePlayerController(
          initialVideoId: videoId,
          flags: YoutubePlayerFlags(
            autoPlay: false,
          ),
        ),
      ).toList();
    });
  }



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(double.infinity, 50),
          child: getAppBar(context, "Live Mecca/ Medina", _prayer_name, _azanTimeSwitched)
      ),
      resizeToAvoidBottomPadding: false,
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 8,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _controllers!= null ? ListView.separated(
                itemBuilder: (context, index) {
                  return YoutubePlayer(
                    key: ObjectKey(_controllers[index]),
                    controller: _controllers[index],
                    actionsPadding: EdgeInsets.only(left: 16.0),
                    bottomActions: [
                      CurrentPosition(),
                      SizedBox(width: 10.0),
                      ProgressBar(isExpanded: true),
                      SizedBox(width: 10.0),
                      RemainingDuration(),
                      FullScreenButton(),
                    ],
                  );
                },
                itemCount: videoIds.length,
                separatorBuilder: (context, _) => SizedBox(height: 10.0),
              ) : Center( child: CircularProgressIndicator()),
            ),
          ),
          Expanded(
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/download.png"),
                    fit: BoxFit.cover),
              ),
            ),
            flex: 1,
          ),
        ],
      ),
    );
  }
}
