import 'package:denario/Backend/Ticket.dart';
import 'package:denario/Models/Products.dart';
import 'package:denario/POS/POSAddFractionItem.dart';
import 'package:denario/POS/POSItemDialog.dart';
import 'package:flutter/material.dart';

class PlateSelectionDesktop extends StatefulWidget {
  final String businessID;
  final String category;
  final List<Products> productList;
  final bool search;
  final String searchName;
  final List categoryList;
  PlateSelectionDesktop(this.businessID, this.category, this.productList,
      this.search, this.searchName, this.categoryList);

  @override
  _PlateSelectionDesktopState createState() => _PlateSelectionDesktopState();
}

class _PlateSelectionDesktopState extends State<PlateSelectionDesktop> {
  bool productExists = false;
  int? itemIndex;
  List<Products>? product;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: bloc.getStream,
        initialData: bloc.ticketItems,
        builder: (context, snapshot) {
          if (widget.search && widget.searchName.length > 0) {
            if (widget.productList.any(
                (menuItem) => menuItem.code!.contains(widget.searchName))) {
              product = widget.productList
                  .where((menuItem) => menuItem.code!
                      .toLowerCase()
                      .contains(widget.searchName.toLowerCase()))
                  .toList();
            } else {
              product = widget.productList
                  .where((menuItem) => menuItem.product!
                      .toLowerCase()
                      .contains(widget.searchName.toLowerCase()))
                  .toList();
            }
          } else {
            product = widget.productList
                .where((menuItem) => menuItem.category == widget.category)
                .toList();
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: (MediaQuery.of(context).size.width > 1100)
                  ? 5
                  : (MediaQuery.of(context).size.width > 950)
                      ? 4
                      : 3,
              crossAxisSpacing: 15.0,
              mainAxisSpacing: 15.0,
              childAspectRatio: 1,
            ),
            scrollDirection: Axis.vertical,
            itemCount: product!.length,
            itemBuilder: (context, i) {
              double totalCost = 0;
              List ingredients = product![i].ingredients!;
              if (ingredients.length > 0) {
                for (int x = 0; x < ingredients.length; x++) {
                  if (ingredients[x]['Supply Cost'] != null &&
                      ingredients[x]['Supply Quantity'] != null &&
                      ingredients[x]['Quantity'] != null &&
                      ingredients[x]['Yield'] != null) {
                    double ingredientTotal = ((ingredients[x]['Supply Cost'] /
                                ingredients[x]['Supply Quantity']) *
                            ingredients[x]['Quantity']) /
                        ingredients[x]['Yield'];
                    if (!ingredientTotal.isNaN &&
                        !ingredientTotal.isInfinite &&
                        !ingredientTotal.isNegative) {
                      totalCost = totalCost + ingredientTotal;
                    }
                  }
                }
              }
              return ElevatedButton(
                style: ButtonStyle(
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
                  if (product![i].priceType == 'Precio por fracción') {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return POSAddFractionItem(product![i]);
                        });
                  } else {
                    //If ticket contains product, just add
                    for (var x = 0; x < bloc.ticketItems['Items'].length; x++) {
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
                        'Price': (product![i].priceType == 'Precio por margen')
                            ? (totalCost +
                                (totalCost * (product![i].price! / 100)))
                            : product![i].price,
                        'Quantity': 1,
                        'Total Price':
                            (product![i].priceType == 'Precio por margen')
                                ? (totalCost +
                                    (totalCost * (product![i].price! / 100)))
                                : product![i].price,
                        'Options': [],
                        'Supplies': product![i].ingredients,
                        'Control Stock': product![i].controlStock,
                        'Product ID': product![i].productID
                      });
                    }

                    //Turn false
                    setState(() {
                      productExists = false;
                    });
                  }
                },
                onLongPress: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return POSItemDialog(
                            widget.businessID,
                            product![i],
                            product![i].productID!,
                            product![i].category!,
                            widget.categoryList);
                      });
                },
                child: Container(
                  padding: EdgeInsets.all(5.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      //product
                      Text(
                        product![i].product!, //product[index].product,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                          height: (product![i].controlStock! &&
                                  product![i].currentStock! <
                                      product![i].lowStockAlert!)
                              ? 10
                              : 0),
                      (product![i].controlStock! &&
                              product![i].currentStock! <
                                  product![i].lowStockAlert!)
                          ? Text(
                              'Bajo stock: ${product![i].currentStock}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400),
                            )
                          : SizedBox(),
                      SizedBox(
                          height: (product![i].controlStock! &&
                                  product![i].currentStock! <
                                      product![i].lowStockAlert!)
                              ? 15
                              : 30),

                      ///Price
                      Text(
                        (product![i].priceType == 'Precio por margen')
                            ? "\$${(totalCost + (totalCost * (product![i].price! / 100))).toStringAsFixed(2)}"
                            : "\$${product![i].price}", //'\$120' + //product[index].price.toString(),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        });
  }
}
