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
  List<String> products = ["400 points", "250 points", "1000 points"];

  List<String> productsSubtitles = ["KFC", "Macdonald", "Starbucks"];

  _DashboardWidgetState() {
    handleData().whenComplete(() => print("abc"));
  }

  Future handleData() async {
    var url2 = Uri.parse(
        "https://petbottle-project-default-rtdb.firebaseio.com/usersdata.json");

    var result2 = await http.get(url2);
    final SharedPreferences preference = await SharedPreferences.getInstance();
    var email = preference.getString('email');
    print("Data ID: " + preference.getString('dataid').toString());

    var body = await json
        .decode(result2.body)[preference.getString('dataid').toString()];

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
          ),
          body: Container(
            margin:
                EdgeInsets.only(top: 15.0, left: 5.0, right: 5.0, bottom: 5.0),
            child: TabBarView(
              children: [
                Column(
                  children: [
                    Text(
                      "Your Balance",
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                    Text("1260 points",
                        style: TextStyle(
                            fontSize: 30.0, fontWeight: FontWeight.bold))
                  ],
                ),
                Column(
                  children: [
                    Text("Previous Redeems",
                        style: TextStyle(
                            fontSize: 30.0, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: SizedBox(
                        height: 200.0,
                        child: new ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: products.length,
                          itemBuilder: (BuildContext ctxt, int index) {
                            return new ListTile(
                              title: Text(
                                products[index],
                                style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(productsSubtitles[index]),
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
                          Text("Email Address"),
                          Text(userData['email']),
                          Text("First Name"),
                          Text(userData['firstName']),
                          Text("Last Name"),
                          Text(userData['lastName']),
                          Text("Mobile No."),
                          Text(userData['mobileNo']),
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
                                          Size.fromWidth(320)))))
                        ],
                      )
                    : Text(""),
              ],
            ),
          )),
    ));
  }
}
