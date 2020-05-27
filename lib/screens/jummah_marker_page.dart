import 'dart:async';
import 'package:ameen_project/model/jummah_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/azan_timer_box.dart';


class JummahMarkerPage extends StatefulWidget {
  List<Events> _placeMarker;
  JummahMarkerPage(this._placeMarker);

  @override
  _JummahMarkerPageState createState() => _JummahMarkerPageState(this._placeMarker);
}

class _JummahMarkerPageState extends State<JummahMarkerPage> {

  Completer<GoogleMapController> controller = Completer();

  _JummahMarkerPageState(this._placeMarker);

  var location = new Location();

  LocationData locationData;

  String userLocation;

  List<Events> _placeMarker;
  //Map markers = {};

  Set<Marker> markers = Set();
  String _prayer_name = "Fajar";
  bool _azanTimeSwitched = true;

  _loadData() async{
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


  _generateMarkers() async {
    Set<Marker> markers = Set();
    for(Events places in _placeMarker) {
      Marker newMarker = Marker(
        markerId: MarkerId('${places.id}'),
        position: LatLng(double.parse(places.latitude), double.parse(places.longitude)),
        infoWindow: InfoWindow(title: places.name),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueBlue,
        ),
      );
      markers.add(newMarker);
    }
    setState(() {
      this.markers = markers;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
    _getLocation().then((value) {
      setState(() {
        locationData = value;
      });
    });
    _generateMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(double.infinity, 50),
          child: getAppBar(context, "Map", _prayer_name, _azanTimeSwitched)
      ),
      body: locationData!= null ? _googleMap(context) : Container(),
    );
  }

  Future<LocationData> _getLocation() async {
    LocationData currentLocation;
    try {
      currentLocation = await location.getLocation();
    } catch (e) {
      print('54354353' + e);
      currentLocation = null;
    }
    return currentLocation;
  }

  Widget _googleMap(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
            target: _placeMarker.length > 0 ? computeCentroid():
            LatLng(locationData.latitude,
                locationData.longitude),
            zoom: 10),
        onMapCreated: (GoogleMapController controller) {
          this.controller.complete(controller);
        },
//        markers: {newMarker, oldMarker},
        markers: markers,
      ),
    );
  }

  LatLng computeCentroid() {
    double latitude = 0;
    double longitude = 0;
    List<LatLng> points = List<LatLng>();
    for (Events place in _placeMarker) {
      points.add(LatLng(double.parse(place.latitude),
          double.parse(place.longitude)));
    }
    int count = _placeMarker.length;

    for (LatLng point in points) {
      latitude += point.latitude;
      longitude += point.longitude;
    }

    return new LatLng(latitude/count, longitude/count);
  }
}

Marker newMarker = Marker(
  markerId: MarkerId('newyork'),
  position: LatLng(40.742451, -74.005974),
  infoWindow: InfoWindow(title: 'La pasta'),
  icon: BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueBlue,
  ),
);
Marker oldMarker = Marker(
  markerId: MarkerId('newyork'),
  position: LatLng(40.729640, -73.983510),
  infoWindow: InfoWindow(title: 'New york'),
  icon: BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueBlue,
  ),
);
