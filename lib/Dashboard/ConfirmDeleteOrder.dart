import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Models/DailyCash.dart';
import 'package:denario/Models/Sales.dart';
import 'package:flutter/material.dart';

class ConfirmDeleteOrder extends StatefulWidget {
  final String businessID;
  final Sales sale;
  final CashRegister registerStatus;
  final DailyTransactions dailyTransactions;
  const ConfirmDeleteOrder(
      this.businessID, this.sale, this.registerStatus, this.dailyTransactions,
      {Key key})
      : super(key: key);

  @override
  State<ConfirmDeleteOrder> createState() => _ConfirmDeleteOrderState();
}

class _ConfirmDeleteOrderState extends State<ConfirmDeleteOrder> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Container(
        padding: EdgeInsets.all(20),
        height: 200,
        width: 450,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //Title
            Text(
              'Estas apunto de eliminar esta venta ¿Deseas continuar?',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            SizedBox(height: 30),
            //Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Si
                Container(
                  height: 45,
                  child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.greenAccent),
                        overlayColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.hovered))
                              return Colors.grey[300];
                            if (states.contains(MaterialState.focused) ||
                                states.contains(MaterialState.pressed))
                              return Colors.grey[300];
                            return null; // Defer to the widget's default.
                          },
                        ),
                      ),
                      onPressed: () async {
                        //Date variables
                        var year = DateTime.now().year.toString();
                        var month = DateTime.now().month.toString();

                        // ////////////////////////Update Accounts (sales and categories)

                        //Firestore reference
                        var firestore = FirebaseFirestore.instance;
                        var docRef = firestore
                            .collection('ERP')
                            .doc(widget.businessID)
                            .collection(widget.sale.date.year.toString())
                            .doc(widget.sale.date.month.toString());

                        final doc = await docRef.get();

                        try {
                          if (doc.exists) {
                            docRef.update({
                              'Ventas': FieldValue.increment(
                                  -widget.sale.total.toDouble())
                            });
                          }
                        } catch (error) {
                          print('Error updating Total Sales Value: $error');
                        }

                        List<Map> items = [];

                        for (var i = 0; i < widget.sale.soldItems.length; i++) {
                          items.add({
                            'Name': widget.sale.soldItems[i].product,
                            'Category': widget.sale.soldItems[i].category,
                            'Price': widget.sale.soldItems[i].price,
                            'Quantity': widget.sale.soldItems[i].qty,
                            'Total Price': widget.sale.soldItems[i].total
                          });
                        }

                        //Record in sales list as negative
                        DatabaseService().markSaleReversed(
                            widget.businessID, widget.sale.docID);
                        //Create Sale negative
                        DatabaseService().createOrder(
                            widget.businessID,
                            DateTime.now().toString(),
                            year,
                            month,
                            DateTime.now(),
                            widget.sale.subTotal * -1,
                            widget.sale.discount,
                            widget.sale.tax,
                            widget.sale.total * -1,
                            items,
                            'Reversa de ' + widget.sale.transactionID,
                            widget.sale.paymentType,
                            widget.sale.orderName,
                            widget.sale.clientDetails,
                            widget.sale.transactionID + '-1',
                            widget.sale.cashRegister,
                            true,
                            widget.sale.splitPaymentDetails,
                            widget.sale.orderType);

                        /////Save Sales and Order Categories to database
                        ////////Update each Account for the month based on order's categories
                        Map orderCategories = {};

                        //Logic to retrieve and add up categories totals
                        for (var i = 0; i < items.length; i++) {
                          //Check if the map contains the key
                          if (orderCategories.containsKey(
                              'Ventas de ${items[i]["Category"]}')) {
                            //Add to existing category amount
                            orderCategories.update(
                                'Ventas de ${items[i]["Category"]}',
                                (value) =>
                                    value +
                                    (items[i]["Price"] * items[i]["Quantity"]));
                          } else {
                            //Add new category with amount
                            orderCategories[
                                    'Ventas de ${items[i]["Category"]}'] =
                                items[i]["Price"] * items[i]["Quantity"];
                          }
                        }
                        ////Logic to add Sales by Categories to Firebase based on current Values from snap
                        orderCategories.forEach((k, v) {
                          docRef.update({k: FieldValue.increment(-v)});
                        });

                        //If it was on current register, substract from payment method
                        //If it was cash, substract amount from register
                        ///////////////////////////Register in Daily Transactions/////

                        ///////////////////////// MONTH STATS ///////////////////////////
                        ///

                        //Increment stats
                        var monthStatsRef = firestore
                            .collection('ERP')
                            .doc(widget.businessID)
                            .collection(year)
                            .doc(month)
                            .collection('Stats')
                            .doc('Monthly Stats');

                        //Update STATS for MONTH
                        try {
                          final monthStatsdoc = await monthStatsRef.get();

                          if (monthStatsdoc.exists) {
                            //MONTHLY Stats
                            if (widget.sale.paymentType != 'Split') {
                              monthStatsRef.update({
                                'Total Sales Count': FieldValue.increment(-1),
                                'Total Sales':
                                    FieldValue.increment(-widget.sale.total),
                                'Total Items Sold':
                                    FieldValue.increment(-items.length),
                                'Sales by Order Type.${widget.sale.orderType}':
                                    FieldValue.increment(-widget.sale.total),
                                'Sales by Payment Type.${widget.sale.paymentType}':
                                    FieldValue.increment(-widget.sale.total),
                              });
                            } else {
                              monthStatsRef.update({
                                'Total Sales Count': FieldValue.increment(-1),
                                'Total Sales':
                                    FieldValue.increment(-widget.sale.total),
                                'Total Items Sold':
                                    FieldValue.increment(-items.length),
                                'Sales by Order Type.${widget.sale.orderType}':
                                    FieldValue.increment(-widget.sale.total),
                              });
                              for (var x in widget.sale.splitPaymentDetails) {
                                monthStatsRef.update({
                                  'Sales by Payment Type.${x['Type']}':
                                      FieldValue.increment(-(x['Amount'])),
                                });
                              }
                            }

                            //MONTHLY Stats By PRODUCTS and CATEGORIES'
                            for (var i = 0; i < items.length; i++) {
                              monthStatsRef.update({
                                'Sales Amount by Product.${items[i]["Name"]}':
                                    FieldValue.increment(-(items[i]["Price"] *
                                        items[i]["Quantity"])),
                                'Sales Count by Product.${items[i]["Name"]}':
                                    FieldValue.increment(
                                        -(items[i]["Quantity"])),
                                'Sales Amount by Category.${items[i]["Category"]}':
                                    FieldValue.increment(-(items[i]["Price"] *
                                        items[i]["Quantity"])),
                                'Sales Count by Category.${items[i]["Category"]}':
                                    FieldValue.increment(
                                        -(items[i]["Quantity"])),
                              });
                            }
                          } else {
                            Map<String, dynamic> orderStats = {
                              'Total Sales Count': 0,
                              'Total Sales': 0,
                              'Total Items Sold': 0,
                              'Sales by Order Type': {},
                              'Sales by Payment Type': {},
                              'Sales Amount by Product': {},
                              'Sales Count by Product': {},
                              'Sales Amount by Category': {},
                              'Sales Count by Category': {}
                            };

                            orderStats['Total Sales Count'] = 0;
                            orderStats['Total Sales'] = -widget.sale.total;
                            orderStats['Total Items Sold'] = -items.length;
                            orderStats['Sales by Order Type'] = {
                              widget.sale.orderType: -widget.sale.total
                            };
                            orderStats['Sales by Payment Type'] = {
                              widget.sale.paymentType: -widget.sale.total
                            };

                            //Add list of payment types to the Map
                            // for (var x in splitPaymentDetails) {
                            //   orderStats['Sales by Payment Type']
                            //       ['${x['Type']}'] = x['Amount'];
                            // }

                            //Add product and categories stats
                            for (var i = 0; i < items.length; i++) {
                              //Product Amounts
                              orderStats['Sales Amount by Product']
                                      ['${items[i]["Name"]}'] =
                                  (orderStats['Sales Amount by Product']
                                              ['${items[i]["Name"]}'] ??
                                          0) -
                                      (items[i]["Price"] *
                                          items[i]["Quantity"]);
                              //Products Count
                              orderStats['Sales Count by Product']
                                      ['${items[i]["Name"]}'] =
                                  (orderStats['Sales Count by Product']
                                              ['${items[i]["Name"]}'] ??
                                          0) -
                                      items[i]["Quantity"];
                              //Categories Amount
                              orderStats['Sales Amount by Category']
                                      ['${items[i]["Category"]}'] =
                                  (orderStats['Sales Amount by Category']
                                              ['${items[i]["Category"]}'] ??
                                          0) -
                                      (items[i]["Price"] *
                                          items[i]["Quantity"]);
                              //Categories Count
                              orderStats['Sales Count by Category']
                                      ['${items[i]["Category"]}'] =
                                  (orderStats['Sales Count by Category']
                                              ['${items[i]["Category"]}'] ??
                                          0) -
                                      items[i]["Quantity"];
                            }

                            await monthStatsRef.set(orderStats);
                          }
                        } catch (error) {
                          print('Error updating Monthly Stats: $error');
                        }

                        ///////////////////////// DAILY STATS ///////////////////////////
                        ///
                        ///Increment stats
                        var dayStatsRef = firestore
                            .collection('ERP')
                            .doc(widget.businessID)
                            .collection(year)
                            .doc(month)
                            .collection('Daily')
                            .doc(widget.sale.cashRegister);

                        //Update STATS for DAY
                        try {
                          final dayStatsdoc = await dayStatsRef.get();

                          if (dayStatsdoc.exists) {
                            //DAILY Stats
                            if (widget.sale.paymentType != 'Split') {
                              dayStatsRef.update({
                                'Total Sales Count': FieldValue.increment(-1),
                                'Ventas':
                                    FieldValue.increment(-widget.sale.total),
                                'Transacciones del Día':
                                    FieldValue.increment(-widget.sale.total),
                                'Total Items Sold':
                                    FieldValue.increment(-items.length),
                                'Sales by Order Type.${widget.sale.orderType}':
                                    FieldValue.increment(-widget.sale.total),
                                'Ventas por Medio.${widget.sale.paymentType}':
                                    FieldValue.increment(-widget.sale.total),
                              });
                            } else {
                              dayStatsRef.update({
                                'Total Sales Count': FieldValue.increment(-1),
                                'Ventas':
                                    FieldValue.increment(-widget.sale.total),
                                'Transacciones del Día':
                                    FieldValue.increment(-widget.sale.total),
                                'Total Items Sold':
                                    FieldValue.increment(-items.length),
                                'Sales by Order Type.${widget.sale.orderType}':
                                    FieldValue.increment(-widget.sale.total),
                              });
                              for (var x in widget.sale.splitPaymentDetails) {
                                monthStatsRef.update({
                                  'Ventas por Medio.${x['Type']}':
                                      FieldValue.increment(-(x['Amount'])),
                                });
                              }
                            }
                            //DAILY Stats By PRODUCTS and CATEGORIES'
                            for (var i = 0; i < items.length; i++) {
                              dayStatsRef.update({
                                'Sales Amount by Product.${items[i]["Name"]}':
                                    FieldValue.increment(-(items[i]["Price"] *
                                        items[i]["Quantity"])),
                                'Sales Count by Product.${items[i]["Name"]}':
                                    FieldValue.increment(-items[i]["Quantity"]),
                                'Sales Amount by Category.${items[i]["Category"]}':
                                    FieldValue.increment(-(items[i]["Price"] *
                                        items[i]["Quantity"])),
                                'Sales Count by Category.${items[i]["Category"]}':
                                    FieldValue.increment(-items[i]["Quantity"]),
                              });
                            }
                          }
                        } catch (error) {
                          print('Error updating Daily Stats: $error');
                        }

                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            child: Text(
                              'Eliminar venta',
                              style: TextStyle(color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      )),
                ),
                SizedBox(width: 25),
                //No
                Container(
                  height: 45,
                  child: OutlinedButton(
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.hovered))
                              return Colors.grey[300];
                            if (states.contains(MaterialState.focused) ||
                                states.contains(MaterialState.pressed))
                              return Colors.grey[300];
                            return null; // Defer to the widget's default.
                          },
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            child: Text(
                              'Volver',
                              style: TextStyle(color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      )),
                )
              ],
            )
          ],
        ),
      ),
    ));
  }
}
