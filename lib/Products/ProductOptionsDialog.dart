import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProductOptionsDialog extends StatefulWidget {
  final setProductOptions;
  final bool editProduct;
  final String optionTitle;
  final bool mandatory;
  final bool multipleOptions;
  final String priceStructure;
  final List optionsList;
  final int index;
  const ProductOptionsDialog(this.setProductOptions, this.editProduct,
      {Key key,
      this.optionTitle,
      this.mandatory,
      this.multipleOptions,
      this.priceStructure,
      this.optionsList,
      this.index})
      : super(key: key);

  @override
  State<ProductOptionsDialog> createState() => _ProductOptionsDialogState();
}

class _ProductOptionsDialogState extends State<ProductOptionsDialog> {
  final _formKey = GlobalKey<FormState>();

  String optionTitle;
  bool mandadory = false;
  bool multipleOptions = false;

  //List of product Options
  List priceOptions = [];
  ValueKey redrawObject = ValueKey('List');
  List<TextEditingController> _controllers = [];

  List priceStructureList = [
    'Monto adicional sobre el producto',
    'Reemplaza precio del producto',
    'Éstas opciones no afectan el precio'
  ];
  String priceStructure = 'Éstas opciones no afectan el precio';
  String newPriceStructure;

  @override
  void initState() {
    if (widget.editProduct) {
      optionTitle = widget.optionTitle;
      mandadory = widget.mandatory;
      multipleOptions = widget.multipleOptions;
      priceOptions = widget.optionsList;

      if (widget.priceStructure == 'Aditional') {
        priceStructure = 'Monto adicional sobre el producto';
      } else if (widget.priceStructure == 'Complete') {
        priceStructure = 'Reemplaza precio del producto';
      } else {
        priceStructure = 'Éstas opciones no afectan el precio';
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width > 800) {
      return SingleChildScrollView(
        child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          child: Container(
            padding: EdgeInsets.all(30.0),
            width: MediaQuery.of(context).size.width * 0.5,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Go back
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.close),
                          iconSize: 20.0),
                    ],
                  ),
                  //Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Text(
                          "Opciones del producto",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  //Titulo
                  Text(
                    'Título de la opción*',
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Colors.black45),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    child: TextFormField(
                      style: TextStyle(color: Colors.black, fontSize: 14),
                      cursorColor: Colors.grey,
                      initialValue: widget.optionTitle,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Agrega un título";
                        } else {
                          return null;
                        }
                      },
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
                          optionTitle = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  //Mandatory
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      //Price Structure
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Estructura de precio',
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Colors.black45),
                            ),
                            SizedBox(height: 10),
                            Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: DropdownButton(
                                  isExpanded: true,
                                  underline: SizedBox(),
                                  hint: Text(
                                    priceStructureList[0],
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        color: Colors.grey[700]),
                                  ),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: Colors.grey[700]),
                                  value: priceStructure,
                                  items: priceStructureList.map((x) {
                                    return new DropdownMenuItem(
                                      value: x,
                                      child: new Text(x),
                                      onTap: () {
                                        setState(() {
                                          priceStructure = x;
                                        });
                                      },
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      priceStructure = newValue;
                                    });
                                  },
                                )),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      //Mandatory
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Obligatorio',
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: Colors.black45),
                              ),
                              SizedBox(width: 10),
                              Tooltip(
                                message:
                                    'Al cliente pedir online estará obligado a escoger entre las opciones',
                                child:
                                    Icon(Icons.info_outline_rounded, size: 18),
                              )
                            ],
                          ),
                          SizedBox(height: 10),
                          Switch(
                            value: mandadory,
                            onChanged: (value) {
                              setState(() {
                                mandadory = value;
                              });
                            },
                            activeTrackColor: Colors.lightGreenAccent,
                            activeColor: Colors.green,
                          ),
                        ],
                      ),
                      SizedBox(width: 35),
                      //Multiple Options
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Selección múltiple',
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: Colors.black45),
                              ),
                              SizedBox(width: 10),
                              Tooltip(
                                message:
                                    'Se podrá seleccionar más de una opción a la vez',
                                child:
                                    Icon(Icons.info_outline_rounded, size: 18),
                              )
                            ],
                          ),
                          SizedBox(height: 10),
                          Switch(
                            value: multipleOptions,
                            onChanged: (value) {
                              setState(() {
                                multipleOptions = value;
                              });
                            },
                            activeTrackColor: Colors.lightGreenAccent,
                            activeColor: Colors.green,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  //Options
                  Text(
                    'Opciones*',
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Colors.black45),
                  ),
                  SizedBox(height: 10),
                  (priceOptions.length == 0)
                      ? SizedBox()
                      : ListView.builder(
                          key: redrawObject,
                          shrinkWrap: true,
                          itemCount: priceOptions.length,
                          itemBuilder: ((context, i) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 15.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //Option
                                  Expanded(
                                    flex: 6,
                                    child: Container(
                                      width: double.infinity,
                                      child: TextFormField(
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 14),
                                        cursorColor: Colors.grey,
                                        validator: (val) {
                                          if (val == null || val.isEmpty) {
                                            return "Agrega una opción válida";
                                          } else {
                                            return null;
                                          }
                                        },
                                        initialValue: priceOptions[i]['Option'],
                                        decoration: InputDecoration(
                                          hintText: 'Opción',
                                          focusColor: Colors.black,
                                          hintStyle: TextStyle(
                                              color: Colors.black45,
                                              fontSize: 12),
                                          errorStyle: TextStyle(
                                              color: Colors.redAccent[700],
                                              fontSize: 12),
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
                                        onChanged: (value) {
                                          setState(() {
                                            priceOptions[i]['Option'] = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  //Price
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      width: double.infinity,
                                      child: TextFormField(
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 14),
                                        initialValue: (priceOptions[i]
                                                        ['Price'] !=
                                                    null &&
                                                priceOptions[i]['Price'] != 0)
                                            ? '${priceOptions[i]['Price'].toString()}'
                                            : '',
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
                                          TextInputFormatter.withFunction(
                                            (oldValue, newValue) =>
                                                newValue.copyWith(
                                              text: newValue.text
                                                  .replaceAll(',', '.'),
                                            ),
                                          ),
                                        ],
                                        cursorColor: Colors.grey,
                                        decoration: InputDecoration(
                                          focusColor: Colors.black,
                                          prefixIcon: Icon(Icons.attach_money),
                                          hintText: 'Precio',
                                          hintStyle: TextStyle(
                                              color: Colors.black45,
                                              fontSize: 12),
                                          errorStyle: TextStyle(
                                              color: Colors.redAccent[700],
                                              fontSize: 12),
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
                                        onChanged: (value) {
                                          String newValue = value.toString();
                                          try {
                                            double newPrice =
                                                double.parse(newValue);
                                            setState(() {
                                              priceOptions[i]['Price'] =
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
                                  SizedBox(width: 20),
                                  //Delete
                                  IconButton(
                                      onPressed: () {
                                        priceOptions.removeAt(i);

                                        final random = Random();
                                        const availableChars =
                                            'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
                                        final randomString = List.generate(
                                                10,
                                                (index) => availableChars[
                                                    random.nextInt(
                                                        availableChars.length)])
                                            .join();
                                        setState(() {
                                          redrawObject = ValueKey(randomString);
                                        });
                                      },
                                      icon: Icon(Icons.delete))
                                ],
                              ),
                            );
                          })),
                  Tooltip(
                    message: 'Agregar opción',
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {
                        for (var x = 0; x < 2; x++) {
                          _controllers.add(new TextEditingController());
                        }
                        setState(() {
                          priceOptions.add({'Option': '', 'Price': 0});
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
                  //Button
                  SizedBox(height: 35),
                  ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.black),
                        overlayColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.hovered))
                              return Colors.grey;
                            if (states.contains(MaterialState.focused) ||
                                states.contains(MaterialState.pressed))
                              return Colors.grey.shade300;
                            return null; // Defer to the widget's default.
                          },
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          if (priceStructure ==
                              'Monto adicional sobre el producto') {
                            newPriceStructure = 'Aditional';
                          } else if (priceStructure ==
                              'Reemplaza precio del producto') {
                            newPriceStructure = 'Complete';
                          } else {
                            newPriceStructure = 'Non';
                          }

                          widget.setProductOptions(
                              widget.editProduct,
                              optionTitle,
                              mandadory,
                              multipleOptions,
                              newPriceStructure,
                              priceOptions,
                              widget.index);

                          Navigator.of(context).pop();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        child: Center(
                          child: Text('Guardar'),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.all(30.0),
        height: MediaQuery.of(context).size.width * 0.75,
        width: MediaQuery.of(context).size.width,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Text(
                        "Opciones del producto",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                //Titulo
                Text(
                  'Título de la opción*',
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Colors.black45),
                ),
                SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  height: 45,
                  child: TextFormField(
                    style: TextStyle(color: Colors.black, fontSize: 14),
                    cursorColor: Colors.grey,
                    initialValue: widget.optionTitle,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "Agrega un título";
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      focusColor: Colors.black,
                      hintStyle: TextStyle(color: Colors.black45, fontSize: 14),
                      errorStyle:
                          TextStyle(color: Colors.redAccent[700], fontSize: 12),
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
                        optionTitle = value;
                      });
                    },
                  ),
                ),
                SizedBox(height: 20),
                //Structure
                Text(
                  'Estructura de precio',
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Colors.black45),
                ),
                SizedBox(height: 10),
                Container(
                    height: 45,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButton(
                      isExpanded: true,
                      underline: SizedBox(),
                      hint: Text(
                        priceStructureList[0],
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Colors.grey[700]),
                      ),
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Colors.grey[700]),
                      value: priceStructure,
                      items: priceStructureList.map((x) {
                        return new DropdownMenuItem(
                          value: x,
                          child: new Text(x),
                          onTap: () {
                            setState(() {
                              priceStructure = x;
                            });
                          },
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          priceStructure = newValue;
                        });
                      },
                    )),
                SizedBox(height: 20),
                //Mandatory
                Container(
                  width: double.infinity,
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      //Mandatory
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Obligatorio',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: Colors.black45),
                                ),
                                SizedBox(width: 10),
                                Tooltip(
                                  message:
                                      'Al cliente pedir online estará obligado a escoger entre las opciones',
                                  child: Icon(Icons.info_outline_rounded,
                                      size: 18),
                                )
                              ],
                            ),
                            SizedBox(height: 10),
                            Switch(
                              value: mandadory,
                              onChanged: (value) {
                                setState(() {
                                  mandadory = value;
                                });
                              },
                              activeTrackColor: Colors.lightGreenAccent,
                              activeColor: Colors.green,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 5),
                      //Multiple Options
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Selección múltiple',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: Colors.black45),
                                ),
                                SizedBox(width: 10),
                                Tooltip(
                                  message:
                                      'Se podrá seleccionar más de una opción a la vez',
                                  child: Icon(Icons.info_outline_rounded,
                                      size: 18),
                                )
                              ],
                            ),
                            SizedBox(height: 10),
                            Switch(
                              value: multipleOptions,
                              onChanged: (value) {
                                setState(() {
                                  multipleOptions = value;
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
                SizedBox(height: 20),

                //Options
                Text(
                  'Opciones*',
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Colors.black45),
                ),
                SizedBox(height: 10),
                (priceOptions.length == 0)
                    ? SizedBox()
                    : ListView.builder(
                        key: redrawObject,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: priceOptions.length,
                        itemBuilder: ((context, i) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: Container(
                              height: 75,
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //Option
                                  Column(
                                    children: [
                                      //Option
                                      Container(
                                        width: double.infinity,
                                        child: TextFormField(
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14),
                                          cursorColor: Colors.grey,
                                          validator: (val) {
                                            if (val == null || val.isEmpty) {
                                              return "Agrega una opción válida";
                                            } else {
                                              return null;
                                            }
                                          },
                                          initialValue: priceOptions[i]
                                              ['Option'],
                                          decoration: InputDecoration(
                                            hintText: 'Opción',
                                            focusColor: Colors.black,
                                            hintStyle: TextStyle(
                                                color: Colors.black45,
                                                fontSize: 12),
                                            errorStyle: TextStyle(
                                                color: Colors.redAccent[700],
                                                fontSize: 12),
                                            border: new OutlineInputBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      12.0),
                                              borderSide: new BorderSide(
                                                color: Colors.grey[350],
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
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
                                              priceOptions[i]['Option'] = value;
                                            });
                                          },
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      //Price
                                      Container(
                                        width: double.infinity,
                                        child: TextFormField(
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14),
                                          initialValue: (priceOptions[i]
                                                          ['Price'] !=
                                                      null &&
                                                  priceOptions[i]['Price'] != 0)
                                              ? '${priceOptions[i]['Price'].toString()}'
                                              : '',
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(
                                                    r'[0-9]+[,.]{0,1}[0-9]*')),
                                            TextInputFormatter.withFunction(
                                              (oldValue, newValue) =>
                                                  newValue.copyWith(
                                                text: newValue.text
                                                    .replaceAll(',', '.'),
                                              ),
                                            ),
                                          ],
                                          cursorColor: Colors.grey,
                                          decoration: InputDecoration(
                                            focusColor: Colors.black,
                                            prefixIcon:
                                                Icon(Icons.attach_money),
                                            hintText: 'Precio',
                                            hintStyle: TextStyle(
                                                color: Colors.black45,
                                                fontSize: 12),
                                            errorStyle: TextStyle(
                                                color: Colors.redAccent[700],
                                                fontSize: 12),
                                            border: new OutlineInputBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      12.0),
                                              borderSide: new BorderSide(
                                                color: Colors.grey[350],
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      12.0),
                                              borderSide: new BorderSide(
                                                color: Colors.green,
                                              ),
                                            ),
                                          ),
                                          onChanged: (value) {
                                            String newValue = value.toString();
                                            try {
                                              double newPrice =
                                                  double.parse(newValue);
                                              setState(() {
                                                priceOptions[i]['Price'] =
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
                                    ],
                                  ),
                                  SizedBox(width: 20),
                                  //Delete
                                  IconButton(
                                      onPressed: () {
                                        priceOptions.removeAt(i);

                                        final random = Random();
                                        const availableChars =
                                            'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
                                        final randomString = List.generate(
                                                10,
                                                (index) => availableChars[
                                                    random.nextInt(
                                                        availableChars.length)])
                                            .join();
                                        setState(() {
                                          redrawObject = ValueKey(randomString);
                                        });
                                      },
                                      icon: Icon(Icons.delete))
                                ],
                              ),
                            ),
                          );
                        })),

                Tooltip(
                  message: 'Agregar opción',
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                      for (var x = 0; x < 2; x++) {
                        _controllers.add(new TextEditingController());
                      }
                      setState(() {
                        priceOptions.add({'Option': '', 'Price': 0});
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
                //Button
                SizedBox(height: 35),
                ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.black),
                      overlayColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.hovered))
                            return Colors.grey;
                          if (states.contains(MaterialState.focused) ||
                              states.contains(MaterialState.pressed))
                            return Colors.grey.shade300;
                          return null; // Defer to the widget's default.
                        },
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        if (priceStructure ==
                            'Monto adicional sobre el producto') {
                          newPriceStructure = 'Aditional';
                        } else if (priceStructure ==
                            'Reemplaza precio del producto') {
                          newPriceStructure = 'Complete';
                        } else {
                          newPriceStructure = 'Non';
                        }

                        widget.setProductOptions(
                            widget.editProduct,
                            optionTitle,
                            mandadory,
                            multipleOptions,
                            newPriceStructure,
                            priceOptions,
                            widget.index);

                        Navigator.of(context).pop();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      child: Center(
                        child: Text('Guardar'),
                      ),
                    )),
              ],
            ),
          ),
        ),
      );
    }
  }
}
