import 'package:denario/Models/Supply.dart';
import 'package:denario/Supplies/NewSupply.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SuppliesList extends StatelessWidget {
  final String currentBusiness;
  final loadMore;
  final int limitSearch;
  SuppliesList(this.currentBusiness, this.loadMore, this.limitSearch, {Key key})
      : super(key: key);

  final formatCurrency = new NumberFormat.simpleCurrency();

  @override
  Widget build(BuildContext context) {
    final supplies = Provider.of<List<Supply>>(context);

    if (supplies == null || supplies.length < 1) {
      return SliverList(
          delegate: SliverChildBuilderDelegate((context, i) {
        return const SizedBox();
      }, childCount: 1));
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, i) {
          if (i < supplies.length) {
            String description;
            if (supplies[i].suppliers.isEmpty) {
              description = 'Sin proveedor';
            } else if (supplies[i].suppliers.length > 1) {
              if (supplies[i].suppliers.length > 2) {
                description =
                    '${supplies[i].suppliers[0]}, ${supplies[i].suppliers[1]}...';
              } else {
                description =
                    '${supplies[i].suppliers[0]}, ${supplies[i].suppliers[1]}';
              }
            } else {
              description = supplies[i].suppliers.first;
            }

            if (MediaQuery.of(context).size.width > 650) {
              return TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              NewSupply(currentBusiness, supplies[i])));
                },
                child: Container(
                  color: i.isOdd ? Colors.grey[100] : Colors.white,
                  width: double.infinity,
                  height: 50,
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //Suppliers
                      (MediaQuery.of(context).size.width > 950)
                          ? Container(
                              width: 150,
                              child: Text(
                                description,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black),
                              ))
                          : SizedBox(),
                      //Nombre
                      (MediaQuery.of(context).size.width > 950)
                          ? Container(
                              width: 150,
                              child: Text(
                                supplies[i].supply,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black),
                              ))
                          : Column(
                              children: [
                                Container(
                                    width: 150,
                                    child: Text(
                                      supplies[i].supply,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    )),
                                SizedBox(height: 5),
                                Container(
                                    width: 150,
                                    child: Text(
                                      description,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 11),
                                    ))
                              ],
                            ),
                      //QTY
                      Container(
                          width: 150,
                          child: Text(
                            supplies[i].qty.toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black),
                          )),
                      //Unit
                      Container(
                          width: 100,
                          child: Text(
                            supplies[i].unit,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black),
                          )),
                      //Precio
                      Container(
                          width: 150,
                          child: Text(
                            '${formatCurrency.format(supplies[i].price)}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                    ],
                  ),
                ),
              );
            } else {
              return TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              NewSupply(currentBusiness, supplies[i])));
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //Nombre
                      Expanded(
                        flex: 3,
                        child: Container(
                          child: Column(
                            children: [
                              Container(
                                  child: Text(
                                supplies[i].supply,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              )),
                              SizedBox(height: 5),
                              Container(
                                  child: Text(
                                description,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 11),
                              ))
                            ],
                          ),
                        ),
                      ),
                      //QTY
                      Expanded(
                        flex: 3,
                        child: Container(
                            child: Column(
                          children: [
                            Text(
                              supplies[i].qty.toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14),
                            ),
                            SizedBox(height: 5),
                            Text(
                              supplies[i].unit,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 11),
                            )
                          ],
                        )),
                      ),
                      //Precio
                      Expanded(
                        flex: 3,
                        child: Container(
                            child: Text(
                          '${formatCurrency.format(supplies[i].price)}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )),
                      ),
                    ],
                  ),
                ),
              );
            }
          } else if (supplies.length < limitSearch) {
            return SizedBox();
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Button load more
                  Container(
                    height: 30,
                    child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () {
                          loadMore();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 5),
                          child: Text(
                            'Ver más',
                            style: TextStyle(color: Colors.black),
                          ),
                        )),
                  ),
                ],
              ),
            );
          }
        },
        childCount: supplies.length + 1,
      ),
    );
  }
}
