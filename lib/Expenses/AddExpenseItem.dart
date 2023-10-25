import 'package:denario/Backend/Expense.dart';
import 'package:denario/Models/Supplier.dart';
import 'package:denario/Models/Supply.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddExpenseItem extends StatefulWidget {
  final addExpenseItem;
  final int itemIndex;
  final List dropdownCategories;
  final bool editItem;
  final String? product;
  final String? category;
  final double? price;
  final double? qty;
  final bool newItem;
  final Supplier selectedSupplier;
  final double? basePrice;
  const AddExpenseItem(
      this.addExpenseItem,
      this.itemIndex,
      this.dropdownCategories,
      this.editItem,
      this.newItem,
      this.selectedSupplier,
      {Key? key,
      this.product,
      this.category,
      this.price,
      this.qty,
      this.basePrice})
      : super(key: key);

  @override
  State<AddExpenseItem> createState() => _AddExpenseItemState();
}

class _AddExpenseItemState extends State<AddExpenseItem> {
  late String product;
  late String category;
  late double qty;
  late double price;
  late bool newItem;
  late double basePrice;

  final FocusNode _productNode = FocusNode();
  final FocusNode _qtyNode = FocusNode();
  final FocusNode _priceNode = FocusNode();

  @override
  void initState() {
    if (widget.editItem) {
      product = widget.product!;
      category = widget.category!;
      qty = widget.qty!;
      price = widget.price!;
      basePrice = widget.basePrice!;
      newItem = false;
    } else {
      product = '';
      category = widget.dropdownCategories.first;
      qty = 1;
      price = 0;
      newItem = true;
      basePrice = 0;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final supplies = Provider.of<List<Supply>>(context);

    if (supplies == []) {
      return Container();
    }

    return StreamBuilder(
        stream: bloc.getExpenseStream,
        initialData: bloc.expenseItems,
        builder: (context, snapshot) {
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.85,
            padding: EdgeInsets.all(20),
            child: (newItem)
                ? Column(
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
                      //Add new Item
                      OutlinedButton(
                          onPressed: () {
                            setState(() {
                              newItem = false;
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            padding: EdgeInsets.all(5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                //Icon
                                Icon(Icons.add, size: 16, color: Colors.grey),
                                SizedBox(width: 10),
                                //Text
                                Text(
                                  'Agregar nuevo',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                )
                              ],
                            ),
                          )),
                      SizedBox(height: 20),
                      //List of items
                      Expanded(
                          child: ListView.builder(
                              itemCount: supplies.length,
                              itemBuilder: (context, i) {
                                return TextButton(
                                    onPressed: () {
                                      setState(() {
                                        product = supplies[i].supply!;
                                        price = supplies[i].price!;
                                        qty = 1;
                                        category =
                                            widget.dropdownCategories.first;
                                        basePrice = supplies[i].price!;
                                        newItem = false;
                                      });
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: 50,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                              flex: 5,
                                              child: Text(
                                                supplies[i].supply!,
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14),
                                              )),
                                          Expanded(
                                              flex: 3,
                                              child: Text(
                                                '${NumberFormat.simpleCurrency().format(supplies[i].price)}',
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ))
                                        ],
                                      ),
                                    ));
                              }))
                    ],
                  )
                : SingleChildScrollView(
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
                              focusNode: _productNode,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Colors.grey[700]),
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(25)
                              ],
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                hintText: product,
                                label: Text(''),
                                labelStyle:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                                errorStyle: TextStyle(
                                    color: Colors.redAccent[700], fontSize: 14),
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
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (term) {
                                _productNode.unfocus();
                                FocusScope.of(context).requestFocus(_qtyNode);
                              },
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
                                  category = newValue.toString();
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          focusNode: _qtyNode,
                                          initialValue: '1',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                              color: Colors.grey[700]),
                                          validator: (val) => val!.contains(',')
                                              ? "Usa punto"
                                              : null,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(
                                                    r'[0-9]+[,.]{0,1}[0-9]*')),
                                            TextInputFormatter.withFunction(
                                              (oldValue, newValue) =>
                                                  newValue.copyWith(
                                                text: newValue.text
                                                    .replaceAll(',', '.'),
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
                                                color: Colors.grey,
                                                fontSize: 12),
                                            errorStyle: TextStyle(
                                                color: Colors.redAccent[700],
                                                fontSize: 14),
                                            border: new OutlineInputBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      5.0),
                                              borderSide: new BorderSide(
                                                color: Colors.grey,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      5.0),
                                              borderSide: new BorderSide(
                                                color: Colors.green,
                                              ),
                                            ),
                                          ),
                                          onFieldSubmitted: (term) {
                                            _qtyNode.unfocus();
                                            FocusScope.of(context)
                                                .requestFocus(_priceNode);
                                          },
                                          onChanged: (val) {
                                            if (val != '') {
                                              setState(() {
                                                qty = double.tryParse(val)!;
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          focusNode: _priceNode,
                                          textAlign: TextAlign.center,
                                          initialValue: price.toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                              color: Colors.grey[700]),
                                          validator: (val) => val!.contains(',')
                                              ? "Usa punto"
                                              : null,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(
                                                    r'[0-9]+[,.]{0,1}[0-9]*')),
                                            TextInputFormatter.withFunction(
                                              (oldValue, newValue) =>
                                                  newValue.copyWith(
                                                text: newValue.text
                                                    .replaceAll(',', '.'),
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
                                                color: Colors.grey,
                                                fontSize: 12),
                                            errorStyle: TextStyle(
                                                color: Colors.redAccent[700],
                                                fontSize: 14),
                                            border: new OutlineInputBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      5.0),
                                              borderSide: new BorderSide(
                                                color: Colors.grey,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      5.0),
                                              borderSide: new BorderSide(
                                                color: Colors.green,
                                              ),
                                            ),
                                          ),
                                          onFieldSubmitted: (term) {
                                            _priceNode.unfocus();
                                          },
                                          onChanged: (val) {
                                            if (val != '') {
                                              setState(() {
                                                price = double.tryParse(val)!;
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
                        SizedBox(height: 20),
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
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                ),
                              ),
                              onPressed: () {
                                if (widget.editItem) {
                                  bloc.editProduct(widget.itemIndex, product);
                                  bloc.editCategory(widget.itemIndex, category);
                                  bloc.editPrice(widget.itemIndex, price);
                                  bloc.editQuantity(widget.itemIndex, qty);
                                } else {
                                  widget.addExpenseItem(
                                      product, category, qty, price, basePrice);
                                }
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
          );
        });
  }
}
