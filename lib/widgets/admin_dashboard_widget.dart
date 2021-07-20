import "package:flutter/material.dart";
import "package:flutter_icons/flutter_icons.dart";
import "package:http/http.dart" as http;
import "dart:convert";
import "package:shared_preferences/shared_preferences.dart";

class AdminDashboardWidget extends StatefulWidget {
  const AdminDashboardWidget({Key? key}) : super(key: key);

  @override
  _AdminDashboardWidgetState createState() => _AdminDashboardWidgetState();
}

class _AdminDashboardWidgetState extends State<AdminDashboardWidget> {
  String managerEmail = "";
  String managerPassword = "";
  var allDeals = [];

  Future getAllDeals(managerEmail) async {
    var dealUrl = Uri.parse(
        "https://petbottle-project-default-rtdb.firebaseio.com/managerdeals.json");

    var allEmailsResult = await http.get(dealUrl);
    Map body = json.decode(allEmailsResult.body);
    print("All Deals: " + body.toString());
    var arr = [];
    body.forEach((key, value) {
      List val = value['deals'];
      arr.addAll(val);
    });
    print("Array: $arr");
    setState(() {
      allDeals = arr;
    });
  }

  void addManager() async {
    var url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyD6FVCXVR7SqRD2rjavBUAantQxi8Qpz-4");
    var result = await http.post(url,
        body: json.encode({
          "email": managerEmail,
          "password": managerPassword,
          "returnSecureToken": true
        }));
    Map body = json.decode(result.body);
    print(body);
  }

  void handleShowDeals() async {
    final SharedPreferences preference = await SharedPreferences.getInstance();
    var managerEmail = preference.getString('email')?.split("@")[0];
    getAllDeals(managerEmail).whenComplete(() => print("Fetched!!!"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color.fromRGBO(0, 200, 0, 1),
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.shopping_bag)),
                Tab(icon: Icon(Icons.shopping_cart)),
                Tab(icon: Icon(Icons.info_outline)),
              ],
            ),
            title: Text('Admin Dashboard'),
          ),
          body: Container(
            margin:
                EdgeInsets.only(top: 15.0, left: 5.0, right: 5.0, bottom: 5.0),
            child: TabBarView(
              children: [
                SingleChildScrollView(
                    child: Column(
                  children: [
                    Text("Add Manager", style: TextStyle(fontSize: 20.0)),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: "Manager Email",
                          prefixIcon: Icon(FlutterIcons.shopping_bag_ent,
                              color: Color.fromRGBO(0, 200, 0, 1))),
                      onChanged: (v) {
                        managerEmail = v;
                      },
                      cursorColor: Color.fromRGBO(0, 200, 0, 1),
                      maxLength: 50,
                    ),
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                          labelText: "Manager Password",
                          prefixIcon: Icon(FlutterIcons.passport_biometric_mco,
                              color: Color.fromRGBO(0, 200, 0, 1))),
                      onChanged: (v) {
                        managerPassword = v;
                      },
                      cursorColor: Color.fromRGBO(0, 200, 0, 1),
                      maxLength: 20,
                    ),
                    Container(
                        margin: EdgeInsets.only(top: 30.0),
                        child: ElevatedButton(
                            child: Text("Add Manager"),
                            onPressed: () => addManager(),
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.lightGreen.shade800),
                                fixedSize: MaterialStateProperty.all(
                                    Size.fromWidth(320)))))
                  ],
                )),
                Column(
                  children: [
                    allDeals.length == 0
                        ? Container(
                            margin: EdgeInsets.only(top: 30.0),
                            child: ElevatedButton(
                                child: Text("Show all Deals"),
                                onPressed: () => handleShowDeals(),
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.lightGreen.shade800),
                                    fixedSize: MaterialStateProperty.all(
                                        Size.fromWidth(320)))))
                        : Text("All Deals",
                            style: TextStyle(
                                fontSize: 30.0, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: SizedBox(
                        height: 200.0,
                        child: new ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: allDeals.length,
                          itemBuilder: (BuildContext ctxt, int index) {
                            return new Container(
                                margin: EdgeInsets.all(5.0),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                  color: Colors.black,
                                  width: 1.0,
                                )),
                                child: ListTile(
                                    leading: new Image.memory(base64
                                        .decode(allDeals[index]['image'])),
                                    title: Column(children: [
                                      Text(
                                        allDeals[index]['dealName'],
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold),
                                      )
                                    ]),
                                    subtitle: Container(
                                        margin: EdgeInsets.only(
                                            top: 10.0, bottom: 10.0),
                                        child: Column(children: [
                                          Text(allDeals[index]['address']),
                                          Text(allDeals[index]
                                                  ['requiredPoints'] +
                                              " Points"),
                                        ]))));
                          },
                        ),
                      ),
                    ),
                    allDeals.length != 0
                        ? Container(
                            margin: EdgeInsets.only(top: 30.0),
                            child: ElevatedButton(
                                child: Text("Refresh"),
                                onPressed: () => handleShowDeals(),
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.lightGreen.shade800),
                                    fixedSize: MaterialStateProperty.all(
                                        Size.fromWidth(320)))))
                        : Text("")
                  ],
                ),
                Column(
                  children: [],
                )
              ],
            ),
          )),
    ));
  }
}
