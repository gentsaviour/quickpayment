import 'package:flutter/material.dart';
import 'package:mandate_storeapp/Screens/InvestmentDetail/components/body.dart';

class InvestmentDetailScreen extends StatelessWidget {
  final String product;
  final String shipping;
  final Map<String, dynamic> investmentDetail;

  InvestmentDetailScreen(
      {@required this.product, @required this.shipping, this.investmentDetail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Investment Details'),
      ),
      body: Body(
        investmentDetail: investmentDetail,
        product: product,
        shipping: shipping,
      ),
    );
  }
}
