import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mandate_storeapp/Screens/InvestmentDetail/investment_detail_screen.dart';
import 'package:mandate_storeapp/Screens/Signup/components/background.dart';
import 'package:mandate_storeapp/components/rounded_button.dart';
import 'package:mandate_storeapp/components/text_field_container.dart';
import 'package:mandate_storeapp/constants.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mandate_storeapp/mainpage.dart';
import 'package:mandate_storeapp/utils.dart';
import 'package:path/path.dart';

class Body extends StatefulWidget {
  // int userId;
  // int investorId;

  // Body({@required this.userId, @required this.investorId});

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final controllerInvestAmount = TextEditingController();
  final controllerAmountAfter = TextEditingController(text: '0.00');
  final controllerNairaRate = TextEditingController();
  int selectedShipping;
  String selectedShippingName = '';
  int selectedProduct;
  String selectedProductName = '';
  List<dynamic> shippingDetails = [];
  List<dynamic> productPayingFor = [];

  bool showLoading = true;

  double remoteRate;
  String token;
  int investorId;

  fetchNeccessaryData() async {
    var client = http.Client();
    token = await sharedPref.getString('token');

    try {
      final rateResponse = await client.get(
        Uri.http(BASE_URL, '/api/rate/'),
        headers: Utils.configHeader(token: token),
      );
      final productResponse = await client.get(
        Uri.http(BASE_URL, '/api/product/'),
        headers: Utils.configHeader(token: token),
      );
      final shippingResponse = await client.get(
        Uri.http(BASE_URL, '/api/shipping/'),
        headers: Utils.configHeader(token: token),
      );

      setState(() {
        remoteRate = rateResponse.statusCode == 200
            ? json.decode(rateResponse.body.toString())[0]['rate']
            : null;
        print(rateResponse.body.toString());
        productPayingFor = productResponse.statusCode == 200
            ? json.decode(productResponse.body.toString())
            : [];
        print(productResponse.body.toString());
        shippingDetails = shippingResponse.statusCode == 200
            ? json.decode(shippingResponse.body.toString())
            : [];
        print(shippingResponse.body.toString());
        showLoading = false;
      });
    } finally {
      client.close();
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNeccessaryData();
  }

  final sharedPref = SharedPref();

  Future<void> makePayment(BuildContext context) async {
    investorId = int.tryParse(await sharedPref.getString('investorId'));
    final url = Uri.http("www.mandatestore.ng", '/api/addinvestment');
    final response = await http.post(
      url,
      body: jsonEncode(
        {
          "investor": investorId,
          "rate": remoteRate,
          "investment": controllerInvestAmount.text,
          "transferable": controllerAmountAfter.text,
          "conversion": controllerNairaRate.text,
          "shipping": selectedShipping,
          "product": selectedProduct,
        },
      ),
      headers: Utils.configHeader(token: token),
    );
    var investmentData = json.decode(response.body.toString());
    print(investmentData);
    print(response.statusCode);
    if (response.statusCode == 201) {
      Fluttertoast.showToast(
        msg: "Validation Successfull",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InvestmentDetailScreen(
            investmentDetail: investmentData,
            product: selectedProductName,
            shipping: selectedShippingName,
          ),
        ),
      );
    } else {
      Fluttertoast.showToast(
          msg: "Invalid Username or Password",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: showLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // SizedBox(height: size.height * 0.03),
                  Icon(Icons.monetization_on, color: Colors.green, size: 96),
                  // SvgPicture.asset(
                  //   "assets/icons/signup.svg",
                  //   height: size.height * 0.35,
                  // ),
                  TextFieldContainer(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      cursorColor: kPrimaryColor,
                      controller: controllerInvestAmount,
                      decoration: InputDecoration(
                        hintText: "Investment in \$",
                        icon: Icon(
                          Icons.attach_money,
                          color: kPrimaryColor,
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        final calculate =
                            double.tryParse(controllerInvestAmount.text) -
                                (double.tryParse(controllerInvestAmount.text) *
                                    0.039);
                        controllerAmountAfter.text = '${calculate ?? 0.00}';
                        controllerNairaRate.text = '${calculate * remoteRate}';
                      },
                    ),
                  ),
                  TextFieldContainer(
                    child: TextField(
                      readOnly: true,
                      cursorColor: kPrimaryColor,
                      controller: controllerAmountAfter,
                      decoration: InputDecoration(
                        hintText: "Amount after charges in \$",
                        icon: Icon(
                          Icons.money_off,
                          color: kPrimaryColor,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  TextFieldContainer(
                    child: TextField(
                      readOnly: true,
                      obscureText: false,
                      cursorColor: kPrimaryColor,
                      controller: controllerNairaRate,
                      decoration: InputDecoration(
                        hintText: "Rate in Naira at $remoteRate",
                        labelText: "Rate in Naira at $remoteRate",
                        icon: Icon(
                          Icons.money,
                          color: kPrimaryColor,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  TextFieldContainer(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: selectedShippingName ?? '',
                      decoration: InputDecoration(
                        icon: Icon(
                          Icons.person,
                          color: kPrimaryColor,
                        ),
                        border: InputBorder.none,
                      ),
                      items: [
                            DropdownMenuItem<String>(
                              value: '',
                              child: Text('Select Shipping Details'),
                            )
                          ] +
                          shippingDetails
                              .map(
                                (data) => DropdownMenuItem<String>(
                                  value:
                                      "${data['beneficiary']}) ${data['beneficiary']} - ${data['account']}",
                                  onTap: () {
                                    selectedShipping = data['id'];
                                    selectedShippingName = data['beneficiary'];
                                  },
                                  child: Text(
                                      "${data['beneficiary']} - ${data['account']}"),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {},
                    ),
                  ),
                  TextFieldContainer(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: selectedProductName ?? '',
                      decoration: InputDecoration(
                        icon: Icon(
                          Icons.ac_unit,
                          color: kPrimaryColor,
                        ),
                        border: InputBorder.none,
                      ),
                      items: [
                            DropdownMenuItem(
                              value: '',
                              child: Text('Select Product'),
                            )
                          ] +
                          productPayingFor
                              .map(
                                (data) => DropdownMenuItem<String>(
                                  value: (data['name'] as String),
                                  onTap: () {
                                    selectedProduct = data['id'];
                                    selectedProductName = data['name'];
                                    Scaffold.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "${data['name']} - ${data['price']}",
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "${data['name']} - ${data['price']}",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {},
                    ),
                  ),
                  SizedBox(height: 16.0),
                  RoundedButton(
                    text: "MAKE PAYMENT",
                    press: () {
                      if (controllerInvestAmount.text.isEmpty) {
                        Fluttertoast.showToast(
                          msg: "Amount to be invested is required",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      } else if (controllerAmountAfter.text.isEmpty) {
                        Fluttertoast.showToast(
                          msg: "Amount to be invested is Required",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      } else if (controllerNairaRate.text.isEmpty) {
                        Fluttertoast.showToast(
                          msg: "Amount to be invested is Required",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      } else if (selectedShippingName.isEmpty) {
                        Fluttertoast.showToast(
                          msg: "Shipping Detail is Required",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      } else if (selectedProductName.isEmpty) {
                        Fluttertoast.showToast(
                          msg: "Product to be paid for is Required",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      } else {
                        makePayment(context);
                      }
                    },
                  ),
                  SizedBox(height: size.height * 0.03),
                ],
              ),
            ),
    );
  }
}
