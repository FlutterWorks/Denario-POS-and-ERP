import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Expenses/VendorsSelection.dart';
import 'package:denario/Models/Supplier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Backend/Expense.dart';

class VendorSearchBar extends StatefulWidget {
  final String activeBusiness;
  final String costType;
  final selectVendor;
  const VendorSearchBar(this.activeBusiness, this.costType, this.selectVendor,
      {Key key})
      : super(key: key);

  @override
  State<VendorSearchBar> createState() => _VendorSearchBarState();
}

class _VendorSearchBarState extends State<VendorSearchBar> {
  TextEditingController _mobileSearchController =
      TextEditingController(text: '');
  String vendorName = '';
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            //Back
            Container(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  //IconButton
                  IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: Colors.black,
                      )),
                ],
              ),
            ),
            SizedBox(height: 10),
            //Search
            Container(
              height: 50,
              width: double.infinity,
              child: TextFormField(
                key: Key('Mobile Search'),
                style: TextStyle(color: Colors.black, fontSize: 14),
                cursorColor: Colors.grey,
                controller: _mobileSearchController,
                textAlign: TextAlign.left,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  hintText: 'Buscar',
                  focusColor: Colors.black,
                  hintStyle: TextStyle(color: Colors.black45, fontSize: 14),
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(12.0),
                    borderSide: new BorderSide(
                      color: Colors.grey[350],
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(12.0),
                    borderSide: new BorderSide(
                      color: Colors.green,
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    vendorName = value;
                  });
                },
                onFieldSubmitted: (value) {
                  setState(() {
                    bloc.changeVendor(_mobileSearchController.text);
                  });
                  Navigator.of(context).pop();
                },
              ),
            ),
            SizedBox(height: 20),
            //Suggested or Search findings
            (vendorName == '')
                ? StreamProvider<List<Supplier>>.value(
                    value: DatabaseService().suppliersListbyCategory(
                        widget.activeBusiness, widget.costType),
                    initialData: null,
                    child: VendorsSelection(widget.selectVendor))
                : StreamProvider<List<Supplier>>.value(
                    value: DatabaseService().suppliersList(
                        widget.activeBusiness, vendorName.toLowerCase()),
                    initialData: null,
                    child: VendorsSelection(widget.selectVendor))
          ],
        ),
      ),
    );
  }
}
