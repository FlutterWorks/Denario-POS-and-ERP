import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Dashboard/ConfirmDeleteOrder.dart';
import 'package:denario/Models/DailyCash.dart';
import 'package:denario/Models/Receivables.dart';
import 'package:denario/Models/Sales.dart';
import 'package:denario/Models/Stats.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SingleReceivableDialog extends StatefulWidget {
  final Receivables sale;
  final String businessID;
  final String docID;
  final List paymentTypes;
  final CashRegister registerStatus;

  SingleReceivableDialog(this.sale, this.businessID, this.docID,
      this.paymentTypes, this.registerStatus);

  @override
  _SingleReceivableDialogState createState() => _SingleReceivableDialogState();
}

class _SingleReceivableDialogState extends State<SingleReceivableDialog> {
  final formatCurrency = new NumberFormat.simpleCurrency();
  bool editMethod = false;
  bool paymentMethodEdited = false;
  String paymentType;
  List availablePaymentTypes = [];

  @override
  void initState() {
    paymentType = 'Por Cobrar';
    widget.paymentTypes.forEach((x) => availablePaymentTypes.add(x['Type']));
    availablePaymentTypes.add('Por Cobrar');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Container(
          width: (MediaQuery.of(context).size.width > 800)
              ? MediaQuery.of(context).size.width * 0.4
              : MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.7,
          constraints: BoxConstraints(minHeight: 350, minWidth: 300),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Close
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                    iconSize: 20.0),
              ),
              SizedBox(height: 15),
              //Time and Name
              Container(
                width: double.infinity,
                child: Row(
                  children: [
                    //Time and date
                    Container(
                        child: Text(
                      DateFormat.MMMd()
                              .format(widget.sale.savedDate)
                              .toString() +
                          " - " +
                          DateFormat('HH:mm:ss')
                              .format(widget.sale.savedDate)
                              .toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                      ),
                    )),
                    Spacer(),
                    //Name
                    Container(
                        child: Text(
                      (widget.sale.orderName == '')
                          ? 'Nombre sin agregar'
                          : widget.sale.orderName,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                      ),
                    )),
                  ],
                ),
              ),
              SizedBox(height: 20),
              //Ticket
              Container(
                  child: Text(
                'Ticket',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              )),
              SizedBox(height: 20),
              Expanded(
                child: Container(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.sale.orderDetail.length,
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 5.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                //Name
                                Container(
                                  constraints: BoxConstraints(maxWidth: 250),
                                  child: Text((widget.sale.orderDetail[i].qty ==
                                          1)
                                      ? widget.sale.orderDetail[i].product
                                      : widget.sale.orderDetail[i].product +
                                          ' (${formatCurrency.format(widget.sale.orderDetail[i].price)} x ${widget.sale.orderDetail[i].qty})'),
                                ),
                                //Amount
                                Spacer(),
                                Text(
                                    '${formatCurrency.format(widget.sale.orderDetail[i].total)}'),
                              ]),
                        );
                      }),
                ),
              ),
              //Payment Method
              SizedBox(height: 15),
              (!editMethod)
                  ? Container(
                      height: 50,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              editMethod = true;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            child: Center(
                              child: Text('Marcar cobrado'),
                            ),
                          )),
                    )
                  : Container(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          //Payment Method
                          Container(
                              width: 200,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: DropdownButton(
                                isExpanded: true,
                                underline: SizedBox(),
                                hint: Text(
                                  paymentType,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: Colors.grey[700]),
                                ),
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Colors.grey[700]),
                                value: paymentType,
                                items: availablePaymentTypes.map((x) {
                                  return new DropdownMenuItem(
                                    value: x,
                                    child: new Text(x),
                                    onTap: () {
                                      setState(() {
                                        paymentType = x;
                                        paymentMethodEdited = true;
                                      });
                                    },
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    paymentType = newValue;
                                    paymentMethodEdited = true;
                                  });
                                },
                              )),
                          SizedBox(width: 5),
                          (editMethod)
                              ? TextButton(
                                  onPressed: (() {
                                    setState(() {
                                      editMethod = false;
                                      paymentMethodEdited = false;
                                    });
                                  }),
                                  child: Text(
                                    'Dejar de Editar',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ))
                              : IconButton(
                                  onPressed: () {
                                    setState(() {
                                      editMethod = true;
                                    });
                                    // DatabaseService().editSalePaymentMethod(
                                    //     widget.businessID, widget.docID, '');
                                  },
                                  icon: Icon(Icons.edit, size: 16),
                                  splashRadius: 18,
                                ),
                          Spacer(),
                          //Total
                          Container(
                              child: Text(
                            '${formatCurrency.format(widget.sale.total)}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          )),
                        ],
                      ),
                    ),

              //Save new payment method
              (paymentMethodEdited) ? SizedBox(height: 15) : SizedBox(),
              (paymentMethodEdited)
                  ? Container(
                      height: 45,
                      child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.greenAccent),
                            overlayColor:
                                MaterialStateProperty.resolveWith<Color>(
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
                            DatabaseService().editSalePaymentMethod(
                                widget.businessID,
                                widget.sale.savedDate.year,
                                widget.sale.savedDate.month,
                                widget.docID,
                                paymentType);

                            //// IF RECEIVABLE, CHANGE IN BOTH COLLECTIONS
                            DatabaseService().paidReceivable(
                                widget.businessID, widget.docID);

                            ///////////////////////////Register in Daily Transactions/////
                            if (widget.registerStatus.registerName != null &&
                                widget.registerStatus.registerName != '' &&
                                widget.sale.cashRegister ==
                                    widget.registerStatus.registerName) {
                              //Substract previus payment type // Add new
                              var firestore = FirebaseFirestore.instance;
                              var dayStatsRef = firestore
                                  .collection('ERP')
                                  .doc(widget.businessID)
                                  .collection(
                                      widget.sale.savedDate.year.toString())
                                  .doc(widget.sale.savedDate.month.toString())
                                  .collection('Daily')
                                  .doc(widget.sale.cashRegister);

                              final doc = await dayStatsRef.get();

                              try {
                                if (doc.exists) {
                                  dayStatsRef.update({
                                    'Ventas por Medio.$paymentType':
                                        FieldValue.increment(widget.sale.total),
                                  });
                                }
                              } catch (error) {
                                print(
                                    'Error updating Total Sales Value: $error');
                              }
                            }

                            //Register in Monthly Stats
                            //Substract previus payment type // Add new
                            var firestore = FirebaseFirestore.instance;
                            var monthStatsRef = firestore
                                .collection('ERP')
                                .doc(widget.businessID)
                                .collection(
                                    widget.sale.savedDate.year.toString())
                                .doc(widget.sale.savedDate.month.toString())
                                .collection('Stats')
                                .doc('Monthly Stats');

                            final doc = await monthStatsRef.get();

                            try {
                              if (doc.exists) {
                                monthStatsRef.update({
                                  'Sales by Payment Type.$paymentType':
                                      FieldValue.increment(widget.sale.total),
                                });
                              }
                            } catch (error) {
                              print('Error updating Total Sales Value: $error');
                            }

                            Navigator.of(context).pop();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 5),
                                child: Text(
                                  'Guardar cambios',
                                  style: TextStyle(color: Colors.black),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          )),
                    )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
