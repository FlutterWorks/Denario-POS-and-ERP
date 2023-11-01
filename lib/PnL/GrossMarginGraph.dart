import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Models/Categories.dart';

class GrossMarginGraph extends StatefulWidget {
  final String activeBusiness;
  final AsyncSnapshot snapshot;
  final CategoryList categoryList;

  GrossMarginGraph(this.activeBusiness, this.snapshot, this.categoryList);

  @override
  State<StatefulWidget> createState() => GrossMarginGraphState();
}

class GrossMarginGraphState extends State<GrossMarginGraph> {
  final Color leftBarColor = const Color(0xff53fdd7);
  final Color rightBarColor = const Color(0xffff5182);
  final double width = 7;

  int touchedGroupIndex = -1;

  double maxAmount = 0;
  List<BarChartGroupData> listOfBarGroups = [];
  AsyncSnapshot? snapshot;
  List? categoryList;
  final formatCurrency = new NumberFormat.simpleCurrency(decimalDigits: 0);

  String abbreviateCurrency(double? amount) {
    if (amount == null) {
      return formatCurrency.format(0);
    } else if (amount >= 1.0e9) {
      return '\$${(amount / 1.0e9).toStringAsFixed(0)}B';
    } else if (amount >= 1.0e6) {
      return '\$${(amount / 1.0e6).toStringAsFixed(0)}M';
    } else if (amount >= 1.0e5) {
      return '\$${(amount / 1.0e3).toStringAsFixed(0)}K';
    } else if (amount >= 1.0e3) {
      return '\$${(amount / 1.0e3).toStringAsFixed(0)}K';
    } else {
      return formatCurrency.format(amount);
    }
  }

  @override
  void initState() {
    snapshot = widget.snapshot;
    categoryList = widget.categoryList.categoryList;

    for (var x = 0; x < categoryList!.length; x++) {
      var category = categoryList![x];
      double categorySales;
      double categoryCosts;

      try {
        categorySales = snapshot!.data["Ventas de $category"];
      } catch (e) {
        categorySales = 0;
      }

      try {
        categoryCosts = snapshot!.data["Costos de $category"];
      } catch (e) {
        categoryCosts = 0;
      }

      //Get Max Amount
      if (categorySales > maxAmount) {
        maxAmount = categorySales;
      }
      if (categoryCosts > maxAmount) {
        maxAmount = categoryCosts;
      }
      BarChartGroupData barGroup =
          makeGroupData(x, categorySales, categoryCosts);

      listOfBarGroups.add(barGroup);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.6,
      constraints: BoxConstraints(minHeight: 300),
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
      child: Center(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.5,
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              //Title
              Text(
                'Margen por Categoría',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
              const SizedBox(
                height: 38,
              ),
              //Graph
              Expanded(
                child: BarChart(
                  BarChartData(
                    maxY: maxAmount,
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, meta) {
                          Widget text = Text(
                            categoryList![value.toInt()],
                            style: const TextStyle(
                              color: Color(0xff7589a2),
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                            ),
                          );

                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 8, //margin top
                            child: text,
                            angle: (MediaQuery.of(context).size.width > 900)
                                ? 0.0
                                : -0.65,
                          );
                        },
                      )),
                      leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, meta) {
                          Widget text = Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              abbreviateCurrency(value),
                              style: const TextStyle(
                                color: Color(0xff7589a2),
                                fontWeight: FontWeight.normal,
                                fontSize: 11,
                              ),
                            ),
                          );

                          return SideTitleWidget(
                            axisSide: AxisSide.top,
                            space: 8, //margin top
                            child: text,
                          );
                        },
                      )),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    barGroups: listOfBarGroups,
                  ),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(barsSpace: 4, x: x, barRods: [
      BarChartRodData(
        toY: y1,
        color: leftBarColor,
        width: width,
      ),
      BarChartRodData(
        toY: y2,
        color: rightBarColor,
        width: width,
      ),
    ]);
  }
}
