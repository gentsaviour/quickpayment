import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mandate_storeapp/Screens/AddInvestment/add_investment_screen.dart';
import 'package:mandate_storeapp/Screens/AddShipping/add_shipping_screen.dart';
import 'package:mandate_storeapp/Screens/AddShipping/components/body.dart';
import 'package:mandate_storeapp/Screens/Login/login_screen.dart';
import 'package:mandate_storeapp/constants.dart';
import 'package:mandate_storeapp/utils.dart';
import 'package:http/http.dart' as http;

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String storedUsername;
  String storedPassword;
  String storedToken;

  List<dynamic> completedTransactions = [];
  dynamic userDetails;
  final sharedPref = SharedPref();

  bool showLoading = true;

  String token;
  int investorId;

  fetchNeccessaryData() async {
    var client = http.Client();
    token = await sharedPref.getString('token');

    try {
      final completedTransactionsResponse = await client.get(
        Uri.http(BASE_URL, '/api/completed/'),
        headers: Utils.configHeader(token: token),
      );
      final userDetailsResponse = await client.get(
        Uri.http(BASE_URL, '/api/userdetail'),
        headers: Utils.configHeader(token: token),
      );

      setState(() {
        completedTransactions = completedTransactionsResponse.statusCode == 200
            ? json.decode(completedTransactionsResponse.body.toString())
            : [];
        print(completedTransactionsResponse.body.toString());
        print(userDetailsResponse.body.toString());
        userDetails = json.decode(userDetailsResponse.body.toString());
        showLoading = false;
      });

      await fetchSharedPref();
    } finally {
      client.close();
    }
  }

  Future fetchSharedPref() async {
    storedToken = await sharedPref.getString('token');
    storedUsername = await sharedPref.getString('username');
    storedPassword = await sharedPref.getString('password');
    await Future.delayed(
      Duration(seconds: 3),
    ); // You can remove this, this is just to see the circular indicator
    return true;
  }

  @override
  void initState() {
    super.initState();
    fetchNeccessaryData();
  }

  int _selectedItemIndex = 2;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // bottomNavigationBar: Row(
        //   children: [
        //     buildNavBarItem(Icons.home, 0),
        //     buildNavBarItem(Icons.card_giftcard, 1),
        //     buildNavBarItem(Icons.camera, 2),
        //     buildNavBarItem(Icons.pie_chart, 3),
        //     buildNavBarItem(Icons.person, 4),
        //   ],
        // ),
        body: showLoading
            ? Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  Column(
                    children: [
                      Container(
                        height: 300,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [Color(0XFF00B686), Color(0XFF00838F)]),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20.0,
                            top: 30,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    Icons.menu,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    "Available balance",
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => Navigator.of(context)
                                        .pushAndRemoveUntil(
                                      // the new route
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            LoginScreen(),
                                      ),

                                      // this function should return true when we're done removing routes
                                      // but because we want to remove all other screens, we make it
                                      // always return false
                                      (Route route) => false,
                                    ),
                                    icon: Icon(Icons.exit_to_app),
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 80.0,
                                    height: 80.0,
                                    decoration: BoxDecoration(
                                      color: Color(0XFF00B686),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black.withOpacity(.1),
                                            blurRadius: 8,
                                            spreadRadius: 3)
                                      ],
                                      border: Border.all(
                                        width: 1.5,
                                        color: Colors.white,
                                      ),
                                      borderRadius: BorderRadius.circular(40.0),
                                    ),
                                    padding: EdgeInsets.all(5),
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        "https://www.mandatestore.ng${userDetails['profile']}",
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${Utils.capitalizeFirstLetter(userDetails['user']['first_name'])} ${Utils.capitalizeFirstLetter(userDetails['user']['last_name'])}",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.email_rounded,
                                            color: Colors.white,
                                          ),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Text(
                                            '${userDetails['user']['email']}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          )
                                          // RichText(
                                          //   text: TextSpan(
                                          //       text: "\$5320",
                                          //       style: TextStyle(
                                          //         fontSize: 20,
                                          //         fontWeight: FontWeight.w600,
                                          //       ),
                                          //       children: [
                                          //         TextSpan(
                                          //             text: ".50",
                                          //             style: TextStyle(
                                          //                 color:
                                          //                     Colors.white38))
                                          //       ]),
                                          // )
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.grey.shade100,
                          child: ListView(
                            padding: EdgeInsets.only(top: 75),
                            children: [
                              Text(
                                "Activity",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                height: 100,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    buildActivityButton(
                                      Icons.card_membership,
                                      "Quick Payment",
                                      Colors.blue.withOpacity(0.2),
                                      Color(0XFF01579B),
                                      route: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              AddInvestmentScreen(),
                                        ),
                                      ),
                                    ),
                                    buildActivityButton(
                                      Icons.transfer_within_a_station,
                                      "Add Shipping Address",
                                      Colors.cyanAccent.withOpacity(0.2),
                                      Color(0XFF0097A7),
                                      route: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              AddShippingScreen(),
                                        ),
                                      ),
                                    ),
                                    buildActivityButton(
                                      Icons.pie_chart,
                                      "Payment History",
                                      Color(0XFFD7CCC8).withOpacity(0.4),
                                      Color(0XFF9499B7),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                "Categories",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: completedTransactions.length,
                                itemBuilder: (context, index) {
                                  final data = completedTransactions[index];
                                  return buildCategoryCard(
                                    Icons.star,
                                    "${data['shipping_obj']['beneficiary']}",
                                    "${data['transferable']}",
                                    "${data['rate']}",
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  Positioned(
                    top: 185,
                    right: 0,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: 160,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.05),
                              blurRadius: 8,
                              spreadRadius: 3,
                              offset: Offset(0, 10),
                            ),
                          ],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(50),
                          )),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Transfered",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "\$${(userDetails['total_transfered'] as double).toStringAsFixed(2)}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 50,
                                margin: EdgeInsets.symmetric(horizontal: 8.0),
                                color: Colors.grey,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Conversion",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "N${(userDetails['total_conversion'] as double).toStringAsFixed(2)}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "You spent \$${(userDetails['total_transfered'] as double).toStringAsFixed(2)} so far",
                            style: TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Text(
                            "Let's see the cost statistics for this period",
                            style: TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 1,
                            width: double.maxFinite,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ShippingDetailsScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                "View Shipping Addresses",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0XFF00B686),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ));
  }

  GestureDetector buildNavBarItem(IconData icon, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedItemIndex = index;
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 5,
        height: 60,
        decoration: index == _selectedItemIndex
            ? BoxDecoration(
                border:
                    Border(bottom: BorderSide(width: 4, color: Colors.green)),
                gradient: LinearGradient(colors: [
                  Colors.green.withOpacity(0.3),
                  Colors.green.withOpacity(0.016),
                ], begin: Alignment.bottomCenter, end: Alignment.topCenter))
            : BoxDecoration(),
        child: Icon(
          icon,
          color: index == _selectedItemIndex ? Color(0XFF00B868) : Colors.grey,
        ),
      ),
    );
  }

  Container buildCategoryCard(
      IconData icon, String title, String amount, String percentage) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      height: 85,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: Color(0xFF00B686),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    "\$$amount",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "(N$percentage)",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  )
                ],
              )
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Stack(
            children: [
              Container(
                height: 5,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: Colors.grey.shade300),
              ),
              Container(
                height: 5,
                width: 80,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: Color(0XFF00B686)),
              ),
            ],
          )
        ],
      ),
    );
  }

  GestureDetector buildActivityButton(
      IconData icon, String title, Color backgroundColor, Color iconColor,
      {VoidCallback route}) {
    return GestureDetector(
      onTap: () => route(),
      // onTap: () => Navigator.of(context).push(
      //     MaterialPageRoute(builder: (BuildContext context) => AddInvestmentScreen())),
      child: Container(
        margin: EdgeInsets.all(10),
        height: 90,
        width: 90,
        decoration: BoxDecoration(
            color: backgroundColor, borderRadius: BorderRadius.circular(10.0)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: iconColor,
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
