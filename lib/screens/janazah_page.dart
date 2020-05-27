import 'dart:convert';

import 'package:ameen_project/model/janazah_model.dart';
import 'package:ameen_project/screens/add_janazahs.dart';
import 'package:ameen_project/screens/each_janazah_page.dart';
import 'package:ameen_project/screens/how_to_pray.dart';
import 'package:ameen_project/utils/calculate_date_time.dart';
import 'package:ameen_project/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:ameen_project/utils/azan_timer_box.dart';
import 'package:ameen_project/screens/add_event_page.dart';
import 'package:ameen_project/screens/each_event_page.dart';
import 'package:flutter/services.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'place_list.dart';

class JanazahsPage extends StatefulWidget {
  _JanazahsPageState createState() => _JanazahsPageState();
}

class _JanazahsPageState extends State<JanazahsPage>
    with SingleTickerProviderStateMixin {


  TabController _tabController;
  String _prayer_name = "";
  bool _loggedIn = false;
  bool _azanTimeSwitched = true;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(vsync: this, length: 2, initialIndex: 0);
    _loadData();
  }



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
      if(token != null) _loggedIn = token.isEmpty ? false : true;
    });
    print('Pray ' + _prayer_name);
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(double.infinity, 50),
          child: Container(
            height: 100,
            decoration:  BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/mosque.jpg"), fit: BoxFit.cover),
            ),
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 20, 10, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.navigate_before,size: 40,color: Colors.white,),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      ),
                      Text("Janazahs",style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.bold),),
                    ],
                  ),
                  _azanTimeSwitched
                  ? Text(_prayer_name,style: TextStyle(fontSize: 13,color: Colors.white),)
                  : Container(),
                ],
              ),
            ),
          ),
        ),
        resizeToAvoidBottomPadding: false,
        body: Builder(
          builder: (BuildContext context) {
            return Column(
              children: <Widget>[
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/innahlillah_image.png"),
                        fit: BoxFit.fill),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TabBar(
                        controller: _tabController,
                        labelColor: Colors.lightBlue,
                        unselectedLabelColor: Colors.black38,
                        indicator: UnderlineTabIndicator(
                            borderSide:
                            BorderSide(width: 2.0, color: Colors.lightBlue),
                            insets: EdgeInsets.symmetric(horizontal: 30.0)),
                        tabs: <Widget>[
                          Tab(
                            text: 'Upcoming',
                          ),
                          Tab(
                            text: 'Past',
                          ),
                        ],
                      ),
                      flex: 3,
                    ),
                    Expanded(
                      flex: 2,
                      child: GradientButton(
                        child: Text('Add'),
                        callback: () {
                          if (_loggedIn) {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                                  return AddJanazahPage();
                                }));
                          } else {
                            showMessageBar(context, "Please login.");
                          }

                        },
                        gradient: Gradients.taitanum,
                        shadowColor:
                        Gradients.taitanum.colors.last.withOpacity(0.0),
                      ),
                    )
                  ],
                ),

                Expanded(
                  flex: 7,
                  //height: MediaQuery.of(context).size.height/1.5,
                  child: TabBarView(
                    controller: _tabController,
                    children: <Widget>[
                      TabPage("upcoming"),
                      TabPage("past"),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  //width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      color: Color(0xffFFFFFF),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: <Widget>[
                                CircularGradientButton(
                                  child: Image.asset(
                                    'assets/cemeteries.png',
                                    height: 25,
                                    width: 25,
                                  ),
                                  callback: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                                      return MapListPage(true);
                                    }));
                                  },
                                  gradient: Gradients.rainbowBlue,
                                  shadowColor: Gradients.rainbowBlue.colors.last
                                      .withOpacity(0.5),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text(
                                    'Cemeteries',
                                    style: TextStyle(
                                      fontSize: 11.0,
                                      color: Color(0xff939393),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: <Widget>[
                                CircularGradientButton(
                                  child: Image.asset(
                                    'assets/funeral_homes.png',
                                    height: 25,
                                    width: 25,
                                  ),
                                  callback: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                                      return MapListPage(false);
                                    }));
                                  },
                                  gradient: Gradients.rainbowBlue,
                                  shadowColor: Gradients.rainbowBlue.colors.last
                                      .withOpacity(0.5),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text(
                                    'Funeral Homes\nParticipants',
                                    style: TextStyle(
                                      fontSize: 11.0,
                                      color: Color(0xff939393),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: <Widget>[
                                CircularGradientButton(
                                  child: Image.asset(
                                    'assets/shafi.png',
                                    height: 25,
                                    width: 25,
                                  ),
                                  callback: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                                      return SliderPage(true);
                                    }));
                                  },
                                  gradient: Gradients.rainbowBlue,
                                  shadowColor: Gradients.rainbowBlue.colors.last
                                      .withOpacity(0.5),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text(
                                    'How to pray\n(Shafi)',
                                    style: TextStyle(
                                      fontSize: 11.0,
                                      color: Color(0xff939393),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: <Widget>[
                                CircularGradientButton(
                                  child: Image.asset(
                                    'assets/hanafi.png',
                                    height: 25,
                                    width: 25,
                                  ),
                                  callback: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                                      return SliderPage(false);
                                    }));
                                  },
                                  gradient: Gradients.rainbowBlue,
                                  shadowColor: Gradients.rainbowBlue.colors.last
                                      .withOpacity(0.5),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text(
                                    'How to pray\n(Hanafi)',
                                    style: TextStyle(
                                      fontSize: 11.0,
                                      color: Color(0xff939393),
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        )
    );
  }
}

