import 'package:flutter/material.dart';
import 'package:mandate_storeapp/Screens/AddShipping/components/body.dart';

class AddShippingScreen extends StatelessWidget {
  // final int userId;
  // final int investorId;

  // AddInvestmentScreen({@required this.userId, @required this.investorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Shipping'),
      ),
      body: Body(),
    );
  }
}
