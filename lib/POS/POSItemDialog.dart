import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Backend/Ticket.dart';
import 'package:denario/Models/Products.dart';
import 'package:denario/Products/NewProduct.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class POSItemDialog extends StatefulWidget {
  final String businessID;
  final Products product;
  // final String product;
  // final List<ProductOptions> productOptions;
  // final bool availableOnMenu;
  final List categoryList;
  final String category;
  final String documentID;

  POSItemDialog(this.businessID, this.product, this.documentID, this.category,
      this.categoryList);
  @override
  _POSItemDialogState createState() => _POSItemDialogState();
}

class _POSItemDialogState extends State<POSItemDialog> {
  late bool isAvailable;
  late bool changedAvailability;
  late int quantity;
  late double selectedPrice;
  late double basePrice;
  final formatCurrency = new NumberFormat.simpleCurrency();
  List selectedTags = [];

  double totalAmount(
    double basePrice,
    List selectedTags,
  ) {
    double total = 0;
    List<double> additionalsList = [];
    double additionalAmount = 0;

    //Serch for base price
    widget.product.productOptions!.forEach((x) {
      if (x.priceStructure == 'Aditional') {
        for (var i = 0; i < x.priceOptions.length; i++) {
          if (selectedTags.contains(x.priceOptions[i]['Option'])) {
            additionalsList.add(x.priceOptions[i]['Price']);
          }
        }
      }
    });

    //Add up
    additionalsList.forEach((y) {
      additionalAmount = additionalAmount + y;
    });

    total = basePrice + additionalAmount;

    return total;
  }

  double totalCost = 0;
  List ingredients = [];

