import "package:flutter/material.dart";
import "package:flutter_icons/flutter_icons.dart";
import "package:fluttertoast/fluttertoast.dart";
import "dart:convert";
import "package:http/http.dart" as http;
import "./dashboard_widget.dart";
import "package:shared_preferences/shared_preferences.dart";

class otpWidget extends StatefulWidget {
  final String emailAddress;
  final String password;
  final String firstName;
  final String lastName;
  final String mobileNo;
  final num points;
  const otpWidget(
      {Key? key,
      this.emailAddress: "",
      this.password: "",
      this.firstName: "",
      this.lastName: "",
      this.mobileNo: "",
      this.points: 0});

  @override
  _otpWidgetState createState() => _otpWidgetState();
}

class _otpWidgetState extends State<otpWidget> {
  String enteredOtp = "";
  bool otpStatus = false;

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

  void createUser(ctx) async {
    var url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyDpgSXCIPigSzmvciQnauTbvLfQVOjrH94");

    if (enteredOtp == "1234") {
      print("Success");
      otpStatus = true;
    } else {
      print("Failure");
      otpStatus = false;
    }

    if (otpStatus) {
      var result = await http.post(url,
          body: json.encode({
            "email": widget.emailAddress,
            "password": widget.password,
            "returnSecureToken": true
          }));
      Map body = json.decode(result.body);
      print(body);

      if (body.containsKey("error")) {
        showToast("Email already in use!");
      } else {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        var email = body['email'],
            idToken = body['idToken'],
            localId = body['localId'];
        prefs.setString('email', email);
        prefs.setString('idToken', idToken);
        prefs.setString('localId', localId);

        var url2 = Uri.parse(
            "https://petbottle-project-ae85a-default-rtdb.firebaseio.com/usersdata/$localId.json");

        var result2 = await http.patch(url2,
            headers: {"Content-Type": "application/json"},
            body: json.encode({
              "email": widget.emailAddress,
              "password": widget.password,
              "idToken": idToken,
              "firstName": widget.firstName,
              "lastName": widget.lastName,
              "mobileNo": widget.mobileNo,
            }));

        var url3 = Uri.parse(
            "https://petbottle-project-ae85a-default-rtdb.firebaseio.com/newuserdata/${widget.mobileNo}.json");

        // var getBody = await http.get(url3);

        // if (json.decode(getBody.body) == null) {
        //   await http.post(url3,
        //       headers: {"Content-Type": "application/json"},
        //       body: json.encode({"points": widget.points}));
        // } else {
        //   await http.patch(url3,
        //       headers: {"Content-Type": "application/json"},
        //       body: json.encode({"points": widget.points}));
        // }

        var result3 = await http.patch(url3,
            headers: {"Content-Type": "application/json"},
            body: json.encode({"points": widget.points}));

        Map body3 = json.decode(result3.body);
        print(body3);
        // var result3 = await http.patch(url3,
        //     headers: {"Content-Type": "application/json"},
        //     body: json.encode({"points": widget.points}));

        // Map body2 = json.decode(result3.body);
        // prefs.setString('dataId', localId);
        // print(body2);

        showToast("Signed Up Successfully!!");

        Navigator.of(ctx).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext ctx) => DashboardWidget()),
            (Route<dynamic> route) => false);
      }
    } else {
      showToast("OTP do not match!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "OTP Verification",
          ),
          backgroundColor: Color.fromRGBO(0, 200, 0, 1),
        ),
        body: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
                child: Column(children: [
              Container(margin: EdgeInsets.only(top: 20.0)),
              TextField(
                decoration: InputDecoration(
                  labelText: "Enter OTP",
                  prefixIcon: Icon(FlutterIcons.lock_outline_mdi,
                      color: Color.fromRGBO(0, 200, 0, 1)),
                ),
                onChanged: (v) {
                  enteredOtp = v;
                },
                maxLength: 4,
                keyboardType: TextInputType.number,
              ),
              Container(
                  margin: EdgeInsets.only(top: 30.0),
                  child: ElevatedButton(
                      child: Text("Verify OTP"),
                      onPressed: () => createUser(context),
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.lightGreen.shade800),
                          fixedSize:
                              MaterialStateProperty.all(Size.fromWidth(320))))),
            ]))));
  }
}
