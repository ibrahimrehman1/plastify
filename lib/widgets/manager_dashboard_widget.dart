import "package:flutter/material.dart";
import "package:flutter_icons/flutter_icons.dart";
import "package:http/http.dart" as http;
import "dart:convert";
import "package:shared_preferences/shared_preferences.dart";

class ManagerDashboardWidget extends StatefulWidget {
  const ManagerDashboardWidget({Key? key}) : super(key: key);

  @override
  _ManagerDashboardWidgetState createState() => _ManagerDashboardWidgetState();
}

class _ManagerDashboardWidgetState extends State<ManagerDashboardWidget> {
  String dealName = "";
  String requiredPoints = "";
  var allDeals = [];

  Future getAllDeals(managerEmail) async {
    var dealUrl = Uri.parse(
        "https://petbottle-project-default-rtdb.firebaseio.com/managerdeals/$managerEmail.json");

    var allEmailsResult = await http.get(dealUrl);
    var body = json.decode(allEmailsResult.body);
    print("All Deals: " + body.toString());
    setState(() {
      allDeals = body['deals'];
    });
  }

  void handleDealAddition() async {
    final SharedPreferences preference = await SharedPreferences.getInstance();
    var managerEmail = preference.getString('email')?.split("@")[0];
    var dealUrl = Uri.parse(
        "https://petbottle-project-default-rtdb.firebaseio.com/managerdeals/$managerEmail.json");

    getAllDeals(managerEmail).whenComplete(() async {
      print(allDeals);
      var result2 = await http.patch(dealUrl,
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            "deals": [
              ...allDeals,
              {"dealName": dealName, "requiredPoints": requiredPoints}
            ],
            "managerEmail": preference.getString('email')
          }));

      var body = json.decode(result2.body);
      print(body);
    });
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
            title: Text('Manager Dashboard'),
          ),
          body: Container(
            margin:
                EdgeInsets.only(top: 15.0, left: 5.0, right: 5.0, bottom: 5.0),
            child: TabBarView(
              children: [
                SingleChildScrollView(
                    child: Column(
                  children: [
                    Text("Add a Deal",
                        style: TextStyle(
                            fontSize: 30.0, fontWeight: FontWeight.bold)),
                    Container(
                        margin: EdgeInsets.only(top: 20.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                              labelText: "Deal Name",
                              prefixIcon: Icon(FlutterIcons.shopping_bag_ent,
                                  color: Color.fromRGBO(0, 200, 0, 1))),
                          onChanged: (v) {
                            dealName = v;
                          },
                          cursorColor: Color.fromRGBO(0, 200, 0, 1),
                          maxLength: 20,
                        )),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: "Required Points",
                          prefixIcon: Icon(FlutterIcons.shopping_bag_ent,
                              color: Color.fromRGBO(0, 200, 0, 1))),
                      onChanged: (v) {
                        requiredPoints = v;
                      },
                      cursorColor: Color.fromRGBO(0, 200, 0, 1),
                      maxLength: 20,
                    ),
                    Container(
                        margin: EdgeInsets.only(top: 30.0),
                        child: ElevatedButton(
                            child: Text("Add Deal"),
                            onPressed: () => handleDealAddition(),
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
                                  title: Text(
                                    allDeals[index]['dealName'],
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(allDeals[index]
                                          ['requiredPoints']
                                      .toString()),
                                ));
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
