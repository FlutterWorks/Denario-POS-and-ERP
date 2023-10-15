import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Expenses/CreateExpenseDialogForm.dart';
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

  CreateExpenseDialog(
      this.costType,
      this.registerStatus,
      this.dailyTransactions,
      this.clearVariables,
      this.activeBusiness,
      this.dropdownCategories);

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

  DateTime selectedIvoiceDate;

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
  Map<String, dynamic> expenseCategories;

  void selectPayment(payment) {
    paymentType = payment;
  }

  void clearVariables() {
    setState(() {
      showList = false;
    });
  }

  //Vendor
  void setShowVendorTags(show) {
    showVendorTags = show;
  }

  String vendorName;
  String selectedVendor = '';
  bool showSearchOptions;
  bool showListofVendors;
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

  void showVendorOptionsfromParent(bool show) {
    setState(() {
      showSearchOptions = show;
    });
  }

  void showVendorTagsfromParent(bool show) {
    setState(() {
      showVendorTags = show;
    });
  }

  void addProduct(Supplier selectedSupplier, Supply supply) {
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
        'Category': bloc.expenseItems["Items"][0]['Category'],
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

  void selectInvoiceDate(date) {
    setState(() {
      selectedIvoiceDate = date;
    });
  }

  @override
  void initState() {
    showSearchOptions = true;
    showListofVendors = false;
    showVendorTags = true;
    isChecked = false;
    useEntireAmount = false;
    dropdownCategories = widget.dropdownCategories;
    saveVendor = false;
    saveVendorPressed = false;
    selectedIvoiceDate = DateTime.now();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width > 650) {
      return SingleChildScrollView(
        child: GestureDetector(
          onTap: () => setState(() {
            if (showSearchOptions == true) {
              showSearchOptions = false;
              saveVendor = true;
            }
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
                              value: DatabaseService().suppliersListbyCategory(
                                  widget.activeBusiness, widget.costType),
                              initialData: null,
                              child: VendorsTags(selectVendor))
                          : SizedBox(),
                      SizedBox(height: 15),
                      //Titles
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                              removeSupplyFromList,
                              addSupplyToList,
                              widget.activeBusiness)
                          : Container(),
                      //Tags de productos
                      (widget.costType == 'Costo de Ventas')
                          ? StreamProvider<List<Supply>>.value(
                              value: DatabaseService().suppliesListbyVendor(
                                  widget.activeBusiness,
                                  bloc.expenseItems['Vendor'].toLowerCase()),
                              initialData: null,
                              child: VendorProductsTags(
                                  selectedSupplier, addProduct))
                          : SizedBox(),
                      //Total
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [TotalExpenseAmount()],
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
                      // Use money in petty cash?
                      CreateExpenseUseCashierMoney(
                          bloc.totalExpenseAmount,
                          moneyFromCashier,
                          checkCashierMoneyBox,
                          selectPayment,
                          widget.dailyTransactions,
                          widget.registerStatus),
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
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25)),
                            ),
                          ),
                          onPressed: () async {
                            //////////Save expense
                            var docID = DateTime.now().toString();
                            var cartList = bloc.expenseItems['Items'];
                            DatabaseService().saveExpense(
                                widget.activeBusiness,
                                widget.costType,
                                (bloc.expenseItems["Vendor"] != '' &&
                                        bloc.expenseItems["Vendor"] != null)
                                    ? bloc.expenseItems["Vendor"]
                                    : vendorName,
                                bloc.totalExpenseAmount,
                                paymentType,
                                bloc.expenseItems["Items"],
                                selectedIvoiceDate,
                                selectedIvoiceDate.year.toString(),
                                selectedIvoiceDate.month.toString(),
                                widget.registerStatus.registerName,
                                false,
                                (isChecked &&
                                        widget.registerStatus.registerisOpen)
                                    ? true
                                    : false,
                                (isChecked &&
                                        widget.registerStatus.registerisOpen)
                                    ? cashRegisterAmount
                                    : 0,
                                docID,
                                setSearchParam(
                                  (bloc.expenseItems["Vendor"] != '' &&
                                          bloc.expenseItems["Vendor"] != null)
                                      ? bloc.expenseItems["Vendor"]
                                          .toLowerCase()
                                      : vendorName.toLowerCase(),
                                ),
                                invoiceReference);

                            //Payable
                            if (paymentType == 'Por pagar') {
                              DatabaseService().createPayable(
                                  widget.activeBusiness,
                                  widget.costType,
                                  (bloc.expenseItems["Vendor"] != '' &&
                                          bloc.expenseItems["Vendor"] != null)
                                      ? bloc.expenseItems["Vendor"]
                                      : vendorName,
                                  bloc.totalExpenseAmount,
                                  paymentType,
                                  bloc.expenseItems["Items"],
                                  selectedIvoiceDate,
                                  docID,
                                  setSearchParam(
                                    (bloc.expenseItems["Vendor"] != '' &&
                                            bloc.expenseItems["Vendor"] != null)
                                        ? bloc.expenseItems["Vendor"]
                                            .toLowerCase()
                                        : vendorName.toLowerCase(),
                                  ),
                                  invoiceReference);
                            }

                            //Save to Vendor
                            if (selectedVendor != '' &&
                                selectedVendor != null) {
                              DatabaseService().associateExpensetoVendor(
                                  widget.activeBusiness,
                                  docID,
                                  invoiceReference,
                                  DateTime.now(),
                                  selectedVendor,
                                  bloc.totalExpenseAmount,
                                  (paymentType == 'Por pagar') ? true : false);
                            }

                            //////////Loop over items to save expense type and subaccounts

                            //Firestore reference
                            var firestore = FirebaseFirestore.instance;
                            var docRef = firestore
                                .collection('ERP')
                                .doc(widget.activeBusiness)
                                .collection(selectedIvoiceDate.year.toString())
                                .doc(selectedIvoiceDate.month.toString());

                            final doc = await docRef.get();
                            //Save Expense Type new amount
                            try {
                              if (doc.exists) {
                                docRef.update({
                                  '${widget.costType}': FieldValue.increment(
                                      bloc.totalExpenseAmount)
                                });
                              } else {
                                docRef.set({
                                  '${widget.costType}': bloc.totalExpenseAmount
                                });
                              }
                            } catch (error) {
                              print(
                                  'Error updating Total Expense Value: $error');
                            }

                            //Create map to get categories totals
                            expenseCategories = {};

                            for (var i = 0; i < cartList.length; i++) {
                              if (widget.costType == 'Costo de Ventas') {
                                //Check if the map contains the key
                                if (expenseCategories.containsKey(
                                    'Costos de ${cartList[i]["Category"]}')) {
                                  //Add to existing category amount
                                  expenseCategories.update(
                                      'Costos de ${cartList[i]["Category"]}',
                                      (value) =>
                                          value +
                                          (cartList[i]["Price"] *
                                              cartList[i]["Quantity"]));
                                } else {
                                  //Add new category with amount
                                  expenseCategories[
                                          'Costos de ${cartList[i]["Category"]}'] =
                                      cartList[i]["Price"] *
                                          cartList[i]["Quantity"];
                                }
                              } else {
                                //Check if the map contains the key
                                if (expenseCategories.containsKey(
                                    '${cartList[i]["Category"]}')) {
                                  //Add to existing category amount
                                  expenseCategories.update(
                                      '${cartList[i]["Category"]}',
                                      (value) =>
                                          value +
                                          (cartList[i]["Price"] *
                                              cartList[i]["Quantity"]));
                                } else {
                                  //Add new category with amount
                                  expenseCategories[
                                          '${cartList[i]["Category"]}'] =
                                      cartList[i]["Price"] *
                                          cartList[i]["Quantity"];
                                }
                              }
                            }

                            //Logic to add Expense by Categories to Firebase
                            expenseCategories.forEach((k, v) {
                              docRef.update({k: FieldValue.increment(v)});
                            });

                            ///////////If we use money in cash register ///////////////
                            if (isChecked &&
                                widget.registerStatus.registerisOpen) {
                              double totalTransactionAmount =
                                  widget.dailyTransactions.outflows +
                                      cashRegisterAmount;

                              double totalTransactions =
                                  widget.dailyTransactions.dailyTransactions -
                                      cashRegisterAmount;

                              DatabaseService().updateCashRegister(
                                  widget.activeBusiness,
                                  widget.registerStatus.registerName,
                                  'Egresos',
                                  totalTransactionAmount,
                                  totalTransactions, {
                                'Amount': cashRegisterAmount,
                                'Type': widget.costType,
                                'Motive': (bloc.expenseItems["Items"].length >
                                        1)
                                    ? '${bloc.expenseItems["Items"][0]['Name']}...'
                                    : bloc.expenseItems["Items"][0]['Name'],
                                'Time': DateTime.now()
                              });
                            }

                            //Save vendor
                            if (saveVendor && saveVendorPressed) {
                              int min =
                                  10000; //min and max values act as your 6 digit range
                              int max = 99999;
                              var rNum = min + random.nextInt(max - min);

                              DatabaseService().createSupplier(
                                  widget.activeBusiness,
                                  bloc.expenseItems["Vendor"],
                                  setSearchParam(bloc.expenseItems["Vendor"]
                                      .toLowerCase()),
                                  0,
                                  '',
                                  1100000000,
                                  '',
                                  (bloc.expenseItems["Items"][0]['Category'] !=
                                              '' &&
                                          bloc.expenseItems["Items"][0]
                                                  ['Category'] !=
                                              null)
                                      ? bloc.expenseItems["Items"][0]
                                          ['Category']
                                      : widget.dropdownCategories[0],
                                  (bloc.expenseItems["Items"][0]['Name'] !=
                                              '' &&
                                          bloc.expenseItems["Items"][0]
                                                  ['Name'] !=
                                              null)
                                      ? bloc.expenseItems["Items"][0]['Name']
                                      : '',
                                  (widget.costType == 'Costo de Ventas')
                                      ? 'Costo de Ventas'
                                      : bloc.expenseItems["Items"][0]
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
                              List updatedSupplyDocuments = [];

                              updateSuppliesFromList
                                  .forEach((key, value) async {
                                //Update Business products in MENU
                                await FirebaseFirestore.instance
                                    .collection("Products")
                                    .doc(widget.activeBusiness)
                                    .collection("Menu")
                                    .where('List Of Ingredients',
                                        arrayContains: key)
                                    .get()
                                    .then((snapshot) =>
                                        List.from(snapshot.docs).forEach((doc) {
                                          if (updatedDocuments
                                              .contains(doc.id)) {
                                            //
                                          } else {
                                            //Take list of ingredients
                                            List ingredients =
                                                doc['Ingredients'];
                                            //Identify which has ingredient to update (named like KEY)
                                            for (var x = 0;
                                                x < ingredients.length;
                                                x++) {
                                              //Update price in this index
                                              updateSuppliesFromList
                                                  .forEach((y, z) {
                                                if (ingredients[x]
                                                        ['Ingredient'] ==
                                                    y) {
                                                  ingredients[x]
                                                      ['Supply Cost'] = z;
                                                }
                                              });
                                            }
                                            DatabaseService().editProductSupply(
                                                widget.activeBusiness,
                                                doc.id,
                                                ingredients);
                                            updatedDocuments.add(doc.id);
                                          }
                                        }));

                                //Update business Supplies with ingredients
                                await FirebaseFirestore.instance
                                    .collection("ERP")
                                    .doc(widget.activeBusiness)
                                    .collection("Supplies")
                                    .where('List of Ingredients',
                                        arrayContains: key)
                                    .get()
                                    .then((snapshot) =>
                                        List.from(snapshot.docs).forEach((doc) {
                                          if (updatedSupplyDocuments
                                              .contains(doc.id)) {
                                            //
                                          } else {
                                            //Take list of ingredients
                                            List ingredients = doc['Recipe'];
                                            //Identify which has ingredient to update (named like KEY)
                                            for (var x = 0;
                                                x < ingredients.length;
                                                x++) {
                                              //Update price in this index
                                              updateSuppliesFromList
                                                  .forEach((y, z) {
                                                if (ingredients[x]
                                                        ['Ingredient'] ==
                                                    y) {
                                                  ingredients[x]
                                                      ['Supply Cost'] = z;
                                                }
                                              });
                                            }
                                            DatabaseService()
                                                .editSupplyIngredients(
                                                    widget.activeBusiness,
                                                    doc.id,
                                                    ingredients);
                                            updatedSupplyDocuments.add(doc.id);
                                          }
                                        }));
                              });
                            }

                            setState(() {
                              showList = false;
                            });
                            widget.clearVariables();

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
                    selectInvoiceDate,
                    widget.costType,
                    widget.dropdownCategories,
                    setInvoiceReference,
                    setShowVendorTags,
                    showSearchOptions,
                    showVendorOptionsfromParent,
                    showVendorTagsfromParent,
                    saveVendor,
                    saveNewVendor,
                    vendorName,
                  )
                ]),
              ),
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Stack(children: [
                //Form
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 315,
                    ),
                    //Form
                    (showList)
                        ? CreateExpenseDialogForm(
                            widget.costType,
                            dropdownCategories,
                            removeSupplyFromList,
                            addSupplyToList,
                            widget.activeBusiness)
                        : Container(),
                    //Tags de productos
                    // (widget.costType == 'Costo de Ventas')
                    //     ? StreamProvider<List<Supply>>.value(
                    //         value: DatabaseService().suppliesListbyVendor(
                    //             widget.activeBusiness,
                    //             bloc.expenseItems['Vendor'].toLowerCase()),
                    //         initialData: null,
                    //         child: VendorProductsTags(
                    //             selectedSupplier, addProduct))
                    //     : SizedBox(),
                    //Total
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [TotalExpenseAmount()],
                      ),
                    ),
                    // Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
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
                      ],
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    // Use money in petty cash?
                    CreateExpenseUseCashierMoney(
                        bloc.totalExpenseAmount,
                        moneyFromCashier,
                        checkCashierMoneyBox,
                        selectPayment,
                        widget.dailyTransactions,
                        widget.registerStatus),
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
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                        onPressed: () async {
                          //////////Save expense
                          var docID = DateTime.now().toString();
                          var cartList = bloc.expenseItems['Items'];
                          DatabaseService().saveExpense(
                              widget.activeBusiness,
                              widget.costType,
                              (bloc.expenseItems["Vendor"] != '' &&
                                      bloc.expenseItems["Vendor"] != null)
                                  ? bloc.expenseItems["Vendor"]
                                  : vendorName,
                              bloc.totalExpenseAmount,
                              paymentType,
                              bloc.expenseItems["Items"],
                              selectedIvoiceDate,
                              selectedIvoiceDate.year.toString(),
                              selectedIvoiceDate.month.toString(),
                              widget.registerStatus.registerName,
                              false,
                              (isChecked &&
                                      widget.registerStatus.registerisOpen)
                                  ? true
                                  : false,
                              (isChecked &&
                                      widget.registerStatus.registerisOpen)
                                  ? cashRegisterAmount
                                  : 0,
                              docID,
                              setSearchParam(
                                (bloc.expenseItems["Vendor"] != '' &&
                                        bloc.expenseItems["Vendor"] != null)
                                    ? bloc.expenseItems["Vendor"].toLowerCase()
                                    : vendorName.toLowerCase(),
                              ),
                              invoiceReference);

                          //Payable
                          if (paymentType == 'Por pagar') {
                            DatabaseService().createPayable(
                                widget.activeBusiness,
                                widget.costType,
                                (bloc.expenseItems["Vendor"] != '' &&
                                        bloc.expenseItems["Vendor"] != null)
                                    ? bloc.expenseItems["Vendor"]
                                    : vendorName,
                                bloc.totalExpenseAmount,
                                paymentType,
                                bloc.expenseItems["Items"],
                                selectedIvoiceDate,
                                docID,
                                setSearchParam(
                                  (bloc.expenseItems["Vendor"] != '' &&
                                          bloc.expenseItems["Vendor"] != null)
                                      ? bloc.expenseItems["Vendor"]
                                          .toLowerCase()
                                      : vendorName.toLowerCase(),
                                ),
                                invoiceReference);
                          }

                          //Save to Vendor
                          if (selectedVendor != '' && selectedVendor != null) {
                            DatabaseService().associateExpensetoVendor(
                                widget.activeBusiness,
                                docID,
                                invoiceReference,
                                DateTime.now(),
                                selectedVendor,
                                bloc.totalExpenseAmount,
                                (paymentType == 'Por pagar') ? true : false);
                          }

                          //////////Loop over items to save expense type and subaccounts

                          //Firestore reference
                          var firestore = FirebaseFirestore.instance;
                          var docRef = firestore
                              .collection('ERP')
                              .doc(widget.activeBusiness)
                              .collection(selectedIvoiceDate.year.toString())
                              .doc(selectedIvoiceDate.month.toString());

                          final doc = await docRef.get();
                          //Save Expense Type new amount
                          try {
                            if (doc.exists) {
                              docRef.update({
                                '${widget.costType}': FieldValue.increment(
                                    bloc.totalExpenseAmount)
                              });
                            } else {
                              docRef.set({
                                '${widget.costType}': bloc.totalExpenseAmount
                              });
                            }
                          } catch (error) {
                            print('Error updating Total Expense Value: $error');
                          }

                          //Create map to get categories totals
                          expenseCategories = {};

                          for (var i = 0; i < cartList.length; i++) {
                            if (widget.costType == 'Costo de Ventas') {
                              //Check if the map contains the key
                              if (expenseCategories.containsKey(
                                  'Costos de ${cartList[i]["Category"]}')) {
                                //Add to existing category amount
                                expenseCategories.update(
                                    'Costos de ${cartList[i]["Category"]}',
                                    (value) =>
                                        value +
                                        (cartList[i]["Price"] *
                                            cartList[i]["Quantity"]));
                              } else {
                                //Add new category with amount
                                expenseCategories[
                                        'Costos de ${cartList[i]["Category"]}'] =
                                    cartList[i]["Price"] *
                                        cartList[i]["Quantity"];
                              }
                            } else {
                              //Check if the map contains the key
                              if (expenseCategories
                                  .containsKey('${cartList[i]["Category"]}')) {
                                //Add to existing category amount
                                expenseCategories.update(
                                    '${cartList[i]["Category"]}',
                                    (value) =>
                                        value +
                                        (cartList[i]["Price"] *
                                            cartList[i]["Quantity"]));
                              } else {
                                //Add new category with amount
                                expenseCategories[
                                    '${cartList[i]["Category"]}'] = cartList[i]
                                        ["Price"] *
                                    cartList[i]["Quantity"];
                              }
                            }
                          }

                          //Logic to add Expense by Categories to Firebase
                          expenseCategories.forEach((k, v) {
                            docRef.update({k: FieldValue.increment(v)});
                          });

                          ///////////If we use money in cash register ///////////////
                          if (isChecked &&
                              widget.registerStatus.registerisOpen) {
                            double totalTransactionAmount =
                                widget.dailyTransactions.outflows +
                                    cashRegisterAmount;

                            double totalTransactions =
                                widget.dailyTransactions.dailyTransactions -
                                    cashRegisterAmount;

                            DatabaseService().updateCashRegister(
                                widget.activeBusiness,
                                widget.registerStatus.registerName,
                                'Egresos',
                                totalTransactionAmount,
                                totalTransactions, {
                              'Amount': cashRegisterAmount,
                              'Type': widget.costType,
                              'Motive': (bloc.expenseItems["Items"].length > 1)
                                  ? '${bloc.expenseItems["Items"][0]['Name']}...'
                                  : bloc.expenseItems["Items"][0]['Name'],
                              'Time': DateTime.now()
                            });
                          }

                          //Save vendor
                          if (saveVendor && saveVendorPressed) {
                            int min =
                                10000; //min and max values act as your 6 digit range
                            int max = 99999;
                            var rNum = min + random.nextInt(max - min);

                            DatabaseService().createSupplier(
                                widget.activeBusiness,
                                bloc.expenseItems["Vendor"],
                                setSearchParam(
                                    bloc.expenseItems["Vendor"].toLowerCase()),
                                0,
                                '',
                                1100000000,
                                '',
                                (bloc.expenseItems["Items"][0]['Category'] !=
                                            '' &&
                                        bloc.expenseItems["Items"][0]
                                                ['Category'] !=
                                            null)
                                    ? bloc.expenseItems["Items"][0]['Category']
                                    : widget.dropdownCategories[0],
                                (bloc.expenseItems["Items"][0]['Name'] != '' &&
                                        bloc.expenseItems["Items"][0]['Name'] !=
                                            null)
                                    ? bloc.expenseItems["Items"][0]['Name']
                                    : '',
                                (widget.costType == 'Costo de Ventas')
                                    ? 'Costo de Ventas'
                                    : bloc.expenseItems["Items"][0]['Category'],
                                [widget.costType],
                                rNum);
                          }

                          //Update supplies and product Prices
                          if (updateSuppliesFromList.length > 0) {
                            //Update supplies
                            updateSuppliesFromList.forEach((key, value) async {
                              await FirebaseFirestore.instance
                                  .collection("ERP")
                                  .doc(widget.activeBusiness)
                                  .collection("Supplies")
                                  .doc(key)
                                  .get()
                                  .then((snapshot) {
                                List historicPrices = snapshot['Price History'];

                                historicPrices.last['To Date'] = DateTime.now();

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
                            List updatedSupplyDocuments = [];

                            updateSuppliesFromList.forEach((key, value) async {
                              //Update Business products in MENU
                              await FirebaseFirestore.instance
                                  .collection("Products")
                                  .doc(widget.activeBusiness)
                                  .collection("Menu")
                                  .where('List Of Ingredients',
                                      arrayContains: key)
                                  .get()
                                  .then((snapshot) =>
                                      List.from(snapshot.docs).forEach((doc) {
                                        if (updatedDocuments.contains(doc.id)) {
                                          //
                                        } else {
                                          //Take list of ingredients
                                          List ingredients = doc['Ingredients'];
                                          //Identify which has ingredient to update (named like KEY)
                                          for (var x = 0;
                                              x < ingredients.length;
                                              x++) {
                                            //Update price in this index
                                            updateSuppliesFromList
                                                .forEach((y, z) {
                                              if (ingredients[x]
                                                      ['Ingredient'] ==
                                                  y) {
                                                ingredients[x]['Supply Cost'] =
                                                    z;
                                              }
                                            });
                                          }
                                          DatabaseService().editProductSupply(
                                              widget.activeBusiness,
                                              doc.id,
                                              ingredients);
                                          updatedDocuments.add(doc.id);
                                        }
                                      }));

                              //Update business Supplies with ingredients
                              await FirebaseFirestore.instance
                                  .collection("ERP")
                                  .doc(widget.activeBusiness)
                                  .collection("Supplies")
                                  .where('List of Ingredients',
                                      arrayContains: key)
                                  .get()
                                  .then((snapshot) =>
                                      List.from(snapshot.docs).forEach((doc) {
                                        if (updatedSupplyDocuments
                                            .contains(doc.id)) {
                                          //
                                        } else {
                                          //Take list of ingredients
                                          List ingredients = doc['Recipe'];
                                          //Identify which has ingredient to update (named like KEY)
                                          for (var x = 0;
                                              x < ingredients.length;
                                              x++) {
                                            //Update price in this index
                                            updateSuppliesFromList
                                                .forEach((y, z) {
                                              if (ingredients[x]
                                                      ['Ingredient'] ==
                                                  y) {
                                                ingredients[x]['Supply Cost'] =
                                                    z;
                                              }
                                            });
                                          }
                                          DatabaseService()
                                              .editSupplyIngredients(
                                                  widget.activeBusiness,
                                                  doc.id,
                                                  ingredients);
                                          updatedSupplyDocuments.add(doc.id);
                                        }
                                      }));
                            });
                          }

                          setState(() {
                            showList = false;
                          });
                          widget.clearVariables();

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
                  selectInvoiceDate,
                  widget.costType,
                  widget.dropdownCategories,
                  setInvoiceReference,
                  setShowVendorTags,
                  showSearchOptions,
                  showVendorOptionsfromParent,
                  showVendorTagsfromParent,
                  saveVendor,
                  saveNewVendor,
                  vendorName,
                )
              ]),
            ),
          ),
        ),
      );
    }
  }
}

class TotalExpenseAmount extends StatefulWidget {
  const TotalExpenseAmount({Key key}) : super(key: key);

  @override
  State<TotalExpenseAmount> createState() => _TotalExpenseAmountState();
}

class _TotalExpenseAmountState extends State<TotalExpenseAmount> {
  final formatCurrency = new NumberFormat.simpleCurrency();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: bloc.getExpenseStream,
        builder: (context, snapshot) {
          return Text(
            '${formatCurrency.format(bloc.totalExpenseAmount)}',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
          );
        });
  }
}
