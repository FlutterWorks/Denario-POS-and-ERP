import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Expenses/SingleExpenseDialog.dart';
import 'package:denario/Models/DailyCash.dart';
import 'package:denario/Models/Expenses.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ExpenseList extends StatelessWidget {
  final String businessID;
  ExpenseList(this.businessID);
  @override
  Widget build(BuildContext context) {
    final formatCurrency = new NumberFormat.simpleCurrency();
    final expenses = Provider.of<List<Expenses>>(context);
    final registerStatus = Provider.of<CashRegister>(context);

    if (registerStatus == null || expenses == null) {
      return Container();
    }

    if (expenses.length == 0) {
      return Container(
        width: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //Icon
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    color: Colors.white,
                    image: DecorationImage(
                      image: AssetImage('images/EmptyState.png'),
                      fit: BoxFit.cover,
                    )),
              ),
              SizedBox(height: 15),
              //Text
              Text(
                'Nada para mostrar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              )
            ],
          ),
        ),
      );
    }

    List<Expenses> expenseList = expenses;

    return Container(
      width: double.infinity,
      child: ListView.builder(
          itemCount: expenseList.length, //(expenseList.length > 7) ? 7 :
          shrinkWrap: true,
          reverse: false,
          physics: BouncingScrollPhysics(),
          itemBuilder: (context, i) {
            String description;

            if (expenseList[i].items.isEmpty) {
              description = 'Sin descripción';
            } else if (expenseList[i].items.length > 1) {
              if (expenseList[i].items.length > 2) {
                description =
                    '${expenseList[i].items[0].product}, ${expenseList[i].items[1].product}...';
              } else {
                description =
                    '${expenseList[i].items[0].product}, ${expenseList[i].items[1].product}';
              }
            } else {
              description = expenseList[i].items.first.product;
            }
            if (MediaQuery.of(context).size.width > 650) {
              return TextButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return StreamProvider<DailyTransactions>.value(
                            initialData: null,
                            value: DatabaseService().dailyTransactions(
                                businessID, registerStatus.registerName),
                            child: SingleExpenseDialog(
                                expenseList[i], businessID, registerStatus));
                      });
                },
                child: Container(
                  height: 60,
                  width: double.infinity,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      //Fecha
                      Container(
                          width: 50,
                          child: Text(
                            DateFormat.MMMd()
                                .format(expenseList[i].date)
                                .toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          )),
                      SizedBox(width: 10),
                      //Detail
                      Container(
                        width: 150,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              //Desc
                              Container(
                                  child: Text(
                                description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black),
                              )),
                              SizedBox(height: 5),
                              //Vendor + Cat
                              Container(
                                  child: Text(
                                '${expenseList[i].vendor}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 11,
                                ),
                              )),
                            ]),
                      ),
                      SizedBox(width: 10),
                      //Cost Type
                      Container(
                          width: (MediaQuery.of(context).size.width > 1200)
                              ? 150
                              : 100,
                          child: Center(
                            child: Text(
                              '${expenseList[i].costType}',
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                          )),
                      SizedBox(width: 10),
                      //Total
                      Container(
                          width: 70,
                          child: Center(
                            child: Text(
                                '${formatCurrency.format(expenseList[i].total)}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                          )),
                    ],
                  ),
                ),
              );
            } else {
              return TextButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return StreamProvider<DailyTransactions>.value(
                            initialData: null,
                            value: DatabaseService().dailyTransactions(
                                businessID, registerStatus.registerName),
                            child: SingleExpenseDialog(
                                expenseList[i], businessID, registerStatus));
                      });
                },
                child: Container(
                  height: 60,
                  width: double.infinity,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      //Fecha
                      Expanded(
                        flex: 2,
                        child: Container(
                            child: Text(
                          DateFormat.MMMd()
                              .format(expenseList[i].date)
                              .toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        )),
                      ),
                      //Detail
                      Expanded(
                        flex: 4,
                        child: Container(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                //Desc
                                Container(
                                    child: Text(
                                  description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black),
                                )),
                                SizedBox(height: 5),
                                //Vendor + Cat
                                Container(
                                    child: Text(
                                  '${expenseList[i].vendor}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 11,
                                  ),
                                )),
                              ]),
                        ),
                      ),
                      //Total
                      Expanded(
                        flex: 2,
                        child: Container(
                            child: Center(
                          child: Text(
                              '${formatCurrency.format(expenseList[i].total)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                        )),
                      ),
                    ],
                  ),
                ),
              );
            }
          }),
    );
  }
}
