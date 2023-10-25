import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Dashboard/SalesDetailsFilters.dart';
import 'package:denario/Models/DailyCash.dart';
import 'package:denario/Models/Payables.dart';
import 'package:denario/Models/Receivables.dart';
import 'package:denario/Models/Sales.dart';
import 'package:denario/Models/Stats.dart';
import 'package:denario/Models/User.dart';
import 'package:denario/No%20POS%20Sales/LastSales.dart';
import 'package:denario/No%20POS%20Sales/NewSaleScreen.dart';
import 'package:denario/No%20POS%20Sales/PayablesReceivables.dart';
import 'package:denario/No%20POS%20Sales/PnLSummary.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NoPOSDashboard extends StatefulWidget {
  final String currentBusiness;

  NoPOSDashboard(this.currentBusiness);

  @override
  State<NoPOSDashboard> createState() => _NoPOSDashboardState();
}

class _NoPOSDashboardState extends State<NoPOSDashboard>
    with SingleTickerProviderStateMixin {
  final formatCurrency = new NumberFormat.simpleCurrency();

  AnimationController? _controller;
  Animation<double>? _animation;
  bool _isExpanded = false;
// • Crear nueva venta
  void _toggleDropdown() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller!.forward();
      } else {
        _controller!.reverse();
      }
    });
  }

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeInOut,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final register = Provider.of<CashRegister>(context);
    final userProfile = Provider.of<UserData>(context);

    if (userProfile == UserData()) {
      return Center();
    }

    if (MediaQuery.of(context).size.width > 1000) {
      return MultiProvider(
        providers: [
          StreamProvider<List<Payables>>.value(
              initialData: [],
              value:
                  DatabaseService().payablesList(userProfile.activeBusiness)),
          StreamProvider<List<Receivables>>.value(
              initialData: [],
              value: DatabaseService()
                  .shortReceivablesList(userProfile.activeBusiness))
        ],
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            width: double.infinity,
            child: Stack(
              children: [
                //Info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    //Title
                    Text(
                      'Hola ${userProfile.name}!',
                      textAlign: TextAlign.left,
                      style:
                          TextStyle(fontWeight: FontWeight.w900, fontSize: 30),
                    ),
                    SizedBox(height: 30),
                    //Dashboard
                    SizedBox(
                      height: 600,
                      width: double.infinity,
                      child: Row(children: [
                        //PnL and Sales
                        Expanded(
                            flex: 3,
                            child: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //Sales
                                  Expanded(
                                      flex: 1,
                                      child: PnLSummary(
                                          userProfile.activeBusiness!)),
                                  SizedBox(height: 20),
                                  //History
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 30, vertical: 15),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(25),
                                        boxShadow: <BoxShadow>[
                                          new BoxShadow(
                                            color: Colors.grey[350]!,
                                            offset: Offset(0.0,
                                                0.0), //offset: new Offset(15.0, 15.0),
                                            blurRadius: 10.0,
                                            // spreadRadius: 2.0,
                                          )
                                        ],
                                      ),
                                      child: Column(children: [
                                        //Title
                                        Row(
                                          children: [
                                            Text(
                                              'Últimas ventas',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.black),
                                            ),
                                            Spacer(),
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) => StreamProvider<
                                                                  CashRegister>.value(
                                                              initialData:
                                                                  CashRegister(),
                                                              value: DatabaseService()
                                                                  .cashRegisterStatus(
                                                                      widget
                                                                          .currentBusiness),
                                                              child: SalesDetailsFilters(
                                                                  widget
                                                                      .currentBusiness,
                                                                  register))));
                                                  // MultiProvider(
                                                  //     providers: [
                                                  //       StreamProvider<
                                                  //               List<
                                                  //                   Sales>>.value(
                                                  //           initialData: null,
                                                  //           value: DatabaseService()
                                                  //               .salesList(
                                                  //                   currentBusiness))
                                                  //     ],
                                                  //     child:
                                                  //         SalesDetailsView())));
                                                },
                                                child: Text('Ver más',
                                                    style: TextStyle(
                                                        color: Colors.black45,
                                                        fontSize: 12)))
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Divider(
                                          indent: 5,
                                          endIndent: 5,
                                          color: Colors.grey,
                                          thickness: 0.5,
                                        ),
                                        SizedBox(height: 5),
                                        //List of last sales
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
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.grey,
                                                        fontSize: 12),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                              Spacer(),
                                              Container(
                                                  width: 100,
                                                  child: Text(
                                                    'Cliente',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.grey,
                                                        fontSize: 12),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                              Spacer(),
                                              //Monto vendidos
                                              Container(
                                                  width: 100,
                                                  child: Center(
                                                    child: Text(
                                                        'Monto', //expenseList[i].total
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            color: Colors.grey,
                                                            fontSize: 12)),
                                                  )),
                                              SizedBox(width: 25),
                                              //Cantidad vendido
                                              Container(
                                                  width: 75,
                                                  child: Center(
                                                    child: Text(
                                                      'Cantidad', //'${expenseList[i].costType}',
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Colors.grey,
                                                          fontSize: 12),
                                                    ),
                                                  )),
                                            ]),
                                        SizedBox(height: 10),
                                        //List
                                        Expanded(
                                            child: StreamProvider<
                                                    List<Sales>>.value(
                                                initialData: [],
                                                value: DatabaseService()
                                                    .shortsalesList(
                                                        widget.currentBusiness),
                                                child: LastSales()))
                                      ]),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        SizedBox(width: 20),
                        //Pending
                        Expanded(
                          flex: 2,
                          child: Container(
                            child: PayablesReceivables(
                                userProfile.activeBusiness!),
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
                //Title
                Align(
                  alignment: Alignment.topRight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          foregroundColor: Colors.grey,
                        ),
                        onPressed: _toggleDropdown,
                        child: Container(
                          height: 40,
                          width: _isExpanded ? 40 : 100,
                          padding: const EdgeInsets.symmetric(
                              vertical: 2.0, horizontal: 10),
                          child: Center(
                            child: Text(
                              _isExpanded ? 'X' : 'Crear',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                      ),
                      if (_isExpanded)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: FadeTransition(
                            opacity: _animation!,
                            child: Container(
                              height: 35,
                              width: 150,
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.white),
                                    overlayColor: MaterialStateProperty
                                        .resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                        if (states
                                            .contains(MaterialState.hovered))
                                          return Colors.grey;
                                        if (states.contains(
                                                MaterialState.focused) ||
                                            states.contains(
                                                MaterialState.pressed))
                                          return Colors.grey.shade300;
                                        return Colors.grey
                                            .shade300; // Defer to the widget's default.
                                      },
                                    ),
                                  ),
                                  onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => StreamProvider<
                                                  MonthlyStats>.value(
                                                value: DatabaseService()
                                                    .monthlyStatsfromSnapshot(
                                                        widget.currentBusiness),
                                                initialData: MonthlyStats(),
                                                child: NewSaleScreen(
                                                  widget.currentBusiness,
                                                  fromPOS: false,
                                                ),
                                              ))),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 5),
                                    child: Center(
                                      child: Text(
                                        'Crear Venta',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  )),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: FadeTransition(
                          opacity: _animation!,
                          child: Container(
                            height: 35,
                            width: 150,
                            child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white),
                                  overlayColor:
                                      MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.hovered))
                                        return Colors.grey;
                                      if (states.contains(
                                              MaterialState.focused) ||
                                          states
                                              .contains(MaterialState.pressed))
                                        return Colors.grey.shade300;
                                      return Colors.grey
                                          .shade300; // Defer to the widget's default.
                                    },
                                  ),
                                ),
                                onPressed: () {},
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 5),
                                  child: Center(
                                    child: Text(
                                      'Crear Gasto',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                )),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (MediaQuery.of(context).size.width > 650) {
      return MultiProvider(
        providers: [
          StreamProvider<List<Payables>>.value(
              initialData: [],
              value:
                  DatabaseService().payablesList(userProfile.activeBusiness)),
          StreamProvider<List<Receivables>>.value(
              initialData: [],
              value: DatabaseService()
                  .shortReceivablesList(userProfile.activeBusiness))
        ],
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            width: double.infinity,
            child: Stack(
              children: [
                //Info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    //Title
                    Text(
                      'Hola ${userProfile.name}!',
                      textAlign: TextAlign.left,
                      style:
                          TextStyle(fontWeight: FontWeight.w900, fontSize: 30),
                    ),
                    SizedBox(height: 30),
                    //Dashboard
                    SizedBox(
                      width: double.infinity,
                      child: Column(children: [
                        //PnL and Sales
                        Container(
                            height: 200,
                            width: double.infinity,
                            child: PnLSummary(userProfile.activeBusiness!)),
                        SizedBox(height: 20),
                        //Pending
                        Container(
                          height: 400,
                          width: double.infinity,
                          child:
                              PayablesReceivables(userProfile.activeBusiness!),
                        ),
                        SizedBox(height: 20),
                        //History
                        Container(
                          height: 400,
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: <BoxShadow>[
                              new BoxShadow(
                                color: Colors.grey[350]!,
                                offset: Offset(
                                    0.0, 0.0), //offset: new Offset(15.0, 15.0),
                                blurRadius: 10.0,
                                // spreadRadius: 2.0,
                              )
                            ],
                          ),
                          child: Column(children: [
                            //Title
                            Row(
                              children: [
                                Text(
                                  'Últimas ventas',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.black),
                                ),
                                Spacer(),
                                TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => StreamProvider<
                                                      CashRegister>.value(
                                                  initialData: CashRegister(),
                                                  value: DatabaseService()
                                                      .cashRegisterStatus(widget
                                                          .currentBusiness),
                                                  child: SalesDetailsFilters(
                                                      widget.currentBusiness,
                                                      register))));
                                      // MultiProvider(
                                      //     providers: [
                                      //       StreamProvider<
                                      //               List<
                                      //                   Sales>>.value(
                                      //           initialData: null,
                                      //           value: DatabaseService()
                                      //               .salesList(
                                      //                   currentBusiness))
                                      //     ],
                                      //     child:
                                      //         SalesDetailsView())));
                                    },
                                    child: Text('Ver más',
                                        style: TextStyle(
                                            color: Colors.black45,
                                            fontSize: 12)))
                              ],
                            ),
                            SizedBox(height: 5),
                            Divider(
                              indent: 5,
                              endIndent: 5,
                              color: Colors.grey,
                              thickness: 0.5,
                            ),
                            SizedBox(height: 5),
                            //List of last sales
                            //Titles
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  //Producto
                                  Container(
                                      width: 150,
                                      child: Text(
                                        'Producto',
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: Colors.grey,
                                            fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )),
                                  Spacer(),
                                  Container(
                                      width: 100,
                                      child: Text(
                                        'Cliente',
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: Colors.grey,
                                            fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )),
                                  Spacer(),
                                  //Monto vendidos
                                  Container(
                                      width: 100,
                                      child: Center(
                                        child: Text(
                                            'Monto', //expenseList[i].total
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color: Colors.grey,
                                                fontSize: 12)),
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
                                              fontWeight: FontWeight.normal,
                                              color: Colors.grey,
                                              fontSize: 12),
                                        ),
                                      )),
                                ]),
                            SizedBox(height: 10),
                            //List
                            Expanded(
                                child: StreamProvider<List<Sales>>.value(
                                    initialData: [],
                                    value: DatabaseService()
                                        .shortsalesList(widget.currentBusiness),
                                    child: LastSales()))
                          ]),
                        ),
                      ]),
                    ),
                  ],
                ),
                //Title
                Align(
                  alignment: Alignment.topRight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          foregroundColor: Colors.grey,
                        ),
                        onPressed: _toggleDropdown,
                        child: Container(
                          height: 40,
                          width: _isExpanded ? 40 : 100,
                          padding: const EdgeInsets.symmetric(
                              vertical: 2.0, horizontal: 10),
                          child: Center(
                            child: Text(
                              _isExpanded ? 'X' : 'Crear',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                      ),
                      if (_isExpanded)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: FadeTransition(
                            opacity: _animation!,
                            child: Container(
                              height: 35,
                              width: 150,
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.white),
                                    overlayColor: MaterialStateProperty
                                        .resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                        if (states
                                            .contains(MaterialState.hovered))
                                          return Colors.grey;
                                        if (states.contains(
                                                MaterialState.focused) ||
                                            states.contains(
                                                MaterialState.pressed))
                                          return Colors.grey.shade300;
                                        return Colors.grey
                                            .shade300; // Defer to the widget's default.
                                      },
                                    ),
                                  ),
                                  onPressed: () {
                                    _toggleDropdown();
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                StreamProvider<
                                                    MonthlyStats>.value(
                                                  value: DatabaseService()
                                                      .monthlyStatsfromSnapshot(
                                                          widget
                                                              .currentBusiness),
                                                  initialData: MonthlyStats(),
                                                  child: NewSaleScreen(
                                                    widget.currentBusiness,
                                                    fromPOS: false,
                                                  ),
                                                )));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 5),
                                    child: Center(
                                      child: Text(
                                        'Crear Venta',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  )),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: FadeTransition(
                          opacity: _animation!,
                          child: Container(
                            height: 35,
                            width: 150,
                            child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white),
                                  overlayColor:
                                      MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.hovered))
                                        return Colors.grey;
                                      if (states.contains(
                                              MaterialState.focused) ||
                                          states
                                              .contains(MaterialState.pressed))
                                        return Colors.grey.shade300;
                                      return Colors.grey
                                          .shade300; // Defer to the widget's default.
                                    },
                                  ),
                                ),
                                onPressed: () {},
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 5),
                                  child: Center(
                                    child: Text(
                                      'Crear Gasto',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                )),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
