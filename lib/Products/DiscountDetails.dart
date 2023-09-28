import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Models/Discounts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DiscountDetails extends StatefulWidget {
  final Discounts currentDiscount;
  final String activeBusiness;
  const DiscountDetails(this.currentDiscount, this.activeBusiness, {Key key})
      : super(key: key);

  @override
  State<DiscountDetails> createState() => _DiscountDetailsState();
}

class _DiscountDetailsState extends State<DiscountDetails> {
  Discounts discount = new Discounts();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    discount = widget.currentDiscount;
    super.initState();
  }

  //CODE
  //Discount
  //Created, Uses, Active,
  //Description

  @override
  Widget build(BuildContext context) {
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
                'Descuento',
                textAlign: TextAlign.left,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28),
              ),
            ],
          ),
          SizedBox(height: 35),
          //Form
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              width: (MediaQuery.of(context).size.width > 950)
                  ? 500
                  : double.infinity,
              padding: EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: <BoxShadow>[
                  new BoxShadow(
                    color: Colors.grey[350],
                    offset: new Offset(0, 0),
                    blurRadius: 10.0,
                  )
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //Code
                    Text(
                      discount.code,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    SizedBox(height: 10),
                    //Percentage
                    Text(
                      '${discount.discount}%',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                    SizedBox(height: 20),
                    //Created, Uses, Active,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //Created
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Creado',
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: Colors.black45),
                              ),
                              SizedBox(height: 10),
                              Text(
                                DateFormat.yMMMd()
                                    .format(discount.createdDate)
                                    .toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: Colors.black45),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 20),
                        //Uses
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Usos',
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: Colors.black45),
                              ),
                              SizedBox(height: 10),
                              Text(
                                '${discount.numberOfUses}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 20),
                        //Active
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Activo',
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: Colors.black45),
                              ),
                              SizedBox(height: 10),
                              Switch(
                                value: discount.active,
                                onChanged: (value) {
                                  setState(() {
                                    discount.active = value;
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
                    SizedBox(height: 20),
                    //Description
                    Text(
                      'Descripción',
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
                      initialValue: discount.description,
                      decoration: InputDecoration(
                        hintText: 'Descripción del descuento',
                        focusColor: Colors.black,
                        hintStyle:
                            TextStyle(color: Colors.black45, fontSize: 14),
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
                          discount.description = value;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    //Button
                    SizedBox(height: 35),
                    Container(
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
                                  overlayColor:
                                      MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.hovered))
                                        return Colors.grey;
                                      if (states.contains(
                                              MaterialState.focused) ||
                                          states
                                              .contains(MaterialState.pressed))
                                        return Colors.grey.shade300;
                                      return null; // Defer to the widget's default.
                                    },
                                  ),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    DatabaseService().editDiscount(
                                        widget.activeBusiness,
                                        discount.code,
                                        discount.description,
                                        discount.active);
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 15),
                                  child: Center(
                                    child: Text('Guardar cambios'),
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
                                      EdgeInsetsGeometry>(EdgeInsets.all(5)),
                                  alignment: Alignment.center,
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white70),
                                  overlayColor:
                                      MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.hovered))
                                        return Colors.grey.shade300;
                                      if (states.contains(
                                              MaterialState.focused) ||
                                          states
                                              .contains(MaterialState.pressed))
                                        return Colors.white;
                                      return null; // Defer to the widget's default.
                                    },
                                  ),
                                ),
                                onPressed: () {
                                  DatabaseService().deleteDiscount(
                                    widget.activeBusiness,
                                    discount.code,
                                  );
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
          SizedBox(height: 20),
        ],
      )),
    );
  }
}
