import "package:flutter/material.dart";
import "./signup_widget.dart";
import "dart:convert";
import "package:shared_preferences/shared_preferences.dart";
import "package:http/http.dart" as http;

var userData = null;

class DashboardWidget extends StatefulWidget {
  @override
  _DashboardWidgetState createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  var firstName;
  var lastName;
  var email;
  var mobileNo;
  var allDeals = [];

  Future getAllDeals() async {
    var dealUrl = Uri.parse(
        "https://petbottle-project-default-rtdb.firebaseio.com/managerdeals/manager.json");

    var allEmailsResult = await http.get(dealUrl);
    var body = json.decode(allEmailsResult.body);
    print("All Deals: " + body.toString());
    setState(() {
      allDeals = body['deals'];
    });
  }

  List<String> productsSubtitles = ["KFC", "Macdonald", "Starbucks"];

  _DashboardWidgetState() {
    handleData().whenComplete(() => print("abc"));
  }

  Future handleData() async {
    final SharedPreferences preference = await SharedPreferences.getInstance();
    var dataId = preference.getString('dataId');
    print("Data ID: " + dataId.toString());

    var url2 = Uri.parse(
        "https://petbottle-project-default-rtdb.firebaseio.com/usersdata/$dataId.json");

    var result2 = await http.get(url2);

    var body = await json.decode(result2.body);

    // if (body['email'] != email) {
    //   var body = await json.decode(result2.body);
    //   print(body.values.singleWhere((e) {
    //     print(e);
    //   }));
    // }

    setState(() {
      userData = body;
    });
    print(result2.body.length);
  }

  Future updateData() async {
    final SharedPreferences preference = await SharedPreferences.getInstance();
    var dataId = preference.getString('dataId');
    print(dataId);
    var url3 = Uri.parse(
        "https://petbottle-project-default-rtdb.firebaseio.com/usersdata/$dataId.json");

    var result3 = await http.patch(url3,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'email': userData['email'],
          'firstName': userData['firstName'],
          'lastName': userData['lastName'],
          'mobileNo': userData['mobileNo']
        }));
    print(json.decode(result3.body));

    if (userData['email'] != email) {}
  }

  void changeEmail() async {
    final SharedPreferences preference = await SharedPreferences.getInstance();
    var urlForEmail = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:update?key=AIzaSyD6FVCXVR7SqRD2rjavBUAantQxi8Qpz-4");
    var result4 = await http.post(urlForEmail,
        body: json.encode({
          "idToken": preference.getString("idToken").toString(),
          "email": email,
          "returnSecureToken": false
        }));

    print(json.decode(result4.body));
  }

  Future<void> _showMyDialog(String msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change $msg'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: msg,
                  ),
                  keyboardType: msg == "Mobile No."
                      ? TextInputType.number
                      : TextInputType.text,
                  maxLength: 50,
                  onChanged: (v) {
                    if (msg == "First Name") {
                      firstName = v;
                    } else if (msg == "Last Name") {
                      lastName = v;
                    } else if (msg == "Email Address") {
                      email = v;
                    } else if (msg == "Mobile No.") {
                      mobileNo = v;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Change'),
              onPressed: () {
                setState(() {
                  if (msg == "First Name") {
                    userData['firstName'] = firstName;
                  } else if (msg == "Last Name") {
                    userData['lastName'] = lastName;
                  } else if (msg == "Email Address") {
                    changeEmail();

                    userData['email'] = email;
                  } else if (msg == "Mobile No.") {
                    userData['mobileNo'] = mobileNo;
                  }
                });
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
// Try reading data from the counter key. If it doesn't exist, return 0.

    return Scaffold(
        body: DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: AppBar(
              backgroundColor: Color.fromRGBO(0, 200, 0, 1),
              bottom: TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.home_filled)),
                  Tab(icon: Icon(Icons.book_outlined)),
                  Tab(icon: Icon(Icons.info_outline)),
                ],
              ),
              title: Text('Dashboard'),
              actions: <Widget>[
                Padding(
                    padding: EdgeInsets.only(right: 20.0, top: 18.0),
                    child: GestureDetector(
                      onTap: () {},
                      child: Text(
                        "1200 Points",
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                    ))
              ]),
          body: Container(
            margin:
                EdgeInsets.only(top: 15.0, left: 5.0, right: 5.0, bottom: 5.0),
            child: TabBarView(
              children: [
                Column(
                  children: [
                    allDeals.length == 0
                        ? Container(
                            margin: EdgeInsets.only(top: 30.0),
                            child: ElevatedButton(
                                child: Text("Show available Deals"),
                                onPressed: () {
                                  getAllDeals()
                                      .whenComplete(() => print("Fetched!!!"));
                                },
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.lightGreen.shade800),
                                    fixedSize: MaterialStateProperty.all(
                                        Size.fromWidth(320)))))
                        : Expanded(
                            child: SizedBox(
                              height: 200.0,
                              child: new ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: allDeals.length,
                                itemBuilder: (BuildContext ctxt, int index) {
                                  return new ListTile(
                                    title: Text(
                                      allDeals[index]['dealName'],
                                      style: TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle:
                                        Text(allDeals[index]['requiredPoints']),
                                  );
                                },
                              ),
                            ),
                          ),
                  ],
                ),
                Column(
                  children: [
                    allDeals.length == 0
                        ? Container(
                            margin: EdgeInsets.only(top: 30.0),
                            child: ElevatedButton(
                                child: Text("Show previous Redeems"),
                                onPressed: () {
                                  getAllDeals()
                                      .whenComplete(() => print("Fetched!!!"));
                                },
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.lightGreen.shade800),
                                    fixedSize: MaterialStateProperty.all(
                                        Size.fromWidth(320)))))
                        : Text("Previous Redeems",
                            style: TextStyle(
                                fontSize: 30.0, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: SizedBox(
                        height: 200.0,
                        child: new ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: allDeals.length,
                          itemBuilder: (BuildContext ctxt, int index) {
                            return new ListTile(
                              title: Text(
                                allDeals[index]['dealName'],
                                style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(allDeals[index]['requiredPoints']),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                userData != null
                    ? Column(
                        children: [
                          TextButton(
                            child: Text("Email Address",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () => _showMyDialog('Email Address'),
                          ),
                          Text(userData['email']),
                          TextButton(
                              child: Text("First Name",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: () => _showMyDialog('First Name')),
                          Text(userData['firstName']),
                          TextButton(
                              child: Text("Last Name",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: () => _showMyDialog('Last Name')),
                          Text(userData['lastName']),
                          TextButton(
                              child: Text("Mobile No.",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: () => _showMyDialog('Mobile No.')),
                          Text(userData['mobileNo']),
                          Container(
                              margin: EdgeInsets.only(top: 30.0),
                              child: ElevatedButton(
                                  child: Text("Save Data"),
                                  onPressed: () => updateData(),
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.lightGreen.shade800),
                                      fixedSize: MaterialStateProperty.all(
                                          Size.fromWidth(320))))),
                          Container(
                              margin: EdgeInsets.only(top: 30.0),
                              child: ElevatedButton(
                                  child: Text("Logout"),
                                  onPressed: () async {
                                    final SharedPreferences preference =
                                        await SharedPreferences.getInstance();
                                    await preference.remove('email');
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(builder: (_) {
                                      return (SignupWidget());
                                    }));
                                  },
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.lightGreen.shade800),
                                      fixedSize: MaterialStateProperty.all(
                                          Size.fromWidth(320))))),
                        ],
                      )
                    : Text(""),
              ],
            ),
          )),
    ));
  }
}
