import 'dart:async';
import 'package:ameen_project/model/place.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

//AIzaSyC5SCmJTL7dY85G3f0hq-gIq7FOzdNfssc

//AIzaSyDRY98-IEBkxwWNyWsYsw_QpRenFq92Sug

class GetLocationPage extends StatefulWidget {
  @override
  _GetLocationPageState createState() => _GetLocationPageState();
}

class _GetLocationPageState extends State<GetLocationPage> {
  Completer<GoogleMapController> controller = Completer();

  var location = new Location();

  LocationData locationData;

  String userLocation;

  List<Place> _placesList;

  final List<Place> _suggestedList = [
    Place('New York'),
    Place('Florida'),
    Place('DC'),
    Place('Texus'),
  ];

  //var currentLocation = <String, double>{};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _placesList = _suggestedList;

    _getLocation().then((value) {
      setState(() {
        locationData = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Stack(
          children: <Widget>[
            _googleMap(context),
            Column(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Container(
                      height: 42,
                      child: TextField(
                        onChanged: (text) {
                          getLocationResult(text);
                        },
                        decoration: InputDecoration(
                          hintText: "Search",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 0),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Divider(),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(16.0),
                    child: ListView.separated(
                        itemBuilder: (BuildContext context, int index) {
                          return Text("${_placesList[index].address}",
                          style: TextStyle(fontSize: 24, ),);
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            Divider(),
                        itemCount: _placesList.length),
                  ),
                ),
              ],
            )
          ],
        ));
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
            target: LatLng(locationData.latitude, locationData.longitude),
            zoom: 15),
        onMapCreated: (GoogleMapController controller) {
          this.controller.complete(controller);
        },
        markers: {
          Marker(
            position: LatLng(locationData.latitude, locationData.longitude),
            markerId: MarkerId('newyork'),
          ),
        },
      ),
    );
  }

  void getLocationResult(String input) async {
    String baseURL =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json";
    String type = '(regions)';
    String request =
        '$baseURL?input=$input'
        '&key=AIzaSyAmbl1YzfcisrzY4_mXePtFuo5KAro8G50&type=$type';
//AIzaSyASnQa-E0l1JzP03uF-HeTDe3hejQR4syE
    //AIzaSyDRY98-IEBkxwWNyWsYsw_QpRenFq92Sug
    //AIzaSyBk-h0-OaJcsPEfTJ_oZkphrp0SK5mQnwo
    if (input.isNotEmpty && input.length > 3) {
      Response response = await Dio().get(request);

      final predictions = response.data['predictions'];
      print('response 343535  $response');
      List<Place> _displayResults = [];

      for (var i = 0; i < predictions.lenght; i++) {
        String name = predictions[i]['description'];
        _displayResults.add(Place(name));
        print('response 343535  $name');
      }

      setState(() {
        _placesList = _displayResults;
      });
    }
  }
}

/*Marker newMarker(LocationData locationData) {
  return Marker(
    markerId: MarkerId('newyork'),
    position: LatLng(locationData.latitude, locationData.longitude),
    infoWindow: InfoWindow(title: 'La pasta'),
    icon: BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueBlue,
    ),
  );
}*/
