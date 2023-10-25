import 'package:denario/Models/Supplier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VendorsSelection extends StatelessWidget {
  final selectVendor;
  const VendorsSelection(this.selectVendor, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final suppliers = Provider.of<List<Supplier>>(context);

    if (suppliers.length < 0) {
      return Container();
    }

    return Expanded(
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: suppliers.length,
            itemBuilder: (context, i) {
              return Container(
                width: double.infinity,
                height: 50,
                child: TextButton(
                    onPressed: () {
                      selectVendor(suppliers[i]);
                      Navigator.of(context).pop();
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      overlayColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.hovered))
                            return Colors.black12;
                          if (states.contains(MaterialState.focused) ||
                              states.contains(MaterialState.pressed))
                            return Colors.black26;
                          return Colors
                              .black26; // Defer to the widget's default.
                        },
                      ),
                    ),
                    child: Text(
                      suppliers[i].name!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.black),
                    )),
              );
            }));
  }
}
