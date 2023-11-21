import 'package:denario/Models/Products.dart';
import 'package:denario/Products/NewProduct.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProductList extends StatelessWidget {
  final String businessID;
  final List categories;
  final String businessField;
  final loadMore;
  final int limitSearch;
  ProductList(this.businessID, this.categories, this.businessField,
      this.loadMore, this.limitSearch);

  final formatCurrency = new NumberFormat.simpleCurrency();

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<List<Products>>(context);

    if (products == []) {
      return SliverList(
          delegate: SliverChildBuilderDelegate((context, i) {
        return const SizedBox();
      }, childCount: 1));
    }

    if (products.length == 0) {
      return SliverList(
          delegate: SliverChildBuilderDelegate((context, i) {
        return const SizedBox();
      }, childCount: 1));
    }

    return SliverList(
        delegate: SliverChildBuilderDelegate(
      (context, i) {
        if (i < products.length) {
          double totalCost = 0;
          List ingredients = products[i].ingredients!;
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

          if (MediaQuery.of(context).size.width > 900) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NewProduct(businessID,
                              categories, businessField, products[i])));
                },
                child: Container(
                  width: double.infinity,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //Imagen
                      (products[i].image != '')
                          ? Container(
                              height: 75,
                              width: 75,
                              decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25)),
                                  color: Colors.grey.shade300,
                                  image: DecorationImage(
                                      image: NetworkImage(products[i].image!),
                                      fit: BoxFit.cover)))
                          : Container(
                              height: 75,
                              width: 75,
                              decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25)),
                                  color: Colors.grey.shade300)),
                      //Nombre
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          (MediaQuery.of(context).size.width <= 800)
                              ? Container(
                                  width: 150,
                                  child: Text(
                                    products[i].code!,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black54),
                                  ))
                              : SizedBox(),
                          (MediaQuery.of(context).size.width <= 800)
                              ? SizedBox(height: 5)
                              : SizedBox(),
                          Container(
                              width: 150,
                              child: Text(
                                products[i].product!,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              )),
                          SizedBox(height: 5),
                          Container(
                              width: 150,
                              child: Text(
                                products[i].category ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 11),
                              ))
                        ],
                      ),
                      //Código
                      (MediaQuery.of(context).size.width > 800)
                          ? Container(
                              width: 100,
                              child: Text(
                                products[i].code ?? '',
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black54),
                              ))
                          : SizedBox(),

                      //Stock
                      Container(
                          width: 150,
                          child: Text(
                            '${products[i].currentStock}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black),
                          )),

                      //Precio
                      (products[i].priceType == 'Precio por margen')
                          ? Container(
                              width: 150,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '${products[i].price!}%',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey,
                                        fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    '${formatCurrency.format(totalCost + (totalCost * (products[i].price! / 100)))}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ))
                          : Container(
                              width: 150,
                              child: Text(
                                '${formatCurrency.format(products[i].price)}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )),
                      //Costo
                      (MediaQuery.of(context).size.width > 850)
                          ? Container(
                              width: 150,
                              child: Text(
                                '${formatCurrency.format(totalCost)}',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.redAccent[700]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ))
                          : Container(
                              width: 150,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  //Cost
                                  Text(
                                    '${formatCurrency.format(totalCost)}',
                                    textAlign: TextAlign.center,
                                    style:
                                        TextStyle(color: Colors.redAccent[700]),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 5),
                                  //Margin
                                  Text(
                                    (products[i].priceType ==
                                            'Precio por margen')
                                        ? '(${((((totalCost + (totalCost * (products[i].price! / 100))) - totalCost) / (totalCost + (totalCost * (products[i].price! / 100)))) * 100).toStringAsFixed(0)}%)'
                                        : '(${(((products[i].price! - totalCost) / products[i].price!) * 100).toStringAsFixed(0)}%)',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: ((((products[i].price! -
                                                            totalCost) /
                                                        products[i].price!) *
                                                    100) >
                                                products[i].lowMarginAlert!)
                                            ? Colors.black54
                                            : Colors.redAccent[700]),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                ],
                              )),
                      //Margin
                      (MediaQuery.of(context).size.width > 850)
                          ? Container(
                              width: 100,
                              child: Text(
                                (products[i].priceType == 'Precio por margen')
                                    ? '(${((((totalCost + (totalCost * (products[i].price! / 100))) - totalCost) / (totalCost + (totalCost * (products[i].price! / 100)))) * 100).toStringAsFixed(0)}%)'
                                    : '(${(((products[i].price! - totalCost) / products[i].price!) * 100).toStringAsFixed(0)}%)',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ((((products[i].price! - totalCost) /
                                                    products[i].price!) *
                                                100) >
                                            products[i].lowMarginAlert!)
                                        ? Colors.black54
                                        : Colors.redAccent[700]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ))
                          : SizedBox()
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NewProduct(businessID,
                              categories, businessField, products[i])));
                },
                child: Container(
                  width: double.infinity,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //Imagen
                      (products[i].image != '')
                          ? Container(
                              height: 75,
                              width: 75,
                              decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25)),
                                  color: Colors.grey.shade300,
                                  image: DecorationImage(
                                      image: NetworkImage(products[i].image!),
                                      fit: BoxFit.cover)))
                          : Container(
                              height: 75,
                              width: 75,
                              decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25)),
                                  color: Colors.grey.shade300)),
                      SizedBox(width: 15),
                      //Nombre
                      Expanded(
                        flex: 5,
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              (products[i].code != '')
                                  ? Container(
                                      width: 150,
                                      child: Text(
                                        products[i].code!,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black54),
                                      ))
                                  : SizedBox(),
                              SizedBox(
                                  height: (products[i].code != '') ? 5 : 0),
                              Container(
                                  width: 150,
                                  child: Text(
                                    products[i].product!,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  )),
                              SizedBox(height: 5),
                              Container(
                                  width: 150,
                                  child: Text(
                                    products[i].category!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 11),
                                  ))
                            ],
                          ),
                        ),
                      ),
                      //Stock
                      (products[i].controlStock!)
                          ? Expanded(
                              flex: 2,
                              child: Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                        child: Text(
                                      'Stock',
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 11),
                                    )),
                                    SizedBox(height: 5),
                                    Container(
                                        child: Text(
                                      '${products[i].currentStock!}',
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    )),
                                  ],
                                ),
                              ),
                            )
                          : SizedBox(),
                      //Precio
                      Expanded(
                        flex: 2,
                        child: Container(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              (products[i].priceType == 'Precio por margen')
                                  ? '${formatCurrency.format(totalCost + (totalCost * (products[i].price! / 100)))}'
                                  : '${formatCurrency.format(products[i].price)}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                //Cost
                                Text(
                                  '${formatCurrency.format(totalCost)}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.redAccent[700],
                                      fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(width: 5),
                                //Margin
                                Text(
                                  (products[i].priceType == 'Precio por margen')
                                      ? '(${((((totalCost + (totalCost * (products[i].price! / 100))) - totalCost) / (totalCost + (totalCost * (products[i].price! / 100)))) * 100).toStringAsFixed(0)}%)'
                                      : '(${(((products[i].price! - totalCost) / products[i].price!) * 100).toStringAsFixed(0)}%)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color:
                                          ((((products[i].price! - totalCost) /
                                                          products[i].price!) *
                                                      100) >
                                                  products[i].lowMarginAlert!)
                                              ? Colors.black54
                                              : Colors.redAccent[700]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            )
                          ],
                        )),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        } else if (products.length < limitSearch) {
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
      childCount: products.length + 1,
    ));
  }
}
