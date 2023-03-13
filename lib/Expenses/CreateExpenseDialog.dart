import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Expenses/CreateExpenseDialogForm.dart';
import 'package:denario/Expenses/CreateExpensePaymentButtons.dart';
import 'package:denario/Expenses/CreateExpenseUseCashierMoney.dart';
import 'package:denario/Expenses/SelectVendorExpense.dart';
import 'package:denario/Expenses/VendorsProductsTags.dart';
import 'package:denario/Expenses/VendorsTags.dart';
import 'package:denario/Models/DailyCash.dart';
import 'package:denario/Models/Supplier.dart';
import 'package:denario/Models/Supply.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../Backend/Expense.dart';

class CreateExpenseDialog extends StatefulWidget {
  final String costType;
  final CashRegister registerStatus;
  final DailyTransactions dailyTransactions;
  final clearVariables;
  final String activeBusiness;
  final List dropdownCategories;
  final DateTime selectedIvoiceDate;
  final resetDate;

  CreateExpenseDialog(
      this.costType,
      this.registerStatus,
      this.dailyTransactions,
      this.clearVariables,
      this.activeBusiness,
      this.dropdownCategories,
      this.selectedIvoiceDate,
      this.resetDate);

  get currentRegister => null;

  String get transactionType => null;

  @override
  _CreateExpenseDialogState createState() => _CreateExpenseDialogState();
}

class _CreateExpenseDialogState extends State<CreateExpenseDialog> {
  final formatCurrency = new NumberFormat.simpleCurrency();

  //Payment Variables
  String paymentType = 'Efectivo';
  double currentCostTypeAmount = 0;
  double currentAccountAmount = 0;
  double currentCategoryAmount = 0;
  Future currentValuesBuilt;
  bool isChecked;
  double cashRegisterAmount = 0;
  bool useEntireAmount;
  double total;

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

  String costAccount = '';
  List dropdownCategories = [];
  List dropdownVendors = [];
  int accountInt = 0;

  var random = new Random();
  setSearchParam(String caseNumber) {
    List<String> caseSearchList = [];
    String temp = "";
    for (int i = 0; i < caseNumber.length; i++) {
      temp = temp + caseNumber[i];
      caseSearchList.add(temp);
    }
    return caseSearchList;
  }

  //Expense total variables
  ValueKey redrawObject = ValueKey('List');
  bool showList = true;
  double expenseTotal = 0;
  Map<String, dynamic> expenseCategories;

  Future currentValue() async {
    var firestore = FirebaseFirestore.instance;

    var docRef = firestore
        .collection('ERP')
        .doc(widget.activeBusiness)
        .collection(widget.selectedIvoiceDate.year.toString())
        .doc(widget.selectedIvoiceDate.month.toString())
        .get();
    return docRef;
  }

  void selectPayment(payment) {
    paymentType = payment;
  }

  void clearVariables() {
    setState(() {
      showList = false;
    });
  }

  double totalAmount(snapshot) {
    double total = 0;
    snapshot.data['Items'].forEach((x) {
      total = total + x['Total Price'];
    });

    return total;
  }

  // final List<String> meses = [
  //   'enero',
  //   'febrero',
  //   'marzo',
  //   'abril',
  //   'mayo',
  //   'junio',
  //   'julio',
  //   'agosto',
  //   'septiembre',
  //   'octubre',
  //   'noviembre',
  //   'diciembre'
  // ];

  //Vendor
  void setShowVendorTags(show) {
    showVendorTags = show;
  }

  String vendorName;
  String selectedVendor = '';
  bool showSearchOptions = true;
  bool showListofVendors = false;
  TextEditingController searchController = new TextEditingController();
  String predefinedCategory;
  String predefinedDescription;
  Supplier selectedSupplier;
  bool saveVendor;
  bool saveVendorPressed;
  bool showVendorTags;
  String invoiceReference = '';
  void saveNewVendor() {
    saveVendor = true;
    saveVendorPressed = true;
  }

