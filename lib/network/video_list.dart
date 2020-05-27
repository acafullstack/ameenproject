import 'package:ameen_project/model/Timing.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

 Future<List> getVideoList() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  var jsonData = null;

  List _videoIds = [];
  VideoList list;

    final response = await http.get("http://ameenproject.org/appadmin/public/api/v1/videos", headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if(response.statusCode == 200 && response.body.length > 0) {
      jsonData = json.decode(response.body);
      list = VideoList.fromJson(jsonData);
      for(int index = 0; index < list.data._videos.length; index++) {
        String videoId = YoutubePlayer.convertUrlToId(list.data._videos[index]._link);
        _videoIds.add(videoId);
      }
    }
    print('print video id 555  $_videoIds');
  return _videoIds;
}


class VideoList {
  bool _success;
  String _message;
  Data _data;

  VideoList({bool success, String message, Data data}) {
    this._success = success;
    this._message = message;
    this._data = data;
  }

  bool get success => _success;
  set success(bool success) => _success = success;
  String get message => _message;
  set message(String message) => _message = message;
  Data get data => _data;
  set data(Data data) => _data = data;

  VideoList.fromJson(Map<String, dynamic> json) {
    _success = json['success'];
    _message = json['message'];
    _data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this._success;
    data['message'] = this._message;
    if (this._data != null) {
      data['data'] = this._data.toJson();
    }
    return data;
  }
}

class Data {
  List<Videos> _videos;

  Data({List<Videos> videos}) {
    this._videos = videos;
  }

  List<Videos> get videos => _videos;
  set videos(List<Videos> videos) => _videos = videos;

  Data.fromJson(Map<String, dynamic> json) {
    if (json['videos'] != null) {
      _videos = new List<Videos>();
      json['videos'].forEach((v) {
        _videos.add(new Videos.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this._videos != null) {
      data['videos'] = this._videos.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Videos {
  int _id;
  String _name;
  String _link;

  Videos({int id, String name, String link}) {
    this._id = id;
    this._name = name;
    this._link = link;
  }

  int get id => _id;
  set id(int id) => _id = id;
  String get name => _name;
  set name(String name) => _name = name;
  String get link => _link;
  set link(String link) => _link = link;

  Videos.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _name = json['name'];
    _link = json['link'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this._id;
    data['name'] = this._name;
    data['link'] = this._link;
    return data;
  }
}