  @override
  void initState() {
    ingredients = widget.product.ingredients!;
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

    isAvailable = widget.product.available!;
    changedAvailability = false;
    quantity = 1;
    selectedPrice = widget.product.price!;
    basePrice = (widget.product.priceType == 'Precio por margen')
        ? (totalCost + (totalCost * (widget.product.price! / 100)))
        : widget.product.price!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Container(
            width: (MediaQuery.of(context).size.width > 500)
                ? 400
                : MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(minHeight: 350),
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //Edit//Cancel Icon
                  Container(
                    child: Row(
                      children: [
                        //Edit
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => NewProduct(
                                            widget.businessID,
                                            widget.categoryList,
                                            widget.category,
                                            widget.product,
                                            fromPOS: true,
                                          )));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                //Icon
                                Icon(Icons.edit, size: 16, color: Colors.black),
                                SizedBox(width: 8),
                                //Text
                                Text(
                                  'Editar',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 14),
                                )
                              ],
                            )),
                        Spacer(),
                        //Close,
                        IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close),
                            iconSize: 20.0),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  //Product
                  Container(
                    width: double.infinity,
                    child: Text(
                      widget.product.product!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(height: 20),
                  //Price
                  Container(
                    width: double.infinity,
                    child: Text(
                      '${formatCurrency.format(totalAmount(basePrice, selectedTags))}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '${widget.product.priceType}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 20),
                  //Available
                  Container(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        (widget.product.controlStock!)
                            ? Text(
                                'Stock: ${widget.product.currentStock}',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              )
                            : SizedBox(),
                        SizedBox(
                            width: (widget.product.controlStock!) ? 25 : 0),
                        //Available Button
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Disponible',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400),
                            ),
                            SizedBox(width: 10),
                            Switch(
                              value: isAvailable,
                              onChanged: (value) {
                                setState(() {
                                  isAvailable = value;
                                  changedAvailability = true;
                                });
                              },
                              activeTrackColor: Colors.lightGreenAccent,
                              activeColor: Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  //Price Options
                  (widget.product.productOptions!.length == 0)
                      ? Container()
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: widget.product.productOptions!.length,
                          itemBuilder: (context, i) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 15.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //Title
                                  Text(
                                    widget.product.productOptions![i].title,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.black),
                                  ),
                                  SizedBox(height: 10),
                                  //List
                                  Container(
                                      width: double.infinity,
                                      child: Wrap(
                                        alignment: WrapAlignment.center,
                                        spacing: 5,
                                        children: List.generate(
                                            widget.product.productOptions![i]
                                                .priceOptions.length, (x) {
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: (selectedTags
                                                          .contains(widget
                                                                  .product
                                                                  .productOptions![
                                                                      i]
                                                                  .priceOptions[
                                                              x]['Option'])
                                                      ? Colors.greenAccent
                                                      : Colors.white)),
                                              onPressed: () {
                                                if (!selectedTags.contains(
                                                    widget
                                                            .product
                                                            .productOptions![i]
                                                            .priceOptions[x]
                                                        ['Option'])) {
                                                  //IF SINGLE CHOICE, REMOVE OTHERS
                                                  if (!widget
                                                      .product
                                                      .productOptions![i]
                                                      .multipleOptions) {
                                                    widget
                                                        .product
                                                        .productOptions![i]
                                                        .priceOptions
                                                        .forEach((x) {
                                                      if (selectedTags.contains(
                                                          x['Option'])) {
                                                        setState(() {
                                                          selectedTags.remove(
                                                              x['Option']);
                                                        });
                                                      }
                                                    });
                                                  }
                                                  //Add new
                                                  setState(() {
                                                    selectedTags.add(widget
                                                            .product
                                                            .productOptions![i]
                                                            .priceOptions[x]
                                                        ['Option']);
                                                  });
                                                }

                                                if (widget
                                                            .product
                                                            .productOptions![i]
                                                            .priceStructure ==
                                                        'Aditional' &&
                                                    !selectedTags.contains(widget
                                                            .product
                                                            .productOptions![i]
                                                            .priceOptions[x]
                                                        ['Option'])) {
                                                  setState(() {
                                                    selectedPrice = selectedPrice +
                                                        widget
                                                                .product
                                                                .productOptions![i]
                                                                .priceOptions[x]
                                                            ['Price'];
                                                  });
                                                } else if (widget
                                                        .product
                                                        .productOptions![i]
                                                        .priceStructure ==
                                                    'Complete') {
                                                  setState(() {
                                                    basePrice = widget
                                                            .product
                                                            .productOptions![i]
                                                            .priceOptions[x]
                                                        ['Price'];
                                                  });
                                                }
                                              },
                                              child: Text(
                                                widget
                                                    .product
                                                    .productOptions![i]
                                                    .priceOptions[x]['Option'],
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                            ),
                                          );
                                        }),
                                      )),
                                ],
                              ),
                            );
                          }),

                  SizedBox(
                      height: (widget.product.productOptions!.length == 0)
                          ? 0
                          : 30),
                  //Quantity
                  Container(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        //Minus
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.grey.shade300),
                            overlayColor:
                                MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.hovered))
                                  return Colors.grey.shade500;
                                if (states.contains(MaterialState.focused) ||
                                    states.contains(MaterialState.pressed))
                                  return Colors.grey.shade500;
                                return null; // Defer to the widget's default.
                              },
                            ),
                          ),
                          onPressed: () {
                            if (quantity <= 0) {
                              //
                            } else {
                              setState(() {
                                quantity = quantity - 1;
                              });
                            }
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            child: Center(
                                child: Icon(Icons.remove,
                                    color: Colors.black, size: 16)),
                          ),
                        ),
                        //Quantity
                        Container(
                            height: 50,
                            width: 50,
                            color: Colors.white,
                            child: Center(
                                child: Text(
                              '$quantity',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ))),
                        //More
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.grey.shade300),
                            overlayColor:
                                MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.hovered))
                                  return Colors.grey.shade500;
                                if (states.contains(MaterialState.focused) ||
                                    states.contains(MaterialState.pressed))
                                  return Colors.grey.shade500;
                                return null; // Defer to the widget's default.
                              },
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              quantity = quantity + 1;
                            });
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            child: Center(
                                child: Icon(Icons.add,
                                    color: Colors.black, size: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  //Save Button
                  Container(
                    height: 40,
                    width: double.infinity,
                    child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.black),
                          overlayColor:
                              MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.hovered))
                                return Colors.grey.shade500;
                              if (states.contains(MaterialState.focused) ||
                                  states.contains(MaterialState.pressed))
                                return Colors.grey.shade500;
                              return null; // Defer to the widget's default.
                            },
                          ),
                        ),
                        onPressed: () {
                          // Update Cart
                          if (quantity > 0) {
                            bloc.addToCart({
                              'Name': widget.product.product,
                              'Category': widget.product.category,
                              'Price': totalAmount(basePrice, selectedTags),
                              'Quantity': quantity,
                              'Total Price':
                                  totalAmount(basePrice, selectedTags) *
                                      quantity,
                              'Options': selectedTags,
                              'Supplies': widget.product.ingredients,
                              'Product ID': widget.product.productID,
                              'Control Stock': widget.product.controlStock,
                            });
                          }
                          // Change Availability
                          if (changedAvailability) {
                            DatabaseService().updateProductAvailability(
                                widget.businessID,
                                widget.documentID,
                                isAvailable);
                          }
                          // Go Back
                          Navigator.of(context).pop();
                        },
                        child: Center(
                            child: Text(
                          'Guardar',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ))),
                  ),
                ],
              ),
            )));
  }
}