class TabPage extends StatefulWidget {
  String _tabTitle = "";
  TabPage(this._tabTitle);

  _TabPageState createState() => _TabPageState(this._tabTitle);
}

class _TabPageState extends State<TabPage> {

  JanazahModel _janazahModel;
  String _tabTitle = "upcoming";
  List<Janazahs> janazahs = List<Janazahs>();
  List<Janazahs> _filterJanazahsList;
  String _currentLatitude = "23.7283019";
  String _currentLongitude = "90.3984344";
  String _location_name = "";
  String _miles = "";

  _TabPageState(this._tabTitle);

  _janazahApiCall({String cityName="", String miles = "300"}) async {
    var jsonData = null;
    //http://ameenproject.org/appadmin/public/api/v1/janazahs/status/past
    final response = await http.get("http://ameenproject.org/appadmin/public/api/v1/janazahs/status/${_tabTitle}/${_currentLatitude}/${_currentLongitude}/${miles}${cityName}", headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    });

    if(response.statusCode == 200) {
      jsonData = json.decode(response.body);
      if (!mounted) return;
      setState(() {
        _janazahModel = new JanazahModel.fromJson(jsonData);
        janazahs = _janazahModel.data.janazahs;
        _filterJanazahsList = janazahs;
      });
    }
    print('Token : ${response.request.toString()}');
    print(jsonData.toString());
  }

  _loadData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {      
      _currentLatitude = preferences.getString("latitude");
      _currentLongitude = preferences.getString("longitude");
    });
    print(_currentLatitude + " " + _currentLongitude);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //print("tite 1234 ${_tabTitle}");
    _filterJanazahsList = janazahs;
    _loadData();
//    var janazahs = List<Janazahs>();
//    Data data = Data(janazahs: janazahs);
//    _janazahModel = JanazahModel(success: true, message: "success", data: data);
    _janazahApiCall();
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
                      'Filter Janazahs',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        'You can filter janazahs with city name and miles.',
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
                                _janazahApiCall(cityName: "/${_location_name}", miles: _miles);
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
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 50.0,
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: TextField(
                        onChanged: (value) {
                          value = value.toLowerCase();
                          print(value);
                          setState(() {
                            _filterJanazahsList = janazahs
                                .where((u) => (
//                              print("u.name: ${u.name}")));
                                u.nameOfDeceased
                                    .toLowerCase()
                                    .contains(value.toLowerCase())))
                                .toList();
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xffEFEFEF),
                          hintText: 'Search janazahs',
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
              ],
            ),
          ),
          Expanded(
            flex: 7,
            child: ListView.builder(
              itemCount: _filterJanazahsList.length,
              shrinkWrap: true,
              //physics: ClampingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) => Container(
                width: MediaQuery.of(context).size.width,

                //padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return EachJanazahPage(this._filterJanazahsList[index]);
                    }));
                  },
                  child: Container(
                    color: index%2==1 ? Color(0xffF5F5F5) : Color(0xffEBEBEB),
                    width: MediaQuery.of(context).size.width,
                    //padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: <Widget>[
                                  GradientCard(
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Column(
                                        children: <Widget>[
                                          Text(
                                            _filterJanazahsList.isNotEmpty ?
                                      returnDate(_filterJanazahsList[index].janazahDate) : "01",
                                            style: TextStyle(
                                              fontSize: 24,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            _filterJanazahsList.isNotEmpty ?
                                            returnMonth(_filterJanazahsList[index].janazahDate) : "JAN",
                                            style: TextStyle(
                                              fontSize: 17,
                                              color: Colors.white,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    gradient: Gradients.backToFuture,
                                    shadowColor: Gradients.backToFuture.colors.last
                                        .withOpacity(0.5)
                                  ),
                                  Align(
                                    alignment: Alignment.topCenter,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                          _filterJanazahsList.isNotEmpty ?
                                              _filterJanazahsList[index].janazah_after : "After",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    _filterJanazahsList.isNotEmpty ? _filterJanazahsList[index].nameOfDeceased : "Deceased Name",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                    ),
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Image.asset('assets/maps.png',
                                          height: 15,
                                          width: 15,),
                                      ),
                                      Flexible(
                                        child: Text(
                                          _filterJanazahsList.isNotEmpty ? _filterJanazahsList[index].mosque : "Mosque",
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 13,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Image.asset('assets/watch.png',
                                          height: 15,
                                          width: 15,),
                                      ),
                                      Text(
                                        _filterJanazahsList.isNotEmpty ? _filterJanazahsList[index].janazahTime : "Time",
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Image.asset('assets/calenders.png',
                                          height: 15,
                                          width: 15,),
                                      ),
                                      Text(
                                        _filterJanazahsList.isNotEmpty ? _filterJanazahsList[index].janazahDate : "Date",
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
//                              Text(
//                                '22d:12h:48m:36s',
//                                style: TextStyle(
//                                  backgroundColor: Color(0xff4D86FE),
//                                  color: Colors.white,
//                                  fontSize: 8,
//                                  fontWeight: FontWeight.bold,
//                                ),
//                                textAlign: TextAlign.start,
//                              )
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
                                          _filterJanazahsList[index].image),
                                    ),
                                  )),
                            ),
                          ]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
