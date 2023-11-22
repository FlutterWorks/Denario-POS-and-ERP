import 'package:denario/Backend/Ticket.dart';
import 'package:denario/Models/SavedOrders.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CounterViewMobile extends StatelessWidget {
  final PageController tableController;
  CounterViewMobile(this.tableController, {Key? key}) : super(key: key);

  final formatCurrency = new NumberFormat.simpleCurrency();

  @override
  Widget build(BuildContext context) {
    final savedOrders = Provider.of<List<SavedOrders>?>(context);

    if (savedOrders == null) {
      return Container();
    }

    return SliverList.builder(
      itemCount: savedOrders.length,
      itemBuilder: (context, i) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.only(left: 15, right: 15, top: 10),
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
              overlayColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.hovered))
                    return Colors.black12;
                  if (states.contains(MaterialState.focused) ||
                      states.contains(MaterialState.pressed))
                    return Colors.black26;
                  return null; // Defer to the widget's default.
                },
              ),
            ),
            onPressed: () {
              //create order with table name
              bloc.retrieveOrder(
                  savedOrders[i].orderName,
                  savedOrders[i].paymentType,
                  savedOrders[i].orderDetail,
                  savedOrders[i].discount,
                  savedOrders[i].tax,
                  Color(savedOrders[i].orderColor!),
                  true,
                  savedOrders[i].id,
                  true,
                  savedOrders[i].orderType,
                  (savedOrders[i].client!['Name'] == '' ||
                          savedOrders[i].client!['Name'] == null)
                      ? false
                      : true,
                  savedOrders[i].client);
              tableController.animateToPage(1,
                  duration: Duration(milliseconds: 250), curve: Curves.easeIn);
            },
            child: Container(
                padding: EdgeInsets.all(15),
                alignment: Alignment.topLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Name of order + time
                    (savedOrders[i].orderName == '')
                        ? Container()
                        : Text(
                            '${savedOrders[i].orderName}',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),
                    SizedBox(height: (savedOrders[i].orderName == '') ? 0 : 10),
                    (savedOrders[i].orderDetail == [])
                        ? SizedBox()
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: (savedOrders[i].orderDetail!.length > 5)
                                ? 5
                                : savedOrders[i].orderDetail!.length,
                            itemBuilder: (context, x) {
                              if ((savedOrders[i].orderDetail!.length > 5) &&
                                  x == 4) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    '...',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                );
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    //Product and qty
                                    Expanded(
                                      flex: 10,
                                      child: Text(
                                        '${savedOrders[i].orderDetail![x]['Name']}',
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 14),
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    //Total
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                          'x${savedOrders[i].orderDetail![x]['Quantity']}',
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14)),
                                    ),
                                  ],
                                ),
                              );
                            }),
                    SizedBox(
                      height: 30,
                    ),
                    (savedOrders[i].orderType == 'Delivery')
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              //Icon
                              IconButton(
                                  tooltip: 'Delivery',
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.directions_bike_outlined,
                                    color: Colors.greenAccent,
                                  )),
                              Spacer(),
                              Text(
                                'Total: ',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal),
                              ),
                              Text(
                                formatCurrency.format(savedOrders[i].total),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Total: ',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal),
                              ),
                              Text(
                                formatCurrency.format(savedOrders[i].total),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          )
                  ],
                )
                // Column(
                //   mainAxisAlignment: MainAxisAlignment.start,
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     //Name of order + time
                //     (savedOrders[i].orderName == '')
                //         ? Container()
                //         : Text(
                //             '${savedOrders[i].orderName}',
                //             style: TextStyle(
                //                 color: Colors.black,
                //                 fontSize: 16,
                //                 fontWeight: FontWeight.bold),
                //           ),
                //     SizedBox(height: (savedOrders[i].orderName == '') ? 0 : 10),
                //     //Items
                //     (savedOrders[i].orderDetail == [])
                //         ? SizedBox()
                //         : ListView.builder(
                //             shrinkWrap: true,
                //             itemCount: (savedOrders[i].orderDetail!.length > 5)
                //                 ? 5
                //                 : savedOrders[i].orderDetail!.length,
                //             itemBuilder: (context, x) {
                //               if ((savedOrders[i].orderDetail!.length > 5) &&
                //                   x == 4) {
                //                 return Padding(
                //                   padding: const EdgeInsets.only(top: 8.0),
                //                   child: Text(
                //                     '...',
                //                     style: TextStyle(
                //                         color: Colors.black,
                //                         fontSize: 18,
                //                         fontWeight: FontWeight.bold),
                //                   ),
                //                 );
                //               }
                //               return Padding(
                //                 padding: const EdgeInsets.only(top: 8.0),
                //                 child: Row(
                //                   mainAxisAlignment: MainAxisAlignment.start,
                //                   children: [
                //                     //Product and qty
                //                     Expanded(
                //                       flex: 10,
                //                       child: Text(
                //                         '${savedOrders[i].orderDetail![x]['Name']}',
                //                         style: TextStyle(
                //                             color: Colors.black, fontSize: 14),
                //                       ),
                //                     ),
                //                     SizedBox(width: 5),
                //                     //Total
                //                     Expanded(
                //                       flex: 2,
                //                       child: Text(
                //                           'x${savedOrders[i].orderDetail![x]['Quantity']}',
                //                           textAlign: TextAlign.end,
                //                           style: TextStyle(
                //                               color: Colors.black,
                //                               fontSize: 14)),
                //                     ),
                //                   ],
                //                 ),
                //               );
                //             }),
                //     Spacer(),
                //     (savedOrders[i].orderType == 'Delivery')
                //         ? Row(
                //             mainAxisAlignment: MainAxisAlignment.end,
                //             children: [
                //               //Icon
                //               IconButton(
                //                   tooltip: 'Delivery',
                //                   onPressed: () {},
                //                   icon: Icon(
                //                     Icons.directions_bike_outlined,
                //                     color: Colors.greenAccent,
                //                   ))
                //             ],
                //           )
                //         : Container()
                //   ],
                // )
                ),
          ),
        );
      },
    );
  }
}
