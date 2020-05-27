import 'dart:typed_data';

import 'package:ameen_project/model/janazah_model.dart';
import 'package:ameen_project/model/jummah_model.dart';
import 'package:ameen_project/utils/map_nav.dart';
import 'package:ameen_project/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:ui' as ui;
import '../utils/azan_timer_box.dart';

class EachJummahPage extends StatefulWidget {
  Events _jummahModel;
  EachJummahPage(this._jummahModel);
  _EachJummahPageState createState() => _EachJummahPageState(this._jummahModel);
}

class _EachJummahPageState extends State<EachJummahPage> {
  Events _jummahModel;
  Completer<GoogleMapController> controller = Completer();
  String _prayer_name = "Fajr";
  bool _azanTimeSwitched = true;
  _EachJummahPageState(this._jummahModel);

  GlobalKey _containerKey = GlobalKey();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  loadData() async{
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

  Future<String> convertWidgetToImage() async {
    RenderRepaintBoundary renderRepaintBoundary = _containerKey.currentContext.findRenderObject();
    ui.Image boxImage = await renderRepaintBoundary.toImage(pixelRatio: 1);
    ByteData byteData = await boxImage.toByteData(format: ui.ImageByteFormat.png);
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
          child: getAppBar(context, "Jummah Info", _prayer_name, _azanTimeSwitched)
      ),
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
                          image: AssetImage("assets/download.png"), fit: BoxFit.cover),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Name of Organization',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      _jummahModel.name,
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
                              image: new NetworkImage(
                                  _jummahModel.image),
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
                      'Contact Name',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      _jummahModel.contactName,
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
                      'Contact Phone Number',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      _jummahModel.contactPhone,
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
                  // ListTile(
                  //   title: Text(
                  //     'Address of Jummah',
                  //     style: TextStyle(
                  //       color: Colors.grey,
                  //       fontSize: 13,
                  //     ),
                  //   ),
                  //   subtitle: Text(
                  //     _jummahModel.address,
                  //     style: TextStyle(
                  //       color: Colors.black,
                  //     ),
                  //   ),
                  //   onTap: () {
                  //     print('');
                  //   },
                  // ),
                  ListTile(
                    title: Text(
                      'Date & Time',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _jummahModel.date != null
                          ? Text(
                            '${_jummahModel.date}, Friday',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ) : Container(),
                          _jummahModel.firstJummah != null
                          ? Text(
                            '1st Jummah: ${_jummahModel.firstJummah}',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ) : Container(),
                          _jummahModel.secondJummah != null
                          ? Text(
                            '2st Jummah: ${_jummahModel.secondJummah}',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ) : Container(),
                          _jummahModel.thirdJummah != null
                            ? Text(
                            '3st Jummah: ${_jummahModel.thirdJummah}',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ) : Container(),
                        ],
                      ),
                    ),
                    // Text(
                    //   _jummahModel.thirdJummah != null ? _jummahModel.firstJummah + " | " + _jummahModel.secondJummah + " | " + _jummahModel.thirdJummah
                    //       : _jummahModel.firstJummah + " | " + _jummahModel.secondJummah,
                    //   style: TextStyle(
                    //     color: Colors.black,
                    //   ),
                    // ),
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
                      'Website',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      _jummahModel.website,
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
                          target: LatLng(double.parse(_jummahModel.latitude),
                              double.parse(_jummahModel.longitude)), zoom: 15),
                      onMapCreated: (GoogleMapController controller) {
                        this.controller.complete(controller);
                      },
                      markers: {
                        Marker(
                          position: LatLng(double.parse(_jummahModel.latitude),
                              double.parse(_jummahModel.longitude)),
                          markerId: MarkerId('jummah'),
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
                                 showMessageBar(buildContext, "File saved to Gallery, path: " + value);
                               });
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(20.0))),
                              label: Text(
                                'Save',
                                style: TextStyle(color: Color(0xff4D82FF),),
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
                                Share. share('Jummah: #${_jummahModel.name}, '
                                    '#${_jummahModel.address}, #${_jummahModel.firstJummah}, #${_jummahModel.secondJummah}'
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
                                style: TextStyle(color: Color(0xff4D82FF),),
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
                                launchingURLWithLatLng(double.parse(_jummahModel.latitude),
                                    double.parse(_jummahModel.longitude));
                                //#4D82FF
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(20.0))),
                              label: Text(
                                'Route',
                                style: TextStyle(color: Color(0xffE83A5E),),
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
      )

    );
  }
}
