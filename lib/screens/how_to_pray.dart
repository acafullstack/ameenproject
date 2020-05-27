import 'package:ameen_project/model/Timing.dart';
import 'package:ameen_project/model/slider_image_model.dart';
import 'package:ameen_project/network/azan_time.dart';
import 'package:ameen_project/screens/each_event_page.dart';
import 'package:ameen_project/utils/notification_alarm.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:ameen_project/utils/azan_timer_box.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SliderPage extends StatefulWidget {
  bool pageOption;
  SliderPage(this.pageOption);
  _SliderPageState createState() => _SliderPageState(this.pageOption);
}

class _SliderPageState extends State<SliderPage> {

  String _prayer_name = "Fajar";
  bool _azanTimeSwitched = true;

  bool pageOption;

  int _current = 0;

  SliderImage _sliderImage;

  SharedPreferences prefs;

  _SliderPageState(this.pageOption);


  List<String> imgList = [
    'http://ameenproject.org/appadmin/public/cdn/salat/1.jpg'
  ];

  final List<String> imgTitle = [
    'Niyat'
  ];

  final List<String> imgDetails = [
    'Niyat'
  ];

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i  ++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  Future loadData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      if (preferences.containsKey('_azanTimeSwitched')) {
      _azanTimeSwitched = preferences.getBool('_azanTimeSwitched');
      }
      _prayer_name = preferences.getString("prayer_name");
      var parts = _prayer_name.split("^");
      _prayer_name = parts[0] + parts[1];
    });
  }

  _loadSliderImage() async {
    var jsonData = null;
    //http://ameenproject.org/appadmin/public/api/v1/janazahs/status/past
    String apiTag = pageOption ? "how_to_pray_safi" : "how_to_pray_hanafi";
    final response = await http.get("http://ameenproject.org/appadmin/public/api/v1/${apiTag}", headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    });

    if(response.statusCode == 200) {
      jsonData = json.decode(response.body);
      setState(() {
        _sliderImage = new SliderImage.fromJson(jsonData);
        imgList.clear();
        imgTitle.clear();
        imgDetails.clear();
        int count = _sliderImage.data.salats.length;
        for(int i = 0; i < count; i++) {
          imgList.add(_sliderImage.data.salats[i].link);
          imgTitle.add(_sliderImage.data.salats[i].header);
          imgDetails.add(_sliderImage.data.salats[i].subHeader);
        }
      });
    }
    //print('Token : ${token}');
    //print(jsonData.toString());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
    _loadSliderImage();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(double.infinity, 50),
          child: getAppBar(context, "How to pray", _prayer_name, _azanTimeSwitched)
      ),
      resizeToAvoidBottomPadding: false,
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 5.0),
              child: Text(
                imgTitle[_current],
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: CarouselSlider(
              initialPage: 0,
              enlargeCenterPage: true,
              reverse: false,
              enableInfiniteScroll: true,
              onPageChanged: (index) {
                setState(() {
                  _current = index;
                  print("_current: $_current");
                });
              },
              items: imgList.map((imgUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 10.0),
                      decoration: BoxDecoration(
                        color: Colors.green,
                      ),
                      child: Image.network(imgUrl, fit: BoxFit.fill,),
                    );
                  },
                );
              }).toList(),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Text(
                imgDetails[_current],
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: map<Widget>(imgList, (index, url) {
              return Container(
                width: 10.0,
                height: 10.0,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(shape: BoxShape.circle,
                  color: _current == index ? Colors.pink : Colors.grey),
              );
            }),
          ),
        ],
      ),
    );
  }
}

