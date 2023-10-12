import 'package:denario/Backend/Expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AddExpenseItem extends StatefulWidget {
  final addExpenseItem;
  final snapshot;
  final int itemIndex;
  final List dropdownCategories;
  const AddExpenseItem(this.addExpenseItem, this.snapshot, this.itemIndex,
      this.dropdownCategories,
      {Key key})
      : super(key: key);

  @override
  State<AddExpenseItem> createState() => _AddExpenseItemState();
}

class _AddExpenseItemState extends State<AddExpenseItem> {
  String product = '';
  String category;
  double qty = 1;
  double price = 0;

  @override
  void initState() {
    category = widget.dropdownCategories.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Back
              Container(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    //Text
                    Text(
                      'Agregar Item',
                    ),
                    Spacer(),
                    //IconButton
                    IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close,
                          color: Colors.black,
                        )),
                  ],
                ),
              ),
              SizedBox(height: 20),
              //Producto
              Text(
                'Descripción',
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Colors.black45),
              ),
              SizedBox(height: 5),
              Container(
                height: 50,
                width: double.infinity,
                child: Center(
                  child: TextFormField(
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Colors.grey[700]),
                    inputFormatters: [LengthLimitingTextInputFormatter(25)],
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      hintText: product,
                      label: Text(''),
                      labelStyle: TextStyle(color: Colors.grey, fontSize: 12),
                      errorStyle:
                          TextStyle(color: Colors.redAccent[700], fontSize: 14),
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(5.0),
                        borderSide: new BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(5.0),
                        borderSide: new BorderSide(
                          color: Colors.green,
                        ),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        product = val;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 15),
              //Categoria
              Text(
                'Categoría',
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Colors.black45),
              ),
              SizedBox(height: 5),
              Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButton(
                    isExpanded: true,
                    underline: SizedBox(),
                    hint: Text(
                      category,
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Colors.grey[700]),
                    ),
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Colors.grey[700]),
                    value: category,
                    items: widget.dropdownCategories.map((x) {
                      return new DropdownMenuItem(
                        value: x,
                        child: new Text(x),
                        onTap: () {
                          setState(() {
                            category = x;
                          });
                        },
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        category = newValue;
                      });
                    },
                  )),
              SizedBox(height: 15),
              //Cantidad/Precio
              Container(
                height: 75,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //Cantidad
                    Expanded(
                        flex: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cantidad ',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Colors.black45),
                            ),
                            SizedBox(height: 5),
                            Expanded(
                              child: TextFormField(
                                initialValue: '1',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Colors.grey[700]),
                                validator: (val) =>
                                    val.contains(',') ? "Usa punto" : null,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
                                  TextInputFormatter.withFunction(
                                    (oldValue, newValue) => newValue.copyWith(
                                      text: newValue.text.replaceAll(',', '.'),
                                    ),
                                  ),
                                ],
                                keyboardType: TextInputType.number,
                                cursorColor: Colors.black,
                                decoration: InputDecoration(
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  label: Text(''),
                                  labelStyle: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                  errorStyle: TextStyle(
                                      color: Colors.redAccent[700],
                                      fontSize: 14),
                                  border: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(5.0),
                                    borderSide: new BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(5.0),
                                    borderSide: new BorderSide(
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                                onChanged: (val) {
                                  if (val != null && val != '') {
                                    setState(() {
                                      qty = double.tryParse(val);
                                    });
                                  } else if (val == '') {
                                    setState(() {
                                      qty = 0;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        )),
                    SizedBox(width: 10),
                    //Precio
                    Expanded(
                        flex: 5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Precio',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Colors.black45),
                            ),
                            SizedBox(height: 5),
                            Expanded(
                              child: TextFormField(
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Colors.grey[700]),
                                validator: (val) =>
                                    val.contains(',') ? "Usa punto" : null,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
                                  TextInputFormatter.withFunction(
                                    (oldValue, newValue) => newValue.copyWith(
                                      text: newValue.text.replaceAll(',', '.'),
                                    ),
                                  ),
                                ],
                                keyboardType: TextInputType.number,
                                cursorColor: Colors.black,
                                decoration: InputDecoration(
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  hintText: '\$0.00',
                                  label: Text(''),
                                  labelStyle: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                  errorStyle: TextStyle(
                                      color: Colors.redAccent[700],
                                      fontSize: 14),
                                  border: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(5.0),
                                    borderSide: new BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(5.0),
                                    borderSide: new BorderSide(
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                                onChanged: (val) {
                                  if (val != null && val != '') {
                                    setState(() {
                                      price = double.tryParse(val);
                                    });
                                  } else if (val == '') {
                                    setState(() {
                                      price = 0;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
              ),
              SizedBox(height: 20),
              //Total
              Container(
                width: double.infinity,
                child: Text(
                  'TOTAL: ${NumberFormat.simpleCurrency().format(qty * price)}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black),
                ),
              ),
              Spacer(),
              //Agregar Boton
              Container(
                  height: 35.0,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: Size(300, 50),
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    onPressed: () {
                      widget.addExpenseItem(product, category, qty, price);
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Agregar",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
