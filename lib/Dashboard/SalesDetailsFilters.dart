import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Dashboard/SalesDetailsView.dart';
import 'package:denario/Models/DailyCash.dart';
import 'package:denario/Models/Sales.dart';
import 'package:denario/Models/Stats.dart';
import 'package:denario/Models/User.dart';
import 'package:denario/No%20POS%20Sales/NewSaleScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SalesDetailsFilters extends StatefulWidget {
  final String currentBusiness;
  final CashRegister registerStatus;
  SalesDetailsFilters(this.currentBusiness, this.registerStatus);

  @override
  State<SalesDetailsFilters> createState() => _SalesDetailsFiltersState();
}

class _SalesDetailsFiltersState extends State<SalesDetailsFilters> {
  DateTime initDate;
  DateTime endDate;
  String paymentType;
  bool filtered;
  List paymentTypes = [];

  bool dateFiltered;
  bool paymentFiltered;

  @override
  void initState() {
    initDate = DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day, 0, 0, 0)
        .subtract(Duration(days: 1));
    endDate = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, 23, 59, 59);
    filtered = false;
    dateFiltered = false;
    paymentFiltered = false;

    for (var i = 0; i < widget.registerStatus.paymentTypes.length; i++) {
      paymentTypes.add(widget.registerStatus.paymentTypes[i]['Type']);
    }

    paymentTypes.insert(0, 'Todos');
    paymentTypes.add('Por Cobrar');
    paymentType = 'Todos';

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width > 650) {
      return Scaffold(
          body: CustomScrollView(
        slivers: [
          //Go Back /// Title //Filters
          SliverAppBar(
            floating: true,
            backgroundColor: Colors.white,
            pinned: false,
            automaticallyImplyLeading: false,
            actions: <Widget>[Container()],
            expandedHeight:
                (MediaQuery.of(context).size.width > 800) ? 150 : 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    //Go Back /// Title
                    (MediaQuery.of(context).size.width > 800)
                        ? Container(
                            width: double.infinity,
                            height: 75,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  //Back
                                  IconButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      icon: Icon(Icons.arrow_back)),
                                  SizedBox(width: 25),
                                  Text(
                                    'Historial de ventas',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Spacer(),
                                  Container(
                                    height: 50,
                                    child: Tooltip(
                                      message:
                                          'Registrar o agendar nueva venta',
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.black,
                                        ),
                                        onPressed: () {
                                          final User user =
                                              FirebaseAuth.instance.currentUser;
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      MultiProvider(
                                                        providers: [
                                                          StreamProvider<
                                                                  UserData>.value(
                                                              initialData: null,
                                                              value: DatabaseService()
                                                                  .userProfile(user
                                                                      .uid
                                                                      .toString())),
                                                          StreamProvider<
                                                              MonthlyStats>.value(
                                                            value: DatabaseService()
                                                                .monthlyStatsfromSnapshot(
                                                                    widget
                                                                        .currentBusiness),
                                                            initialData: null,
                                                          )
                                                        ],
                                                        child: Scaffold(
                                                            body: NewSaleScreen(
                                                          widget
                                                              .currentBusiness,
                                                          fromPOS: false,
                                                        )),
                                                      )));
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.add, size: 16),
                                                SizedBox(width: 10),
                                                Text('Nueva venta')
                                              ]),
                                        ),
                                      ),
                                    ),
                                  )
                                ]),
                          )
                        : Container(
                            width: double.infinity,
                            height: 75,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  //Back
                                  IconButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      icon: Icon(Icons.arrow_back)),
                                  SizedBox(width: 15),
                                  Text(
                                    'Historial de ventas',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ]),
                          ),
                    //Filters
                    (MediaQuery.of(context).size.width > 800)
                        ? Container(
                            height: 70,
                            padding: EdgeInsets.symmetric(horizontal: 20),
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                //Fecha
                                Container(
                                  width: 150,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[350]),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  padding: EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Text(
                                        DateFormat('dd/MM/yyyy')
                                            .format(initDate),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16),
                                      ),
                                      Spacer(),
                                      Container(
                                        height: 20,
                                        width: 20,
                                        child: IconButton(
                                          splashRadius: 1,
                                          onPressed: () async {
                                            DateTime pickedDate =
                                                await showDatePicker(
                                                    context: context,
                                                    initialDate: initDate,
                                                    firstDate: DateTime.now()
                                                        .subtract(Duration(
                                                            days: 730)),
                                                    lastDate: DateTime.now(),
                                                    builder: ((context, child) {
                                                      return Theme(
                                                          data:
                                                              Theme.of(context)
                                                                  .copyWith(
                                                            colorScheme:
                                                                ColorScheme
                                                                    .light(
                                                              primary: Colors
                                                                  .black, // header background color
                                                              onPrimary: Colors
                                                                  .white, // header text color
                                                              onSurface: Colors
                                                                  .black, // body text color
                                                            ),
                                                            textButtonTheme:
                                                                TextButtonThemeData(
                                                              style: TextButton
                                                                  .styleFrom(
                                                                foregroundColor:
                                                                    Colors
                                                                        .black, // button text color
                                                              ),
                                                            ),
                                                          ),
                                                          child: child);
                                                    }));
                                            setState(() {
                                              if (pickedDate != null) {
                                                initDate = pickedDate;
                                                endDate = DateTime(
                                                    pickedDate.year,
                                                    pickedDate.month + 1,
                                                    0);
                                                filtered = true;
                                              }
                                            });
                                          },
                                          padding: EdgeInsets.all(0),
                                          tooltip:
                                              'Selecciona un fecha inicial',
                                          iconSize: 18,
                                          icon: Icon(Icons.calendar_month),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10),
                                Container(
                                    width: 150,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Colors.grey[350]),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    padding: EdgeInsets.all(12),
                                    child: //(DateTime.now().difference(initDate).inDays > 1)
                                        // ?
                                        Row(
                                      children: [
                                        Text(
                                          (endDate == null)
                                              ? 'Hasta fecha'
                                              : DateFormat('dd/MM/yyyy')
                                                  .format(endDate),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 16),
                                        ),
                                        Spacer(),
                                        Container(
                                          height: 20,
                                          width: 20,
                                          child: IconButton(
                                            splashRadius: 1,
                                            onPressed: () async {
                                              DateTime pickedDate =
                                                  await showDatePicker(
                                                      context: context,
                                                      initialDate: initDate.add(
                                                          Duration(days: 1)),
                                                      firstDate: initDate,
                                                      lastDate: DateTime(
                                                          initDate.year,
                                                          initDate.month + 1,
                                                          0),
                                                      builder:
                                                          ((context, child) {
                                                        return Theme(
                                                            data: Theme.of(
                                                                    context)
                                                                .copyWith(
                                                              colorScheme:
                                                                  ColorScheme
                                                                      .light(
                                                                primary: Colors
                                                                    .black, // header background color
                                                                onPrimary: Colors
                                                                    .white, // header text color
                                                                onSurface: Colors
                                                                    .black, // body text color
                                                              ),
                                                              textButtonTheme:
                                                                  TextButtonThemeData(
                                                                style: TextButton
                                                                    .styleFrom(
                                                                  foregroundColor:
                                                                      Colors
                                                                          .black, // button text color
                                                                ),
                                                              ),
                                                            ),
                                                            child: child);
                                                      }));
                                              setState(() {
                                                if (pickedDate != null) {
                                                  endDate = pickedDate.add(
                                                      Duration(
                                                          hours: 23,
                                                          minutes: 59));
                                                  filtered = true;
                                                }
                                              });
                                            },
                                            padding: EdgeInsets.all(0),
                                            tooltip:
                                                'Selecciona un fecha final',
                                            iconSize: 18,
                                            icon: Icon(Icons.calendar_month),
                                          ),
                                        )
                                      ],
                                    )),
                                SizedBox(width: 20),

                                //Medio de pago
                                Container(
                                  width: 250,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[350]),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: DropdownButton(
                                    isExpanded: true,
                                    underline: SizedBox(),
                                    hint: Text(
                                      'Método de pago',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          color: Colors.black),
                                    ),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        color: Colors.black),
                                    value: paymentType,
                                    items: paymentTypes.map((i) {
                                      return new DropdownMenuItem(
                                        value: i,
                                        child: new Text(i),
                                      );
                                    }).toList(),
                                    onChanged: (x) {
                                      setState(() {
                                        paymentType = x;
                                        filtered = true;
                                      });
                                    },
                                  ),
                                ),

                                Spacer(),
                                //Boton de filtrar
                                Container(
                                  height: 40,
                                  width: 40,
                                  child: Tooltip(
                                    message: 'Quitar filtros',
                                    child: OutlinedButton(
                                      style: ButtonStyle(
                                        padding: MaterialStateProperty.all<
                                                EdgeInsetsGeometry>(
                                            EdgeInsets.all(5)),
                                        alignment: Alignment.center,
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.white70),
                                        overlayColor: MaterialStateProperty
                                            .resolveWith<Color>(
                                          (Set<MaterialState> states) {
                                            if (states.contains(
                                                MaterialState.hovered))
                                              return Colors.grey.shade300;
                                            if (states.contains(
                                                    MaterialState.focused) ||
                                                states.contains(
                                                    MaterialState.pressed))
                                              return Colors.white;
                                            return null; // Defer to the widget's default.
                                          },
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          paymentType = 'Todos';
                                          initDate = DateTime(
                                                  DateTime.now().year,
                                                  DateTime.now().month,
                                                  DateTime.now().day,
                                                  0,
                                                  0,
                                                  0)
                                              .subtract(Duration(days: 1));
                                          endDate = DateTime(
                                              DateTime.now().year,
                                              DateTime.now().month,
                                              DateTime.now().day,
                                              23,
                                              59,
                                              59);
                                          filtered = false;
                                        });
                                      },
                                      child: Center(
                                          child: Icon(
                                        Icons.filter_alt_off_outlined,
                                        color: Colors.black,
                                        size: 18,
                                      )),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            height: 120,
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    //Fecha
                                    Container(
                                      width: 150,
                                      height: 45,
                                      decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Colors.grey[350]),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      padding: EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          Text(
                                            DateFormat('dd/MM/yyyy')
                                                .format(initDate),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 16),
                                          ),
                                          Spacer(),
                                          Container(
                                            height: 20,
                                            width: 20,
                                            child: IconButton(
                                              splashRadius: 1,
                                              onPressed: () async {
                                                DateTime pickedDate =
                                                    await showDatePicker(
                                                        context: context,
                                                        initialDate: initDate,
                                                        firstDate: DateTime
                                                                .now()
                                                            .subtract(Duration(
                                                                days: 730)),
                                                        lastDate:
                                                            DateTime.now(),
                                                        builder:
                                                            ((context, child) {
                                                          return Theme(
                                                              data: Theme.of(
                                                                      context)
                                                                  .copyWith(
                                                                colorScheme:
                                                                    ColorScheme
                                                                        .light(
                                                                  primary: Colors
                                                                      .black, // header background color
                                                                  onPrimary: Colors
                                                                      .white, // header text color
                                                                  onSurface: Colors
                                                                      .black, // body text color
                                                                ),
                                                                textButtonTheme:
                                                                    TextButtonThemeData(
                                                                  style: TextButton
                                                                      .styleFrom(
                                                                    foregroundColor:
                                                                        Colors
                                                                            .black, // button text color
                                                                  ),
                                                                ),
                                                              ),
                                                              child: child);
                                                        }));
                                                setState(() {
                                                  if (pickedDate != null) {
                                                    initDate = pickedDate;
                                                    endDate = DateTime(
                                                        pickedDate.year,
                                                        pickedDate.month + 1,
                                                        0);
                                                    filtered = true;
                                                  }
                                                });
                                              },
                                              padding: EdgeInsets.all(0),
                                              tooltip:
                                                  'Selecciona un fecha inicial',
                                              iconSize: 18,
                                              icon: Icon(Icons.calendar_month),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Container(
                                        width: 150,
                                        height: 45,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey[350]),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        padding: EdgeInsets.all(12),
                                        child: //(DateTime.now().difference(initDate).inDays > 1)
                                            // ?
                                            Row(
                                          children: [
                                            Text(
                                              (endDate == null)
                                                  ? 'Hasta fecha'
                                                  : DateFormat('dd/MM/yyyy')
                                                      .format(endDate),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 16),
                                            ),
                                            Spacer(),
                                            Container(
                                              height: 20,
                                              width: 20,
                                              child: IconButton(
                                                splashRadius: 1,
                                                onPressed: () async {
                                                  DateTime pickedDate =
                                                      await showDatePicker(
                                                          context: context,
                                                          initialDate: initDate
                                                              .add(Duration(
                                                                  days: 1)),
                                                          firstDate: initDate,
                                                          lastDate: DateTime(
                                                              initDate.year,
                                                              initDate.month +
                                                                  1,
                                                              0),
                                                          builder: ((context,
                                                              child) {
                                                            return Theme(
                                                                data: Theme.of(
                                                                        context)
                                                                    .copyWith(
                                                                  colorScheme:
                                                                      ColorScheme
                                                                          .light(
                                                                    primary: Colors
                                                                        .black, // header background color
                                                                    onPrimary:
                                                                        Colors
                                                                            .white, // header text color
                                                                    onSurface:
                                                                        Colors
                                                                            .black, // body text color
                                                                  ),
                                                                  textButtonTheme:
                                                                      TextButtonThemeData(
                                                                    style: TextButton
                                                                        .styleFrom(
                                                                      foregroundColor:
                                                                          Colors
                                                                              .black, // button text color
                                                                    ),
                                                                  ),
                                                                ),
                                                                child: child);
                                                          }));
                                                  setState(() {
                                                    if (pickedDate != null) {
                                                      endDate = pickedDate.add(
                                                          Duration(
                                                              hours: 23,
                                                              minutes: 59));
                                                      filtered = true;
                                                    }
                                                  });
                                                },
                                                padding: EdgeInsets.all(0),
                                                tooltip:
                                                    'Selecciona un fecha final',
                                                iconSize: 18,
                                                icon:
                                                    Icon(Icons.calendar_month),
                                              ),
                                            )
                                          ],
                                        )),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    //Medio de pago
                                    Container(
                                      width: 250,
                                      height: 45,
                                      decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Colors.grey[350]),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 12),
                                      child: DropdownButton(
                                        isExpanded: true,
                                        underline: SizedBox(),
                                        hint: Text(
                                          'Método de pago',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 16,
                                              color: Colors.black),
                                        ),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16,
                                            color: Colors.black),
                                        value: paymentType,
                                        items: paymentTypes.map((i) {
                                          return new DropdownMenuItem(
                                            value: i,
                                            child: new Text(i),
                                          );
                                        }).toList(),
                                        onChanged: (x) {
                                          setState(() {
                                            paymentType = x;
                                            filtered = true;
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    //Boton de filtrar
                                    Container(
                                      height: 40,
                                      width: 40,
                                      child: Tooltip(
                                        message: 'Quitar filtros',
                                        child: OutlinedButton(
                                          style: ButtonStyle(
                                            padding: MaterialStateProperty.all<
                                                    EdgeInsetsGeometry>(
                                                EdgeInsets.all(5)),
                                            alignment: Alignment.center,
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.white70),
                                            overlayColor: MaterialStateProperty
                                                .resolveWith<Color>(
                                              (Set<MaterialState> states) {
                                                if (states.contains(
                                                    MaterialState.hovered))
                                                  return Colors.grey.shade300;
                                                if (states.contains(
                                                        MaterialState
                                                            .focused) ||
                                                    states.contains(
                                                        MaterialState.pressed))
                                                  return Colors.white;
                                                return null; // Defer to the widget's default.
                                              },
                                            ),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              paymentType = 'Todos';
                                              initDate = DateTime(
                                                      DateTime.now().year,
                                                      DateTime.now().month,
                                                      DateTime.now().day,
                                                      0,
                                                      0,
                                                      0)
                                                  .subtract(Duration(days: 1));
                                              endDate = DateTime(
                                                  DateTime.now().year,
                                                  DateTime.now().month,
                                                  DateTime.now().day,
                                                  23,
                                                  59,
                                                  59);
                                              filtered = false;
                                            });
                                          },
                                          child: Center(
                                              child: Icon(
                                            Icons.filter_alt_off_outlined,
                                            color: Colors.black,
                                            size: 18,
                                          )),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                  ],
                ),
              ),
            ),
          ),
          //Titles
          SliverAppBar(
            backgroundColor: Colors.white,
            pinned: true,
            automaticallyImplyLeading: false,
            actions: <Widget>[Container()],
            flexibleSpace: SizedBox(
              width: double.infinity,
              height: 50,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //Fecha
                    Container(
                        width: 50,
                        child: Text(
                          'Fecha',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54),
                        )),
                    //Hora
                    Container(
                        width: 75,
                        child: Text(
                          'Hora',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54),
                        )),

                    //Nombre
                    Container(
                        width: 120,
                        child: Text(
                          'Cliente',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54),
                        )),

                    //Payment Type
                    Container(
                        width: 120,
                        child: Center(
                          child: Text(
                            'Medio de pago',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                    //Total
                    Container(
                        width: 70,
                        child: Center(
                          child: Text(
                            'Total',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                    //More Button
                    SizedBox(width: 45)
                  ],
                ),
              ),
            ),
          ),
          //Historical Details
          (filtered)
              ? StreamProvider<List<Sales>>.value(
                  initialData: null,
                  value: DatabaseService().filteredSalesList(
                      widget.currentBusiness, initDate, endDate, paymentType),
                  child: SalesDetailsView(
                      widget.currentBusiness, widget.registerStatus))
              : StreamProvider<List<Sales>>.value(
                  initialData: null,
                  value: DatabaseService().salesList(widget.currentBusiness),
                  child: SalesDetailsView(
                      widget.currentBusiness, widget.registerStatus))
        ],
      ));
    } else {
      return Scaffold(
          body: CustomScrollView(
        slivers: [
          //Go Back /// Title //Filters
          SliverAppBar(
            floating: true,
            backgroundColor: Colors.white,
            pinned: false,
            automaticallyImplyLeading: false,
            actions: <Widget>[Container()],
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                children: [
                  //Go Back /// Title
                  Container(
                    width: double.infinity,
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          //Back
                          IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(Icons.arrow_back)),
                          SizedBox(width: 15),
                          Text(
                            'Historial de ventas',
                            style: TextStyle(
                                fontSize: 21, fontWeight: FontWeight.bold),
                          ),
                        ]),
                  ),
                  //Filters
                  Container(
                      height: 60,
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          //Date
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: TextButton(
                              style: ButtonStyle(
                                overlayColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                    if (states
                                        .contains(MaterialState.hovered)) {
                                      return Colors.greenAccent.withOpacity(
                                          0.2); // Customize the hover color here
                                    }
                                    return null; // Use default overlay color for other states
                                  },
                                ),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.grey.shade300.withOpacity(0.2)),
                              ),
                              onPressed: () async {
                                DateTime pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: initDate,
                                    firstDate: DateTime.now()
                                        .subtract(Duration(days: 730)),
                                    lastDate: DateTime.now(),
                                    builder: ((context, child) {
                                      return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary: Colors
                                                  .black, // header background color
                                              onPrimary: Colors
                                                  .white, // header text color
                                              onSurface: Colors
                                                  .black, // body text color
                                            ),
                                            textButtonTheme:
                                                TextButtonThemeData(
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors
                                                    .black, // button text color
                                              ),
                                            ),
                                          ),
                                          child: child);
                                    }));
                                setState(() {
                                  if (pickedDate != null) {
                                    initDate = pickedDate;
                                    endDate = DateTime(pickedDate.year,
                                        pickedDate.month + 1, 0);
                                    filtered = true;
                                    dateFiltered = true;
                                  }
                                });
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    size: 16,
                                    color: Colors.black,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    dateFiltered
                                        ? DateFormat('dd/MM/yyyy')
                                            .format(initDate)
                                        : 'Desde',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //Date
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: TextButton(
                              style: ButtonStyle(
                                overlayColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                    if (states
                                        .contains(MaterialState.hovered)) {
                                      return Colors.greenAccent.withOpacity(
                                          0.2); // Customize the hover color here
                                    }
                                    return null; // Use default overlay color for other states
                                  },
                                ),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.grey.shade300.withOpacity(0.2)),
                              ),
                              onPressed: () async {
                                DateTime pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate:
                                        initDate.add(Duration(days: 1)),
                                    firstDate: initDate,
                                    lastDate: DateTime(
                                        initDate.year, initDate.month + 1, 0),
                                    builder: ((context, child) {
                                      return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary: Colors
                                                  .black, // header background color
                                              onPrimary: Colors
                                                  .white, // header text color
                                              onSurface: Colors
                                                  .black, // body text color
                                            ),
                                            textButtonTheme:
                                                TextButtonThemeData(
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors
                                                    .black, // button text color
                                              ),
                                            ),
                                          ),
                                          child: child);
                                    }));
                                setState(() {
                                  if (pickedDate != null) {
                                    endDate = pickedDate
                                        .add(Duration(hours: 23, minutes: 59));
                                    filtered = true;
                                    dateFiltered = true;
                                  }
                                });
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    size: 16,
                                    color: Colors.black,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    dateFiltered
                                        ? DateFormat('dd/MM/yyyy')
                                            .format(endDate)
                                        : 'Hasta',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //Payment Method
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: TextButton(
                              style: ButtonStyle(
                                overlayColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                    if (states
                                        .contains(MaterialState.hovered)) {
                                      return Colors.greenAccent.withOpacity(
                                          0.2); // Customize the hover color here
                                    }
                                    return null; // Use default overlay color for other states
                                  },
                                ),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.grey.shade300.withOpacity(0.2)),
                              ),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0)),
                                        child: Container(
                                            width: 400,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.8,
                                            padding: EdgeInsets.all(20),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  //Cancel Icon
                                                  Container(
                                                    alignment:
                                                        Alignment(1.0, 0.0),
                                                    child: IconButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        icon: Icon(Icons.close),
                                                        iconSize: 20.0),
                                                  ),
                                                  SizedBox(height: 10),
                                                  //Title
                                                  Container(
                                                    width: double.infinity,
                                                    child: Text(
                                                      'Métodos de pago',
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      softWrap: true,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  ),
                                                  SizedBox(height: 20),
                                                  //Payment Methods
                                                  ListView.builder(
                                                      itemCount:
                                                          paymentTypes.length,
                                                      shrinkWrap: true,
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      itemBuilder:
                                                          (context, i) {
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  bottom: 10.0),
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .black12,
                                                                    width: 1),
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            12))),
                                                            child: InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  paymentType =
                                                                      paymentTypes[
                                                                          i];
                                                                  filtered =
                                                                      true;
                                                                  paymentFiltered =
                                                                      true;
                                                                });
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        12.0),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    //Name
                                                                    Text(
                                                                      paymentTypes[
                                                                          i],
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.normal),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                ],
                                              ),
                                            )),
                                      );
                                    });
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet_outlined,
                                    size: 16,
                                    color: Colors.black,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    paymentFiltered
                                        ? paymentType
                                        : 'Medio de Pago',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //Remove
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: TextButton(
                              style: ButtonStyle(
                                overlayColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                    if (states
                                        .contains(MaterialState.hovered)) {
                                      return Colors.greenAccent.withOpacity(
                                          0.2); // Customize the hover color here
                                    }
                                    return null; // Use default overlay color for other states
                                  },
                                ),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.grey.shade300.withOpacity(0.2)),
                              ),
                              onPressed: () {
                                setState(() {
                                  paymentType = 'Todos';
                                  initDate = DateTime(
                                          DateTime.now().year,
                                          DateTime.now().month,
                                          DateTime.now().day,
                                          0,
                                          0,
                                          0)
                                      .subtract(Duration(days: 1));
                                  endDate = DateTime(
                                      DateTime.now().year,
                                      DateTime.now().month,
                                      DateTime.now().day,
                                      23,
                                      59,
                                      59);
                                  filtered = false;
                                  dateFiltered = false;
                                  paymentFiltered = false;
                                });
                              },
                              child: Icon(
                                Icons.filter_alt_off_outlined,
                                size: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ),
          //Historical Details
          (filtered)
              ? StreamProvider<List<Sales>>.value(
                  initialData: null,
                  value: DatabaseService().filteredSalesList(
                      widget.currentBusiness, initDate, endDate, paymentType),
                  child: SalesDetailsView(
                      widget.currentBusiness, widget.registerStatus))
              : StreamProvider<List<Sales>>.value(
                  initialData: null,
                  value: DatabaseService().salesList(widget.currentBusiness),
                  child: SalesDetailsView(
                      widget.currentBusiness, widget.registerStatus))
        ],
      ));
    }
  }
}
