import 'dart:math';

import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Models/Products.dart';
import 'package:denario/Products/ProductOptionsDialog.dart';
import 'package:denario/Supplies/SuppliesListDialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class NewProduct extends StatefulWidget {
  final String activeBusiness;
  final List categories;
  final String businessField;
  final Products? product;
  const NewProduct(
      this.activeBusiness, this.categories, this.businessField, this.product,
      {Key? key})
      : super(key: key);

  @override
  State<NewProduct> createState() => _NewProductState();
}

class _NewProductState extends State<NewProduct> {
  final _formKey = GlobalKey<FormState>();
  final formatCurrency = new NumberFormat.simpleCurrency();

  String name = '';
  String code = '';
  double price = 0;
  String description = '';
  String category = '';
  late bool isAvailable;
  late bool show;
  late bool vegan;
  late bool newProduct;
  late List historicPrices;
  List listOfIngredients = [];
  bool featured = false;

  void setProductOptions(
      bool editProduct,
      String optionTitle,
      bool mandadory,
      bool multipleOptions,
      String priceStructure,
      List priceOptions,
      int index) {
    if (editProduct) {
      setState(() {
        productOptions.removeAt(index);
        productOptions.insert(index, {
          'Title': optionTitle,
          'Mandatory': mandadory,
          'Multiple Options': multipleOptions,
          'Price Structure': priceStructure,
          'Price Options': priceOptions
        });
      });
    } else {
      setState(() {
        productOptions.add({
          'Title': optionTitle,
          'Mandatory': mandadory,
          'Multiple Options': multipleOptions,
          'Price Structure': priceStructure,
          'Price Options': priceOptions
        });
      });
    }
  }

  void selectSupply(
      String supply, String unit, double supplyCost, double supplyQty) {
    for (var x = 0; x < 2; x++) {
      _controllers.add(new TextEditingController());
    }
    setState(() {
      ingredients.add({
        'Ingredient': supply,
        'Quantity': 0,
        'Yield': 0,
        'Unit': unit,
        'Supply Cost': supplyCost,
        'Supply Quantity': supplyQty
      });
    });
  }

  //List of ingredients
  List ingredients = [];
  ValueKey redrawObject = ValueKey('List');
  List<TextEditingController> _controllers = [];
  Map ingredientsCostList = {};
  double totalIngredientsCost() {
    double totalCost = 0;
    for (int i = 0; i < ingredients.length; i++) {
      double ingredientTotal =
          ((ingredients[i]['Supply Cost'] / ingredients[i]['Supply Quantity']) *
                  ingredients[i]['Quantity']) /
              ingredients[i]['Yield'];
      if (!ingredientTotal.isNaN &&
          !ingredientTotal.isInfinite &&
          !ingredientTotal.isNegative) {
        totalCost = totalCost + ingredientTotal;
      }
    }
    return totalCost;
  }

  double? expectedMargin;
  double? lowMarginAlert;

  //List of product Options
  List productOptions = [];
  ValueKey redrawObject2 = ValueKey('List2');

  //Lista de letras del nombre
  setSearchParam(String caseNumber) {
    List<String> caseSearchList = [];
    String temp = "";
    for (int i = 0; i < caseNumber.length; i++) {
      temp = temp + caseNumber[i];
      caseSearchList.add(temp);
    }
    return caseSearchList;
  }

  //Image select and upload to storage
  String image = '';
  Uint8List webImage = Uint8List(8);
  String? downloadUrl;
  bool changedImage = false;
  Future getImage() async {
    XFile? selectedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    Uint8List uploadFile = await selectedImage!.readAsBytes();
    setState(() {
      webImage = uploadFile;
      changedImage = true;
    });
  }

  Future uploadPic(businessID) async {
    ////Upload to Clod Storage

    String fileName = 'Product Images/' + businessID + '/' + name + '.png';
    var ref = FirebaseStorage.instance.ref().child(fileName);

    TaskSnapshot uploadTask = await ref.putData(webImage);

    ///Save to Firestore
    if (uploadTask.state == TaskState.success) {
      downloadUrl = await uploadTask.ref.getDownloadURL();
    }
  }

