import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:ameen_project/model/events_model.dart';
import 'package:ameen_project/utils/map_nav.dart';
import 'package:ameen_project/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/azan_timer_box.dart';

class EachEventPage extends StatefulWidget {
  Events _events;

  EachEventPage(this._events);

  _EachEventPageState createState() => _EachEventPageState(this._events);
}

class _EachEventPageState extends State<EachEventPage> {
  GlobalKey _containerKey = GlobalKey();

  Events _events;
  String _prayer_name = "Fajar";
  bool _azanTimeSwitched = true;
  Completer<GoogleMapController> controller = Completer();

  var _latitude = 40.6971494;
  var _longitude = -74.2598542;

  //40.6971494,-74.2598542

  _EachEventPageState(this._events);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
    _latitude = _events.latitude.isNotEmpty
        ? double.parse(_events.latitude)
        : _latitude;
    _longitude = _events.longitude.isNotEmpty
        ? double.parse(_events.longitude)
        : _longitude;
  }

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

  Future<dynamic> convertWidgetToImage() async {
    RenderRepaintBoundary renderRepaintBoundary =
        _containerKey.currentContext.findRenderObject();
    ui.Image boxImage = await renderRepaintBoundary.toImage(pixelRatio: 1);
    ByteData byteData =
        await boxImage.toByteData(format: ui.ImageByteFormat.png);
    Uint8List uint8list = byteData.buffer.asUint8List();
    final result = await ImageGallerySaver.saveImage(uint8list);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: Size(double.infinity, 50),
            child: getAppBar(
                context, _events.name, _prayer_name, _azanTimeSwitched)),
        resizeToAvoidBottomPadding: false,
        body: Builder(
          builder: (BuildContext buildContext) {
            return RepaintBoundary(
              key: _containerKey,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.white,
                child: ListView(
                  children: <Widget>[
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/download.png"),
                            fit: BoxFit.cover),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Event Name',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
                        _events.name,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      onTap: () {
                        print('');
                      },
                    ),
                    Divider(
                      height: 5.0,
                      color: Colors.black12,
                    ),
                    ListTile(
                      title: Text(
                        'Date & Time',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
                        _events.eventDate + ' ' + _events.eventTime,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      onTap: () {
                        print('');
                      },
                    ),
                    Divider(
                      height: 5.0,
                      color: Colors.black12,
                    ),
                    ListTile(
                      title: Text(
                        'Location',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
                        _events.location,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      onTap: () {
                        print('');
                      },
                    ),
                    Divider(
                      height: 5.0,
                      color: Colors.black12,
                    ),
                    Container(
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      child: GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: CameraPosition(
                            target: LatLng(_latitude, _longitude), zoom: 15),
                        onMapCreated: (GoogleMapController controller) {
                          this.controller.complete(controller);
                        },
                        markers: {
                          Marker(
                            position: LatLng(_latitude, _longitude),
                            markerId: MarkerId('newyork'),
                          ),
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: RaisedButton.icon(
                                onPressed: () {
                                  convertWidgetToImage().then((value) {
                                    if (value is bool)
                                      showMessageBar(buildContext,
                                          "File saved to Gallery");
                                    else
                                      showMessageBar(
                                          buildContext,
                                          "File saved to Gallery, path: " +
                                              value);
                                  });
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(20.0))),
                                label: Text(
                                  'Save',
                                  style: TextStyle(
                                    color: Color(0xff4D82FF),
                                  ),
                                ),
                                icon: Image.asset('assets/save.png'),
                                textColor: Colors.lightBlue,
                                splashColor: Colors.red,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: RaisedButton.icon(
                                onPressed: () {
                                  Share.share(
                                      'Events: #${_events.name}, #${_events.eventDate}, #${_events.location}'
                                      '\ncheck out Ameen app '
                                      'https://play.google.com/store/apps/details?id=com.app.p5623DC',
                                      subject: '');
                                  //#4D82FF
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(20.0))),
                                label: Text(
                                  'Share',
                                  style: TextStyle(
                                    color: Color(0xff4D82FF),
                                  ),
                                ),
                                icon: Image.asset('assets/share.png'),
                                textColor: Colors.lightBlue,
                                splashColor: Colors.red,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: RaisedButton.icon(
                                onPressed: () {
                                  launchingURLWithLatLng(_latitude, _longitude);
                                  //#4D82FF
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(20.0))),
                                label: Text(
                                  'Route',
                                  style: TextStyle(
                                    color: Color(0xffE83A5E),
                                  ),
                                ),
                                icon: Image.asset('assets/route.png'),
                                textColor: Colors.lightBlue,
                                splashColor: Colors.red,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ));
  }
}
