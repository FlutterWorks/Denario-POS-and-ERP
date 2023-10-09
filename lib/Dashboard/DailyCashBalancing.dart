import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Dashboard/CloseCashRegisterDialog.dart';
import 'package:denario/Dashboard/DailyHistory.dart';
import 'package:denario/Dashboard/DailyTransactionsList.dart';
import 'package:denario/Dashboard/OpenCashRegisterDialog.dart';
import 'package:denario/Dashboard/UpdateCashRegisterDialog.dart';
import 'package:denario/Models/DailyCash.dart';
import 'package:denario/Models/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DailyCashBalancing extends StatefulWidget {
  @override
  _DailyCashBalancingState createState() => _DailyCashBalancingState();
}

class _DailyCashBalancingState extends State<DailyCashBalancing> {
  final formatCurrency = new NumberFormat.simpleCurrency();
  double expectedInRegister = 0;
  Widget closedRegister() {
    return Container(
      height: 40,
      width: 300,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          // backgroundColor: Colors.green,
          // minimumSize: Size(300, 50),
          padding: EdgeInsets.symmetric(horizontal: 15),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return OpenCashRegisterDialog();
              });
        },
        child: Center(
            child: Text('Abrir caja',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w400))),
      ),
    );
  }

  List<DailyTransactions> dailyTransactionsList = [];

  @override
  Widget build(BuildContext context) {
    final registerStatus = Provider.of<CashRegister>(context);
    final dailyTransactions = Provider.of<DailyTransactions>(context);

    final User user = FirebaseAuth.instance.currentUser;
    final String uid = user.uid.toString();

    if (registerStatus == null) {
      //Si no encuentra el status
      return Container();
    } else if (dailyTransactions == null) {
      //Si no hay caja abierta
      return Container(
          padding: EdgeInsets.fromLTRB(30, 30, 30, 15),
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Title
              Container(
                width: double.infinity,
                child: Text(
                  'Arqueo de caja',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  textAlign: TextAlign.start,
                ),
              ),
              SizedBox(height: 5),
              Container(
                width: 50,
                child: Divider(
                  thickness: 1,
                  endIndent: 10,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 10),
              //Open
              Container(
                height: 40,
                width: 300,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    // minimumSize: Size(300, 50),
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return StreamProvider<UserData>.value(
                              value: DatabaseService().userProfile(uid),
                              initialData: null,
                              child: OpenCashRegisterDialog());
                        });
                  },
                  child: Center(
                      child: Text('Abrir caja',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400))),
                ),
              )
            ],
          ));
    } else if (registerStatus.registerisOpen) {
      //Si esta abierta
      if (dailyTransactions.salesByMedium.toString().contains('Efectivo')) {
        //.containsKey('Efectivo')) {
        expectedInRegister = dailyTransactions.initialAmount +
            dailyTransactions.salesByMedium['Efectivo'] +
            dailyTransactions.inflows -
            dailyTransactions.outflows;
      } else {
        expectedInRegister = dailyTransactions.initialAmount +
            dailyTransactions.inflows -
            dailyTransactions.outflows;
      }

      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Open/Close Register
          Container(
              padding: EdgeInsets.fromLTRB(30, 30, 30, 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Title
                  Container(
                    width: double.infinity,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          //Title
                          Text(
                            'Arqueo de caja',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            textAlign: TextAlign.start,
                          ),
                          Spacer(),
                          //List of Transactions
                          IconButton(
                              tooltip: 'Movimientos de caja',
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DailyTransactionsList(
                                              dailyTransactions
                                                  .registerTransactionList))),
                              icon: Icon(
                                Icons.list,
                                color: Colors.black,
                                size: 24,
                              )),
                          SizedBox(width: 5),
                          //Historic Cash Balancing
                          IconButton(
                              tooltip: 'Historial de arqueos',
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DailyHistory())),
                              icon: Icon(
                                Icons.history,
                                color: Colors.black,
                                size: 24,
                              ))
                        ]),
                  ),
                  SizedBox(height: 5),
                  Container(
                    width: 50,
                    child: Divider(
                      thickness: 1,
                      endIndent: 10,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 10),
                  //Open / Current
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Open//Close
                      Container(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            //Openned
                            Text(
                              '• Caja abierta',
                              style:
                                  TextStyle(color: Colors.green, fontSize: 12),
                            ),
                            Spacer(),
                            //Close Button
                            Container(
                              padding: EdgeInsets.all(5),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[50],
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                  ),
                                ),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return StreamProvider<UserData>.value(
                                          value: DatabaseService()
                                              .userProfile(uid),
                                          initialData: null,
                                          child: CloseCashRegisterDialog(
                                              currentRegister:
                                                  registerStatus.registerName),
                                        );
                                      });
                                },
                                child: Center(
                                    child: Text('Hacer cierre',
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.w300,
                                            fontSize: 11))),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      //Date
                      Container(
                          child: Row(
                        children: [
                          Text(
                            'Apertura:',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Spacer(),
                          Text(
                            (DateFormat.MMMd()
                                    .format(dailyTransactions.openDate)
                                    .toString() +
                                ', ' +
                                DateFormat('HH:mm:ss')
                                    .format(dailyTransactions.openDate)
                                    .toString()),
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      )),
                      SizedBox(height: 20),
                      //uSER
                      Container(
                          child: Row(
                        children: [
                          Text(
                            'Usuario',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Spacer(),
                          Text(
                            '${dailyTransactions.user}',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      )),
                      SizedBox(height: 20),
                      //Monto apertura
                      Row(
                        children: [
                          Text(
                            'Monto de Apertura:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Spacer(),
                          Text(
                            '${formatCurrency.format(dailyTransactions.initialAmount)}',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      //Sales
                      Row(
                        children: [
                          Text(
                            'Ventas en efectivo',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Spacer(),
                          Text(
                            (dailyTransactions.salesByMedium['Efectivo'] !=
                                    null)
                                ? '${formatCurrency.format(dailyTransactions.salesByMedium['Efectivo'])}'
                                : '${formatCurrency.format(0)}',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      //inflows
                      Row(
                        children: [
                          Text(
                            'Ingresos a Caja',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Spacer(),
                          Text(
                            '${formatCurrency.format(dailyTransactions.inflows)}',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      //outflows
                      Row(
                        children: [
                          Text(
                            'Egresos de Caja',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Spacer(),
                          Text(
                            '${formatCurrency.format(dailyTransactions.outflows)}',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      //Divider
                      Container(
                        width: double.infinity,
                        child: Divider(
                          thickness: 1,
                          endIndent: 10,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 15),
                      //Expected in Register
                      Row(
                        children: [
                          Text(
                            'Esperado en Caja',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Spacer(),
                          Text(
                            formatCurrency.format(expectedInRegister),
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      //Buttons to add transactions
                      SizedBox(height: 30),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          //Inngreso
                          Container(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                ),
                              ),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return StreamProvider<UserData>.value(
                                        value:
                                            DatabaseService().userProfile(uid),
                                        initialData: null,
                                        child: UpdateCashRegisterDialog(
                                          currentRegister:
                                              registerStatus.registerName,
                                          transactionType: 'Ingresos',
                                          transactionAmount:
                                              dailyTransactions.inflows,
                                          currentTransactions: dailyTransactions
                                              .dailyTransactions,
                                        ),
                                      );
                                    });
                              },
                              child: Center(
                                  child: Text('Ingreso',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w300,
                                          fontSize: 12))),
                            ),
                          ),
                          SizedBox(width: 15),
                          //Egreso
                          Container(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                ),
                              ),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return StreamProvider<UserData>.value(
                                        value:
                                            DatabaseService().userProfile(uid),
                                        initialData: null,
                                        child: UpdateCashRegisterDialog(
                                          currentRegister:
                                              registerStatus.registerName,
                                          transactionType: 'Egresos',
                                          transactionAmount:
                                              dailyTransactions.outflows,
                                          currentTransactions: dailyTransactions
                                              .dailyTransactions,
                                        ),
                                      );
                                    });
                              },
                              child: Center(
                                  child: Text('Egreso',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w300,
                                          fontSize: 12))),
                            ),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              )),
        ],
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Open/Close Register
        Container(
            height: 200,
            padding: EdgeInsets.fromLTRB(30, 30, 30, 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Title
                Container(
                  width: double.infinity,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        //Title
                        Text(
                          'Arqueo de caja',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          textAlign: TextAlign.start,
                        ),
                        Spacer(),
                        //Historic Cash Balancing
                        IconButton(
                            tooltip: 'Historial de arqueos',
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DailyHistory())),
                            icon: Icon(
                              Icons.history,
                              color: Colors.black,
                              size: 24,
                            ))
                      ]),
                ),
                SizedBox(height: 5),
                Container(
                  width: 50,
                  child: Divider(
                    thickness: 1,
                    endIndent: 10,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 5),
                //Open / Current
                Container(
                  height: 40,
                  width: 300,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      // minimumSize: Size(300, 50),
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return StreamProvider<UserData>.value(
                                value: DatabaseService().userProfile(uid),
                                initialData: null,
                                child: OpenCashRegisterDialog());
                          });
                    },
                    child: Center(
                        child: Text('Abrir caja',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400))),
                  ),
                )
              ],
            )),
      ],
    );
  }
}
