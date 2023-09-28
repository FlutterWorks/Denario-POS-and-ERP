import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Backend/Ticket.dart';
import 'package:denario/Models/DailyCash.dart';
import 'package:denario/Models/ScheduledSales.dart';
import 'package:denario/Models/Stats.dart';
import 'package:denario/Models/User.dart';
import 'package:denario/POS/ConfirmOrder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:provider/provider.dart';

class SingleScheduledDialog extends StatefulWidget {
  final ScheduledSales order;
  final String businessID;

  SingleScheduledDialog({this.order, this.businessID});

  @override
  _SingleScheduledDialogState createState() => _SingleScheduledDialogState();
}

class _SingleScheduledDialogState extends State<SingleScheduledDialog> {
  final formatCurrency = new NumberFormat.simpleCurrency();
  final controller = PageController(initialPage: 0);
  FocusNode amountNode;
  double initialAmount = 0;

  Map<String, dynamic> orderCategories;

  //Month Stats Variables
  Map<String, dynamic> orderStats = {};
  int currentSalesCount;
  Map<String, dynamic> currentItemsCount = {};
  Map<String, dynamic> currentItemsAmount = {};
  Map<String, dynamic> salesCountbyCategory = {};
  Map<String, dynamic> currentSalesbyOrderType = {};
  int newSalesCount;
  int currentTicketItemsCount;
  int newTicketItemsCount;

  Future currentValue() async {
    var year = DateTime.now().year.toString();
    var month = DateTime.now().month.toString();

    var firestore = FirebaseFirestore.instance;

    var docRef = firestore
        .collection('ERP')
        .doc(widget.businessID)
        .collection(year)
        .doc(month)
        .get();
    return docRef;
  }

  Future currentValuesBuilt;

  void clearControllers() {
    setState(() {
      bloc.removeAllFromCart();
    });
  }

