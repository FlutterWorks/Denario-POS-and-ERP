import 'package:denario/Models/Supplier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:provider/provider.dart';

class VendorsTags extends StatelessWidget {
  final selectVendor;
  const VendorsTags(this.selectVendor, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final suppliers = Provider.of<List<Supplier>>(context);

    if (suppliers == null || suppliers.length < 0) {
      return Container();
    }

    return Tags(
        itemCount: suppliers.length,
        itemBuilder: (int i) {
          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: ItemTags(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                border: Border.all(color: Colors.grey),
                padding: EdgeInsets.all(12),
                key: Key(i.toString()),
                index: i,
                title: suppliers[i].name,
                textColor: Colors.black,
                textActiveColor: Colors.black,
                color: Colors.white,
                activeColor: Colors.white,
                onPressed: (item) {
                  selectVendor(suppliers[i]);
                }),
          );
        });
  }
}
