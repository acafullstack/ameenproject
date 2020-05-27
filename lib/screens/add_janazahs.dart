import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:ameen_project/model/image_upload.dart';
import 'package:ameen_project/model/janazah_model.dart';
import 'package:ameen_project/model/place_model.dart';
import 'package:ameen_project/screens/janazah_page.dart';
import 'package:ameen_project/utils/snackbar.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:async/async.dart';

import '../utils/azan_timer_box.dart';

class AddJanazahPage extends StatefulWidget {
  _AddJanazahPageState createState() => _AddJanazahPageState();
}

class _AddJanazahPageState extends State<AddJanazahPage> {

  List<Places> _placesList = <Places> [
     Places(id: 1, name: "a", address: "b", city: "c", state: "d",
         zip: "e", country: "f", phone: "g", website: "h", contactPerson: "i",  contactPhone: "j",
         image: "k",
         description: "l",)
  ];

  List<Places> _cemeteryList = <Places> [
    Places(id: 1, name: "a", address: "b", city: "c", state: "d",
      zip: "e", country: "f", phone: "g", website: "h", contactPerson: "i",  contactPhone: "j",
      image: "k",
      description: "l",)
  ];

  var genderList = ['Male', 'Female'];

  bool _loading = false;
  Places selectedUser, selectedCemetery;
  String selectedGender;

  List<Places> data = List();


  DateTime _date = DateTime.now();

  TimeOfDay _time = TimeOfDay.now();

  String todayDate = DateFormat.yMMMMd("en_US").format(DateTime.now());
  String todayTime = '11:10 PM';
  String _prayer_name = "";
  bool _azanTimeSwitched = true;


  String location_name = 'Please write the address here.';
  String _deceased_name = "";
  String _cemetery_id = "";
  String _heritage = "";
  String _mosque_id = "";
  String _age = "";
  String _gender = "Male";
  String janazah_after = "";

  String _fileName = "";
  String _currentLatitude = "23.7283019";
  String _currentLongitude = "90.3984344";

  AutoCompleteTextField searchMosqueField;
  GlobalKey<AutoCompleteTextFieldState<Places>> key = new GlobalKey();
  TextEditingController _controller = new TextEditingController();

