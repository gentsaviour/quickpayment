import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mandate_storeapp/Screens/Signup/components/background.dart';
import 'package:mandate_storeapp/components/rounded_button.dart';
import 'package:mandate_storeapp/components/text_field_container.dart';
import 'package:mandate_storeapp/constants.dart';
import 'package:http/http.dart' as http;
import 'package:mandate_storeapp/utils.dart';

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

  final controllerBeneficiary = TextEditingController();
  final controllerAccount = TextEditingController();
  final controllerAddress = TextEditingController();
  int selectedBank;
  String selectedBankName = '';
  List<dynamic> banks = [];

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
      final bankResponse = await client.get(Uri.http(BASE_URL, '/api/bank'),
          headers: Utils.configHeader(token: token));

      setState(() {
        banks = bankResponse.statusCode == 200
            ? (json.decode(bankResponse.body.toString()) as List)
            : [];
        print(bankResponse.body.toString());
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

  Future<void> addShipping(BuildContext context) async {
    investorId = int.tryParse(await sharedPref.getString('investorId'));
    final url = Uri.http("www.mandatestore.ng", '/api/shipping/');
    final response = await http.post(
      url,
      body: jsonEncode(
        {
          "address": controllerAddress.text,
          "beneficiary": controllerBeneficiary.text,
          "account": controllerAccount.text,
          "bank": selectedBank,
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
          builder: (context) => ShippingDetailsScreen(),
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
                  Icon(Icons.person_add, color: Colors.green, size: 96),
                  // SvgPicture.asset(
                  //   "assets/icons/signup.svg",
                  //   height: size.height * 0.35,
                  // ),
                  TextFieldContainer(
                    child: TextField(
                      keyboardType: TextInputType.text,
                      cursorColor: kPrimaryColor,
                      controller: controllerBeneficiary,
                      decoration: InputDecoration(
                        hintText: "Beneficiary",
                        icon: Icon(
                          Icons.person,
                          color: kPrimaryColor,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  TextFieldContainer(
                    child: TextField(
                      cursorColor: kPrimaryColor,
                      controller: controllerAddress,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Address",
                        labelText: "Address",
                        icon: Icon(
                          Icons.location_on,
                          color: kPrimaryColor,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  TextFieldContainer(
                    child: TextField(
                      cursorColor: kPrimaryColor,
                      controller: controllerAccount,
                      decoration: InputDecoration(
                        hintText: "Account Number",
                        icon: Icon(
                          Icons.account_balance_wallet,
                          color: kPrimaryColor,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  TextFieldContainer(
                    child: DropdownButtonFormField<String>(
                      value: selectedBankName as String,
                      decoration: InputDecoration(
                        icon: Icon(
                          FontAwesome.bank,
                          color: kPrimaryColor,
                        ),
                        border: InputBorder.none,
                      ),
                      items: [
                            DropdownMenuItem(
                              value: '',
                              child: Text(''),
                            )
                          ] +
                          (banks)
                              .map(
                                (data) => DropdownMenuItem<String>(
                                  value: (data['name'] as String),
                                  onTap: () {
                                    selectedBank = data['id'];
                                    selectedBankName = data['name'];
                                    Scaffold.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "${data['name']}",
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "${(data['name'] as String)}",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedBankName = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 16.0),
                  RoundedButton(
                    text: "ADD SHIPPING",
                    press: () {
                      if (controllerBeneficiary.text.isEmpty) {
                        Fluttertoast.showToast(
                          msg: "Beneficiary is required",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      } else if (controllerAddress.text.isEmpty) {
                        Fluttertoast.showToast(
                          msg: "Address is required",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      } else if (controllerAccount.text.isEmpty) {
                        Fluttertoast.showToast(
                          msg: "Account number is required",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      } else if (selectedBankName.isEmpty) {
                        Fluttertoast.showToast(
                          msg: "Bank is Required",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      } else {
                        addShipping(context);
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

class ShippingDetailsScreen extends StatefulWidget {
  ShippingDetailsScreen({Key key}) : super(key: key);

  @override
  _ShippingDetailsScreenState createState() => _ShippingDetailsScreenState();
}

class _ShippingDetailsScreenState extends State<ShippingDetailsScreen> {
  List<dynamic> shippingDetails = [];
  final sharedPref = SharedPref();

  bool showLoading = true;

  String token;
  int investorId;

  fetchNeccessaryData() async {
    var client = http.Client();
    token = await sharedPref.getString('token');

    try {
      final shippingResponse = await client.get(
        Uri.http(BASE_URL, '/api/shipping/'),
        headers: Utils.configHeader(token: token),
      );

      setState(() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Shippings')),
      body: showLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              separatorBuilder: (context, index) => Divider(),
              itemCount: shippingDetails.length,
              itemBuilder: (context, index) {
                final data = shippingDetails[index];
                return ListTile(
                  leading: Icon(Icons.person),
                  title: Text("${data['beneficiary']} - ${data['account']}"),
                  subtitle: Wrap(
                    children: [
                      Text("${data['bank_obj']['name']} | "),
                      Text("${data['address']}"),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
