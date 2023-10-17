import 'package:denario/Models/Supply.dart';
import 'package:denario/Suppliers/SupplierProductCard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SupplierProducts extends StatelessWidget {
  final String businessID;
  const SupplierProducts(this.businessID, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<List<Supply>>(context);

    if (products == null) {
      return Container();
    }
    if (products.length < 1) {
      return Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 20.0),
        child: Text('No hay insumos de este proveedor'),
      );
    } else {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: products.length,
          physics: (MediaQuery.of(context).size.width > 650)
              ? BouncingScrollPhysics()
              : NeverScrollableScrollPhysics(),
          itemBuilder: ((context, index) {
            return SupplierProductCard(products[index], businessID);
          }));
    }
  }
}
