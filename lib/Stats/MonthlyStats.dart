import 'package:denario/Models/Categories.dart';
import 'package:denario/Models/DailyCash.dart';
import 'package:denario/Models/Stats.dart';
import 'package:denario/Stats/StatsByCategory.dart';
import 'package:denario/Stats/StatsByPaymentMethods.dart';
import 'package:denario/Stats/StatsByProducts.dart';
import 'package:denario/Stats/TotalsSummary.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MonthStats extends StatefulWidget {
  @override
  State<MonthStats> createState() => _MonthStatsState();
}

class _MonthStatsState extends State<MonthStats> {
  final PageController pageController = PageController();

  int _currentPageIndex = 0;

  List productsList = [];

  @override
  Widget build(BuildContext context) {
    final formatCurrency = new NumberFormat.simpleCurrency();
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

      var productsList = monthlyStats.salesAmountbyProduct.keys.toList();

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
                Expanded(
                  child: Container(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          //Lista de ultimas ventas
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
                            child: Center(child: Text('Lista de ventas')),
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
                                                  width:
                                                      (_currentPageIndex == 0)
                                                          ? 3
                                                          : 0,
                                                  color: (_currentPageIndex ==
                                                          0)
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
                                                  color: (_currentPageIndex ==
                                                          0)
                                                      ? Colors.greenAccent[700]
                                                      : Colors.black),
                                            ),
                                          )),
                                    ),
                                    SizedBox(width: 20),
                                    //Products
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  width:
                                                      (_currentPageIndex == 1)
                                                          ? 3
                                                          : 0,
                                                  color: (_currentPageIndex ==
                                                          1)
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
                                                  color: (_currentPageIndex ==
                                                          1)
                                                      ? Colors.greenAccent[700]
                                                      : Colors.black),
                                            ),
                                          )),
                                    ),
                                    SizedBox(width: 20),
                                    //Payment Methods
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  width:
                                                      (_currentPageIndex == 2)
                                                          ? 3
                                                          : 0,
                                                  color: (_currentPageIndex ==
                                                          2)
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
                                                  color: (_currentPageIndex ==
                                                          2)
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
                                              StatsByCategory(
                                                  dayStats,
                                                  categoriesProvider
                                                      .categoryList)
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
                                            ])
                                      ]),
                                )
                              ],
                            ),
                          )),
                        ]),
                  ),
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
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                  child: Column(
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            //Total Sales
                            Container(
                              width: 200,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    //Amount
                                    Text(
                                      '${formatCurrency.format(monthlyStats.totalSales)}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 25),
                                    ),
                                    SizedBox(height: 10),
                                    //Text
                                    Text(
                                      'Ingresos por Ventas',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: Colors.grey),
                                    )
                                  ]),
                            ),
                            SizedBox(width: 20),
                            //Sales count
                            Container(
                              width: 200,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    //Amount
                                    Text(
                                      '${monthlyStats.totalSalesCount}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 25),
                                    ),
                                    SizedBox(height: 10),
                                    //Text
                                    Text(
                                      'No. de Ventas',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: Colors.grey),
                                    )
                                  ]),
                            ),
                          ]),
                      SizedBox(height: 15),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            //Products sold
                            Container(
                              width: 200,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    //Amount
                                    Text(
                                      '${monthlyStats.totalItemsSold}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 25),
                                    ),
                                    SizedBox(height: 10),
                                    //Text
                                    Text(
                                      'Productos Vendidos',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: Colors.grey),
                                    )
                                  ]),
                            ),
                            SizedBox(width: 20),
                            //Average Sale
                            Container(
                              width: 200,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    //Amount
                                    Text(
                                      '${formatCurrency.format(monthlyStats.totalSales / monthlyStats.totalSalesCount)}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 25),
                                    ),
                                    SizedBox(height: 10),
                                    //Text
                                    Text(
                                      'Promedio por Venta',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: Colors.grey),
                                    )
                                  ]),
                            ),
                          ]),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                //Lists by Products/Category
                Container(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //By Product
                        Container(
                          width: double.infinity,
                          height: 500,
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //Title
                                Container(
                                  height: 40,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        //Title
                                        Text(
                                          'Ventas por producto',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 18),
                                        ),
                                        Spacer(),
                                        //Search Button
                                        IconButton(
                                            onPressed: () {},
                                            icon: Icon(Icons.search_outlined))
                                      ]),
                                ),
                                Divider(
                                    thickness: 0.5, indent: 0, endIndent: 0),
                                SizedBox(height: 10),
                                //Titles
                                Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      //Producto
                                      Container(
                                          width: 150,
                                          child: Text(
                                            'Producto',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )),
                                      Spacer(),
                                      //Monto vendidos
                                      Container(
                                          width: 75,
                                          child: Center(
                                            child: Text(
                                                'Monto', //expenseList[i].total
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                )),
                                          )),
                                      SizedBox(width: 25),
                                      //Cantidad vendido
                                      Container(
                                          width: 75,
                                          child: Center(
                                            child: Text(
                                              'Cantidad', //'${expenseList[i].costType}',
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )),
                                    ]),
                                SizedBox(height: 10),
                                //List
                                Expanded(
                                  child: Container(
                                    child: ListView.builder(
                                        itemCount: productsList.length,
                                        shrinkWrap: true,
                                        reverse: false,
                                        physics: BouncingScrollPhysics(),
                                        itemBuilder: (context, i) {
                                          return Container(
                                            height: 50,
                                            width: double.infinity,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                //Producto
                                                Container(
                                                    width: 150,
                                                    child: Text(
                                                      '${productsList[i]}',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )),
                                                Spacer(),
                                                //Monto vendidos
                                                Container(
                                                    width: 75,
                                                    child: Center(
                                                      child: Text(
                                                        '${formatCurrency.format(monthlyStats.salesAmountbyProduct[productsList[i]])}',
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    )),
                                                SizedBox(width: 25),
                                                //Cantidad vendido
                                                Container(
                                                    width: 75,
                                                    child: Center(
                                                      child: Text(
                                                        '${monthlyStats.salesCountbyProduct[productsList[i]]}', //'${expenseList[i].costType}',
                                                        textAlign:
                                                            TextAlign.end,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                    )),
                                              ],
                                            ),
                                          );
                                        }),
                                  ),
                                )
                              ]),
                        ),
                        SizedBox(height: 20),
                        //By Categories
                        Container(
                          width: double.infinity,
                          height: 500,
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //Title
                                Container(
                                  height: 40,
                                  child: Text(
                                    'Ventas por Categoría',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18),
                                  ),
                                ),
                                Divider(
                                    thickness: 0.5, indent: 0, endIndent: 0),
                                SizedBox(height: 10),
                                //List
                                Expanded(
                                  child: Container(
                                    child: ListView.builder(
                                        itemCount: categoriesProvider
                                            .categoryList.length,
                                        shrinkWrap: true,
                                        reverse: false,
                                        physics: BouncingScrollPhysics(),
                                        itemBuilder: (context, i) {
                                          return Container(
                                            height: 50,
                                            width: double.infinity,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                //Producto
                                                Container(
                                                    width: 150,
                                                    child: Text(
                                                      '${categoriesProvider.categoryList[i]}',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )),
                                                Spacer(),
                                                //Monto vendidos
                                                Container(
                                                    width: 120,
                                                    child: Center(
                                                      child: Text(
                                                        (monthlyStats.salesAmountbyCategory[
                                                                    (categoriesProvider
                                                                            .categoryList[
                                                                        i])] !=
                                                                null)
                                                            ? '${formatCurrency.format(monthlyStats.salesAmountbyCategory[(categoriesProvider.categoryList[i])])}'
                                                            : '${formatCurrency.format(0)}',
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    )),
                                              ],
                                            ),
                                          );
                                        }),
                                  ),
                                )
                              ]),
                        ),
                        //Payment Methods
                        Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(thickness: 0.5, indent: 0, endIndent: 0),
                              //List
                              StatsByPaymentMethods(
                                  dayStats, registerStatus.paymentTypes)
                            ])
                      ]),
                ),
              ]),
        );
      }
    }
  }
}
