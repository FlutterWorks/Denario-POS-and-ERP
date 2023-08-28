import 'package:denario/Models/DailyCash.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatsByProducts extends StatefulWidget {
  final DailyTransactions dayStats;
  StatsByProducts(this.dayStats, {Key key}) : super(key: key);

  @override
  State<StatsByProducts> createState() => _StatsByProductsState();
}

class _StatsByProductsState extends State<StatsByProducts> {
  final formatCurrency = new NumberFormat.simpleCurrency();

  bool sortedPrdAscending;
  bool sortAmtAscending;
  bool sortQtyAscending;
  List nProductList = [];

  void _sortByProduct() {
    if (sortedPrdAscending == null) {
      sortedPrdAscending = true;
      sortAmtAscending = null;
      sortQtyAscending = null;
    } else {}
    setState(() {
      if (sortedPrdAscending) {
        nProductList.sort((a, b) => b['Name'].compareTo(a['Name']));
      } else {
        nProductList.sort((a, b) => a['Name'].compareTo(b['Name']));
      }
      sortedPrdAscending = !sortedPrdAscending;
    });
  }

  void _sortByAmount() {
    if (sortAmtAscending == null) {
      sortedPrdAscending = null;
      sortAmtAscending = true;
      sortQtyAscending = null;
    } else {}
    setState(() {
      if (sortAmtAscending) {
        nProductList.sort((a, b) => b['Amount'].compareTo(a['Amount']));
      } else {
        nProductList.sort((a, b) => a['Amount'].compareTo(b['Amount']));
      }
      sortAmtAscending = !sortAmtAscending;
    });
  }

  void _sortByQty() {
    if (sortQtyAscending == null) {
      sortedPrdAscending = null;
      sortAmtAscending = null;
      sortQtyAscending = true;
    } else {}
    setState(() {
      if (sortQtyAscending) {
        nProductList.sort((a, b) => b['Qty'].compareTo(a['Qty']));
      } else {
        nProductList.sort((a, b) => a['Qty'].compareTo(b['Qty']));
      }
      sortQtyAscending = !sortQtyAscending;
    });
  }

  @override
  void initState() {
    //New
    if (widget.dayStats.salesAmountbyProduct != null) {
      widget.dayStats.salesAmountbyProduct.keys.forEach((k) {
        nProductList.add({
          'Name': k,
          'Qty': widget.dayStats.salesCountbyProduct[k],
          'Amount': widget.dayStats.salesAmountbyProduct[k]
        });
      });
    } else {
      nProductList = [];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(thickness: 0.5, indent: 0, endIndent: 0),
          SizedBox(height: 5),
          //Titles
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //Producto
                Expanded(
                  flex: 4,
                  child: Container(
                      // width: 150,
                      child: TextButton(
                    onPressed: _sortByProduct,
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.hovered)) {
                            return Colors.grey.withOpacity(
                                0.2); // Customize the hover color here
                          }
                          return null; // Use default overlay color for other states
                        },
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Producto',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(width: 2),
                        (sortedPrdAscending == null)
                            ? Container()
                            : Icon(
                                (sortedPrdAscending)
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: Colors.black,
                                size: 12,
                              )
                      ],
                    ),
                  )),
                ),
                SizedBox(width: 10),
                //Monto vendidos
                Expanded(
                  flex: 3,
                  child: Container(
                      // width: 100,
                      child: TextButton(
                          onPressed: _sortByAmount,
                          style: ButtonStyle(
                            overlayColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.hovered)) {
                                  return Colors.grey.withOpacity(
                                      0.2); // Customize the hover color here
                                }
                                return null; // Use default overlay color for other states
                              },
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Monto',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(width: 2),
                              (sortAmtAscending == null)
                                  ? Container()
                                  : Icon(
                                      (sortAmtAscending)
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward,
                                      color: Colors.black,
                                      size: 12,
                                    )
                            ],
                          ))),
                ),
                SizedBox(width: 10),
                //Cantidad vendido
                Expanded(
                  flex: 2,
                  child: Container(
                      // width: 75,
                      child: TextButton(
                          onPressed: _sortByQty,
                          style: ButtonStyle(
                            overlayColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.hovered)) {
                                  return Colors.grey.withOpacity(
                                      0.2); // Customize the hover color here
                                }
                                return null; // Use default overlay color for other states
                              },
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Cantidad',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(width: 2),
                              (sortQtyAscending == null)
                                  ? Container()
                                  : Icon(
                                      (sortQtyAscending)
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward,
                                      color: Colors.black,
                                      size: 12,
                                    )
                            ],
                          ))),
                ),
              ]),
          SizedBox(height: 5),
          //List
          Expanded(
            child: Container(
              child: ListView.builder(
                  itemCount: nProductList.length,
                  shrinkWrap: true,
                  reverse: false,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, i) {
                    return Container(
                      height: 35,
                      width: double.infinity,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          //Producto
                          Expanded(
                            flex: 4,
                            child: Container(
                                // width: 150,
                                child: Text(
                              '${nProductList[i]['Name']}',
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )),
                          ),
                          SizedBox(width: 10),
                          //Monto vendidos
                          Expanded(
                            flex: 3,
                            child: Container(
                                // width: 100,
                                child: Center(
                              child: Text(
                                '${formatCurrency.format(nProductList[i]['Amount'])}', //expenseList[i].total
                                textAlign: TextAlign.left,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )),
                          ),
                          SizedBox(width: 10),
                          //Cantidad vendido
                          Expanded(
                            flex: 2,
                            child: Container(
                                // width: 75,
                                child: Center(
                              child: Text(
                                '${nProductList[i]['Qty']}', //'${expenseList[i].costType}',
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            )),
                          ),
                        ],
                      ),
                    );
                  }),
            ),
          )
        ]);
  }
}
