import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Models/Categories.dart';
import 'package:denario/Models/Mapping.dart';
import 'package:denario/Models/Payables.dart';
import 'package:denario/Models/Supplier.dart';
import 'package:denario/Models/Supply.dart';
import 'package:denario/Suppliers/SupplierData.dart';
import 'package:denario/Suppliers/SupplierPendingInvoices.dart';
import 'package:denario/Suppliers/SupplierProducts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SupplierDetails extends StatefulWidget {
  final String currentBusiness;
  final String selectedVendor;
  final CategoryList categoriesProvider;
  final HighLevelMapping highLevelMapping;
  const SupplierDetails(this.selectedVendor, this.currentBusiness,
      this.categoriesProvider, this.highLevelMapping,
      {Key key})
      : super(key: key);

  @override
  State<SupplierDetails> createState() => _SupplierDetailsState();
}

class _SupplierDetailsState extends State<SupplierDetails> {
  @override
  Widget build(BuildContext context) {
    if (widget.selectedVendor == '' || widget.selectedVendor == null) {
      return Container();
    }

    final vendor = Provider.of<Supplier>(context);

    if (vendor == null) {
      return Container();
    }

    if (MediaQuery.of(context).size.width > 850) {
      return Container(
        width: double.infinity,
        // color: Colors.red,
        padding: EdgeInsets.only(bottom: 15, left: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //About //=> On button 'Edit' make text field
            Expanded(
                flex: 5,
                child: Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: new BorderRadius.circular(12.0),
                      boxShadow: <BoxShadow>[
                        new BoxShadow(
                          color: Colors.grey[350],
                          offset: Offset(0.0, 0.0),
                          blurRadius: 10.0,
                        )
                      ],
                    ),
                    child: SupplierData(widget.currentBusiness, vendor,
                        widget.categoriesProvider, widget.highLevelMapping))),
            SizedBox(width: 20),
            //Products and Pending
            Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Invoices
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: new BorderRadius.circular(12.0),
                          boxShadow: <BoxShadow>[
                            new BoxShadow(
                              color: Colors.grey[350],
                              offset: Offset(0.0, 0.0),
                              blurRadius: 10.0,
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            //Title
                            Text(
                              'Pendientes',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            StreamProvider<List<Payables>>.value(
                                initialData: null,
                                value: DatabaseService().payablesListbyVendor(
                                    widget.currentBusiness, vendor.name),
                                child: SupplierPendingInvoices(
                                    widget.currentBusiness))
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      //Productos
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: new BorderRadius.circular(12.0),
                          boxShadow: <BoxShadow>[
                            new BoxShadow(
                              color: Colors.grey[350],
                              offset: Offset(0.0, 0.0),
                              blurRadius: 10.0,
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            //Title
                            Text(
                              'Productos',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            StreamProvider<List<Supply>>.value(
                                initialData: null,
                                value: DatabaseService().suppliesListbyVendor(
                                    widget.currentBusiness,
                                    vendor.name.toLowerCase()),
                                child: SupplierProducts(widget.currentBusiness))
                          ],
                        ),
                      )
                    ],
                  ),
                ))
          ],
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        // color: Colors.red,
        padding: EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //About //=> On button 'Edit' make text field
            Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: new BorderRadius.circular(12.0),
                  boxShadow: <BoxShadow>[
                    new BoxShadow(
                      color: Colors.grey[350],
                      offset: Offset(0.0, 0.0),
                      blurRadius: 10.0,
                    )
                  ],
                ),
                child: SupplierData(widget.currentBusiness, vendor,
                    widget.categoriesProvider, widget.highLevelMapping)),
            SizedBox(height: 20),
            //Invoices
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: new BorderRadius.circular(12.0),
                boxShadow: <BoxShadow>[
                  new BoxShadow(
                    color: Colors.grey[350],
                    offset: Offset(0.0, 0.0),
                    blurRadius: 10.0,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //Title
                  Text(
                    'Pendientes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  StreamProvider<List<Payables>>.value(
                      initialData: null,
                      value: DatabaseService().payablesListbyVendor(
                          widget.currentBusiness, vendor.name),
                      child: SupplierPendingInvoices(widget.currentBusiness))
                ],
              ),
            ),
            SizedBox(height: 20),
            //Productos
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: new BorderRadius.circular(12.0),
                boxShadow: <BoxShadow>[
                  new BoxShadow(
                    color: Colors.grey[350],
                    offset: Offset(0.0, 0.0),
                    blurRadius: 10.0,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //Title
                  Text(
                    'Productos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  StreamProvider<List<Supply>>.value(
                      initialData: null,
                      value: DatabaseService().suppliesListbyVendor(
                          widget.currentBusiness, vendor.name.toLowerCase()),
                      child: SupplierProducts(widget.currentBusiness))
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
