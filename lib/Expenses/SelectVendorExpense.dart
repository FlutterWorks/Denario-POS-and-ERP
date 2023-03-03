import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Backend/Expense.dart';
import 'package:denario/Models/Supplier.dart';
import 'package:denario/Suppliers/SaveVendorButton.dart';
import 'package:denario/Suppliers/SupplierSearchBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SelectVendorExpense extends StatefulWidget {
  final DateTime selectedIvoiceDate;
  final String activeBusiness;
  final List dropdownCategories;
  final String costType;
  final setInvoiceReference;
  final setShowVendorTags;
  final bool showSearchOptions;
  final showVendorOptionsfromParent;
  final showVendorTagsfromParent;
  final bool saveVendor;
  final saveNewVendor;
  final String vendorName;

  const SelectVendorExpense(
      this.activeBusiness,
      this.selectedIvoiceDate,
      this.costType,
      this.dropdownCategories,
      this.setInvoiceReference,
      this.setShowVendorTags,
      this.showSearchOptions,
      this.showVendorOptionsfromParent,
      this.showVendorTagsfromParent,
      this.saveVendor,
      this.saveNewVendor,
      this.vendorName,
      {Key key})
      : super(key: key);

  @override
  State<SelectVendorExpense> createState() => _SelectVendorExpenseState();
}

class _SelectVendorExpenseState extends State<SelectVendorExpense> {
  final List<String> meses = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre'
  ];
  bool showList = true;

  //Vendor
  String vendorName;
  String selectedVendor = '';
  bool showSearchOptions = false;
  bool showListofVendors = false;
  TextEditingController searchController = new TextEditingController();
  String predefinedCategory;
  String predefinedDescription;
  Supplier selectedSupplier;
  bool saveVendor;
  bool saveVendorPressed;
  bool showVendorTags;
  String invoiceReference = '';

  void selectVendor(Supplier vendor) {
    setState(() {
      selectedVendor = vendor.name;
      vendorName = vendor.name;
      searchController.text = vendor.name;
      showSearchOptions = false;
      showListofVendors = false;
      predefinedCategory = vendor.predefinedCategory;
      predefinedDescription = vendor.initialExpenseDescription;
      selectedSupplier = vendor;
      saveVendor = false;
      saveVendorPressed = false;
      showVendorTags = false;
    });

    if (widget.costType != 'Costo de Ventas' &&
        bloc.expenseItems['Items'].length <= 1 &&
        vendor.predefinedAccount != null &&
        vendor.predefinedAccount != '' &&
        widget.dropdownCategories.contains(vendor.predefinedAccount)) {
      //Editar cuenta y descripcion de la primera linea
      bloc.editCategory(0, vendor.predefinedAccount);
      bloc.editProduct(0, vendor.initialExpenseDescription);
    }
    bloc.changeVendor(selectedVendor = vendor.name);
  }

  @override
  void initState() {
    showVendorTags = true;
    saveVendor = false;
    saveVendorPressed = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.vendorName != '') {
      searchController.text = widget.vendorName;
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Go back
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              child: Text(
                '${meses[widget.selectedIvoiceDate.month - 1]}, ${widget.selectedIvoiceDate.year}',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            Spacer(),
            //Title
            Container(
              width: 150,
              child: Text(
                "Registrar gasto",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Spacer(),
            //Go back
            Container(
              width: 150,
              alignment: Alignment(1.0, 0.0),
              child: IconButton(
                  onPressed: () {
                    setState(() {
                      showList = false;
                    });
                    bloc.removeAllFromExpense();
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close),
                  iconSize: 20.0),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        //Vendor
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Proveedor',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Colors.black45),
                  ),
                  SizedBox(height: 10),
                  //TextField
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 45,
                          child: TextFormField(
                            style: TextStyle(color: Colors.black, fontSize: 14),
                            cursorColor: Colors.grey,
                            controller: searchController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              suffixIcon: IconButton(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(2),
                                iconSize: 14,
                                splashRadius: 15,
                                onPressed: () {
                                  setState(() {
                                    showSearchOptions = false;
                                    showListofVendors = false;
                                    searchController.text = '';
                                    widget.setShowVendorTags(true);
                                    widget.showVendorTagsfromParent(true);
                                    bloc.changeVendor('');
                                  });
                                },
                                icon: Icon(Icons.close),
                                color: Colors.black,
                              ),
                              hintText: 'Buscar',
                              focusColor: Colors.black,
                              hintStyle: TextStyle(
                                  color: Colors.black45, fontSize: 14),
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
                            onTap: () {
                              widget.showVendorOptionsfromParent(true);
                            },
                            onChanged: (value) {
                              setState(() {
                                vendorName = value;
                                bloc.changeVendor(value);
                                if (value != '') {
                                  showSearchOptions = true;
                                  showListofVendors = false;
                                } else {
                                  showSearchOptions = false;
                                  showListofVendors = true;
                                }
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      (widget.saveVendor &&
                              vendorName != null &&
                              vendorName != '' &&
                              searchController.text != '')
                          ? StreamProvider<List<Supplier>>.value(
                              value: DatabaseService().suppliersList(
                                  widget.activeBusiness,
                                  vendorName.toLowerCase()),
                              initialData: null,
                              child: SaveVendorButton(
                                  vendorName, widget.saveNewVendor),
                            )
                          : SizedBox(),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: 20),
            //Reference
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'No. de referencia',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Colors.black45),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 50,
                    child: Center(
                      child: TextFormField(
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Colors.grey[700]),
                        inputFormatters: [LengthLimitingTextInputFormatter(25)],
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          hintText: 'No. Referencia',
                          label: Text(''),
                          labelStyle:
                              TextStyle(color: Colors.grey, fontSize: 12),
                          errorStyle: TextStyle(
                              color: Colors.redAccent[700], fontSize: 14),
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(12.0),
                            borderSide: new BorderSide(
                              color: Colors.grey,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(12.0),
                            borderSide: new BorderSide(
                              color: Colors.green,
                            ),
                          ),
                        ),
                        onChanged: (val) {
                          widget.setInvoiceReference(val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 5),
        // (showListofVendors)
        //     ? StreamProvider<List<Supplier>>.value(
        //         value: DatabaseService().suppliersListbyCategory(
        //             widget.activeBusiness, widget.costType),
        //         initialData: null,
        //         child: SupplierSearchBar(selectVendor),
        //       )
        // :
        (widget.showSearchOptions && showSearchOptions)
            ? StreamProvider<List<Supplier>>.value(
                value: DatabaseService().suppliersList(
                    widget.activeBusiness, vendorName.toLowerCase()),
                initialData: null,
                child: SupplierSearchBar(
                    selectVendor, widget.showVendorTagsfromParent),
              )
            : SizedBox(),

        SizedBox(height: 25),
      ],
    );
  }
}
