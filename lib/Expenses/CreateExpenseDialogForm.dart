import 'dart:math';

import 'package:denario/Backend/Expense.dart';
import 'package:denario/Expenses/AddExpenseItem.dart';
import 'package:denario/Models/Supplier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class CreateExpenseDialogForm extends StatefulWidget {
  final List dropdownCategories;
  final String costType;
  final removeSupplyFromList;
  final addSupplyToList;

  const CreateExpenseDialogForm(this.costType, this.dropdownCategories,
      this.removeSupplyFromList, this.addSupplyToList,
      {Key key})
      : super(key: key);

  @override
  State<CreateExpenseDialogForm> createState() =>
      _CreateExpenseDialogFormState();
}

class _CreateExpenseDialogFormState extends State<CreateExpenseDialogForm> {
  ValueKey redrawObject = ValueKey('List');
  //Form variables
  String selectedCategory = '';
  int categoryInt = 0;
  String selectedAccount = '';
  List<String> categoryList = [];
  List<String> categoriesVendors = [];
  String expenseDescription = '';
  String expenseHintDescription = '';
  TextEditingController descriptionController =
      new TextEditingController(text: '');
  List<TextEditingController> _controllers = [];
  Supplier selectedSupplier;

  var random = new Random();
  Map updateSuppliesFromList = {};
  void nothing(BuildContext context) {}

