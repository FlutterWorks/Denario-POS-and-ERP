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
            return Container(
              color: i.isOdd ? Colors.grey[100] : Colors.white,
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //Suppliers
                  Container(
                      width: 150,
                      child: Text(
                        description,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black),
                      )),
                  //Nombre
                  Container(
                      width: 150,
                      child: Text(
                        supplies[i].supply,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black),
                      )),
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
                  //More Button
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.black, size: 20),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  NewSupply(currentBusiness, supplies[i])));
                    },
                  )
                ],
              ),
            );
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
