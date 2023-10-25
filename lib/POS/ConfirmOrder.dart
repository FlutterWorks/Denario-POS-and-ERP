import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Backend/Ticket.dart';
import 'package:denario/Models/DailyCash.dart';
import 'package:denario/Models/Stats.dart';
import 'package:denario/Models/User.dart';
import 'package:denario/No%20POS%20Sales/NewSaleScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ConfirmOrder extends StatefulWidget {
  final double? total;
  final dynamic items;

  final double? subTotal;
  final double? discount;
  final String? discountCode;
  final double? tax;
  final orderDetail;
  final String? orderName;
  final clearVariables;
  final List? paymentTypes;

  final TextEditingController? controller;
  final bool? isTable;
  final String? tableCode;

  final PageController? tablePageController;
  final String? businessID;

  final bool? isSavedOrder;
  final String? savedOrderID;
  final String? orderType;

  final bool? onTableView;
  final CashRegister? register;

  ConfirmOrder(
      {this.total,
      this.items,
      this.discount,
      this.discountCode,
      this.orderDetail,
      this.orderName,
      this.subTotal,
      this.tax,
      this.controller,
      this.clearVariables,
      this.paymentTypes,
      this.isTable,
      this.tableCode,
      this.tablePageController,
      this.businessID,
      this.isSavedOrder,
      this.savedOrderID,
      this.orderType,
      this.onTableView,
      this.register});

  @override
  _ConfirmOrderState createState() => _ConfirmOrderState();
}

class _ConfirmOrderState extends State<ConfirmOrder> {
  final formatCurrency = new NumberFormat.simpleCurrency();
  Map<String, dynamic>? orderCategories;
  late Future currentValuesBuilt;
  double? salesAmount;
  String? paymentType;
  bool? otherChanageAmount;
  double paysWith = 1000;
  FocusNode? otherChangeNode;
  String? invoiceNo;
  String clientName = '';

  //Split Payment Variables
  List splitPaymentDetails = [];
  int currentSplitAmount = 0;

  final controller = PageController(initialPage: 0);

