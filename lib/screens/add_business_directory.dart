import 'dart:convert';
import 'dart:core';
import 'dart:io';import 'dart:math';

import 'package:ameen_project/screens/event_page.dart';
import 'package:ameen_project/model/image_upload.dart';
import 'package:ameen_project/screens/directory_list.dart';
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




class AddBusinessDirectoryPage extends StatefulWidget {
  _AddBusinessDirectoryPageState createState() => _AddBusinessDirectoryPageState();
}


class _AddBusinessDirectoryPageState extends State<AddBusinessDirectoryPage> {


  String _prayer_name = "";
  bool _azanTimeSwitched = true;

  String location_name = 'Please write the address here.';
  String _companyName = "";
  String _fileName = "";
  String _phoneNumber = "";
  String _websiteLink = "";

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



  _addBusinessDirectory(String eventName, String location, String phone, String website) async {
    Map data = {
      'name': eventName,
      'image': _fileName,
      'address': location,
      'phone': phone,
      'website': website,
    };
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');
    var jsonData = null;
    final response = await http.post(
        "http://ameenproject.org/appadmin/public/api/v1/business_directory/create",
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
          child: getAppBar(context, "Business Directory", _prayer_name, _azanTimeSwitched)
      ),
      resizeToAvoidBottomPadding: true,
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
                        'Add Your business info',
                        style: TextStyle(
                          color: Colors.lightBlue,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
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
                        'Company Name\n',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      TextField(
                        onChanged: (value) {
                          _companyName = value;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Please provide your company name',
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
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Phone number\n',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      TextField(
                        onChanged: (value) {
                          _phoneNumber = value;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Please provide your phone number',
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
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Website link\n',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      TextField(
                        onChanged: (value) {
                          _websiteLink = value;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Please provide your website link',
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
                        child: Text('Add'),
                        callback: () {
                          if(_companyName.isEmpty || _phoneNumber.isEmpty || _websiteLink.isEmpty) {
                            showMessageBar(buildContext, "Fields can not be empty");
                          } else {
                        _addBusinessDirectory(
                            _companyName, location_name, _phoneNumber, _websiteLink);
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


