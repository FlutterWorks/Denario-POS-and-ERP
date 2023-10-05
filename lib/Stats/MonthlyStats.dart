import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Models/Categories.dart';
import 'package:denario/Models/DailyCash.dart';
import 'package:denario/Models/Sales.dart';
import 'package:denario/Models/Stats.dart';
import 'package:denario/Stats/ShortSalesList.dart';
import 'package:denario/Stats/StatsByCategory.dart';
import 'package:denario/Stats/StatsByChannel.dart';
import 'package:denario/Stats/StatsByPaymentMethods.dart';
import 'package:denario/Stats/StatsByProducts.dart';
import 'package:denario/Stats/TotalsSummary.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MonthStats extends StatefulWidget {
  final String userBusiness;
  final String dateFilter;
  final DateTime selectedDate;
  MonthStats(this.userBusiness, this.dateFilter, this.selectedDate);
  @override
  State<MonthStats> createState() => _MonthStatsState();
}

class _MonthStatsState extends State<MonthStats> {
  final PageController pageController = PageController();

  int _currentPageIndex = 0;

  List productsList = [];
  List categoriesSelection = [
    'Categoría',
    'Productos',
    'Medios de Pago',
    'Canales'
  ];
  String selectedCategory;

  @override
  void initState() {
    selectedCategory = 'Categoría';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final monthlyStats = Provider.of<MonthlyStats>(context);
    final categoriesProvider = Provider.of<CategoryList>(context);
    final registerStatus = Provider.of<CashRegister>(context);

    if (monthlyStats == null || categoriesProvider == null) {
      return Container();
    } else {
      DailyTransactions dayStats = DailyTransactions(
          sales: monthlyStats.totalSales,
          totalItemsSold: monthlyStats.totalItemsSold,
          totalSalesCount: monthlyStats.totalSalesCount,
          salesByMedium: monthlyStats.salesByMedium,
          salesAmountbyCategory: monthlyStats.salesAmountbyCategory,
          salesAmountbyProduct: monthlyStats.salesAmountbyProduct,
          salesCountbyCategory: monthlyStats.salesCountbyCategory,
          salesCountbyProduct: monthlyStats.salesCountbyProduct,
          salesbyOrderType: monthlyStats.salesbyOrderType);

      if (dayStats == null) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //Image
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  color: Colors.white,
                  image: DecorationImage(
                    image: AssetImage('images/Sales_Empty State.png'),
                    fit: BoxFit.cover,
                  )),
            ),
            //Title
            Text(
              'Nada por acá',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            //Subtitle
            Text(
              'La información sobre tus ventas se verá en esta sección',
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w400),
            )
          ],
        );
      }

      if (MediaQuery.of(context).size.width > 950) {
        return Container(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Total sum and counts Summary
                TotalsSummary(monthlyStats: monthlyStats),
                SizedBox(height: 30),
                //Lists by Products/Category
                Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        //List of sales
                        Expanded(
                            child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: <BoxShadow>[
                              new BoxShadow(
                                color: Colors.grey[350],
                                offset: Offset(0.0, 0.0),
                                blurRadius: 10.0,
                              )
                            ],
                          ),
                          child: StreamProvider<List<Sales>>.value(
                            initialData: null,
                            value: DatabaseService().shortFilteredSalesList(
                              widget.userBusiness,
                              widget.selectedDate,
                              DateTime(widget.selectedDate.year,
                                  widget.selectedDate.month + 1),
                            ),
                            child: ShortSalesList(
                                widget.userBusiness, registerStatus),
                          ),
                        )),
                        SizedBox(width: 20),
                        //Stats por categoria/producto
                        Expanded(
                            child: Container(
                          padding: EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
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
                              //Select Option
                              (MediaQuery.of(context).size.width > 1100)
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        //Category
                                        Container(
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      width:
                                                          (_currentPageIndex ==
                                                                  0)
                                                              ? 3
                                                              : 0,
                                                      color: (_currentPageIndex ==
                                                              0)
                                                          ? Colors
                                                              .greenAccent[700]
                                                          : Colors
                                                              .transparent))),
                                          child: TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  _currentPageIndex = 0;
                                                });
                                                pageController.animateToPage(0,
                                                    duration: Duration(
                                                        milliseconds: 250),
                                                    curve: Curves.easeIn);
                                              },
                                              style: ButtonStyle(
                                                overlayColor:
                                                    MaterialStateProperty
                                                        .resolveWith<Color>(
                                                  (Set<MaterialState> states) {
                                                    if (states.contains(
                                                        MaterialState
                                                            .hovered)) {
                                                      return Colors.grey
                                                          .withOpacity(
                                                              0.2); // Customize the hover color here
                                                    }
                                                    return null; // Use default overlay color for other states
                                                  },
                                                ),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(5),
                                                child: Text(
                                                  'Categorías',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          (_currentPageIndex ==
                                                                  0)
                                                              ? FontWeight.bold
                                                              : FontWeight
                                                                  .normal,
                                                      color: (_currentPageIndex ==
                                                              0)
                                                          ? Colors
                                                              .greenAccent[700]
                                                          : Colors.black),
                                                ),
                                              )),
                                        ),
                                        SizedBox(width: 10),
                                        //Products
                                        Container(
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      width:
                                                          (_currentPageIndex ==
                                                                  1)
                                                              ? 3
                                                              : 0,
                                                      color: (_currentPageIndex ==
                                                              1)
                                                          ? Colors
                                                              .greenAccent[700]
                                                          : Colors
                                                              .transparent))),
                                          child: TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  _currentPageIndex = 1;
                                                });
                                                pageController.animateToPage(1,
                                                    duration: Duration(
                                                        milliseconds: 250),
                                                    curve: Curves.easeIn);
                                              },
                                              style: ButtonStyle(
                                                overlayColor:
                                                    MaterialStateProperty
                                                        .resolveWith<Color>(
                                                  (Set<MaterialState> states) {
                                                    if (states.contains(
                                                        MaterialState
                                                            .hovered)) {
                                                      return Colors.grey
                                                          .withOpacity(
                                                              0.2); // Customize the hover color here
                                                    }
                                                    return null; // Use default overlay color for other states
                                                  },
                                                ),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(5),
                                                child: Text(
                                                  'Productos',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          (_currentPageIndex ==
                                                                  1)
                                                              ? FontWeight.bold
                                                              : FontWeight
                                                                  .normal,
                                                      color: (_currentPageIndex ==
                                                              1)
                                                          ? Colors
                                                              .greenAccent[700]
                                                          : Colors.black),
                                                ),
                                              )),
                                        ),
                                        SizedBox(width: 10),
                                        //Payment Methods
                                        Container(
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      width:
                                                          (_currentPageIndex ==
                                                                  2)
                                                              ? 3
                                                              : 0,
                                                      color: (_currentPageIndex ==
                                                              2)
                                                          ? Colors
                                                              .greenAccent[700]
                                                          : Colors
                                                              .transparent))),
                                          child: TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  _currentPageIndex = 2;
                                                });
                                                pageController.animateToPage(2,
                                                    duration: Duration(
                                                        milliseconds: 250),
                                                    curve: Curves.easeIn);
                                              },
                                              style: ButtonStyle(
                                                overlayColor:
                                                    MaterialStateProperty
                                                        .resolveWith<Color>(
                                                  (Set<MaterialState> states) {
                                                    if (states.contains(
                                                        MaterialState
                                                            .hovered)) {
                                                      return Colors.grey
                                                          .withOpacity(
                                                              0.2); // Customize the hover color here
                                                    }
                                                    return null; // Use default overlay color for other states
                                                  },
                                                ),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(5),
                                                child: Text(
                                                  'Medios de Pago',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          (_currentPageIndex ==
                                                                  2)
                                                              ? FontWeight.bold
                                                              : FontWeight
                                                                  .normal,
                                                      color: (_currentPageIndex ==
                                                              2)
                                                          ? Colors
                                                              .greenAccent[700]
                                                          : Colors.black),
                                                ),
                                              )),
                                        ),
                                        //Channels
                                        Container(
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      width:
                                                          (_currentPageIndex ==
                                                                  3)
                                                              ? 3
                                                              : 0,
                                                      color: (_currentPageIndex ==
                                                              3)
                                                          ? Colors
                                                              .greenAccent[700]
                                                          : Colors
                                                              .transparent))),
                                          child: TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  _currentPageIndex = 3;
                                                });
                                                pageController.animateToPage(3,
                                                    duration: Duration(
                                                        milliseconds: 250),
                                                    curve: Curves.easeIn);
                                              },
                                              style: ButtonStyle(
                                                overlayColor:
                                                    MaterialStateProperty
                                                        .resolveWith<Color>(
                                                  (Set<MaterialState> states) {
                                                    if (states.contains(
                                                        MaterialState
                                                            .hovered)) {
                                                      return Colors.grey
                                                          .withOpacity(
                                                              0.2); // Customize the hover color here
                                                    }
                                                    return null; // Use default overlay color for other states
                                                  },
                                                ),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(5),
                                                child: Text(
                                                  'Canales',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          (_currentPageIndex ==
                                                                  3)
                                                              ? FontWeight.bold
                                                              : FontWeight
                                                                  .normal,
                                                      color: (_currentPageIndex ==
                                                              3)
                                                          ? Colors
                                                              .greenAccent[700]
                                                          : Colors.black),
                                                ),
                                              )),
                                        ),
                                      ],
                                    )
                                  : DropdownButton(
                                      isExpanded: true,
                                      underline: SizedBox(),
                                      hint: Text(
                                        selectedCategory,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            color: Colors.grey[700]),
                                      ),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                          color: Colors.grey[700]),
                                      value: selectedCategory,
                                      items: categoriesSelection.map((x) {
                                        return new DropdownMenuItem(
                                          value: x,
                                          child: new Text(x),
                                          onTap: () {
                                            setState(() {
                                              _currentPageIndex =
                                                  categoriesSelection
                                                      .indexOf(x);
                                            });
                                            pageController.animateToPage(
                                                categoriesSelection.indexOf(x),
                                                duration:
                                                    Duration(milliseconds: 250),
                                                curve: Curves.easeIn);
                                          },
                                        );
                                      }).toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          selectedCategory = newValue;
                                        });
                                      },
                                    ),
                              SizedBox(height: 5),
                              //Pageview
                              Expanded(
                                child: PageView(
                                    controller: pageController,
                                    physics: NeverScrollableScrollPhysics(),
                                    children: [
                                      //Categorias
                                      Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Divider(
                                                thickness: 0.5,
                                                indent: 0,
                                                endIndent: 0),
                                            //List
                                            StatsByCategory(dayStats,
                                                categoriesProvider.categoryList)
                                          ]),

                                      //Productos
                                      StatsByProducts(dayStats),

                                      //Payment Methods
                                      Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Divider(
                                                thickness: 0.5,
                                                indent: 0,
                                                endIndent: 0),
                                            //List
                                            StatsByPaymentMethods(dayStats,
                                                registerStatus.paymentTypes)
                                          ]),
                                      //Channels
                                      Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Divider(
                                                thickness: 0.5,
                                                indent: 0,
                                                endIndent: 0),
                                            //List
                                            StatsByCannels(
                                                monthlyStats.salesbyOrderType)
                                          ])
                                    ]),
                              )
                            ],
                          ),
                        )),
                      ]),
                ),
              ]),
        );
      } else {
        return Container(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Total sum and counts Summary
                TotalsSummary(monthlyStats: monthlyStats),
                SizedBox(height: 30),
                //List of sales
                Container(
                  constraints: BoxConstraints(minHeight: 300, maxHeight: 400),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: <BoxShadow>[
                      new BoxShadow(
                        color: Colors.grey[350],
                        offset: Offset(0.0, 0.0),
                        blurRadius: 10.0,
                      )
                    ],
                  ),
                  child: StreamProvider<List<Sales>>.value(
                    initialData: null,
                    value: DatabaseService().shortFilteredSalesList(
                      widget.userBusiness,
                      widget.selectedDate,
                      DateTime(widget.selectedDate.year,
                          widget.selectedDate.month + 1),
                    ),
                    child: ShortSalesList(widget.userBusiness, registerStatus),
                  ),
                ),
                SizedBox(height: 20),
                //Lists by Products/Category
                Container(
                  padding: EdgeInsets.all(20),
                  constraints: BoxConstraints(minHeight: 300, maxHeight: 400),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
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
                      //Select Option
                      (MediaQuery.of(context).size.width > 600)
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                //Category
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              width: (_currentPageIndex == 0)
                                                  ? 3
                                                  : 0,
                                              color: (_currentPageIndex == 0)
                                                  ? Colors.greenAccent[700]
                                                  : Colors.transparent))),
                                  child: TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _currentPageIndex = 0;
                                        });
                                        pageController.animateToPage(0,
                                            duration:
                                                Duration(milliseconds: 250),
                                            curve: Curves.easeIn);
                                      },
                                      style: ButtonStyle(
                                        overlayColor: MaterialStateProperty
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
                                          'Categorías',
                                          style: TextStyle(
                                              fontWeight:
                                                  (_currentPageIndex == 0)
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                              color: (_currentPageIndex == 0)
                                                  ? Colors.greenAccent[700]
                                                  : Colors.black),
                                        ),
                                      )),
                                ),
                                SizedBox(width: 10),
                                //Products
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              width: (_currentPageIndex == 1)
                                                  ? 3
                                                  : 0,
                                              color: (_currentPageIndex == 1)
                                                  ? Colors.greenAccent[700]
                                                  : Colors.transparent))),
                                  child: TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _currentPageIndex = 1;
                                        });
                                        pageController.animateToPage(1,
                                            duration:
                                                Duration(milliseconds: 250),
                                            curve: Curves.easeIn);
                                      },
                                      style: ButtonStyle(
                                        overlayColor: MaterialStateProperty
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
                                          'Productos',
                                          style: TextStyle(
                                              fontWeight:
                                                  (_currentPageIndex == 1)
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                              color: (_currentPageIndex == 1)
                                                  ? Colors.greenAccent[700]
                                                  : Colors.black),
                                        ),
                                      )),
                                ),
                                SizedBox(width: 10),
                                //Payment Methods
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              width: (_currentPageIndex == 2)
                                                  ? 3
                                                  : 0,
                                              color: (_currentPageIndex == 2)
                                                  ? Colors.greenAccent[700]
                                                  : Colors.transparent))),
                                  child: TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _currentPageIndex = 2;
                                        });
                                        pageController.animateToPage(2,
                                            duration:
                                                Duration(milliseconds: 250),
                                            curve: Curves.easeIn);
                                      },
                                      style: ButtonStyle(
                                        overlayColor: MaterialStateProperty
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
                                          'Medios de Pago',
                                          style: TextStyle(
                                              fontWeight:
                                                  (_currentPageIndex == 2)
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                              color: (_currentPageIndex == 2)
                                                  ? Colors.greenAccent[700]
                                                  : Colors.black),
                                        ),
                                      )),
                                ),
                                SizedBox(width: 10),
                                //Cost types
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              width: (_currentPageIndex == 3)
                                                  ? 3
                                                  : 0,
                                              color: (_currentPageIndex == 3)
                                                  ? Colors.greenAccent[700]
                                                  : Colors.transparent))),
                                  child: TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _currentPageIndex = 3;
                                        });
                                        pageController.animateToPage(3,
                                            duration:
                                                Duration(milliseconds: 250),
                                            curve: Curves.easeIn);
                                      },
                                      style: ButtonStyle(
                                        overlayColor: MaterialStateProperty
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
                                          'Canales',
                                          style: TextStyle(
                                              fontWeight:
                                                  (_currentPageIndex == 3)
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                              color: (_currentPageIndex == 3)
                                                  ? Colors.greenAccent[700]
                                                  : Colors.black),
                                        ),
                                      )),
                                ),
                              ],
                            )
                          : DropdownButton(
                              isExpanded: true,
                              underline: SizedBox(),
                              hint: Text(
                                selectedCategory,
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Colors.grey[700]),
                              ),
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Colors.grey[700]),
                              value: selectedCategory,
                              items: categoriesSelection.map((x) {
                                return new DropdownMenuItem(
                                  value: x,
                                  child: new Text(x),
                                  onTap: () {
                                    setState(() {
                                      _currentPageIndex =
                                          categoriesSelection.indexOf(x);
                                    });
                                    pageController.animateToPage(
                                        categoriesSelection.indexOf(x),
                                        duration: Duration(milliseconds: 250),
                                        curve: Curves.easeIn);
                                  },
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  selectedCategory = newValue;
                                });
                              },
                            ),
                      SizedBox(height: 5),
                      //Pageview
                      Expanded(
                        child: PageView(
                            controller: pageController,
                            physics: NeverScrollableScrollPhysics(),
                            children: [
                              //Categorias
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Divider(
                                        thickness: 0.5,
                                        indent: 0,
                                        endIndent: 0),
                                    //List
                                    StatsByCategory(dayStats,
                                        categoriesProvider.categoryList)
                                  ]),

                              //Productos
                              StatsByProducts(dayStats),

                              //Payment Methods
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Divider(
                                        thickness: 0.5,
                                        indent: 0,
                                        endIndent: 0),
                                    //List
                                    StatsByPaymentMethods(
                                        dayStats, registerStatus.paymentTypes)
                                  ]),
                              //Channels
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Divider(
                                        thickness: 0.5,
                                        indent: 0,
                                        endIndent: 0),
                                    //List
                                    StatsByCannels(
                                        monthlyStats.salesbyOrderType)
                                  ])
                            ]),
                      )
                    ],
                  ),
                )
              ]),
        );
      }
    }
  }
}
