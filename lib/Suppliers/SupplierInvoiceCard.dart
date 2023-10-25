import 'package:denario/Expenses/SinglePayableDialog.dart';
import 'package:denario/Models/Payables.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SupplierIvoiceCard extends StatelessWidget {
  final Payables payable;
  final String businessID;
  SupplierIvoiceCard(this.payable, this.businessID, {Key? key})
      : super(key: key);

  final formatCurrency = new NumberFormat.simpleCurrency();

  @override
  Widget build(BuildContext context) {
    var ageing = payable.date!.difference(DateTime.now()).inDays * -1;

    return TextButton(
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) {
              return SinglePayableDialog(payable, businessID);
            });
      },
      child: Container(
        height: 60,
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //Fecha
            Expanded(
              flex: 3,
              child: Container(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //Desc
                      Text(
                        (ageing == 0) ? 'Hoy' : '+$ageing días',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: (ageing > 30) ? Colors.red : Colors.black),
                      ),
                      SizedBox(height: 5),
                      //Date
                      Container(
                        child: Text(
                          DateFormat.MMMd().format(payable.date!).toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ]),
              ),
            ),
            SizedBox(width: 10),
            //Cost Type
            Expanded(
              flex: 3,
              child: Container(
                  width: (MediaQuery.of(context).size.width > 1200) ? 150 : 100,
                  child: Center(
                    child: Text(
                      (payable.referenceNo != '')
                          ? '${payable.referenceNo}'
                          : 'Sin N° de referencia',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.black),
                    ),
                  )),
            ),
            SizedBox(width: 10),
            //Total
            Expanded(
              flex: 3,
              child: Container(
                  width: 70,
                  child: Center(
                    child: Text('${formatCurrency.format(payable.total)}',
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
