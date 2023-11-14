import 'package:denario/Dashboard/DailyTransactionsList.dart';
import 'package:denario/Models/DailyCash.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RegisterTransactionsCard extends StatelessWidget {
  final Registradora register;
  final DailyTransactions dailyTransactions;
  final String activeBusiness;
  RegisterTransactionsCard(
      this.register, this.dailyTransactions, this.activeBusiness,
      {Key? key})
      : super(key: key);

  final formatCurrency = new NumberFormat.simpleCurrency();

  @override
  Widget build(BuildContext context) {
    final List registerTransactions =
        dailyTransactions.registerTransactionList!.reversed.toList();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: new BorderRadius.circular(12.0),
        boxShadow: <BoxShadow>[
          new BoxShadow(
            color: Colors.grey[350]!,
            offset: Offset(0.0, 0.0),
            blurRadius: 10.0,
          )
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Title
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Movimientos de caja',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Spacer(),
              //List of Transactions
              IconButton(
                  tooltip: 'Movimientos de caja',
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DailyTransactionsList(
                              dailyTransactions.registerTransactionList!))),
                  icon: Icon(
                    Icons.list,
                    color: Colors.black,
                    size: 24,
                  )),
            ],
          ),
          SizedBox(height: 15),
          //List of transactions
          Expanded(
            child: (Container(
                child: ListView.builder(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: (registerTransactions.length < 5)
                  ? registerTransactions.length
                  : 5,
              itemBuilder: (context, i) {
                return Container(
                  height: 40,
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  color: Colors.white,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      //Time
                      Container(
                          width: 75,
                          child: Text(
                            DateFormat('HH:mm')
                                .format(
                                    (registerTransactions[i]['Time']).toDate())
                                .toString(),
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w400,
                            ),
                          )),
                      SizedBox(width: 20),
                      //Motive
                      Container(
                          width: 120,
                          child: Text(
                            registerTransactions[i]['Motive'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                            ),
                          )),
                      Spacer(),
                      //Amount
                      Container(
                          width: 70,
                          child: Center(
                            child: Text(
                              (registerTransactions[i]['Type'] == 'Egresos')
                                  ? '-${formatCurrency.format(registerTransactions[i]['Amount'])}'
                                  : '${formatCurrency.format(registerTransactions[i]['Amount'])}',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: (registerTransactions[i]['Type'] ==
                                          'Egresos')
                                      ? Colors.red
                                      : Colors.black),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                    ],
                  ),
                );
              },
            ))),
          )
        ],
      ),
    );
  }
}
