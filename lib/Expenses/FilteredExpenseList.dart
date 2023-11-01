import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Expenses/SingleExpenseDialog.dart';
import 'package:denario/Models/DailyCash.dart';
import 'package:denario/Models/Expenses.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FilteredExpenseList extends StatelessWidget {
  final String businessID;
  final CashRegister registerStatus;
  final bool filteredAccount;
  final String accountFiltered;
  FilteredExpenseList(this.businessID, this.registerStatus,
      this.filteredAccount, this.accountFiltered);

  final formatCurrency = new NumberFormat.simpleCurrency();

  @override
  Widget build(BuildContext context) {
    final expensesListfromSnap = Provider.of<List<Expenses>>(context);

    if (expensesListfromSnap == []) {
      return SliverList(
          delegate: SliverChildBuilderDelegate((context, i) {
        return const SizedBox();
      }, childCount: 1));
    }

    List<Expenses> expensesList = expensesListfromSnap.reversed.toList();

    if (filteredAccount) {
      expensesList =
          expensesList.where((x) => x.costType == accountFiltered).toList();
    }

    return SliverList(
        delegate: SliverChildBuilderDelegate((context, i) {
      //Identify accounts in the expense
      var account = '';

      if (expensesList[i].items!.length == 1) {
        account = expensesList[i].items![0].category!;
      } else {
        account = expensesList[i].items![0].category!;
        for (var x = 0; x < expensesList[i].items!.length; x++) {
          if (expensesList[i].items![x].category !=
              expensesList[i].items![0].category) {
            account = 'Varios';
          }
        }
      }

      if (MediaQuery.of(context).size.width > 800) {
        return TextButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return StreamProvider<DailyTransactions?>.value(
                      initialData: null,
                      value: DatabaseService().dailyTransactions(
                          businessID, registerStatus.registerName!),
                      child: SingleExpenseDialog(
                          expensesList[i], businessID, registerStatus));
                });
          },
          child: Container(
            color: i.isOdd ? Colors.grey[100] : Colors.white,
            width: double.infinity,
            padding: EdgeInsets.all(5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //Fecha
                Container(
                    width: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat.MMMd()
                              .format(expensesList[i].date!)
                              .toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 5),
                        Text(
                          DateFormat('HH:mm')
                              .format(expensesList[i].date!)
                              .toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.grey,
                              fontSize: 11),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )),
                //CostType
                Container(
                    width: 150,
                    child: Column(
                      children: [
                        Text(
                          '${expensesList[i].costType}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 3),
                        Text(
                          '$account',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )),
                //Vendor
                (MediaQuery.of(context).size.width > 850)
                    ? Container(
                        width: 120,
                        child: Text(
                          '${expensesList[i].vendor}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black),
                        ))
                    : Container(
                        width: 120,
                        child: Column(
                          children: [
                            Text(
                              '${expensesList[i].vendor}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              (expensesList[i].items!.isEmpty)
                                  ? 'Sin descripción'
                                  : (expensesList[i].items!.length > 1)
                                      ? 'Varios'
                                      : (expensesList[i].items![0].product ==
                                              '')
                                          ? 'Sin descripción'
                                          : '${expensesList[i].items![0].product}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                //Product
                (MediaQuery.of(context).size.width > 850)
                    ? Container(
                        width: 120,
                        child: Text(
                          (expensesList[i].items!.isEmpty)
                              ? 'Sin descripción'
                              : (expensesList[i].items!.length > 1)
                                  ? 'Varios'
                                  : (expensesList[i].items![0].product == '')
                                      ? 'Sin descripción'
                                      : '${expensesList[i].items![0].product}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black),
                        ))
                    : SizedBox(),
                //Payment Type
                Container(
                    width: 120,
                    child: Center(
                      child: Text(
                        '${expensesList[i].paymentType}',
                        style: TextStyle(color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    )),
                //Total
                Container(
                    width: 100,
                    child: Center(
                      child: Text(
                        '${formatCurrency.format(expensesList[i].total)}',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    )),
              ],
            ),
          ),
        );
      } else {
        return TextButton(
          style: TextButton.styleFrom(backgroundColor: Colors.white),
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return StreamProvider<DailyTransactions?>.value(
                      initialData: null,
                      value: DatabaseService().dailyTransactions(
                          businessID, registerStatus.registerName!),
                      child: SingleExpenseDialog(
                          expensesList[i], businessID, registerStatus));
                });
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(5),
            height: 50,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //Fecha
                Expanded(
                  flex: 2,
                  child: Container(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat.MMMd()
                            .format(expensesList[i].date!)
                            .toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5),
                      Text(
                        DateFormat('HH:mm')
                            .format(expensesList[i].date!)
                            .toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.grey,
                            fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )),
                ),
                //CostType
                Expanded(
                  flex: 4,
                  child: Container(
                      child: Column(
                    children: [
                      Text(
                        '${expensesList[i].costType}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 3),
                      Text(
                        '$account',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )),
                ),
                //Vendor
                Expanded(
                  flex: 3,
                  child: Container(
                    child: Column(
                      children: [
                        Text(
                          '${expensesList[i].vendor}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          (expensesList[i].items!.isEmpty)
                              ? 'Sin descripción'
                              : (expensesList[i].items!.length > 1)
                                  ? 'Varios'
                                  : (expensesList[i].items![0].product == '')
                                      ? 'Sin descripción'
                                      : '${expensesList[i].items![0].product}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                //Total
                Expanded(
                  flex: 3,
                  child: Container(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${formatCurrency.format(expensesList[i].total)}',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5),
                      Text(
                        '${expensesList[i].paymentType}',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )),
                ),
              ],
            ),
          ),
        );
      }
    }, childCount: expensesList.length));
  }
}
