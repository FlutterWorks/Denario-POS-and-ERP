import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Expenses/FilteredExpenseList.dart';
import 'package:denario/Models/DailyCash.dart';
import 'package:denario/Models/Expenses.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ExpensesHistory extends StatefulWidget {
  final String activeBusiness;
  ExpensesHistory(this.activeBusiness);
  @override
  _ExpensesHistoryState createState() => _ExpensesHistoryState();
}

class _ExpensesHistoryState extends State<ExpensesHistory> {
  DateTime initDate;
  DateTime endDate;
  String paymentType;
  bool filtered;
  List paymentTypes = [];
  TextEditingController supplierController =
      new TextEditingController(text: '');
  String supplier;
  String account;
  List accountsList = [];
  bool filteredAccount;

  @override
  void initState() {
    initDate = DateTime(DateTime.now().year, DateTime.now().month, 1, 0, 0, 0);
    endDate = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, 23, 59, 59);
    filtered = false;
    paymentTypes = ['Todos', 'Efectivo', 'MercadoPago', 'Tarjeta', 'Por pagar'];
    accountsList = [
      'Todas',
      'Costo de Ventas',
      'Gastos de Empleados',
      'Gastos del Local',
      'Otros Gastos'
    ];
    filteredAccount = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final registerStatus = Provider.of<CashRegister>(context);

