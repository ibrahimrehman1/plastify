import "package:flutter/material.dart";
import "./login_widget.dart";
import "package:flutter_icons/flutter_icons.dart";
import 'package:fluttertoast/fluttertoast.dart';
import "dart:convert";
import "package:shared_preferences/shared_preferences.dart";
import "./user_http.dart";

class DashboardWidget extends StatefulWidget {
  @override
  _DashboardWidgetState createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  var firstName;
  var userData;

  var lastName;
  var newPassword;
  var email;
  var points;

  var mobileNo;
  var location;
  var allDeals = [];
  var previousRedeems = [];
  bool previousRedeemsStatus = false;
  var filteredDeals = [];
  bool redeemStatus = false;
  bool selectRedeem = false;
  bool filterStatus = false;
  int selectedDeal = -1;

  Future getAllDeals() async {
    var arr = await UserHTTP.getAllDeals();
    setState(() {
      allDeals = arr;
    });
  }

  _DashboardWidgetState() {
    handleData().whenComplete(() => getPoints());
    getAllDeals().whenComplete(() => print("Deals Fetched!"));
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

  Future handleData() async {
    final SharedPreferences preference = await SharedPreferences.getInstance();
    var dataId = preference.getString('dataId');
    var body = await UserHTTP.handleData(dataId);
    if (selectRedeem) {
      // getPreviousRedeems();
      // showToast("Deal has been Redeemed!");
    }

    if (body != null) {
      setState(() {
        userData = body;
        previousRedeems = body['previousRedeems'];
        redeemStatus = true;
        selectRedeem = false;
        selectedDeal = -1;
      });
    }
  }

  Future updateData() async {
    final SharedPreferences preference = await SharedPreferences.getInstance();
    var dataId = preference.getString('dataId');
    await UserHTTP.updateData(userData, dataId);
  }

  Future getPreviousRedeems() async {
    final SharedPreferences preference = await SharedPreferences.getInstance();
    var dataId = preference.getString('dataId');

    var userData = await UserHTTP.handleData(dataId);
    var redeem = userData['previousRedeems'];
    if (redeem != null) {
      setState(() {
        previousRedeems = redeem;
      });
    }
    setState(() {
      previousRedeemsStatus = true;
    });
  }

  void updateRedeem(Map deal, int index) async {
    final SharedPreferences preference = await SharedPreferences.getInstance();
    var dataId = preference.getString('dataId');
    // var decodedRedeem = await UserHTTP.handleData(dataId);
    // var body2 = await UserHTTP.fetchUserPoints(decodedRedeem['mobileNo']);

    var redeem = [];
    if (userData['previousRedeems'] != null) {
      redeem = userData['previousRedeems'];
    }
    // var currentPoints = body2['points'];
    var currentPoints = points;
    var requiredPoints = deal['requiredPoints'];
    var newPoints;
    if (currentPoints >= requiredPoints) {
      setState(() {
        redeemStatus = false;
        selectRedeem = true;
        selectedDeal = index;
      });

      newPoints = currentPoints - deal['requiredPoints'];
      var currentRedeems = [...redeem, deal];

      var body2 = await UserHTTP.patchData(
          dataId, currentRedeems, newPoints, userData['mobileNo']);
      // handleData();

      setState(() {
        points = newPoints;
        previousRedeems = currentRedeems;
        redeemStatus = true;
      });

      showToast("Deal has been Redeemed!");

      allDeals = allDeals.map((e) {
        if (e['dealName'] == deal['dealName']) {
          e['redeems'] += 1;
          return e;
        } else {
          return e;
        }
      }).toList();

      var body = await UserHTTP.updateManagerDeals(allDeals);
    } else {
      showToast("Points not Enough!!");
    }
  }

  void updatePassword() async {
    final SharedPreferences preference = await SharedPreferences.getInstance();
    String idToken = preference.getString("idToken").toString();
    await UserHTTP.updatePassword(idToken, newPassword);

    showToast('Password has been Updated!!');
  }

  void updateEmail() async {
    final SharedPreferences preference = await SharedPreferences.getInstance();
    String idToken = preference.getString("idToken").toString();
    await UserHTTP.updateEmail(idToken, email);

    showToast("Email has been Updated!!");
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
                    } else if (msg == "Password") {
                      newPassword = v;
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
                    updateData();
                  } else if (msg == "Last Name") {
                    userData['lastName'] = lastName;
                    updateData();
                  } else if (msg == "Email Address") {
                    userData['email'] = email;
                    updateEmail();
                    updateData();
                  } else if (msg == "Mobile No.") {
                    userData['mobileNo'] = mobileNo;
                    updateData();
                  } else if (msg == "Password") {
                    userData['password'] = newPassword;
                    updatePassword();
                    updateData();
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

  void filterDeals() {
    var arr = allDeals.where((val) {
      if (val['address']
              .toString()
              .toLowerCase()
              .contains(location.toLowerCase()) ==
          true) {
        return true;
      }
      return false;
    }).toList();
    setState(() {
      filteredDeals = arr;
      filterStatus = true;
    });
  }

  void getPoints() async {
    var body2 = await UserHTTP.fetchUserPoints(userData['mobileNo']);
    setState(() {
      points = body2['points'];
    });
  }

  @override
  Widget build(BuildContext context) {
    // print("All Deals: $allDeals");
    // print("Previous Redeems: ${previousRedeems}");
// Try reading data from the counter key. If it doesn't exist, return 0.
    // if (allDeals.length == 0) {
    //   getAllDeals().whenComplete(() => print("Deals Fetched!"));
    // }

    // if (userData != null && points == null) {
    //   getPoints();
    // }

    // if (previousRedeems.length == 0) {
    //   getPreviousRedeems()
    //       .whenComplete(() => print("Previous Redeems Fetched!"));
    // }

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
                      child: userData != null
                          ? Text(
                              points.toString() + " Points",
                              style: TextStyle(
                                  fontSize: 20.0, fontWeight: FontWeight.bold),
                            )
                          : Text(""),
                    ))
              ]),
          body: Container(
            margin:
                EdgeInsets.only(top: 15.0, left: 5.0, right: 5.0, bottom: 5.0),
            child: TabBarView(
              children: [
                Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Filter by Location",
                        prefixIcon: Icon(FlutterIcons.location_arrow_faw,
                            color: Color.fromRGBO(0, 200, 0, 1)),
                      ),
                      onChanged: (v) {
                        location = v;
                      },
                      maxLength: 30,
                    ),
                    Container(
                        margin: EdgeInsets.only(top: 30.0),
                        child: ElevatedButton(
                            child: Text("Search"),
                            onPressed: () => filterDeals(),
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.lightGreen.shade800),
                                fixedSize: MaterialStateProperty.all(
                                    Size.fromWidth(320))))),
                    filterStatus == true
                        ? Container(
                            child: ElevatedButton(
                                child: Text("Show all Deals"),
                                onPressed: () {
                                  setState(() {
                                    filterStatus = false;
                                  });
                                },
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.lightGreen.shade800),
                                    fixedSize: MaterialStateProperty.all(
                                        Size.fromWidth(320)))))
                        : Text(""),
                    allDeals.length == 0
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : Expanded(
                            child: SizedBox(
                              height: 200.0,
                              child: new ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: filterStatus == false
                                    ? allDeals.length
                                    : filteredDeals.length,
                                itemBuilder: (BuildContext ctxt, int index) {
                                  return new Container(
                                      margin: EdgeInsets.only(top: 30.0),
                                      child: ListTile(
                                          title: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Stack(children: <Widget>[
                                                  new Image.memory(
                                                      base64.decode(
                                                          filterStatus == false
                                                              ? allDeals[index]
                                                                  ['image']
                                                              : filteredDeals[
                                                                      index]
                                                                  ['image']),
                                                      width: 340,
                                                      height: 180,
                                                      fit: BoxFit.fill),
                                                  Column(children: [
                                                    Container(
                                                        margin: EdgeInsets.only(
                                                            top: 20.0),
                                                        padding:
                                                            EdgeInsets.all(5.0),
                                                        width: 100,
                                                        // height: 20,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            color:
                                                                Color.fromRGBO(
                                                                    255,
                                                                    40,
                                                                    77,
                                                                    1)),
                                                        child: Text(
                                                          filterStatus == false
                                                              ? "${allDeals[index]['percentDiscount']}% OFF"
                                                              : "${filteredDeals[index]['percentDiscount']}% OFF",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              color: Color
                                                                  .fromRGBO(
                                                                      255,
                                                                      255,
                                                                      255,
                                                                      1)),
                                                        ))
                                                  ]),
                                                ]),
                                                Text(
                                                  filterStatus == false
                                                      ? allDeals[index]
                                                          ['dealName']
                                                      : filteredDeals[index]
                                                          ['dealName'],
                                                  style: TextStyle(
                                                      fontSize: 25.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              ]),
                                          subtitle: Container(
                                              margin: EdgeInsets.only(
                                                  top: 10.0, bottom: 10.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(filterStatus == false
                                                      ? allDeals[index]
                                                          ['address']
                                                      : filteredDeals[index]
                                                          ['address']),
                                                  Text(
                                                      "Original Price: " +
                                                          (filterStatus == false
                                                                  ? allDeals[index]
                                                                          [
                                                                          'originalPrice']
                                                                      .toString()
                                                                  : filteredDeals[
                                                                          index]
                                                                      [
                                                                      'originalPrice'])
                                                              .toString() +
                                                          " Rs.",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(
                                                      "Discounted Price: " +
                                                          (filterStatus == false
                                                              ? (allDeals[index][
                                                                          'originalPrice'] -
                                                                      (allDeals[index]['percentDiscount'] /
                                                                              100) *
                                                                          allDeals[index][
                                                                              'originalPrice'])
                                                                  .toString()
                                                              : (filteredDeals[index][
                                                                          'originalPrice'] -
                                                                      (filteredDeals[index]['percentDiscount'] /
                                                                              100) *
                                                                          filteredDeals[index][
                                                                              'originalPrice'])
                                                                  .toString()) +
                                                          " Rs.",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(
                                                      "Required Points: " +
                                                          (filterStatus == false
                                                              ? allDeals[index][
                                                                      'requiredPoints']
                                                                  .toString()
                                                              : filteredDeals[
                                                                          index]
                                                                      [
                                                                      'requiredPoints']
                                                                  .toString()),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Row(children: [
                                                    Container(
                                                        child: ElevatedButton(
                                                            child:
                                                                Text("Redeem"),
                                                            onPressed: () {
                                                              updateRedeem(
                                                                  allDeals[
                                                                      index],
                                                                  index);
                                                            },
                                                            style: ButtonStyle(
                                                                backgroundColor:
                                                                    MaterialStateProperty.all<
                                                                            Color>(
                                                                        Colors
                                                                            .lightGreen
                                                                            .shade800),
                                                                fixedSize: MaterialStateProperty.all(
                                                                    Size.fromWidth(
                                                                        120))))),
                                                    redeemStatus == false &&
                                                            selectRedeem ==
                                                                true &&
                                                            selectedDeal ==
                                                                index
                                                        ? Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    left: 20.0),
                                                            child: Center(
                                                              child:
                                                                  CircularProgressIndicator(),
                                                            ))
                                                        : Text("")
                                                  ])
                                                ],
                                              ))));
                                },
                              ),
                            ),
                          ),
                  ],
                ),
                Column(
                  children: [
                    previousRedeems.length == 0
                        ? (!previousRedeemsStatus
                            ? Container(
                                margin: EdgeInsets.only(top: 20.0),
                                child:
                                    Center(child: CircularProgressIndicator()))
                            : Text("No Previous Redeems!"))
                        : Text("Previous Redeems",
                            style: TextStyle(
                                fontSize: 30.0, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: SizedBox(
                        height: 200.0,
                        child: new ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: previousRedeems.length,
                          itemBuilder: (BuildContext ctxt, int index) {
                            return new Container(
                                margin: EdgeInsets.only(top: 30.0),
                                child: ListTile(
                                    title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Stack(children: <Widget>[
                                            new Image.memory(
                                                base64.decode(
                                                    previousRedeems[index]
                                                        ['image']),
                                                width: 340,
                                                height: 180,
                                                fit: BoxFit.fill),
                                            Column(children: [
                                              Container(
                                                  margin: EdgeInsets.only(
                                                      top: 20.0),
                                                  padding: EdgeInsets.all(5.0),
                                                  width: 100,
                                                  // height: 20,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color: Color.fromRGBO(
                                                          255, 40, 77, 1)),
                                                  child: Text(
                                                    "${previousRedeems[index]['percentDiscount']}% OFF",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Color.fromRGBO(
                                                            255, 255, 255, 1)),
                                                  ))
                                            ]),
                                          ]),
                                          Text(
                                            previousRedeems[index]['dealName'],
                                            style: TextStyle(
                                                fontSize: 25.0,
                                                fontWeight: FontWeight.bold),
                                          )
                                        ]),
                                    subtitle: Container(
                                        margin: EdgeInsets.only(
                                            top: 10.0, bottom: 10.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(previousRedeems[index]
                                                ['address']),
                                            Text(
                                                "Original Price: " +
                                                    (previousRedeems[index][
                                                                'originalPrice']
                                                            .toString() +
                                                        " Rs."),
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(
                                                "Discounted Price: " +
                                                    ((previousRedeems[index][
                                                                'originalPrice'] -
                                                            (previousRedeems[
                                                                            index]
                                                                        [
                                                                        'percentDiscount'] /
                                                                    100) *
                                                                previousRedeems[
                                                                        index][
                                                                    'originalPrice'])
                                                        .toString()) +
                                                    " Rs.",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(
                                                "Required Points: " +
                                                    (previousRedeems[index]
                                                            ['requiredPoints']
                                                        .toString()),
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ],
                                        ))));
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                userData != null
                    ? SingleChildScrollView(
                        child: Column(
                        children: [
                          Container(
                              padding: EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                color: Colors.black,
                                width: 1.0,
                              )),
                              child: Column(
                                children: [
                                  TextButton(
                                    child: Text("Email Address",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    onPressed: () =>
                                        _showMyDialog('Email Address'),
                                  ),
                                  Text(userData['email']),
                                  TextButton(
                                      child: Text("First Name",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      onPressed: () =>
                                          _showMyDialog('First Name')),
                                  Text(userData['firstName']),
                                  TextButton(
                                      child: Text("Last Name",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      onPressed: () =>
                                          _showMyDialog('Last Name')),
                                  Text(userData['lastName']),
                                  TextButton(
                                      child: Text("Mobile No.",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      onPressed: () =>
                                          _showMyDialog('Mobile No.')),
                                  Text(userData['mobileNo']),
                                  TextButton(
                                      child: Text("Password",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      onPressed: () =>
                                          _showMyDialog('Password')),
                                  Text(userData['password']),
                                ],
                              )),
                          Container(
                              margin: EdgeInsets.only(top: 30.0),
                              child: ElevatedButton(
                                  child: Text("Logout"),
                                  onPressed: () async {
                                    Fluttertoast.showToast(
                                        msg: "Logged Out Successfully!!",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                    final SharedPreferences preference =
                                        await SharedPreferences.getInstance();
                                    await preference.remove('email');
                                    await preference.remove("idToken");
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(builder: (_) {
                                      return (LoginWidget());
                                    }));
                                  },
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.lightGreen.shade800),
                                      fixedSize: MaterialStateProperty.all(
                                          Size.fromWidth(320))))),
                        ],
                      ))
                    : Text(""),
              ],
            ),
          )),
    ));
  }
}
