import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Models/Supply.dart';
import 'package:denario/Supplies/NewSupply.dart';
import 'package:denario/Supplies/SuppliesList.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SuppliesDesk extends StatefulWidget {
  final String currentBusiness;
  final List categories;
  final String businessField;
  const SuppliesDesk(this.currentBusiness, this.categories, this.businessField,
      {Key key})
      : super(key: key);

  @override
  State<SuppliesDesk> createState() => _SuppliesDeskState();
}

class _SuppliesDeskState extends State<SuppliesDesk> {
  String name;
  String vendor;
  TextEditingController nameController = new TextEditingController(text: '');
  FocusNode nameNode;
  String selectedProduct;
  List searchName;
  String searchvendorName;
  bool filtered;
  List listOfCategories = [];
  String selectedVendor;
  bool showSearchOptions;
  bool showVendorSearchOptions;

  bool searchByVendor;
  int limitSearch;
  void loadMore() {
    setState(() {
      limitSearch = limitSearch + 10;
    });
  }

  void selectSupply(Supply supply) {
    setState(() {
      selectedProduct = supply.supply;
      nameController.text = supply.supply;
      searchName = supply.searchName;
      vendor = '';
      selectedVendor = null;
      showSearchOptions = false;
    });
  }

  @override
  void initState() {
    filtered = false;
    searchByVendor = false;
    showSearchOptions = false;
    name = '';
    listOfCategories = widget.categories;
    limitSearch = 10;
    if (!listOfCategories.contains('Todas las categorías')) {
      listOfCategories.add('Todas las categorías');
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: Colors.white,
          pinned: false,
          automaticallyImplyLeading: false,
          actions: <Widget>[Container()],
          expandedHeight:
              (MediaQuery.of(context).size.width > 1175) ? 150 : 200,
          flexibleSpace: FlexibleSpaceBar(
            background: Column(
              children: [
                //Title
                Container(
                  child: Text(
                    'Insumos',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 30),
                //Filter Box
                (MediaQuery.of(context).size.width > 1175)
                    ? Container(
                        height: 70,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: <BoxShadow>[
                            new BoxShadow(
                              color: Colors.grey[350],
                              offset: Offset(0.0, 0.0),
                              blurRadius: 10.0,
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            //Boton search for name/vendor
                            //Name
                            Container(
                              height: 45,
                              width: 100,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: searchByVendor
                                      ? Colors.white
                                      : Colors.greenAccent[400],
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        bottomLeft: Radius.circular(8)),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    searchByVendor = false;
                                  });
                                  nameNode.requestFocus();
                                },
                                child: Center(
                                    child: Text('Insumo',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: searchByVendor
                                              ? Colors.grey
                                              : Colors.white,
                                        ))),
                              ),
                            ),
                            //Vendor
                            Container(
                              width: 100,
                              height: 45,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: searchByVendor
                                      ? Colors.greenAccent[400]
                                      : Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(8),
                                        bottomRight: Radius.circular(8)),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    searchByVendor = true;
                                  });
                                  nameNode.requestFocus();
                                },
                                child: Center(
                                    child: Text('Proveedor',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: searchByVendor
                                              ? Colors.white
                                              : Colors.grey,
                                        ))),
                              ),
                            ),
                            SizedBox(width: 15),
                            //Nombre
                            Container(
                              width: 300,
                              height: 45,
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: TextFormField(
                                focusNode: nameNode,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 14),
                                cursorColor: Colors.grey,
                                controller: nameController,
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.all(2),
                                    iconSize: 14,
                                    splashRadius: 15,
                                    onPressed: () {
                                      setState(() {
                                        showSearchOptions = false;
                                        nameController.text = '';
                                        name = '';
                                        limitSearch = 10;
                                      });
                                    },
                                    icon: Icon(Icons.close),
                                    color: Colors.black,
                                  ),
                                  hintText: searchByVendor
                                      ? 'Buscar por proveedor'
                                      : 'Buscar por nombre',
                                  hintStyle: TextStyle(
                                      color: Colors.black45, fontSize: 14),
                                  border: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(12.0),
                                    borderSide: new BorderSide(
                                      color: Colors.grey[350],
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(12.0),
                                    borderSide: new BorderSide(
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    name = val.toLowerCase();
                                  });
                                },
                                onFieldSubmitted: ((value) {
                                  setState(() {
                                    name = value;
                                    nameController.text = value;
                                  });
                                }),
                              ),
                            ),
                            Spacer(),
                            //Boton de agregar
                            Container(
                              height: 45,
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.greenAccent[400]),
                                    overlayColor: MaterialStateProperty
                                        .resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                        if (states
                                            .contains(MaterialState.hovered))
                                          return Colors.greenAccent[300];
                                        if (states.contains(
                                                MaterialState.focused) ||
                                            states.contains(
                                                MaterialState.pressed))
                                          return Colors.lightGreenAccent;
                                        return null; // Defer to the widget's default.
                                      },
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => NewSupply(
                                                widget.currentBusiness, null)));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'Agregar Insumos',
                                          style: TextStyle(color: Colors.white),
                                        )
                                      ],
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        height: 120,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: <BoxShadow>[
                            new BoxShadow(
                              color: Colors.grey[350],
                              offset: Offset(0.0, 0.0),
                              blurRadius: 10.0,
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                //Boton search for name/vendor
                                //Name
                                Container(
                                  height: 45,
                                  width: 100,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: searchByVendor
                                          ? Colors.white
                                          : Colors.greenAccent[400],
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            bottomLeft: Radius.circular(8)),
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        searchByVendor = false;
                                      });
                                      nameNode.requestFocus();
                                    },
                                    child: Center(
                                        child: Text('Insumo',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: searchByVendor
                                                  ? Colors.grey
                                                  : Colors.white,
                                            ))),
                                  ),
                                ),
                                //Vendor
                                Container(
                                  width: 100,
                                  height: 45,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: searchByVendor
                                          ? Colors.greenAccent[400]
                                          : Colors.white,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(8),
                                            bottomRight: Radius.circular(8)),
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        searchByVendor = true;
                                      });
                                      nameNode.requestFocus();
                                    },
                                    child: Center(
                                        child: Text('Proveedor',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: searchByVendor
                                                  ? Colors.white
                                                  : Colors.grey,
                                            ))),
                                  ),
                                ),
                                SizedBox(width: 15),
                                //Nombre
                                Container(
                                  width: 300,
                                  height: 45,
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: TextFormField(
                                    focusNode: nameNode,
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 14),
                                    cursorColor: Colors.grey,
                                    controller: nameController,
                                    decoration: InputDecoration(
                                      suffixIcon: IconButton(
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.all(2),
                                        iconSize: 14,
                                        splashRadius: 15,
                                        onPressed: () {
                                          setState(() {
                                            showSearchOptions = false;
                                            nameController.text = '';
                                            name = '';
                                            limitSearch = 10;
                                          });
                                        },
                                        icon: Icon(Icons.close),
                                        color: Colors.black,
                                      ),
                                      hintText: searchByVendor
                                          ? 'Buscar por proveedor'
                                          : 'Buscar por nombre',
                                      hintStyle: TextStyle(
                                          color: Colors.black45, fontSize: 14),
                                      border: new OutlineInputBorder(
                                        borderRadius:
                                            new BorderRadius.circular(12.0),
                                        borderSide: new BorderSide(
                                          color: Colors.grey[350],
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            new BorderRadius.circular(12.0),
                                        borderSide: new BorderSide(
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                    onChanged: (val) {
                                      setState(() {
                                        name = val.toLowerCase();
                                      });
                                    },
                                    onFieldSubmitted: ((value) {
                                      setState(() {
                                        name = value;
                                        nameController.text = value;
                                      });
                                    }),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                //Boton de agregar
                                Container(
                                  height: 45,
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.greenAccent[400]),
                                        overlayColor: MaterialStateProperty
                                            .resolveWith<Color>(
                                          (Set<MaterialState> states) {
                                            if (states.contains(
                                                MaterialState.hovered))
                                              return Colors.greenAccent[300];
                                            if (states.contains(
                                                    MaterialState.focused) ||
                                                states.contains(
                                                    MaterialState.pressed))
                                              return Colors.lightGreenAccent;
                                            return null; // Defer to the widget's default.
                                          },
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => NewSupply(
                                                    widget.currentBusiness,
                                                    null)));
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 5),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              'Agregar Insumos',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            )
                                          ],
                                        ),
                                      )),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ),
        //Titles
        SliverAppBar(
          backgroundColor: Colors.white,
          pinned: true,
          automaticallyImplyLeading: false,
          actions: <Widget>[Container()],
          flexibleSpace: SizedBox(
            height: 40,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //Vendors
                  Container(
                      width: 150,
                      child: Text(
                        'Proveedor(es)',
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black54),
                      )),
                  //Nombre
                  Container(
                      width: 150,
                      child: Text(
                        'Insumo',
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black54),
                      )),
                  //QTY
                  Container(
                      width: 150,
                      child: Text(
                        'Cantidad',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black54),
                      )),
                  //Unit
                  Container(
                      width: 100,
                      child: Text(
                        'Unidad',
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black54),
                      )),
                  //Precio
                  Container(
                      width: 150,
                      child: Text(
                        'Precio',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black54),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                  //More Button
                  SizedBox(width: 35)
                ],
              ),
            ),
          ),
        ),
        //List of Products
        (searchByVendor && name != null && name != '')
            ? StreamProvider<List<Supply>>.value(
                initialData: null,
                value: DatabaseService()
                    .suppliesListbyVendor(widget.currentBusiness, name),
                child:
                    SuppliesList(widget.currentBusiness, loadMore, limitSearch))
            : (!searchByVendor && name != null && name != '')
                ? StreamProvider<List<Supply>>.value(
                    initialData: null,
                    value: DatabaseService()
                        .suppliesListbyName(widget.currentBusiness, name),
                    child: SuppliesList(
                        widget.currentBusiness, loadMore, limitSearch))
                : StreamProvider<List<Supply>>.value(
                    initialData: null,
                    value: DatabaseService()
                        .allSuppliesList(widget.currentBusiness, limitSearch),
                    child: SuppliesList(
                        widget.currentBusiness, loadMore, limitSearch))
      ],
    ));
  }
}