    if (registerStatus == null) {
      return Container();
    }

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
              (MediaQuery.of(context).size.width > 1175) ? 150 : 200,
          flexibleSpace: FlexibleSpaceBar(
            background: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  //Go Back /// Title
                  Container(
                    width: double.infinity,
                    height: 75,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          //Back
                          IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(Icons.arrow_back)),
                          SizedBox(width: 25),
                          Text(
                            'Historial de ventas',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ]),
                  ),
                  //Filters
                  (MediaQuery.of(context).size.width > 1175)
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
                                      DateFormat('dd/MM/yyyy').format(initDate),
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
                                                      .subtract(
                                                          Duration(days: 730)),
                                                  lastDate: DateTime.now(),
                                                  builder: ((context, child) {
                                                    return Theme(
                                                        data: Theme.of(context)
                                                            .copyWith(
                                                          colorScheme:
                                                              ColorScheme.light(
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
                                            if (pickedDate != null &&
                                                pickedDate.month ==
                                                    DateTime.now().month) {
                                              initDate = pickedDate;
                                              filtered = true;
                                            } else if (pickedDate != null &&
                                                pickedDate.month !=
                                                    DateTime.now().month) {
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
                                        tooltip: 'Selecciona un fecha inicial',
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
                                    border: Border.all(color: Colors.grey[350]),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  padding: EdgeInsets.all(12),
                                  child: Row(
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
                                                    initialDate: (initDate
                                                                .month ==
                                                            DateTime.now()
                                                                .month)
                                                        ? DateTime.now()
                                                        : DateTime(
                                                            initDate.year,
                                                            initDate.month + 1,
                                                            0),
                                                    firstDate: initDate,
                                                    lastDate: DateTime(
                                                        initDate.year,
                                                        initDate.month + 1,
                                                        0),
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
                                                endDate = pickedDate.add(
                                                    Duration(
                                                        hours: 23,
                                                        minutes: 59));
                                                filtered = true;
                                              }
                                            });
                                          },
                                          padding: EdgeInsets.all(0),
                                          tooltip: 'Selecciona un fecha final',
                                          iconSize: 18,
                                          icon: Icon(Icons.calendar_month),
                                        ),
                                      )
                                    ],
                                  )),
                              SizedBox(width: 20),
                              //Proveedor
                              Container(
                                width: 200,
                                height: 45,
                                child: TextFormField(
                                  controller: supplierController,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 14),
                                  cursorColor: Colors.grey,
                                  decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(2),
                                      iconSize: 14,
                                      splashRadius: 15,
                                      onPressed: () {
                                        setState(() {
                                          supplierController.text = '';
                                          supplier = null;
                                        });
                                      },
                                      icon: Icon(Icons.close),
                                      color: Colors.black,
                                    ),
                                    hintText: 'Proveedor',
                                    hintStyle: TextStyle(
                                        color: Colors.black45, fontSize: 14),
                                    border: new OutlineInputBorder(
                                      borderRadius:
                                          new BorderRadius.circular(12.0),
                                      borderSide: new BorderSide(
                                        color: Colors.grey[350],
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          new BorderRadius.circular(12.0),
                                      borderSide: new BorderSide(
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      supplier = val;
                                      filtered = true;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 20),
                              //Medio de pago
                              Container(
                                width: 200,
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
                              SizedBox(width: 20),
                              //Account type
                              Container(
                                width: 200,
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
                                    'Tipo de gasto',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        color: Colors.black),
                                  ),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: Colors.black),
                                  value: account,
                                  items: accountsList.map((i) {
                                    return new DropdownMenuItem(
                                      value: i,
                                      child: new Text(i),
                                    );
                                  }).toList(),
                                  onChanged: (x) {
                                    if (x == 'Todas') {
                                      setState(() {
                                        account = x;
                                        filteredAccount = false;
                                      });
                                    } else {
                                      setState(() {
                                        account = x;
                                        filteredAccount = true;
                                      });
                                    }
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
                                          if (states
                                              .contains(MaterialState.hovered))
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
                                        account = 'Todas';
                                        filteredAccount = false;
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
                                        supplierController.text = '';
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
                              horizontal: 20, vertical: 10),
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                                if (pickedDate != null &&
                                                    pickedDate.month ==
                                                        DateTime.now().month) {
                                                  initDate = pickedDate;
                                                  filtered = true;
                                                } else if (pickedDate != null &&
                                                    pickedDate.month !=
                                                        DateTime.now().month) {
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
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      padding: EdgeInsets.all(12),
                                      child: Row(
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
                                                        initialDate: (initDate
                                                                    .month ==
                                                                DateTime.now()
                                                                    .month)
                                                            ? DateTime.now()
                                                            : DateTime(
                                                                initDate.year,
                                                                initDate.month +
                                                                    1,
                                                                0),
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
                                  //Proveedor
                                  Container(
                                    width: 200,
                                    height: 45,
                                    child: TextFormField(
                                      controller: supplierController,
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 14),
                                      cursorColor: Colors.grey,
                                      decoration: InputDecoration(
                                        suffixIcon: IconButton(
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.all(2),
                                          iconSize: 14,
                                          splashRadius: 15,
                                          onPressed: () {
                                            setState(() {
                                              supplierController.text = '';
                                              supplier = null;
                                            });
                                          },
                                          icon: Icon(Icons.close),
                                          color: Colors.black,
                                        ),
                                        hintText: 'Proveedor',
                                        hintStyle: TextStyle(
                                            color: Colors.black45,
                                            fontSize: 14),
                                        border: new OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(12.0),
                                          borderSide: new BorderSide(
                                            color: Colors.grey[350],
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(12.0),
                                          borderSide: new BorderSide(
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          supplier = val;
                                          filtered = true;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  //Medio de pago
                                  Container(
                                    width: 200,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Colors.grey[350]),
                                      borderRadius: BorderRadius.circular(12.0),
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
                                  //Account type
                                  Container(
                                    width: 200,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Colors.grey[350]),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    child: DropdownButton(
                                      isExpanded: true,
                                      underline: SizedBox(),
                                      hint: Text(
                                        'Tipo de gasto',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16,
                                            color: Colors.black),
                                      ),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          color: Colors.black),
                                      value: account,
                                      items: accountsList.map((i) {
                                        return new DropdownMenuItem(
                                          value: i,
                                          child: new Text(i),
                                        );
                                      }).toList(),
                                      onChanged: (x) {
                                        if (x == 'Todas') {
                                          setState(() {
                                            account = x;
                                            filteredAccount = false;
                                          });
                                        } else {
                                          setState(() {
                                            account = x;
                                            filteredAccount = true;
                                          });
                                        }
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
                                            account = 'Todas';
                                            filteredAccount = false;
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
                                            supplierController.text = '';
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //Fecha
                Container(
                    width: 100,
                    child: Text(
                      'Fecha',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black54),
                    )),
                //CostType
                Container(
                    width: 150,
                    child: Text(
                      'Tipo de costo',
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black54),
                    )),
                //Vendor
                Container(
                    width: 120,
                    child: Text(
                      'Proveedor',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
                //Product
                Container(
                    width: 120,
                    child: Text(
                      'Producto',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
                //Payment Type
                Container(
                    width: 120,
                    child: Center(
                      child: Text(
                        'Medio de pago',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black54),
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
                            fontWeight: FontWeight.bold, color: Colors.black54),
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                      ),
                    )),
                //More Button
                SizedBox(width: 45)
              ],
            ),
          ),
        ),
        //Historical Details
        (filtered)
            ? StreamProvider<List<Expenses>>.value(
                value: DatabaseService().filteredExpenseList(
                    widget.activeBusiness,
                    endDate.month.toString(),
                    endDate.year.toString(),
                    initDate,
                    endDate,
                    paymentType,
                    (supplier != null && supplier != '')
                        ? supplier.toLowerCase()
                        : null),
                initialData: null,
                child: FilteredExpenseList(widget.activeBusiness,
                    registerStatus, filteredAccount, account))
            : StreamProvider<List<Expenses>>.value(
                value: DatabaseService().expenseList(widget.activeBusiness,
                    endDate.month.toString(), endDate.year.toString()),
                initialData: null,
                child: FilteredExpenseList(widget.activeBusiness,
                    registerStatus, filteredAccount, account),
              ),
      ],
    ));
  }
}
