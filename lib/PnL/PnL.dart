import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denario/Loading.dart';
import 'package:denario/Models/Categories.dart';
import 'package:denario/PnL/GrossMarginGraph.dart';
import 'package:denario/PnL/PnLCard.dart';
import 'package:denario/PnL/PnlMargins.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PnL extends StatelessWidget {
  final List? pnlAccountGroups;
  final Map<dynamic, dynamic>? pnlMapping;
  final int? pnlMonth;
  final int? pnlYear;
  final String? activeBusiness;

  PnL(
      {this.pnlAccountGroups,
      this.pnlMapping,
      this.pnlMonth,
      this.pnlYear,
      this.activeBusiness});

  Future currentValue() async {
    var firestore = FirebaseFirestore.instance;

    var docRef = firestore
        .collection('ERP')
        .doc(activeBusiness)
        .collection((pnlYear).toString())
        .doc((pnlMonth).toString())
        .get();
    return docRef;
  }

  // @override
  @override
  Widget build(BuildContext context) {
    final categoriesProvider = Provider.of<CategoryList?>(context);

    if (categoriesProvider == null) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.6,
        width: double.infinity,
      );
    }

    return FutureBuilder(
        future: currentValue(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            double totalVentas;
            double totalCostodeVentas;
            double totalGastosdeEmpleados;
            double totalGastosdelLocal;
            double totalOtrosGastos;

            try {
              totalVentas = snapshot.data['Ventas'];
            } catch (e) {
              totalVentas = 0;
            }
            try {
              totalCostodeVentas = snapshot.data['Costo de Ventas'];
            } catch (e) {
              totalCostodeVentas = 0;
            }
            try {
              totalGastosdeEmpleados = snapshot.data['Gastos de Empleados'];
            } catch (e) {
              totalGastosdeEmpleados = 0;
            }
            try {
              totalGastosdelLocal = snapshot.data['Gastos del Local'];
            } catch (e) {
              totalGastosdelLocal = 0;
            }
            try {
              totalOtrosGastos = snapshot.data['Otros Gastos'];
            } catch (e) {
              totalOtrosGastos = 0;
            }

            final double grossMargin =
                ((totalVentas - totalCostodeVentas) / totalVentas) * 100;
            final double gross = totalVentas - totalCostodeVentas;

            final double operatingMargin = ((totalVentas -
                        totalCostodeVentas -
                        totalGastosdeEmpleados -
                        totalGastosdelLocal) /
                    totalVentas) *
                100;
            final double operating = totalVentas -
                totalCostodeVentas -
                totalGastosdeEmpleados -
                totalGastosdelLocal;

            final double profitMargin = ((totalVentas -
                        totalCostodeVentas -
                        totalGastosdeEmpleados -
                        totalGastosdelLocal -
                        totalOtrosGastos) /
                    totalVentas) *
                100;

            final double profit = totalVentas -
                totalCostodeVentas -
                totalGastosdeEmpleados -
                totalGastosdelLocal -
                totalOtrosGastos;

            return Container(
              width: MediaQuery.of(context).size.width * 0.9,
              child: (MediaQuery.of(context).size.width > 1150)
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                          //Margins and Graphs
                          Expanded(
                            child: Column(
                              children: [
                                PnlMargins(
                                  grossMargin: grossMargin,
                                  gross: gross,
                                  operatingMargin: operatingMargin,
                                  operating: operating,
                                  profitMargin: profitMargin,
                                  profit: profit,
                                  snapshot: snapshot,
                                ),
                                SizedBox(height: 15),
                                GrossMarginGraph(activeBusiness!, snapshot,
                                    categoriesProvider)
                              ],
                            ),
                          ),
                          SizedBox(width: 20),
                          //PnL Card
                          Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: PnLCard(
                                pnlAccountGroups!, pnlMapping!, snapshot),
                          ),
                        ])
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                          //Margins
                          PnlMargins(
                            grossMargin: grossMargin,
                            gross: gross,
                            operatingMargin: operatingMargin,
                            operating: operating,
                            profitMargin: profitMargin,
                            profit: profit,
                            snapshot: snapshot,
                          ),
                          SizedBox(height: 20),
                          //PnL Card
                          PnLCard(pnlAccountGroups!, pnlMapping!, snapshot),
                          SizedBox(height: 20),
                          //Graph
                          GrossMarginGraph(
                              activeBusiness!, snapshot, categoriesProvider)
                        ]),
            );
          } else {
            return Loading();
          }
        });
  }
}
