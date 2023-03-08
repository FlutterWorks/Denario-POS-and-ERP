import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateExpenseUseCashierMoney extends StatefulWidget {
  final AsyncSnapshot snapshot;
  final expenseTotal;
  final moneyFromCashier;
  final checkCashierMoneyBox;
  const CreateExpenseUseCashierMoney(this.snapshot, this.expenseTotal,
      this.moneyFromCashier, this.checkCashierMoneyBox,
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

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.all(5)),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  side: MaterialStateProperty.all(
                      BorderSide(width: 2, color: Colors.green)),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  overlayColor: MaterialStateProperty.resolveWith<Color>(
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
                      i < widget.snapshot.data['Items'].length;
                      i++) {
                    total += widget.snapshot.data['Items'][i]["Price"] *
                        widget.snapshot.data['Items'][i]["Quantity"];
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
                  color: isChecked ? Colors.green : Colors.transparent,
                  size: 18,
                ))),
          ),
          isChecked ? SizedBox(width: 15) : Container(),
          isChecked
              ? Container(
                  width: 100,
                  height: 40,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey)),
                  alignment: Alignment.center,
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    autofocus: true,
                    validator: (val) =>
                        val.isEmpty ? "No olvides agregar un monto" : null,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    cursorColor: Colors.grey,
                    decoration: InputDecoration.collapsed(
                      hintText: "¿Cuánto?",
                      hintStyle: TextStyle(color: Colors.grey.shade700),
                    ),
                    onChanged: (val) {
                      setState(() => cashRegisterAmount = double.parse(val));
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
                        color: useEntireAmount ? Colors.green : Colors.white)),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    overlayColor: MaterialStateProperty.resolveWith<Color>(
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
                        color: useEntireAmount ? Colors.green : Colors.grey,
                        fontSize: 11),
                  )))
              : Container(),
        ],
      ),
    );
  }
}