  void selectVendor(Supplier vendor) {
    setState(() {
      selectedVendor = vendor.name;
      vendorName = vendor.name;
      searchController.text = vendor.name;
      showSearchOptions = false;
      showListofVendors = false;
      predefinedCategory = vendor.predefinedCategory;
      predefinedDescription = vendor.initialExpenseDescription;
      selectedSupplier = vendor;
      saveVendor = false;
      saveVendorPressed = false;
      showVendorTags = false;
    });

    // if (widget.costType == 'Costo de Ventas' &&
    //     bloc.expenseItems['Items'].length <= 1 &&
    //     vendor.predefinedCategory != null &&
    //     vendor.predefinedCategory != '' &&
    //     widget.dropdownCategories.contains(vendor.predefinedCategory)) {
    //   //Editar categoria de la primera linea
    //   bloc.editCategory(0, vendor.predefinedCategory);
    // } else
    if (widget.costType != 'Costo de Ventas' &&
        bloc.expenseItems['Items'].length <= 1 &&
        vendor.predefinedAccount != null &&
        vendor.predefinedAccount != '' &&
        widget.dropdownCategories.contains(vendor.predefinedAccount)) {
      //Editar cuenta y descripcion de la primera linea
      bloc.editCategory(0, vendor.predefinedAccount);
      bloc.editProduct(0, vendor.initialExpenseDescription);
    }
    bloc.changeVendor(selectedVendor = vendor.name);
  }

  void showVendorOptionsfromParent(show) {
    showSearchOptions = show;
  }

  void showVendorTagsfromParent(show) {
    showVendorTags = show;
  }

  void addProduct(Supplier selectedSupplier, snapshot, Supply supply) {
    for (var x = 0; x < 3; x++) {
      _controllers.add(new TextEditingController());
    }

    if (widget.costType == 'Costo de Ventas' &&
        selectedSupplier != null &&
        selectedSupplier.predefinedCategory != null &&
        selectedSupplier.predefinedCategory != '') {
      bloc.addToExpenseList({
        'Name': supply.supply,
        'Base Price': supply.price,
        'Price': supply.price,
        'Quantity': 1,
        'Total Price': supply.price,
        'Category': (selectedSupplier.predefinedCategory),
      });
    } else if (widget.costType != 'Costo de Ventas' &&
        selectedSupplier != null &&
        selectedSupplier.predefinedAccount != null &&
        selectedSupplier.predefinedAccount != '') {
      bloc.addToExpenseList({
        'Name': supply.supply,
        'Base Price': supply.price,
        'Price': supply.price,
        'Quantity': 1,
        'Total Price': supply.price,
        'Category': selectedSupplier.predefinedAccount,
      });
    } else {
      bloc.addToExpenseList({
        'Name': supply.supply,
        'Base Price': supply.price,
        'Price': supply.price,
        'Quantity': 1,
        'Total Price': supply.price,
        'Category': snapshot.data["Items"][0]['Category'],
      });
    }
  }

  Map updateSuppliesFromList = {};

  void removeSupplyFromList(val) {
    updateSuppliesFromList.remove(val);
  }

  void addSupplyToList(name, price) {
    updateSuppliesFromList[name] = price;
  }

  void setInvoiceReference(val) {
    invoiceReference = val;
  }

  double expenseTotalAmount(snapshot) {
    double total = 0;
    for (var i = 0; i < snapshot.data['Items'].length; i++) {
      total += snapshot.data['Items'][i]["Price"] *
          snapshot.data['Items'][i]["Quantity"];
    }
    return total;
  }

  void moneyFromCashier(amount) {
    cashRegisterAmount = amount;
  }

  void checkCashierMoneyBox(val) {
    isChecked = val;
  }

