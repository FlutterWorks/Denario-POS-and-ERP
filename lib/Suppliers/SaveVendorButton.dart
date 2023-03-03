import 'package:denario/Models/Supplier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SaveVendorButton extends StatefulWidget {
  final String vendorName;
  final saveNewVendor;
  const SaveVendorButton(this.vendorName, this.saveNewVendor, {Key key})
      : super(key: key);

  @override
  State<SaveVendorButton> createState() => _SaveVendorButtonState();
}

class _SaveVendorButtonState extends State<SaveVendorButton> {
  bool saveVendor;
  bool saveVendorPressed;
  bool vendorExists = false;

  @override
  void initState() {
    saveVendor = false;
    saveVendorPressed = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final suppliers = Provider.of<List<Supplier>>(context);

    if (suppliers == null) {
      return Container();
    }

    if (suppliers.length > 0) {
      for (var i = 0; i < suppliers.length; i++) {
        if (suppliers[i].name == widget.vendorName) {
          setState(() {
            vendorExists = true;
          });
        }
      }
    }

    if (vendorExists || widget.vendorName == '' || widget.vendorName == null) {
      return SizedBox();
    }

    return Container(
      height: 40,
      width: 40,
      child: Tooltip(
        message: 'Guardar proveedor',
        child: OutlinedButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  EdgeInsets.all(5)),
              backgroundColor: (saveVendorPressed)
                  ? MaterialStateProperty.all<Color>(Colors.greenAccent)
                  : MaterialStateProperty.all<Color>(Colors.white),
              side: MaterialStateProperty.all<BorderSide>(BorderSide(
                  color: Colors.grey, width: (saveVendorPressed) ? 0 : 1)),
              overlayColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.hovered))
                    return Colors.grey[300];
                  if (states.contains(MaterialState.focused) ||
                      states.contains(MaterialState.pressed))
                    return Colors.grey[300];
                  return null; // Defer to the widget's default.
                },
              ),
            ),
            onPressed: () {
              widget.saveNewVendor();
              setState(() {
                saveVendorPressed = !saveVendorPressed;
              });
            },
            child: Center(
              child: Icon(
                Icons.save_outlined,
                size: 18,
                color: Colors.black,
              ),
            )),
      ),
    );
  }
}
