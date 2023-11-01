import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Expenses/CreateExpenseDialog.dart';
import 'package:denario/Models/Categories.dart';
import 'package:denario/Models/DailyCash.dart';
import 'package:denario/Models/Mapping.dart';
import 'package:denario/Models/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Backend/Expense.dart';

class ExpenseInput extends StatefulWidget {
  final String activeBusiness;
  final DateTime selectedIvoiceDate;
  final CategoryList categoriesProvider;
  final HighLevelMapping highlevelMapping;
  ExpenseInput(this.activeBusiness, this.selectedIvoiceDate,
      this.categoriesProvider, this.highlevelMapping);
  @override
  _ExpenseInputState createState() => _ExpenseInputState();
}

class _ExpenseInputState extends State<ExpenseInput> {
  final dateFormat = new DateFormat('dd/MMMM');

  int qty = 1;
  double price = 0;
  String costType = '';

  Widget nullCostSelection() {
    return Column(children: [
      //Circle
      AnimatedContainer(
          duration: Duration(milliseconds: 200),
          width: 75,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            // border: Border.all(color: Colors.grey),
            boxShadow: <BoxShadow>[
              new BoxShadow(
                color: Colors.grey[350]!,
                offset: Offset(0.0, 0.0),
                blurRadius: 10.0,
              )
            ],
          ),
          child:
              Center(child: Icon(Icons.circle, color: Colors.white, size: 35))),
      SizedBox(height: 15),
    ]);
  }

  Widget costSelection(
      String type,
      IconData icon,
      Color color,
      HighLevelMapping highlevelMapping,
      CashRegister registerStatus,
      DailyTransactions? dailyTransactions) {
    return InkWell(
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        setState(() {
          costType = type;

          dropdownCategories = [];
          dropdownVendors = [];
        });

        if (type == 'Costo de Ventas') {
          dropdownCategories = widget.categoriesProvider.categoryList!;
        } else {
          highlevelMapping.pnlMapping![type]
              .forEach((y) => dropdownCategories.add(y));
          if (MediaQuery.of(context).size.width > 650) {
            bloc.addToExpenseList({
              'Name': '',
              'Price': 0,
              'Quantity': 1,
              'Total Price': 0,
              'Category': dropdownCategories[0],
            });
          }
        }

        bloc.changeCostType(costType);
        // bloc.changeVendor(dropdownVendors.first);

        if (MediaQuery.of(context).size.width > 650) {
          showDialog(
              context: context,
              builder: (context) {
                return StreamProvider<UserData?>.value(
                  initialData: null,
                  value: DatabaseService().userProfile(
                      FirebaseAuth.instance.currentUser!.uid.toString()),
                  child: CreateExpenseDialog(
                      costType,
                      registerStatus,
                      dailyTransactions,
                      clearVariables,
                      widget.activeBusiness,
                      dropdownCategories),
                );
              });
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => StreamProvider<UserData?>.value(
                        initialData: null,
                        value: DatabaseService().userProfile(
                            FirebaseAuth.instance.currentUser!.uid.toString()),
                        child: CreateExpenseDialog(
                            costType,
                            registerStatus,
                            dailyTransactions,
                            clearVariables,
                            widget.activeBusiness,
                            dropdownCategories),
                      )));
        }
      },
      child: Column(children: [
        //Circle
        AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: 75,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              // border: Border.all(color: Colors.grey),
              boxShadow: <BoxShadow>[
                new BoxShadow(
                  color: Colors.grey[350]!,
                  offset: Offset(0.0, 0.0),
                  blurRadius: 10.0,
                )
              ],
            ),
            child: Center(child: Icon(icon, color: color, size: 35))),
        SizedBox(height: 15),
        //Name
        Text(type, style: TextStyle(fontSize: 14, color: Colors.grey[700]))
      ]),
    );
  }

  //Form variables
  String selectedCategory = '';
  int categoryInt = 0;
  String selectedAccount = '';
  String selectedVendor = '';
  List<String> categoryList = [];
  List<String> categoriesVendors = [];
  String expenseDescription = '';
  String expenseHintDescription = '';
  TextEditingController descriptionController =
      new TextEditingController(text: '');

  String costAccount = '';
  int accountInt = 0;
  List dropdownCategories = [];
  List dropdownVendors = [];

  void clearVariables() {
    setState(() {
      costType = '';
      selectedCategory = '';
      categoryInt = 0;
      selectedAccount = '';
      selectedVendor = '';
      categoryList = [];
      categoriesVendors = [];
      expenseDescription = '';
      dropdownCategories = [];
      dropdownVendors = [];

      costAccount = '';
      accountInt = 0;
      qty = 1;
      price = 0;
      costType = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final highLevelMapping = Provider.of<HighLevelMapping?>(context);
    final categoriesProvider = Provider.of<CategoryList?>(context);
    final registerStatus = Provider.of<CashRegister?>(context);
    final dailyTransactions = Provider.of<DailyTransactions?>(context);

    if (highLevelMapping == null ||
        registerStatus == null ||
        categoriesProvider == null) {
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        nullCostSelection(),
        SizedBox(width: 35),
        nullCostSelection(),
        SizedBox(width: 35),
        nullCostSelection(),
        SizedBox(width: 35),
        nullCostSelection(),
      ]);
    } else {
      return Container(
        height: 120,
        width: double.infinity,
        child: Center(
          child: ListView.builder(
              itemCount: highLevelMapping.expenseGroups!.length,
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, i) {
                IconData iconSelected;
                Color colorSelected;

                if (highLevelMapping.expenseGroups![i] == 'Costo de Ventas') {
                  iconSelected = Icons.attach_money;
                  colorSelected = Colors.red;
                } else if (highLevelMapping.expenseGroups![i] ==
                    'Gastos del Local') {
                  iconSelected = Icons.store;
                  colorSelected = Colors.blue;
                } else if (highLevelMapping.expenseGroups![i] ==
                    'Gastos de Empleados') {
                  iconSelected = Icons.people;
                  colorSelected = Colors.green;
                } else if (highLevelMapping.expenseGroups![i] ==
                    'Gastos de Empleados') {
                  iconSelected = Icons.people;
                  colorSelected = Colors.green;
                } else {
                  iconSelected = Icons.account_balance_wallet;
                  colorSelected = Colors.purple;
                }

                return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5),
                    child: costSelection(
                        highLevelMapping.expenseGroups![i],
                        iconSelected,
                        colorSelected,
                        highLevelMapping,
                        registerStatus,
                        dailyTransactions ?? null));
              }),
        ),
      );
    }
  }
}
