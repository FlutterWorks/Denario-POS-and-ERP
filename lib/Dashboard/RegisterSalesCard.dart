import 'package:cached_network_image/cached_network_image.dart';
import 'package:denario/Dashboard/SalesDetailsFilters.dart';
import 'package:denario/Models/DailyCash.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RegisterSalesCard extends StatelessWidget {
  final Registradora register;
  final DailyTransactions dailyTransactions;
  final String activeBusiness;
  RegisterSalesCard(this.register, this.dailyTransactions, this.activeBusiness,
      {Key? key})
      : super(key: key);

  final formatCurrency = new NumberFormat.simpleCurrency();

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(20),
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
                    //Texto
                    Text(
                      'Ventas',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      textAlign: TextAlign.start,
                    ),
                    Spacer(),
                    IconButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SalesDetailsFilters(
                                    activeBusiness, register))),
                        icon: Icon(
                          Icons.search,
                          color: Colors.black,
                          size: 24,
                        ))
                  ]),
            ),
            SizedBox(height: 15),
            //Amount
            (register.registerisOpen!)
                ? Text(
                    '${formatCurrency.format(dailyTransactions.sales)}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  )
                : Text(
                    '\$0',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
            SizedBox(height: 15),
            //List of payment types
            Expanded(
              child: (Container(
                  child: GridView.builder(
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      (MediaQuery.of(context).size.width > 600) ? 4 : 3,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 5.0,
                  childAspectRatio: 1.25,
                ),
                scrollDirection: Axis.vertical,
                itemCount: register.paymentTypes!.length,
                itemBuilder: (context, i) {
                  return Container(
                    padding: EdgeInsets.all(5.0),
                    child: Column(
                      children: <Widget>[
                        ///Image
                        Expanded(
                          child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: CachedNetworkImage(
                                  imageUrl: register.paymentTypes![i]['Image'],
                                  fit: BoxFit.cover)),
                        ),
                        SizedBox(height: 10),

                        ///Text
                        Text(
                          (register.registerID == '')
                              ? '${formatCurrency.format(0)}'
                              : (dailyTransactions.salesByMedium![register
                                              .paymentTypes![i]['Type']] !=
                                          null &&
                                      dailyTransactions.salesByMedium![register
                                              .paymentTypes![i]['Type']] >
                                          0)
                                  ? '${formatCurrency.format(dailyTransactions.salesByMedium![register.paymentTypes![i]['Type']])}'
                                  : '${formatCurrency.format(0)}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                },
              ))),
            )
          ],
        ));
  }
}
