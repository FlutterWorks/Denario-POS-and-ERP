import 'package:denario/Dashboard/DailyTransactionsList.dart';
import 'package:denario/Models/DailyCash.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DailyHistory extends StatelessWidget {
  final formatCurrency = new NumberFormat.simpleCurrency();

  @override
  Widget build(BuildContext context) {
    final dailyTransactionsListOrigina =
        Provider.of<List<DailyTransactions>>(context);

    if (dailyTransactionsListOrigina == []) {
      return Scaffold(
          body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Go Back /// Title
            Container(
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                //Back
                IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.keyboard_arrow_left_outlined)),
                Spacer(),
                Text('Historico de Arqueos'),
                Spacer()
              ]),
            ),
            SizedBox(height: 20),
            //Historical Details
            Expanded(child: Container(padding: EdgeInsets.all(20)))
          ],
        ),
      ));
    }

    final dailyTransactionsList =
        dailyTransactionsListOrigina.reversed.toList();

    if (MediaQuery.of(context).size.width > 650) {
      return Scaffold(
          body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Go Back /// Title
          Container(
            padding: const EdgeInsets.all(20.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              //Back
              IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.arrow_back)),
              Spacer(),
              Text(
                'Historico de Arqueos',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              Spacer()
            ]),
          ),
          //Historical Details
          Expanded(
              child: Container(
            padding: EdgeInsets.all(20),
            child: (dailyTransactionsList.length == 0)
                ? Container()
                : Container(
                    child: Column(children: [
                    //Titles
                    Container(
                      height: 40,
                      width: double.infinity,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //Fecha
                          Container(
                              width: 50,
                              child: Text(
                                'Fecha',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                          //Apertura
                          Container(
                              width: 75,
                              child: Text(
                                'Apertura',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                          //Cierre
                          Container(
                              width: 75,
                              child: Text(
                                'Cierre',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              )),

                          //Nombre
                          Container(
                              width: 120,
                              child: Text(
                                'Usuario',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                          //Monto inicial
                          Container(
                              width: 200,
                              child: Center(
                                child: Text(
                                  'Monto Inicial',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )),

                          //Monto al cierre
                          Container(
                              width: 200,
                              child: Center(
                                child: Text(
                                  'Monto al Cierre',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )),
                          //More Button
                          SizedBox(width: 20)
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    //List
                    Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          itemCount: dailyTransactionsList.length,
                          itemBuilder: (context, i) {
                            return Container(
                              height: 50,
                              width: double.infinity,
                              color: i.isOdd ? Colors.grey[100] : Colors.white,
                              padding: EdgeInsets.all(5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  //Fecha
                                  Container(
                                      width: 50,
                                      child: Text(
                                        DateFormat.MMMd()
                                            .format(dailyTransactionsList[i]
                                                .openDate!)
                                            .toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                        ),
                                      )),
                                  //Hora
                                  Container(
                                      width: 75,
                                      child: Text(
                                        DateFormat('HH:mm:ss')
                                            .format(dailyTransactionsList[i]
                                                .openDate!)
                                            .toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                        ),
                                      )),
                                  //Cierre
                                  Container(
                                      width: 75,
                                      child: Text(
                                        DateFormat('HH:mm:ss')
                                            .format(dailyTransactionsList[i]
                                                .closeDate!)
                                            .toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: Colors.red),
                                      )),

                                  //Nombre
                                  Container(
                                      width: 120,
                                      child: Text(
                                        dailyTransactionsList[i].user!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                        ),
                                      )),
                                  //Monto inicial
                                  Container(
                                      width: 200,
                                      child: Center(
                                        child: Text(
                                          '${formatCurrency.format(dailyTransactionsList[i].initialAmount)}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )),

                                  //Monto al cierre
                                  Container(
                                      width: 200,
                                      child: Center(
                                        child: Text(
                                          '${formatCurrency.format(dailyTransactionsList[i].closeAmount)}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )),
                                  //More Button
                                  IconButton(
                                    icon: Icon(Icons.search,
                                        color: Colors.black, size: 20),
                                    onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                DailyTransactionsList(
                                                    dailyTransactionsList[i]
                                                        .registerTransactionList!))),
                                  )
                                ],
                              ),
                            );
                          }),
                    ),
                  ])),
          ))
        ],
      ));
    } else {
      return Scaffold(
          body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Go Back /// Title
          Container(
            padding: const EdgeInsets.all(20.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              //Back
              IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.arrow_back)),
              SizedBox(width: 15),
              Text(
                'Historico de Arqueos',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
            ]),
          ),
          //Historical Details
          Expanded(
              child: Container(
            child: (dailyTransactionsList.length == 0)
                ? Container()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemCount: dailyTransactionsList.length,
                    itemBuilder: (context, i) {
                      return TextButton(
                        style:
                            TextButton.styleFrom(backgroundColor: Colors.white),
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DailyTransactionsList(
                                    dailyTransactionsList[i]
                                        .registerTransactionList!))),
                        child: Container(
                          height: 70,
                          width: double.infinity,
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 20),
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
                                    //Date
                                    Text(
                                      DateFormat.MMMd()
                                          .format(dailyTransactionsList[i]
                                              .openDate!)
                                          .toString(),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    //Hours
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        //Open
                                        Text(
                                          DateFormat('HH:mm')
                                              .format(dailyTransactionsList[i]
                                                  .openDate!)
                                              .toString(),
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 11),
                                        ),
                                        SizedBox(width: 5),
                                        //Close
                                        Text(
                                          (dailyTransactionsList[i].closeDate ==
                                                  dailyTransactionsList[i]
                                                      .openDate)
                                              ? ''
                                              : DateFormat('HH:mm')
                                                  .format(
                                                      dailyTransactionsList[i]
                                                          .closeDate!)
                                                  .toString(),
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 11),
                                        )
                                      ],
                                    )
                                  ],
                                )),
                              ),
                              //Nombre
                              Expanded(
                                flex: 3,
                                child: Container(
                                    child: Text(
                                  dailyTransactionsList[i].user!,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black),
                                )),
                              ),
                              //Monto inicial
                              Expanded(
                                flex: 3,
                                child: Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${formatCurrency.format(dailyTransactionsList[i].initialAmount)}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        '${formatCurrency.format(dailyTransactionsList[i].closeAmount)}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: Colors.redAccent[700]),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
          ))
        ],
      ));
    }
  }
}
