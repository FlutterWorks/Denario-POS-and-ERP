import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Dashboard/SingleSaleDialog.dart';
import 'package:denario/Models/DailyCash.dart';
import 'package:denario/Models/Sales.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SalesDetailsView extends StatelessWidget {
  final String businessID;
  final CashRegister registerStatus;
  SalesDetailsView(this.businessID, this.registerStatus);
  final formatCurrency = new NumberFormat.simpleCurrency();

  @override
  Widget build(BuildContext context) {
    final salesListfromSnap = Provider.of<List<Sales>>(context);

    if (registerStatus == CashRegister()) {
      return SliverList(
          delegate: SliverChildBuilderDelegate((context, i) {
        return const SizedBox();
      }, childCount: 1));
    }

    final List<Sales> salesList = salesListfromSnap.reversed.toList();

    return SliverList(
        delegate: SliverChildBuilderDelegate((context, i) {
      if (MediaQuery.of(context).size.width > 650) {
        return Container(
          height: 50,
          color: i.isOdd ? Colors.grey[100] : Colors.white,
          width: double.infinity,
          padding: EdgeInsets.all(5),
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
                      DateFormat.MMMd().format(salesList[i].date!).toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                //Hora
                Container(
                    width: 75,
                    child: Text(
                      DateFormat('HH:mm:ss')
                          .format(salesList[i].date!)
                          .toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    )),

                //Nombre
                Container(
                    width: 120,
                    child: Text(
                      (salesList[i].orderName == '')
                          ? 'Sin nombre'
                          : '${salesList[i].orderName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    )),

                //Payment Type
                Container(
                    width: 120,
                    child: Center(
                      child: Text(
                        '${salesList[i].paymentType}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )),
                //Total
                Container(
                    width: 70,
                    child: Center(
                      child: Text(
                        '${formatCurrency.format(salesList[i].total)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )),
                //More Button
                IconButton(
                  icon: Icon(Icons.search, color: Colors.black, size: 20),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return StreamProvider<DailyTransactions>.value(
                              initialData: DailyTransactions(),
                              catchError: (_, err) => DailyTransactions(),
                              value: DatabaseService().dailyTransactions(
                                  businessID, registerStatus.registerName!),
                              builder: (context, snapshot) {
                                return SingleSaleDialog(
                                    salesList[i],
                                    businessID,
                                    salesList[i].docID!,
                                    registerStatus.paymentTypes!,
                                    registerStatus);
                              });
                        });
                  },
                )
              ],
            ),
          ),
        );
      } else {
        return TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return StreamProvider<DailyTransactions>.value(
                  initialData: DailyTransactions(),
                  catchError: (_, err) => DailyTransactions(),
                  value: DatabaseService().dailyTransactions(
                      businessID, registerStatus.registerName!),
                  builder: (context, snapshot) {
                    return SingleSaleDialog(
                        salesList[i],
                        businessID,
                        salesList[i].docID!,
                        registerStatus.paymentTypes!,
                        registerStatus);
                  });
            }));
          },
          child: Container(
            height: 50,
            width: double.infinity,
            padding: EdgeInsets.all(5),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //Fecha
                  Expanded(
                    flex: 3,
                    child: Container(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat.MMMd()
                              .format(salesList[i].date!)
                              .toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          DateFormat('HH:mm')
                              .format(salesList[i].date!)
                              .toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.normal,
                          ),
                        )
                      ],
                    )),
                  ),

                  //Nombre
                  Expanded(
                    flex: 5,
                    child: Container(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          (salesList[i].orderName == '')
                              ? 'Sin nombre'
                              : '${salesList[i].orderName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '${salesList[i].paymentType}',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    )),
                  ),
                  //Total
                  Expanded(
                    flex: 3,
                    child: Container(
                        child: Text(
                      '${formatCurrency.format(salesList[i].total)}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w800, color: Colors.black),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }, childCount: salesList.length));
  }
}