  @override
  void initState() {
    invoiceNo = '00' +
        (DateTime.now().day).toString() +
        (DateTime.now().month).toString() +
        (DateTime.now().year).toString() +
        (DateTime.now().hour).toString() +
        (DateTime.now().minute).toString() +
        (DateTime.now().millisecond).toString();
    paymentType = 'Efectivo';
    otherChanageAmount = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.register!.registerisOpen!) {
      return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          child: Container(
            height: 400,
            width: MediaQuery.of(context).size.width * 0.35,
            child: Padding(
              padding: EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment(1.0, 0.0),
                    child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close),
                        iconSize: 20.0),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Ups!...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Debes abrir caja para poder realizar un cobro por el punto de venta. Tambien puedes registrar una venta independiente si así lo deseas",
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      //Cerrar
                      Container(
                          height: 50,
                          child: OutlinedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white70),
                                overlayColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                    if (states.contains(MaterialState.hovered))
                                      return Colors.grey.shade300;
                                    if (states
                                            .contains(MaterialState.focused) ||
                                        states.contains(MaterialState.pressed))
                                      return Colors.white;
                                    return Colors
                                        .white; // Defer to the widget's default.
                                  },
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 5),
                                child: Center(
                                  child: Text(
                                    'Cerrar',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ))),
                      SizedBox(width: 20),
                      //Abrir ventas independientes
                      Container(
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
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MultiProvider(
                                          providers: [
                                            StreamProvider<CashRegister>.value(
                                                initialData: CashRegister(),
                                                value: DatabaseService()
                                                    .cashRegisterStatus(
                                                        widget.businessID)),
                                            StreamProvider<UserData>.value(
                                                initialData: UserData(),
                                                value: DatabaseService()
                                                    .userProfile(FirebaseAuth
                                                        .instance
                                                        .currentUser!
                                                        .uid
                                                        .toString())),
                                            StreamProvider<MonthlyStats>.value(
                                              value: DatabaseService()
                                                  .monthlyStatsfromSnapshot(
                                                      widget.businessID!),
                                              initialData: MonthlyStats(),
                                            )
                                          ],
                                          child: Scaffold(
                                              body: NewSaleScreen(
                                            widget.businessID!,
                                            fromPOS: true,
                                          )),
                                        ))),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
                              child: Center(
                                child: Text('Abirir Venta Independiente'),
                              ),
                            )),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ));
    }
    return SingleChildScrollView(
      child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          child: Container(
            padding: EdgeInsets.all(20),
            height: (paymentType != 'Efectivo' &&
                    MediaQuery.of(context).size.width > 650)
                ? 400
                : 500,
            width: (MediaQuery.of(context).size.width > 650)
                ? MediaQuery.of(context).size.width * 0.35
                : MediaQuery.of(context).size.width * 0.9,
            constraints: (paymentType != 'Efectivo' &&
                    MediaQuery.of(context).size.width > 650)
                ? BoxConstraints(minHeight: 400, minWidth: 400)
                : BoxConstraints(minHeight: 500, minWidth: 400),
            child: PageView(
                controller: controller,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  //Regular Checkout
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      //Splt / Close
                      Container(
                        width: double.infinity,
                        height: 50,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              //Split
                              OutlinedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white70),
                                  overlayColor:
                                      MaterialStateProperty.resolveWith<Color?>(
                                    (Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.hovered))
                                        return Colors.grey.shade300;
                                      if (states.contains(
                                              MaterialState.focused) ||
                                          states
                                              .contains(MaterialState.pressed))
                                        return Colors.white;
                                      return null; // Defer to the widget's default.
                                    },
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    paymentType = 'Efectivo';
                                  });
                                  for (var i = 0;
                                      i < widget.paymentTypes!.length;
                                      i++) {
                                    splitPaymentDetails.add({
                                      'Type': widget.paymentTypes![i]['Type'],
                                      'Amount': 0
                                    });
                                  }
                                  controller.nextPage(
                                      duration: Duration(milliseconds: 500),
                                      curve: Curves.ease);
                                },
                                child: Center(
                                    child: Text(
                                  'Split',
                                  style: TextStyle(color: Colors.black),
                                )),
                              ),
                              Spacer(),
                              //Confirm Text
                              (MediaQuery.of(context).size.width > 650)
                                  ? Text(
                                      "Confirmar pedido",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  : SizedBox(),
                              (MediaQuery.of(context).size.width > 650)
                                  ? Spacer()
                                  : SizedBox(),
                              //Cancel
                              IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: Icon(Icons.close),
                                  splashRadius: 5,
                                  iconSize: 20.0),
                            ]),
                      ),
                      Divider(thickness: 0.5, indent: 0, endIndent: 0),
                      SizedBox(height: 15),
                      //Amount
                      (MediaQuery.of(context).size.width > 650)
                          ? Container(
                              width: double.infinity,
                              height: 50,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    //Text
                                    Text(
                                      "Total:",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Spacer(),
                                    //Amount
                                    Text(
                                      "${formatCurrency.format(widget.total)}",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ]),
                            )
                          : Container(
                              height: 75,
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Total",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  //Text
                                  Text(
                                    "${formatCurrency.format(widget.total)}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 28.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      (MediaQuery.of(context).size.width > 650)
                          ? Divider(thickness: 0.5, indent: 0, endIndent: 0)
                          : SizedBox(),
                      SizedBox(
                        height:
                            (MediaQuery.of(context).size.width > 650) ? 15 : 0,
                      ),
                      //Change AMOUNT
                      (paymentType == 'Efectivo' &&
                              (MediaQuery.of(context).size.width > 650))
                          ? Container(
                              width: double.infinity,
                              height: 50,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    //Text
                                    Text(
                                      "Paga con:",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Spacer(),
                                    //Pays with
                                    (!otherChanageAmount!)
                                        ? Row(
                                            children: [
                                              //500
                                              OutlinedButton(
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                              Color>(
                                                          Colors.white70),
                                                  overlayColor:
                                                      MaterialStateProperty
                                                          .resolveWith<Color?>(
                                                    (Set<MaterialState>
                                                        states) {
                                                      if (states.contains(
                                                          MaterialState
                                                              .hovered))
                                                        return Colors
                                                            .grey.shade300;
                                                      if (states.contains(
                                                              MaterialState
                                                                  .focused) ||
                                                          states.contains(
                                                              MaterialState
                                                                  .pressed))
                                                        return Colors.grey;
                                                      return null; // Defer to the widget's default.
                                                    },
                                                  ),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    paysWith = 500;
                                                  });
                                                },
                                                child: Center(
                                                    child: Text(
                                                  '500',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                )),
                                              ),
                                              SizedBox(width: 10),
                                              //1000
                                              OutlinedButton(
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                              Color>(
                                                          Colors.white70),
                                                  overlayColor:
                                                      MaterialStateProperty
                                                          .resolveWith<Color?>(
                                                    (Set<MaterialState>
                                                        states) {
                                                      if (states.contains(
                                                          MaterialState
                                                              .hovered))
                                                        return Colors
                                                            .grey.shade300;
                                                      if (states.contains(
                                                              MaterialState
                                                                  .focused) ||
                                                          states.contains(
                                                              MaterialState
                                                                  .pressed))
                                                        return Colors.grey;
                                                      return null; // Defer to the widget's default.
                                                    },
                                                  ),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    paysWith = 1000;
                                                  });
                                                },
                                                child: Center(
                                                    child: Text(
                                                  '1.000',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                )),
                                              ),
                                              SizedBox(width: 10),
                                              //otro
                                              OutlinedButton(
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                              Color>(
                                                          Colors.white70),
                                                  overlayColor:
                                                      MaterialStateProperty
                                                          .resolveWith<Color?>(
                                                    (Set<MaterialState>
                                                        states) {
                                                      if (states.contains(
                                                          MaterialState
                                                              .hovered))
                                                        return Colors
                                                            .grey.shade300;
                                                      if (states.contains(
                                                              MaterialState
                                                                  .focused) ||
                                                          states.contains(
                                                              MaterialState
                                                                  .pressed))
                                                        return Colors.grey;
                                                      return null; // Defer to the widget's default.
                                                    },
                                                  ),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    otherChanageAmount = true;
                                                  });
                                                },
                                                child: Center(
                                                    child: Text(
                                                  'Otro',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                )),
                                              ),
                                            ],
                                          )
                                        : Container(
                                            height: 50,
                                            width: 70,
                                            child: Center(
                                              child: TextFormField(
                                                autofocus: true,
                                                focusNode: otherChangeNode,
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 18,
                                                    color: Colors.black),
                                                validator: (val) =>
                                                    val!.contains(',')
                                                        ? "Usa punto"
                                                        : null,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp(
                                                          r"[0-9]+[.]?[0-9]*"))
                                                ],
                                                keyboardType:
                                                    TextInputType.number,
                                                cursorColor: Colors.black,
                                                decoration:
                                                    InputDecoration.collapsed(
                                                  hintText: "0",
                                                  hintStyle: TextStyle(
                                                      color:
                                                          Colors.grey.shade700),
                                                ),
                                                onChanged: (val) {
                                                  setState(() => paysWith =
                                                      double.parse(val));
                                                },
                                              ),
                                            ),
                                          ),
                                  ]),
                            )
                          : Container(),
                      SizedBox(
                        height: (paymentType == 'Efectivo' &&
                                (MediaQuery.of(context).size.width > 650))
                            ? 15
                            : 0,
                      ),
                      //Change FORMULA
                      (paymentType == 'Efectivo' &&
                              (MediaQuery.of(context).size.width > 650))
                          ? Container(
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  //Text
                                  Text(
                                    "Cambio:  ${formatCurrency.format(paysWith - widget.total!)}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      SizedBox(
                        height: (paymentType == 'Efectivo') ? 15 : 0,
                      ),
                      (paymentType == 'Efectivo' &&
                              (MediaQuery.of(context).size.width > 650))
                          ? Divider(thickness: 0.5, indent: 0, endIndent: 0)
                          : Container(),
                      SizedBox(
                        height: 15,
                      ),
                      //Payment type
                      (MediaQuery.of(context).size.width > 650)
                          ? Container(
                              width: double.infinity,
                              height: 60,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    //Text
                                    Text(
                                      "Método:",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: 15),
                                    //List of payment methods
                                    Expanded(
                                      child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount:
                                              widget.paymentTypes!.length,
                                          shrinkWrap: true,
                                          itemBuilder: (context, i) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 3.0),
                                              child: Container(
                                                height: 60,
                                                width: 60,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8)),
                                                  border: Border.all(
                                                      color: (paymentType ==
                                                              widget.paymentTypes![
                                                                  i]['Type'])
                                                          ? Colors.greenAccent
                                                          : Colors.white10,
                                                      width: 1.5),
                                                ),
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      paymentType = widget
                                                              .paymentTypes![i]
                                                          ['Type'];
                                                    });
                                                    bloc.changePaymentType(
                                                        widget.paymentTypes![i]
                                                            ['Type']);
                                                  },
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5.0),
                                                      child: Image(
                                                        image: NetworkImage(
                                                            widget.paymentTypes![
                                                                i]['Image']),
                                                        fit: BoxFit.scaleDown,
                                                      )
                                                      // Container(
                                                      //     decoration: BoxDecoration(
                                                      //         image: DecorationImage(
                                                      //   image: NetworkImage(widget
                                                      //       .paymentTypes[i]['Image']),
                                                      //   fit: BoxFit.cover,
                                                      // ))),
                                                      ),
                                                ),
                                              ),
                                            );
                                          }),
                                    ),
                                  ]),
                            )
                          : Container(
                              height: 60,
                              width: double.infinity,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: widget.paymentTypes!.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, i) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 3.0),
                                      child: Container(
                                        height: 60,
                                        width: 60,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)),
                                          border: Border.all(
                                              color: (paymentType ==
                                                      widget.paymentTypes![i]
                                                          ['Type'])
                                                  ? Colors.greenAccent
                                                  : Colors.white10,
                                              width: 1.5),
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              paymentType = widget
                                                  .paymentTypes![i]['Type'];
                                            });
                                            bloc.changePaymentType(widget
                                                .paymentTypes![i]['Type']);
                                          },
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Image(
                                                image: NetworkImage(widget
                                                    .paymentTypes![i]['Image']),
                                                fit: BoxFit.scaleDown,
                                              )),
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                      SizedBox(height: 25),
                      //Buttons
                      (MediaQuery.of(context).size.width > 650)
                          ? Container(
                              height: 50,
                              width: double.infinity,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    //To Receivables
                                    Container(
                                      height: 50,
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.black,
                                        ),
                                        onPressed: () {
                                          var documentID =
                                              DateTime.now().toString();

                                          bloc.changePaymentType('Por Cobrar');
                                          bloc.changePaymentType('Por Cobrar');

                                          DatabaseService().createReceivable(
                                              widget.businessID,
                                              documentID,
                                              widget.subTotal,
                                              widget.discount,
                                              widget.tax,
                                              widget.total,
                                              widget.orderDetail,
                                              widget.orderName,
                                              widget.orderType,
                                              widget.orderName, {
                                            'Name': widget.orderName,
                                            'Address': '',
                                            'Phone': 0,
                                            'email': '',
                                          });
                                          DatabaseService().saveNewOrder(
                                              documentID,
                                              widget.businessID!,
                                              false,
                                              [],
                                              invoiceNo,
                                              (widget.register == null)
                                                  ? 'Indpendiente'
                                                  : widget
                                                      .register!.registerName,
                                              widget.isTable!,
                                              widget.tableCode,
                                              widget.isSavedOrder!,
                                              widget.savedOrderID,
                                              false,
                                              widget.orderName,
                                              widget.orderDetail,
                                              widget.subTotal,
                                              widget.total,
                                              paymentType,
                                              widget.orderType,
                                              widget.tax,
                                              widget.discount,
                                              widget.discountCode);
                                          /////////////////Clear Variables
                                          widget.clearVariables();
                                          if (widget.onTableView!) {
                                            widget.tablePageController!
                                                .jumpTo(0);
                                          }
                                          Navigator.of(context).pop();
                                          // saveOrder(userProfile, 'Por Cobrar',
                                          //     documentID, false);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('A ventas por cobrar'),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 15),
                                    //Confirmar
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8)),
                                          ),
                                        ),
                                        onPressed: () {
                                          var documentID =
                                              DateTime.now().toString();

                                          DatabaseService().saveNewOrder(
                                              documentID,
                                              widget.businessID!,
                                              false,
                                              [],
                                              invoiceNo,
                                              (widget.register == null)
                                                  ? null
                                                  : widget
                                                      .register!.registerName,
                                              widget.isTable!,
                                              widget.tableCode,
                                              widget.isSavedOrder!,
                                              widget.savedOrderID,
                                              false,
                                              widget.orderName,
                                              widget.orderDetail,
                                              widget.subTotal,
                                              widget.total,
                                              paymentType,
                                              widget.orderType,
                                              widget.tax,
                                              widget.discount,
                                              widget.discountCode);
                                          /////////////////Clear Variables
                                          widget.clearVariables();
                                          if (widget.onTableView!) {
                                            widget.tablePageController!
                                                .jumpTo(0);
                                          }
                                          if (widget.orderType ==
                                              'Venta Agendada') {
                                            DatabaseService().paidScheduledSale(
                                                widget.businessID,
                                                widget.savedOrderID);
                                            Navigator.of(context).pop();
                                          }
                                          Navigator.of(context).pop();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 5),
                                          child: Center(
                                            child: Text('Confirmar'),
                                          ),
                                        )),
                                  ]),
                            )
                          : Container(
                              height: 120,
                              width: double.infinity,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    //To Receivables
                                    Container(
                                      height: 50,
                                      width: double.infinity,
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.black,
                                        ),
                                        onPressed: () {
                                          var documentID =
                                              DateTime.now().toString();

                                          bloc.changePaymentType('Por Cobrar');

                                          DatabaseService().createReceivable(
                                              widget.businessID,
                                              documentID,
                                              widget.subTotal,
                                              widget.discount,
                                              widget.tax,
                                              widget.total,
                                              widget.orderDetail,
                                              widget.orderName,
                                              widget.orderType,
                                              widget.orderName, {
                                            'Name': widget.orderName,
                                            'Address': '',
                                            'Phone': 0,
                                            'email': '',
                                          });
                                          DatabaseService().saveNewOrder(
                                              documentID,
                                              widget.businessID!,
                                              false,
                                              [],
                                              invoiceNo,
                                              (widget.register == null)
                                                  ? 'Indpendiente'
                                                  : widget
                                                      .register!.registerName,
                                              widget.isTable!,
                                              widget.tableCode,
                                              widget.isSavedOrder!,
                                              widget.savedOrderID,
                                              false,
                                              widget.orderName,
                                              widget.orderDetail,
                                              widget.subTotal,
                                              widget.total,
                                              paymentType,
                                              widget.orderType,
                                              widget.tax,
                                              widget.discount,
                                              widget.discountCode);
                                          /////////////////Clear Variables
                                          widget.clearVariables();
                                          if (widget.onTableView!) {
                                            widget.tablePageController!
                                                .jumpTo(0);
                                          }
                                          Navigator.of(context).pop();
                                          // saveOrder(userProfile, 'Por Cobrar',
                                          //     documentID, false);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('A ventas por cobrar'),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    //Confirmar
                                    Container(
                                      height: 50,
                                      width: double.infinity,
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 15),
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8)),
                                            ),
                                          ),
                                          onPressed: () {
                                            var documentID =
                                                DateTime.now().toString();
                                            DatabaseService().saveNewOrder(
                                                documentID,
                                                widget.businessID!,
                                                false,
                                                [],
                                                invoiceNo,
                                                (widget.register == null)
                                                    ? null
                                                    : widget
                                                        .register!.registerName,
                                                widget.isTable!,
                                                widget.tableCode,
                                                widget.isSavedOrder!,
                                                widget.savedOrderID,
                                                false,
                                                widget.orderName,
                                                widget.orderDetail,
                                                widget.subTotal,
                                                widget.total,
                                                paymentType,
                                                widget.orderType,
                                                widget.tax,
                                                widget.discount,
                                                widget.discountCode);
                                            /////////////////Clear Variables
                                            widget.clearVariables();
                                            if (widget.onTableView!) {
                                              widget.tablePageController!
                                                  .jumpTo(0);
                                            }
                                            if (widget.orderType ==
                                                'Venta Agendada') {
                                              DatabaseService()
                                                  .paidScheduledSale(
                                                      widget.businessID,
                                                      widget.savedOrderID);
                                            }
                                            Navigator.of(context).pop();
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 5),
                                            child: Center(
                                              child: Text('Confirmar'),
                                            ),
                                          )),
                                    ),
                                  ]),
                            ),
                    ],
                  ),
                  //Split
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      //Header (back, amount, close)
                      Container(
                        width: double.infinity,
                        height: 50,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              //Back
                              IconButton(
                                  onPressed: () {
                                    splitPaymentDetails = [];
                                    controller.previousPage(
                                        duration: Duration(milliseconds: 500),
                                        curve: Curves.ease);
                                  },
                                  icon: Icon(Icons.arrow_back)),
                              Spacer(),
                              //Amount
                              Text(
                                "Total: \$${widget.total}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Spacer(),
                              //Cancel
                              IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: Icon(Icons.close),
                                  splashRadius: 5,
                                  iconSize: 20.0),
                            ]),
                      ),
                      Divider(thickness: 0.5, indent: 0, endIndent: 0),
                      SizedBox(height: 15),
                      //List of payment methods
                      Expanded(
                        child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: splitPaymentDetails.length,
                            shrinkWrap: true,
                            itemBuilder: (context, i) {
                              int currentIndex = i;
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 3.0),
                                child: Container(
                                  width: double.infinity,
                                  height: 50,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        //Text
                                        Expanded(
                                          flex: 5,
                                          child: Text(
                                            splitPaymentDetails[i]['Type'],
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 15),
                                        //Dollar sign
                                        Container(
                                          width: 15,
                                          child: Text(
                                            "\$",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 24.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        //Amount
                                        Expanded(
                                          flex: 4,
                                          child: Container(
                                            height: 50,
                                            child: Center(
                                              child: TextFormField(
                                                autofocus: true,
                                                focusNode: otherChangeNode,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 24,
                                                    color: Colors.black),
                                                validator: (val) =>
                                                    val!.contains(',')
                                                        ? "Usa punto"
                                                        : null,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp(
                                                          r"[0-9]+[.]?[0-9]*"))
                                                ],
                                                keyboardType:
                                                    TextInputType.number,
                                                cursorColor: Colors.black,
                                                decoration:
                                                    InputDecoration.collapsed(
                                                  hintText: "0",
                                                  hintStyle: TextStyle(
                                                      color:
                                                          Colors.grey.shade700),
                                                ),
                                                onChanged: (val) {
                                                  setState(() {
                                                    splitPaymentDetails[
                                                                currentIndex]
                                                            ['Amount'] =
                                                        int.parse(val);
                                                  });

                                                  double currentSplitAmount = 0;
                                                  for (var i = 0;
                                                      i <
                                                          splitPaymentDetails
                                                              .length;
                                                      i++) {
                                                    currentSplitAmount =
                                                        currentSplitAmount +
                                                            splitPaymentDetails[
                                                                i]['Amount'];
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]),
                                ),
                              );
                            }),
                      ),
                      //
                      Divider(thickness: 0.5, indent: 0, endIndent: 0),
                      SizedBox(height: 15),
                      //Remaining
                      Container(
                        width: double.infinity,
                        height: 50,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              //Text
                              Text(
                                "Remanente:",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 15),
                              //Dollar sign
                              Container(
                                width: 15,
                                child: Text(
                                  "\$",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              //Amount
                              Container(
                                height: 50,
                                width: 70,
                                child: Center(
                                  child: Text(
                                    "${widget.total! - currentSplitAmount}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                      ),
                      SizedBox(height: 25),
                      //Buttons
                      Container(
                        height: 50,
                        width: double.infinity,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              //Confirmar
                              ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        (currentSplitAmount != widget.total)
                                            ? MaterialStateProperty.all<Color>(
                                                Colors.grey)
                                            : MaterialStateProperty.all<Color>(
                                                Colors.black),
                                    overlayColor: MaterialStateProperty
                                        .resolveWith<Color?>(
                                      (Set<MaterialState> states) {
                                        if (states
                                            .contains(MaterialState.hovered))
                                          return Colors.grey;
                                        if (states.contains(
                                                MaterialState.focused) ||
                                            states.contains(
                                                MaterialState.pressed))
                                          return Colors.grey.shade300;
                                        return null; // Defer to the widget's default.
                                      },
                                    ),
                                  ),
                                  onPressed: () {
                                    bloc.changePaymentType('Split Payment');
                                    var documentID = DateTime.now().toString();
                                    DatabaseService().saveNewOrder(
                                        documentID,
                                        widget.businessID!,
                                        true,
                                        splitPaymentDetails,
                                        invoiceNo,
                                        widget.register!.registerName,
                                        widget.isTable!,
                                        widget.tableCode,
                                        widget.isSavedOrder!,
                                        widget.savedOrderID,
                                        false,
                                        widget.orderName,
                                        widget.orderDetail,
                                        widget.subTotal,
                                        widget.total,
                                        paymentType,
                                        widget.orderType,
                                        widget.tax,
                                        widget.discount,
                                        widget.discountCode);

                                    /////////////////Clear Variables
                                    widget.clearVariables();
                                    if (widget.onTableView!) {
                                      widget.tablePageController!.jumpTo(0);
                                    }
                                    Navigator.of(context).pop();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 5),
                                    child: Center(
                                      child: Text('Confirmar'),
                                    ),
                                  )),
                            ]),
                      ),
                    ],
                  ),
                ]),
          )),
    );
  }
}
