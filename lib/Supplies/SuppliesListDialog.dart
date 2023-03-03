import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Models/Supply.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SuppliesListDialog extends StatefulWidget {
  final selectSupply;
  final String businessID;
  SuppliesListDialog(this.selectSupply, this.businessID, {Key key})
      : super(key: key);

  @override
  State<SuppliesListDialog> createState() => _SuppliesListDialogState();
}

class _SuppliesListDialogState extends State<SuppliesListDialog> {
  String name = '';
  int limitSearch;
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
            width: 600,
            height: MediaQuery.of(context).size.height * 0.65,
            padding: EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 20),
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
              (name == '' || name == null)
                  ? StreamProvider.value(
                      value: DatabaseService()
                          .allSuppliesList(widget.businessID, limitSearch),
                      initialData: null,
                      child: ListofSupplies(
                          widget.selectSupply, limitSearch, loadMore))
                  : StreamProvider.value(
                      value: DatabaseService()
                          .suppliesListbyName(widget.businessID, name),
                      initialData: null,
                      child: ListofSupplies(
                          widget.selectSupply, limitSearch, loadMore))
            ]),
          )),
    );
  }
}

class ListofSupplies extends StatelessWidget {
  final selectSupply;
  final loadMore;
  final int limitSearch;
  ListofSupplies(this.selectSupply, this.limitSearch, this.loadMore, {Key key})
      : super(key: key);

  final formatCurrency = new NumberFormat.simpleCurrency();

  @override
  Widget build(BuildContext context) {
    final supplies = Provider.of<List<Supply>>(context);

    if (supplies == null) {
      return Container();
    }

    return Expanded(
        child: (supplies == null)
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
            : (supplies.length > 0)
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: supplies.length + 1,
                    itemBuilder: (context, i) {
                      if (i < supplies.length) {
                        return TextButton(
                          onPressed: () {
                            selectSupply(supplies[i].supply, supplies[i].unit,
                                supplies[i].price, supplies[i].qty);
                            Navigator.of(context).pop();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  //Name
                                  Container(
                                    width: 150,
                                    child: Text(supplies[i].supply,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.black,
                                            overflow: TextOverflow.ellipsis)),
                                  ),
                                  //QTY
                                  Container(
                                    width: 100,
                                    child: Text(
                                      supplies[i].qty.toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.grey,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ),
                                  //Unit
                                  Container(
                                    width: 100,
                                    child: Text(
                                      supplies[i].unit,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.grey,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ),
                                  //Price
                                  Container(
                                    width: 150,
                                    child: Text(
                                      '${formatCurrency.format(supplies[i].price)}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.black,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ),
                                ]),
                          ),
                        );
                      } else if (supplies.length < limitSearch) {
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
                    child: Text('No hay insumos para mostrar'),
                  ));
  }
}
