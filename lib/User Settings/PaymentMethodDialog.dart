import 'package:denario/Backend/DatabaseService.dart';
import 'package:flutter/material.dart';

class PaymentMethodDialog extends StatefulWidget {
  final String businessID;
  final List businessPaymentMthods;

  PaymentMethodDialog(this.businessID, this.businessPaymentMthods);
  @override
  _PaymentMethodDialogState createState() => _PaymentMethodDialogState();
}

class _PaymentMethodDialogState extends State<PaymentMethodDialog> {
  final _formKey = GlobalKey<FormState>();

  final List<Map<String, String>> paymentMethodsList = [
    {
      'Type': 'Efectivo',
      'Image':
          'https://firebasestorage.googleapis.com/v0/b/cafe-galia.appspot.com/o/App%20Assets%2FPayment%20Methods%2Ficons8-cash-100.png?alt=media&token=9d58b0f5-dcff-4ecb-bc8c-ffc51d05dc94'
    },
    {
      'Type': 'Tarjeta de Débito',
      'Image':
          'https://firebasestorage.googleapis.com/v0/b/cafe-galia.appspot.com/o/App%20Assets%2FPayment%20Methods%2Ficons8-credit-card-80.png?alt=media&token=b349ec08-93ea-4120-91b8-c1b0a643c7da'
    },
    {
      'Type': 'Tarjeta de Crédito',
      'Image':
          'https://firebasestorage.googleapis.com/v0/b/cafe-galia.appspot.com/o/App%20Assets%2FPayment%20Methods%2Ficons8-mastercard-credit-card-80.png?alt=media&token=b149b90d-3c5c-4120-80f6-d600dcaf6ba0'
    },
    {
      'Type': 'QR',
      'Image':
          'https://firebasestorage.googleapis.com/v0/b/cafe-galia.appspot.com/o/App%20Assets%2FPayment%20Methods%2Ficons8-qr-code-96.png?alt=media&token=a3a9d2f5-3ba6-4775-aaf9-a22159997694'
    },
    {
      'Type': 'Transferencia Bancaria',
      'Image':
          'https://firebasestorage.googleapis.com/v0/b/cafe-galia.appspot.com/o/App%20Assets%2FPayment%20Methods%2Ficons8-bank-transfer-58.png?alt=media&token=71680c7e-a20c-4601-ba2d-3ea792c7c550'
    },
  ];
  List selectedMethods = [];

  @override
  void initState() {
    for (var i = 0; i < widget.businessPaymentMthods.length; i++) {
      selectedMethods.add(widget.businessPaymentMthods[i]['Type']);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Container(
          width: 400,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //Cancel Icon
                  Container(
                    alignment: Alignment(1.0, 0.0),
                    child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close),
                        iconSize: 20.0),
                  ),
                  SizedBox(height: 10),
                  //Title
                  Container(
                    width: double.infinity,
                    child: Text(
                      'Métodos de pago',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(height: 20),
                  //Payment Methods
                  ListView.builder(
                      itemCount: paymentMethodsList.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: (selectedMethods.contains(
                                            paymentMethodsList[i]['Type']))
                                        ? Colors.greenAccent
                                        : Colors.black12,
                                    width: (selectedMethods.contains(
                                            paymentMethodsList[i]['Type']))
                                        ? 2
                                        : 1),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12))),
                            child: InkWell(
                              onTap: () {
                                if (selectedMethods
                                    .contains(paymentMethodsList[i]['Type'])) {
                                  setState(() {
                                    selectedMethods
                                        .remove(paymentMethodsList[i]['Type']);
                                  });
                                } else {
                                  setState(() {
                                    selectedMethods
                                        .add(paymentMethodsList[i]['Type']);
                                  });
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    //Image
                                    Container(
                                      height: 45,
                                      width: 45,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)),
                                          color: Colors.white,
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                paymentMethodsList[i]
                                                    ['Image']!),
                                            fit: BoxFit.cover,
                                          )),
                                    ),
                                    SizedBox(width: 10),
                                    //Name
                                    Text(
                                      paymentMethodsList[i]['Type']!,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal),
                                    ),
                                    Spacer(),
                                    //Included?
                                    Icon(Icons.check,
                                        weight: (selectedMethods.contains(
                                                paymentMethodsList[i]['Type']))
                                            ? 15
                                            : 8,
                                        color: (selectedMethods.contains(
                                                paymentMethodsList[i]['Type']))
                                            ? Colors.greenAccent
                                            : Colors.transparent,
                                        size: 21)
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                  SizedBox(height: 20),
                  //Save Button
                  Container(
                    height: 40,
                    width: double.infinity,
                    child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: (selectedMethods.length == 0)
                              ? MaterialStateProperty.all<Color>(Colors.grey)
                              : MaterialStateProperty.all<Color>(Colors.black),
                          overlayColor:
                              MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.hovered))
                                return Colors.grey.shade500;
                              if (states.contains(MaterialState.focused) ||
                                  states.contains(MaterialState.pressed))
                                return Colors.grey.shade500;
                              return null; // Defer to the widget's default.
                            },
                          ),
                        ),
                        onPressed: () {
                          if (selectedMethods.length != 0) {
                            List newPaymentMethods = [];

                            for (var i = 0;
                                i < paymentMethodsList.length;
                                i++) {
                              if (selectedMethods
                                  .contains(paymentMethodsList[i]['Type'])) {
                                newPaymentMethods.add(paymentMethodsList[i]);
                              }
                            }

                            DatabaseService().updateBusinessPaymentTypes(
                                widget.businessID, newPaymentMethods);
                            Navigator.of(context).pop();
                          }
                        },
                        child: Center(
                            child: Text(
                          'Guardar',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ))),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
