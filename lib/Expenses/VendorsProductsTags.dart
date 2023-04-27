import 'package:denario/Models/Supplier.dart';
import 'package:denario/Models/Supply.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:provider/provider.dart';

class VendorProductsTags extends StatelessWidget {
  final Supplier selectedVendor;
  final selectProduct;
  const VendorProductsTags(this.selectedVendor, this.selectProduct, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final supplies = Provider.of<List<Supply>>(context);

    if (supplies == null || supplies.length < 0) {
      return Container();
    }

    return Tags(
        itemCount: supplies.length,
        itemBuilder: (int i) {
          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: ItemTags(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                border: Border.all(color: Colors.grey[200]),
                padding: EdgeInsets.all(12),
                key: Key(i.toString()),
                index: i,
                title: supplies[i].supply,
                textColor: Colors.white,
                textActiveColor: Colors.black,
                color: Colors.greenAccent,
                activeColor: Colors.white,
                elevation: 1,
                onPressed: (item) {
                  if (!item.active) {
                    selectProduct(selectedVendor, supplies[i]);
                  }
                }),
          );
        });
  }
}
