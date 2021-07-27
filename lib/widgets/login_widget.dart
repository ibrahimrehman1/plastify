import "package:flutter/material.dart";
import "package:flutter_icons/flutter_icons.dart";
import "./signup_widget.dart";
import "package:http/http.dart" as http;
import "dart:convert";
import "package:fluttertoast/fluttertoast.dart";
import "package:shared_preferences/shared_preferences.dart";
import "./dashboard_widget.dart";

import "./forgotPassword_widget.dart";

class LoginWidget extends StatefulWidget {
  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  String emailAddress = "";

  String password = "";
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void loginUser(ctx) async {
    final url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyDpgSXCIPigSzmvciQnauTbvLfQVOjrH94");

    emailAddress = emailController.text;
    password = passwordController.text;
    var result = await http.post(url,
        body: json.encode({
          "email": emailAddress,
          "password": password,
          "returnSecureToken": true
        }));

    Map body = json.decode(result.body);
    print(body);
    print(body.containsKey("error"));
    if (body.containsKey("error")) {
      Fluttertoast.showToast(
          msg: "Email/Password is Incorrect!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }

    final prefs = await SharedPreferences.getInstance();

    prefs.setString('email', body['email']);
    prefs.setString('idToken', body['idToken']);
    prefs.setString('dataId', body['localId']);

    Fluttertoast.showToast(
        msg: "Logged In Successfully!!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);

    if (body.containsKey("email")) {
      // if (body['email'].toString().contains("manager")) {
      //   Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
      //     return (ManagerDashboardWidget());
      //   }));
      // } else if (body['email'].toString().contains("admin")) {
      //   Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
      //     return (AdminDashboardWidget());
      //   }));
      // }

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => DashboardWidget()),
          (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Reverse Vending Machine",
          ),
          backgroundColor: Color.fromRGBO(0, 200, 0, 1),
        ),
        body: Container(
            width: double.infinity,
            padding: EdgeInsets.only(right: 15.0, left: 15.0, top: 0.0),
            child: SingleChildScrollView(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage('assets/images/petbottle_logo.png'),
                  width: 200,
                  height: 200,
                ),
                Container(margin: EdgeInsets.only(top: 10.0)),
                TextFormField(
                  controller: emailController,
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
                TextField(
                  controller: passwordController,
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
                Container(
                    margin: EdgeInsets.only(top: 30.0),
                    child: ElevatedButton(
                        child: Text("Login"),
                        onPressed: () => loginUser(context),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.lightGreen.shade800),
                            fixedSize: MaterialStateProperty.all(
                                Size.fromWidth(320))))),
                Container(
                    padding: EdgeInsets.only(top: 10.0, bottom: 20.0),
                    child: Material(
                        child: InkWell(
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                      onTap: () => Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) {
                        return ForgotPasswordWidget();
                      })),
                      hoverColor: Color.fromRGBO(0, 255, 0, 1),
                    ))),
                Container(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: Material(
                        child: InkWell(
                      child: Text(
                        "Don't have an Account? Sign Up",
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                      onTap: () => Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) {
                        return SignupWidget();
                      })),
                      hoverColor: Color.fromRGBO(0, 255, 0, 1),
                    ))),
                Text("Powered by NCAI",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Container(
                    margin: EdgeInsets.only(top: 10.0),
                    child: Align(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          Container(
                              padding: EdgeInsets.all(5.0),
                              child: Image(
                                image: AssetImage('assets/images/ned_logo.png'),
                                width: 70,
                                height: 70,
                              )),
                          Container(
                              padding: EdgeInsets.all(5.0),
                              child: Image(
                                image:
                                    AssetImage('assets/images/ncai_logo.png'),
                                width: 70,
                                height: 70,
                              )),
                          Container(
                              padding: EdgeInsets.all(5.0),
                              child: Image(
                                image: AssetImage(
                                    'assets/images/smartCityLab_logo.png'),
                                width: 70,
                                height: 70,
                              )),
                        ])))
              ],
            ))));
  }
}
