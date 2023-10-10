import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyTransactionsList extends StatelessWidget {
  final formatCurrency = new NumberFormat.simpleCurrency();
  final List dailyTransactionsList;

  DailyTransactionsList(this.dailyTransactionsList);

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width > 650) {
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
                Text('Movimientos de Caja'),
                Spacer()
              ]),
            ),
            SizedBox(height: 20),
            //Details
            Expanded(
                child: Container(
              padding: EdgeInsets.all(20),
              child: (dailyTransactionsList.length == 0)
                  ? Container()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                          //Titles
                          Container(
                            height: 40,
                            width: double.infinity,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                //Type
                                Container(
                                    width: 200,
                                    child: Text(
                                      'Tipo de Movimiento',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                                //Time
                                Container(
                                    width: 75,
                                    child: Text(
                                      'Hora',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                                //Motive
                                Container(
                                    width: 120,
                                    child: Text(
                                      'Motivo',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                                //Amount
                                Container(
                                    width: 70,
                                    child: Center(
                                      child: Text(
                                        'Monto',
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
                                    padding: EdgeInsets.all(5),
                                    color: i.isOdd
                                        ? Colors.grey[100]
                                        : Colors.white,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        //Type
                                        Container(
                                            width: 200,
                                            child: Text(
                                              dailyTransactionsList[i]['Type'],
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                              ),
                                            )),
                                        //Time
                                        Container(
                                            width: 75,
                                            child: Text(
                                              (dailyTransactionsList[i]
                                                          ['Time'] !=
                                                      null)
                                                  ? DateFormat('HH:mm:ss')
                                                      .format(
                                                          (dailyTransactionsList[
                                                                  i]['Time'])
                                                              .toDate())
                                                      .toString()
                                                  : '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                              ),
                                            )),
                                        //Motive
                                        Container(
                                            width: 120,
                                            child: Text(
                                              dailyTransactionsList[i]
                                                  ['Motive'],
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                              ),
                                            )),
                                        //Amount
                                        Container(
                                            width: 70,
                                            child: Center(
                                              child: Text(
                                                '${formatCurrency.format(dailyTransactionsList[i]['Amount'])}',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            )),
                                      ],
                                    ),
                                  );
                                }),
                          ),
                        ]),
            ))
          ],
        ),
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
                'Movimientos de Caja',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
            ]),
          ),
          SizedBox(height: 20),
          //Details
          Expanded(
              child: Container(
            child: (dailyTransactionsList.length == 0)
                ? Container()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemCount: dailyTransactionsList.length,
                    itemBuilder: (context, i) {
                      return Container(
                        height: 75,
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        color: Colors.white,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //Type
                            Expanded(
                              flex: 3,
                              child: Container(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    dailyTransactionsList[i]['Type'],
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    (dailyTransactionsList[i]['Time'] != null)
                                        ? DateFormat('HH:mm:ss')
                                            .format((dailyTransactionsList[i]
                                                    ['Time'])
                                                .toDate())
                                            .toString()
                                        : '',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey,
                                        fontSize: 11),
                                  )
                                ],
                              )),
                            ),
                            //Motive
                            Expanded(
                              flex: 4,
                              child: Container(
                                  child: Text(
                                dailyTransactionsList[i]['Motive'],
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                ),
                              )),
                            ),
                            //Amount
                            Expanded(
                              flex: 3,
                              child: Container(
                                  child: Text(
                                '${formatCurrency.format(dailyTransactionsList[i]['Amount'])}',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )),
                            ),
                          ],
                        ),
                      );
                    }),
          ))
        ],
      ));
    }
  }
}
