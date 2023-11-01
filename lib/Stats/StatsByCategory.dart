import 'package:denario/Models/DailyCash.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatsByCategory extends StatelessWidget {
  final List categoryList;
  final DailyTransactions? dayStats;
  StatsByCategory(this.dayStats, this.categoryList, {Key? key})
      : super(key: key);

  final formatCurrency = new NumberFormat.simpleCurrency();

  @override
  Widget build(BuildContext context) {
    if (categoryList.length < 1) {
      return Container();
    }

    return Expanded(
      child: Container(
        child: ListView.builder(
            itemCount: categoryList.length,
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
                    //Producto
                    Container(
                        width: 150,
                        child: Text(
                          '${categoryList[i] ?? ''}',
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
                            (dayStats != null)
                                ? '${formatCurrency.format(dayStats!.salesAmountbyCategory![(categoryList[i])] ?? 0)}'
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
