import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PnLSummary extends StatefulWidget {
  final String activeBusiness;
  const PnLSummary(this.activeBusiness, {Key? key}) : super(key: key);

  @override
  State<PnLSummary> createState() => _PnLSummaryState();
}

class _PnLSummaryState extends State<PnLSummary> {
  final formatCurrency = new NumberFormat.simpleCurrency();
  Future currentValue() async {
    var firestore = FirebaseFirestore.instance;

    var docRef = firestore
        .collection('ERP')
        .doc(widget.activeBusiness)
        .collection((DateTime.now().year).toString())
        .doc((DateTime.now().month).toString())
        .get();
    return docRef;
  }

  late Future currentValuesBuilt;

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
  void initState() {
    currentValuesBuilt = currentValue();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: currentValuesBuilt,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            double totalVentas;
            double totalCostos;
            double totalCostodeVentas;
            double totalGastosdeEmpleados;
            double totalGastosdelLocal;
            double totalOtrosGastos;
            bool surplus;

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

            totalCostos = totalCostodeVentas +
                totalGastosdelLocal +
                totalGastosdeEmpleados +
                totalOtrosGastos;

            if (totalVentas > totalCostos) {
              surplus = true;
            } else {
              surplus = false;
            }

            return Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: <BoxShadow>[
                  new BoxShadow(
                    color: Colors.grey[350]!,
                    offset: new Offset(0, 0),
                    blurRadius: 10.0,
                  )
                ],
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Title
                    Text(
                      'Balance de este mes',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 12,
                          color: Colors.grey),
                    ),
                    SizedBox(height: 15),
                    //Amount
                    Text(
                      '${formatCurrency.format(totalVentas - totalCostos)}',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 24,
                          color: Colors.black),
                    ),
                    SizedBox(height: 20),
                    //Ventas/Gastos
                    Expanded(
                      child: Container(
                        child: LayoutBuilder(builder:
                            (BuildContext context, BoxConstraints constraints) {
                          double maxWidth = constraints.maxWidth;
                          return Column(
                            children: [
                              //Sales
                              Container(
                                height: 35,
                                width: maxWidth,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    //Text
                                    Column(
                                      children: [
                                        Container(
                                          height: 15,
                                          width: 50,
                                          child: Text(
                                            'Ventas ',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                fontSize: 14,
                                                color: Colors.black),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 2,
                                        ),
                                        Container(
                                          height: 15,
                                          width: 50,
                                          child: Text(
                                            abbreviateCurrency(totalVentas),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                fontSize: 12,
                                                color: Colors.grey),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 10),
                                    //Graph
                                    Container(
                                      width: surplus
                                          ? maxWidth * 0.8
                                          : (maxWidth *
                                                      ((totalVentas /
                                                              totalCostos) -
                                                          0.2) >
                                                  0)
                                              ? maxWidth *
                                                  ((totalVentas / totalCostos) -
                                                      0.2)
                                              : 5,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: Colors.greenAccent,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(height: 15),
                              //Expenses
                              Container(
                                height: 35,
                                width: maxWidth,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    //Text
                                    Column(
                                      children: [
                                        Container(
                                          height: 15,
                                          width: 50,
                                          child: Text(
                                            'Gastos ',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                fontSize: 14,
                                                color: Colors.black),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 2,
                                        ),
                                        Container(
                                          height: 15,
                                          width: 50,
                                          child: Text(
                                            abbreviateCurrency(totalCostos),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                fontSize: 12,
                                                color: Colors.grey),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 10),
                                    //Graph
                                    Container(
                                      width: !surplus
                                          ? maxWidth * 0.8
                                          : (maxWidth *
                                                      ((totalCostos /
                                                              totalVentas) -
                                                          0.2) >
                                                  0)
                                              ? maxWidth *
                                                  ((totalCostos / totalVentas) -
                                                      0.2)
                                              : 5,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),

                    // SizedBox(height: 10),
                    // //Gastos
                    // Container(
                    //   height: 35,
                    //   width: double.infinity,
                    //   child: Row(
                    //     children: [
                    //       //Text
                    //       Text(
                    //         'Gastos ',
                    //         textAlign: TextAlign.left,
                    //         style: TextStyle(
                    //             fontWeight: FontWeight.w300,
                    //             fontSize: 14,
                    //             color: Colors.black),
                    //       ),
                    //       SizedBox(width: 10),
                    //       //Graph
                    //       Tooltip(
                    //         message: 'No',
                    //         //'${formatCurrency.format('$totalCostos')}',
                    //         child: Container(
                    //           width: surplus ? 2 : double.infinity,
                    //           height: 3.5,
                    //           decoration: BoxDecoration(
                    //             color: Colors.redAccent,
                    //             borderRadius: BorderRadius.circular(25),
                    //           ),
                    //         ),
                    //       )
                    //     ],
                    //   ),
                    // ),
                  ]),
            );
          } else {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: <BoxShadow>[
                  new BoxShadow(
                    color: Colors.grey[350]!,
                    offset: new Offset(0, 0),
                    blurRadius: 10.0,
                  )
                ],
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Title
                    Text(
                      'Balance de este mes',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 12,
                          color: Colors.grey),
                    ),
                    SizedBox(height: 15),
                    //PnL
                    Expanded(
                      child: Container(child: Center()),
                    )
                  ]),
            );
          }
        });
  }
}
