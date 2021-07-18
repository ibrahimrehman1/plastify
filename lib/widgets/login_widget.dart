import 'package:app/widgets/admin_dashboard_widget.dart';
import "package:flutter/material.dart";
import "package:flutter_icons/flutter_icons.dart";
import "package:http/http.dart" as http;
import "dart:convert";
import "package:shared_preferences/shared_preferences.dart";
import "./dashboard_widget.dart";
import "./manager_dashboard_widget.dart";
import "./admin_dashboard_widget.dart";

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
        "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyD6FVCXVR7SqRD2rjavBUAantQxi8Qpz-4");

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

    final prefs = await SharedPreferences.getInstance();

    prefs.setString('email', body['email']);
    prefs.setString('idToken', body['idToken']);
    prefs.setString('dataId', body['localId']);

    if (body['email'].toString().contains("manager")) {
      Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
        return (ManagerDashboardWidget());
      }));
    } else if (body['email'].toString().contains("admin")) {
      Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
        return (AdminDashboardWidget());
      }));
    } else {
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
            "Login",
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
                  image: AssetImage('assets/images/ncai_logo.png'),
                  width: 150,
                  height: 150,
                ),
                Container(margin: EdgeInsets.only(top: 20.0)),
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
                                Size.fromWidth(320)))))
              ],
            ))));
  }
}
