import 'dart:convert';
import 'dart:io';

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

class Body extends StatelessWidget {
  final String product;
  final String shipping;
  final Map<String, dynamic> investmentDetail;

  Body(
      {@required this.product, @required this.shipping, this.investmentDetail});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: ListView(
        children: [
          ListTile(
            title: Text(shipping),
            subtitle: Text('Shipping Details'),
          ),
          ListTile(
            title: Text(product),
            subtitle: Text('Product Paid For'),
          ),
          ListTile(
            title: Text('${investmentDetail['investment']}'),
            subtitle: Text('Amount Invested in \$'),
          ),
          ListTile(
            title: Text('${investmentDetail['rate']}'),
            subtitle: Text('Exchange Rate'),
          ),
          ListTile(
            title: Text('${investmentDetail['conversion']}'),
            subtitle: Text('Rate in naira'),
          ),
          ListTile(
            title: Text('${investmentDetail['transferable']}'),
            subtitle: Text('Amount Transferable in \$'),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: RoundedButton(
              text: "CHECKOUT",
              press: () {},
            ),
          ),
        ],
      ),
    );
  }
}
