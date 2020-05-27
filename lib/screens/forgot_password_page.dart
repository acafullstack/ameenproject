import 'dart:convert';

import 'package:ameen_project/home_page.dart';
import 'package:ameen_project/screens/login_page.dart';
import 'package:ameen_project/model/login_status.dart';
import 'package:ameen_project/screens/sign_up_request.dart';
import 'package:ameen_project/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/azan_timer_box.dart';

class ForgotPasswordPage extends StatefulWidget {
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {

  String email="";
  String _prayer_name = "";
  String _message = "";
  bool _azanTimeSwitched = true;


  _forgotPasswordApiCall(String email) async {
    Map data = {'email': email};
    var jsonData = null;
    var response = await http.post(
        "http://ameenproject.org/appadmin/public/api/v1/password_reset?email=${email}",
        body: data);
    if (response.statusCode == 200) {
      jsonData = json.decode(response.body);
      _message = "Password reset successful.";
      return;
    }
    print(response.body.toString());
    _message = "Try again later.";
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(double.infinity, 50),
          child: getAppBar(context, "Forgot Password", _prayer_name, _azanTimeSwitched)
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
                      'Please provide\nyour email',
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
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10.0),
                  child: Container(
                    child: GestureDetector(
                      onTap: () {
                        if (email.isEmpty || !validateEmail(email)) {
                         // _forgotPasswordApiCall(email);
                          showMessageBar(buildContext, "Invalid email address.");

                        } else {
                          _forgotPasswordApiCall(email);
                          showMessageBar(buildContext, _message);
                        }
                      },
                      child: Material(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(25.0),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              'Submit',
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
                Container(
                  margin: EdgeInsets.only(top: 10.0, bottom: 20.0),
                  child: Text.rich(
                    TextSpan(
                      text: '',
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Log In',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                                  return LoginPage();
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
