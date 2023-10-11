import 'package:denario/Models/DailyCash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Backend/Expense.dart';

class CreateExpenseUseCashierMoney extends StatefulWidget {
  final expenseTotal;
  final moneyFromCashier;
  final checkCashierMoneyBox;
  final selectPayment;
  final CashRegister registerStatus;
  final DailyTransactions dailyTransactions;
  const CreateExpenseUseCashierMoney(
      this.expenseTotal,
      this.moneyFromCashier,
      this.checkCashierMoneyBox,
      this.selectPayment,
      this.dailyTransactions,
      this.registerStatus,
      {Key key})
      : super(key: key);

  @override
  State<CreateExpenseUseCashierMoney> createState() =>
      _CreateExpenseUseCashierMoneyState();
}

class _CreateExpenseUseCashierMoneyState
    extends State<CreateExpenseUseCashierMoney> {
  bool isChecked = false;
  double cashRegisterAmount = 0;
  bool useEntireAmount = false;

  String paymentType = 'Efectivo';
  Widget paymentButton(String type, String imagePath) {
    return GestureDetector(
        onTap: () {
          setState(() {
            paymentType = type;
          });
          widget.selectPayment(type);
        },
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 75,
                width: 75,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    color: Colors.white,
                    border: Border.all(
                        color: (paymentType == type)
                            ? Colors.green
                            : Colors.white10,
                        width: 2),
                    image: DecorationImage(
                      image: AssetImage(imagePath),
                      fit: BoxFit.cover,
                    )),
              ),
              SizedBox(height: 15),
              Container(
                  width: 120,
                  height: 50,
                  child: Text(
                    type,
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Colors.grey[400]),
                    textAlign: TextAlign.center,
                  ))
            ]));
  }

  Widget mobilePaymentButton(String type, String imagePath) {
    return GestureDetector(
        onTap: () {
          setState(() {
            paymentType = type;
          });
          widget.selectPayment(type);
        },
        child: Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              color: Colors.white,
              border: Border.all(
                  color: (paymentType == type) ? Colors.green : Colors.white10,
                  width: 2),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              )),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Payment Buttons
        (MediaQuery.of(context).size.width > 650)
            ? Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: //Payment type
                    Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Efectivo
                    paymentButton('Efectivo', 'images/Cash.png'),
                    // MercadoPago
                    paymentButton('MercadoPago', 'images/MP.png'),
                    // Card
                    paymentButton('Tarjeta', 'images/CreditCard.png'),
                    //Payable
                    paymentButton('Por pagar', 'images/Payable.jpg'),
                  ],
                ),
              )
            : Container(
                width: double.infinity,
                height: 75,
                child: //Payment type
                    ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Efectivo
                    mobilePaymentButton('Efectivo', 'images/Cash.png'),
                    SizedBox(width: 10),
                    // MercadoPago
                    mobilePaymentButton('MercadoPago', 'images/MP.png'),
                    SizedBox(width: 10),
                    // Card
                    mobilePaymentButton('Tarjeta', 'images/CreditCard.png'),
                    SizedBox(width: 10),
                    //Payable
                    mobilePaymentButton('Por pagar', 'images/Payable.jpg'),
                    SizedBox(width: 10),
                  ],
                ),
              ),
        SizedBox(
          height: 5,
        ),
        // Use cashier money text
        (paymentType == 'Efectivo' &&
                widget.registerStatus != null &&
                widget.dailyTransactions != null)
            ? Text(
                "¿Usar dinero de la caja?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                ),
              )
            : Container(),
        SizedBox(
          height: 12,
        ),
        // Use money in petty cash?
        (paymentType == 'Efectivo' && widget.dailyTransactions != null)
            //Money from cashier
            ? Container(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      child: OutlinedButton(
                          style: ButtonStyle(
                            padding:
                                MaterialStateProperty.all<EdgeInsetsGeometry>(
                                    EdgeInsets.all(5)),
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12))),
                            side: MaterialStateProperty.all(
                                BorderSide(width: 2, color: Colors.green)),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            overlayColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.hovered))
                                  return Colors.grey.shade50;
                                if (states.contains(MaterialState.focused) ||
                                    states.contains(MaterialState.pressed))
                                  return Colors.grey.shade200;
                                return null; // Defer to the widget's default.
                              },
                            ),
                          ),
                          onPressed: () {
                            double total = 0;
                            for (var i = 0;
                                i < bloc.expenseItems['Items'].length;
                                i++) {
                              total += bloc.expenseItems['Items'][i]["Price"] *
                                  bloc.expenseItems['Items'][i]["Quantity"];
                            }

                            setState(() {
                              isChecked = !isChecked;
                            });

                            if (isChecked) {
                              useEntireAmount = true;
                              widget.moneyFromCashier(total);
                              widget.checkCashierMoneyBox(true);
                              setState(() {
                                cashRegisterAmount = total;
                              });
                            } else {
                              widget.moneyFromCashier(0);
                              widget.checkCashierMoneyBox(false);
                            }
                          },
                          child: Center(
                              child: Icon(
                            Icons.check,
                            color:
                                isChecked ? Colors.green : Colors.transparent,
                            size: 18,
                          ))),
                    ),
                    isChecked ? SizedBox(width: 15) : Container(),
                    isChecked
                        ? Container(
                            width: 100,
                            height: 40,
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey)),
                            alignment: Alignment.center,
                            child: TextFormField(
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                              autofocus: true,
                              validator: (val) => val.isEmpty
                                  ? "No olvides agregar un monto"
                                  : null,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              cursorColor: Colors.grey,
                              decoration: InputDecoration.collapsed(
                                hintText: "¿Cuánto?",
                                hintStyle:
                                    TextStyle(color: Colors.grey.shade700),
                              ),
                              onChanged: (val) {
                                setState(() =>
                                    cashRegisterAmount = double.parse(val));
                                widget.moneyFromCashier(double.parse(val));
                                useEntireAmount = false;
                              },
                            ),
                          )
                        : Container(),
                    isChecked ? SizedBox(width: 15) : Container(),
                    isChecked
                        ? ElevatedButton(
                            style: ButtonStyle(
                              side: MaterialStateProperty.all(BorderSide(
                                  width: 2,
                                  color: useEntireAmount
                                      ? Colors.green
                                      : Colors.white)),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              overlayColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.hovered))
                                    return Colors.grey.shade100;
                                  if (states.contains(MaterialState.focused) ||
                                      states.contains(MaterialState.pressed))
                                    return Colors.grey.shade200;
                                  return null; // Defer to the widget's default.
                                },
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                useEntireAmount = !useEntireAmount;
                                cashRegisterAmount = widget.expenseTotal;
                                widget.moneyFromCashier(widget.expenseTotal);
                              });
                            },
                            child: Center(
                                child: Text(
                              'Todo el importe',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: useEntireAmount
                                      ? Colors.green
                                      : Colors.grey,
                                  fontSize: 11),
                            )))
                        : Container(),
                  ],
                ),
              )
            : Container(),
      ],
    );
  }
}
