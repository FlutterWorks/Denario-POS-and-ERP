import 'package:denario/Models/Supply.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SupplierProductCard extends StatelessWidget {
  final Supply product;
  final String businessID;
  SupplierProductCard(this.product, this.businessID, {Key? key})
      : super(key: key);

  final formatCurrency = new NumberFormat.simpleCurrency();

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        // showDialog(
        //     context: context,
        //     builder: (context) {
        //       return SinglePayableDialog(payable, businessID, null);
        //     });
      },
      child: Container(
        height: 60,
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            //Product
            Expanded(
              flex: 3,
              child: Container(
                  width: (MediaQuery.of(context).size.width > 1200) ? 150 : 100,
                  child: Text(
                    '${product.supply}',
                    textAlign: TextAlign.start,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.w500, color: Colors.black),
                  )),
            ),
            //Qty
            Expanded(
              flex: 2,
              child: Container(
                  width: (MediaQuery.of(context).size.width > 1200) ? 150 : 100,
                  child: Center(
                    child: Text(
                      '${product.qty}',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.grey),
                    ),
                  )),
            ),
            //Unit
            Expanded(
              flex: 2,
              child: Container(
                  width: (MediaQuery.of(context).size.width > 1200) ? 150 : 100,
                  child: Center(
                    child: Text(
                      '${product.unit}',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.grey),
                    ),
                  )),
            ),
            //Total
            Expanded(
              flex: 2,
              child: Container(
                  width: 70,
                  child: Center(
                    child: Text('${formatCurrency.format(product.price)}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black)),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
