import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denario/PnL/GrossMarginGraph.dart';
import 'package:denario/PnL/PnLCard.dart';
import 'package:denario/PnL/PnlMargins.dart';
import 'package:flutter/material.dart';

class PnL extends StatefulWidget {
  final List pnlAccountGroups;
  final Map<dynamic, dynamic> pnlMapping;
  final int pnlMonth;
  final int pnlYear;
  final String activeBusiness;

  PnL(
      {this.pnlAccountGroups,
      this.pnlMapping,
      this.pnlMonth,
      this.pnlYear,
      this.activeBusiness});

  @override
  State<PnL> createState() => _PnLState();
}

class _PnLState extends State<PnL> {
//   @override
  Future currentValue() async {
    var firestore = FirebaseFirestore.instance;

    var docRef = firestore
        .collection('ERP')
        .doc(widget.activeBusiness)
        .collection((widget.pnlYear).toString())
        .doc((widget.pnlMonth).toString())
        .get();
    return docRef;
  }

  Future currentValuesBuilt;

  double cafeVentas;
  double cafeCostos;
  double postresVentas;
  double postresCostos;
  double panVentas;
  double panCostos;
  double platosVentas;
  double platosCostos;
  double bebidasVentas;
  double bebidasCostos;
  double promosVentas;
  double otrosCostos;

  @override
  void initState() {
    currentValuesBuilt = currentValue();
    super.initState();
  }

  // @override
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: currentValuesBuilt,
        builder: (context, snapshot) {
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

            try {
              cafeVentas = snapshot.data['Ventas de Café'];
            } catch (e) {
              cafeVentas = 0;
            }
            try {
              cafeCostos = snapshot.data['Costos de Café'];
            } catch (e) {
              cafeCostos = 0;
            }
            try {
              postresVentas = snapshot.data['Ventas de Postres'];
            } catch (e) {
              postresVentas = 0;
            }
            try {
              postresCostos = snapshot.data['Costos de Postres'];
            } catch (e) {
              postresCostos = 0;
            }
            try {
              panVentas = snapshot.data['Ventas de Panadería'];
            } catch (e) {
              panVentas = 0;
            }
            try {
              panCostos = snapshot.data['Costos de Panadería'];
            } catch (e) {
              panCostos = 0;
            }
            try {
              platosVentas = snapshot.data['Ventas de Platos'];
            } catch (e) {
              platosVentas = 0;
            }
            try {
              platosCostos = snapshot.data['Costos de Platos'];
            } catch (e) {
              platosCostos = 0;
            }
            try {
              bebidasVentas = snapshot.data['Ventas de Bebidas'];
            } catch (e) {
              bebidasVentas = 0;
            }
            try {
              bebidasCostos = snapshot.data['Costos de Bebidas'];
            } catch (e) {
              bebidasCostos = 0;
            }
            try {
              promosVentas = snapshot.data['Ventas de Promos'];
            } catch (e) {
              promosVentas = 0;
            }
            try {
              otrosCostos = snapshot.data['Otros Costos'];
            } catch (e) {
              otrosCostos = 0;
            }

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
                                GrossMarginGraph(widget.activeBusiness)
                              ],
                            ),
                          ),
                          SizedBox(width: 20),
                          //PnL Card
                          Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: PnLCard(widget.pnlAccountGroups,
                                widget.pnlMapping, snapshot),
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
                          PnLCard(widget.pnlAccountGroups, widget.pnlMapping,
                              snapshot),
                          SizedBox(height: 20),
                          //Graph
                          GrossMarginGraph(
                            widget.activeBusiness,
                          )
                        ]),
            );
          } else {
            return Center();
          }
        });
  }
}
