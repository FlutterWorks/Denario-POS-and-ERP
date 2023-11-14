import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Expenses/SinglePayableDialog.dart';
import 'package:denario/Models/DailyCash.dart';
import 'package:denario/Models/Payables.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PayablesList extends StatelessWidget {
  final String businessID;
  PayablesList(this.businessID);
  @override
  Widget build(BuildContext context) {
    final formatCurrency = new NumberFormat.simpleCurrency();
    final payables = Provider.of<List<Payables>>(context);
    final registerStatus = Provider.of<Registradora>(context);

    if (payables == []) {
      return Container();
    }

    if (payables.length == 0) {
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
                'Nada para mostrar por acá',
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

    return Container(
      width: double.infinity,
      child: ListView.builder(
          itemCount: payables.length,
          shrinkWrap: true,
          reverse: false,
          physics: BouncingScrollPhysics(),
          itemBuilder: (context, i) {
            String description;

            if (payables[i].items!.isEmpty) {
              description = 'Sin descripción';
            } else if (payables[i].items!.length > 1) {
              if (payables[i].items!.length > 2) {
                description =
                    '${payables[i].items![0].product}, ${payables[i].items![1].product}...';
              } else {
                description =
                    '${payables[i].items![0].product}, ${payables[i].items![1].product}';
              }
            } else {
              description = payables[i].items!.first.product!;
            }

            var ageing =
                payables[i].date!.difference(DateTime.now()).inDays * -1;
            if (MediaQuery.of(context).size.width > 650) {
              return TextButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return StreamProvider<DailyTransactions?>.value(
                            initialData: null,
                            value: DatabaseService().dailyTransactions(
                                businessID, registerStatus.registerID!),
                            child:
                                SinglePayableDialog(payables[i], businessID));
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
                        width: 75,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              //Desc
                              Text(
                                (ageing == 0) ? 'Hoy' : '+$ageing días',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: (ageing > 30)
                                        ? Colors.redAccent
                                        : Colors.black),
                              ),
                              SizedBox(height: 5),
                              //Vendor + Cat
                              Container(
                                child: Text(
                                  DateFormat.MMMd()
                                      .format(payables[i].date!)
                                      .toString(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ]),
                      ),
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
                                '${payables[i].vendor != '' ? payables[i].vendor : 'Sin identificar'}',
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
                              '${payables[i].costType}',
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
                                '${formatCurrency.format(payables[i].total)}',
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
                        return StreamProvider<DailyTransactions?>.value(
                            initialData: null,
                            value: DatabaseService().dailyTransactions(
                                businessID, registerStatus.registerID!),
                            child:
                                SinglePayableDialog(payables[i], businessID));
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
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                //Desc
                                Text(
                                  (ageing == 0) ? 'Hoy' : '+$ageing días',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: (ageing > 30)
                                          ? Colors.redAccent
                                          : Colors.black),
                                ),
                                SizedBox(height: 5),
                                //Vendor + Cat
                                Container(
                                  child: Text(
                                    DateFormat.MMMd()
                                        .format(payables[i].date!)
                                        .toString(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ]),
                        ),
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
                                  '${payables[i].vendor != '' ? payables[i].vendor : 'Sin identificar'}',
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
                              '${formatCurrency.format(payables[i].total)}',
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
