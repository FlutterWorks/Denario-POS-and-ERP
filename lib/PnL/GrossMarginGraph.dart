import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denario/Models/Stats.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/Categories.dart';

class GrossMarginGraph extends StatefulWidget {
  final String activeBusiness;

  GrossMarginGraph(
    this.activeBusiness,
  );

  @override
  State<StatefulWidget> createState() => GrossMarginGraphState();
}

class GrossMarginGraphState extends State<GrossMarginGraph> {
  final Color leftBarColor = const Color(0xff53fdd7);
  final Color rightBarColor = const Color(0xffff5182);
  final double width = 7;

  int touchedGroupIndex = -1;

  Future currentValue() async {
    var year = DateTime.now().year.toString();
    var month = DateTime.now().month.toString();

    var firestore = FirebaseFirestore.instance;

    var docRef = firestore
        .collection('ERP')
        .doc(widget.activeBusiness)
        .collection(year)
        .doc(month)
        .get();
    return docRef;
  }

  Future currentValuesBuilt;
  double maxAmount = 0;

  List<BarChartGroupData> listOfBarGroups = [];
  @override
  void initState() {
    currentValuesBuilt = currentValue();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesProvider = Provider.of<CategoryList>(context);

    if (categoriesProvider == null) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.6,
        width: double.infinity,
      );
    }

    return FutureBuilder(
        future: currentValuesBuilt,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // for (var x = 0; x < categoriesProvider.categoryList.length; x++) {
            //   var category = categoriesProvider.categoryList[x];
            //   double categorySales = 0;
            //   double categoryCosts = 0;

            //   if (snapshot.data().toString().contains("Ventas de $category")) {
            //     categorySales = snapshot.data["Ventas de $category"];
            //   }
            //   if (snapshot.data().toString().contains("Costos de $category")) {
            //     categoryCosts = snapshot.data["Costos de $category"];
            //   }

            //   //Get Max Amount
            //   if (categorySales > maxAmount) {
            //     maxAmount = categorySales;
            //   }
            //   if (categoryCosts > maxAmount) {
            //     maxAmount = categoryCosts;
            //   }
            //   BarChartGroupData barGroup =
            //       makeGroupData(x, categorySales, categoryCosts);

            //   listOfBarGroups.add(barGroup);
            // }
            // print(categoriesProvider.categoryList.length);

            var lio = Map.from(snapshot.data);

            return Text(lio.toString());

            // return Container(
            //   width: double.infinity,
            //   height: MediaQuery.of(context).size.height * 0.6,
            //   constraints: BoxConstraints(minHeight: 300),
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: BorderRadius.circular(25),
            //     boxShadow: <BoxShadow>[
            //       new BoxShadow(
            //         color: Colors.grey[350],
            //         offset: Offset(0.0, 0.0),
            //         blurRadius: 10.0,
            //       )
            //     ],
            //   ),
            //   child: Center(
            //     child: Container(
            //       width: double.infinity,
            //       height: MediaQuery.of(context).size.height * 0.5,
            //       padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.stretch,
            //         mainAxisAlignment: MainAxisAlignment.start,
            //         mainAxisSize: MainAxisSize.max,
            //         children: <Widget>[
            //           //Title
            //           Text(
            //             'Gross Margin by Category',
            //             style: TextStyle(color: Colors.black, fontSize: 18),
            //           ),
            //           const SizedBox(
            //             height: 38,
            //           ),
            //           //Graph
            //           Expanded(
            //             child: Padding(
            //               padding: const EdgeInsets.symmetric(horizontal: 8.0),
            //               child: BarChart(
            //                 BarChartData(
            //                   maxY: maxAmount,
            //                   gridData: FlGridData(show: false),
            //                   titlesData: FlTitlesData(
            //                     show: true,
            //                     topTitles: AxisTitles(
            //                         sideTitles: SideTitles(showTitles: false)),
            //                     bottomTitles: AxisTitles(
            //                         sideTitles: SideTitles(
            //                       showTitles: true,
            //                       getTitlesWidget: (double value, meta) {
            //                         // Widget text = Text(
            //                         //   categoriesProvider
            //                         //       .categoryList[value.toInt()],
            //                         //   style: const TextStyle(
            //                         //     color: Color(0xff7589a2),
            //                         //     fontWeight: FontWeight.normal,
            //                         //     fontSize: 14,
            //                         //   ),
            //                         // );

            //                         return SideTitleWidget(
            //                             axisSide: meta.axisSide,
            //                             space: 8, //margin top
            //                             child: Text("Linea") //text,
            //                             );
            //                       },
            //                     )),
            //                     rightTitles: AxisTitles(
            //                         sideTitles: SideTitles(showTitles: false)),
            //                   ),
            //                   borderData: FlBorderData(
            //                     show: false,
            //                   ),
            //                   barGroups: listOfBarGroups,
            //                 ),
            //               ),
            //             ),
            //           ),
            //           const SizedBox(
            //             height: 12,
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // );
          } else {
            return Container();
          }
        });
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
