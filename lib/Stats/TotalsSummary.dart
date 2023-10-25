import 'package:denario/Models/DailyCash.dart';
import 'package:denario/Models/Stats.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TotalsSummary extends StatelessWidget {
  final DailyTransactions? dayStats;
  final MonthlyStats? monthlyStats;
  TotalsSummary({this.dayStats, this.monthlyStats, Key? key}) : super(key: key);

  final formatCurrency = new NumberFormat.simpleCurrency();
  String abbreviateCurrency(double amount) {
    if (amount >= 1.0e9) {
      return '\$${(amount / 1.0e9).toStringAsFixed(1)}B';
    } else if (amount >= 1.0e6) {
      return '\$${(amount / 1.0e6).toStringAsFixed(1)}M';
    } else if (amount >= 1.0e5) {
      return '\$${(amount / 1.0e3).toStringAsFixed(1)}K';
    } else {
      return formatCurrency.format(amount);
    }
  }

  @override
  Widget build(BuildContext context) {
    var stats;
    stats = dayStats ?? monthlyStats ?? {};

    if (MediaQuery.of(context).size.width > 950) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: 75,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //Total Sales
              Container(
                width: MediaQuery.of(context).size.width * 0.17,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: <BoxShadow>[
                    new BoxShadow(
                      color: Colors.grey[350]!,
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
                            ? abbreviateCurrency(stats.sales)
                            : abbreviateCurrency(stats.totalSales),
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 21),
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
                width: MediaQuery.of(context).size.width * 0.17,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: <BoxShadow>[
                    new BoxShadow(
                      color: Colors.grey[350]!,
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
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 21),
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
                width: MediaQuery.of(context).size.width * 0.17,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: <BoxShadow>[
                    new BoxShadow(
                      color: Colors.grey[350]!,
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
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 21),
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
                width: MediaQuery.of(context).size.width * 0.17,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: <BoxShadow>[
                    new BoxShadow(
                      color: Colors.grey[350]!,
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
                            ? abbreviateCurrency((stats.totalSalesCount != 0)
                                ? (stats.sales / stats.totalSalesCount)
                                : 0)
                            : abbreviateCurrency((stats.totalSalesCount != 0)
                                ? (stats.totalSales / stats.totalSalesCount)
                                : 0),
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 21),
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
    } else if (MediaQuery.of(context).size.width > 650) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: 200,
        child: Column(
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //Total Sales
                  Container(
                    width: 200,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: <BoxShadow>[
                        new BoxShadow(
                          color: Colors.grey[350]!,
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
                                ? abbreviateCurrency(stats.sales)
                                : abbreviateCurrency(stats.totalSales),
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 25),
                          ),
                          SizedBox(height: 10),
                          //Text
                          Text(
                            'Ingresos por Ventas',
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: Colors.grey),
                          )
                        ]),
                  ),
                  SizedBox(width: 20),
                  //Sales count
                  Container(
                    width: 200,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: <BoxShadow>[
                        new BoxShadow(
                          color: Colors.grey[350]!,
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
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 25),
                          ),
                          SizedBox(height: 10),
                          //Text
                          Text(
                            'No. de Ventas',
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: Colors.grey),
                          )
                        ]),
                  ),
                ]),
            SizedBox(height: 15),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //Products sold
                  Container(
                    width: 200,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: <BoxShadow>[
                        new BoxShadow(
                          color: Colors.grey[350]!,
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
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 25),
                          ),
                          SizedBox(height: 10),
                          //Text
                          Text(
                            'Productos Vendidos',
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: Colors.grey),
                          )
                        ]),
                  ),
                  SizedBox(width: 20),
                  //Average Sale
                  Container(
                    width: 200,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: <BoxShadow>[
                        new BoxShadow(
                          color: Colors.grey[350]!,
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
                                  ? abbreviateCurrency((stats.totalSalesCount !=
                                          0)
                                      ? (stats.sales / stats.totalSalesCount)
                                      : 0)
                                  : abbreviateCurrency(
                                      (stats.totalSalesCount != 0)
                                          ? (stats.totalSales /
                                              stats.totalSalesCount)
                                          : 0),
                              style: TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 25)),
                          SizedBox(height: 10),
                          //Text
                          Text(
                            'Promedio por Venta',
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: Colors.grey),
                          )
                        ]),
                  ),
                ]),
          ],
        ),
      );
    } else {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: 200,
        child: Column(
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //Total Sales
                  Expanded(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: <BoxShadow>[
                          new BoxShadow(
                            color: Colors.grey[350]!,
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
                                  ? abbreviateCurrency(stats.sales)
                                  : abbreviateCurrency(stats.totalSales),
                              style: TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 21),
                            ),
                            SizedBox(height: 10),
                            //Text
                            Text(
                              'Ingresos por Ventas',
                              maxLines: 2,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Colors.grey),
                            )
                          ]),
                    ),
                  ),
                  SizedBox(width: 20),
                  //Sales count
                  Expanded(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: <BoxShadow>[
                          new BoxShadow(
                            color: Colors.grey[350]!,
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
                              style: TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 21),
                            ),
                            SizedBox(height: 10),
                            //Text
                            Text(
                              'No. de Ventas',
                              maxLines: 2,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Colors.grey),
                            )
                          ]),
                    ),
                  ),
                ]),
            SizedBox(height: 15),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //Products sold
                  Expanded(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: <BoxShadow>[
                          new BoxShadow(
                            color: Colors.grey[350]!,
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
                              style: TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 21),
                            ),
                            SizedBox(height: 10),
                            //Text
                            Text(
                              'Productos Vendidos',
                              maxLines: 2,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Colors.grey),
                            )
                          ]),
                    ),
                  ),
                  SizedBox(width: 20),
                  //Average Sale
                  Expanded(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: <BoxShadow>[
                          new BoxShadow(
                            color: Colors.grey[350]!,
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
                                    ? abbreviateCurrency((stats
                                                .totalSalesCount !=
                                            0)
                                        ? (stats.sales / stats.totalSalesCount)
                                        : 0)
                                    : abbreviateCurrency(
                                        (stats.totalSalesCount != 0)
                                            ? (stats.totalSales /
                                                stats.totalSalesCount)
                                            : 0),
                                style: TextStyle(
                                    fontWeight: FontWeight.w900, fontSize: 21)),
                            SizedBox(height: 10),
                            //Text
                            Text(
                              'Promedio por Venta',
                              maxLines: 2,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Colors.grey),
                            )
                          ]),
                    ),
                  ),
                ]),
          ],
        ),
      );
    }
  }
}
