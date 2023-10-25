import 'package:denario/Backend/DatabaseService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DiscountCreate extends StatefulWidget {
  final String activeBusiness;
  const DiscountCreate(this.activeBusiness, {Key? key}) : super(key: key);

  @override
  State<DiscountCreate> createState() => _DiscountCreateState();
}

class _DiscountCreateState extends State<DiscountCreate> {
  final _formKey = GlobalKey<FormState>();

  String? code;
  int? discount;
  String? description;

  final FocusNode _codeNode = FocusNode();
  final FocusNode _discountNode = FocusNode();
  final FocusNode _descriptionNode = FocusNode();
  TextEditingController? descriptionController;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width > 650) {
      return SingleChildScrollView(
          child: Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Container(
          width: (MediaQuery.of(context).size.width > 950)
              ? MediaQuery.of(context).size.width * 0.45
              : MediaQuery.of(context).size.width * 0.7,
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Close
                Container(
                  alignment: Alignment(1.0, 0.0),
                  child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                      iconSize: 20.0),
                ),
                //Titulo
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Center(
                      child: Text(
                    'Crear descuento',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  )),
                ]),
                SizedBox(height: 30),
                //Código/Monto
                Text(
                  'Descuento',
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Colors.black45),
                ),
                SizedBox(height: 10),
                Container(
                  height: 45,
                  child: Row(
                    children: [
                      //Code
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: Colors.black, fontSize: 14),
                          cursorColor: Colors.grey,
                          focusNode: _codeNode,
                          autofocus: true,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: 'Código',
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 12),
                            errorStyle: TextStyle(
                                color: Colors.redAccent[700], fontSize: 12),
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
                          onFieldSubmitted: (term) {
                            _codeNode.unfocus();
                            _discountNode.requestFocus();
                          },
                          onChanged: (val) {
                            setState(() => code = val);
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          focusNode: _discountNode,
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.black, fontSize: 14),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(2),
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          cursorColor: Colors.grey,
                          decoration: InputDecoration(
                            suffix: Padding(
                                padding: EdgeInsets.fromLTRB(20, 10, 2, 10),
                                child: Text(
                                  '%',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                )),
                            hintText: 'Descuento',
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 12),
                            border: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(12.0),
                              borderSide: new BorderSide(
                                color: Colors.grey,
                              ),
                            ),
                            errorBorder: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(12.0),
                              borderSide: new BorderSide(
                                color: Colors.red,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(12.0),
                              borderSide: new BorderSide(
                                color: Colors.green,
                              ),
                            ),
                          ),
                          onFieldSubmitted: (val) {
                            _discountNode.unfocus();
                            _descriptionNode.requestFocus();
                          },
                          onChanged: (val) {
                            setState(() => discount = int.parse(val));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                //Descripcion
                Container(
                  child: TextFormField(
                    style: TextStyle(color: Colors.black, fontSize: 16),
                    cursorColor: Colors.grey,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "Agregá una breve descripción";
                      } else {
                        return null;
                      }
                    },
                    focusNode: _descriptionNode,
                    controller: descriptionController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      label: Text(
                        'Descripción',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Colors.black45),
                      ),
                      errorStyle:
                          TextStyle(color: Colors.redAccent[700], fontSize: 12),
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
                    onFieldSubmitted: (term) {
                      _descriptionNode.unfocus();
                    },
                    onChanged: (val) {
                      setState(() {
                        description = val;
                      });
                    },
                  ),
                ),
                //Confirm
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    //Confirmar
                    Container(
                      height: 50,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              DatabaseService().createDiscount(
                                  widget.activeBusiness,
                                  code!,
                                  description!,
                                  discount!.toDouble());
                              Navigator.of(context).pop();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            child: Center(
                              child: Text('Crear'),
                            ),
                          )),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ));
    } else {
      return Container(
        height: MediaQuery.of(context).size.height * 0.65,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Close
                Container(
                  width: double.infinity,
                  height: 15,
                  child: Center(
                    child: Text(
                      ' - ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 35),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                //Titulo
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Center(
                      child: Text(
                    'Crear descuento',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  )),
                ]),
                SizedBox(height: 30),
                //Código/Monto
                Text(
                  'Descuento',
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Colors.black45),
                ),
                SizedBox(height: 10),
                Container(
                  height: 45,
                  child: Row(
                    children: [
                      //Code
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: Colors.black, fontSize: 14),
                          cursorColor: Colors.grey,
                          focusNode: _codeNode,
                          autofocus: true,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: 'Código',
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 12),
                            errorStyle: TextStyle(
                                color: Colors.redAccent[700], fontSize: 12),
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
                          onFieldSubmitted: (term) {
                            _codeNode.unfocus();
                            _discountNode.requestFocus();
                          },
                          onChanged: (val) {
                            setState(() => code = val);
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          focusNode: _discountNode,
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.black, fontSize: 14),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(2),
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          cursorColor: Colors.grey,
                          decoration: InputDecoration(
                            suffix: Padding(
                                padding: EdgeInsets.fromLTRB(20, 10, 2, 10),
                                child: Text(
                                  '%',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                )),
                            hintText: 'Descuento',
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 12),
                            border: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(12.0),
                              borderSide: new BorderSide(
                                color: Colors.grey,
                              ),
                            ),
                            errorBorder: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(12.0),
                              borderSide: new BorderSide(
                                color: Colors.red,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(12.0),
                              borderSide: new BorderSide(
                                color: Colors.green,
                              ),
                            ),
                          ),
                          onFieldSubmitted: (val) {
                            _discountNode.unfocus();
                            _descriptionNode.requestFocus();
                          },
                          onChanged: (val) {
                            setState(() => discount = int.parse(val));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                //Descripcion
                Container(
                  child: TextFormField(
                    style: TextStyle(color: Colors.black, fontSize: 16),
                    cursorColor: Colors.grey,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "Agregá una breve descripción";
                      } else {
                        return null;
                      }
                    },
                    focusNode: _descriptionNode,
                    controller: descriptionController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      label: Text(
                        'Descripción',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Colors.black45),
                      ),
                      errorStyle:
                          TextStyle(color: Colors.redAccent[700], fontSize: 12),
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
                    onFieldSubmitted: (term) {
                      _descriptionNode.unfocus();
                    },
                    onChanged: (val) {
                      setState(() {
                        description = val;
                      });
                    },
                  ),
                ),
                //Confirm
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    //Confirmar
                    Container(
                      height: 50,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              DatabaseService().createDiscount(
                                  widget.activeBusiness,
                                  code!,
                                  description!,
                                  discount!.toDouble());
                              Navigator.of(context).pop();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            child: Center(
                              child: Text('Crear'),
                            ),
                          )),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    }
  }
}
