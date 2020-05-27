import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';

Future<LocationData> locationTrace() async {
  var location = new Location();
  LocationData currentLocation;
  try {
    currentLocation = await location.getLocation();
  } catch (e) {
    print('54354353' + e);
    currentLocation = null;
  }
  final coordinates = new Coordinates(currentLocation.latitude, currentLocation.longitude);
  var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
//  print("${addresses.first.countryName} :  : locality ${addresses.first.locality} ");
  return currentLocation;
}