  @override
  void initState() {
    showVendorTags = true;
    isChecked = false;
    useEntireAmount = false;
    dropdownCategories = widget.dropdownCategories;
    currentValuesBuilt = currentValue();
    expenseTotal = 0;
    saveVendor = false;
    saveVendorPressed = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: currentValuesBuilt,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.done) {
            return StreamBuilder(
                stream: bloc.getExpenseStream,
                initialData: bloc.expenseItems,
                builder: (context, snapshot) {
                  return SingleChildScrollView(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        // if (vendorName != '' && vendorName != null) {
                        showSearchOptions = false;
                        saveVendor = true;
                        // }
                      }),
                      child: Dialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.75,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 20),
                            child: Stack(children: [
                              //Form
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 160,
                                  ),
                                  //Vendors Tags
                                  (showVendorTags)
                                      ? StreamProvider<List<Supplier>>.value(
                                          value: DatabaseService()
                                              .suppliersListbyCategory(
                                                  widget.activeBusiness,
                                                  widget.costType),
                                          initialData: null,
                                          child: VendorsTags(selectVendor))
                                      : SizedBox(),
                                  SizedBox(height: 15),
                                  //Titles
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      //Account
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          (widget.costType == 'Costo de Ventas')
                                              ? 'Categoría'
                                              : 'Cuenta',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              color: Colors.grey[400]),
                                        ),
                                      ),
                                      SizedBox(width: 15),
                                      // Description
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          'Descripción',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              color: Colors.grey[400]),
                                        ),
                                      ),
                                      SizedBox(width: 15),
                                      // Qty
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          'Cantidad',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              color: Colors.grey[400]),
                                        ),
                                      ),
                                      SizedBox(width: 15),
                                      //Price
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Precio',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              color: Colors.grey[400]),
                                        ),
                                      ),
                                      SizedBox(width: 15),
                                      //Total
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Total',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              color: Colors.grey[400]),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      //Detele
                                      SizedBox(width: 30),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  //Form
                                  (showList)
                                      ? CreateExpenseDialogForm(
                                          widget.costType,
                                          dropdownCategories,
                                          snapshot,
                                          removeSupplyFromList,
                                          addSupplyToList)
                                      : Container(),
                                  //Tags de productos
                                  (widget.costType == 'Costo de Ventas')
                                      ? StreamProvider<List<Supply>>.value(
                                          value: DatabaseService()
                                              .suppliesListbyVendor(
                                                  widget.activeBusiness,
                                                  snapshot.data['Vendor']
                                                      .toLowerCase()),
                                          initialData: null,
                                          child: VendorProductsTags(snapshot,
                                              selectedSupplier, addProduct))
                                      : SizedBox(),
                                  //Total
                                  Padding(
                                    padding: const EdgeInsets.only(right: 20.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Total: " +
                                              formatCurrency.format(
                                                  totalAmount(snapshot)),
                                          // "Total: \$${totalAmount(snapshot)}",
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Title
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Método de pago",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 25,
                                  ),
                                  // Payment Buttons
                                  CreateExpensePaymentButtons(selectPayment),
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
                                  (paymentType == 'Efectivo' &&
                                          widget.dailyTransactions != null)
                                      ? CreateExpenseUseCashierMoney(
                                          snapshot,
                                          expenseTotalAmount(snapshot),
                                          moneyFromCashier,
                                          checkCashierMoneyBox)
                                      : Container(),
                                  SizedBox(
                                    height: 25,
                                  ),
                                  //Boton
                                  Container(
                                    height: 35.0,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        minimumSize: Size(300, 50),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15),
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(25)),
                                        ),
                                      ),
                                      onPressed: () async {
                                        for (var i = 0;
                                            i < snapshot.data['Items'].length;
                                            i++) {
                                          expenseTotal += snapshot.data['Items']
                                                  [i]["Price"] *
                                              snapshot.data['Items'][i]
                                                  ["Quantity"];
                                        }

                                        //////////Save expense
                                        var docID = DateTime.now().toString();
                                        DatabaseService().saveExpense(
                                            widget.activeBusiness,
                                            widget.costType,
                                            (snapshot.data["Vendor"] != '' &&
                                                    snapshot.data["Vendor"] !=
                                                        null)
                                                ? snapshot.data["Vendor"]
                                                : vendorName,
                                            expenseTotal,
                                            paymentType,
                                            snapshot.data["Items"],
                                            widget.selectedIvoiceDate,
                                            widget.selectedIvoiceDate.year
                                                .toString(),
                                            widget.selectedIvoiceDate.month
                                                .toString(),
                                            widget.registerStatus.registerName,
                                            false,
                                            (isChecked &&
                                                    widget.registerStatus
                                                        .registerisOpen)
                                                ? true
                                                : false,
                                            (isChecked &&
                                                    widget.registerStatus
                                                        .registerisOpen)
                                                ? cashRegisterAmount
                                                : 0,
                                            docID,
                                            setSearchParam(
                                              (snapshot.data["Vendor"] != '' &&
                                                      snapshot.data["Vendor"] !=
                                                          null)
                                                  ? snapshot.data["Vendor"]
                                                      .toLowerCase()
                                                  : vendorName.toLowerCase(),
                                            ),
                                            invoiceReference);

                                        //Payable
                                        if (paymentType == 'Por pagar') {
                                          DatabaseService().createPayable(
                                              widget.activeBusiness,
                                              widget.costType,
                                              (snapshot.data["Vendor"] != '' &&
                                                      snapshot.data["Vendor"] !=
                                                          null)
                                                  ? snapshot.data["Vendor"]
                                                  : vendorName,
                                              expenseTotal,
                                              paymentType,
                                              snapshot.data["Items"],
                                              widget.selectedIvoiceDate,
                                              docID,
                                              setSearchParam(
                                                (snapshot.data["Vendor"] !=
                                                            '' &&
                                                        snapshot.data[
                                                                "Vendor"] !=
                                                            null)
                                                    ? snapshot.data["Vendor"]
                                                        .toLowerCase()
                                                    : vendorName.toLowerCase(),
                                              ),
                                              invoiceReference);
                                        }

                                        //Save to Vendor
                                        if (selectedVendor != '' &&
                                            selectedVendor != null) {
                                          DatabaseService()
                                              .associateExpensetoVendor(
                                                  widget.activeBusiness,
                                                  docID,
                                                  invoiceReference,
                                                  DateTime.now(),
                                                  selectedVendor,
                                                  expenseTotal,
                                                  (paymentType == 'Por pagar')
                                                      ? true
                                                      : false);
                                        }

                                        //////////Loop over items to save expense
                                        try {
                                          currentCostTypeAmount =
                                              snap.data[widget.costType] +
                                                  expenseTotal;
                                        } catch (e) {
                                          currentCostTypeAmount = expenseTotal;
                                        }

                                        //Create map to get categories totals
                                        expenseCategories = {};

                                        for (var i = 0;
                                            i < snapshot.data["Items"].length;
                                            i++) {
                                          if (widget.costType ==
                                              'Costo de Ventas') {
                                            //Check if the map contains the key
                                            if (expenseCategories.containsKey(
                                                'Costos de ${snapshot.data["Items"][i]["Category"]}')) {
                                              //Add to existing category amount
                                              expenseCategories.update(
                                                  'Costos de ${snapshot.data["Items"][i]["Category"]}',
                                                  (value) =>
                                                      value +
                                                      (snapshot.data["Items"][i]
                                                              ["Price"] *
                                                          snapshot.data["Items"]
                                                              [i]["Quantity"]));
                                            } else {
                                              //Add new category with amount
                                              expenseCategories[
                                                      'Costos de ${snapshot.data["Items"][i]["Category"]}'] =
                                                  snapshot.data["Items"][i]
                                                          ["Price"] *
                                                      snapshot.data["Items"][i]
                                                          ["Quantity"];
                                            }
                                          } else {
                                            //Check if the map contains the key
                                            if (expenseCategories.containsKey(
                                                '${snapshot.data["Items"][i]["Category"]}')) {
                                              //Add to existing category amount
                                              expenseCategories.update(
                                                  '${snapshot.data["Items"][i]["Category"]}',
                                                  (value) =>
                                                      value +
                                                      (snapshot.data["Items"][i]
                                                              ["Price"] *
                                                          snapshot.data["Items"]
                                                              [i]["Quantity"]));
                                            } else {
                                              //Add new category with amount
                                              expenseCategories[
                                                      '${snapshot.data["Items"][i]["Category"]}'] =
                                                  snapshot.data["Items"][i]
                                                          ["Price"] *
                                                      snapshot.data["Items"][i]
                                                          ["Quantity"];
                                            }
                                          }
                                        }
                                        //Logic to add Sales by Categories to Firebase based on current Values from snap
                                        expenseCategories.forEach((k, v) {
                                          try {
                                            expenseCategories.update(
                                                k,
                                                (value) =>
                                                    v = v + snap.data['$k']);
                                          } catch (e) {
                                            //Do nothing
                                          }
                                        });

                                        //Add cost type account to MAP
                                        expenseCategories[widget.costType] =
                                            currentCostTypeAmount;

                                        DatabaseService().saveExpenseType(
                                            widget.activeBusiness,
                                            expenseCategories,
                                            widget.selectedIvoiceDate.year
                                                .toString(),
                                            widget.selectedIvoiceDate.month
                                                .toString());

                                        ///////////If we use money in cash register ///////////////
                                        if (isChecked &&
                                            widget.registerStatus
                                                .registerisOpen) {
                                          double totalTransactionAmount = widget
                                                  .dailyTransactions.outflows +
                                              cashRegisterAmount;

                                          double totalTransactions = widget
                                                  .dailyTransactions
                                                  .dailyTransactions -
                                              cashRegisterAmount;

                                          DatabaseService().updateCashRegister(
                                              widget.activeBusiness,
                                              widget
                                                  .registerStatus.registerName,
                                              'Egresos',
                                              totalTransactionAmount,
                                              totalTransactions,
                                              {
                                                'Amount': cashRegisterAmount,
                                                'Type': widget.costType,
                                                'Motive': (snapshot
                                                            .data["Items"]
                                                            .length >
                                                        1)
                                                    ? '${snapshot.data["Items"][0]['Name']}...'
                                                    : snapshot.data["Items"][0]
                                                        ['Name'],
                                                'Time': DateTime.now()
                                              });
                                        }

                                        //Save vendor
                                        if (saveVendor && saveVendorPressed) {
                                          int min =
                                              10000; //min and max values act as your 6 digit range
                                          int max = 99999;
                                          var rNum =
                                              min + random.nextInt(max - min);

                                          DatabaseService().createSupplier(
                                              widget.activeBusiness,
                                              snapshot.data["Vendor"],
                                              setSearchParam(snapshot.data["Vendor"]
                                                  .toLowerCase()),
                                              0,
                                              '',
                                              1100000000,
                                              '',
                                              (snapshot.data["Items"][0]['Category'] != '' &&
                                                      snapshot.data["Items"][0]
                                                              ['Category'] !=
                                                          null)
                                                  ? snapshot.data["Items"][0]
                                                      ['Category']
                                                  : widget
                                                      .dropdownCategories[0],
                                              (snapshot.data["Items"][0]['Name'] != '' &&
                                                      snapshot.data["Items"][0]['Name'] !=
                                                          null)
                                                  ? snapshot.data["Items"][0]
                                                      ['Name']
                                                  : '',
                                              (widget.costType == 'Costo de Ventas')
                                                  ? 'Costo de Ventas'
                                                  : snapshot.data["Items"][0]
                                                      ['Category'],
                                              [widget.costType],
                                              rNum);
                                        }

                                        //Update supplies and product Prices
                                        if (updateSuppliesFromList.length > 0) {
                                          //Update supplies
                                          updateSuppliesFromList
                                              .forEach((key, value) async {
                                            await FirebaseFirestore.instance
                                                .collection("ERP")
                                                .doc(widget.activeBusiness)
                                                .collection("Supplies")
                                                .doc(key)
                                                .get()
                                                .then((snapshot) {
                                              List historicPrices =
                                                  snapshot['Price History'];

                                              historicPrices.last['To Date'] =
                                                  DateTime.now();

                                              historicPrices.add({
                                                'From Date': DateTime.now(),
                                                'To Date': null,
                                                'Price': value
                                              });

                                              DatabaseService().editSupplyCost(
                                                  widget.activeBusiness,
                                                  key,
                                                  value,
                                                  historicPrices);
                                            });
                                          });
                                          //Update Products containing this supply
                                          List updatedDocuments = [];

                                          updateSuppliesFromList
                                              .forEach((key, value) async {
                                            await FirebaseFirestore.instance
                                                .collection("Products")
                                                .doc(widget.activeBusiness)
                                                .collection("Menu")
                                                .where('List Of Ingredients',
                                                    arrayContains: key)
                                                .get()
                                                .then((snapshot) =>
                                                    List.from(snapshot.docs)
                                                        .forEach((doc) {
                                                      if (updatedDocuments
                                                          .contains(doc.id)) {
                                                        //
                                                      } else {
                                                        //Take list of ingredients
                                                        List ingredients =
                                                            doc['Ingredients'];
                                                        //Identify which has ingredient to update (named like KEY)
                                                        for (var x = 0;
                                                            x <
                                                                ingredients
                                                                    .length;
                                                            x++) {
                                                          //Update price in this index
                                                          updateSuppliesFromList
                                                              .forEach((y, z) {
                                                            if (ingredients[x][
                                                                    'Ingredient'] ==
                                                                y) {
                                                              ingredients[x][
                                                                  'Supply Cost'] = z;
                                                            }
                                                          });
                                                        }
                                                        DatabaseService()
                                                            .editProductSupply(
                                                                widget
                                                                    .activeBusiness,
                                                                doc.id,
                                                                ingredients);
                                                        updatedDocuments
                                                            .add(doc.id);
                                                      }
                                                    }));
                                          });
                                        }

                                        setState(() {
                                          showList = false;
                                        });
                                        widget.clearVariables();
                                        widget.resetDate();

                                        //Clear Expenses Variables and go back
                                        bloc.removeAllFromExpense();
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        "REGISTRAR",
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
                              ),
                              //Inicio y proveedor
                              SelectVendorExpense(
                                  widget.activeBusiness,
                                  widget.selectedIvoiceDate,
                                  widget.costType,
                                  widget.dropdownCategories,
                                  setInvoiceReference,
                                  setShowVendorTags,
                                  showSearchOptions,
                                  showVendorOptionsfromParent,
                                  showVendorTagsfromParent,
                                  saveVendor,
                                  saveNewVendor,
                                  snapshot.data["Vendor"])
                            ]),
                          ),
                        ),
                      ),
                    ),
                  );
                });
          } else {
            return SingleChildScrollView(
              child: Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: 700,
                    constraints: BoxConstraints(minHeight: 400, minWidth: 400),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            alignment: Alignment(1.0, 0.0),
                            child: IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(Icons.close),
                                iconSize: 20.0),
                          ),
                          SizedBox(height: 10),
                          Container(
                              height: 30,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  color: Colors.grey.shade300)),
                          SizedBox(height: 10),
                          Container(
                              height: 30,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  color: Colors.grey.shade300)),
                          SizedBox(height: 10),
                          Container(
                              height: 25,
                              width: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  color: Colors.grey.shade300)),
                          SizedBox(height: 30),
                          Container(
                              height: 25,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  color: Colors.grey.shade300)),
                          SizedBox(height: 50),
                          Container(
                            height: 100,
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                    height: 75,
                                    width: 75,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black38)),
                                Container(
                                    height: 75,
                                    width: 75,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black38)),
                                Container(
                                    height: 75,
                                    width: 75,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black38)),
                                Container(
                                    height: 75,
                                    width: 75,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black38)),
                              ],
                            ),
                          ),
                          SizedBox(height: 25),
                        ],
                      ),
                    ),
                  )),
            );
          }
        });
  }
}
