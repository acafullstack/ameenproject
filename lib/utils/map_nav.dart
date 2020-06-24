import 'dart:ffi';

import 'package:geocoder/geocoder.dart';
import 'package:google_maps_webservice/directions.dart';
import 'package:url_launcher/url_launcher.dart';

launchingURL(String address) async {
  //'google.navigation:q=${_mapLocation['latitude']},${_mapLocation['longitude']}';
  //https://github.com/flutter/flutter/issues/21115
  var addresses = await Geocoder.local.findAddressesFromQuery(address);
  var first = addresses.first;
  double lat = first.coordinates.latitude;
  double lon = first.coordinates.longitude;
  String url = 'google.navigation:q=$lat,$lon';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

extractCoordinates(String address) async {
  //'google.navigation:q=${_mapLocation['latitude']},${_mapLocation['longitude']}';
  //https://github.com/flutter/flutter/issues/21115
  var addresses = await Geocoder.local.findAddressesFromQuery(address);
  var first = addresses.first;
  double lat = first.coordinates.latitude;
  double lon = first.coordinates.longitude;

  return Location(lat, lon);

}

launchingURLWithLatLng(double lat, double lon) async {
  String url = 'google.navigation:q=$lat,$lon';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}


