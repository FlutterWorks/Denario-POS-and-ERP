import 'package:denario/Backend/Ticket.dart';
import 'package:denario/Models/Products.dart';
import 'package:denario/POS/POSItemDialog.dart';
import 'package:flutter/material.dart';

class PlateSelectionMobile extends StatefulWidget {
  final String businessID;
  final String category;
  final List<Products> productList;
  PlateSelectionMobile(this.businessID, this.category, this.productList);

  @override
  State<PlateSelectionMobile> createState() => _PlateSelectionMobileState();
}

class _PlateSelectionMobileState extends State<PlateSelectionMobile> {
  bool productExists = false;
  int? itemIndex;
  List<Products>? product;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: bloc.getStream,
      initialData: bloc.ticketItems,
      builder: (context, snapshot) {
        product = widget.productList
            .where((menuItem) => menuItem.category == widget.category)
            .toList();

        return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: (MediaQuery.of(context).size.width > 500) ? 3 : 2,
              crossAxisSpacing: 2.0,
              mainAxisSpacing: 2.0,
              childAspectRatio: 1,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                double itemCount = 0;
                for (var x = 0; x < bloc.ticketItems['Items'].length; x++) {
                  if (product![i].product ==
                      bloc.ticketItems['Items'][x]["Name"]) {
                    itemCount =
                        itemCount + bloc.ticketItems['Items'][x]["Quantity"]!;
                  }
                }

                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          EdgeInsets.zero),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
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
                      //If ticket contains product, just add
                      for (var x = 0;
                          x < bloc.ticketItems['Items'].length;
                          x++) {
                        if (product![i].product ==
                                bloc.ticketItems['Items'][x]["Name"] &&
                            bloc.ticketItems['Items'][x]["Options"].isEmpty) {
                          setState(() {
                            productExists = true;
                            itemIndex = x;
                          });
                        }
                      }
                      //Else add new item
                      if (productExists) {
                        bloc.addQuantity(itemIndex);
                      } else {
                        bloc.addToCart({
                          'Name': product![i].product,
                          'Category': product![i].category,
                          'Price': product![i].price,
                          'Quantity': 1,
                          'Total Price': product![i].price,
                          'Options': [],
                          'Supplies': product![i].ingredients
                        });
                      }

                      //Turn false
                      setState(() {
                        productExists = false;
                      });
                    },
                    onLongPress: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return POSItemDialog(
                                widget.businessID,
                                product![i].product!,
                                product![i].productOptions!,
                                product![i].available!,
                                product![i].price!.toDouble(),
                                product![i].category!,
                                product![i].productID!);
                          });
                    },
                    child: Container(
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 10,
                            right: 10,
                            top: 20,
                            bottom: 20,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  //product
                                  Text(
                                    product![i]
                                        .product!, //product[index].product,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  SizedBox(height: 20),

                                  ///Price
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      "\$${product![i].price}", //'\$120' + //product[index].price.toString(),
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          (itemCount > 0)
                              ? Positioned(
                                  right: 5,
                                  top: 5,
                                  child: Container(
                                    height: 25,
                                    width: 25,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.greenAccent),
                                    child: Center(
                                      child: Text(
                                        itemCount.toString(),
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 11),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: product!.length,
            ));
      },
    );
  }
}
