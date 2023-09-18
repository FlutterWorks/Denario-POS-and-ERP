import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Models/Categories.dart';
import 'package:denario/Models/DailyCash.dart';
import 'package:denario/Models/Sales.dart';
import 'package:denario/Stats/ShortSalesList.dart';
import 'package:denario/Stats/StatsByCategory.dart';
import 'package:denario/Stats/StatsByPaymentMethods.dart';
import 'package:denario/Stats/StatsByProducts.dart';
import 'package:denario/Stats/TotalsSummary.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DailyStats extends StatefulWidget {
  final String userBusiness;
  final String dateFilter;
  final DateTime selectedDate;
  DailyStats(this.userBusiness, this.dateFilter, this.selectedDate);
  @override
  State<DailyStats> createState() => _DailyStatsState();
}

class _DailyStatsState extends State<DailyStats> {
  final PageController pageController = PageController();
  int _currentPageIndex = 0;
  List productsList = [];

  @override
  Widget build(BuildContext context) {
    final dailyTransactions = Provider.of<List<DailyTransactions>>(context);
    final registerStatus = Provider.of<CashRegister>(context);
    final categoriesProvider = Provider.of<CategoryList>(context);

    if (dailyTransactions == null || categoriesProvider == null) {
      return Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.5,
        constraints: BoxConstraints(minHeight: 300),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 100),
            //Ups
            Text(
              'Upss..',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            //Text
            Text(
              'La caja registradora está cerrada, no hay nada que ver por aca',
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w400),
            )
          ],
        ),
      );
    } else {
      DailyTransactions dayStats = DailyTransactions(
          sales: 0,
          totalItemsSold: 0,
          totalSalesCount: 0,
          salesByMedium: {},
          salesAmountbyCategory: {},
          salesAmountbyProduct: {},
          salesCountbyCategory: {},
          salesCountbyProduct: {},
          salesbyCategory: {},
          salesbyOrderType: {});

      if (dailyTransactions.length == null || dailyTransactions.length == 0) {
        dayStats = null;
      } else if (dailyTransactions.length == 1) {
        dayStats = dailyTransactions[0];
      } else {
        for (var map in dailyTransactions) {
          //Sales
          dayStats.sales = dayStats.sales + map.sales;
          //Items Sold
          dayStats.totalItemsSold =
              dayStats.totalItemsSold + map.totalItemsSold;
          //Sales Count
          dayStats.totalSalesCount =
              dayStats.totalSalesCount + map.totalSalesCount;
          //Sales by payment method
          map.salesByMedium.forEach((key, value) {
            if (dayStats.salesByMedium.containsKey(key)) {
              dayStats.salesByMedium[key] += value;
            } else {
              dayStats.salesByMedium[key] = value;
            }
          });
          //Sales Amount by Category
          map.salesAmountbyCategory.forEach((key, value) {
            if (dayStats.salesAmountbyCategory.containsKey(key)) {
              dayStats.salesAmountbyCategory[key] += value;
            } else {
              dayStats.salesAmountbyCategory[key] = value;
            }
          });
          //Sales Amount by Product
          map.salesAmountbyProduct.forEach((key, value) {
            if (dayStats.salesAmountbyProduct.containsKey(key)) {
              dayStats.salesAmountbyProduct[key] += value;
            } else {
              dayStats.salesAmountbyProduct[key] = value;
            }
          });
          //Sales Count by Category
          map.salesCountbyCategory.forEach((key, value) {
            if (dayStats.salesCountbyCategory.containsKey(key)) {
              dayStats.salesCountbyCategory[key] += value;
            } else {
              dayStats.salesCountbyCategory[key] = value;
            }
          });
          //Sales Count by Product
          map.salesCountbyProduct.forEach((key, value) {
            if (dayStats.salesCountbyProduct.containsKey(key)) {
              dayStats.salesCountbyProduct[key] += value;
            } else {
              dayStats.salesCountbyProduct[key] = value;
            }
          });
          //Sales by order Type
          map.salesbyOrderType.forEach((key, value) {
            if (dayStats.salesbyOrderType.containsKey(key)) {
              dayStats.salesbyOrderType[key] += value;
            } else {
              dayStats.salesbyOrderType[key] = value;
            }
          });
        }
      }

      if (dayStats == null) {
        return Container(
          width: double.infinity,
          height: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30),
              //Image
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    color: Colors.white,
                    image: DecorationImage(
                      image: AssetImage('images/Sales_Empty State.png'),
                      fit: BoxFit.cover,
                    )),
              ),
              SizedBox(height: 20),
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
          ),
        );
      }

      if (MediaQuery.of(context).size.width > 950) {
        return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Total sum and counts Summary
              TotalsSummary(dayStats: dayStats),
              SizedBox(height: 20),
              //Lists by Products/Category
              Container(
                height: MediaQuery.of(context).size.height * 0.8,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //Lista de ultimas ventas
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
                        child: (widget.dateFilter == 'Today')
                            ? StreamProvider<List<Sales>>.value(
                                initialData: null,
                                value: DatabaseService()
                                    .shortsalesList(widget.userBusiness),
                                child: ShortSalesList(
                                    widget.userBusiness, registerStatus),
                              )
                            : StreamProvider<List<Sales>>.value(
                                initialData: null,
                                value: DatabaseService().shortFilteredSalesList(
                                  widget.userBusiness,
                                  DateTime(
                                      widget.selectedDate.year,
                                      widget.selectedDate.month,
                                      widget.selectedDate.day,
                                      0,
                                      0,
                                      0),
                                  DateTime(
                                      widget.selectedDate.year,
                                      widget.selectedDate.month,
                                      widget.selectedDate.day,
                                      23,
                                      59,
                                      59),
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
                            Row(
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
                              ],
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
                                  ]),
                            )
                          ],
                        ),
                      )),
                    ]),
              ),
            ]);
      } else {
        return Container(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Total sum and counts Summary
                TotalsSummary(dayStats: dayStats),
                SizedBox(height: 20),
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
                  child: (widget.dateFilter == 'Today')
                      ? StreamProvider<List<Sales>>.value(
                          initialData: null,
                          value: DatabaseService()
                              .shortsalesList(widget.userBusiness),
                          child: ShortSalesList(
                              widget.userBusiness, registerStatus),
                        )
                      : StreamProvider<List<Sales>>.value(
                          initialData: null,
                          value: DatabaseService().shortFilteredSalesList(
                            widget.userBusiness,
                            DateTime(
                                widget.selectedDate.year,
                                widget.selectedDate.month,
                                widget.selectedDate.day,
                                0,
                                0,
                                0),
                            DateTime(
                                widget.selectedDate.year,
                                widget.selectedDate.month,
                                widget.selectedDate.day,
                                23,
                                59,
                                59),
                          ),
                          child: ShortSalesList(
                              widget.userBusiness, registerStatus),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          //Category
                          Container(
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        width: (_currentPageIndex == 0) ? 3 : 0,
                                        color: (_currentPageIndex == 0)
                                            ? Colors.greenAccent[700]
                                            : Colors.transparent))),
                            child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    _currentPageIndex = 0;
                                  });
                                  pageController.animateToPage(0,
                                      duration: Duration(milliseconds: 250),
                                      curve: Curves.easeIn);
                                },
                                style: ButtonStyle(
                                  overlayColor:
                                      MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.hovered)) {
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
                                        fontWeight: (_currentPageIndex == 0)
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
                                        width: (_currentPageIndex == 1) ? 3 : 0,
                                        color: (_currentPageIndex == 1)
                                            ? Colors.greenAccent[700]
                                            : Colors.transparent))),
                            child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    _currentPageIndex = 1;
                                  });
                                  pageController.animateToPage(1,
                                      duration: Duration(milliseconds: 250),
                                      curve: Curves.easeIn);
                                },
                                style: ButtonStyle(
                                  overlayColor:
                                      MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.hovered)) {
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
                                        fontWeight: (_currentPageIndex == 1)
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
                                        width: (_currentPageIndex == 2) ? 3 : 0,
                                        color: (_currentPageIndex == 2)
                                            ? Colors.greenAccent[700]
                                            : Colors.transparent))),
                            child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    _currentPageIndex = 2;
                                  });
                                  pageController.animateToPage(3,
                                      duration: Duration(milliseconds: 250),
                                      curve: Curves.easeIn);
                                },
                                style: ButtonStyle(
                                  overlayColor:
                                      MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.hovered)) {
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
                                        fontWeight: (_currentPageIndex == 2)
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: (_currentPageIndex == 2)
                                            ? Colors.greenAccent[700]
                                            : Colors.black),
                                  ),
                                )),
                          ),
                        ],
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
