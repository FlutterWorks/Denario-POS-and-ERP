import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Backend/Expense.dart';
import 'package:denario/Models/Supplier.dart';
import 'package:denario/Suppliers/SaveVendorButton.dart';
import 'package:denario/Suppliers/SupplierSearchBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart';

class SelectVendorExpense extends StatefulWidget {
  final selectIvoiceDate;
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
      this.selectIvoiceDate,
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
  DateTime selectedIvoiceDate;

  //Vendor
  String vendorName = '';
  String selectedVendor = '';
  bool showSearchOptions = false;
  bool showListofVendors = false;
  TextEditingController searchController = TextEditingController(text: '');
  TextEditingController _newController = TextEditingController(text: '');
  String predefinedCategory;
  String predefinedDescription;
  Supplier selectedSupplier;
  bool saveVendor;
  bool saveVendorPressed;
  bool showVendorTags;
  String invoiceReference = '';
  bool keepTaggedVendor;
  String taggedVendor;

  void selectVendor(Supplier vendor) {
    setState(() {
      selectedVendor = vendor.name;
      vendorName = vendor.name;
      _newController.text = vendor.name;
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
    keepTaggedVendor = true;
    selectedIvoiceDate = DateTime.now();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width > 650) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Go back
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${meses[selectedIvoiceDate.month - 1]}, ${selectedIvoiceDate.year}',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(width: 5),
              Container(
                height: 20,
                width: 20,
                child: IconButton(
                  splashRadius: 1,
                  onPressed: () async {
                    DateTime pickedDate = await showDatePicker(
                        context: context,
                        helpText: 'Fecha del gasto',
                        confirmText: 'Guardar',
                        cancelText: 'Cancelar',
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now().subtract(Duration(days: 60)),
                        lastDate: DateTime.now(),
                        builder: ((context, child) {
                          return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary:
                                      Colors.black, // header background color
                                  onPrimary: Colors.white, // header text color
                                  onSurface: Colors.black, // body text color
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        Colors.black, // button text color
                                  ),
                                ),
                              ),
                              child: child);
                        }));
                    setState(() {
                      if (pickedDate != null) {
                        selectedIvoiceDate = pickedDate;
                        widget.selectIvoiceDate(pickedDate);
                      }
                    });
                  },
                  padding: EdgeInsets.all(0),
                  tooltip: 'Seleccionar fecha del gasto',
                  iconSize: 18,
                  icon: Icon(Icons.calendar_month),
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
                    (bloc.expenseItems['Vendor'] != '')
                        ? Row(
                            children: [
                              Text(
                                bloc.expenseItems['Vendor'],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              SizedBox(width: 10),
                              IconButton(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(2),
                                iconSize: 14,
                                splashRadius: 15,
                                onPressed: () {
                                  setState(() {
                                    vendorName = '';
                                    showSearchOptions = true;
                                    showListofVendors = false;
                                    _newController.text = '';
                                    widget.setShowVendorTags(true);
                                    widget.showVendorTagsfromParent(true);
                                    widget.showVendorOptionsfromParent(true);
                                    bloc.changeVendor('');
                                  });
                                },
                                icon: Icon(Icons.close),
                                color: Colors.black,
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 45,
                                  child: TextFormField(
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 14),
                                    cursorColor: Colors.grey,
                                    controller:
                                        _newController, //searchController,
                                    textAlign: TextAlign.left,
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
                                            vendorName = '';
                                            showSearchOptions = true;
                                            showListofVendors = false;
                                            _newController.text = '';
                                            widget.setShowVendorTags(true);
                                            widget
                                                .showVendorTagsfromParent(true);
                                            widget.showVendorOptionsfromParent(
                                                true);
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
                                    onTap: () {
                                      widget.setShowVendorTags(true);
                                      widget.showVendorTagsfromParent(true);
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        if (value.isNotEmpty) {
                                          showSearchOptions = true;
                                          showListofVendors = false;
                                          widget.showVendorOptionsfromParent(
                                              true);
                                        } else {
                                          showSearchOptions = false;
                                          showListofVendors = true;
                                        }
                                        vendorName = value;
                                      });
                                    },
                                    onFieldSubmitted: (value) {
                                      setState(() {
                                        bloc.changeVendor(_newController.text);
                                        showSearchOptions = false;
                                        showListofVendors = true;
                                        widget
                                            .showVendorOptionsfromParent(false);
                                        widget.setShowVendorTags(false);
                                      });
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              (widget.saveVendor &&
                                      vendorName != null &&
                                      vendorName != '' &&
                                      _newController.text.isNotEmpty)
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
                          )
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
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(25)
                          ],
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
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Go back
          Container(
            width: double.infinity,
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              //Back
              IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.arrow_back)),
              SizedBox(width: 15),
              Text(
                'Registrar gasto',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
            ]),
          ),
          SizedBox(
            height: 10,
          ),
          //Month
          Container(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () async {
                    DateTime pickedDate = await showDatePicker(
                        context: context,
                        helpText: 'Fecha del gasto',
                        confirmText: 'Guardar',
                        cancelText: 'Cancelar',
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now().subtract(Duration(days: 60)),
                        lastDate: DateTime.now(),
                        builder: ((context, child) {
                          return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary:
                                      Colors.black, // header background color
                                  onPrimary: Colors.white, // header text color
                                  onSurface: Colors.black, // body text color
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        Colors.black, // button text color
                                  ),
                                ),
                              ),
                              child: child);
                        }));
                    setState(() {
                      if (pickedDate != null) {
                        selectedIvoiceDate = pickedDate;
                        widget.selectIvoiceDate(pickedDate);
                      }
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: 18,
                        color: Colors.black,
                      ),
                      SizedBox(width: 5),
                      Text(
                        '${meses[selectedIvoiceDate.month - 1]}, ${selectedIvoiceDate.year}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
          //Reference
          Text(
            'No. de referencia',
            textAlign: TextAlign.start,
            style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: Colors.black45),
          ),
          SizedBox(height: 8),
          Container(
            height: 50,
            width: double.infinity,
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
                  labelStyle: TextStyle(color: Colors.grey, fontSize: 12),
                  errorStyle:
                      TextStyle(color: Colors.redAccent[700], fontSize: 14),
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
          SizedBox(height: 15),
          //Vendor
          Text(
            'Proveedor',
            textAlign: TextAlign.start,
            style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: Colors.black45),
          ),
          SizedBox(height: 8),
          (bloc.expenseItems['Vendor'] != '')
              ? Container(
                  height: 50,
                  width: double.infinity,
                  child: Row(
                    children: [
                      Text(
                        bloc.expenseItems['Vendor'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(width: 10),
                      IconButton(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(2),
                        iconSize: 14,
                        splashRadius: 15,
                        onPressed: () {
                          setState(() {
                            vendorName = '';
                            showSearchOptions = true;
                            showListofVendors = false;
                            _newController.text = '';
                            widget.setShowVendorTags(true);
                            widget.showVendorTagsfromParent(true);
                            widget.showVendorOptionsfromParent(true);
                            bloc.changeVendor('');
                          });
                        },
                        icon: Icon(Icons.close),
                        color: Colors.black,
                      ),
                    ],
                  ),
                )
              : Container(
                  height: 50,
                  width: double.infinity,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 45,
                          child: TextFormField(
                            style: TextStyle(color: Colors.black, fontSize: 14),
                            cursorColor: Colors.grey,
                            controller: _newController, //searchController,
                            textAlign: TextAlign.left,
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
                                    vendorName = '';
                                    showSearchOptions = true;
                                    showListofVendors = false;
                                    _newController.text = '';
                                    widget.setShowVendorTags(true);
                                    widget.showVendorTagsfromParent(true);
                                    widget.showVendorOptionsfromParent(true);
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
                              widget.setShowVendorTags(true);
                              widget.showVendorTagsfromParent(true);
                            },
                            onChanged: (value) {
                              setState(() {
                                if (value.isNotEmpty) {
                                  showSearchOptions = true;
                                  showListofVendors = false;
                                  widget.showVendorOptionsfromParent(true);
                                } else {
                                  showSearchOptions = false;
                                  showListofVendors = true;
                                }
                                vendorName = value;
                              });
                            },
                            onFieldSubmitted: (value) {
                              setState(() {
                                bloc.changeVendor(_newController.text);
                                showSearchOptions = false;
                                showListofVendors = true;
                                widget.showVendorOptionsfromParent(false);
                                widget.setShowVendorTags(false);
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      (widget.saveVendor &&
                              vendorName != null &&
                              vendorName != '' &&
                              _newController.text.isNotEmpty)
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
                ),
          SizedBox(height: 5),
          //Lookup
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
}
