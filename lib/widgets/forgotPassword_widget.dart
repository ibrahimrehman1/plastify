import "package:flutter/material.dart";
import "package:flutter_icons/flutter_icons.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:http/http.dart" as http;
import "dart:convert";
import "package:fluttertoast/fluttertoast.dart";

class ForgotPasswordWidget extends StatefulWidget {
  const ForgotPasswordWidget({Key? key}) : super(key: key);

  @override
  _ForgotPasswordWidgetState createState() => _ForgotPasswordWidgetState();
}

class _ForgotPasswordWidgetState extends State<ForgotPasswordWidget> {
  String emailAddress = "";
  String password = "";

  void updatePassword() async {
    final SharedPreferences preference = await SharedPreferences.getInstance();
    var changePasswordURI = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:update?key=AIzaSyDpgSXCIPigSzmvciQnauTbvLfQVOjrH94");

    var result4 = await http.post(changePasswordURI,
        body: json.encode({
          "idToken": preference.getString("idToken").toString(),
          "password": password,
          "returnSecureToken": false
        }));

    print(json.decode(result4.body));

    Fluttertoast.showToast(
        msg: "Password has been Updated!!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Set New Password",
          ),
          backgroundColor: Color.fromRGBO(0, 200, 0, 1),
        ),
        body: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.0),
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
                Container(margin: EdgeInsets.only(top: 20.0)),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Current Email Address",
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
                  decoration: InputDecoration(
                    labelText: "New Password",
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
                        child: Text("Update Password"),
                        onPressed: () => updatePassword(),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.lightGreen.shade800),
                            fixedSize: MaterialStateProperty.all(
                                Size.fromWidth(320))))),
              ],
            ))));
  }
}
