import 'package:flutter/material.dart';

class CreateExpensePaymentButtons extends StatefulWidget {
  final selectPayment;
  const CreateExpensePaymentButtons(this.selectPayment, {Key key})
      : super(key: key);

  @override
  State<CreateExpensePaymentButtons> createState() =>
      _CreateExpensePaymentButtonsState();
}

class _CreateExpensePaymentButtonsState
    extends State<CreateExpensePaymentButtons> {
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

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
