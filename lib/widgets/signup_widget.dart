import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import "dart:core";
import "package:flutter_icons/flutter_icons.dart";
import "package:fluttertoast/fluttertoast.dart";
import "./login_widget.dart";
import "package:shared_preferences/shared_preferences.dart";
import "./dashboard_widget.dart";
import "../main.dart";
import "./user_http.dart";
import "./otp_widget.dart";

var currentEmail;

class SignupWidget extends StatefulWidget {
  @override
  _SignupWidgetState createState() => _SignupWidgetState();
}

class _SignupWidgetState extends State<SignupWidget> {
  String firstName = "";

  String lastName = "";

  String mobileNo = "";

  String emailAddress = "";

  String password = "";

  int r = 255;
  int g = 0;
  int b = 0;

  String confirmPassword = "";
  num points = 0;
  String enteredOtp = "";
  bool otpStatus = false;

  void initState() {
    getEmail().whenComplete(() async => {print("")});
  }

  Future getEmail() async {
    final SharedPreferences preference = await SharedPreferences.getInstance();
    await preference.remove('email');
    var obtainedEmail = preference.getString("email");
    setState(() {
      currentEmail = obtainedEmail;
    });
    currentEmail != null
        ? navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) {
            return (DashboardWidget());
          }))
        : print("");
  }

  void showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void sendOTP() async {
    if (password == confirmPassword) {
      if (mobileNo.length != 0) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) {
          return otpWidget(
              emailAddress: emailAddress,
              password: password,
              firstName: firstName,
              lastName: lastName,
              mobileNo: mobileNo,
              points: points);
        }));

        var body = UserHTTP.sendOtp(mobileNo);
        print(body);
      } else {
        showToast("Please Enter Your Mobile Number!");
      }
    } else {
      showToast("Password does not match!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Signup",
          ),
          backgroundColor: Color.fromRGBO(0, 200, 0, 1),
        ),
        body: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
                child: Column(children: [
              Container(margin: const EdgeInsets.only(top: 20.0)),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "First Name",
                  prefixIcon: Icon(FlutterIcons.person_outline_mdi,
                      color: Color.fromRGBO(0, 200, 0, 1)),
                ),
                onChanged: (v) {
                  firstName = v;
                },
                maxLength: 20,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Last Name",
                  prefixIcon: Icon(FlutterIcons.person_outline_mdi,
                      color: Color.fromRGBO(0, 200, 0, 1)),
                ),
                onChanged: (v) {
                  lastName = v;
                },
                maxLength: 20,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Email Address",
                  prefixIcon: Icon(FlutterIcons.email_check_outline_mco,
                      color: Color.fromRGBO(0, 200, 0, 1)),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (v) {
                  emailAddress = v;
                },
                maxLength: 50,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Mobile Number (0321...)",
                  prefixIcon: Icon(FlutterIcons.device_mobile_oct,
                      color: Color.fromRGBO(0, 200, 0, 1)),
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  mobileNo = v;
                },
                maxLength: 11,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(FlutterIcons.lock_outline_mdi,
                      color: Color.fromRGBO(0, 200, 0, 1)),
                ),
                obscureText: true,
                onChanged: (v) {
                  password = v;
                },
                maxLength: 30,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  prefixIcon: Icon(FlutterIcons.lock_outline_mdi,
                      color: Color.fromRGBO(r, g, b, 1)),
                ),
                obscureText: true,
                onChanged: (v) {
                  confirmPassword = v;
                  if (confirmPassword == password) {
                    setState(() {
                      r = 0;
                      g = 200;
                    });
                  } else {
                    setState(() {
                      r = 255;
                      g = 0;
                    });
                  }
                },
                maxLength: 30,
              ),
              Container(
                  margin: EdgeInsets.only(top: 30.0),
                  child: ElevatedButton(
                      child: Text("Signup"),
                      onPressed: () => sendOTP(),
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.lightGreen.shade800),
                          fixedSize:
                              MaterialStateProperty.all(Size.fromWidth(320))))),
              Container(
                  padding: EdgeInsets.only(top: 10.0, bottom: 20.0),
                  child: Material(
                      child: InkWell(
                    child: Text(
                      "Already have an Account? Log In",
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) {
                      return LoginWidget();
                    })),
                    hoverColor: Color.fromRGBO(0, 255, 0, 1),
                  )))
            ]))));
  }
}