  void _chooseImage() async {
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: file.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
      iosUiSettings: IOSUiSettings(
        minimumAspectRatio: 1.0,
      )
    );
    _upload(croppedFile);
  }

  void _upload(File imageFile) async {
    if (imageFile == null) return;
    var stream = new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();

    var uri = Uri.parse("http://ameenproject.org/appadmin/public/api/v1/file_upload/image");

    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile('file_name', stream, length,
        filename: basename(imageFile.path));
    //contentType: new MediaType('image', 'png'));

    request.files.add(multipartFile);
    var response = await request.send();
    print(response.statusCode);
    if (response.statusCode == 200) {
      response.stream.transform(utf8.decoder).listen((value) {
        print(value);
        var jsonData = json.decode(value);
        ImageUpload imageUpload = new ImageUpload.fromJson(jsonData);
        setState(() {
          if(imageUpload != null)
            _fileName = imageUpload.data.image;
        });
      });
    }

  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2019),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _date) {
      setState(() {
        //_date = picked;
        todayDate = DateFormat.yMMMMd("en_US").format(picked);
      });
    }
  }

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked =
        await showTimePicker(context: context, initialTime: _time);
    if (picked != null && picked != _time) {
      setState(() {
        _time = picked;
        if (_time.hour > 12)
          todayTime = _time.hourOfPeriod.toString() +
              ':' +
              _time.minute.toString() +
              ' PM';
        else if (_time.hour == 0)
          todayTime = '12' + ':' + _time.minute.toString() + ' AM';
        else if (_time.hour == 12)
          todayTime = '12' + ':' + _time.minute.toString() + ' PM';
        else
          todayTime = _time.hourOfPeriod.toString() +
              ':' +
              _time.minute.toString() +
              ' AM';
        // print('648364837264786 3442^*&^%%&^%&^ ' + _time.hour.toString()+ '  ' +todayTime);
      });
    }
  }

  //Cemetery
  _getSearchSuggestions() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');
    var jsonData = null;
    var jsonCemetery = null;
    //http://ameenproject.org/appadmin/public/api/v1/janazahs/status/past
    final response = await http.get(
        "http://ameenproject.org/appadmin/public/api/v1/places/type/Mosque"
            "/${_currentLatitude}/${_currentLongitude}/3000",
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        });

    //http://ameenproject.org/appadmin/public/api/v1/janazahs/status/past
    final responseCemetery = await http.get(
        "http://ameenproject.org/appadmin/public/api/v1/places/type/Cemetery"
            "/${_currentLatitude}/${_currentLongitude}/3000",
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        });

    if (response.statusCode == 200) {
      jsonData = json.decode(response.body);
      setState(() {
        _loading = false;
        PlaceModel placeModel = new PlaceModel.fromJson(jsonData);
        _placesList = placeModel.data.places;
        print('Token Place : ${_placesList.length} ');

      });
    }

    if (responseCemetery.statusCode == 200) {
      jsonCemetery = json.decode(responseCemetery.body);
      setState(() {
        _loading = false;
        PlaceModel placeModel = new PlaceModel.fromJson(jsonCemetery);
        _cemeteryList = placeModel.data.places;
        print('Token Place : ${_cemeteryList.length} ');

      });
    }

    print('Token : ${token}');
    print(_cemeteryList.toString());
  }


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


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
    _getSearchSuggestions();
  }

  _addJanazah(String eventName, String heritage, String date, String time,
      String mosque_id, String cemetery_id, String age, String gender, String janazah_after) async {

    var selectedDate = DateFormat.yMMMMd("en_US").parse(date);
    date = DateFormat('MM/dd/yyyy').format(selectedDate);

    Map data = {
      'name_of_deceased': eventName,
      'image': _fileName,
      'heritage': heritage,
      'janazah_date': date,
      'janazah_time': time,
      'event_time': time,
      'mosque_id': "3",
      'cemetery_id': "4",
      'age': age,
      'gender': gender,
      'janazah_after': janazah_after

    };
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');
    var jsonData = null;
    final response = await http.post(
        "http://ameenproject.org/appadmin/public/api/v1/janazahs/create",
        body: data,
        headers: {'Authorization': 'Bearer $token'});

    print(response.body.toString());
    if (response.statusCode == 200) {
      jsonData = json.decode(response.body);
      print('Name: ${response.body.toString()}');
    }
    print('Token : ${token}');
    print(jsonData.toString());
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(double.infinity, 50),
          child: getAppBar(context, "Janazah", _prayer_name, _azanTimeSwitched)
      ),
      resizeToAvoidBottomPadding: true,
      body: Builder(
        builder: (BuildContext buildCOntext) {
          return Container(
            color: Colors.white,
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.topLeft,
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Add Janazah',
                        style: TextStyle(
                          color: Colors.lightBlue,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          'You can post 2 janazah at a time.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Deceased Name\n',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      TextField(
                        onChanged: (value) {
                          _deceased_name = value;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Please write deceased name here',
                          hintStyle: TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 1.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Heritage\n',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      TextField(
                        onChanged: (value) {
                          _heritage = value;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Please write heritage here.",
                          hintStyle: TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 1.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Janazah Date\n',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            _selectDate(context);
                          },
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.0),
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Row(
                                children: <Widget>[
                                  Image.asset(
                                    'assets/calendar.png',
                                    height: 25,
                                    width: 25,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      '$todayDate',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Time\n',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            _selectTime(context);
                          },
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.0),
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Row(
                                children: <Widget>[
                                  Image.asset(
                                    'assets/clock.png',
                                    height: 25,
                                    width: 25,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Text(
                                      '$todayTime',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Janazah Time\n',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      TextField(
                        onChanged: (value) {
                          janazah_after = value;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Please write when the janazah will start.',
                          hintStyle: TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 1.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 10),
                  child: DropdownButton<Places>(
                    hint:  Text("Select Mosque"),
                    value: selectedUser,
                    onChanged: (Places Value) {
                      setState(() {
                        selectedUser = Value;
                      });
                    },
                    items: _placesList.map((Places user) {
                      return  DropdownMenuItem<Places>(
                        value: user,
                        child: Row(
                          children: <Widget>[
                            SizedBox(width: 10,),
                            Text(
                              user.name??'Mosque',
                              style:  TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 10),
                  child: DropdownButton<Places>(
                    hint:  Text("Select Cemetery"),
                    value: selectedCemetery,
                    onChanged: (Places Value) {
                      setState(() {
                        selectedCemetery = Value;
                      });
                    },
                    items: _cemeteryList.map((Places user) {
                      return  DropdownMenuItem<Places>(
                        value: user,
                        child: Row(
                          children: <Widget>[
                            SizedBox(width: 10,),
                            Text(
                              user.name??'Cemetery',
                              style:  TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Age\n',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      TextField(
                        onChanged: (value) {
                          _age = value;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Please write the age here',
                          hintStyle: TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 1.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 10),
                  child: DropdownButton<String>(
                    hint:  Text("Select Gender"),
                    value: selectedGender,
                    onChanged: (String Value) {
                      setState(() {
                        selectedGender = Value;
                      });
                    },
                    items: genderList.map((String user) {
                      return  DropdownMenuItem<String>(
                        value: user,
                        child: Row(
                          children: <Widget>[
                            SizedBox(width: 10,),
                            Text(
                              user,
                              style:  TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal:20.0, vertical: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              _chooseImage();
                            },
                            child: Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25.0),
                              child: Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Row(
                                  children: <Widget>[
                                    Image.asset(
                                      'assets/paper.png',
                                      height: 25,
                                      width: 25,
                                    ),
                                    Text(
                                      'Upload Masjid Logo',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      flex: 8,
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        '',
                        // '(png, jpg)',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 10),
                      child: GradientButton(
                        child: Text('Cancel'),
                        callback: () {
                          Navigator.of(context).pop();
                        },
                        gradient: Gradients.backToFuture,
                        shadowColor: Gradients.backToFuture.colors.last.withOpacity(0.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal:4.0),
                      child: GradientButton(
                        child: Text(' Add Janazah '),
                        callback: () {
                          if (_deceased_name.isEmpty || _heritage.isEmpty || todayTime.isEmpty ||
                          _age.isEmpty || _gender.isEmpty) {
                            showMessageBar(buildCOntext, "Fileds can not be empty.");
                          } else {
                            _addJanazah(_deceased_name, _heritage, todayDate,
                                todayTime, selectedUser.id.toString(), selectedCemetery.id.toString()
                                , _age, _gender, janazah_after);
                            Navigator.of(context,
                                rootNavigator: true)
                                .pop();
                          }

                        },
                        gradient: Gradients.rainbowBlue,
                        shadowColor: Gradients.rainbowBlue.colors.last.withOpacity(0.0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      )

    );
  }

  Widget row(Places item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          item.name,
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
        SizedBox(
          width: 10.0,
        ),
        Text(
          item.name,
          style: TextStyle(
            fontSize: 16.0,
          ),
        )
      ],
    );
  }
}
