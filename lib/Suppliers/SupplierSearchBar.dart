import 'package:denario/Models/Supplier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SupplierSearchBar extends StatelessWidget {
  final selectVendor;
  final showVendorTagsfromParent;

  const SupplierSearchBar(this.selectVendor, this.showVendorTagsfromParent,
      {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final suppliers = Provider.of<List<Supplier>>(context);

    if (suppliers == null) {
      return Container();
    }

    if (suppliers.length < 1) {
      return SizedBox();
      // Container(
      //     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      //     width: 400,
      //     decoration: BoxDecoration(
      //       borderRadius: new BorderRadius.circular(12.0),
      //       color: Colors.white,
      //       boxShadow: <BoxShadow>[
      //         new BoxShadow(
      //           color: Colors.grey[350],
      //           offset: new Offset(0, 0),
      //           blurRadius: 10.0,
      //         )
      //       ],
      //     ),
      //     child: Text('No encontramos ninguno con este nombre'));
    }

    if (MediaQuery.of(context).size.width > 850) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        width:
            (MediaQuery.of(context).size.width > 650) ? 400 : double.infinity,
        // height: 200,
        constraints: BoxConstraints(maxHeight: 250),
        decoration: BoxDecoration(
          borderRadius: new BorderRadius.circular(12.0),
          color: Colors.white,
          boxShadow: <BoxShadow>[
            new BoxShadow(
              color: Colors.grey[350],
              offset: new Offset(0, 0),
              blurRadius: 10.0,
            )
          ],
        ),
        child: ListView.builder(
            itemCount: suppliers.length,
            shrinkWrap: true,
            itemBuilder: ((context, i) {
              return TextButton(
                  onPressed: () {
                    selectVendor(suppliers[i]);
                    if (showVendorTagsfromParent != null) {
                      showVendorTagsfromParent(false);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: double.infinity,
                      child: Text(
                        suppliers[i].name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        textAlign: TextAlign.start,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ));
            })),
      );
    } else {
      return ListView.builder(
          itemCount: suppliers.length,
          shrinkWrap: true,
          itemBuilder: ((context, i) {
            return TextButton(
                onPressed: () {
                  selectVendor(suppliers[i]);
                  if (showVendorTagsfromParent != null) {
                    showVendorTagsfromParent(false);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Text(
                        suppliers[i].name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        textAlign: TextAlign.start,
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ));
          }));
    }
  }
}
