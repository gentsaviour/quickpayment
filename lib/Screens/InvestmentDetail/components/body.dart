import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mandate_storeapp/Screens/Signup/components/background.dart';
import 'package:mandate_storeapp/components/rounded_button.dart';
import 'package:mandate_storeapp/components/text_field_container.dart';
import 'package:mandate_storeapp/constants.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mandate_storeapp/mainpage.dart';
import 'package:mandate_storeapp/utils.dart';
import 'package:path/path.dart';
import 'package:rave_flutter/rave_flutter.dart';

class Body extends StatefulWidget {
  final String product;
  final String shipping;
  final Map<String, dynamic> investmentDetail;

  Body(
      {@required this.product, @required this.shipping, this.investmentDetail});

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  dynamic userDetails;
  final sharedPref = SharedPref();
  bool showLoading = true;

  String token;
  int investorId;
  bool successful = false;

  fetchNeccessaryData() async {
    var client = http.Client();
    token = await sharedPref.getString('token');

    try {
      final userDetailsResponse = await client.get(
        Uri.http(BASE_URL, '/api/userdetails/'),
        headers: Utils.configHeader(token: token),
      );

      setState(() {
        print(userDetailsResponse.body.toString());
        userDetails = json.decode(userDetailsResponse.body.toString());
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
    return showLoading
        ? Center(child: CircularProgressIndicator())
        : Background(
            child: ListView(
              children: [
                ListTile(
                  title: Text(widget.shipping),
                  subtitle: Text('Shipping Details'),
                ),
                ListTile(
                  title: Text(widget.product),
                  subtitle: Text('Product Paid For'),
                ),
                ListTile(
                  title: Text('${widget.investmentDetail['investment']}'),
                  subtitle: Text('Amount Invested in \$'),
                ),
                ListTile(
                  title: Text('${widget.investmentDetail['rate']}'),
                  subtitle: Text('Exchange Rate'),
                ),
                ListTile(
                  title: Text('${widget.investmentDetail['conversion']}'),
                  subtitle: Text('Rate in naira'),
                ),
                ListTile(
                  title: Text('${widget.investmentDetail['transferable']}'),
                  subtitle: Text('Amount Transferable in \$'),
                ),
                ListTile(
                  title: Text('${widget.investmentDetail['ref_code']}'),
                  subtitle: Text('Payment Reference Code'),
                ),
                successful
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: RoundedButton(
                          text: "CHECKOUT",
                          press: () => processTransaction(context),
                        ),
                      ),
              ],
            ),
          );
  }

  processTransaction(BuildContext context) async {
    // Get a reference to RavePayInitializer
    var initializer = RavePayInitializer(
      amount: widget.investmentDetail['investment'],
      publicKey: kReleaseMode
          ? 'FLWPUBK-c1bccd31678e460df713a77dbd38f013-X'
          : 'FLWPUBK_TEST-274c85854362a3e67555aba71efdd19f-X',
      encryptionKey: kReleaseMode
          ? '188814becafb4815c582189c'
          : 'FLWSECK_TEST96da9a851f9d',
    )
      ..country = "US"
      ..currency = "USD"
      ..email = userDetails['email']
      ..fName = userDetails['first_name']
      ..lName = userDetails['last_name']
      ..txRef = widget.investmentDetail['ref_code']
      ..acceptCardPayments = true
      ..staging = !kReleaseMode
      ..displayFee = true;

    // Initialize and get the transaction result
    RaveResult response = await RavePayManager()
        .prompt(context: context, initializer: initializer);

    switch (response.status) {
      case RaveStatus.success:
        await makePayment(context);
        break;
      case RaveStatus.error:
      case RaveStatus.cancelled:
        Scaffold.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error: An error occured during payment'),
        ));
        break;
      default:
    }
  }

  Future<void> makePayment(BuildContext context) async {
    investorId = int.tryParse(await sharedPref.getString('investorId'));
    final url = Uri.http(
      "www.mandatestore.ng",
      '/api/payment_confirm_completed',
    );
    final response = await http.post(
      url,
      body: jsonEncode(
        {
          "investment_id": widget.investmentDetail['id'],
        },
      ),
      headers: Utils.configHeader(token: token),
    );
    var checkoutData = json.decode(response.body.toString());
    print(checkoutData);
    print(response.statusCode);
    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "Validation Successfull",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      setState(() {
        successful = true;
      });
    } else {
      Fluttertoast.showToast(
        msg: "Payment cannot be verified, contact admin",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}