  @override
  void initState() {
    if (widget.product != null) {
      newProduct = false;
      category = widget.product!.category ?? '';
      isAvailable = widget.product!.available ?? false;
      show = widget.product!.showOnMenu ?? false;
      vegan = widget.product!.vegan ?? false;
      name = widget.product!.product!;
      price = widget.product!.price!;
      code = widget.product!.code ?? '';
      description = widget.product!.description ?? '';
      image = widget.product!.image ?? '';
      ingredients = widget.product!.ingredients ?? [];
      historicPrices = widget.product!.historicPrices ?? [];
      featured = widget.product!.featured ?? false;
      expectedMargin = widget.product!.expectedMargin ?? 0;
      lowMarginAlert = widget.product!.lowMarginAlert ?? 0;
      if (widget.product!.productOptions!.length > 0) {
        for (var x = 0; x < widget.product!.productOptions!.length; x++) {
          productOptions.add({
            'Mandatory': widget.product!.productOptions![x].mandatory,
            'Multiple Options':
                widget.product!.productOptions![x].multipleOptions,
            'Price Structure':
                widget.product!.productOptions![x].priceStructure,
            'Title': widget.product!.productOptions![x].title,
            'Price Options': widget.product!.productOptions![x].priceOptions
          });
        }
      } else {
        productOptions = [];
      }
    } else {
      newProduct = true;
      category = widget.categories.first;
      isAvailable = true;
      show = true;
      featured = false;
      vegan = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width > 800) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //Title
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.arrow_back),
                    iconSize: 20.0),
                SizedBox(width: 25),
                Text(
                  widget.product == null ? 'Nuevo producto' : 'Editar producto',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28),
                ),
              ],
            ),
            SizedBox(height: 35),
            //Form
            (MediaQuery.of(context).size.width > 1050)
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 15),
                      //Image
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: <BoxShadow>[
                              new BoxShadow(
                                color: Colors.grey[350]!,
                                offset: new Offset(0, 0),
                                blurRadius: 10.0,
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              //Text
                              Text(
                                'Imagen',
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: Colors.black45),
                              ),
                              SizedBox(height: 10),
                              //Image
                              (changedImage)
                                  ? Container(
                                      width: double.infinity,
                                      height: 150,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(25)),
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          color: Colors.grey,
                                          image: DecorationImage(
                                              image: Image.memory(
                                                webImage,
                                                fit: BoxFit.cover,
                                              ).image,
                                              fit: BoxFit.cover)))
                                  : (!newProduct && image != '')
                                      ? Container(
                                          width: double.infinity,
                                          height: 150,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(25)),
                                              border: Border.all(
                                                  color: Colors.grey.shade300),
                                              color: Colors.grey.shade200,
                                              image: DecorationImage(
                                                  image: NetworkImage(
                                                      widget.product!.image!),
                                                  fit: BoxFit.cover)),
                                        )
                                      : Container(
                                          width: double.infinity,
                                          height: 150,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(25)),
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                            color: Colors.grey.shade200,
                                          ),
                                          child: Center(
                                            child: Icon(Icons.add_a_photo,
                                                color: Colors.grey),
                                          ),
                                        ),

                              SizedBox(height: 20),
                              TextButton(
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.black),
                                onPressed: getImage,
                                child: Container(
                                  height: 35,
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2.0, horizontal: 2),
                                  child: Center(
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.edit,
                                            color: Colors.black,
                                            size: 12,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            'Editar imagen',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ]),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 35),
                      //Main Data
                      Expanded(
                        flex: 4,
                        child: Container(
                          padding: EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: <BoxShadow>[
                              new BoxShadow(
                                color: Colors.grey[350]!,
                                offset: new Offset(0, 0),
                                blurRadius: 10.0,
                              )
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //Name and code
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    //Nombre
                                    Expanded(
                                      flex: 6,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Nombre del producto*',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                                color: Colors.black45),
                                          ),
                                          SizedBox(height: 10),
                                          Container(
                                            width: double.infinity,
                                            child: TextFormField(
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14),
                                              cursorColor: Colors.grey,
                                              validator: (val) {
                                                if (val == null ||
                                                    val.isEmpty) {
                                                  return "Agrega un nombre";
                                                } else {
                                                  return null;
                                                }
                                              },
                                              initialValue: name,
                                              decoration: InputDecoration(
                                                focusColor: Colors.black,
                                                hintStyle: TextStyle(
                                                    color: Colors.black45,
                                                    fontSize: 14),
                                                errorStyle: TextStyle(
                                                    color:
                                                        Colors.redAccent[700],
                                                    fontSize: 12),
                                                border: new OutlineInputBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          12.0),
                                                  borderSide: new BorderSide(
                                                    color: Colors.grey[350]!,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          12.0),
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
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    //Code
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Código interno (opcional)',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                                color: Colors.black45),
                                          ),
                                          SizedBox(height: 10),
                                          Container(
                                            width: double.infinity,
                                            child: TextFormField(
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14),
                                              cursorColor: Colors.grey,
                                              initialValue: code,
                                              decoration: InputDecoration(
                                                hintText: 'xxx',
                                                focusColor: Colors.black,
                                                hintStyle: TextStyle(
                                                    color: Colors.black45,
                                                    fontSize: 14),
                                                errorStyle: TextStyle(
                                                    color:
                                                        Colors.redAccent[700],
                                                    fontSize: 12),
                                                border: new OutlineInputBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          12.0),
                                                  borderSide: new BorderSide(
                                                    color: Colors.grey[350]!,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          12.0),
                                                  borderSide: new BorderSide(
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ),
                                              onChanged: (value) {
                                                setState(() {
                                                  code = value;
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                //Price
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    //Price
                                    Expanded(
                                      flex: 6,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Precio de venta*',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                                color: Colors.black45),
                                          ),
                                          SizedBox(height: 10),
                                          Container(
                                            width: double.infinity,
                                            child: TextFormField(
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14),
                                              cursorColor: Colors.grey,
                                              initialValue: (price > 0)
                                                  ? price.toString()
                                                  : '',
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(
                                                        r'[0-9]+[,.]{0,1}[0-9]*')),
                                                TextInputFormatter.withFunction(
                                                  (oldValue, newValue) =>
                                                      newValue.copyWith(
                                                    text: newValue.text
                                                        .replaceAll(',', '.'),
                                                  ),
                                                ),
                                              ],
                                              validator: (val) {
                                                if (val == null ||
                                                    val.isEmpty) {
                                                  return "Agrega un precio";
                                                } else {
                                                  return null;
                                                }
                                              },
                                              decoration: InputDecoration(
                                                hintText: '0.00',
                                                prefixIcon: Icon(
                                                  Icons.attach_money,
                                                  color: Colors.grey,
                                                ),
                                                focusColor: Colors.black,
                                                hintStyle: TextStyle(
                                                    color: Colors.black45,
                                                    fontSize: 14),
                                                errorStyle: TextStyle(
                                                    color:
                                                        Colors.redAccent[700],
                                                    fontSize: 12),
                                                border: new OutlineInputBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          12.0),
                                                  borderSide: new BorderSide(
                                                    color: Colors.grey[350]!,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          12.0),
                                                  borderSide: new BorderSide(
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ),
                                              onChanged: (value) {
                                                if (value != '') {
                                                  setState(() {
                                                    price = double.parse(value);
                                                  });
                                                } else {
                                                  setState(() {
                                                    price = 0;
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    //Available
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Disponible',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                                color: Colors.black45),
                                          ),
                                          SizedBox(height: 10),
                                          Switch(
                                            value: isAvailable,
                                            onChanged: (value) {
                                              setState(() {
                                                isAvailable = value;
                                              });
                                            },
                                            activeTrackColor:
                                                Colors.lightGreenAccent,
                                            activeColor: Colors.green,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    //Show on menu
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Mostrar en catálogo digital',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                                color: Colors.black45),
                                          ),
                                          SizedBox(height: 10),
                                          Switch(
                                            value: show,
                                            onChanged: (value) {
                                              setState(() {
                                                show = value;
                                              });
                                            },
                                            activeTrackColor:
                                                Colors.lightGreenAccent,
                                            activeColor: Colors.green,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                //Dropdown categories
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    //Categories
                                    Expanded(
                                      flex: 6,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Categoría',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                                color: Colors.black45),
                                          ),
                                          SizedBox(height: 10),
                                          Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.grey),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12),
                                              child: DropdownButton(
                                                isExpanded: true,
                                                underline: SizedBox(),
                                                hint: Text(
                                                  widget.categories[0],
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 14,
                                                      color: Colors.grey[700]),
                                                ),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14,
                                                    color: Colors.grey[700]),
                                                value: category,
                                                items:
                                                    widget.categories.map((x) {
                                                  return new DropdownMenuItem(
                                                    value: x,
                                                    child: new Text(x),
                                                    onTap: () {
                                                      setState(() {
                                                        category = x;
                                                      });
                                                    },
                                                  );
                                                }).toList(),
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    category =
                                                        newValue.toString();
                                                  });
                                                },
                                              )),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    //Featured
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Destacado',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                                color: Colors.black45),
                                          ),
                                          SizedBox(height: 10),
                                          IconButton(
                                              tooltip:
                                                  'Los productos destacados se verán primero en tu catálogo digital',
                                              onPressed: () {
                                                setState(() {
                                                  featured = !featured;
                                                });
                                              },
                                              icon: !featured
                                                  ? Icon(
                                                      Icons
                                                          .star_border_outlined,
                                                      size: 30,
                                                      color: Colors.grey,
                                                    )
                                                  : Icon(
                                                      Icons.star,
                                                      size: 30,
                                                      color: Colors.yellow,
                                                    ))
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 20),
                                //Description
                                Text(
                                  'Descripción (opcional)',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: Colors.black45),
                                ),
                                SizedBox(height: 10),
                                TextFormField(
                                  minLines: 5,
                                  maxLines: 10,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 14),
                                  cursorColor: Colors.grey,
                                  initialValue: description,
                                  decoration: InputDecoration(
                                    hintText: 'Descripción del producto',
                                    focusColor: Colors.black,
                                    hintStyle: TextStyle(
                                        color: Colors.black45, fontSize: 14),
                                    border: new OutlineInputBorder(
                                      borderRadius:
                                          new BorderRadius.circular(12.0),
                                      borderSide: new BorderSide(
                                        color: Colors.grey[350]!,
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
                                  onChanged: (value) {
                                    setState(() {
                                      description = value;
                                    });
                                  },
                                ),
                                SizedBox(height: 20),
                                //Vegan
                                (widget.businessField == 'Gastronómico')
                                    ? //Available
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Vegano',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                                color: Colors.black45),
                                          ),
                                          SizedBox(height: 10),
                                          Switch(
                                            value: vegan,
                                            onChanged: (value) {
                                              setState(() {
                                                vegan = value;
                                              });
                                            },
                                            activeTrackColor:
                                                Colors.lightGreenAccent,
                                            activeColor: Colors.green,
                                          ),
                                        ],
                                      )
                                    : SizedBox(),
                                (widget.businessField == 'Gastronómico')
                                    ? SizedBox(height: 20)
                                    : SizedBox(),
                                //Product Options
                                Text(
                                  'Opciones del producto (opcional)',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: Colors.black45),
                                ),
                                SizedBox(height: 10),
                                (productOptions.length == 0)
                                    ? SizedBox()
                                    : ListView.builder(
                                        key: redrawObject2,
                                        shrinkWrap: true,
                                        itemCount: productOptions.length,
                                        itemBuilder: ((context, i) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 15.0),
                                            child: Column(
                                              children: [
                                                //TITLE
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    //Title
                                                    Expanded(
                                                      flex: 9,
                                                      child: Text(
                                                        productOptions[i]
                                                            ['Title'],
                                                        maxLines: 5,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    SizedBox(width: 20),
                                                    //Edit
                                                    IconButton(
                                                        onPressed: () {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return ProductOptionsDialog(
                                                                  setProductOptions,
                                                                  true,
                                                                  optionTitle:
                                                                      productOptions[
                                                                              i]
                                                                          [
                                                                          'Title'],
                                                                  mandatory:
                                                                      productOptions[
                                                                              i]
                                                                          [
                                                                          'Mandatory'],
                                                                  multipleOptions:
                                                                      productOptions[
                                                                              i]
                                                                          [
                                                                          'Multiple Options'],
                                                                  priceStructure:
                                                                      productOptions[
                                                                              i]
                                                                          [
                                                                          'Price Structure'],
                                                                  optionsList:
                                                                      productOptions[
                                                                              i]
                                                                          [
                                                                          'Price Options'],
                                                                  index: i,
                                                                );
                                                              });
                                                        },
                                                        icon: Icon(Icons.edit)),
                                                    SizedBox(width: 5),

                                                    //Delete
                                                    IconButton(
                                                        onPressed: () {
                                                          productOptions
                                                              .removeAt(i);

                                                          final random =
                                                              Random();
                                                          const availableChars =
                                                              'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
                                                          final randomString = List.generate(
                                                              10,
                                                              (index) => availableChars[
                                                                  random.nextInt(
                                                                      availableChars
                                                                          .length)]).join();
                                                          setState(() {
                                                            redrawObject2 =
                                                                ValueKey(
                                                                    randomString);
                                                          });
                                                        },
                                                        icon:
                                                            Icon(Icons.delete))
                                                  ],
                                                ),
                                                SizedBox(height: 5),
                                                //Mandatory //Multiple options
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    //Mandatory
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 5),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    12)),
                                                        border: Border.all(
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      child: Text(
                                                          (productOptions[i]
                                                                  ['Mandatory'])
                                                              ? 'Obligatorio'
                                                              : 'Opcional'),
                                                    ),
                                                    SizedBox(width: 10),
                                                    //Multiple Options
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 5),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    12)),
                                                        border: Border.all(
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      child: Text((productOptions[
                                                                  i][
                                                              'Multiple Options'])
                                                          ? 'Selección múltiple'
                                                          : 'Selección única'),
                                                    ),
                                                    SizedBox(width: 10),
                                                    //Price Structure
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 5),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    12)),
                                                        border: Border.all(
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      child: Text((productOptions[
                                                                      i][
                                                                  'Price Structure'] ==
                                                              'Aditional')
                                                          ? 'Precio adicional'
                                                          : (productOptions[i][
                                                                      'Price Structure'] ==
                                                                  'Complete')
                                                              ? 'Reemplaza el precio'
                                                              : 'Sin costo adicional'),
                                                    ),
                                                  ],
                                                ),

                                                SizedBox(height: 10),
                                                //OPTIONS
                                                ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount: productOptions[i]
                                                            ['Price Options']
                                                        .length,
                                                    itemBuilder: ((context, x) {
                                                      if (productOptions[i][
                                                                      'Price Options']
                                                                  [
                                                                  x]['Price'] !=
                                                              0 &&
                                                          productOptions[i][
                                                                      'Price Options']
                                                                  [
                                                                  x]['Price'] !=
                                                              null) {
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 15.0),
                                                          child: Text(
                                                              '• ${productOptions[i]['Price Options'][x]['Option']}  (+\$${productOptions[i]['Price Options'][x]['Price']})'),
                                                        );
                                                      } else {
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 15.0),
                                                          child: Text(
                                                              '• ${productOptions[i]['Price Options'][x]['Option']}'),
                                                        );
                                                      }
                                                    })),
                                              ],
                                            ),
                                          );
                                        })),
                                //Agregar Lista de opciones
                                Tooltip(
                                  message: 'Agregar opciones del producto',
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.black,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return ProductOptionsDialog(
                                                setProductOptions, false);
                                          });
                                    },
                                    child: Container(
                                      height: 70,
                                      width: 70,
                                      child: Center(
                                          child: Icon(
                                        Icons.add,
                                        color: Colors.black87,
                                        size: 30,
                                      )),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                //Ingredientes
                                Text(
                                  'Insumos asociados (opcional)',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: Colors.black45),
                                ),
                                SizedBox(height: 15),
                                (ingredients.length == 0)
                                    ? SizedBox()
                                    : ListView.builder(
                                        key: redrawObject,
                                        shrinkWrap: true,
                                        itemCount: ingredients.length,
                                        itemBuilder: ((context, i) {
                                          double ingredientTotal = ((ingredients[
                                                          i]['Supply Cost'] /
                                                      ingredients[i]
                                                          ['Supply Quantity']) *
                                                  ingredients[i]['Quantity']) /
                                              ingredients[i]['Yield'];

                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 15.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                //Ingrediente
                                                Expanded(
                                                  flex: 6,
                                                  child: Container(
                                                    width: double.infinity,
                                                    child: TextFormField(
                                                      enabled: false,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 14),
                                                      cursorColor: Colors.grey,
                                                      initialValue:
                                                          ingredients[i]
                                                              ['Ingredient'],
                                                      decoration:
                                                          InputDecoration(
                                                        focusColor:
                                                            Colors.black,
                                                        hintStyle: TextStyle(
                                                            color:
                                                                Colors.black45,
                                                            fontSize: 12),
                                                        errorStyle: TextStyle(
                                                            color: Colors
                                                                .redAccent[700],
                                                            fontSize: 12),
                                                        border:
                                                            new OutlineInputBorder(
                                                          borderRadius:
                                                              new BorderRadius
                                                                  .circular(
                                                                  12.0),
                                                          borderSide:
                                                              new BorderSide(
                                                            color: Colors
                                                                .grey[350]!,
                                                          ),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              new BorderRadius
                                                                  .circular(
                                                                  12.0),
                                                          borderSide:
                                                              new BorderSide(
                                                            color: Colors.green,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 15),
                                                //Amount
                                                Expanded(
                                                  flex: 3,
                                                  child: Container(
                                                    width: double.infinity,
                                                    child: TextFormField(
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 14),
                                                      textAlign:
                                                          TextAlign.center,
                                                      initialValue: ingredients[
                                                                      i][
                                                                  'Quantity'] ==
                                                              0
                                                          ? ''
                                                          : '${ingredients[i]['Quantity']}',
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter
                                                            .allow(RegExp(
                                                                r'[0-9]+[,.]{0,1}[0-9]*')),
                                                        TextInputFormatter
                                                            .withFunction(
                                                          (oldValue,
                                                                  newValue) =>
                                                              newValue.copyWith(
                                                            text: newValue.text
                                                                .replaceAll(
                                                                    ',', '.'),
                                                          ),
                                                        ),
                                                      ],
                                                      cursorColor: Colors.grey,
                                                      decoration:
                                                          InputDecoration(
                                                        floatingLabelStyle:
                                                            TextStyle(
                                                                color: Colors
                                                                    .grey),
                                                        labelStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 12),
                                                        labelText: (ingredients[
                                                                        i]
                                                                    ['Unit'] !=
                                                                null)
                                                            ? ingredients[i]
                                                                ['Unit']
                                                            : 'Cantidad',
                                                        focusColor:
                                                            Colors.black,
                                                        hintStyle: TextStyle(
                                                            color:
                                                                Colors.black45,
                                                            fontSize: 12),
                                                        errorStyle: TextStyle(
                                                            color: Colors
                                                                .redAccent[700],
                                                            fontSize: 12),
                                                        border:
                                                            new OutlineInputBorder(
                                                          borderRadius:
                                                              new BorderRadius
                                                                  .circular(
                                                                  12.0),
                                                          borderSide:
                                                              new BorderSide(
                                                            color: Colors
                                                                .grey[350]!,
                                                          ),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              new BorderRadius
                                                                  .circular(
                                                                  12.0),
                                                          borderSide:
                                                              new BorderSide(
                                                            color: Colors.green,
                                                          ),
                                                        ),
                                                      ),
                                                      onChanged: (value) {
                                                        String newValue =
                                                            value.toString();
                                                        try {
                                                          double newPrice =
                                                              double.parse(
                                                                  newValue);
                                                          setState(() {
                                                            ingredients[i][
                                                                    'Quantity'] =
                                                                newPrice;
                                                          });
                                                        } catch (e) {
                                                          print(e);
                                                          // priceOptions[i]['Price'] =
                                                          //     double.parse(newValue);
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 15),
                                                //Yield
                                                Expanded(
                                                  flex: 3,
                                                  child: Container(
                                                    width: double.infinity,
                                                    child: TextFormField(
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 14),
                                                      textAlign:
                                                          TextAlign.center,
                                                      initialValue: ingredients[
                                                                  i]['Yield'] ==
                                                              0
                                                          ? ''
                                                          : '${ingredients[i]['Yield']}',
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter
                                                            .allow(RegExp(
                                                                r'[0-9]+[,.]{0,1}[0-9]*')),
                                                        TextInputFormatter
                                                            .withFunction(
                                                          (oldValue,
                                                                  newValue) =>
                                                              newValue.copyWith(
                                                            text: newValue.text
                                                                .replaceAll(
                                                                    ',', '.'),
                                                          ),
                                                        ),
                                                      ],
                                                      cursorColor: Colors.grey,
                                                      decoration:
                                                          InputDecoration(
                                                        labelText: 'Rinde para',
                                                        floatingLabelStyle:
                                                            TextStyle(
                                                                color: Colors
                                                                    .grey),
                                                        labelStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 12),
                                                        focusColor:
                                                            Colors.black,
                                                        hintStyle: TextStyle(
                                                            color:
                                                                Colors.black45,
                                                            fontSize: 12),
                                                        errorStyle: TextStyle(
                                                            color: Colors
                                                                .redAccent[700],
                                                            fontSize: 12),
                                                        border:
                                                            new OutlineInputBorder(
                                                          borderRadius:
                                                              new BorderRadius
                                                                  .circular(
                                                                  12.0),
                                                          borderSide:
                                                              new BorderSide(
                                                            color: Colors
                                                                .grey[350]!,
                                                          ),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              new BorderRadius
                                                                  .circular(
                                                                  12.0),
                                                          borderSide:
                                                              new BorderSide(
                                                            color: Colors.green,
                                                          ),
                                                        ),
                                                      ),
                                                      onChanged: (value) {
                                                        String newValue =
                                                            value.toString();
                                                        try {
                                                          double newPrice =
                                                              double.parse(
                                                                  newValue);
                                                          setState(() {
                                                            ingredients[i]
                                                                    ['Yield'] =
                                                                newPrice;
                                                          });
                                                        } catch (e) {
                                                          print(e);
                                                          // priceOptions[i]['Price'] =
                                                          //     double.parse(newValue);
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 15),
                                                //Cost
                                                Expanded(
                                                    flex: 3,
                                                    child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              new BorderRadius
                                                                  .circular(
                                                                  12.0),
                                                          border: Border.all(
                                                            color: Colors
                                                                .grey[350]!,
                                                          ),
                                                        ),
                                                        padding:
                                                            EdgeInsets.all(15),
                                                        child: Center(
                                                          child: Text(
                                                            (ingredientTotal
                                                                        .isNaN ||
                                                                    ingredientTotal
                                                                        .isInfinite ||
                                                                    ingredientTotal
                                                                        .isNegative)
                                                                ? '0'
                                                                : '\$${ingredientTotal.toStringAsFixed(0)}',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ))),
                                                //Delete
                                                IconButton(
                                                    tooltip: 'Eliminar',
                                                    padding: EdgeInsets.all(2),
                                                    splashRadius: 5,
                                                    onPressed: () {
                                                      ingredients.removeAt(i);

                                                      final random = Random();
                                                      const availableChars =
                                                          'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
                                                      final randomString = List.generate(
                                                          10,
                                                          (index) => availableChars[
                                                              random.nextInt(
                                                                  availableChars
                                                                      .length)]).join();
                                                      setState(() {
                                                        redrawObject = ValueKey(
                                                            randomString);
                                                      });
                                                    },
                                                    icon: Icon(
                                                      Icons.close,
                                                      size: 16,
                                                    ))
                                              ],
                                            ),
                                          );
                                        })),

                                SizedBox(
                                    height: (ingredients.length == 0) ? 0 : 10),
                                (ingredients.length == 0)
                                    ? SizedBox()
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text('Costo total del producto: '),
                                          Text(
                                            formatCurrency
                                                .format(totalIngredientsCost()),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                          SizedBox(
                                            width: 50,
                                          )
                                        ],
                                      ),
                                SizedBox(
                                    height: (ingredients.length == 0) ? 0 : 20),
                                //Agregar ingrediente
                                Tooltip(
                                  message: 'Agregar insumo',
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.black,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: ((context) =>
                                              SuppliesListDialog(selectSupply,
                                                  widget.activeBusiness)));
                                    },
                                    child: Container(
                                      height: 70,
                                      width: 70,
                                      child: Center(
                                          child: Icon(
                                        Icons.add,
                                        color: Colors.black87,
                                        size: 30,
                                      )),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    height: (ingredients.length == 0) ? 0 : 20),
                                //Expected Margin/Low margin
                                (ingredients.length == 0)
                                    ? SizedBox()
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          //Current Margin
                                          Expanded(
                                            flex: 5,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Margen de ganancia actual',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 12,
                                                      color: Colors.black45),
                                                ),
                                                SizedBox(height: 10),
                                                Container(
                                                  width: double.infinity,
                                                  height: 45,
                                                  child: Center(
                                                    child: Text(
                                                        '${(((price - totalIngredientsCost()) / price) * 100).toStringAsFixed(1)}%',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18,
                                                            color: ((((price - totalIngredientsCost()) /
                                                                            price) *
                                                                        100) <
                                                                    lowMarginAlert!)
                                                                ? Colors.red
                                                                : Colors.greenAccent[
                                                                    700])),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 20),
                                          //Expected Margin
                                          Expanded(
                                            flex: 5,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Margen esperado',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 12,
                                                      color: Colors.black45),
                                                ),
                                                SizedBox(height: 10),
                                                Container(
                                                  width: double.infinity,
                                                  child: TextFormField(
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14),
                                                    cursorColor: Colors.grey,
                                                    initialValue:
                                                        (expectedMargin != null)
                                                            ? expectedMargin
                                                                .toString()
                                                            : '',
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter
                                                          .digitsOnly,
                                                      LengthLimitingTextInputFormatter(
                                                          2),
                                                    ],
                                                    decoration: InputDecoration(
                                                      focusColor: Colors.black,
                                                      suffixIcon: Icon(
                                                          Icons
                                                              .percent_outlined,
                                                          color: Colors.grey,
                                                          size: 16),
                                                      hintStyle: TextStyle(
                                                          color: Colors.black45,
                                                          fontSize: 14),
                                                      errorStyle: TextStyle(
                                                          color: Colors
                                                              .redAccent[700],
                                                          fontSize: 12),
                                                      border:
                                                          new OutlineInputBorder(
                                                        borderRadius:
                                                            new BorderRadius
                                                                .circular(12.0),
                                                        borderSide:
                                                            new BorderSide(
                                                          color:
                                                              Colors.grey[350]!,
                                                        ),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            new BorderRadius
                                                                .circular(12.0),
                                                        borderSide:
                                                            new BorderSide(
                                                          color: Colors.green,
                                                        ),
                                                      ),
                                                    ),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        expectedMargin =
                                                            double.parse(value);
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 20),
                                          //Low Margin Alert
                                          Expanded(
                                            flex: 5,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Alerta de bajo margen',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 12,
                                                      color: Colors.black45),
                                                ),
                                                SizedBox(height: 10),
                                                Container(
                                                  width: double.infinity,
                                                  child: TextFormField(
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14),
                                                    cursorColor: Colors.grey,
                                                    initialValue:
                                                        (lowMarginAlert != null)
                                                            ? lowMarginAlert
                                                                .toString()
                                                            : '',
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter
                                                          .digitsOnly,
                                                      LengthLimitingTextInputFormatter(
                                                          2),
                                                    ],
                                                    decoration: InputDecoration(
                                                      suffixIcon: Icon(
                                                          Icons
                                                              .percent_outlined,
                                                          color: Colors.grey,
                                                          size: 16),
                                                      focusColor: Colors.black,
                                                      hintStyle: TextStyle(
                                                          color: Colors.black45,
                                                          fontSize: 14),
                                                      errorStyle: TextStyle(
                                                          color: Colors
                                                              .redAccent[700],
                                                          fontSize: 12),
                                                      border:
                                                          new OutlineInputBorder(
                                                        borderRadius:
                                                            new BorderRadius
                                                                .circular(12.0),
                                                        borderSide:
                                                            new BorderSide(
                                                          color:
                                                              Colors.grey[350]!,
                                                        ),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            new BorderRadius
                                                                .circular(12.0),
                                                        borderSide:
                                                            new BorderSide(
                                                          color: Colors.green,
                                                        ),
                                                      ),
                                                    ),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        lowMarginAlert =
                                                            double.parse(value);
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                //Button
                                SizedBox(height: 35),
                                (widget.product == null)
                                    ? ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.black),
                                          overlayColor: MaterialStateProperty
                                              .resolveWith<Color?>(
                                            (Set<MaterialState> states) {
                                              if (states.contains(
                                                  MaterialState.hovered))
                                                return Colors.grey;
                                              if (states.contains(
                                                      MaterialState.focused) ||
                                                  states.contains(
                                                      MaterialState.pressed))
                                                return Colors.grey.shade300;
                                              return null; // Defer to the widget's default.
                                            },
                                          ),
                                        ),
                                        onPressed: () {
                                          if (newProduct) {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              if (ingredients.length > 0) {
                                                for (int i = 0;
                                                    i < ingredients.length;
                                                    i++) {
                                                  listOfIngredients.add(
                                                      ingredients[i]
                                                          ['Ingredient']);
                                                }
                                              }
                                              if (changedImage) {
                                                uploadPic(widget.activeBusiness).then(
                                                    (value) => DatabaseService()
                                                        .createProduct(
                                                            widget
                                                                .activeBusiness,
                                                            name,
                                                            downloadUrl,
                                                            category,
                                                            price,
                                                            description,
                                                            productOptions,
                                                            setSearchParam(name
                                                                .toLowerCase()),
                                                            code,
                                                            listOfIngredients,
                                                            ingredients,
                                                            (widget.businessField ==
                                                                    'Gatronómico')
                                                                ? vegan
                                                                : null,
                                                            show,
                                                            featured,
                                                            expectedMargin,
                                                            lowMarginAlert));
                                              } else {
                                                DatabaseService().createProduct(
                                                    widget.activeBusiness,
                                                    name,
                                                    '',
                                                    category,
                                                    price,
                                                    description,
                                                    productOptions,
                                                    setSearchParam(
                                                        name.toLowerCase()),
                                                    code,
                                                    listOfIngredients,
                                                    ingredients,
                                                    (widget.businessField ==
                                                            'Gatronómico')
                                                        ? vegan
                                                        : null,
                                                    show,
                                                    featured,
                                                    expectedMargin,
                                                    lowMarginAlert);
                                              }

                                              Navigator.of(context).pop();
                                            }
                                          } else {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              if (ingredients.length > 0) {
                                                for (int i = 0;
                                                    i < ingredients.length;
                                                    i++) {
                                                  listOfIngredients.add(
                                                      ingredients[i]
                                                          ['Ingredient']);
                                                }
                                              }
                                              if (changedImage) {
                                                if (widget.product!.price !=
                                                    price) {
                                                  try {
                                                    historicPrices
                                                            .last['To Date'] =
                                                        DateTime.now();

                                                    historicPrices.add({
                                                      'From Date':
                                                          DateTime.now(),
                                                      'To Date': null,
                                                      'Price': price
                                                    });
                                                  } catch (e) {
                                                    print(e);
                                                    historicPrices = [
                                                      {
                                                        'From Date':
                                                            DateTime.now(),
                                                        'To Date': null,
                                                        'Price': price
                                                      }
                                                    ];
                                                  }
                                                }
                                                uploadPic(widget.activeBusiness).then(
                                                    (value) => DatabaseService()
                                                        .editProduct(
                                                            widget
                                                                .activeBusiness,
                                                            widget.product!
                                                                .productID,
                                                            isAvailable,
                                                            name,
                                                            downloadUrl,
                                                            category,
                                                            price,
                                                            description,
                                                            productOptions,
                                                            setSearchParam(name
                                                                .toLowerCase()),
                                                            code,
                                                            listOfIngredients,
                                                            ingredients,
                                                            (widget.businessField ==
                                                                    'Gatronómico')
                                                                ? vegan
                                                                : null,
                                                            show,
                                                            historicPrices,
                                                            featured,
                                                            expectedMargin!,
                                                            lowMarginAlert!));
                                              } else {
                                                if (widget.product!.price !=
                                                    price) {
                                                  try {
                                                    historicPrices
                                                            .last['To Date'] =
                                                        DateTime.now();

                                                    historicPrices.add({
                                                      'From Date':
                                                          DateTime.now(),
                                                      'To Date': null,
                                                      'Price': price
                                                    });
                                                  } catch (e) {
                                                    print(e);
                                                    historicPrices = [
                                                      {
                                                        'From Date':
                                                            DateTime.now(),
                                                        'To Date': null,
                                                        'Price': price
                                                      }
                                                    ];
                                                  }
                                                }
                                                DatabaseService().editProduct(
                                                    widget.activeBusiness,
                                                    widget.product!.productID,
                                                    isAvailable,
                                                    name,
                                                    image,
                                                    category,
                                                    price,
                                                    description,
                                                    productOptions,
                                                    setSearchParam(
                                                        name.toLowerCase()),
                                                    code,
                                                    listOfIngredients,
                                                    ingredients,
                                                    (widget.businessField ==
                                                            'Gatronómico')
                                                        ? vegan
                                                        : null,
                                                    show,
                                                    historicPrices,
                                                    featured,
                                                    expectedMargin!,
                                                    lowMarginAlert!);
                                              }
                                              Navigator.of(context).pop();
                                            }
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 15),
                                          child: Center(
                                            child: Text((newProduct)
                                                ? 'Crear'
                                                : 'Guardar cambios'),
                                          ),
                                        ))
                                    : Container(
                                        width: double.infinity,
                                        child: Row(
                                          children: [
                                            //Save
                                            Expanded(
                                              child: ElevatedButton(
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                Colors.black),
                                                    overlayColor:
                                                        MaterialStateProperty
                                                            .resolveWith<
                                                                Color?>(
                                                      (Set<MaterialState>
                                                          states) {
                                                        if (states.contains(
                                                            MaterialState
                                                                .hovered))
                                                          return Colors.grey;
                                                        if (states.contains(
                                                                MaterialState
                                                                    .focused) ||
                                                            states.contains(
                                                                MaterialState
                                                                    .pressed))
                                                          return Colors
                                                              .grey.shade300;
                                                        return null; // Defer to the widget's default.
                                                      },
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    if (newProduct) {
                                                      if (_formKey.currentState!
                                                          .validate()) {
                                                        if (widget
                                                                .product!
                                                                .ingredients!
                                                                .length >
                                                            0) {
                                                          for (int i = 0;
                                                              i <
                                                                  ingredients
                                                                      .length;
                                                              i++) {
                                                            listOfIngredients
                                                                .add(ingredients[
                                                                        i][
                                                                    'Ingredient']);
                                                          }
                                                        }
                                                        if (changedImage) {
                                                          uploadPic(widget.activeBusiness).then((value) => DatabaseService().createProduct(
                                                              widget
                                                                  .activeBusiness,
                                                              name,
                                                              downloadUrl,
                                                              category,
                                                              price,
                                                              description,
                                                              productOptions,
                                                              setSearchParam(name
                                                                  .toLowerCase()),
                                                              code,
                                                              listOfIngredients,
                                                              ingredients,
                                                              (widget.businessField ==
                                                                      'Gatronómico')
                                                                  ? vegan
                                                                  : null,
                                                              show,
                                                              featured,
                                                              expectedMargin,
                                                              lowMarginAlert));
                                                        } else {
                                                          DatabaseService().createProduct(
                                                              widget
                                                                  .activeBusiness,
                                                              name,
                                                              '',
                                                              category,
                                                              price,
                                                              description,
                                                              productOptions,
                                                              setSearchParam(name
                                                                  .toLowerCase()),
                                                              code,
                                                              listOfIngredients,
                                                              ingredients,
                                                              (widget.businessField ==
                                                                      'Gatronómico')
                                                                  ? vegan
                                                                  : null,
                                                              show,
                                                              featured,
                                                              expectedMargin,
                                                              lowMarginAlert);
                                                        }

                                                        Navigator.of(context)
                                                            .pop();
                                                      }
                                                    } else {
                                                      if (_formKey.currentState!
                                                          .validate()) {
                                                        if (ingredients.length >
                                                            0) {
                                                          for (int i = 0;
                                                              i <
                                                                  ingredients
                                                                      .length;
                                                              i++) {
                                                            listOfIngredients
                                                                .add(ingredients[
                                                                        i][
                                                                    'Ingredient']);
                                                          }
                                                        }
                                                        if (changedImage) {
                                                          if (widget.product!
                                                                  .price !=
                                                              price) {
                                                            if (historicPrices
                                                                    .length >
                                                                0) {
                                                              historicPrices
                                                                          .last[
                                                                      'To Date'] =
                                                                  DateTime
                                                                      .now();

                                                              historicPrices
                                                                  .add({
                                                                'From Date':
                                                                    DateTime
                                                                        .now(),
                                                                'To Date': null,
                                                                'Price': price
                                                              });
                                                            } else {
                                                              historicPrices = [
                                                                {
                                                                  'From Date':
                                                                      DateTime
                                                                          .now(),
                                                                  'To Date':
                                                                      null,
                                                                  'Price': price
                                                                }
                                                              ];
                                                            }
                                                          }
                                                          uploadPic(widget.activeBusiness).then((value) => DatabaseService().editProduct(
                                                              widget
                                                                  .activeBusiness,
                                                              widget.product!
                                                                  .productID,
                                                              isAvailable,
                                                              name,
                                                              downloadUrl,
                                                              category,
                                                              price,
                                                              description,
                                                              productOptions,
                                                              setSearchParam(name
                                                                  .toLowerCase()),
                                                              code,
                                                              listOfIngredients,
                                                              ingredients,
                                                              (widget.businessField ==
                                                                      'Gatronómico')
                                                                  ? vegan
                                                                  : null,
                                                              show,
                                                              historicPrices,
                                                              featured,
                                                              expectedMargin!,
                                                              lowMarginAlert!));
                                                        } else {
                                                          if (widget.product!
                                                                  .price !=
                                                              price) {
                                                            if (historicPrices
                                                                    .length >
                                                                0) {
                                                              historicPrices
                                                                          .last[
                                                                      'To Date'] =
                                                                  DateTime
                                                                      .now();

                                                              historicPrices
                                                                  .add({
                                                                'From Date':
                                                                    DateTime
                                                                        .now(),
                                                                'To Date': null,
                                                                'Price': price
                                                              });
                                                            } else {
                                                              historicPrices = [
                                                                {
                                                                  'From Date':
                                                                      DateTime
                                                                          .now(),
                                                                  'To Date':
                                                                      null,
                                                                  'Price': price
                                                                }
                                                              ];
                                                            }
                                                          }
                                                          DatabaseService().editProduct(
                                                              widget
                                                                  .activeBusiness,
                                                              widget.product!
                                                                  .productID,
                                                              isAvailable,
                                                              name,
                                                              image,
                                                              category,
                                                              price,
                                                              description,
                                                              productOptions,
                                                              setSearchParam(name
                                                                  .toLowerCase()),
                                                              code,
                                                              listOfIngredients,
                                                              ingredients,
                                                              (widget.businessField ==
                                                                      'Gatronómico')
                                                                  ? vegan
                                                                  : null,
                                                              show,
                                                              historicPrices,
                                                              featured,
                                                              expectedMargin!,
                                                              lowMarginAlert!);
                                                        }
                                                        Navigator.of(context)
                                                            .pop();
                                                      }
                                                    }
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 20,
                                                        vertical: 15),
                                                    child: Center(
                                                      child: Text((newProduct)
                                                          ? 'Crear'
                                                          : 'Guardar cambios'),
                                                    ),
                                                  )),
                                            ),
                                            SizedBox(width: 20),
                                            //Delete
                                            Container(
                                              height: 45,
                                              width: 45,
                                              child: Tooltip(
                                                message: 'Eliminar producto',
                                                child: OutlinedButton(
                                                  style: ButtonStyle(
                                                    padding: MaterialStateProperty
                                                        .all<EdgeInsetsGeometry>(
                                                            EdgeInsets.all(5)),
                                                    alignment: Alignment.center,
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                Colors.white70),
                                                    overlayColor:
                                                        MaterialStateProperty
                                                            .resolveWith<
                                                                Color?>(
                                                      (Set<MaterialState>
                                                          states) {
                                                        if (states.contains(
                                                            MaterialState
                                                                .hovered))
                                                          return Colors
                                                              .grey.shade300;
                                                        if (states.contains(
                                                                MaterialState
                                                                    .focused) ||
                                                            states.contains(
                                                                MaterialState
                                                                    .pressed))
                                                          return Colors.white;
                                                        return null; // Defer to the widget's default.
                                                      },
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    DatabaseService()
                                                        .deleteProduct(
                                                            widget
                                                                .activeBusiness,
                                                            widget.product!
                                                                .productID!);
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Center(
                                                      child: Icon(
                                                    Icons.delete,
                                                    color: Colors.black,
                                                    size: 18,
                                                  )),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      //Expanded
                      Expanded(flex: 2, child: Container())
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      //Image
                      Container(
                        height: 275,
                        width: 300,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: <BoxShadow>[
                            new BoxShadow(
                              color: Colors.grey[350]!,
                              offset: new Offset(0, 0),
                              blurRadius: 10.0,
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            //Text
                            Text(
                              'Imagen',
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Colors.black45),
                            ),
                            SizedBox(height: 10),
                            //Image
                            (changedImage)
                                ? Container(
                                    width: double.infinity,
                                    height: 150,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25)),
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                        color: Colors.grey,
                                        image: DecorationImage(
                                            image: Image.memory(
                                              webImage,
                                              fit: BoxFit.cover,
                                            ).image,
                                            fit: BoxFit.cover)))
                                : (!newProduct && image != '')
                                    ? Container(
                                        width: double.infinity,
                                        height: 150,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(25)),
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                            color: Colors.grey.shade200,
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                    widget.product!.image!),
                                                fit: BoxFit.cover)),
                                      )
                                    : Container(
                                        width: double.infinity,
                                        height: 150,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(25)),
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          color: Colors.grey.shade200,
                                        ),
                                        child: Center(
                                          child: Icon(Icons.add_a_photo,
                                              color: Colors.grey),
                                        ),
                                      ),

                            SizedBox(height: 20),
                            TextButton(
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.black),
                              onPressed: getImage,
                              child: Container(
                                height: 35,
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2.0, horizontal: 2),
                                child: Center(
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.edit,
                                          color: Colors.black,
                                          size: 12,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          'Editar imagen',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ]),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      //Main Data
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Container(
                          padding: EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: <BoxShadow>[
                              new BoxShadow(
                                color: Colors.grey[350]!,
                                offset: new Offset(0, 0),
                                blurRadius: 10.0,
                              )
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //Name and code
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    //Nombre
                                    Expanded(
                                      flex: 6,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Nombre del producto*',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                                color: Colors.black45),
                                          ),
                                          SizedBox(height: 10),
                                          Container(
                                            width: double.infinity,
                                            child: TextFormField(
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14),
                                              cursorColor: Colors.grey,
                                              validator: (val) {
                                                if (val == null ||
                                                    val.isEmpty) {
                                                  return "Agrega un nombre";
                                                } else {
                                                  return null;
                                                }
                                              },
                                              initialValue: name,
                                              decoration: InputDecoration(
                                                focusColor: Colors.black,
                                                hintStyle: TextStyle(
                                                    color: Colors.black45,
                                                    fontSize: 14),
                                                errorStyle: TextStyle(
                                                    color:
                                                        Colors.redAccent[700],
                                                    fontSize: 12),
                                                border: new OutlineInputBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          12.0),
                                                  borderSide: new BorderSide(
                                                    color: Colors.grey[350]!,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          12.0),
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
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    //Code
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Código interno (opcional)',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                                color: Colors.black45),
                                          ),
                                          SizedBox(height: 10),
                                          Container(
                                            width: double.infinity,
                                            child: TextFormField(
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14),
                                              cursorColor: Colors.grey,
                                              initialValue: code,
                                              decoration: InputDecoration(
                                                hintText: 'xxx',
                                                focusColor: Colors.black,
                                                hintStyle: TextStyle(
                                                    color: Colors.black45,
                                                    fontSize: 14),
                                                errorStyle: TextStyle(
                                                    color:
                                                        Colors.redAccent[700],
                                                    fontSize: 12),
                                                border: new OutlineInputBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          12.0),
                                                  borderSide: new BorderSide(
                                                    color: Colors.grey[350]!,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          12.0),
                                                  borderSide: new BorderSide(
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ),
                                              onChanged: (value) {
                                                setState(() {
                                                  code = value;
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                //Price
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    //Price
                                    Expanded(
                                      flex: 6,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Precio de venta*',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                                color: Colors.black45),
                                          ),
                                          SizedBox(height: 10),
                                          Container(
                                            width: double.infinity,
                                            child: TextFormField(
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14),
                                              cursorColor: Colors.grey,
                                              initialValue: (price > 0)
                                                  ? price.toString()
                                                  : '',
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(
                                                        r'[0-9]+[,.]{0,1}[0-9]*')),
                                                TextInputFormatter.withFunction(
                                                  (oldValue, newValue) =>
                                                      newValue.copyWith(
                                                    text: newValue.text
                                                        .replaceAll(',', '.'),
                                                  ),
                                                ),
                                              ],
                                              validator: (val) {
                                                if (val == null ||
                                                    val.isEmpty) {
                                                  return "Agrega un precio";
                                                } else {
                                                  return null;
                                                }
                                              },
                                              decoration: InputDecoration(
                                                hintText: '0.00',
                                                prefixIcon: Icon(
                                                  Icons.attach_money,
                                                  color: Colors.grey,
                                                ),
                                                focusColor: Colors.black,
                                                hintStyle: TextStyle(
                                                    color: Colors.black45,
                                                    fontSize: 14),
                                                errorStyle: TextStyle(
                                                    color:
                                                        Colors.redAccent[700],
                                                    fontSize: 12),
                                                border: new OutlineInputBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          12.0),
                                                  borderSide: new BorderSide(
                                                    color: Colors.grey[350]!,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          12.0),
                                                  borderSide: new BorderSide(
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ),
                                              onChanged: (value) {
                                                if (value != '') {
                                                  setState(() {
                                                    price = double.parse(value);
                                                  });
                                                } else {
                                                  setState(() {
                                                    price = 0;
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    //Available
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Disponible',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                                color: Colors.black45),
                                          ),
                                          SizedBox(height: 10),
                                          Switch(
                                            value: isAvailable,
                                            onChanged: (value) {
                                              setState(() {
                                                isAvailable = value;
                                              });
                                            },
                                            activeTrackColor:
                                                Colors.lightGreenAccent,
                                            activeColor: Colors.green,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    //Show on menu
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Mostrar en catálogo digital',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                                color: Colors.black45),
                                          ),
                                          SizedBox(height: 10),
                                          Switch(
                                            value: show,
                                            onChanged: (value) {
                                              setState(() {
                                                show = value;
                                              });
                                            },
                                            activeTrackColor:
                                                Colors.lightGreenAccent,
                                            activeColor: Colors.green,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                //Dropdown categories
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    //Categories
                                    Expanded(
                                      flex: 6,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Categoría',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                                color: Colors.black45),
                                          ),
                                          SizedBox(height: 10),
                                          Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.grey),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12),
                                              child: DropdownButton(
                                                isExpanded: true,
                                                underline: SizedBox(),
                                                hint: Text(
                                                  widget.categories[0],
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 14,
                                                      color: Colors.grey[700]),
                                                ),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14,
                                                    color: Colors.grey[700]),
                                                value: category,
                                                items:
                                                    widget.categories.map((x) {
                                                  return new DropdownMenuItem(
                                                    value: x,
                                                    child: new Text(x),
                                                    onTap: () {
                                                      setState(() {
                                                        category = x;
                                                      });
                                                    },
                                                  );
                                                }).toList(),
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    category =
                                                        newValue.toString();
                                                  });
                                                },
                                              )),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    //Featured
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Destacado',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                                color: Colors.black45),
                                          ),
                                          SizedBox(height: 10),
                                          IconButton(
                                              tooltip:
                                                  'Los productos destacados se verán primero en tu catálogo digital',
                                              onPressed: () {
                                                setState(() {
                                                  featured = !featured;
                                                });
                                              },
                                              icon: !featured
                                                  ? Icon(
                                                      Icons
                                                          .star_border_outlined,
                                                      size: 30,
                                                      color: Colors.grey,
                                                    )
                                                  : Icon(
                                                      Icons.star,
                                                      size: 30,
                                                      color: Colors.yellow,
                                                    ))
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 20),
                                //Description
                                Text(
                                  'Descripción (opcional)',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: Colors.black45),
                                ),
                                SizedBox(height: 10),
                                TextFormField(
                                  minLines: 5,
                                  maxLines: 10,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 14),
                                  cursorColor: Colors.grey,
                                  initialValue: description,
                                  decoration: InputDecoration(
                                    hintText: 'Descripción del producto',
                                    focusColor: Colors.black,
                                    hintStyle: TextStyle(
                                        color: Colors.black45, fontSize: 14),
                                    border: new OutlineInputBorder(
                                      borderRadius:
                                          new BorderRadius.circular(12.0),
                                      borderSide: new BorderSide(
                                        color: Colors.grey[350]!,
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
                                  onChanged: (value) {
                                    setState(() {
                                      description = value;
                                    });
                                  },
                                ),
                                SizedBox(height: 20),
                                //Vegan
                                (widget.businessField == 'Gastronómico')
                                    ? //Available
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Vegano',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                                color: Colors.black45),
                                          ),
                                          SizedBox(height: 10),
                                          Switch(
                                            value: vegan,
                                            onChanged: (value) {
                                              setState(() {
                                                vegan = value;
                                              });
                                            },
                                            activeTrackColor:
                                                Colors.lightGreenAccent,
                                            activeColor: Colors.green,
                                          ),
                                        ],
                                      )
                                    : SizedBox(),
                                (widget.businessField == 'Gastronómico')
                                    ? SizedBox(height: 20)
                                    : SizedBox(),
                                //Product Options
                                Text(
                                  'Opciones del producto (opcional)',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: Colors.black45),
                                ),
                                SizedBox(height: 10),
                                (productOptions.length == 0)
                                    ? SizedBox()
                                    : ListView.builder(
                                        key: redrawObject2,
                                        shrinkWrap: true,
                                        itemCount: productOptions.length,
                                        itemBuilder: ((context, i) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 15.0),
                                            child: Column(
                                              children: [
                                                //TITLE
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    //Title
                                                    Expanded(
                                                      flex: 9,
                                                      child: Text(
                                                        productOptions[i]
                                                            ['Title'],
                                                        maxLines: 5,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    SizedBox(width: 20),
                                                    //Edit
                                                    IconButton(
                                                        onPressed: () {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return ProductOptionsDialog(
                                                                  setProductOptions,
                                                                  true,
                                                                  optionTitle:
                                                                      productOptions[
                                                                              i]
                                                                          [
                                                                          'Title'],
                                                                  mandatory:
                                                                      productOptions[
                                                                              i]
                                                                          [
                                                                          'Mandatory'],
                                                                  multipleOptions:
                                                                      productOptions[
                                                                              i]
                                                                          [
                                                                          'Multiple Options'],
                                                                  priceStructure:
                                                                      productOptions[
                                                                              i]
                                                                          [
                                                                          'Price Structure'],
                                                                  optionsList:
                                                                      productOptions[
                                                                              i]
                                                                          [
                                                                          'Price Options'],
                                                                  index: i,
                                                                );
                                                              });
                                                        },
                                                        icon: Icon(Icons.edit)),
                                                    SizedBox(width: 5),

                                                    //Delete
                                                    IconButton(
                                                        onPressed: () {
                                                          productOptions
                                                              .removeAt(i);

                                                          final random =
                                                              Random();
                                                          const availableChars =
                                                              'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
                                                          final randomString = List.generate(
                                                              10,
                                                              (index) => availableChars[
                                                                  random.nextInt(
                                                                      availableChars
                                                                          .length)]).join();
                                                          setState(() {
                                                            redrawObject2 =
                                                                ValueKey(
                                                                    randomString);
                                                          });
                                                        },
                                                        icon:
                                                            Icon(Icons.delete))
                                                  ],
                                                ),
                                                SizedBox(height: 5),
                                                //Mandatory //Multiple options
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    //Mandatory
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 5),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    12)),
                                                        border: Border.all(
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      child: Text(
                                                          (productOptions[i]
                                                                  ['Mandatory'])
                                                              ? 'Obligatorio'
                                                              : 'Opcional'),
                                                    ),
                                                    SizedBox(width: 10),
                                                    //Multiple Options
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 5),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    12)),
                                                        border: Border.all(
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      child: Text((productOptions[
                                                                  i][
                                                              'Multiple Options'])
                                                          ? 'Selección múltiple'
                                                          : 'Selección única'),
                                                    ),
                                                    SizedBox(width: 10),
                                                    //Price Structure
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 5),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    12)),
                                                        border: Border.all(
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      child: Text((productOptions[
                                                                      i][
                                                                  'Price Structure'] ==
                                                              'Aditional')
                                                          ? 'Precio adicional'
                                                          : (productOptions[i][
                                                                      'Price Structure'] ==
                                                                  'Complete')
                                                              ? 'Reemplaza el precio'
                                                              : 'Sin costo adicional'),
                                                    ),
                                                  ],
                                                ),

                                                SizedBox(height: 10),
                                                //OPTIONS
                                                ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount: productOptions[i]
                                                            ['Price Options']
                                                        .length,
                                                    itemBuilder: ((context, x) {
                                                      if (productOptions[i][
                                                                      'Price Options']
                                                                  [
                                                                  x]['Price'] !=
                                                              0 &&
                                                          productOptions[i][
                                                                      'Price Options']
                                                                  [
                                                                  x]['Price'] !=
                                                              null) {
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 15.0),
                                                          child: Text(
                                                              '• ${productOptions[i]['Price Options'][x]['Option']}  (+\$${productOptions[i]['Price Options'][x]['Price']})'),
                                                        );
                                                      } else {
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 15.0),
                                                          child: Text(
                                                              '• ${productOptions[i]['Price Options'][x]['Option']}'),
                                                        );
                                                      }
                                                    })),
                                              ],
                                            ),
                                          );
                                        })),
                                //Agregar Lista de opciones
                                Tooltip(
                                  message: 'Agregar opciones del producto',
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.black,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return ProductOptionsDialog(
                                                setProductOptions, false);
                                          });
                                    },
                                    child: Container(
                                      height: 70,
                                      width: 70,
                                      child: Center(
                                          child: Icon(
                                        Icons.add,
                                        color: Colors.black87,
                                        size: 30,
                                      )),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                //Ingredientes
                                Text(
                                  'Insumos asociados (opcional)',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: Colors.black45),
                                ),
                                SizedBox(height: 15),
                                (ingredients.length == 0)
                                    ? SizedBox()
                                    : ListView.builder(
                                        key: redrawObject,
                                        shrinkWrap: true,
                                        itemCount: ingredients.length,
                                        itemBuilder: ((context, i) {
                                          double ingredientTotal = ((ingredients[
                                                          i]['Supply Cost'] /
                                                      ingredients[i]
                                                          ['Supply Quantity']) *
                                                  ingredients[i]['Quantity']) /
                                              ingredients[i]['Yield'];

                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 15.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                //Ingrediente
                                                Expanded(
                                                  flex: 6,
                                                  child: Container(
                                                    width: double.infinity,
                                                    child: TextFormField(
                                                      enabled: false,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 14),
                                                      cursorColor: Colors.grey,
                                                      initialValue:
                                                          ingredients[i]
                                                              ['Ingredient'],
                                                      decoration:
                                                          InputDecoration(
                                                        focusColor:
                                                            Colors.black,
                                                        hintStyle: TextStyle(
                                                            color:
                                                                Colors.black45,
                                                            fontSize: 12),
                                                        errorStyle: TextStyle(
                                                            color: Colors
                                                                .redAccent[700],
                                                            fontSize: 12),
                                                        border:
                                                            new OutlineInputBorder(
                                                          borderRadius:
                                                              new BorderRadius
                                                                  .circular(
                                                                  12.0),
                                                          borderSide:
                                                              new BorderSide(
                                                            color: Colors
                                                                .grey[350]!,
                                                          ),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              new BorderRadius
                                                                  .circular(
                                                                  12.0),
                                                          borderSide:
                                                              new BorderSide(
                                                            color: Colors.green,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 15),
                                                //Amount
                                                Expanded(
                                                  flex: 3,
                                                  child: Container(
                                                    width: double.infinity,
                                                    child: TextFormField(
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 14),
                                                      textAlign:
                                                          TextAlign.center,
                                                      initialValue: ingredients[
                                                                      i][
                                                                  'Quantity'] ==
                                                              0
                                                          ? ''
                                                          : '${ingredients[i]['Quantity']}',
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter
                                                            .allow(RegExp(
                                                                r'[0-9]+[,.]{0,1}[0-9]*')),
                                                        TextInputFormatter
                                                            .withFunction(
                                                          (oldValue,
                                                                  newValue) =>
                                                              newValue.copyWith(
                                                            text: newValue.text
                                                                .replaceAll(
                                                                    ',', '.'),
                                                          ),
                                                        ),
                                                      ],
                                                      cursorColor: Colors.grey,
                                                      decoration:
                                                          InputDecoration(
                                                        floatingLabelStyle:
                                                            TextStyle(
                                                                color: Colors
                                                                    .grey),
                                                        labelStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 12),
                                                        labelText: (ingredients[
                                                                        i]
                                                                    ['Unit'] !=
                                                                null)
                                                            ? ingredients[i]
                                                                ['Unit']
                                                            : 'Cantidad',
                                                        focusColor:
                                                            Colors.black,
                                                        hintStyle: TextStyle(
                                                            color:
                                                                Colors.black45,
                                                            fontSize: 12),
                                                        errorStyle: TextStyle(
                                                            color: Colors
                                                                .redAccent[700],
                                                            fontSize: 12),
                                                        border:
                                                            new OutlineInputBorder(
                                                          borderRadius:
                                                              new BorderRadius
                                                                  .circular(
                                                                  12.0),
                                                          borderSide:
                                                              new BorderSide(
                                                            color: Colors
                                                                .grey[350]!,
                                                          ),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              new BorderRadius
                                                                  .circular(
                                                                  12.0),
                                                          borderSide:
                                                              new BorderSide(
                                                            color: Colors.green,
                                                          ),
                                                        ),
                                                      ),
                                                      onChanged: (value) {
                                                        String newValue =
                                                            value.toString();
                                                        try {
                                                          double newPrice =
                                                              double.parse(
                                                                  newValue);
                                                          setState(() {
                                                            ingredients[i][
                                                                    'Quantity'] =
                                                                newPrice;
                                                          });
                                                        } catch (e) {
                                                          print(e);
                                                          // priceOptions[i]['Price'] =
                                                          //     double.parse(newValue);
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 15),
                                                //Yield
                                                Expanded(
                                                  flex: 3,
                                                  child: Container(
                                                    width: double.infinity,
                                                    child: TextFormField(
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 14),
                                                      textAlign:
                                                          TextAlign.center,
                                                      initialValue: ingredients[
                                                                  i]['Yield'] ==
                                                              0
                                                          ? ''
                                                          : '${ingredients[i]['Yield']}',
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter
                                                            .allow(RegExp(
                                                                r'[0-9]+[,.]{0,1}[0-9]*')),
                                                        TextInputFormatter
                                                            .withFunction(
                                                          (oldValue,
                                                                  newValue) =>
                                                              newValue.copyWith(
                                                            text: newValue.text
                                                                .replaceAll(
                                                                    ',', '.'),
                                                          ),
                                                        ),
                                                      ],
                                                      cursorColor: Colors.grey,
                                                      decoration:
                                                          InputDecoration(
                                                        labelText: 'Rinde para',
                                                        floatingLabelStyle:
                                                            TextStyle(
                                                                color: Colors
                                                                    .grey),
                                                        labelStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 12),
                                                        focusColor:
                                                            Colors.black,
                                                        hintStyle: TextStyle(
                                                            color:
                                                                Colors.black45,
                                                            fontSize: 12),
                                                        errorStyle: TextStyle(
                                                            color: Colors
                                                                .redAccent[700],
                                                            fontSize: 12),
                                                        border:
                                                            new OutlineInputBorder(
                                                          borderRadius:
                                                              new BorderRadius
                                                                  .circular(
                                                                  12.0),
                                                          borderSide:
                                                              new BorderSide(
                                                            color: Colors
                                                                .grey[350]!,
                                                          ),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              new BorderRadius
                                                                  .circular(
                                                                  12.0),
                                                          borderSide:
                                                              new BorderSide(
                                                            color: Colors.green,
                                                          ),
                                                        ),
                                                      ),
                                                      onChanged: (value) {
                                                        String newValue =
                                                            value.toString();
                                                        try {
                                                          double newPrice =
                                                              double.parse(
                                                                  newValue);
                                                          setState(() {
                                                            ingredients[i]
                                                                    ['Yield'] =
                                                                newPrice;
                                                          });
                                                        } catch (e) {
                                                          print(e);
                                                          // priceOptions[i]['Price'] =
                                                          //     double.parse(newValue);
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 15),
                                                //Cost
                                                Expanded(
                                                    flex: 3,
                                                    child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              new BorderRadius
                                                                  .circular(
                                                                  12.0),
                                                          border: Border.all(
                                                            color: Colors
                                                                .grey[350]!,
                                                          ),
                                                        ),
                                                        padding:
                                                            EdgeInsets.all(15),
                                                        child: Center(
                                                          child: Text(
                                                            (ingredientTotal
                                                                        .isNaN ||
                                                                    ingredientTotal
                                                                        .isInfinite ||
                                                                    ingredientTotal
                                                                        .isNegative)
                                                                ? '0'
                                                                : '\$${ingredientTotal.toStringAsFixed(0)}',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ))),
                                                //Delete
                                                IconButton(
                                                    tooltip: 'Eliminar',
                                                    padding: EdgeInsets.all(2),
                                                    splashRadius: 5,
                                                    onPressed: () {
                                                      ingredients.removeAt(i);

                                                      final random = Random();
                                                      const availableChars =
                                                          'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
                                                      final randomString = List.generate(
                                                          10,
                                                          (index) => availableChars[
                                                              random.nextInt(
                                                                  availableChars
                                                                      .length)]).join();
                                                      setState(() {
                                                        redrawObject = ValueKey(
                                                            randomString);
                                                      });
                                                    },
                                                    icon: Icon(
                                                      Icons.close,
                                                      size: 16,
                                                    ))
                                              ],
                                            ),
                                          );
                                        })),

                                SizedBox(
                                    height: (ingredients.length == 0) ? 0 : 10),
                                (ingredients.length == 0)
                                    ? SizedBox()
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text('Costo total del producto: '),
                                          Text(
                                            formatCurrency
                                                .format(totalIngredientsCost()),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                          SizedBox(
                                            width: 50,
                                          )
                                        ],
                                      ),
                                SizedBox(
                                    height: (ingredients.length == 0) ? 0 : 20),
                                //Agregar ingrediente
                                Tooltip(
                                  message: 'Agregar insumo',
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.black,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: ((context) =>
                                              SuppliesListDialog(selectSupply,
                                                  widget.activeBusiness)));
                                    },
                                    child: Container(
                                      height: 70,
                                      width: 70,
                                      child: Center(
                                          child: Icon(
                                        Icons.add,
                                        color: Colors.black87,
                                        size: 30,
                                      )),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    height: (ingredients.length == 0) ? 0 : 20),
                                //Expected Margin/Low margin
                                (ingredients.length == 0)
                                    ? SizedBox()
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          //Current Margin
                                          Expanded(
                                            flex: 5,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Margen de ganancia actual',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 12,
                                                      color: Colors.black45),
                                                ),
                                                SizedBox(height: 10),
                                                Container(
                                                  width: double.infinity,
                                                  height: 45,
                                                  child: Center(
                                                    child: Text(
                                                        '${(((price - totalIngredientsCost()) / price) * 100).toStringAsFixed(1)}%',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18,
                                                            color: ((((price - totalIngredientsCost()) /
                                                                            price) *
                                                                        100) <
                                                                    lowMarginAlert!)
                                                                ? Colors.red
                                                                : Colors.greenAccent[
                                                                    700])),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 20),
                                          //Expected Margin
                                          Expanded(
                                            flex: 5,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Margen esperado',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 12,
                                                      color: Colors.black45),
                                                ),
                                                SizedBox(height: 10),
                                                Container(
                                                  width: double.infinity,
                                                  child: TextFormField(
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14),
                                                    cursorColor: Colors.grey,
                                                    initialValue:
                                                        (expectedMargin != null)
                                                            ? expectedMargin
                                                                .toString()
                                                            : '',
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter
                                                          .digitsOnly,
                                                      LengthLimitingTextInputFormatter(
                                                          2),
                                                    ],
                                                    decoration: InputDecoration(
                                                      focusColor: Colors.black,
                                                      suffixIcon: Icon(
                                                          Icons
                                                              .percent_outlined,
                                                          color: Colors.grey,
                                                          size: 16),
                                                      hintStyle: TextStyle(
                                                          color: Colors.black45,
                                                          fontSize: 14),
                                                      errorStyle: TextStyle(
                                                          color: Colors
                                                              .redAccent[700],
                                                          fontSize: 12),
                                                      border:
                                                          new OutlineInputBorder(
                                                        borderRadius:
                                                            new BorderRadius
                                                                .circular(12.0),
                                                        borderSide:
                                                            new BorderSide(
                                                          color:
                                                              Colors.grey[350]!,
                                                        ),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            new BorderRadius
                                                                .circular(12.0),
                                                        borderSide:
                                                            new BorderSide(
                                                          color: Colors.green,
                                                        ),
                                                      ),
                                                    ),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        expectedMargin =
                                                            double.parse(value);
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 20),
                                          //Low Margin Alert
                                          Expanded(
                                            flex: 5,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Alerta de bajo margen',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 12,
                                                      color: Colors.black45),
                                                ),
                                                SizedBox(height: 10),
                                                Container(
                                                  width: double.infinity,
                                                  child: TextFormField(
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14),
                                                    cursorColor: Colors.grey,
                                                    initialValue:
                                                        (lowMarginAlert != null)
                                                            ? lowMarginAlert
                                                                .toString()
                                                            : '',
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter
                                                          .digitsOnly,
                                                      LengthLimitingTextInputFormatter(
                                                          2),
                                                    ],
                                                    decoration: InputDecoration(
                                                      suffixIcon: Icon(
                                                          Icons
                                                              .percent_outlined,
                                                          color: Colors.grey,
                                                          size: 16),
                                                      focusColor: Colors.black,
                                                      hintStyle: TextStyle(
                                                          color: Colors.black45,
                                                          fontSize: 14),
                                                      errorStyle: TextStyle(
                                                          color: Colors
                                                              .redAccent[700],
                                                          fontSize: 12),
                                                      border:
                                                          new OutlineInputBorder(
                                                        borderRadius:
                                                            new BorderRadius
                                                                .circular(12.0),
                                                        borderSide:
                                                            new BorderSide(
                                                          color:
                                                              Colors.grey[350]!,
                                                        ),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            new BorderRadius
                                                                .circular(12.0),
                                                        borderSide:
                                                            new BorderSide(
                                                          color: Colors.green,
                                                        ),
                                                      ),
                                                    ),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        lowMarginAlert =
                                                            double.parse(value);
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                //Button
                                SizedBox(height: 35),
                                (widget.product == null)
                                    ? ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.black),
                                          overlayColor: MaterialStateProperty
                                              .resolveWith<Color?>(
                                            (Set<MaterialState> states) {
                                              if (states.contains(
                                                  MaterialState.hovered))
                                                return Colors.grey;
                                              if (states.contains(
                                                      MaterialState.focused) ||
                                                  states.contains(
                                                      MaterialState.pressed))
                                                return Colors.grey.shade300;
                                              return null; // Defer to the widget's default.
                                            },
                                          ),
                                        ),
                                        onPressed: () {
                                          if (newProduct) {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              if (ingredients.length > 0) {
                                                for (int i = 0;
                                                    i < ingredients.length;
                                                    i++) {
                                                  listOfIngredients.add(
                                                      ingredients[i]
                                                          ['Ingredient']);
                                                }
                                              }
                                              if (changedImage) {
                                                uploadPic(widget.activeBusiness).then(
                                                    (value) => DatabaseService()
                                                        .createProduct(
                                                            widget
                                                                .activeBusiness,
                                                            name,
                                                            downloadUrl,
                                                            category,
                                                            price,
                                                            description,
                                                            productOptions,
                                                            setSearchParam(name
                                                                .toLowerCase()),
                                                            code,
                                                            listOfIngredients,
                                                            ingredients,
                                                            (widget.businessField ==
                                                                    'Gatronómico')
                                                                ? vegan
                                                                : null,
                                                            show,
                                                            featured,
                                                            expectedMargin,
                                                            lowMarginAlert));
                                              } else {
                                                DatabaseService().createProduct(
                                                    widget.activeBusiness,
                                                    name,
                                                    '',
                                                    category,
                                                    price,
                                                    description,
                                                    productOptions,
                                                    setSearchParam(
                                                        name.toLowerCase()),
                                                    code,
                                                    listOfIngredients,
                                                    ingredients,
                                                    (widget.businessField ==
                                                            'Gatronómico')
                                                        ? vegan
                                                        : null,
                                                    show,
                                                    featured,
                                                    expectedMargin,
                                                    lowMarginAlert);
                                              }

                                              Navigator.of(context).pop();
                                            }
                                          } else {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              if (ingredients.length > 0) {
                                                for (int i = 0;
                                                    i < ingredients.length;
                                                    i++) {
                                                  listOfIngredients.add(
                                                      ingredients[i]
                                                          ['Ingredient']);
                                                }
                                              }
                                              if (changedImage) {
                                                if (widget.product!.price !=
                                                    price) {
                                                  try {
                                                    historicPrices
                                                            .last['To Date'] =
                                                        DateTime.now();

                                                    historicPrices.add({
                                                      'From Date':
                                                          DateTime.now(),
                                                      'To Date': null,
                                                      'Price': price
                                                    });
                                                  } catch (e) {
                                                    print(e);
                                                    historicPrices = [
                                                      {
                                                        'From Date':
                                                            DateTime.now(),
                                                        'To Date': null,
                                                        'Price': price
                                                      }
                                                    ];
                                                  }
                                                }
                                                uploadPic(widget.activeBusiness).then(
                                                    (value) => DatabaseService()
                                                        .editProduct(
                                                            widget
                                                                .activeBusiness,
                                                            widget.product!
                                                                .productID,
                                                            isAvailable,
                                                            name,
                                                            downloadUrl,
                                                            category,
                                                            price,
                                                            description,
                                                            productOptions,
                                                            setSearchParam(name
                                                                .toLowerCase()),
                                                            code,
                                                            listOfIngredients,
                                                            ingredients,
                                                            (widget.businessField ==
                                                                    'Gatronómico')
                                                                ? vegan
                                                                : null,
                                                            show,
                                                            historicPrices,
                                                            featured,
                                                            expectedMargin!,
                                                            lowMarginAlert!));
                                              } else {
                                                if (widget.product!.price !=
                                                    price) {
                                                  try {
                                                    historicPrices
                                                            .last['To Date'] =
                                                        DateTime.now();

                                                    historicPrices.add({
                                                      'From Date':
                                                          DateTime.now(),
                                                      'To Date': null,
                                                      'Price': price
                                                    });
                                                  } catch (e) {
                                                    print(e);
                                                    historicPrices = [
                                                      {
                                                        'From Date':
                                                            DateTime.now(),
                                                        'To Date': null,
                                                        'Price': price
                                                      }
                                                    ];
                                                  }
                                                }
                                                DatabaseService().editProduct(
                                                    widget.activeBusiness,
                                                    widget.product!.productID,
                                                    isAvailable,
                                                    name,
                                                    image,
                                                    category,
                                                    price,
                                                    description,
                                                    productOptions,
                                                    setSearchParam(
                                                        name.toLowerCase()),
                                                    code,
                                                    listOfIngredients,
                                                    ingredients,
                                                    (widget.businessField ==
                                                            'Gatronómico')
                                                        ? vegan
                                                        : null,
                                                    show,
                                                    historicPrices,
                                                    featured,
                                                    expectedMargin!,
                                                    lowMarginAlert!);
                                              }
                                              Navigator.of(context).pop();
                                            }
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 15),
                                          child: Center(
                                            child: Text((newProduct)
                                                ? 'Crear'
                                                : 'Guardar cambios'),
                                          ),
                                        ))
                                    : Container(
                                        width: double.infinity,
                                        child: Row(
                                          children: [
                                            //Save
                                            Expanded(
                                              child: ElevatedButton(
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                Colors.black),
                                                    overlayColor:
                                                        MaterialStateProperty
                                                            .resolveWith<
                                                                Color?>(
                                                      (Set<MaterialState>
                                                          states) {
                                                        if (states.contains(
                                                            MaterialState
                                                                .hovered))
                                                          return Colors.grey;
                                                        if (states.contains(
                                                                MaterialState
                                                                    .focused) ||
                                                            states.contains(
                                                                MaterialState
                                                                    .pressed))
                                                          return Colors
                                                              .grey.shade300;
                                                        return null; // Defer to the widget's default.
                                                      },
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    if (newProduct) {
                                                      if (_formKey.currentState!
                                                          .validate()) {
                                                        if (widget
                                                                .product!
                                                                .ingredients!
                                                                .length >
                                                            0) {
                                                          for (int i = 0;
                                                              i <
                                                                  ingredients
                                                                      .length;
                                                              i++) {
                                                            listOfIngredients
                                                                .add(ingredients[
                                                                        i][
                                                                    'Ingredient']);
                                                          }
                                                        }
                                                        if (changedImage) {
                                                          uploadPic(widget.activeBusiness).then((value) => DatabaseService().createProduct(
                                                              widget
                                                                  .activeBusiness,
                                                              name,
                                                              downloadUrl,
                                                              category,
                                                              price,
                                                              description,
                                                              productOptions,
                                                              setSearchParam(name
                                                                  .toLowerCase()),
                                                              code,
                                                              listOfIngredients,
                                                              ingredients,
                                                              (widget.businessField ==
                                                                      'Gatronómico')
                                                                  ? vegan
                                                                  : null,
                                                              show,
                                                              featured,
                                                              expectedMargin,
                                                              lowMarginAlert));
                                                        } else {
                                                          DatabaseService().createProduct(
                                                              widget
                                                                  .activeBusiness,
                                                              name,
                                                              '',
                                                              category,
                                                              price,
                                                              description,
                                                              productOptions,
                                                              setSearchParam(name
                                                                  .toLowerCase()),
                                                              code,
                                                              listOfIngredients,
                                                              ingredients,
                                                              (widget.businessField ==
                                                                      'Gatronómico')
                                                                  ? vegan
                                                                  : null,
                                                              show,
                                                              featured,
                                                              expectedMargin,
                                                              lowMarginAlert);
                                                        }

                                                        Navigator.of(context)
                                                            .pop();
                                                      }
                                                    } else {
                                                      if (_formKey.currentState!
                                                          .validate()) {
                                                        if (ingredients.length >
                                                            0) {
                                                          for (int i = 0;
                                                              i <
                                                                  ingredients
                                                                      .length;
                                                              i++) {
                                                            listOfIngredients
                                                                .add(ingredients[
                                                                        i][
                                                                    'Ingredient']);
                                                          }
                                                        }
                                                        if (changedImage) {
                                                          if (widget.product!
                                                                  .price !=
                                                              price) {
                                                            if (historicPrices
                                                                    .length >
                                                                0) {
                                                              historicPrices
                                                                          .last[
                                                                      'To Date'] =
                                                                  DateTime
                                                                      .now();

                                                              historicPrices
                                                                  .add({
                                                                'From Date':
                                                                    DateTime
                                                                        .now(),
                                                                'To Date': null,
                                                                'Price': price
                                                              });
                                                            } else {
                                                              historicPrices = [
                                                                {
                                                                  'From Date':
                                                                      DateTime
                                                                          .now(),
                                                                  'To Date':
                                                                      null,
                                                                  'Price': price
                                                                }
                                                              ];
                                                            }
                                                          }
                                                          uploadPic(widget.activeBusiness).then((value) => DatabaseService().editProduct(
                                                              widget
                                                                  .activeBusiness,
                                                              widget.product!
                                                                  .productID,
                                                              isAvailable,
                                                              name,
                                                              downloadUrl,
                                                              category,
                                                              price,
                                                              description,
                                                              productOptions,
                                                              setSearchParam(name
                                                                  .toLowerCase()),
                                                              code,
                                                              listOfIngredients,
                                                              ingredients,
                                                              (widget.businessField ==
                                                                      'Gatronómico')
                                                                  ? vegan
                                                                  : null,
                                                              show,
                                                              historicPrices,
                                                              featured,
                                                              expectedMargin!,
                                                              lowMarginAlert!));
                                                        } else {
                                                          if (widget.product!
                                                                  .price !=
                                                              price) {
                                                            if (historicPrices
                                                                    .length >
                                                                0) {
                                                              historicPrices
                                                                          .last[
                                                                      'To Date'] =
                                                                  DateTime
                                                                      .now();

                                                              historicPrices
                                                                  .add({
                                                                'From Date':
                                                                    DateTime
                                                                        .now(),
                                                                'To Date': null,
                                                                'Price': price
                                                              });
                                                            } else {
                                                              historicPrices = [
                                                                {
                                                                  'From Date':
                                                                      DateTime
                                                                          .now(),
                                                                  'To Date':
                                                                      null,
                                                                  'Price': price
                                                                }
                                                              ];
                                                            }
                                                          }
                                                          DatabaseService().editProduct(
                                                              widget
                                                                  .activeBusiness,
                                                              widget.product!
                                                                  .productID,
                                                              isAvailable,
                                                              name,
                                                              image,
                                                              category,
                                                              price,
                                                              description,
                                                              productOptions,
                                                              setSearchParam(name
                                                                  .toLowerCase()),
                                                              code,
                                                              listOfIngredients,
                                                              ingredients,
                                                              (widget.businessField ==
                                                                      'Gatronómico')
                                                                  ? vegan
                                                                  : null,
                                                              show,
                                                              historicPrices,
                                                              featured,
                                                              expectedMargin!,
                                                              lowMarginAlert!);
                                                        }
                                                        Navigator.of(context)
                                                            .pop();
                                                      }
                                                    }
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 20,
                                                        vertical: 15),
                                                    child: Center(
                                                      child: Text((newProduct)
                                                          ? 'Crear'
                                                          : 'Guardar cambios'),
                                                    ),
                                                  )),
                                            ),
                                            SizedBox(width: 20),
                                            //Delete
                                            Container(
                                              height: 45,
                                              width: 45,
                                              child: Tooltip(
                                                message: 'Eliminar producto',
                                                child: OutlinedButton(
                                                  style: ButtonStyle(
                                                    padding: MaterialStateProperty
                                                        .all<EdgeInsetsGeometry>(
                                                            EdgeInsets.all(5)),
                                                    alignment: Alignment.center,
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                Colors.white70),
                                                    overlayColor:
                                                        MaterialStateProperty
                                                            .resolveWith<
                                                                Color?>(
                                                      (Set<MaterialState>
                                                          states) {
                                                        if (states.contains(
                                                            MaterialState
                                                                .hovered))
                                                          return Colors
                                                              .grey.shade300;
                                                        if (states.contains(
                                                                MaterialState
                                                                    .focused) ||
                                                            states.contains(
                                                                MaterialState
                                                                    .pressed))
                                                          return Colors.white;
                                                        return null; // Defer to the widget's default.
                                                      },
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    DatabaseService()
                                                        .deleteProduct(
                                                            widget
                                                                .activeBusiness,
                                                            widget.product!
                                                                .productID!);
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Center(
                                                      child: Icon(
                                                    Icons.delete,
                                                    color: Colors.black,
                                                    size: 18,
                                                  )),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
            SizedBox(height: 20),
          ],
        )),
      );
    } else {
      return Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //Title
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.arrow_back),
                    iconSize: 20.0),
                SizedBox(width: 25),
                Text(
                  widget.product == null ? 'Nuevo producto' : 'Editar producto',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28),
                ),
              ],
            ),
            SizedBox(height: 20),
            //Form
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                //Image
                (changedImage)
                    ? Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            border: Border.all(color: Colors.grey.shade300),
                            color: Colors.grey,
                            image: DecorationImage(
                                image: Image.memory(
                                  webImage,
                                  fit: BoxFit.cover,
                                ).image,
                                fit: BoxFit.cover)))
                    : (!newProduct && image != '')
                        ? Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25)),
                                border: Border.all(color: Colors.grey.shade300),
                                color: Colors.grey.shade200,
                                image: DecorationImage(
                                    image: NetworkImage(widget.product!.image!),
                                    fit: BoxFit.cover)),
                          )
                        : Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25)),
                              border: Border.all(color: Colors.grey.shade300),
                              color: Colors.grey.shade200,
                            ),
                            child: Center(
                              child:
                                  Icon(Icons.add_a_photo, color: Colors.grey),
                            ),
                          ),

                SizedBox(height: 15),
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
                  onPressed: getImage,
                  child: Container(
                    height: 35,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 2.0, horizontal: 2),
                    child: Center(
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.edit,
                              color: Colors.black,
                              size: 12,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Editar imagen',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400),
                            ),
                          ]),
                    ),
                  ),
                ),

                SizedBox(height: 20),
                //Main Data
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Code
                      Text(
                        'Código interno (opcional)',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Colors.black45),
                      ),
                      SizedBox(height: 5),
                      Container(
                        width: double.infinity,
                        child: TextFormField(
                          style: TextStyle(color: Colors.black, fontSize: 14),
                          cursorColor: Colors.grey,
                          initialValue: code,
                          decoration: InputDecoration(
                            hintText: 'xxx',
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
                              code = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 15),
                      //Name
                      Text(
                        'Nombre del producto*',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Colors.black45),
                      ),
                      SizedBox(height: 5),
                      Container(
                        width: double.infinity,
                        child: TextFormField(
                          style: TextStyle(color: Colors.black, fontSize: 14),
                          cursorColor: Colors.grey,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Agrega un nombre";
                            } else {
                              return null;
                            }
                          },
                          initialValue: name,
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
                      SizedBox(height: 15),
                      //Price
                      Text(
                        'Precio de venta*',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Colors.black45),
                      ),
                      SizedBox(height: 5),
                      Container(
                        width: double.infinity,
                        child: TextFormField(
                          style: TextStyle(color: Colors.black, fontSize: 14),
                          cursorColor: Colors.grey,
                          initialValue: (price > 0) ? price.toString() : '',
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
                            TextInputFormatter.withFunction(
                              (oldValue, newValue) => newValue.copyWith(
                                text: newValue.text.replaceAll(',', '.'),
                              ),
                            ),
                          ],
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Agrega un precio";
                            } else {
                              return null;
                            }
                          },
                          decoration: InputDecoration(
                            hintText: '0.00',
                            prefixIcon: Icon(
                              Icons.attach_money,
                              color: Colors.grey,
                            ),
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
                            if (value != '') {
                              setState(() {
                                price = double.parse(value);
                              });
                            } else {
                              setState(() {
                                price = 0;
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 15),
                      //Available//Show
                      Container(
                        width: double.infinity,
                        height: 75,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            //Available
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Disponible',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: Colors.black45),
                                  ),
                                  SizedBox(height: 10),
                                  Switch(
                                    value: isAvailable,
                                    onChanged: (value) {
                                      setState(() {
                                        isAvailable = value;
                                      });
                                    },
                                    activeTrackColor: Colors.lightGreenAccent,
                                    activeColor: Colors.green,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 20),
                            //Show on menu
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mostrar en catálogo digital',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: Colors.black45),
                                  ),
                                  SizedBox(height: 10),
                                  Switch(
                                    value: show,
                                    onChanged: (value) {
                                      setState(() {
                                        show = value;
                                      });
                                    },
                                    activeTrackColor: Colors.lightGreenAccent,
                                    activeColor: Colors.green,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      //Dropdown categories
                      Container(
                        width: double.infinity,
                        height: 75,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            //Categories
                            Expanded(
                              flex: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Categoría',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: Colors.black45),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 12),
                                      child: DropdownButton(
                                        isExpanded: true,
                                        underline: SizedBox(),
                                        hint: Text(
                                          widget.categories[0],
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                              color: Colors.grey[700]),
                                        ),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            color: Colors.grey[700]),
                                        value: category,
                                        items: widget.categories.map((x) {
                                          return new DropdownMenuItem(
                                            value: x,
                                            child: new Text(x),
                                            onTap: () {
                                              setState(() {
                                                category = x;
                                              });
                                            },
                                          );
                                        }).toList(),
                                        onChanged: (newValue) {
                                          setState(() {
                                            category = newValue.toString();
                                          });
                                        },
                                      )),
                                ],
                              ),
                            ),
                            SizedBox(width: 20),
                            //Featured
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Destacado',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: Colors.black45),
                                  ),
                                  SizedBox(height: 10),
                                  IconButton(
                                      tooltip:
                                          'Los productos destacados se verán primero en tu catálogo digital',
                                      onPressed: () {
                                        setState(() {
                                          featured = !featured;
                                        });
                                      },
                                      icon: !featured
                                          ? Icon(
                                              Icons.star_border_outlined,
                                              size: 30,
                                              color: Colors.grey,
                                            )
                                          : Icon(
                                              Icons.star,
                                              size: 30,
                                              color: Colors.yellow,
                                            ))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      //Description
                      Text(
                        'Descripción (opcional)',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Colors.black45),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        minLines: 5,
                        maxLines: 10,
                        style: TextStyle(color: Colors.black, fontSize: 14),
                        cursorColor: Colors.grey,
                        initialValue: description,
                        decoration: InputDecoration(
                          hintText: 'Descripción del producto',
                          focusColor: Colors.black,
                          hintStyle:
                              TextStyle(color: Colors.black45, fontSize: 14),
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
                            description = value;
                          });
                        },
                      ),
                      SizedBox(height: 15),
                      //Vegan
                      (widget.businessField == 'Gastronómico')
                          ? //Available
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Vegano',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: Colors.black45),
                                ),
                                SizedBox(height: 10),
                                Switch(
                                  value: vegan,
                                  onChanged: (value) {
                                    setState(() {
                                      vegan = value;
                                    });
                                  },
                                  activeTrackColor: Colors.lightGreenAccent,
                                  activeColor: Colors.green,
                                ),
                              ],
                            )
                          : SizedBox(),
                      (widget.businessField == 'Gastronómico')
                          ? SizedBox(height: 20)
                          : SizedBox(),
                      //Product Options
                      Text(
                        'Opciones del producto (opcional)',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Colors.black45),
                      ),
                      SizedBox(height: 10),
                      (productOptions.length == 0)
                          ? SizedBox()
                          : ListView.builder(
                              key: redrawObject2,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: productOptions.length,
                              itemBuilder: ((context, i) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 15.0),
                                  child: Column(
                                    children: [
                                      //TITLE
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          //Title
                                          Expanded(
                                            flex: 9,
                                            child: Text(
                                              productOptions[i]['Title'],
                                              maxLines: 5,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          SizedBox(width: 20),
                                          //Edit
                                          IconButton(
                                              onPressed: () {
                                                showModalBottomSheet(
                                                    isScrollControlled: true,
                                                    context: context,
                                                    backgroundColor: Colors
                                                        .white,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topRight: Radius
                                                                    .circular(
                                                                        25),
                                                                topLeft: Radius
                                                                    .circular(
                                                                        25))),
                                                    builder: (context) {
                                                      return ProductOptionsDialog(
                                                        setProductOptions,
                                                        true,
                                                        optionTitle:
                                                            productOptions[i]
                                                                ['Title'],
                                                        mandatory:
                                                            productOptions[i]
                                                                ['Mandatory'],
                                                        multipleOptions:
                                                            productOptions[i][
                                                                'Multiple Options'],
                                                        priceStructure:
                                                            productOptions[i][
                                                                'Price Structure'],
                                                        optionsList:
                                                            productOptions[i][
                                                                'Price Options'],
                                                        index: i,
                                                      );
                                                    });
                                              },
                                              icon: Icon(Icons.edit)),
                                          SizedBox(width: 5),

                                          //Delete
                                          IconButton(
                                              onPressed: () {
                                                productOptions.removeAt(i);

                                                final random = Random();
                                                const availableChars =
                                                    'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
                                                final randomString = List.generate(
                                                    10,
                                                    (index) => availableChars[
                                                        random.nextInt(
                                                            availableChars
                                                                .length)]).join();
                                                setState(() {
                                                  redrawObject2 =
                                                      ValueKey(randomString);
                                                });
                                              },
                                              icon: Icon(Icons.delete))
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      //Mandatory //Multiple options
                                      Container(
                                        height: 40,
                                        width: double.infinity,
                                        child: ListView(
                                          scrollDirection: Axis.horizontal,
                                          children: [
                                            //Mandatory
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 5),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(12)),
                                                border: Border.all(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text((productOptions[i]
                                                        ['Mandatory'])
                                                    ? 'Obligatorio'
                                                    : 'Opcional'),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            //Multiple Options
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 5),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(12)),
                                                border: Border.all(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text((productOptions[i]
                                                        ['Multiple Options'])
                                                    ? 'Selección múltiple'
                                                    : 'Selección única'),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            //Price Structure
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 5),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(12)),
                                                border: Border.all(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text((productOptions[i][
                                                            'Price Structure'] ==
                                                        'Aditional')
                                                    ? 'Precio adicional'
                                                    : (productOptions[i][
                                                                'Price Structure'] ==
                                                            'Complete')
                                                        ? 'Reemplaza el precio'
                                                        : 'Sin costo adicional'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      SizedBox(height: 10),
                                      //OPTIONS
                                      ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: productOptions[i]
                                                  ['Price Options']
                                              .length,
                                          itemBuilder: ((context, x) {
                                            if (productOptions[i]
                                                            ['Price Options'][x]
                                                        ['Price'] !=
                                                    0 &&
                                                productOptions[i]
                                                            ['Price Options'][x]
                                                        ['Price'] !=
                                                    null) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 15.0),
                                                child: Text(
                                                    '• ${productOptions[i]['Price Options'][x]['Option']}  (+\$${productOptions[i]['Price Options'][x]['Price']})'),
                                              );
                                            } else {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 15.0),
                                                child: Text(
                                                    '• ${productOptions[i]['Price Options'][x]['Option']}'),
                                              );
                                            }
                                          })),
                                    ],
                                  ),
                                );
                              })),
                      //Agregar Lista de opciones
                      Tooltip(
                        message: 'Agregar opciones del producto',
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(25),
                                        topLeft: Radius.circular(25))),
                                builder: (context) {
                                  return ProductOptionsDialog(
                                      setProductOptions, false);
                                });
                          },
                          child: Container(
                            height: 70,
                            width: 70,
                            child: Center(
                                child: Icon(
                              Icons.add,
                              color: Colors.black87,
                              size: 30,
                            )),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      //Ingredientes
                      Text(
                        'Insumos asociados (opcional)',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Colors.black45),
                      ),
                      SizedBox(height: 15),
                      (ingredients.length == 0)
                          ? SizedBox()
                          : ListView.builder(
                              key: redrawObject,
                              shrinkWrap: true,
                              itemCount: ingredients.length,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: ((context, i) {
                                double ingredientTotal = ((ingredients[i]
                                                ['Supply Cost'] /
                                            ingredients[i]['Supply Quantity']) *
                                        ingredients[i]['Quantity']) /
                                    ingredients[i]['Yield'];

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 15.0),
                                  child: Container(
                                    width: double.infinity,
                                    height: 120,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        //Ingrediente
                                        Container(
                                          width: double.infinity,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                (ingredientTotal.isNaN ||
                                                        ingredientTotal
                                                            .isInfinite ||
                                                        ingredientTotal
                                                            .isNegative)
                                                    ? '${ingredients[i]['Ingredient']} \$0'
                                                    : '${ingredients[i]['Ingredient']} \$${ingredientTotal.toStringAsFixed(0)}',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Spacer(),
                                              //Delete
                                              IconButton(
                                                  tooltip: 'Eliminar',
                                                  padding: EdgeInsets.all(2),
                                                  splashRadius: 5,
                                                  onPressed: () {
                                                    ingredients.removeAt(i);

                                                    final random = Random();
                                                    const availableChars =
                                                        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
                                                    final randomString = List.generate(
                                                        10,
                                                        (index) => availableChars[
                                                            random.nextInt(
                                                                availableChars
                                                                    .length)]).join();
                                                    setState(() {
                                                      redrawObject = ValueKey(
                                                          randomString);
                                                    });
                                                  },
                                                  icon: Icon(
                                                    Icons.close,
                                                    size: 16,
                                                  ))
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        //Amount
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                width: double.infinity,
                                                child: TextFormField(
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14),
                                                  textAlign: TextAlign.center,
                                                  initialValue: ingredients[i]
                                                              ['Quantity'] ==
                                                          0
                                                      ? ''
                                                      : '${ingredients[i]['Quantity']}',
                                                  keyboardType:
                                                      TextInputType.number,
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .allow(RegExp(
                                                            r'[0-9]+[,.]{0,1}[0-9]*')),
                                                    TextInputFormatter
                                                        .withFunction(
                                                      (oldValue, newValue) =>
                                                          newValue.copyWith(
                                                        text: newValue.text
                                                            .replaceAll(
                                                                ',', '.'),
                                                      ),
                                                    ),
                                                  ],
                                                  cursorColor: Colors.grey,
                                                  decoration: InputDecoration(
                                                    floatingLabelStyle:
                                                        TextStyle(
                                                            color: Colors.grey),
                                                    labelStyle: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12),
                                                    labelText: (ingredients[i]
                                                                ['Unit'] !=
                                                            null)
                                                        ? ingredients[i]['Unit']
                                                        : 'Cantidad',
                                                    focusColor: Colors.black,
                                                    hintStyle: TextStyle(
                                                        color: Colors.black45,
                                                        fontSize: 12),
                                                    errorStyle: TextStyle(
                                                        color: Colors
                                                            .redAccent[700],
                                                        fontSize: 12),
                                                    border:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                    focusedBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Colors.greenAccent,
                                                      ),
                                                    ),
                                                  ),
                                                  onChanged: (value) {
                                                    String newValue =
                                                        value.toString();
                                                    try {
                                                      double newPrice =
                                                          double.parse(
                                                              newValue);
                                                      setState(() {
                                                        ingredients[i]
                                                                ['Quantity'] =
                                                            newPrice;
                                                      });
                                                    } catch (e) {
                                                      print(e);
                                                      // priceOptions[i]['Price'] =
                                                      //     double.parse(newValue);
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            //Yield
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                width: double.infinity,
                                                child: TextFormField(
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14),
                                                  textAlign: TextAlign.center,
                                                  initialValue: ingredients[i]
                                                              ['Yield'] ==
                                                          0
                                                      ? ''
                                                      : '${ingredients[i]['Yield']}',
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .allow(RegExp(
                                                            r'[0-9]+[,.]{0,1}[0-9]*')),
                                                    TextInputFormatter
                                                        .withFunction(
                                                      (oldValue, newValue) =>
                                                          newValue.copyWith(
                                                        text: newValue.text
                                                            .replaceAll(
                                                                ',', '.'),
                                                      ),
                                                    ),
                                                  ],
                                                  keyboardType:
                                                      TextInputType.number,
                                                  cursorColor: Colors.grey,
                                                  decoration: InputDecoration(
                                                    labelText: 'Rinde para',
                                                    floatingLabelStyle:
                                                        TextStyle(
                                                            color: Colors.grey),
                                                    labelStyle: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12),
                                                    focusColor: Colors.black,
                                                    hintStyle: TextStyle(
                                                        color: Colors.black45,
                                                        fontSize: 12),
                                                    errorStyle: TextStyle(
                                                        color: Colors
                                                            .redAccent[700],
                                                        fontSize: 12),
                                                    border:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                    focusedBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Colors.greenAccent,
                                                      ),
                                                    ),
                                                  ),
                                                  onChanged: (value) {
                                                    String newValue =
                                                        value.toString();
                                                    try {
                                                      double newPrice =
                                                          double.parse(
                                                              newValue);
                                                      setState(() {
                                                        ingredients[i]
                                                                ['Yield'] =
                                                            newPrice;
                                                      });
                                                    } catch (e) {
                                                      print(e);
                                                      // priceOptions[i]['Price'] =
                                                      //     double.parse(newValue);
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              })),

                      SizedBox(height: (ingredients.length == 0) ? 0 : 10),
                      (ingredients.length == 0)
                          ? SizedBox()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('Costo total: '),
                                Text(
                                  formatCurrency.format(totalIngredientsCost()),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                SizedBox(
                                  width: 50,
                                )
                              ],
                            ),
                      SizedBox(height: (ingredients.length == 0) ? 0 : 20),
                      //Agregar ingrediente
                      Tooltip(
                        message: 'Agregar insumo',
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: ((context) => SuppliesListDialog(
                                    selectSupply, widget.activeBusiness)));
                          },
                          child: Container(
                            height: 70,
                            width: 70,
                            child: Center(
                                child: Icon(
                              Icons.add,
                              color: Colors.black87,
                              size: 30,
                            )),
                          ),
                        ),
                      ),
                      SizedBox(height: (ingredients.length == 0) ? 0 : 20),
                      //Expected Margin/Low margin
                      (ingredients.length == 0)
                          ? SizedBox()
                          : Container(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Margen de ganancia actual',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: Colors.black45),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                      '${(((price - totalIngredientsCost()) / price) * 100).toStringAsFixed(1)}%',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color:
                                              ((((price - totalIngredientsCost()) /
                                                              price) *
                                                          100) <
                                                      lowMarginAlert!)
                                                  ? Colors.red
                                                  : Colors.greenAccent[700])),
                                  SizedBox(height: 20),
                                ],
                              ),
                            ),

                      (ingredients.length == 0)
                          ? SizedBox()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                //Expected Margin
                                Expanded(
                                  flex: 5,
                                  child: Container(
                                    width: double.infinity,
                                    child: TextFormField(
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 14),
                                      cursorColor: Colors.grey,
                                      initialValue: (expectedMargin != null)
                                          ? expectedMargin.toString()
                                          : '',
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(2),
                                      ],
                                      decoration: InputDecoration(
                                        suffixIcon: Icon(Icons.percent_outlined,
                                            color: Colors.grey, size: 16),
                                        labelText: 'Margen esperado',
                                        floatingLabelStyle:
                                            TextStyle(color: Colors.grey),
                                        labelStyle: TextStyle(
                                            color: Colors.black, fontSize: 12),
                                        focusColor: Colors.black,
                                        hintStyle: TextStyle(
                                            color: Colors.black45,
                                            fontSize: 12),
                                        errorStyle: TextStyle(
                                            color: Colors.redAccent[700],
                                            fontSize: 12),
                                        border: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.greenAccent,
                                          ),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          expectedMargin = double.parse(value);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(width: 20),
                                //Low Margin Alert
                                Expanded(
                                  flex: 5,
                                  child: Container(
                                    width: double.infinity,
                                    child: TextFormField(
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 14),
                                      cursorColor: Colors.grey,
                                      initialValue: (lowMarginAlert != null)
                                          ? lowMarginAlert.toString()
                                          : '',
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(2),
                                      ],
                                      decoration: InputDecoration(
                                        suffixIcon: Icon(Icons.percent_outlined,
                                            color: Colors.grey, size: 16),
                                        labelText: 'Alerta de bajo margen',
                                        floatingLabelStyle:
                                            TextStyle(color: Colors.grey),
                                        labelStyle: TextStyle(
                                            color: Colors.black, fontSize: 12),
                                        focusColor: Colors.black,
                                        hintStyle: TextStyle(
                                            color: Colors.black45,
                                            fontSize: 12),
                                        errorStyle: TextStyle(
                                            color: Colors.redAccent[700],
                                            fontSize: 12),
                                        border: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.greenAccent,
                                          ),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          lowMarginAlert = double.parse(value);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      //Button
                      SizedBox(height: 35),
                      (widget.product == null)
                          ? ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.black),
                                overlayColor:
                                    MaterialStateProperty.resolveWith<Color?>(
                                  (Set<MaterialState> states) {
                                    if (states.contains(MaterialState.hovered))
                                      return Colors.grey;
                                    if (states
                                            .contains(MaterialState.focused) ||
                                        states.contains(MaterialState.pressed))
                                      return Colors.grey.shade300;
                                    return null; // Defer to the widget's default.
                                  },
                                ),
                              ),
                              onPressed: () {
                                if (newProduct) {
                                  if (_formKey.currentState!.validate()) {
                                    if (ingredients.length > 0) {
                                      for (int i = 0;
                                          i < ingredients.length;
                                          i++) {
                                        listOfIngredients
                                            .add(ingredients[i]['Ingredient']);
                                      }
                                    }
                                    if (changedImage) {
                                      uploadPic(widget.activeBusiness).then(
                                          (value) => DatabaseService()
                                              .createProduct(
                                                  widget.activeBusiness,
                                                  name,
                                                  downloadUrl,
                                                  category,
                                                  price,
                                                  description,
                                                  productOptions,
                                                  setSearchParam(
                                                      name.toLowerCase()),
                                                  code,
                                                  listOfIngredients,
                                                  ingredients,
                                                  (widget.businessField ==
                                                          'Gatronómico')
                                                      ? vegan
                                                      : null,
                                                  show,
                                                  featured,
                                                  expectedMargin,
                                                  lowMarginAlert));
                                    } else {
                                      DatabaseService().createProduct(
                                          widget.activeBusiness,
                                          name,
                                          '',
                                          category,
                                          price,
                                          description,
                                          productOptions,
                                          setSearchParam(name.toLowerCase()),
                                          code,
                                          listOfIngredients,
                                          ingredients,
                                          (widget.businessField ==
                                                  'Gatronómico')
                                              ? vegan
                                              : null,
                                          show,
                                          featured,
                                          expectedMargin,
                                          lowMarginAlert);
                                    }

                                    Navigator.of(context).pop();
                                  }
                                } else {
                                  if (_formKey.currentState!.validate()) {
                                    if (ingredients.length > 0) {
                                      for (int i = 0;
                                          i < ingredients.length;
                                          i++) {
                                        listOfIngredients
                                            .add(ingredients[i]['Ingredient']);
                                      }
                                    }
                                    if (changedImage) {
                                      if (widget.product!.price != price) {
                                        try {
                                          historicPrices.last['To Date'] =
                                              DateTime.now();

                                          historicPrices.add({
                                            'From Date': DateTime.now(),
                                            'To Date': null,
                                            'Price': price
                                          });
                                        } catch (e) {
                                          print(e);
                                          historicPrices = [
                                            {
                                              'From Date': DateTime.now(),
                                              'To Date': null,
                                              'Price': price
                                            }
                                          ];
                                        }
                                      }
                                      uploadPic(widget.activeBusiness).then(
                                          (value) => DatabaseService()
                                              .editProduct(
                                                  widget.activeBusiness,
                                                  widget.product!.productID,
                                                  isAvailable,
                                                  name,
                                                  downloadUrl,
                                                  category,
                                                  price,
                                                  description,
                                                  productOptions,
                                                  setSearchParam(
                                                      name.toLowerCase()),
                                                  code,
                                                  listOfIngredients,
                                                  ingredients,
                                                  (widget.businessField ==
                                                          'Gatronómico')
                                                      ? vegan
                                                      : null,
                                                  show,
                                                  historicPrices,
                                                  featured,
                                                  expectedMargin!,
                                                  lowMarginAlert!));
                                    } else {
                                      if (widget.product!.price != price) {
                                        try {
                                          historicPrices.last['To Date'] =
                                              DateTime.now();

                                          historicPrices.add({
                                            'From Date': DateTime.now(),
                                            'To Date': null,
                                            'Price': price
                                          });
                                        } catch (e) {
                                          print(e);
                                          historicPrices = [
                                            {
                                              'From Date': DateTime.now(),
                                              'To Date': null,
                                              'Price': price
                                            }
                                          ];
                                        }
                                      }
                                      DatabaseService().editProduct(
                                          widget.activeBusiness,
                                          widget.product!.productID,
                                          isAvailable,
                                          name,
                                          image,
                                          category,
                                          price,
                                          description,
                                          productOptions,
                                          setSearchParam(name.toLowerCase()),
                                          code,
                                          listOfIngredients,
                                          ingredients,
                                          (widget.businessField ==
                                                  'Gatronómico')
                                              ? vegan
                                              : null,
                                          show,
                                          historicPrices,
                                          featured,
                                          expectedMargin!,
                                          lowMarginAlert!);
                                    }
                                    Navigator.of(context).pop();
                                  }
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                child: Center(
                                  child: Text((newProduct)
                                      ? 'Crear'
                                      : 'Guardar cambios'),
                                ),
                              ))
                          : Container(
                              width: double.infinity,
                              child: Row(
                                children: [
                                  //Save
                                  Expanded(
                                    child: ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.black),
                                          overlayColor: MaterialStateProperty
                                              .resolveWith<Color?>(
                                            (Set<MaterialState> states) {
                                              if (states.contains(
                                                  MaterialState.hovered))
                                                return Colors.grey;
                                              if (states.contains(
                                                      MaterialState.focused) ||
                                                  states.contains(
                                                      MaterialState.pressed))
                                                return Colors.grey.shade300;
                                              return null; // Defer to the widget's default.
                                            },
                                          ),
                                        ),
                                        onPressed: () {
                                          if (newProduct) {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              if (widget.product!.ingredients!
                                                      .length >
                                                  0) {
                                                for (int i = 0;
                                                    i < ingredients.length;
                                                    i++) {
                                                  listOfIngredients.add(
                                                      ingredients[i]
                                                          ['Ingredient']);
                                                }
                                              }
                                              if (changedImage) {
                                                uploadPic(widget.activeBusiness).then(
                                                    (value) => DatabaseService()
                                                        .createProduct(
                                                            widget
                                                                .activeBusiness,
                                                            name,
                                                            downloadUrl,
                                                            category,
                                                            price,
                                                            description,
                                                            productOptions,
                                                            setSearchParam(name
                                                                .toLowerCase()),
                                                            code,
                                                            listOfIngredients,
                                                            ingredients,
                                                            (widget.businessField ==
                                                                    'Gatronómico')
                                                                ? vegan
                                                                : null,
                                                            show,
                                                            featured,
                                                            expectedMargin,
                                                            lowMarginAlert));
                                              } else {
                                                DatabaseService().createProduct(
                                                    widget.activeBusiness,
                                                    name,
                                                    '',
                                                    category,
                                                    price,
                                                    description,
                                                    productOptions,
                                                    setSearchParam(
                                                        name.toLowerCase()),
                                                    code,
                                                    listOfIngredients,
                                                    ingredients,
                                                    (widget.businessField ==
                                                            'Gatronómico')
                                                        ? vegan
                                                        : null,
                                                    show,
                                                    featured,
                                                    expectedMargin,
                                                    lowMarginAlert);
                                              }

                                              Navigator.of(context).pop();
                                            }
                                          } else {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              if (ingredients.length > 0) {
                                                for (int i = 0;
                                                    i < ingredients.length;
                                                    i++) {
                                                  listOfIngredients.add(
                                                      ingredients[i]
                                                          ['Ingredient']);
                                                }
                                              }
                                              if (changedImage) {
                                                if (widget.product!.price !=
                                                    price) {
                                                  if (historicPrices.length >
                                                      0) {
                                                    historicPrices
                                                            .last['To Date'] =
                                                        DateTime.now();

                                                    historicPrices.add({
                                                      'From Date':
                                                          DateTime.now(),
                                                      'To Date': null,
                                                      'Price': price
                                                    });
                                                  } else {
                                                    historicPrices = [
                                                      {
                                                        'From Date':
                                                            DateTime.now(),
                                                        'To Date': null,
                                                        'Price': price
                                                      }
                                                    ];
                                                  }
                                                }
                                                uploadPic(widget.activeBusiness).then(
                                                    (value) => DatabaseService()
                                                        .editProduct(
                                                            widget
                                                                .activeBusiness,
                                                            widget.product!
                                                                .productID,
                                                            isAvailable,
                                                            name,
                                                            downloadUrl,
                                                            category,
                                                            price,
                                                            description,
                                                            productOptions,
                                                            setSearchParam(name
                                                                .toLowerCase()),
                                                            code,
                                                            listOfIngredients,
                                                            ingredients,
                                                            (widget.businessField ==
                                                                    'Gatronómico')
                                                                ? vegan
                                                                : null,
                                                            show,
                                                            historicPrices,
                                                            featured,
                                                            expectedMargin!,
                                                            lowMarginAlert!));
                                              } else {
                                                if (widget.product!.price !=
                                                    price) {
                                                  if (historicPrices.length >
                                                      0) {
                                                    historicPrices
                                                            .last['To Date'] =
                                                        DateTime.now();

                                                    historicPrices.add({
                                                      'From Date':
                                                          DateTime.now(),
                                                      'To Date': null,
                                                      'Price': price
                                                    });
                                                  } else {
                                                    historicPrices = [
                                                      {
                                                        'From Date':
                                                            DateTime.now(),
                                                        'To Date': null,
                                                        'Price': price
                                                      }
                                                    ];
                                                  }
                                                }
                                                DatabaseService().editProduct(
                                                    widget.activeBusiness,
                                                    widget.product!.productID,
                                                    isAvailable,
                                                    name,
                                                    image,
                                                    category,
                                                    price,
                                                    description,
                                                    productOptions,
                                                    setSearchParam(
                                                        name.toLowerCase()),
                                                    code,
                                                    listOfIngredients,
                                                    ingredients,
                                                    (widget.businessField ==
                                                            'Gatronómico')
                                                        ? vegan
                                                        : null,
                                                    show,
                                                    historicPrices,
                                                    featured,
                                                    expectedMargin!,
                                                    lowMarginAlert!);
                                              }
                                              Navigator.of(context).pop();
                                            }
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 15),
                                          child: Center(
                                            child: Text((newProduct)
                                                ? 'Crear'
                                                : 'Guardar cambios'),
                                          ),
                                        )),
                                  ),
                                  SizedBox(width: 20),
                                  //Delete
                                  Container(
                                    height: 45,
                                    width: 45,
                                    child: Tooltip(
                                      message: 'Eliminar producto',
                                      child: OutlinedButton(
                                        style: ButtonStyle(
                                          padding: MaterialStateProperty.all<
                                                  EdgeInsetsGeometry>(
                                              EdgeInsets.all(5)),
                                          alignment: Alignment.center,
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.white70),
                                          overlayColor: MaterialStateProperty
                                              .resolveWith<Color?>(
                                            (Set<MaterialState> states) {
                                              if (states.contains(
                                                  MaterialState.hovered))
                                                return Colors.grey.shade300;
                                              if (states.contains(
                                                      MaterialState.focused) ||
                                                  states.contains(
                                                      MaterialState.pressed))
                                                return Colors.white;
                                              return null; // Defer to the widget's default.
                                            },
                                          ),
                                        ),
                                        onPressed: () {
                                          DatabaseService().deleteProduct(
                                              widget.activeBusiness,
                                              widget.product!.productID!);
                                          Navigator.of(context).pop();
                                        },
                                        child: Center(
                                            child: Icon(
                                          Icons.delete,
                                          color: Colors.black,
                                          size: 18,
                                        )),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        )),
      );
    }
  }
}