  void addExpenseItem(String name, String category, double qty, double price) {
    bloc.addToExpenseList({
      'Name': name,
      'Price': price,
      'Quantity': qty,
      'Total Price': qty * price,
      'Category': category,
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: bloc.getExpenseStream,
        initialData: bloc.expenseItems,
        builder: (context, snapshot) {
          if (MediaQuery.of(context).size.width > 650) {
            return Column(
              children: [
                //Form
                ListView.builder(
                    key: redrawObject,
                    shrinkWrap: true,
                    itemCount: snapshot.data["Items"].length,
                    itemBuilder: (context, i) {
                      double itemTotal;

                      if (snapshot.data["Items"][i]['Price'] != null &&
                          bloc.expenseItems["Items"][i]['Quantity'] != null) {
                        itemTotal = snapshot.data["Items"][i]['Price'] *
                            snapshot.data["Items"][i]['Quantity'];
                      } else {
                        itemTotal = 0;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Column(
                          children: [
                            //Input
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                //Category/Acct
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 12),
                                      child: DropdownButton(
                                        isExpanded: true,
                                        underline: SizedBox(),
                                        hint: Text(
                                          snapshot.data["Items"][i]['Category'],
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                              color: Colors.grey[700]),
                                        ),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            color: Colors.grey[700]),
                                        value: snapshot.data["Items"][i]
                                            ['Category'],
                                        items:
                                            widget.dropdownCategories.map((x) {
                                          return new DropdownMenuItem(
                                            value: x,
                                            child: new Text(x),
                                            onTap: () {
                                              setState(() {
                                                categoryInt = widget
                                                    .dropdownCategories
                                                    .indexOf(x);
                                                if (widget.costType ==
                                                    'Costo de Ventas') {
                                                  selectedAccount =
                                                      'Costo de Ventas';
                                                }

                                                if (widget.costType ==
                                                    'Costo de Ventas') {
                                                  bloc.changeAccount(
                                                      'Costo de Ventas');
                                                  bloc.editCategory(i, x);
                                                } else {
                                                  bloc.changeAccount(x);
                                                  bloc.editCategory(i, x);
                                                }

                                                // bloc.editProduct(
                                                //     i,
                                                //     widget
                                                //         .accountsProvider
                                                //         .accountsMapping[widget.costType][categoryInt]['Description']);
                                              });
                                            },
                                          );
                                        }).toList(),
                                        onChanged: (newValue) {
                                          setState(() {
                                            snapshot.data["Items"][i]
                                                ['Category'] = newValue;
                                          });
                                        },
                                      )),
                                ),
                                SizedBox(width: 15),
                                // Description
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    height: 50,
                                    child: Center(
                                      child: TextFormField(
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            color: Colors.grey[700]),
                                        validator: (val) => val.isEmpty
                                            ? "No olvides agregar una descripción"
                                            : null,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(25)
                                        ],
                                        cursorColor: Colors.black,
                                        decoration: InputDecoration(
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.always,
                                          hintText: snapshot.data["Items"][i]
                                              ['Name'],
                                          label: Text(''),
                                          labelStyle: TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                          errorStyle: TextStyle(
                                              color: Colors.redAccent[700],
                                              fontSize: 14),
                                          border: new OutlineInputBorder(
                                            borderRadius:
                                                new BorderRadius.circular(12.0),
                                            borderSide: new BorderSide(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                new BorderRadius.circular(12.0),
                                            borderSide: new BorderSide(
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                        onChanged: (val) {
                                          bloc.editProduct(i, val);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 15),
                                // Qty
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    height: 50,
                                    child: Center(
                                      child: TextFormField(
                                        initialValue: snapshot.data["Items"][i]
                                                ['Quantity']
                                            .toString(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            color: Colors.grey[700]),
                                        validator: (val) => val.contains(',')
                                            ? "Usa punto"
                                            : null,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
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
                                          label: Text(''),
                                          labelStyle: TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                          errorStyle: TextStyle(
                                              color: Colors.redAccent[700],
                                              fontSize: 12),
                                          border: new OutlineInputBorder(
                                            borderRadius:
                                                new BorderRadius.circular(12.0),
                                            borderSide: new BorderSide(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                new BorderRadius.circular(12.0),
                                            borderSide: new BorderSide(
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                        onChanged: (val) {
                                          bloc.editQuantity(
                                              i, double.parse(val));
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 15),
                                //Price
                                Expanded(
                                    flex: 2,
                                    child: Container(
                                      height: 50,
                                      child: Center(
                                        child: TextFormField(
                                          initialValue: (snapshot.data["Items"]
                                                          [i]['Price'] !=
                                                      null &&
                                                  snapshot.data["Items"][i]
                                                          ['Price'] !=
                                                      '' &&
                                                  snapshot.data["Items"][i]
                                                          ['Price'] >
                                                      0)
                                              ? '\$${snapshot.data["Items"][i]['Price'].toString()}'
                                              : null,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 16,
                                              color: Colors.grey[700]),
                                          validator: (val) {
                                            if (val.isEmpty) {
                                              return 'Agrega un precio';
                                            } else {
                                              return null;
                                            }
                                          },
                                          inputFormatters: [
                                            // CurrencyTextInputFormatter(
                                            //   name: '\$',
                                            //   locale: 'en',
                                            //   decimalDigits: 2,
                                            // ),
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
                                                fontSize: 12),
                                            border: new OutlineInputBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      12.0),
                                              borderSide: new BorderSide(
                                                color: Colors.grey,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      12.0),
                                              borderSide: new BorderSide(
                                                color: Colors.green,
                                              ),
                                            ),
                                          ),
                                          onChanged: (val) {
                                            if (val != null && val != '') {
                                              bloc.editPrice(
                                                  i, double.tryParse((val)));
                                              // bloc.editPrice(
                                              //     i,
                                              //     double.tryParse(
                                              //         (val.substring(
                                              //                 1))
                                              //             .replaceAll(
                                              //                 ',',
                                              //                 '')));
                                            } else if (val == '') {
                                              bloc.editPrice(i, 0);
                                            }
                                          },
                                        ),
                                      ),
                                    )),
                                SizedBox(width: 15),
                                //Total
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    child: Center(
                                      child: Text(
                                        '${NumberFormat.simpleCurrency().format(itemTotal)}',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: Colors.grey[700]),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                //Detele
                                IconButton(
                                    onPressed: () {
                                      bloc.removeFromExpenseList(
                                          snapshot.data["Items"][i]);
                                      if (updateSuppliesFromList.containsKey(
                                          snapshot.data["Items"][i]['Name'])) {
                                        updateSuppliesFromList.remove(
                                            snapshot.data["Items"][i]['Name']);
                                      }

                                      final random = Random();
                                      const availableChars =
                                          'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
                                      final randomString = List.generate(
                                              10,
                                              (index) => availableChars[
                                                  random.nextInt(
                                                      availableChars.length)])
                                          .join();
                                      setState(() {
                                        redrawObject = ValueKey(randomString);
                                      });
                                    },
                                    icon: Icon(Icons.delete))
                              ],
                            ),
                            SizedBox(
                                height: (snapshot.data["Items"][i]
                                            ['Base Price'] !=
                                        snapshot.data["Items"][i]['Price'])
                                    ? 10
                                    : 0),
                            //Button
                            ((snapshot.data["Items"][i]['Base Price'] !=
                                        null) &&
                                    (snapshot.data["Items"][i]['Base Price'] !=
                                        snapshot.data["Items"][i]['Price']))
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton(
                                          style: ButtonStyle(
                                            side: MaterialStateProperty.all(
                                                BorderSide(
                                                    width: 1,
                                                    color: (updateSuppliesFromList
                                                            .containsKey(
                                                                snapshot.data[
                                                                        "Items"]
                                                                    [
                                                                    i]['Name']))
                                                        ? Colors.green
                                                        : Colors.grey)),
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.white),
                                            overlayColor: MaterialStateProperty
                                                .resolveWith<Color>(
                                              (Set<MaterialState> states) {
                                                if (states.contains(
                                                    MaterialState.hovered))
                                                  return Colors.grey.shade100;
                                                if (states.contains(
                                                        MaterialState
                                                            .focused) ||
                                                    states.contains(
                                                        MaterialState.pressed))
                                                  return Colors.grey.shade200;
                                                return null; // Defer to the widget's default.
                                              },
                                            ),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              if (updateSuppliesFromList
                                                  .containsKey(
                                                      snapshot.data["Items"][i]
                                                          ['Name'])) {
                                                updateSuppliesFromList.remove(
                                                    snapshot.data["Items"][i]
                                                        ['Name']);
                                                widget.removeSupplyFromList(
                                                    snapshot.data["Items"][i]
                                                        ['Name']);
                                              } else {
                                                updateSuppliesFromList[
                                                    snapshot.data["Items"][i]
                                                        ['Name']] = snapshot
                                                    .data["Items"][i]['Price'];
                                                widget.addSupplyToList(
                                                    snapshot.data["Items"][i]
                                                        ['Name'],
                                                    snapshot.data["Items"][i]
                                                        ['Price']);
                                              }
                                            });
                                          },
                                          child: Center(
                                              child: Text(
                                            'Actualizar costo',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: (updateSuppliesFromList
                                                        .containsKey(snapshot
                                                                .data["Items"]
                                                            [i]['Name']))
                                                    ? Colors.green
                                                    : Colors.black,
                                                fontSize: 11),
                                          ))),
                                      SizedBox(
                                        width: 50,
                                      )
                                    ],
                                  )
                                : SizedBox()
                          ],
                        ),
                      );
                    }),

