import 'dart:convert';

import 'package:ameen_project/home_page.dart';
import 'package:ameen_project/model/login_status.dart';
import 'package:ameen_project/screens/forgot_password_page.dart';
import 'package:ameen_project/screens/sign_up_request.dart';
import 'package:ameen_project/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/azan_timer_box.dart';

class LoginPage extends StatefulWidget {
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;
  String email, password;
  String _prayer_name = "";
  bool _azanTimeSwitched = true;

  _signIn(String email, String password) async {
    Map data = {'email': email, 'password': password};
    var jsonData = null;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var response = await http.post(
        "http://ameenproject.org/appadmin/public/api/v1/login",
        body: data);
    if (response.statusCode == 200) {
      jsonData = json.decode(response.body);
      LoginStatus loginStatus = new LoginStatus.fromJson(jsonData);
      if (!mounted) return;
      setState(() {
        if(loginStatus.data.length > 0) {
          sharedPreferences.setInt("id", loginStatus.data[0].id);
          sharedPreferences.setString("token", loginStatus.data[0].accessToken);
          sharedPreferences.setString("email", loginStatus.data[0].email);
          sharedPreferences.setString("name", loginStatus.data[0].name);
          sharedPreferences.setString("profilePic", loginStatus.data[0].profilePicture);
          sharedPreferences.setString("isJanzahEnabled", loginStatus.data[0].isJanzahEnabled);
          sharedPreferences.setBool("status", true);
          _saveUserToken(loginStatus.data[0].accessToken);
        }
      });
      print('UserINfo: ${response.body.toString()}');
      print('Name: ${loginStatus.data[0].accessToken}');

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomePage()),
          (Route<dynamic> route) => false);
    } else {
      print('1111 ${response.body}');
    }
    print('1111 ${response.body}');
  }

  _saveUserToken(String token) async {

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String fcm_token = sharedPreferences.getString("fcm_token");

    Map data = {
      'firebase_token': fcm_token,
      'Edit_Id': "3"
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
    print('FCM TOKEN  : ${response.body.toString()}');
    print('Token : ${token}');
    print(jsonData.toString());

  }

  validateEmail(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
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
      appBar: PreferredSize(
          preferredSize: Size(double.infinity, 50),
          child: getAppBar(context, "Log In", _prayer_name, _azanTimeSwitched)
      ),
      resizeToAvoidBottomPadding: false,
      body: Builder(
        builder: (BuildContext buildContext) {
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                    child: Text(
                      'Log In to\nyour account',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
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
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
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
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10.0),
                  child: Container(
                    child: GestureDetector(
                      onTap: () {
                        if (email != null &&
                            password != null &&
                            validateEmail(email)) {
                          _signIn(email, password);
                        } else {
                          showMessageBar(buildContext, "Invalid credentials.");
                        }
                      },
                      child: Material(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(25.0),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              'LOG IN',
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
                GestureDetector(
                  onTap: (){
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                          return ForgotPasswordPage();
                        }));
                  },
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.lightBlue,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10.0, bottom: 20.0),
                  child: Text.rich(
                    TextSpan(
                      text: '',
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Sign Up Request',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return SignUpRequestPage();
                                })),
                        ),
                        // can add more TextSpans here...
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Image.asset(
                    'assets/login_bg.png',
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
