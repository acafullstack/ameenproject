import 'dart:convert';

import 'package:ameen_project/model/place_model.dart';
import 'package:ameen_project/screens/each_event_page.dart';
import 'package:flutter/material.dart';
import 'package:ameen_project/utils/azan_timer_box.dart';
import 'package:ameen_project/screens/map_marker_page.dart';
import 'package:flutter/services.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:http/http.dart' as http;

class MapListPage extends StatefulWidget {
  bool position;
  MapListPage(this.position);
  _MapListPageState createState() => _MapListPageState(this.position);
}

class _MapListPageState extends State<MapListPage> {

  bool position;
  String _prayer_name = "Fajar";
  bool _azanTimeSwitched = true;
  int _flex_value = 2;
  PlaceModel _placeModel;
  String _searchHint = "Search cemeteries";
  String _currentLatitude = "23.7283019";
  String _currentLongitude = "90.3984344";
  String _location_name = "";
  String _miles = "";

  var _filterPlaceList;
  List<Places> _placeList;

  _MapListPageState(this.position);


  _loadData() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      if (preferences.containsKey('_azanTimeSwitched')) {
      _azanTimeSwitched = preferences.getBool('_azanTimeSwitched');
      }
      _currentLatitude = preferences.getString("latitude");
      _currentLongitude = preferences.getString("longitude");
      _prayer_name = preferences.getString("prayer_name");
      var parts = _prayer_name.split("^");
      _prayer_name = parts[0] + parts[1];

    });
  }

  _getPlacesApiCall({String cityName="", String miles = "300"}) async {
    String endApi = position ? "Cemetery" : "Funeral Home";
    _searchHint = position ? "Search cemeteries" : "Search funeral home";
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');
    var jsonData = null;
    final response = await http.get("http://ameenproject.org/appadmin/public/api/v1/places/type/${endApi}"
        "/${_currentLatitude}/${_currentLongitude}/${miles}${cityName}", headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    });

    if(response.statusCode == 200) {
      jsonData = json.decode(response.body);
      setState(() {
        _placeModel = new PlaceModel.fromJson(jsonData);
        _placeList = _placeModel.data.places;
        _filterPlaceList = _placeList;
      });
    }
    print("event request@@@@@@@ ${response.request.toString()}");
    print('Token : ${token}');
    print(jsonData.toString());
  }

  _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    20.0)), //this right here
            child: Container(
              height: 250,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 4.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Filter List',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        'You can filter list with city name and miles.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 40.0,
                        child: TextField(
                          onChanged: (value) {
                            _miles = value;
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xffEFEFEF),
                            contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                            hintText: '10 miles',
                            hintStyle:
                            TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(
                                    10.0),
                                borderSide: BorderSide.none),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            WhitelistingTextInputFormatter.digitsOnly
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 40.0,
                        child: TextField(
                          onChanged: (value) {
                            _location_name = value;
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xffEFEFEF),
                            contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                            hintText: 'New York',
                            hintStyle:
                            TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(
                                    10.0),
                                borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context,
                                  rootNavigator: true)
                                  .pop();
                            },
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if(_location_name.isNotEmpty || _miles.isNotEmpty)
                                _getPlacesApiCall(cityName: "/${_location_name}", miles: _miles);
                              Navigator.of(context,
                                  rootNavigator: true)
                                  .pop();
                            },
                            child: Text(
                              'Filter',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var places = List<Places>();
    Data data = Data(places: places);
    _placeModel = PlaceModel(success: true, message: "success", data: data);
    _placeList = _placeModel.data.places;
    _filterPlaceList = _placeList;
//    print("places from api: $_filterPlaceList");
    _loadData();
    _getPlacesApiCall();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(double.infinity, 50),
          child: getAppBar(context, getAppBarTitle(this.position), _prayer_name, _azanTimeSwitched)
      ),
      resizeToAvoidBottomPadding: false,
      body: Column(
        children: <Widget>[
//          Expanded(
//            flex: _flex_value,
//            child:  _azanTimeSwitched ? getAlarm(context, _prayer_name) : Container(),
//          ),
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.only(bottom: 10.0),
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 50.0,
                        child: TextField(
                          onChanged: (value) {
                            value = value.toLowerCase();
                            print(value);
                            setState(() {
                              print("places from api: ${_placeList[0].name}");
                              _filterPlaceList = _placeList
                                 .where((u) => (
//                              print("u.name: ${u.name}")));
                                  u.name
                                .toLowerCase()
                                .contains(value.toLowerCase())))
                                  .toList();
                            });
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xffEFEFEF),
                            hintText: _searchHint,
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(26.0),
                                borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: FlatButton(
                      child: new Image.asset('assets/setup.png'),
                      onPressed: () {
                        _displayDialog(context);
                      },
                    ),
                  ),
                ],
              ),
            ),

          ),
          Expanded(
            flex: 5,
            child: getListView(this._filterPlaceList),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        child: Icon(Icons.location_on,),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return MarkerPage(this._placeModel.data.places);
          }));
        },
      ),
    );
  }
}

String getAppBarTitle(bool position) {
  return position? 'Cemeteries' : 'Funeral Homes';
}

Widget getListView(List<Places> places) {

//  print("places from api: $places");

  var listView = ListView.builder(
      itemCount: places.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Container(
          color: index%2==1 ? Color(0xffF5F5F5) : Color(0xffEBEBEB),
          width: MediaQuery.of(context).size.width,
          //padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Text(
                            places.isNotEmpty ? places[index].name : "Place Name",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset('assets/maps.png',
                                height: 15,
                                width: 15,),
                            ),
                            Flexible(
                              child: Text(
                                places.isNotEmpty ? places[index].address : "Address",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset('assets/call.png',
                                height: 15,
                                width: 15,),
                            ),
                            InkWell(
                              child: Text(
                                places.isNotEmpty ? places[index].phone : "Phone",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 13,
                                ),
                              ),
                              onTap: () {
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset('assets/phone.png',
                                height: 15,
                                width: 15,),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  //\nDar Al-Hijrah\n\n12/08/2019, Monday at 12:00 AM
                  Expanded(
                    flex: 3,
                    child: Container(
                        width: 100.0,
                        height: 100.0,
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
                                places[index].image),
                          ),
                        )),
                  ),
                ]),
          ),
        );
      });
  return listView;
}
