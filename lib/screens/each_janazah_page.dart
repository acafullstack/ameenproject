import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:ameen_project/model/janazah_model.dart';
import 'package:ameen_project/utils/map_nav.dart';
import 'package:ameen_project/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/azan_timer_box.dart';

class EachJanazahPage extends StatefulWidget {
  Janazahs _janazahModel;
  EachJanazahPage(this._janazahModel);
  _EachJanazahPageState createState() =>
      _EachJanazahPageState(this._janazahModel);
}

class _EachJanazahPageState extends State<EachJanazahPage> {
  Janazahs _janazahModel;
  Completer<GoogleMapController> controller = Completer();
  String _prayer_name = "Fajar";
  bool _azanTimeSwitched = true;
  _EachJanazahPageState(this._janazahModel);

  GlobalKey _containerKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  loadData() async {
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
          child: getAppBar(context, _janazahModel.nameOfDeceased, _prayer_name,
              _azanTimeSwitched)),
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
//          _azanTimeSwitched ? getAlarm(context, _prayer_name) : Container(),
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
                      'Deceased Name',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      _janazahModel.nameOfDeceased,
                      style: TextStyle(
                        color: Colors.pink,
                        fontSize: 18,
                      ),
                    ),
                    onTap: () {
                      print('');
                    },
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Container(
                          width: 70.0,
                          height: 70.0,
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
                              image: new NetworkImage(_janazahModel.image),
                            ),
                          )),
                    ),
                  ),
                  Divider(
                    height: 5.0,
                    color: Colors.black12,
                  ),
                  ListTile(
                    title: Text(
                      'Age',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      _janazahModel.age,
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
                      'Heritage',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      _janazahModel.heritage,
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
                      'Day & Time',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      _janazahModel.janazahDate +
                          ' ' +
                          _janazahModel.janazahTime +
                          "\n" +
                          _janazahModel.janazah_after,
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
                      'Salat Al-Janazah',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      _janazahModel.mosque,
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
                      'Cemetery',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      _janazahModel.cemetery,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    onTap: () {
                      print('');
                    },
                  ),
                  Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    child: GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(
                          target: LatLng(double.parse(_janazahModel.latitude),
                              double.parse(_janazahModel.longitude)),
                          zoom: 15),
                      onMapCreated: (GoogleMapController controller) {
                        this.controller.complete(controller);
                      },
                      markers: {
                        Marker(
                          position: LatLng(double.parse(_janazahModel.latitude),
                              double.parse(_janazahModel.longitude)),
                          markerId: MarkerId('newyork'),
                        ),
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(5.0),
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
                                    showMessageBar(
                                        buildContext, "File saved to Gallery");
                                  else
                                    showMessageBar(
                                        buildContext,
                                        "File saved to Gallery, path: " +
                                            value);
                                });
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0))),
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
                                    'Janazahs: #${_janazahModel.nameOfDeceased}, '
                                    '#${_janazahModel.mosque}, #${_janazahModel.janazahDate}, #${_janazahModel.janazahTime}'
                                    '\ncheck out Ameen app '
                                    'https://play.google.com/store/apps/details?id=com.app.p5623DC',
                                    subject: '');
                                //#4D82FF
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0))),
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
                                launchingURLWithLatLng(
                                    double.parse(_janazahModel.latitude),
                                    double.parse(_janazahModel.longitude));
                                //#4D82FF
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0))),
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
      ),
    );
  }
}
