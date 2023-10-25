import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Models/Supplier.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SuppliersListDialog extends StatefulWidget {
  final selectVendor;
  final String businessID;
  const SuppliersListDialog(this.selectVendor, this.businessID, {Key? key})
      : super(key: key);

  @override
  State<SuppliersListDialog> createState() => _SuppliersListDialogState();
}

class _SuppliersListDialogState extends State<SuppliersListDialog> {
  String name = '';
  late int limitSearch;
  void loadMore() {
    setState(() {
      limitSearch = limitSearch + 10;
    });
  }

  @override
  void initState() {
    limitSearch = 10;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          child: Container(
            width: (MediaQuery.of(context).size.width > 650)
                ? 600
                : MediaQuery.of(context).size.width,
            height: (MediaQuery.of(context).size.width > 650)
                ? MediaQuery.of(context).size.height * 0.65
                : (MediaQuery.of(context).size.height * 0.85),
            padding: EdgeInsets.all(20),
            child: Column(children: [
              //Go back
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //Search Bar
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      child: TextFormField(
                        autofocus: true,
                        style: TextStyle(color: Colors.black, fontSize: 14),
                        cursorColor: Colors.grey,
                        decoration: InputDecoration(
                          focusColor: Colors.black,
                          hintStyle:
                              TextStyle(color: Colors.black45, fontSize: 14),
                          errorStyle: TextStyle(
                              color: Colors.redAccent[700], fontSize: 12),
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(12.0),
                            borderSide: new BorderSide(
                              color: Colors.grey[350]!,
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
                            name = value;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  //Close
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.close),
                      iconSize: 20.0),
                ],
              ),
              Divider(
                indent: 1,
                endIndent: 1,
                color: Colors.grey,
                thickness: 0.5,
              ),
              SizedBox(height: 20),
              //List of  Suppliers
              (name != '')
                  ? StreamProvider<List<Supplier>>.value(
                      value: DatabaseService()
                          .suppliersList(widget.businessID, name.toLowerCase()),
                      initialData: [],
                      child: ListofSuppliers(
                          widget.selectVendor, limitSearch, loadMore))
                  : StreamProvider<List<Supplier>>.value(
                      value: DatabaseService()
                          .allSuppliersList(widget.businessID, limitSearch),
                      initialData: [],
                      child: ListofSuppliers(
                          widget.selectVendor, limitSearch, loadMore)),
            ]),
          )),
    );
  }
}

class ListofSuppliers extends StatelessWidget {
  final selectSupplier;
  final loadMore;
  final int limitSearch;
  ListofSuppliers(this.selectSupplier, this.limitSearch, this.loadMore,
      {Key? key})
      : super(key: key);

  final formatCurrency = new NumberFormat.simpleCurrency();

  @override
  Widget build(BuildContext context) {
    final supplier = Provider.of<List<Supplier>>(context);

    if (supplier == []) {
      return Container();
    }

    return Expanded(
        child: (supplier == [])
            ? ListView.builder(
                shrinkWrap: true,
                itemCount: 3,
                itemBuilder: (context, i) {
                  return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      child: Container(
                        width: double.infinity,
                        height: 35,
                        color: Colors.grey[300],
                      ));
                })
            : (supplier.length > 0)
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: supplier.length + 1,
                    itemBuilder: (context, i) {
                      if (i < supplier.length) {
                        if (MediaQuery.of(context).size.width > 650) {
                          return TextButton(
                            onPressed: () {
                              selectSupplier(supplier[i]);
                              Navigator.of(context).pop();
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15.0),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    //Name
                                    Container(
                                      width: 150,
                                      child: Text(supplier[i].name!,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.black,
                                              overflow: TextOverflow.ellipsis)),
                                    ),
                                    Spacer(),
                                    //Cost Type (from List)
                                    Container(
                                      width: 150,
                                      child: Text(
                                        (supplier[i]
                                                    .costTypeAssociated!
                                                    .length >
                                                0)
                                            ? supplier[i].costTypeAssociated![0]
                                            : 'Sin costo asociado',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.grey,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                    ),
                                    Spacer(),
                                    //Phone
                                    Container(
                                      width: 150,
                                      child: Text(
                                        (supplier[i].phone != 0)
                                            ? supplier[i].phone.toString()
                                            : 'Teléfono sin agregar',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.black,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                    ),
                                  ]),
                            ),
                          );
                        } else {
                          return TextButton(
                            onPressed: () {
                              selectSupplier(supplier[i]);
                              Navigator.of(context).pop();
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15.0),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    //Name
                                    Expanded(
                                      flex: 5,
                                      child: Container(
                                        child: Text(supplier[i].name!,
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                color: Colors.black,
                                                overflow:
                                                    TextOverflow.ellipsis)),
                                      ),
                                    ),
                                    SizedBox(width: 15),
                                    //Cost Type (from List)
                                    Expanded(
                                      flex: 5,
                                      child: Container(
                                        child: Text(
                                          (supplier[i]
                                                      .costTypeAssociated!
                                                      .length >
                                                  0)
                                              ? supplier[i]
                                                  .costTypeAssociated![0]
                                              : 'Sin costo asociado',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              color: Colors.grey,
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ),
                                    ),
                                  ]),
                            ),
                          );
                        }
                      } else if (supplier.length < limitSearch) {
                        return SizedBox();
                      } else {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Button load more
                              Container(
                                height: 30,
                                child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.black,
                                    ),
                                    onPressed: () {
                                      loadMore();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 5),
                                      child: Text(
                                        'Ver más',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        );
                      }
                    })
                : Center(
                    child: Text('No hay proveedores para mostrar'),
                  ));
  }
}
