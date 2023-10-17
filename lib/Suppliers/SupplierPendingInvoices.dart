import 'package:denario/Models/Payables.dart';
import 'package:denario/Suppliers/SupplierInvoiceCard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SupplierPendingInvoices extends StatelessWidget {
  final String businessID;
  const SupplierPendingInvoices(this.businessID, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final invoices = Provider.of<List<Payables>>(context);

    if (invoices == null) {
      return Container();
    }
    if (invoices.length < 1) {
      return Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 20.0),
        child: Text('No hay facturas pendientes de este proveedor'),
      );
    } else {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: invoices.length,
          physics: (MediaQuery.of(context).size.width > 650)
              ? BouncingScrollPhysics()
              : NeverScrollableScrollPhysics(),
          itemBuilder: ((context, index) {
            return SupplierIvoiceCard(invoices[index], businessID);
          }));
    }
  }
}
