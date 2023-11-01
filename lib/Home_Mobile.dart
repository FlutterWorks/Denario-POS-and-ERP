import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Backend/auth.dart';
import 'package:denario/Dashboard/DailyDesk.dart';
import 'package:denario/Expenses/ExpensesDesk.dart';
import 'package:denario/Loading.dart';
import 'package:denario/Models/Categories.dart';
import 'package:denario/Models/DailyCash.dart';
import 'package:denario/Models/Mapping.dart';
import 'package:denario/Models/PendingOrders.dart';
import 'package:denario/Models/Products.dart';
import 'package:denario/Models/SavedOrders.dart';
import 'package:denario/Models/Stats.dart';
import 'package:denario/Models/Tables.dart';
import 'package:denario/Models/User.dart';
import 'package:denario/No%20POS%20Sales/NoPOSDashboard.dart';
import 'package:denario/POS/POS_Products.dart';
import 'package:denario/POS/TicketView.dart';
import 'package:denario/PnL/PnlDesk.dart';
import 'package:denario/Products/ProductsDesk.dart';
import 'package:denario/Schedule/ScheduleDesk.dart';
import 'package:denario/Stats/StatsDesk.dart';
import 'package:denario/Suppliers/SuppliersDesk.dart';
import 'package:denario/Supplies/SuppliesDesk.dart';
import 'package:denario/Wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeMobile extends StatefulWidget {
  @override
  _HomeMobileState createState() => _HomeMobileState();
}

