import 'dart:convert';

import 'package:ameen_project/model/directory_modal.dart';
import 'package:ameen_project/screens/add_business_directory.dart';
import 'package:ameen_project/screens/each_event_page.dart';
import 'package:ameen_project/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:ameen_project/utils/azan_timer_box.dart';
import 'package:ameen_project/screens/map_marker_page.dart';
import 'package:flutter/services.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:http/http.dart' as http;

class DirectoryListPage extends StatefulWidget {
  //bool position;
  //DirectoryListPage();
  _DirectoryListPageState createState() => _DirectoryListPageState();
}

class _DirectoryListPageState extends State<DirectoryListPage> {


  String _prayer_name = "Fajar";
  bool _loggedIn = false;
  bool _azanTimeSwitched = true;

  BusinessDirectory _businessDirectory;

  var _filterDirectoryList;
  List<Events> _directoryList;


  String _currentLatitude = "23.7283019";
  String _currentLongitude = "90.3984344";
  String _location_name = "";
  String _miles = "";


  _loadData() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var token = preferences.getString('token');
    setState(() {
      if (preferences.containsKey('_azanTimeSwitched')) {
      _azanTimeSwitched = preferences.getBool('_azanTimeSwitched');
      }
      _prayer_name = preferences.getString("prayer_name");
      var parts = _prayer_name.split("^");
      _prayer_name = parts[0] + parts[1];
      _currentLatitude = preferences.getString("latitude");
      _currentLongitude = preferences.getString("longitude");
      if (token != null) _loggedIn = token.isEmpty ? false : true;
    });
    print('Pray ' + _prayer_name);
  }

  //http://ameenproject.org/appadmin/public/api/v1/business_directory/23.741575/90.3844341/300

  _directoryListApiCall({String cityName="", String miles = "300"}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');
    var jsonData = null;
    final response = await http.get("http://ameenproject.org/appadmin/public/api/v1/business_directory"
        "/${_currentLatitude}/${_currentLongitude}/${miles}${cityName}", headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    });

    if(response.statusCode == 200) {
      jsonData = json.decode(response.body);
      setState(() {
        _businessDirectory = new BusinessDirectory.fromJson(jsonData);
        _directoryList = _businessDirectory.data.events;
        _filterDirectoryList = _directoryList;
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
                      'Filter Directory',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        'You can filter business directory with city name and miles.',
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
                                _directoryListApiCall(cityName: "/${_location_name}", miles: _miles);
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
    var directory= List<Events>();
    Data data = Data(events: directory);
    _businessDirectory = BusinessDirectory(success: true, message: "success", data: data);
    _directoryList = _businessDirectory.data.events;
    _filterDirectoryList = _directoryList;
    _loadData();
    _directoryListApiCall();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(double.infinity, 50),
          child: getAppBar(context, "Business Directory", _prayer_name, _azanTimeSwitched)
      ),
      resizeToAvoidBottomPadding: false,
      body: Builder(
        builder: (BuildContext buildContext) {
          return Column(
            children: <Widget>[
//          Expanded(
//            flex: _flex_value,
//            child:  (_azanTimeSwitched == null) ? getAlarm(context, _prayer_name) : Container(),
//          ),
              Expanded(
                flex: 2,
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
                                  _filterDirectoryList = _directoryList
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
                                hintText: 'Search directory',
                                contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
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
                      Expanded(
                        flex: 1,
                        child: FlatButton(
                          child: Icon(
                            Icons.add,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            if (_loggedIn) {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                    return AddBusinessDirectoryPage();
                                  }));
                            } else {
                              showMessageBar(buildContext, "Please login.");
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

              ),
              Expanded(
                flex: 9,
                child: getListView(_filterDirectoryList),
              ),
            ],
          );
        },
      )

    );
  }
}



Widget getListView(List<Events> directoryList) {

  var listView = ListView.builder(
      itemCount: directoryList.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Container(
          color: index%2==1 ? Color(0xffF5F5F5) : Color(0xffEBEBEB),
          width: MediaQuery.of(context).size.width,
          //padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    flex: 7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            directoryList[index].name,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.0),
                              child: Image.asset('assets/maps.png',
                                height: 15,
                                width: 15,),
                            ),
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  directoryList[index].address,
                                  style: TextStyle(
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    color: Colors.black87,
                                    fontSize: 13,

                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.0),
                              child: Image.asset('assets/call.png',
                                height: 15,
                                width: 15,),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: InkWell(
                                child: Text(
                                  directoryList[index].phone,
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 13,
                                  ),
                                ),
                                onTap: () {
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                              child: Image.asset('assets/phone.png',
                                height: 15,
                                width: 15,),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.0),
                              child: Image.asset('assets/arrow.png',
                                height: 15,
                                width: 15,),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                directoryList[index].website,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 13,
                                ),
                              ),
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
                                directoryList[index].image),
                          ),
                        )),
                  ),
                ]),
          ),
        );
      });
  return listView;
}
