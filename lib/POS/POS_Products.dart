import 'package:denario/Models/Products.dart';
import 'package:denario/POS/POS_Desk.dart';
import 'package:denario/POS/POS_Mobile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class POSProducts extends StatelessWidget {
  final String firstCategory;
  final GlobalKey<ScaffoldState> scaffoldKeyMobile;
  const POSProducts(this.firstCategory, {this.scaffoldKeyMobile, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Products> productList = Provider.of<List<Products>>(context);
    if (productList == null) {
      return Container();
    }

    if (MediaQuery.of(context).size.width > 650) {
      return POSDesk(
        productList: productList,
        firstCategory: firstCategory,
      );
    } else {
      return POSMobile(firstCategory, productList, scaffoldKeyMobile);
    }
  }
}