                //Boton de Agregar Items (cuadrado con +) => Lleva a seleccionar productos
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Tooltip(
                      message: 'Agregar item',
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () {
                          for (var x = 0; x < 3; x++) {
                            _controllers.add(new TextEditingController());
                          }

                          if (widget.costType == 'Costo de Ventas' &&
                              selectedSupplier != null &&
                              selectedSupplier.predefinedCategory != null &&
                              selectedSupplier.predefinedCategory != '') {
                            bloc.addToExpenseList({
                              'Name': '',
                              'Price': 0,
                              'Quantity': 1,
                              'Total Price': 0,
                              'Category': (selectedSupplier.predefinedCategory),
                            });
                          } else if (widget.costType != 'Costo de Ventas' &&
                              selectedSupplier != null &&
                              selectedSupplier.predefinedAccount != null &&
                              selectedSupplier.predefinedAccount != '') {
                            bloc.addToExpenseList({
                              'Name':
                                  selectedSupplier.initialExpenseDescription,
                              'Price': 0,
                              'Quantity': 1,
                              'Total Price': 0,
                              'Category': (widget.dropdownCategories.contains(
                                      selectedSupplier.predefinedAccount))
                                  ? selectedSupplier.predefinedAccount
                                  : widget.dropdownCategories[0],
                            });
                          } else {
                            bloc.addToExpenseList({
                              'Name': '',
                              'Price': 0,
                              'Quantity': 1,
                              'Total Price': 0,
                              'Category': widget.dropdownCategories[0]
                              // widget.snapshot.data["Items"][0]
                              //     ['Category' ],
                            });
                          }
                        },
                        child: Container(
                          height: 70,
                          width: 70,
                          child: Center(
                              child: Icon(
                            Icons.add,
                            color: Colors.black87,
                            size: 30,
                          )),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
              ],
            );
          } else {
            return Column(
              children: [
                //Form
                ListView.builder(
                    key: redrawObject,
                    shrinkWrap: true,
                    itemCount: snapshot.data["Items"].length,
                    itemBuilder: (context, i) {
                      double itemTotal;

                      if (snapshot.data["Items"][i]['Price'] != null &&
                          bloc.expenseItems["Items"][i]['Quantity'] != null) {
                        itemTotal = snapshot.data["Items"][i]['Price'] *
                            snapshot.data["Items"][i]['Quantity'];
                      } else {
                        itemTotal = 0;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Slidable(
                          key: const ValueKey(0),
                          endActionPane: ActionPane(
                            dismissible: DismissiblePane(onDismissed: () {
                              bloc.removeFromExpenseList(
                                  snapshot.data["Items"][i]);
                              if (updateSuppliesFromList.containsKey(
                                  snapshot.data["Items"][i]['Name'])) {
                                updateSuppliesFromList
                                    .remove(snapshot.data["Items"][i]['Name']);
                              }

                              final random = Random();
                              const availableChars =
                                  'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
                              final randomString = List.generate(
                                  10,
                                  (index) => availableChars[random
                                      .nextInt(availableChars.length)]).join();
                              setState(() {
                                redrawObject = ValueKey(randomString);
                              });
                            }),
                            motion: ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: nothing,
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Eliminar',
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: new BorderRadius.circular(12.0),
                                boxShadow: <BoxShadow>[
                                  new BoxShadow(
                                    color: Colors.grey[350],
                                    offset: Offset(0.0, 0.0),
                                    blurRadius: 10.0,
                                  )
                                ],
                              ),
                              child: Column(
                                children: [
                                  //Input
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      //Category/Acct
                                      Expanded(
                                        flex: 5,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            //Product
                                            Text(
                                              snapshot.data["Items"][i]['Name'],
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              snapshot.data["Items"][i]
                                                  ['Category'],
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 11),
                                            ),
                                            SizedBox(height: 10),
                                            //QTY
                                            Text(
                                              '${NumberFormat.simpleCurrency().format(snapshot.data["Items"][i]['Price'])} x ${snapshot.data["Items"][i]['Quantity']}',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ), //Total
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          '${NumberFormat.simpleCurrency().format(itemTotal)}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: Colors.grey[700]),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height: (snapshot.data["Items"][i]
                                                  ['Base Price'] !=
                                              snapshot.data["Items"][i]
                                                  ['Price'])
                                          ? 10
                                          : 0),
                                  //Button
                                  ((snapshot.data["Items"][i]['Base Price'] !=
                                              null) &&
                                          (snapshot.data["Items"][i]
                                                  ['Base Price'] !=
                                              snapshot.data["Items"][i]
                                                  ['Price']))
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            ElevatedButton(
                                                style: ButtonStyle(
                                                  side: MaterialStateProperty.all(BorderSide(
                                                      width: 1,
                                                      color: (updateSuppliesFromList
                                                              .containsKey(snapshot
                                                                          .data[
                                                                      "Items"]
                                                                  [i]['Name']))
                                                          ? Colors.green
                                                          : Colors.grey)),
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                          Color>(Colors.white),
                                                  overlayColor:
                                                      MaterialStateProperty
                                                          .resolveWith<Color>(
                                                    (Set<MaterialState>
                                                        states) {
                                                      if (states.contains(
                                                          MaterialState
                                                              .hovered))
                                                        return Colors
                                                            .grey.shade100;
                                                      if (states.contains(
                                                              MaterialState
                                                                  .focused) ||
                                                          states.contains(
                                                              MaterialState
                                                                  .pressed))
                                                        return Colors
                                                            .grey.shade200;
                                                      return null; // Defer to the widget's default.
                                                    },
                                                  ),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    if (updateSuppliesFromList
                                                        .containsKey(snapshot
                                                                .data["Items"]
                                                            [i]['Name'])) {
                                                      updateSuppliesFromList
                                                          .remove(snapshot
                                                                  .data["Items"]
                                                              [i]['Name']);
                                                      widget
                                                          .removeSupplyFromList(
                                                              snapshot.data[
                                                                      "Items"]
                                                                  [i]['Name']);
                                                    } else {
                                                      updateSuppliesFromList[
                                                              snapshot.data[
                                                                      "Items"]
                                                                  [i]['Name']] =
                                                          snapshot.data["Items"]
                                                              [i]['Price'];
                                                      widget.addSupplyToList(
                                                          snapshot.data["Items"]
                                                              [i]['Name'],
                                                          snapshot.data["Items"]
                                                              [i]['Price']);
                                                    }
                                                  });
                                                },
                                                child: Center(
                                                    child: Text(
                                                  'Actualizar costo',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: (updateSuppliesFromList
                                                              .containsKey(snapshot
                                                                          .data[
                                                                      "Items"]
                                                                  [i]['Name']))
                                                          ? Colors.green
                                                          : Colors.black,
                                                      fontSize: 11),
                                                ))),
                                            SizedBox(
                                              width: 50,
                                            )
                                          ],
                                        )
                                      : SizedBox()
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

                //Boton de Agregar Items (cuadrado con +) => Lleva a seleccionar productos
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Tooltip(
                      message: 'Agregar item',
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () {
                          // for (var x = 0; x < 3; x++) {
                          //   _controllers.add(new TextEditingController());
                          // }
                          // var category = widget.dropdownCategories.first;

                          // double itemTotal;

                          // if (widget.costType == 'Costo de Ventas' &&
                          //     selectedSupplier != null &&
                          //     selectedSupplier.predefinedCategory != null &&
                          //     selectedSupplier.predefinedCategory != '') {
                          //   bloc.addToExpenseList({
                          //     'Name': '',
                          //     'Price': 0,
                          //     'Quantity': 1,
                          //     'Total Price': 0,
                          //     'Category': (selectedSupplier.predefinedCategory),
                          //   });
                          // } else if (widget.costType != 'Costo de Ventas' &&
                          //     selectedSupplier != null &&
                          //     selectedSupplier.predefinedAccount != null &&
                          //     selectedSupplier.predefinedAccount != '') {
                          //   bloc.addToExpenseList({
                          //     'Name':
                          //         selectedSupplier.initialExpenseDescription,
                          //     'Price': 0,
                          //     'Quantity': 1,
                          //     'Total Price': 0,
                          //     'Category': (widget.dropdownCategories.contains(
                          //             selectedSupplier.predefinedAccount))
                          //         ? selectedSupplier.predefinedAccount
                          //         : widget.dropdownCategories[0],
                          //   });
                          // } else {
                          //   bloc.addToExpenseList({
                          //     'Name': '',
                          //     'Price': 0,
                          //     'Quantity': 1,
                          //     'Total Price': 0,
                          //     'Category': widget.dropdownCategories[0]
                          //     // widget.snapshot.data["Items"][0]
                          //     //     ['Category' ],
                          //   });
                          // }
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AddExpenseItem(
                                    addExpenseItem,
                                    snapshot,
                                    snapshot.data['Items'].length,
                                    widget.dropdownCategories);
                                // if (snapshot.data["Items"][itemIndex]
                                //             ['Price'] !=
                                //         null &&
                                //     bloc.expenseItems["Items"][itemIndex]
                                //             ['Quantity'] !=
                                //         null) {
                                //   itemTotal = snapshot.data["Items"][itemIndex]
                                //           ['Price'] *
                                //       snapshot.data["Items"][itemIndex]
                                //           ['Quantity'];
                                // } else {
                                //   itemTotal = 0;
                                // }
                                // return Padding(
                                //   padding: const EdgeInsets.all(20.0),
                                //   child: Dialog(
                                //     shape: RoundedRectangleBorder(
                                //         borderRadius:
                                //             BorderRadius.circular(15.0)),
                                //     child: Container(
                                //       width: double.infinity,
                                //       height: double.infinity,
                                //       padding: EdgeInsets.all(20),
                                //       child: Column(
                                //         mainAxisAlignment:
                                //             MainAxisAlignment.start,
                                //         crossAxisAlignment:
                                //             CrossAxisAlignment.start,
                                //         children: [
                                //           //Back
                                //           Container(
                                //             width: double.infinity,
                                //             child: Row(
                                //               mainAxisAlignment:
                                //                   MainAxisAlignment.start,
                                //               children: [
                                //                 //Text
                                //                 Text(
                                //                   'Agregar Item',
                                //                 ),
                                //                 Spacer(),
                                //                 //IconButton
                                //                 IconButton(
                                //                     onPressed: () =>
                                //                         Navigator.of(context)
                                //                             .pop(),
                                //                     icon: Icon(
                                //                       Icons.close,
                                //                       color: Colors.black,
                                //                     )),
                                //               ],
                                //             ),
                                //           ),
                                //           SizedBox(height: 20),
                                //           //Producto
                                //           Text(
                                //             'Descripción',
                                //             textAlign: TextAlign.start,
                                //             style: TextStyle(
                                //                 fontWeight: FontWeight.w400,
                                //                 fontSize: 12,
                                //                 color: Colors.black45),
                                //           ),
                                //           SizedBox(height: 5),
                                //           Container(
                                //             height: 50,
                                //             width: double.infinity,
                                //             child: Center(
                                //               child: TextFormField(
                                //                 textAlign: TextAlign.left,
                                //                 style: TextStyle(
                                //                     fontWeight: FontWeight.w400,
                                //                     fontSize: 14,
                                //                     color: Colors.grey[700]),
                                //                 inputFormatters: [
                                //                   LengthLimitingTextInputFormatter(
                                //                       25)
                                //                 ],
                                //                 cursorColor: Colors.black,
                                //                 decoration: InputDecoration(
                                //                   floatingLabelBehavior:
                                //                       FloatingLabelBehavior
                                //                           .always,
                                //                   hintText:
                                //                       snapshot.data["Items"]
                                //                           [itemIndex]['Name'],
                                //                   label: Text(''),
                                //                   labelStyle: TextStyle(
                                //                       color: Colors.grey,
                                //                       fontSize: 12),
                                //                   errorStyle: TextStyle(
                                //                       color:
                                //                           Colors.redAccent[700],
                                //                       fontSize: 14),
                                //                   border:
                                //                       new OutlineInputBorder(
                                //                     borderRadius:
                                //                         new BorderRadius
                                //                             .circular(5.0),
                                //                     borderSide: new BorderSide(
                                //                       color: Colors.grey,
                                //                     ),
                                //                   ),
                                //                   focusedBorder:
                                //                       OutlineInputBorder(
                                //                     borderRadius:
                                //                         new BorderRadius
                                //                             .circular(5.0),
                                //                     borderSide: new BorderSide(
                                //                       color: Colors.green,
                                //                     ),
                                //                   ),
                                //                 ),
                                //                 onChanged: (val) {
                                //                   bloc.editProduct(
                                //                       itemIndex, val);
                                //                 },
                                //               ),
                                //             ),
                                //           ),
                                //           SizedBox(height: 15),
                                //           //Categoria
                                //           Text(
                                //             'Categoría',
                                //             textAlign: TextAlign.start,
                                //             style: TextStyle(
                                //                 fontWeight: FontWeight.w400,
                                //                 fontSize: 12,
                                //                 color: Colors.black45),
                                //           ),
                                //           SizedBox(height: 5),
                                //           Container(
                                //               decoration: BoxDecoration(
                                //                 border: Border.all(
                                //                     color: Colors.grey),
                                //                 borderRadius:
                                //                     BorderRadius.circular(5.0),
                                //               ),
                                //               padding: EdgeInsets.symmetric(
                                //                   horizontal: 12),
                                //               child: DropdownButton(
                                //                 isExpanded: true,
                                //                 underline: SizedBox(),
                                //                 hint: Text(
                                //                   snapshot.data["Items"]
                                //                       [itemIndex]['Category'],
                                //                   style: TextStyle(
                                //                       fontWeight:
                                //                           FontWeight.w400,
                                //                       fontSize: 14,
                                //                       color: Colors.grey[700]),
                                //                 ),
                                //                 style: TextStyle(
                                //                     fontWeight: FontWeight.w400,
                                //                     fontSize: 14,
                                //                     color: Colors.grey[700]),
                                //                 value: snapshot.data["Items"]
                                //                     [itemIndex]['Category'],
                                //                 items: widget.dropdownCategories
                                //                     .map((x) {
                                //                   return new DropdownMenuItem(
                                //                     value: x,
                                //                     child: new Text(x),
                                //                     onTap: () {
                                //                       setState(() {
                                //                         categoryInt = widget
                                //                             .dropdownCategories
                                //                             .indexOf(x);
                                //                         if (widget.costType ==
                                //                             'Costo de Ventas') {
                                //                           selectedAccount =
                                //                               'Costo de Ventas';
                                //                         }

                                //                         if (widget.costType ==
                                //                             'Costo de Ventas') {
                                //                           bloc.changeAccount(
                                //                               'Costo de Ventas');
                                //                           bloc.editCategory(
                                //                               itemIndex, x);
                                //                         } else {
                                //                           bloc.changeAccount(x);
                                //                           bloc.editCategory(
                                //                               itemIndex, x);
                                //                         }

                                //                         // bloc.editProduct(
                                //                         //     i,
                                //                         //     widget
                                //                         //         .accountsProvider
                                //                         //         .accountsMapping[widget.costType][categoryInt]['Description']);
                                //                       });
                                //                     },
                                //                   );
                                //                 }).toList(),
                                //                 onChanged: (newValue) {
                                //                   setState(() {
                                //                     snapshot.data["Items"]
                                //                             [itemIndex]
                                //                         ['Category'] = newValue;
                                //                   });
                                //                 },
                                //               )),
                                //           SizedBox(height: 15),
                                //           //Cantidad/Precio
                                //           Container(
                                //             height: 75,
                                //             width: double.infinity,
                                //             child: Row(
                                //               mainAxisAlignment:
                                //                   MainAxisAlignment.start,
                                //               crossAxisAlignment:
                                //                   CrossAxisAlignment.center,
                                //               children: [
                                //                 //Cantidad
                                //                 Expanded(
                                //                     flex: 3,
                                //                     child: Column(
                                //                       mainAxisAlignment:
                                //                           MainAxisAlignment
                                //                               .start,
                                //                       crossAxisAlignment:
                                //                           CrossAxisAlignment
                                //                               .start,
                                //                       children: [
                                //                         Text(
                                //                           'Cantidad ',
                                //                           textAlign:
                                //                               TextAlign.start,
                                //                           style: TextStyle(
                                //                               fontWeight:
                                //                                   FontWeight
                                //                                       .w400,
                                //                               fontSize: 12,
                                //                               color: Colors
                                //                                   .black45),
                                //                         ),
                                //                         SizedBox(height: 5),
                                //                         Expanded(
                                //                           child: TextFormField(
                                //                             initialValue: snapshot
                                //                                 .data["Items"]
                                //                                     [itemIndex]
                                //                                     ['Quantity']
                                //                                 .toString(),
                                //                             textAlign: TextAlign
                                //                                 .center,
                                //                             style: TextStyle(
                                //                                 fontWeight:
                                //                                     FontWeight
                                //                                         .w400,
                                //                                 fontSize: 14,
                                //                                 color: Colors
                                //                                     .grey[700]),
                                //                             validator: (val) =>
                                //                                 val.contains(
                                //                                         ',')
                                //                                     ? "Usa punto"
                                //                                     : null,
                                //                             inputFormatters: [
                                //                               FilteringTextInputFormatter
                                //                                   .allow(RegExp(
                                //                                       r'[0-9]+[,.]{0,1}[0-9]*')),
                                //                               TextInputFormatter
                                //                                   .withFunction(
                                //                                 (oldValue,
                                //                                         newValue) =>
                                //                                     newValue
                                //                                         .copyWith(
                                //                                   text: newValue
                                //                                       .text
                                //                                       .replaceAll(
                                //                                           ',',
                                //                                           '.'),
                                //                                 ),
                                //                               ),
                                //                             ],
                                //                             keyboardType:
                                //                                 TextInputType
                                //                                     .number,
                                //                             cursorColor:
                                //                                 Colors.black,
                                //                             decoration:
                                //                                 InputDecoration(
                                //                               floatingLabelBehavior:
                                //                                   FloatingLabelBehavior
                                //                                       .always,
                                //                               label: Text(''),
                                //                               labelStyle:
                                //                                   TextStyle(
                                //                                       color: Colors
                                //                                           .grey,
                                //                                       fontSize:
                                //                                           12),
                                //                               errorStyle: TextStyle(
                                //                                   color: Colors
                                //                                           .redAccent[
                                //                                       700],
                                //                                   fontSize: 14),
                                //                               border:
                                //                                   new OutlineInputBorder(
                                //                                 borderRadius:
                                //                                     new BorderRadius
                                //                                             .circular(
                                //                                         5.0),
                                //                                 borderSide:
                                //                                     new BorderSide(
                                //                                   color: Colors
                                //                                       .grey,
                                //                                 ),
                                //                               ),
                                //                               focusedBorder:
                                //                                   OutlineInputBorder(
                                //                                 borderRadius:
                                //                                     new BorderRadius
                                //                                             .circular(
                                //                                         5.0),
                                //                                 borderSide:
                                //                                     new BorderSide(
                                //                                   color: Colors
                                //                                       .green,
                                //                                 ),
                                //                               ),
                                //                             ),
                                //                             onChanged: (val) {
                                //                               bloc.editQuantity(
                                //                                   itemIndex,
                                //                                   double.parse(
                                //                                       val));
                                //                             },
                                //                           ),
                                //                         ),
                                //                       ],
                                //                     )),
                                //                 SizedBox(width: 10),
                                //                 //Precio
                                //                 Expanded(
                                //                     flex: 5,
                                //                     child: Column(
                                //                       mainAxisAlignment:
                                //                           MainAxisAlignment
                                //                               .start,
                                //                       crossAxisAlignment:
                                //                           CrossAxisAlignment
                                //                               .start,
                                //                       children: [
                                //                         Text(
                                //                           'Precio',
                                //                           textAlign:
                                //                               TextAlign.start,
                                //                           style: TextStyle(
                                //                               fontWeight:
                                //                                   FontWeight
                                //                                       .w400,
                                //                               fontSize: 12,
                                //                               color: Colors
                                //                                   .black45),
                                //                         ),
                                //                         SizedBox(height: 5),
                                //                         Expanded(
                                //                           child: TextFormField(
                                //                             textAlign: TextAlign
                                //                                 .center,
                                //                             style: TextStyle(
                                //                                 fontWeight:
                                //                                     FontWeight
                                //                                         .w400,
                                //                                 fontSize: 14,
                                //                                 color: Colors
                                //                                     .grey[700]),
                                //                             validator: (val) =>
                                //                                 val.contains(
                                //                                         ',')
                                //                                     ? "Usa punto"
                                //                                     : null,
                                //                             inputFormatters: [
                                //                               FilteringTextInputFormatter
                                //                                   .allow(RegExp(
                                //                                       r'[0-9]+[,.]{0,1}[0-9]*')),
                                //                               TextInputFormatter
                                //                                   .withFunction(
                                //                                 (oldValue,
                                //                                         newValue) =>
                                //                                     newValue
                                //                                         .copyWith(
                                //                                   text: newValue
                                //                                       .text
                                //                                       .replaceAll(
                                //                                           ',',
                                //                                           '.'),
                                //                                 ),
                                //                               ),
                                //                             ],
                                //                             keyboardType:
                                //                                 TextInputType
                                //                                     .number,
                                //                             cursorColor:
                                //                                 Colors.black,
                                //                             decoration:
                                //                                 InputDecoration(
                                //                               floatingLabelBehavior:
                                //                                   FloatingLabelBehavior
                                //                                       .always,
                                //                               hintText:
                                //                                   '\$0.00',
                                //                               label: Text(''),
                                //                               labelStyle:
                                //                                   TextStyle(
                                //                                       color: Colors
                                //                                           .grey,
                                //                                       fontSize:
                                //                                           12),
                                //                               errorStyle: TextStyle(
                                //                                   color: Colors
                                //                                           .redAccent[
                                //                                       700],
                                //                                   fontSize: 14),
                                //                               border:
                                //                                   new OutlineInputBorder(
                                //                                 borderRadius:
                                //                                     new BorderRadius
                                //                                             .circular(
                                //                                         5.0),
                                //                                 borderSide:
                                //                                     new BorderSide(
                                //                                   color: Colors
                                //                                       .grey,
                                //                                 ),
                                //                               ),
                                //                               focusedBorder:
                                //                                   OutlineInputBorder(
                                //                                 borderRadius:
                                //                                     new BorderRadius
                                //                                             .circular(
                                //                                         5.0),
                                //                                 borderSide:
                                //                                     new BorderSide(
                                //                                   color: Colors
                                //                                       .green,
                                //                                 ),
                                //                               ),
                                //                             ),
                                //                             onChanged: (val) {
                                //                               if (val != null &&
                                //                                   val != '') {
                                //                                 bloc.editPrice(
                                //                                     itemIndex,
                                //                                     double.tryParse(
                                //                                         (val)));
                                //                               } else if (val ==
                                //                                   '') {
                                //                                 bloc.editPrice(
                                //                                     itemIndex,
                                //                                     0);
                                //                               }
                                //                             },
                                //                           ),
                                //                         ),
                                //                       ],
                                //                     )),
                                //               ],
                                //             ),
                                //           ),
                                //           SizedBox(height: 20),
                                //           //Total
                                //           Container(
                                //             width: double.infinity,
                                //             child: Text(
                                //               'TOTAL: ${NumberFormat.simpleCurrency().format(0)}',
                                //               textAlign: TextAlign.right,
                                //               style: TextStyle(
                                //                   fontWeight: FontWeight.w600,
                                //                   fontSize: 16,
                                //                   color: Colors.black),
                                //             ),
                                //           ),
                                //           Spacer(),
                                //           //Agregar Boton
                                //           Container(
                                //               height: 35.0,
                                //               width: double.infinity,
                                //               child: ElevatedButton(
                                //                 style: ElevatedButton.styleFrom(
                                //                   backgroundColor: Colors.black,
                                //                   minimumSize: Size(300, 50),
                                //                   padding: EdgeInsets.symmetric(
                                //                       horizontal: 15),
                                //                   shape:
                                //                       const RoundedRectangleBorder(
                                //                     borderRadius:
                                //                         BorderRadius.all(
                                //                             Radius.circular(8)),
                                //                   ),
                                //                 ),
                                //                 onPressed: () =>
                                //                     Navigator.of(context).pop(),
                                //                 child: Text(
                                //                   "Agregar",
                                //                   textAlign: TextAlign.center,
                                //                   style: TextStyle(
                                //                       fontSize: 12,
                                //                       fontWeight:
                                //                           FontWeight.w500,
                                //                       color: Colors.white),
                                //                 ),
                                //               ))
                                //         ],
                                //       ),
                                //     ),
                                //   ),
                                // );
                              });
                        },
                        child: Container(
                          height: 70,
                          width: 70,
                          child: Center(
                              child: Icon(
                            Icons.add,
                            color: Colors.black87,
                            size: 30,
                          )),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
              ],
            );
          }
        });
  }
}
