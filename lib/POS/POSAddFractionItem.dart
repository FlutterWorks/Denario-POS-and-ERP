import 'package:denario/Backend/Ticket.dart';
import 'package:denario/Models/Products.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class POSAddFractionItem extends StatefulWidget {
  final Products product;

  POSAddFractionItem(this.product);
  @override
  _POSAddFractionItemState createState() => _POSAddFractionItemState();
}

class _POSAddFractionItemState extends State<POSAddFractionItem> {
  final formatCurrency = new NumberFormat.simpleCurrency();
  double quantity = 0;

  void addToCart() {
// Update Cart
    if (quantity > 0) {
      bloc.addToCart({
        'Name': widget.product.product,
        'Category': widget.product.category,
        'Price': widget.product.price!,
        'Quantity': quantity,
        'Total Price': widget.product.price!,
        'Options': [],
        'Supplies': widget.product.ingredients,
        'Product ID': widget.product.productID,
        'Control Stock': widget.product.controlStock,
      });
    }
    // Go Back
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Container(
            width: (MediaQuery.of(context).size.width > 600)
                ? 400
                : MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(minHeight: 350),
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //Cancel Icon
                  Container(
                    alignment: Alignment.topRight,
                    child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close),
                        iconSize: 20.0),
                  ),
                  SizedBox(height: 10),
                  //Product
                  Container(
                    width: double.infinity,
                    child: Text(
                      widget.product.product!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(height: 15),
                  //Price
                  Container(
                    width: double.infinity,
                    child: Text(
                      '\$${widget.product.price!} /u',
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
                  Container(
                    width: double.infinity,
                    child: Text(
                      'Cantidad',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(height: 10),
                  //Amount
                  TextFormField(
                    autofocus: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, fontSize: 32),
                    initialValue: null,
                    validator: (val) =>
                        val!.isEmpty ? "Agrega un monto válido" : null,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
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
                    onFieldSubmitted: (v) {
                      addToCart();
                    },
                    onChanged: (val) {
                      if (val == '') {
                        setState(() {
                          quantity = 0;
                        });
                      } else {
                        setState(() {
                          quantity = double.tryParse(val)!;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 20),
                  //TOTAL
                  Container(
                    width: double.infinity,
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Total: ' +
                          formatCurrency
                              .format(widget.product.price! * quantity),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(height: 20),
                  //Save Button
                  Container(
                    height: 40,
                    width: double.infinity,
                    child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.black),
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
                        onPressed: addToCart,
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
            )));
  }
}
