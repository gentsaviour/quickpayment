import 'package:flutter/material.dart';
import 'package:mandate_storeapp/Screens/DataValidation/components/body.dart';

class DataValidationScreen extends StatelessWidget {
  final int userId;
  final int investorId;

  DataValidationScreen({@required this.userId, @required this.investorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Body(userId: userId, investorId: investorId)),
    );
  }
}
