import 'dart:convert';
import 'dart:core';
import 'dart:io';import 'dart:math';

import 'package:ameen_project/screens/event_page.dart';
import 'package:ameen_project/model/image_upload.dart';
import 'package:ameen_project/utils/snackbar.dart';
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
import 'dart:io';

import '../utils/azan_timer_box.dart';



class AddEventPage extends StatefulWidget {
  _AddEventPageState createState() => _AddEventPageState();
}


class _AddEventPageState extends State<AddEventPage> {

  bool _azanTimeSwitched = true;
  String _prayer_name = "";
  DateTime _date = DateTime.now();

  TimeOfDay _time = TimeOfDay.now();

  String todayDate = DateFormat.yMMMMd("en_US").format(DateTime.now());
  String todayTime = '11:10 PM';

  String location_name = 'Please write the address here.';
  String event_name = "";
  String _fileName = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
  }

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

  void _chooseImage() async {
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    print('file.path: '+file.path);
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


  Future<Null> selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2019),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _date) {
      setState(() {
        //_date = picked;
        //DateFormat('MM/dd/yyyy').format(picked);
        todayDate = DateFormat.yMMMMd("en_US").format(picked);
       // print('648364837264786 3442^*&^%%&^%&^ ' + todayDate);
      });
    }
  }

  Future<Null> selectTime(BuildContext context) async {
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

  _addEvent(String eventName, String location, String date, String time) async {
    var selectedDate = DateFormat.yMMMMd("en_US").parse(date);
    date = DateFormat('MM/dd/yyyy').format(selectedDate);
    Map data = {
      'name': eventName,
      'image': _fileName,
      'location': location,
      'event_date': date,
      'event_time': time,
    };
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');
    var jsonData = null;
    final response = await http.post(
        "http://ameenproject.org/appadmin/public/api/v1/events/create",
        body: data,
        headers: {'Authorization': 'Bearer $token'});

    print(response.body.toString());
    if (response.statusCode == 200) {
      jsonData = json.decode(response.body);
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
          child: getAppBar(context, "New Event", _prayer_name, _azanTimeSwitched)
      ),
      resizeToAvoidBottomPadding: false,
      body: Builder(
        builder: (BuildContext buildContext) {
          return Container(
            color: Colors.white,
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.topLeft,
            padding: EdgeInsets.all(10.0),
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Add Event',
                        style: TextStyle(
                          color: Colors.lightBlue,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'You can post 2 events at a time.',
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
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Event Name\n',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      TextField(
                        onChanged: (value) {
                          event_name = value;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Please write event name here',
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
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Location\n',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      TextField(
                        onTap: () async {
                          Prediction p = await PlacesAutocomplete.show(
                              context: context,
                              apiKey: "AIzaSyAmbl1YzfcisrzY4_mXePtFuo5KAro8G50",
                              language: "en",
                              components: [new Component(Component.country, "us")]);
                          var addresses = await Geocoder.local
                              .findAddressesFromQuery(p.description);
                          print('place 44444' +
                              p.description +
                              ' ' +
                              addresses.first.coordinates.toString());
                          setState(() {
                            location_name = p.description;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: location_name,
                          prefixIcon: Image.asset(
                            'assets/map.png',
                            height: 25,
                            width: 25,
                          ),
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
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Event Date\n',
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
                            selectDate(context);
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
                  padding: EdgeInsets.all(10.0),
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
                            selectTime(context);
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
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 5.0),
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
                      flex: 7,
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        // '(png, jpg)',
                        '',
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
                      padding: const EdgeInsets.symmetric(horizontal:8.0),
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
                      padding: const EdgeInsets.symmetric(horizontal:8.0),
                      child: GradientButton(
                        child: Text('Add Event'),
                        callback: () {
                          if(event_name.isEmpty || location_name.isEmpty || todayTime.isEmpty ||
                          todayTime.isEmpty) {
                            showMessageBar(buildContext, "Fields can not be empty.");
                          } else {
                            _addEvent(
                                event_name, location_name, todayDate, todayTime);
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
}


