import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Dashboard/SalesDetailsFilters.dart';
import 'package:denario/Dashboard/SingleSaleDialog.dart';
import 'package:denario/Models/DailyCash.dart';
import 'package:denario/Models/Sales.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ShortSalesList extends StatelessWidget {
  final String userBusiness;
  final CashRegister registerStatus;
  ShortSalesList(this.userBusiness, this.registerStatus, {Key key})
      : super(key: key);

  final formatCurrency = new NumberFormat.simpleCurrency();

  @override
  Widget build(BuildContext context) {
    final salesList = Provider.of<List<Sales>>(context);

    if (salesList == null) {
      return Container();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Title
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //Texto
                Text(
                  'Ventas',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  textAlign: TextAlign.start,
                ),
                Spacer(),
                IconButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SalesDetailsFilters(
                                userBusiness, registerStatus))),
                    icon: Icon(
                      Icons.search,
                      color: Colors.black,
                      size: 24,
                    ))
              ]),
        ),
        //List
        Container(
          width: double.infinity,
          child: ListView.builder(
              itemCount: salesList.length,
              shrinkWrap: true,
              reverse: false,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, i) {
                return TextButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return StreamProvider<DailyTransactions>.value(
                              initialData: null,
                              catchError: (_, err) => null,
                              value: DatabaseService().dailyTransactions(
                                  userBusiness, registerStatus.registerName),
                              builder: (context, snapshot) {
                                return SingleSaleDialog(
                                    salesList[i],
                                    userBusiness,
                                    salesList[i].docID,
                                    registerStatus.paymentTypes,
                                    registerStatus);
                              });
                        });
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    padding: EdgeInsets.all(5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //Fecha
                        Container(
                            width: 45,
                            child: Text(
                              DateFormat.MMMd()
                                  .format(salesList[i].date)
                                  .toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                        //Hora
                        Container(
                            width: 70,
                            child: Text(
                              DateFormat('HH:mm:ss')
                                  .format(salesList[i].date)
                                  .toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                              ),
                            )),

                        //Nombre
                        (MediaQuery.of(context).size.width < 1100)
                            ? Container(
                                width: 120,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    //Name
                                    Text(
                                        (salesList[i].orderName == '')
                                            ? 'Sin nombre'
                                            : '${salesList[i].orderName}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal,
                                        )),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    //Payment
                                    Text(
                                      '${salesList[i].paymentType}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 11),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                width: 120,
                                child: Text(
                                  (salesList[i].orderName == '')
                                      ? 'Sin nombre'
                                      : '${salesList[i].orderName}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                  ),
                                )),

                        //Payment Type
                        (MediaQuery.of(context).size.width < 1100)
                            ? Container()
                            : Container(
                                width: 120,
                                child: Center(
                                  child: Text(
                                    '${salesList[i].paymentType}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )),
                        //Total
                        Container(
                            width: 100,
                            child: Center(
                              child: Text(
                                '${formatCurrency.format(salesList[i].total)}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )),
                      ],
                    ),
                  ),
                );
              }),
        )
      ],
    );
  }
}
