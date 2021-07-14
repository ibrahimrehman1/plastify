import "package:flutter/material.dart";
import "dart:core";
import "package:flutter_icons/flutter_icons.dart";
import "package:http/http.dart" as http;
import "dart:convert";
import "./login_widget.dart";
import "package:shared_preferences/shared_preferences.dart";
import "./dashboard_widget.dart";
import "../main.dart";

var currentEmail = null;

class SignupWidget extends StatefulWidget {
  @override
  _SignupWidgetState createState() => _SignupWidgetState();
}

class _SignupWidgetState extends State<SignupWidget> {
  String firstName = "";

  String lastName = "";

  String permanentAddress = "";

  String mobileNo = "";

  String emailAddress = "";

  String password = "";

  String confirmPassword = "";

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
    print(currentEmail);
    currentEmail != null
        ? navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) {
            return (DashboardWidget());
          }))
        : "";
  }

  void createUser(ctx) async {
    var url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyD6FVCXVR7SqRD2rjavBUAantQxi8Qpz-4");

    if (password == confirmPassword) {
      var result = await http.post(url,
          body: json.encode({
            "email": emailAddress,
            "password": password,
            "returnSecureToken": true
          }));
      Map body = json.decode(result.body);
      print(body);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var email = body['email'],
          idToken = body['idToken'],
          localId = body['localId'];
      prefs.setString('email', email);
      prefs.setString('idToken', idToken);
      prefs.setString('localId', localId);

      var url2 = Uri.parse(
          "https://petbottle-project-default-rtdb.firebaseio.com/usersdata/$localId.json");

      var result2 = await http.patch(url2,
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            "email": emailAddress,
            "password": password,
            "idToken": idToken,
            "firstName": firstName,
            "lastName": lastName,
            "permanentAddress": permanentAddress,
            "mobileNo": mobileNo
          }));

      Map body2 = json.decode(result2.body);
      prefs.setString('dataId', localId);
      print(body2);

      Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
        return (DashboardWidget());
      }));
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
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
                child: Column(children: [
              TextFormField(
                decoration: InputDecoration(
                    labelText: "First Name",
                    prefixIcon: Icon(FlutterIcons.profile_ant,
                        color: Color.fromRGBO(0, 200, 0, 1))),
                onChanged: (v) {
                  firstName = v;
                },
                cursorColor: Color.fromRGBO(0, 200, 0, 1),
                maxLength: 20,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Last Name",
                  prefixIcon: Icon(FlutterIcons.profile_ant,
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
                  prefixIcon: Icon(FlutterIcons.email_box_mco,
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
                    labelText: "Permanent Address",
                    prefixIcon: Icon(FlutterIcons.address_book_faw,
                        color: Color.fromRGBO(0, 200, 0, 1))),
                onChanged: (v) {
                  permanentAddress = v;
                },
                maxLength: 100,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Mobile Number",
                  prefixIcon: Icon(FlutterIcons.device_mobile_oct,
                      color: Color.fromRGBO(0, 200, 0, 1)),
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  mobileNo = v;
                },
                maxLength: 10,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(FlutterIcons.lock_alert_mco,
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
                  prefixIcon: Icon(FlutterIcons.lock_alert_mco,
                      color: Color.fromRGBO(0, 200, 0, 1)),
                ),
                obscureText: true,
                onChanged: (v) {
                  confirmPassword = v;
                },
                maxLength: 30,
              ),
              Container(
                  margin: EdgeInsets.only(top: 30.0),
                  child: ElevatedButton(
                      child: Text("Signup"),
                      onPressed: () => createUser(context),
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.lightGreen.shade800),
                          fixedSize:
                              MaterialStateProperty.all(Size.fromWidth(320))))),
              Container(
                  margin: EdgeInsets.only(top: 10.0, bottom: 20.0),
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
