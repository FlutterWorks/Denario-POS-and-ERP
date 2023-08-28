import 'package:denario/Backend/Ticket.dart';
import 'package:denario/Models/Tables.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TablesMapDesktop extends StatefulWidget {
  final String businessID;
  final PageController tableController;
  TablesMapDesktop(this.businessID, this.tableController);
  @override
  _TablesMapDesktopState createState() => _TablesMapDesktopState();
}

class _TablesMapDesktopState extends State<TablesMapDesktop> {
  bool productExists = false;
  int itemIndex;
  final formatCurrency = new NumberFormat.simpleCurrency();

  @override
  Widget build(BuildContext context) {
    final tables = Provider.of<List<Tables>>(context);

    if (tables == null) {
      return Center();
    }

    return StreamBuilder(
        stream: bloc.getStream,
        initialData: bloc.ticketItems,
        builder: (context, snapshot) {
          return InteractiveViewer(
            child: Stack(
              children: [
                ...tables.map((table) {
                  var tableBaseSize;
                  var tableHeight;
                  var tableWidth;
                  var tableShape;

                  tableBaseSize = (table.tableSize *
                          ((MediaQuery.of(context).size.height - 120) *
                              (MediaQuery.of(context).size.width - 36))) /
                      90;

                  if (table.shape == 'Circle') {
                    tableHeight = tableBaseSize;
                    tableWidth = tableBaseSize;
                    tableShape = 'Circle';
                  } else if (table.shape == 'Wide Rectangle') {
                    tableHeight = tableBaseSize;
                    tableWidth = tableBaseSize * 2;
                    tableShape = 'Wide Rectangle';
                  } else if (table.shape == 'Tall Rectangle') {
                    tableHeight = tableBaseSize * 2;
                    tableWidth = tableBaseSize;
                    tableShape = 'Tall Rectangle';
                  } else {
                    tableHeight = tableBaseSize;
                    tableWidth = tableBaseSize;
                    tableShape = 'Square';
                  }

                  return Positioned(
                      left: (MediaQuery.of(context).size.width - 150) * table.x,
                      top: (MediaQuery.of(context).size.height - 120) * table.y,
                      child: Container(
                        height: tableHeight,
                        width: tableWidth,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: (table.isOpen)
                                ? MaterialStateProperty.all<Color>(
                                    Colors.greenAccent)
                                : MaterialStateProperty.all<Color>(
                                    Colors.white),
                            overlayColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.hovered))
                                  return Colors.black12;
                                if (states.contains(MaterialState.focused) ||
                                    states.contains(MaterialState.pressed))
                                  return Colors.black26;
                                return null; // Defer to the widget's default.
                              },
                            ),
                            shape: (tableShape == "Circle")
                                ? MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(37.5),
                                  ))
                                : MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                          ),
                          onPressed: () {
                            if (table.isOpen) {
                              //retrieve order
                              bloc.retrieveOrder(
                                  table.table,
                                  table.paymentType,
                                  table.orderDetail,
                                  table.discount,
                                  table.tax,
                                  Color(table.orderColor),
                                  true,
                                  'Mesa ${table.table}',
                                  false,
                                  'Mesa',
                                  (table.client['Name'] == '' ||
                                          table.client['Name'] == null)
                                      ? false
                                      : true,
                                  table.client);
                            } else {
                              //create order with table name
                              bloc.retrieveOrder(
                                  table.table,
                                  table.paymentType,
                                  table.orderDetail,
                                  table.discount,
                                  table.tax,
                                  Color(table.orderColor),
                                  false,
                                  'Mesa ${table.table}',
                                  false,
                                  'Mesa',
                                  false, {});
                            }
                            widget.tableController.animateToPage(1,
                                duration: Duration(milliseconds: 250),
                                curve: Curves.easeIn);
                          },
                          child: (table.isOpen)
                              ? Tooltip(
                                  message:
                                      'Total: ${formatCurrency.format(table.total)}',
                                  child: Center(
                                    child: Text(
                                      table.table, //product[index].product,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: true,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    table.table, //product[index].product,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800),
                                  ),
                                ),
                        ),
                      ));
                })
              ],
            ),
          );
        });
  }
}
