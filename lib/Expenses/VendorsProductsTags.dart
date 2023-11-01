import 'package:denario/Models/Supplier.dart';
import 'package:denario/Models/Supply.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VendorProductsTags extends StatefulWidget {
  final Supplier? selectedVendor;
  final selectProduct;
  const VendorProductsTags(this.selectedVendor, this.selectProduct, {Key? key})
      : super(key: key);

  @override
  State<VendorProductsTags> createState() => _VendorProductsTagsState();
}

class _VendorProductsTagsState extends State<VendorProductsTags> {
  List selectedSupplies = [];

  @override
  Widget build(BuildContext context) {
    if (widget.selectedVendor == null) {
      return Container();
    }
    final supplies = Provider.of<List<Supply>>(context);

    if (supplies.length < 0) {
      return Container();
    }

    return Container(
        width: 500,
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 5,
          children: List.generate(supplies.length, (i) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        (selectedSupplies.contains(supplies[i].supply)
                            ? Colors.greenAccent
                            : Colors.white)),
                onPressed: () {
                  if (!selectedSupplies.contains(supplies[i].supply)) {
                    setState(() {
                      selectedSupplies.add(supplies[i].supply);
                      widget.selectProduct(widget.selectedVendor, supplies[i]);
                    });
                  } else {
                    setState(() {
                      selectedSupplies.remove(supplies[i].supply);
                    });
                  }
                },
                child: Text(
                  supplies[i].supply!,
                  style: TextStyle(color: Colors.black),
                ),
              ),
            );
          }),
        ));
  }
}