  void initState() {
    currentValuesBuilt = currentValue();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final monthlyStats = Provider.of<MonthlyStats>(context);
    final registerStatus = Provider.of<CashRegister>(context);

    if (monthlyStats == null) {
      currentSalesCount = 0;
      currentTicketItemsCount = 0;
      currentItemsCount = {};
      currentItemsAmount = {};
      salesCountbyCategory = {};
      currentSalesbyOrderType = {};

      return Container();
    }

    try {
      currentSalesCount = monthlyStats.totalSalesCount;
    } catch (e) {
      //
    }
    try {
      currentItemsCount = monthlyStats.salesCountbyProduct;
    } catch (e) {
      currentItemsCount = {};
    }
    try {
      currentItemsAmount = monthlyStats.salesAmountbyProduct;
    } catch (e) {
      currentItemsAmount = {};
    }
    try {
      currentTicketItemsCount = monthlyStats.totalItemsSold;
    } catch (e) {
      currentTicketItemsCount = 0;
    }
    try {
      salesCountbyCategory = monthlyStats.salesCountbyCategory;
    } catch (e) {
      salesCountbyCategory = {};
    }
    try {
      currentSalesbyOrderType = monthlyStats.salesbyOrderType;
    } catch (e) {
      currentSalesbyOrderType = {};
    }

    return FutureBuilder(
        future: currentValuesBuilt,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              child: Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.35,
                  height: MediaQuery.of(context).size.height * 0.7,
                  constraints: BoxConstraints(minHeight: 350, minWidth: 300),
                  padding: EdgeInsets.all(20),
                  child: PageView(
                    controller: controller,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      //Initial
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Go Back
                          Container(
                            alignment: Alignment(1.0, 0.0),
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
                                          .format(widget.order.savedDate)
                                          .toString() +
                                      " - " +
                                      DateFormat('HH:mm:ss')
                                          .format(widget.order.savedDate)
                                          .toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                )),
                                Spacer(),
                                //Name
                                Container(
                                    child: Text(
                                  (widget.order.orderName == '')
                                      ? 'Nombre sin agregar'
                                      : widget.order.orderName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                )),
                              ],
                            ),
                          ),
                          SizedBox(
                              height: (widget.order.client['Address'] != '')
                                  ? 10
                                  : 20),
                          //If delivery
                          (widget.order.client['Address'] != null &&
                                  widget.order.client['Address'] != '')
                              ? Container(
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      //Type
                                      Icon(
                                        Icons.location_pin,
                                        size: 14,
                                      ),
                                      Container(
                                          child: Text(
                                        '${widget.order.client['Address']}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal),
                                      )),
                                      Spacer(),
                                      //Total
                                      Icon(
                                        Icons.phone,
                                        size: 14,
                                      ),
                                      Container(
                                          child: Text(
                                        '${widget.order.client['Phone']}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal),
                                      )),
                                    ],
                                  ),
                                )
                              : Container(),
                          (widget.order.client['Address'] != null &&
                                  widget.order.client['Address'] != '')
                              ? SizedBox(height: 20)
                              : SizedBox(height: 0),
                          //Ticket
                          Container(
                              child: Text(
                            'Ticket',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          )),
                          SizedBox(height: 20),
                          Expanded(
                            child: Container(
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: widget.order.orderDetail.length,
                                  itemBuilder: (context, i) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 5.0),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            //Name
                                            Container(
                                              constraints:
                                                  BoxConstraints(maxWidth: 250),
                                              child: Text((widget.order
                                                              .orderDetail[i]
                                                          ['Quantity'] ==
                                                      1)
                                                  ? widget.order.orderDetail[i]
                                                      ['Name']
                                                  : widget.order.orderDetail[i]
                                                          ['Name'] +
                                                      '(${formatCurrency.format(widget.order.orderDetail[i]['Price'])} x ${widget.order.orderDetail[i]['Quantity']})'),
                                            ),
                                            //Amount
                                            Spacer(),
                                            Text(
                                                '${formatCurrency.format(widget.order.orderDetail[i]['Total Price'])}'),
                                          ]),
                                    );
                                  }),
                            ),
                          ),
                          SizedBox(height: 15),
                          Container(
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                //Type
                                (widget.order.note != null &&
                                        widget.order.note != '')
                                    ? Tooltip(
                                        richMessage: WidgetSpan(
                                            alignment:
                                                PlaceholderAlignment.baseline,
                                            baseline: TextBaseline.alphabetic,
                                            child: Container(
                                              padding: EdgeInsets.all(10),
                                              constraints: const BoxConstraints(
                                                  maxWidth: 250),
                                              child: Text(
                                                widget.order.note,
                                              ),
                                            )),
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                              160, 223, 224, 255),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(4)),
                                        ),
                                        preferBelow: false,
                                        verticalOffset: 10,
                                        child: Icon(
                                          Icons.info_outline,
                                          size: 20,
                                        ),
                                      )
                                    : Container(
                                        child: Text(
                                        '',
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal),
                                      )),
                                Spacer(),
                                //Total
                                (widget.order.pending)
                                    ? Container(
                                        child: Text(
                                        'Saldo por cobrar: ${formatCurrency.format(widget.order.remainingBalance)}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ))
                                    : Container(
                                        child: Text(
                                        'Cobrado',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      )),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          //Buttons
                          (widget.order.pending)
                              ? Container(
                                  height: 50,
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      //Delete
                                      Expanded(
                                        flex: 2,
                                        child: Tooltip(
                                          message: 'Borrar pedido',
                                          child: Container(
                                            height: 50,
                                            child: OutlinedButton(
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.black,
                                              ),
                                              onPressed: () {
                                                DatabaseService()
                                                    .deleteScheduleSale(
                                                        widget.businessID,
                                                        widget.order.id);
                                                clearControllers();
                                                Navigator.of(context).pop();
                                              },
                                              child: Center(
                                                child: Icon(
                                                  Icons.delete,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      //Partial Pay
                                      Expanded(
                                        flex: 5,
                                        child: Container(
                                          height: 50,
                                          child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.black,
                                            ),
                                            onPressed: () {
                                              controller.nextPage(
                                                  duration: Duration(
                                                      milliseconds: 500),
                                                  curve: Curves.ease);
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text('Cobro parcial'),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      //Pay
                                      Expanded(
                                        flex: 5,
                                        child: Container(
                                          height: 50,
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.black,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 15),
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8)),
                                                ),
                                              ),
                                              onPressed: () {
                                                bloc.changePaymentType(
                                                    'Efectivo');
                                                bloc.changeOrderName(
                                                    widget.order.orderName);
                                                bloc.changeOrderType(
                                                    'Venta Agendada');
                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return MultiProvider(
                                                        providers: [
                                                          StreamProvider<
                                                                  MonthlyStats>.value(
                                                              initialData: null,
                                                              value: DatabaseService()
                                                                  .monthlyStatsfromSnapshot(
                                                                      widget
                                                                          .businessID)),
                                                        ],
                                                        child: ConfirmOrder(
                                                          total: widget
                                                              .order.total,
                                                          items: widget.order
                                                              .orderDetail,
                                                          discount: widget
                                                              .order.discount,
                                                          discountCode: '',
                                                          orderDetail: widget
                                                              .order
                                                              .orderDetail,
                                                          orderName: widget
                                                              .order.orderName,
                                                          subTotal: widget
                                                              .order.subTotal,
                                                          tax: widget.order.tax,
                                                          controller: null,
                                                          clearVariables:
                                                              clearControllers,
                                                          paymentTypes:
                                                              registerStatus
                                                                  .paymentTypes,
                                                          isTable: false,
                                                          tableCode: null,
                                                          businessID:
                                                              widget.businessID,
                                                          tablePageController:
                                                              null,
                                                          isSavedOrder: false,
                                                          savedOrderID:
                                                              widget.order.id,
                                                          orderType:
                                                              'Venta Agendada',
                                                          onTableView: false,
                                                          register: null,
                                                        ),
                                                      );
                                                    });
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15,
                                                        vertical: 5),
                                                child: Center(
                                                  child: Text('Registar venta'),
                                                ),
                                              )),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox()
                        ],
                      ),
                      //Partial payment
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          //Go Back
                          Container(
                            alignment: Alignment(1.0, 0.0),
                            child: IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(Icons.close),
                                iconSize: 20.0),
                          ),
                          SizedBox(height: 15),
                          //Ttitle
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Monto parcial a cobrar",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          //Amount
                          TextFormField(
                            autofocus: true,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black, fontSize: 40),
                            initialValue: '\$0.00',
                            validator: (val) =>
                                val.isEmpty ? "Agrega un monto válido" : null,
                            inputFormatters: <TextInputFormatter>[
                              CurrencyTextInputFormatter(
                                name: '\$',
                                locale: 'en',
                                decimalDigits: 2,
                              ),
                            ],
                            keyboardType: TextInputType.number,
                            cursorColor: Colors.grey,
                            decoration: InputDecoration(
                              border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(12.0),
                                borderSide: new BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(12.0),
                                borderSide: new BorderSide(
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            onChanged: (val) {
                              setState(() => initialAmount = double.tryParse(
                                  (val.substring(1)).replaceAll(',', '')));
                            },
                          ),
                          SizedBox(
                            height: 35,
                          ),
                          //Button
                          Container(
                            height: 40.0,
                            width: double.infinity,
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
                                final double remainingBalance =
                                    widget.order.remainingBalance -
                                        initialAmount;
                                DatabaseService().updateScheduledSale(
                                    widget.businessID,
                                    widget.order.id,
                                    remainingBalance);
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                "Registrar",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(height: 25),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Dialog();
          }
        });
  }
}
