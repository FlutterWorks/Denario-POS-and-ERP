import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Expenses/ExpenseInput.dart';
import 'package:denario/Expenses/ExpenseList.dart';
import 'package:denario/Expenses/ExpenseSummary.dart';
import 'package:denario/Expenses/ExpensesHistory.dart';
import 'package:denario/Expenses/PayablesList.dart';
import 'package:denario/Models/Categories.dart';
import 'package:denario/Models/DailyCash.dart';
import 'package:denario/Models/Expenses.dart';
import 'package:denario/Models/Mapping.dart';
import 'package:denario/Models/Payables.dart';
import 'package:denario/Models/User.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpensesDesk extends StatefulWidget {
  final String rol;
  ExpensesDesk(this.rol);
  @override
  State<ExpensesDesk> createState() => _ExpensesDeskState();
}

class _ExpensesDeskState extends State<ExpensesDesk> {
  DateTime selectedIvoiceDate;
  bool searchByPayables;

  @override
  void initState() {
    searchByPayables = false;
    selectedIvoiceDate = DateTime.now();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<UserData>(context);
    final categoriesProvider = Provider.of<CategoryList>(context);
    final highlevelMapping = Provider.of<HighLevelMapping>(context);

    if (categoriesProvider == null || highlevelMapping == null) {
      return Container();
    }

    return SingleChildScrollView(
      child: Container(
        // padding: EdgeInsets.all(15),
        child: Column(children: [
          //Title
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //Fecha
                Text(
                  'Registrar gasto',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          //Expense Input
          MultiProvider(
              providers: [
                StreamProvider<CategoryList>.value(
                    initialData: null,
                    value: DatabaseService()
                        .categoriesList(userProfile.activeBusiness)),
                StreamProvider<AccountsList>.value(
                    initialData: null,
                    value: DatabaseService()
                        .accountsList(userProfile.activeBusiness))
              ],
              child: ExpenseInput(userProfile.activeBusiness,
                  selectedIvoiceDate, categoriesProvider, highlevelMapping)),
          SizedBox(height: 20),
          //Expense List
          (MediaQuery.of(context).size.width > 650)
              ? MultiProvider(
                  providers: [
                    StreamProvider<CashRegister>.value(
                        initialData: null,
                        value: DatabaseService()
                            .cashRegisterStatus(userProfile.activeBusiness)),
                  ],
                  child: Container(
                      height: (MediaQuery.of(context).size.width > 1100)
                          ? 500
                          : 1000,
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      child: (MediaQuery.of(context).size.width > 1100)
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //ExpenseList
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(30),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          new BorderRadius.circular(12.0),
                                      boxShadow: <BoxShadow>[
                                        new BoxShadow(
                                          color: Colors.grey[350],
                                          offset: Offset(0.0, 0.0),
                                          blurRadius: 10.0,
                                        )
                                      ],
                                    ),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          //Title
                                          Row(children: [
                                            //All
                                            Container(
                                              height: 45,
                                              width: 125,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      searchByPayables
                                                          ? Colors.white
                                                          : Colors
                                                              .greenAccent[400],
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8),
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topLeft: Radius
                                                                .circular(8),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    8)),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    searchByPayables = false;
                                                  });
                                                },
                                                child: Center(
                                                    child: Text(
                                                        'Gastos del mes',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            color:
                                                                searchByPayables
                                                                    ? Colors
                                                                        .grey
                                                                    : Colors
                                                                        .white))),
                                              ),
                                            ),
                                            //Payables
                                            Container(
                                              width: 125,
                                              height: 45,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      searchByPayables
                                                          ? Colors
                                                              .greenAccent[400]
                                                          : Colors.white,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8),
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topRight: Radius
                                                                .circular(8),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    8)),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    searchByPayables = true;
                                                  });
                                                },
                                                child: Center(
                                                    child: Text('Por pagar',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color:
                                                              searchByPayables
                                                                  ? Colors.white
                                                                  : Colors.grey,
                                                        ))),
                                              ),
                                            ),

                                            Spacer(),
                                            IconButton(
                                                tooltip: 'Ver todos los gastos',
                                                iconSize: 16,
                                                splashRadius: 0.2,
                                                onPressed: () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            StreamProvider<
                                                                List<
                                                                    Expenses>>.value(
                                                              initialData: null,
                                                              value: DatabaseService().expenseList(
                                                                  userProfile
                                                                      .activeBusiness,
                                                                  DateTime.now()
                                                                      .month
                                                                      .toString(),
                                                                  DateTime.now()
                                                                      .year
                                                                      .toString()),
                                                              child: ExpensesHistory(
                                                                  userProfile
                                                                      .activeBusiness),
                                                            ))),
                                                // ExpensesHistory(userProfile
                                                //     .activeBusiness))),
                                                icon: Icon(
                                                  Icons.list,
                                                  color: Colors.black,
                                                  size: 24,
                                                ))
                                          ]),
                                          SizedBox(height: 15),
                                          //Expenses List
                                          Expanded(
                                            child: searchByPayables
                                                ? StreamProvider<
                                                    List<Payables>>.value(
                                                    initialData: null,
                                                    value: DatabaseService()
                                                        .payablesList(userProfile
                                                            .activeBusiness),
                                                    child: PayablesList(
                                                        userProfile
                                                            .activeBusiness),
                                                  )
                                                : StreamProvider<
                                                    List<Expenses>>.value(
                                                    initialData: null,
                                                    value: DatabaseService()
                                                        .shortExpenseList(
                                                            userProfile
                                                                .activeBusiness,
                                                            DateTime.now()
                                                                .month
                                                                .toString(),
                                                            DateTime.now()
                                                                .year
                                                                .toString()),
                                                    child: ExpenseList(
                                                        userProfile
                                                            .activeBusiness),
                                                  ),
                                          )
                                        ]),
                                  ),
                                ),
                                SizedBox(width: 20),
                                //Graph
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(30),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          new BorderRadius.circular(12.0),
                                      boxShadow: <BoxShadow>[
                                        new BoxShadow(
                                          color: Colors.grey[350],
                                          offset: Offset(0.0, 0.0),
                                          blurRadius: 10.0,
                                        )
                                      ],
                                    ),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          //Title
                                          Text(
                                            'Resumen de Gastos',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                          SizedBox(height: 15),
                                          //Expenses List
                                          ExpenseSummary(
                                              userProfile.activeBusiness)
                                        ]),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                //ExpenseList
                                Container(
                                  height: 500,
                                  width: double.infinity,
                                  padding: EdgeInsets.all(30),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        new BorderRadius.circular(12.0),
                                    boxShadow: <BoxShadow>[
                                      new BoxShadow(
                                        color: Colors.grey[350],
                                        offset: Offset(0.0, 0.0),
                                        blurRadius: 10.0,
                                      )
                                    ],
                                  ),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        //Title
                                        Row(children: [
                                          //All
                                          Container(
                                            height: 45,
                                            width: 125,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    searchByPayables
                                                        ? Colors.white
                                                        : Colors
                                                            .greenAccent[400],
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8),
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft: Radius
                                                              .circular(8),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  8)),
                                                ),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  searchByPayables = false;
                                                });
                                              },
                                              child: Center(
                                                  child: Text('Gastos del mes',
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color:
                                                              searchByPayables
                                                                  ? Colors.grey
                                                                  : Colors
                                                                      .white))),
                                            ),
                                          ),
                                          //Payables
                                          Container(
                                            width: 125,
                                            height: 45,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    searchByPayables
                                                        ? Colors
                                                            .greenAccent[400]
                                                        : Colors.white,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8),
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topRight: Radius
                                                              .circular(8),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  8)),
                                                ),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  searchByPayables = true;
                                                });
                                              },
                                              child: Center(
                                                  child: Text('Por pagar',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: searchByPayables
                                                            ? Colors.white
                                                            : Colors.grey,
                                                      ))),
                                            ),
                                          ),

                                          Spacer(),
                                          IconButton(
                                              tooltip: 'Ver todos los gastos',
                                              iconSize: 16,
                                              splashRadius: 0.2,
                                              onPressed: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          StreamProvider<
                                                              List<
                                                                  Expenses>>.value(
                                                            initialData: null,
                                                            value: DatabaseService().expenseList(
                                                                userProfile
                                                                    .activeBusiness,
                                                                DateTime.now()
                                                                    .month
                                                                    .toString(),
                                                                DateTime.now()
                                                                    .year
                                                                    .toString()),
                                                            child: ExpensesHistory(
                                                                userProfile
                                                                    .activeBusiness),
                                                          ))),
                                              // ExpensesHistory(userProfile
                                              //     .activeBusiness))),
                                              icon: Icon(
                                                Icons.list,
                                                color: Colors.black,
                                                size: 24,
                                              ))
                                        ]),
                                        SizedBox(height: 15),
                                        //Expenses List
                                        searchByPayables
                                            ? StreamProvider<
                                                List<Payables>>.value(
                                                initialData: null,
                                                value: DatabaseService()
                                                    .payablesList(userProfile
                                                        .activeBusiness),
                                                child: Expanded(
                                                  child: PayablesList(
                                                      userProfile
                                                          .activeBusiness),
                                                ),
                                              )
                                            : StreamProvider<
                                                List<Expenses>>.value(
                                                initialData: null,
                                                value: DatabaseService()
                                                    .shortExpenseList(
                                                        userProfile
                                                            .activeBusiness,
                                                        DateTime.now()
                                                            .month
                                                            .toString(),
                                                        DateTime.now()
                                                            .year
                                                            .toString()),
                                                child: Expanded(
                                                  child: ExpenseList(userProfile
                                                      .activeBusiness),
                                                ),
                                              ),
                                        // ExpenseList(userProfile.activeBusiness)
                                      ]),
                                ),
                                SizedBox(height: 20),
                                //Graph
                                Container(
                                  height: 400,
                                  width: double.infinity,
                                  padding: EdgeInsets.all(30),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        new BorderRadius.circular(12.0),
                                    boxShadow: <BoxShadow>[
                                      new BoxShadow(
                                        color: Colors.grey[350],
                                        offset: Offset(0.0, 0.0),
                                        blurRadius: 10.0,
                                      )
                                    ],
                                  ),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        //Title
                                        Text(
                                          'Resumen de Gastos',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        SizedBox(height: 15),
                                        //Expenses List
                                        ExpenseSummary(
                                            userProfile.activeBusiness)
                                      ]),
                                ),
                              ],
                            )),
                )
              : MultiProvider(
                  providers: [
                    StreamProvider<CashRegister>.value(
                        initialData: null,
                        value: DatabaseService()
                            .cashRegisterStatus(userProfile.activeBusiness)),
                  ],
                  child: Container(
                      height: 950,
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          //Graph
                          Container(
                            height: 375,
                            width: double.infinity,
                            padding: EdgeInsets.all(20),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  //Title
                                  Text(
                                    'Resumen de Gastos',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  SizedBox(height: 15),
                                  //Expenses List
                                  ExpenseSummary(userProfile.activeBusiness)
                                ]),
                          ),
                          SizedBox(height: 20),
                          //ExpenseList
                          Container(
                            height: 500,
                            width: double.infinity,
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //Title
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Container(
                                    width: double.infinity,
                                    child: Row(children: [
                                      //All
                                      Container(
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    width: searchByPayables
                                                        ? 0
                                                        : 3,
                                                    color: searchByPayables
                                                        ? Colors.white
                                                        : Colors.greenAccent[
                                                            400]))),
                                        child: TextButton(
                                            onPressed: () {
                                              setState(() {
                                                searchByPayables = false;
                                              });
                                            },
                                            style: ButtonStyle(
                                              overlayColor:
                                                  MaterialStateProperty
                                                      .resolveWith<Color>(
                                                (Set<MaterialState> states) {
                                                  if (states.contains(
                                                      MaterialState.hovered)) {
                                                    return Colors.grey.withOpacity(
                                                        0.2); // Customize the hover color here
                                                  }
                                                  return null; // Use default overlay color for other states
                                                },
                                              ),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Text(
                                                'Gastos',
                                                style: TextStyle(
                                                    fontWeight:
                                                        (!searchByPayables)
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                    color: (!searchByPayables)
                                                        ? Colors
                                                            .greenAccent[700]
                                                        : Colors.black),
                                              ),
                                            )),
                                      ),
                                      SizedBox(width: 10),
                                      Container(
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    width: searchByPayables
                                                        ? 3
                                                        : 0,
                                                    color: searchByPayables
                                                        ? Colors
                                                            .greenAccent[400]
                                                        : Colors.white))),
                                        child: TextButton(
                                            onPressed: () {
                                              setState(() {
                                                searchByPayables = true;
                                              });
                                            },
                                            style: ButtonStyle(
                                              overlayColor:
                                                  MaterialStateProperty
                                                      .resolveWith<Color>(
                                                (Set<MaterialState> states) {
                                                  if (states.contains(
                                                      MaterialState.hovered)) {
                                                    return Colors.grey.withOpacity(
                                                        0.2); // Customize the hover color here
                                                  }
                                                  return null; // Use default overlay color for other states
                                                },
                                              ),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Text(
                                                'Por pagar',
                                                style: TextStyle(
                                                    fontWeight:
                                                        (searchByPayables)
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                    color: (searchByPayables)
                                                        ? Colors
                                                            .greenAccent[700]
                                                        : Colors.black),
                                              ),
                                            )),
                                      ),
                                      Spacer(),
                                      IconButton(
                                          tooltip: 'Ver todos los gastos',
                                          iconSize: 16,
                                          splashRadius: 0.2,
                                          onPressed: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      StreamProvider<
                                                          List<Expenses>>.value(
                                                        initialData: null,
                                                        value: DatabaseService()
                                                            .expenseList(
                                                                userProfile
                                                                    .activeBusiness,
                                                                DateTime.now()
                                                                    .month
                                                                    .toString(),
                                                                DateTime.now()
                                                                    .year
                                                                    .toString()),
                                                        child: ExpensesHistory(
                                                            userProfile
                                                                .activeBusiness),
                                                      ))),
                                          // ExpensesHistory(userProfile
                                          //     .activeBusiness))),
                                          icon: Icon(
                                            Icons.list,
                                            color: Colors.black,
                                            size: 24,
                                          ))
                                    ]),
                                  ),
                                ),
                                //Expenses List
                                searchByPayables
                                    ? StreamProvider<List<Payables>>.value(
                                        initialData: null,
                                        value: DatabaseService().payablesList(
                                            userProfile.activeBusiness),
                                        child: Expanded(
                                          child: PayablesList(
                                              userProfile.activeBusiness),
                                        ),
                                      )
                                    : StreamProvider<List<Expenses>>.value(
                                        initialData: null,
                                        value: DatabaseService()
                                            .shortExpenseList(
                                                userProfile.activeBusiness,
                                                DateTime.now().month.toString(),
                                                DateTime.now().year.toString()),
                                        child: Expanded(
                                          child: ExpenseList(
                                              userProfile.activeBusiness),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ],
                      )),
                ),
        ]),
      ),
    );
  }
}
