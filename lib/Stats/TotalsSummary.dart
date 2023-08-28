import 'package:denario/Models/DailyCash.dart';
import 'package:denario/Models/Stats.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TotalsSummary extends StatelessWidget {
  final DailyTransactions dayStats;
  final MonthlyStats monthlyStats;
  TotalsSummary({this.dayStats, this.monthlyStats, Key key}) : super(key: key);

  final formatCurrency = new NumberFormat.simpleCurrency();

  @override
  Widget build(BuildContext context) {
    var stats;
    stats = dayStats ?? monthlyStats ?? {};

    return Container(
      width: MediaQuery.of(context).size.width,
      height: 75,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //Total Sales
            Container(
              width: MediaQuery.of(context).size.width * 0.15,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: <BoxShadow>[
                  new BoxShadow(
                    color: Colors.grey[350],
                    offset: Offset(0.0, 0.0),
                    blurRadius: 10.0,
                  )
                ],
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //Amount
                    Text(
                      (dayStats != null)
                          ? '${formatCurrency.format(stats.sales)}'
                          : '${formatCurrency.format(stats.totalSales)}',
                      style:
                          TextStyle(fontWeight: FontWeight.w900, fontSize: 21),
                    ),
                    SizedBox(height: 10),
                    //Text
                    Text(
                      'Ingresos por Ventas',
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 11,
                          color: Colors.grey),
                    )
                  ]),
            ),
            Spacer(),
            //Sales count
            Container(
              width: MediaQuery.of(context).size.width * 0.15,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: <BoxShadow>[
                  new BoxShadow(
                    color: Colors.grey[350],
                    offset: Offset(0.0, 0.0),
                    blurRadius: 10.0,
                  )
                ],
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //Amount
                    Text(
                      '${stats.totalSalesCount}',
                      style:
                          TextStyle(fontWeight: FontWeight.w900, fontSize: 21),
                    ),
                    SizedBox(height: 10),
                    //Text
                    Text(
                      'No. de Ventas',
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 11,
                          color: Colors.grey),
                    )
                  ]),
            ),
            Spacer(),
            //Products sold
            Container(
              width: MediaQuery.of(context).size.width * 0.15,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: <BoxShadow>[
                  new BoxShadow(
                    color: Colors.grey[350],
                    offset: Offset(0.0, 0.0),
                    blurRadius: 10.0,
                  )
                ],
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //Amount
                    Text(
                      '${stats.totalItemsSold}',
                      style:
                          TextStyle(fontWeight: FontWeight.w900, fontSize: 21),
                    ),
                    SizedBox(height: 10),
                    //Text
                    Text(
                      'Productos Vendidos',
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 11,
                          color: Colors.grey),
                    )
                  ]),
            ),
            Spacer(),
            //Average Sale+
            Container(
              width: MediaQuery.of(context).size.width * 0.15,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: <BoxShadow>[
                  new BoxShadow(
                    color: Colors.grey[350],
                    offset: Offset(0.0, 0.0),
                    blurRadius: 10.0,
                  )
                ],
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //Amount
                    Text(
                      (dayStats != null)
                          ? '${formatCurrency.format((stats.totalSalesCount != 0) ? (stats.sales / stats.totalSalesCount) : 0)}'
                          : '${formatCurrency.format((stats.totalSalesCount != 0) ? (stats.totalSales / stats.totalSalesCount) : 0)}',
                      style:
                          TextStyle(fontWeight: FontWeight.w900, fontSize: 21),
                    ),
                    SizedBox(height: 10),
                    //Text
                    Text(
                      'Promedio por Venta',
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 11,
                          color: Colors.grey),
                    )
                  ]),
            ),
            Spacer(),
          ]),
    );
  }
}
