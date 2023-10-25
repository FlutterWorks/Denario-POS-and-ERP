import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Expenses/SinglePayableDialog.dart';
import 'package:denario/Models/DailyCash.dart';
import 'package:denario/Models/Payables.dart';
import 'package:denario/Models/Receivables.dart';
import 'package:denario/No%20POS%20Sales/SingleReceivableDialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PayablesReceivables extends StatefulWidget {
  final String businessID;
  const PayablesReceivables(this.businessID, {Key? key}) : super(key: key);

  @override
  State<PayablesReceivables> createState() => _PayablesReceivablesState();
}

class _PayablesReceivablesState extends State<PayablesReceivables> {
  final PageController pageController = PageController();
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final formatCurrency = new NumberFormat.simpleCurrency();
    final payables = Provider.of<List<Payables>>(context);
    final receivables = Provider.of<List<Receivables>>(context);
    final registerStatus = Provider.of<CashRegister>(context);

    if (payables == []) {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: <BoxShadow>[
            new BoxShadow(
              color: Colors.grey[350]!,
              offset: new Offset(0, 0),
              blurRadius: 10.0,
            )
          ],
        ),
        child: Column(
          children: [
            //Titles
            Row(
              children: [
                Container(
                  height: 15,
                  width: 70,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                SizedBox(width: 20),
                Container(
                  height: 15,
                  width: 70,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Divider(
              thickness: 0.5,
              indent: 5,
              endIndent: 5,
              color: Colors.grey,
            ),
            SizedBox(height: 10),
            //List
            Expanded(
              child: Container(
                child: ListView.builder(
                    itemCount: 7,
                    shrinkWrap: true,
                    reverse: false,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Container(
                          height: 50,
                          child: Row(children: [
                            Container(
                              width: 30,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            SizedBox(width: 20),
                            Container(
                              width: 100,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(25),
                              ),
                            )
                          ]),
                        ),
                      );
                    }),
              ),
            )
          ],
        ),
      );
    }
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: <BoxShadow>[
          new BoxShadow(
            color: Colors.grey[350]!,
            offset: new Offset(0, 0),
            blurRadius: 10.0,
          )
        ],
      ),
      child: Column(children: [
        //Title
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //Payables
            Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          width: (_currentPageIndex == 0) ? 3 : 0,
                          color: (_currentPageIndex == 0)
                              ? Colors.greenAccent[700]!
                              : Colors.transparent))),
              child: TextButton(
                  onPressed: () {
                    setState(() {
                      _currentPageIndex = 0;
                    });
                    pageController.animateToPage(0,
                        duration: Duration(milliseconds: 250),
                        curve: Curves.easeIn);
                  },
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.hovered)) {
                          return Colors.grey.withOpacity(
                              0.2); // Customize the hover color here
                        }
                        return Colors.grey.withOpacity(
                            0.2); // Use default overlay color for other states
                      },
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(
                      'Por pagar',
                      style: TextStyle(
                          fontWeight: (_currentPageIndex == 0)
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: (_currentPageIndex == 0)
                              ? Colors.greenAccent[700]
                              : Colors.black),
                    ),
                  )),
            ),
            SizedBox(width: 10),
            //Receivables
            Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          width: (_currentPageIndex == 1) ? 3 : 0,
                          color: (_currentPageIndex == 1)
                              ? Colors.greenAccent[700]!
                              : Colors.transparent))),
              child: TextButton(
                  onPressed: () {
                    setState(() {
                      _currentPageIndex = 1;
                    });
                    pageController.animateToPage(1,
                        duration: Duration(milliseconds: 250),
                        curve: Curves.easeIn);
                  },
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.hovered)) {
                          return Colors.grey.withOpacity(
                              0.2); // Customize the hover color here
                        }
                        return Colors.grey.withOpacity(
                            0.2); // Use default overlay color for other states
                      },
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(
                      'Por cobrar',
                      style: TextStyle(
                          fontWeight: (_currentPageIndex == 1)
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: (_currentPageIndex == 1)
                              ? Colors.greenAccent[700]
                              : Colors.black),
                    ),
                  )),
            ),
          ],
        ),
        SizedBox(height: 5),
        Divider(
          thickness: 0.5,
          indent: 5,
          endIndent: 5,
          color: Colors.grey,
        ),
        SizedBox(height: 10),
        //List
        Expanded(
          child: PageView(
            controller: pageController,
            children: [
              //Payables
              Container(
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
                          payables[i].date!.difference(DateTime.now()).inDays *
                              -1;

                      return TextButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return StreamProvider<DailyTransactions>.value(
                                    initialData: DailyTransactions(),
                                    value: DatabaseService().dailyTransactions(
                                        widget.businessID,
                                        registerStatus.registerName!),
                                    child: SinglePayableDialog(
                                        payables[i], widget.businessID));
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      //Desc
                                      Text(
                                        (ageing == 0) ? 'Hoy' : '+$ageing días',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: (ageing > 30)
                                                ? Colors.red
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
                                width: 120,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                        '${payables[i].vendor}',
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
                    }),
              ),
              //Receivables
              Container(
                child: ListView.builder(
                    itemCount: receivables.length,
                    shrinkWrap: true,
                    reverse: false,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, i) {
                      String description;

                      if (receivables[i].orderDetail!.length > 1) {
                        if (receivables[i].orderDetail!.length > 2) {
                          description =
                              '${receivables[i].orderDetail![0].product}, ${receivables[i].orderDetail![1].product}...';
                        } else {
                          description =
                              '${receivables[i].orderDetail![0].product}, ${receivables[i].orderDetail![1].product}';
                        }
                      } else {
                        description =
                            receivables[i].orderDetail!.first.product!;
                      }

                      var ageing = receivables[i]
                              .savedDate!
                              .difference(DateTime.now())
                              .inDays *
                          -1;

                      return TextButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return StreamProvider<DailyTransactions>.value(
                                    initialData: DailyTransactions(),
                                    catchError: (_, err) => DailyTransactions(),
                                    value: DatabaseService().dailyTransactions(
                                        widget.businessID,
                                        registerStatus.registerName!),
                                    builder: (context, snapshot) {
                                      return SingleReceivableDialog(
                                          receivables[i],
                                          widget.businessID,
                                          receivables[i].id!,
                                          registerStatus.paymentTypes!,
                                          registerStatus);
                                    });
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      //Date
                                      Text(
                                        (ageing == 0) ? 'Hoy' : '+$ageing días',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                      SizedBox(height: 5),
                                      //Date
                                      Container(
                                        child: Text(
                                          DateFormat.MMMd()
                                              .format(receivables[i].savedDate!)
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
                              (receivables[i].clientName == '')
                                  ? Container(
                                      width: 120,
                                      child: Center(
                                          child: Text(
                                        description,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black),
                                      )),
                                    )
                                  : Container(
                                      width: 120,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                              '${receivables[i].clientName}',
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
                              //Total
                              Container(
                                  width: 70,
                                  child: Center(
                                    child: Text(
                                        '${formatCurrency.format(receivables[i].total)}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Color.fromARGB(255, 2, 2, 2))),
                                  )),
                            ],
                          ),
                        ),
                      );
                    }),
              ),
            ],
          ),
        )
      ]),
    );
  }
}