class _HomeMobileState extends State<HomeMobile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _auth = AuthService();
  int pageIndex = 0;
  bool showUserSettings = false;
  List<Widget>? navigationBarItems;
  List<Widget>? pageNavigators;

  //Change Business Dialog
  void changeBusinessDialog(List<UserBusinessData> businesess, activeBusiness) {
    showDialog(
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            child: Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.8,
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //Go back
                    Container(
                      alignment: Alignment(1.0, 0.0),
                      child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close),
                          iconSize: 20.0),
                    ),
                    //Title
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Cambiar de negocio en pantalla",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Expanded(
                        child: ListView.builder(
                            itemCount: businesess.length,
                            itemBuilder: ((context, i) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    backgroundColor: (activeBusiness ==
                                            businesess[i].businessID)
                                        ? Colors.greenAccent
                                        : Colors.white,
                                    minimumSize: Size(50, 50),
                                  ),
                                  onPressed: () {
                                    if (activeBusiness !=
                                        businesess[i].businessID) {
                                      DatabaseService().changeActiveBusiness(
                                          businesess[i].businessID!);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Wrapper()));
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 8),
                                    child: Column(
                                      children: [
                                        Text(
                                          '${businesess[i].businessName}',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'ID: ${businesess[i].businessID}',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              color: (activeBusiness ==
                                                      businesess[i].businessID)
                                                  ? Colors.black54
                                                  : Colors.grey,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'Rol: ${businesess[i].roleInBusiness}',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              color: (activeBusiness ==
                                                      businesess[i].businessID)
                                                  ? Colors.black54
                                                  : Colors.grey,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }))),
                    SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget screenNavigator(String screenName, IconData screenIcon, int index) {
    return TextButton(
      style: TextButton.styleFrom(
          foregroundColor: Colors.white, fixedSize: Size(double.infinity, 50)),
      onPressed: () {
        setState(() {
          pageIndex = index;
        });
        _scaffoldKey.currentState!.closeDrawer();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //Icon
          Icon(screenIcon, color: Colors.white, size: 25),
          SizedBox(width: 10),
          //Text
          Text(
            screenName,
            style: TextStyle(color: Colors.white, fontSize: 11),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  void openDrawer() {
    _scaffoldKey.currentState!.openDrawer();
  }

  void reloadApp() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Wrapper()));
  }

  @override
  Widget build(BuildContext context) {
    final registerStatus = Provider.of<CashRegister?>(context);
    final categoriesProvider = Provider.of<CategoryList?>(context);
    final userProfile = Provider.of<UserData?>(context);
    final userBusiness = Provider.of<BusinessProfile?>(context);

    if (userProfile == null ||
        registerStatus == null ||
        categoriesProvider == null ||
        userBusiness == null) {
      return Loading();
    }

    // pageNavigators = [
    //   Navigator(onGenerateRoute: (routeSettings) {
    //     return MaterialPageRoute(builder: (context) {
    //       if (userBusiness.businessField == 'Gastronómico' ||
    //           userBusiness.businessField == 'Tienda Minorista') {
    //         return POSProducts(categoriesProvider.categoryList[0]);
    //       } else {
    //         return NoPOSDashboard(userProfile.activeBusiness);
    //       }
    //     });
    //   }),
    // ];
    final businessIndexOnProfile = userProfile.businesses!.indexWhere(
        (element) => element.businessID == userProfile.activeBusiness);

    if (userProfile.businesses![businessIndexOnProfile].roleInBusiness ==
        'Dueñ@') {
      navigationBarItems = [
        screenNavigator(
            (userBusiness.businessField == 'Gastronómico' ||
                    userBusiness.businessField == 'Venta Minorista' ||
                    userBusiness.businessField == 'Belleza/Spa')
                ? 'POS'
                : 'Inicio',
            (userBusiness.businessField == 'Gastronómico' ||
                    userBusiness.businessField == 'Venta Minorista' ||
                    userBusiness.businessField == 'Belleza/Spa')
                ? Icons.blur_circular
                : Icons.home,
            0),
        (userBusiness.cashBalancing!)
            ? screenNavigator('Caja', Icons.fax, 1)
            : SizedBox(),
        screenNavigator('Agenda', Icons.calendar_month_outlined, 2),
        screenNavigator('Ventas', Icons.insert_chart_outlined, 3),
        screenNavigator('Gastos', Icons.multiline_chart, 4),
        screenNavigator('Productos', Icons.assignment, 5),
        screenNavigator('Proveedores', Icons.local_shipping_outlined, 6),
        screenNavigator('Insumos', Icons.shopping_basket_outlined, 7),
        screenNavigator('PnL', Icons.data_usage, 8)
      ];
      pageNavigators = [
        Navigator(onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(builder: (context) {
            if (userBusiness.businessField == 'Gastronómico' ||
                userBusiness.businessField == 'Venta Minorista' ||
                userBusiness.businessField == 'Belleza/Spa') {
              return POSProducts(
                categoriesProvider.categoryList![0] ?? '',
                scaffoldKeyMobile: _scaffoldKey,
              );
            } else {
              return NoPOSDashboard(userProfile.activeBusiness!);
            }
          });
        }),
        (userBusiness.cashBalancing!)
            ? Navigator(onGenerateRoute: (routeSettings) {
                return MaterialPageRoute(builder: (context) => DailyDesk());
              })
            : Container(),
        Navigator(onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(builder: (context) => ScheduleDesk());
        }),
        Navigator(onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
              builder: (context) =>
                  StatsDesk(userProfile.activeBusiness!, registerStatus));
        }),
        Navigator(onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(builder: (context) => ExpensesDesk('Dueñ@'));
        }),
        Navigator(onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
              builder: (context) => ProductDesk(
                  userProfile.activeBusiness!,
                  categoriesProvider.categoryList!,
                  userBusiness.businessField!,
                  reloadApp));
        }),
        Navigator(onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(builder: (context) => SuppliersDesk());
        }),
        Navigator(onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
              builder: (context) => SuppliesDesk(
                  userProfile.activeBusiness!,
                  categoriesProvider.categoryList!,
                  userBusiness.businessField!));
        }),
        Navigator(onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(builder: (context) => PnlDesk());
        }),
      ];
    } else if (userProfile.businesses![businessIndexOnProfile].roleInBusiness ==
        'Encargad@') {
      navigationBarItems = [
        screenNavigator(
            (userBusiness.businessField == 'Gastronómico' ||
                    userBusiness.businessField == 'Venta Minorista' ||
                    userBusiness.businessField == 'Belleza/Spa')
                ? 'POS'
                : 'Inicio',
            (userBusiness.businessField == 'Gastronómico' ||
                    userBusiness.businessField == 'Venta Minorista' ||
                    userBusiness.businessField == 'Belleza/Spa')
                ? Icons.blur_circular
                : Icons.home,
            0),
        (userBusiness.cashBalancing!)
            ? screenNavigator('Caja', Icons.fax, 1)
            : SizedBox(),
        (userBusiness.cashBalancing!) ? SizedBox(height: 20) : SizedBox(),
        screenNavigator('Agenda', Icons.calendar_month_outlined, 2),
        screenNavigator('Ventas', Icons.insert_chart_outlined, 3),
        screenNavigator('Gastos', Icons.multiline_chart, 4),
        screenNavigator('Productos', Icons.assignment, 5),
        screenNavigator('Proveedores', Icons.local_shipping_outlined, 6),
        screenNavigator('Insumos', Icons.shopping_basket_outlined, 7),
      ];
      pageNavigators = [
        Navigator(onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(builder: (context) {
            if (userBusiness.businessField == 'Gastronómico' ||
                userBusiness.businessField == 'Tienda Minorista') {
              return POSProducts(categoriesProvider.categoryList![0]);
            } else {
              return NoPOSDashboard(userProfile.activeBusiness!);
            }
          });
        }),
        (userBusiness.cashBalancing!)
            ? Navigator(onGenerateRoute: (routeSettings) {
                return MaterialPageRoute(builder: (context) => DailyDesk());
              })
            : Container(),
        Navigator(onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(builder: (context) => ScheduleDesk());
        }),
        Navigator(onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
              builder: (context) =>
                  StatsDesk(userProfile.activeBusiness!, registerStatus));
        }),
        Navigator(onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
              builder: (context) => ExpensesDesk('Encargad@'));
        }),
        Navigator(onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
              builder: (context) => ProductDesk(
                  userProfile.activeBusiness!,
                  categoriesProvider.categoryList!,
                  userBusiness.businessField!,
                  reloadApp));
        }),
        Navigator(onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(builder: (context) => SuppliersDesk());
        }),
        Navigator(onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
              builder: (context) => SuppliesDesk(
                  userProfile.activeBusiness!,
                  categoriesProvider.categoryList!,
                  userBusiness.businessField!));
        }),
      ];
    } else if (userProfile.businesses![businessIndexOnProfile].roleInBusiness ==
        'Cajer@') {
      navigationBarItems = [
        screenNavigator(
            (userBusiness.businessField == 'Gastronómico' ||
                    userBusiness.businessField == 'Venta Minorista' ||
                    userBusiness.businessField == 'Belleza/Spa')
                ? 'POS'
                : 'Inicio',
            (userBusiness.businessField == 'Gastronómico' ||
                    userBusiness.businessField == 'Venta Minorista' ||
                    userBusiness.businessField == 'Belleza/Spa')
                ? Icons.blur_circular
                : Icons.home,
            0),
        (userBusiness.cashBalancing!)
            ? screenNavigator('Caja', Icons.fax, 1)
            : SizedBox(),
        screenNavigator('Agenda', Icons.calendar_month_outlined, 2),
        screenNavigator('Gastos', Icons.multiline_chart, 3),
      ];
      pageNavigators = [
        Navigator(onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(builder: (context) {
            if (userBusiness.businessField == 'Gastronómico' ||
                userBusiness.businessField == 'Tienda Minorista') {
              return POSProducts(categoriesProvider.categoryList![0]);
            } else {
              return NoPOSDashboard(userProfile.activeBusiness!);
            }
          });
        }),
        (userBusiness.businessField == 'Gastronómico' ||
                userBusiness.businessField == 'Tienda Minorista')
            ? Navigator(onGenerateRoute: (routeSettings) {
                return MaterialPageRoute(builder: (context) => DailyDesk());
              })
            : Container(),
        Navigator(onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(builder: (context) => ScheduleDesk());
        }),
        Navigator(onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
              builder: (context) => ExpensesDesk('Cajer@'));
        }),
      ];
    } else if (userProfile.businesses![businessIndexOnProfile].roleInBusiness ==
        'Contador(a)') {
      navigationBarItems = [
        screenNavigator('Ventas', Icons.insert_chart_outlined, 1),
        screenNavigator('Gastos', Icons.multiline_chart, 4),
        screenNavigator('PnL', Icons.data_usage, 2),
      ];
      pageNavigators = [
        Navigator(onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
              builder: (context) =>
                  StatsDesk(userProfile.activeBusiness!, registerStatus));
        }),
        Navigator(onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
              builder: (context) => ExpensesDesk('Encargad@'));
        }),
        Navigator(onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(builder: (context) => PnlDesk());
        }),
      ];
    } else if (userProfile.businesses![businessIndexOnProfile].roleInBusiness ==
            'Moz@' ||
        userProfile.businesses![businessIndexOnProfile].roleInBusiness ==
            'Otro') {
      navigationBarItems = [
        screenNavigator('POS', Icons.blur_circular, 0),
        screenNavigator('Agenda', Icons.calendar_month_outlined, 1),
      ];
      pageNavigators = [
        Navigator(onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(builder: (context) {
            if (userBusiness.businessField == 'Gastronómico' ||
                userBusiness.businessField == 'Venta Minorista' ||
                userBusiness.businessField == 'Belleza/Spa') {
              return POSProducts(categoriesProvider.categoryList![0]);
            } else {
              return NoPOSDashboard(userProfile.activeBusiness!);
            }
          });
        }),
        Navigator(onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(builder: (context) => ScheduleDesk());
        }),
      ];
    }
    return MultiProvider(
      providers: [
        StreamProvider<List<Products>>.value(
            initialData: [],
            value:
                DatabaseService().fullProductList(userProfile.activeBusiness!)),
        StreamProvider<CategoryList?>.value(
            initialData: null,
            value:
                DatabaseService().categoriesList(userProfile.activeBusiness)),
        StreamProvider<HighLevelMapping?>.value(
            initialData: null,
            value:
                DatabaseService().highLevelMapping(userProfile.activeBusiness)),
        StreamProvider<DailyTransactions?>.value(
            initialData: null,
            catchError: (_, err) => null,
            value: DatabaseService().dailyTransactions(
                userProfile.activeBusiness, registerStatus.registerName!)),
        StreamProvider<MonthlyStats?>.value(
            initialData: null,
            value: DatabaseService()
                .monthlyStatsfromSnapshot(userProfile.activeBusiness!)),
        StreamProvider<List<DailyTransactions>>.value(
            initialData: [],
            value: DatabaseService()
                .dailyTransactionsList(userProfile.activeBusiness)),
        StreamProvider<List<PendingOrders>>.value(
            initialData: [],
            value:
                DatabaseService().pendingOrderList(userProfile.activeBusiness)),
        StreamProvider<AccountsList?>.value(
            initialData: null,
            value: DatabaseService().accountsList(userProfile.activeBusiness)),
        StreamProvider<List<Tables>>.value(
          initialData: [],
          value: DatabaseService().tableList(userProfile.activeBusiness!),
        ),
        StreamProvider<List<SavedOrders>>.value(
            initialData: [],
            value: DatabaseService()
                .savedCounterOrders(userProfile.activeBusiness)),
      ],
      child: Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          child: Container(
              color: Colors.black87,
              height: double.infinity,
              width: 75,
              child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      //Name
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            //User
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white24),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    //Image
                                    Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                            color: Colors.grey,
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                    userProfile.profileImage!),
                                                fit: BoxFit.cover))),
                                    SizedBox(width: 10),
                                    //Name
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        //Name
                                        Text(
                                          userProfile.name!,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal),
                                        ),
                                        SizedBox(height: 5),
                                        //Current business
                                        Text(
                                          userProfile
                                              .businesses![
                                                  businessIndexOnProfile]
                                              .businessName!,
                                          style: TextStyle(
                                              color: Colors.grey.shade300,
                                              fontSize: 11,
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    //Icons
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                      size: 14,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            //Change business
                            TextButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey,
                              ),
                              onPressed: () {
                                changeBusinessDialog(userProfile.businesses!,
                                    userProfile.activeBusiness);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.swap_horiz_outlined,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "Cambiar de negocio",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white,
                                        ),
                                      )
                                    ]),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        indent: 25,
                        endIndent: 25,
                        thickness: 1,
                        color: Colors.grey,
                      ),
                      //Navigation
                      Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: navigationBarItems!.length,
                              itemExtent: null,
                              itemBuilder: (context, i) {
                                return navigationBarItems![i];
                              })),
                      //Sign out
                      Container(
                        height: 150,
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        child: Column(children: [
                          Divider(
                            indent: 5,
                            endIndent: 5,
                            thickness: 1,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 10),
                          TextButton(
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                fixedSize: Size(double.infinity, 50)),
                            onPressed: () {
                              _auth.signOut();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Wrapper()));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                //Icon
                                Icon(Icons.exit_to_app,
                                    color: Colors.white, size: 25),
                                SizedBox(width: 10),
                                //Text
                                Text(
                                  'Salir',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 11),
                                  textAlign: TextAlign.center,
                                )
                              ],
                            ),
                          ),
                        ]),
                      )
                    ]),
              )),
        ),
        endDrawer: Drawer(
          //Ticket View
          child: Container(
              color: Colors.white,
              child: TicketView(userProfile, businessIndexOnProfile, false,
                  null, false, false)),
        ),
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Center(
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('images/Denario Logo.png'))),
            ),
          ),
          leading: IconButton(
              onPressed: openDrawer,
              icon: Icon(Icons.menu, color: Colors.black, size: 25)),
        ),
        body: Stack(
          children: [
            Container(
                child:
                    IndexedStack(index: pageIndex, children: pageNavigators!)),
          ],
        ),
      ),
    );
  }
}
