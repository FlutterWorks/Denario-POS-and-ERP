import 'package:denario/Models/DailyCash.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatsByPaymentMethods extends StatelessWidget {
  final List paymentMethods;
  final DailyTransactions dayStats;
  StatsByPaymentMethods(this.dayStats, this.paymentMethods, {Key? key})
      : super(key: key);

  final formatCurrency = new NumberFormat.simpleCurrency();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        child: ListView.builder(
            itemCount: paymentMethods.length,
            shrinkWrap: true,
            reverse: false,
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, i) {
              return Container(
                height: 35,
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //Payment Type
                    Container(
                        width: 150,
                        child: Text(
                          '${paymentMethods[i]['Type']}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )),
                    Spacer(),
                    //Monto vendidos
                    Container(
                        width: 120,
                        child: Center(
                          child: Text(
                            (dayStats.salesByMedium![(paymentMethods[i]
                                        ['Type'])] !=
                                    null)
                                ? '${formatCurrency.format(dayStats.salesByMedium![(paymentMethods[i]['Type'])])}'
                                : '${formatCurrency.format(0)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                  ],
                ),
              );
            }),
      ),
    );
  }
}
