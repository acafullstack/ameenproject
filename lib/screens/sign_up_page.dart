import 'dart:convert';
import 'dart:io';

import 'package:ameen_project/home_page.dart';
import 'package:ameen_project/screens/login_page.dart';
import 'package:ameen_project/model/image_upload.dart';
import 'package:ameen_project/model/login_status.dart';
import 'package:ameen_project/model/signup_response.dart';
import 'package:ameen_project/screens/sign_up_request.dart';
import 'package:ameen_project/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import '../utils/azan_timer_box.dart';

class SignUpPage extends StatefulWidget {

  bool _selectOption = true;
  SignUpPage(this._selectOption);

  _SignUpPageState createState() => _SignUpPageState(_selectOption);

}

class _SignUpPageState extends State<SignUpPage> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = false;
  String name = "";
  String email = "";
  String password = "";
  bool _selectOption = true;
  String _prayer_name = "";

  String role = "Mosque";

  String location_name = "Please write the address here.";

  String _fileName = "";
  bool _azanTimeSwitched = true;

  _SignUpPageState(this._selectOption);



  _signUpRequest(String name, String email, String password) async {

    role = _selectOption ? role : "Funeral Home";

    Map data = {
      'name' : name,
      'email': email,
      'password': password,
      'role': role,
      'address': location_name,
      "image": _fileName
    };
    var jsonData = null;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var response = await http.post("http://ameenproject.org/appadmin/public/api/v1/register", body: data);
    print(response.body.toString());
    if(response.statusCode == 200) {
      jsonData = json.decode(response.body);
      print('Name: ${jsonData.toString()}');
      SignUpResponse signUpResponse = new SignUpResponse.fromJson(jsonData);
      setState(() {
        sharedPreferences.setString("token", signUpResponse.data.user.access_token);
        sharedPreferences.setString("email", signUpResponse.data.user.email);
        sharedPreferences.setString("name", signUpResponse.data.user.name);
        sharedPreferences.setString("profilePic", signUpResponse.data.user.profilePicture);
        sharedPreferences.setBool("status", true);
        _saveUserToken();

      });
      if(signUpResponse.success){
        Navigator.of(this.context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
            HomePage()), (Route<dynamic> route) => false);
      }

    } else{
      final snackBar = SnackBar(content: Text('Error, try again later.'));
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }

  }

  _saveUserToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String fcm_token = sharedPreferences.getString("fcm_token");
    var token = sharedPreferences.getString('token');

    Map data = {
      'firebase_token': fcm_token,
      'Edit_Id': "4"
    };

    var jsonData = null;
    final response = await http.post(
        "http://ameenproject.org/appadmin/public/api/v1/profile/update_token",
        body: data,
        headers: {'Authorization': 'Bearer $token'});

      print(response.body.toString());
      if (response.statusCode == 200) {
        jsonData = json.decode(response.body);
      }
      print('Token : ${token}');
      print(jsonData.toString());

  }


  void _chooseImage() async {
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    _upload(file);
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


  _validateEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }

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


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
          preferredSize: Size(double.infinity, 50),
          child: getAppBar(context, "Sign Up", _prayer_name, _azanTimeSwitched)
      ),
      resizeToAvoidBottomPadding: false,
      body: Builder(
        builder: (BuildContext buildContext) {
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                  child: Text(
                    'Register yourself',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                  child: TextField(
                    onChanged: (value) {
                      name = value;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black12,
                      hintText: 'Name',
                      hintStyle: TextStyle(color: Colors.black54),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                  child: TextField(
                    onChanged: (value) {
                      email = value;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black12,
                      hintText: 'Email Address',
                      hintStyle: TextStyle(color: Colors.black54),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                  child: TextField(
                    onChanged: (value) {
                      password = value;
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black12,
                      hintText: 'Password',
                      hintStyle: TextStyle(color: Colors.black54),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextField(
                        onTap: () async {
                          Prediction p = await PlacesAutocomplete.show(
                              context: context,
                              apiKey: "AIzaSyAmbl1YzfcisrzY4_mXePtFuo5KAro8G50",
                              language: "en",
                              components: [new Component(Component.country, "bd")]);
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
                          fillColor: Colors.black12,
                          hintText: location_name,
                          hintStyle: TextStyle(color: Colors.black54),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12),
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
                        EdgeInsets.symmetric(horizontal: 20, vertical: 5.0),
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
                                      'Upload Image',
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
                      flex: 5,
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        '(png, jpg)',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10.0),
                  child: Container(
                    child: GestureDetector(
                      onTap: () {
                        if (name.isEmpty) {
                          showMessageBar(buildContext, "Name required.");
                        } else if (email.isEmpty || !_validateEmail(email)) {
                          showMessageBar(buildContext, "Invalid Emaiil address.");
                        }
                        else if (password.isEmpty) {
                          showMessageBar(buildContext, "Password required.");
                        }
                        else if(location_name.isEmpty) {
                          showMessageBar(buildContext, "Location required.");
                        } else {
                          _signUpRequest(name, email, password);
                        }
                      },
                      child: Material(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(25.0),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                _isLoading ? Center( child: CircularProgressIndicator()) : Container(),
              ],
            ),
          );
        },

      ),
    );
  }
}
