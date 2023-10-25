import 'package:denario/Models/Supplier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VendorsTags extends StatefulWidget {
  final selectVendor;
  const VendorsTags(this.selectVendor, {Key? key}) : super(key: key);

  @override
  State<VendorsTags> createState() => _VendorsTagsState();
}

class _VendorsTagsState extends State<VendorsTags> {
  List selectedVendors = [];
  @override
  Widget build(BuildContext context) {
    final suppliers = Provider.of<List<Supplier>>(context);

    if (suppliers.length < 0) {
      return Container();
    }

    return Container(
        width: 500,
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 5,
          children: List.generate(suppliers.length, (i) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        (selectedVendors.contains(suppliers[i].name)
                            ? Colors.greenAccent
                            : Colors.white)),
                onPressed: () {
                  if (!selectedVendors.contains(suppliers[i].name)) {
                    setState(() {
                      selectedVendors.add(suppliers[i].name);
                      widget.selectVendor(suppliers[i]);
                    });
                  } else {
                    setState(() {
                      selectedVendors.remove(suppliers[i].name);
                    });
                  }
                },
                child: Text(
                  suppliers[i].name!,
                  style: TextStyle(color: Colors.black),
                ),
              ),
            );
          }),
        ));

    // return Tags(
    //     itemCount: suppliers.length,
    //     itemBuilder: (int i) {
    //       return Padding(
    //         padding: const EdgeInsets.all(5.0),
    //         child: ItemTags(
    //             borderRadius: BorderRadius.all(Radius.circular(12)),
    //             border: Border.all(color: Colors.grey[200]),
    //             padding: EdgeInsets.all(12),
    //             key: Key(i.toString()),
    //             index: i,
    //             title: suppliers[i].name,
    //             textColor: Colors.black,
    //             textActiveColor: Colors.black,
    //             color: Colors.white,
    //             activeColor: Colors.white,
    //             elevation: 1,
    //             onPressed: (item) {
    //               widget.selectVendor(suppliers[i]);
    //             }),
    //       );
    //     });
  }
}
