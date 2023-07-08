import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Models/Tables.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditTableDialog extends StatefulWidget {
  final String businessID;
  final Tables currentTable;
  final TablesNotifier tablesNotifier;

  EditTableDialog(
    this.businessID,
    this.currentTable,
    this.tablesNotifier,
  );
  @override
  _EditTableDialogState createState() => _EditTableDialogState();
}

class _EditTableDialogState extends State<EditTableDialog> {
  String tableName = '';
  String _selectedShape;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedShape = widget.currentTable.shape;
  }

  @override
  Widget build(BuildContext context) {
    final oldtablesNotifier = Provider.of<TablesNotifier>(context);
    return SingleChildScrollView(
      child: Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Container(
            width: 400,
            height: 300,
            constraints: BoxConstraints(minHeight: 350),
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //Cancel Icon
                  Container(
                    alignment: Alignment(1.0, 0.0),
                    child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close),
                        iconSize: 20.0),
                  ),
                  SizedBox(height: 10),
                  //Title
                  Container(
                    width: double.infinity,
                    child: Text(
                      'Editar Mesa',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Spacer(),
                  //Name of Table
                  Container(
                    width: 150,
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: Colors.black, fontSize: 21),
                      textAlign: TextAlign.center,
                      maxLength: 3,
                      validator: (val) => (val.isEmpty || val == '')
                          ? "Agrega un código"
                          : null,
                      cursorColor: Colors.grey,
                      autofocus: true,
                      textInputAction: TextInputAction.next,
                      initialValue: widget.currentTable.table,
                      decoration: InputDecoration(
                        label: Text('Código de la mesa'),
                        labelStyle: TextStyle(color: Colors.grey, fontSize: 12),
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
                      onChanged: (val) {
                        setState(() => tableName = val);
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  //Shape
                  Container(
                    width: 200,
                    height: 45,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[350]),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButton(
                      isExpanded: true,
                      underline: SizedBox(),
                      hint: Text(
                        'Método de pago',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: Colors.black),
                      ),
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Colors.black),
                      value: _selectedShape,
                      items: ['Square', 'Circle', 'Rectangle']
                          .map((shape) => DropdownMenuItem(
                                value: shape,
                                child: Text(shape),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedShape = value;
                        });
                      },
                    ),
                  ),
                  Spacer(),
                  //Save Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        flex: 2,
                        child: Container(
                          height: 40,
                          child: Tooltip(
                            message: 'Eliminar',
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
                                    if (states.contains(MaterialState.hovered))
                                      return Colors.grey.shade300;
                                    if (states
                                            .contains(MaterialState.focused) ||
                                        states.contains(MaterialState.pressed))
                                      return Colors.white;
                                    return null; // Defer to the widget's default.
                                  },
                                ),
                              ),
                              onPressed: () {
                                widget.tablesNotifier
                                    .removeTable(widget.currentTable);
                                //If the table is currently on DB, delete it
                                if (widget.currentTable.docID != '') {
                                  DatabaseService()
                                      .deleteTable(widget.businessID,
                                          widget.currentTable.docID)
                                      .then((value) =>
                                          Navigator.of(context).pop());
                                } else {
                                  Navigator.of(context).pop();
                                }
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
                      ),
                      SizedBox(width: 10),
                      Flexible(
                        flex: 8,
                        child: Container(
                          height: 40,
                          child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.black),
                                overlayColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                    if (states.contains(MaterialState.hovered))
                                      return Colors.grey.shade500;
                                    if (states
                                            .contains(MaterialState.focused) ||
                                        states.contains(MaterialState.pressed))
                                      return Colors.grey.shade500;
                                    return null; // Defer to the widget's default.
                                  },
                                ),
                              ),
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  final newTable = Tables(
                                      table: tableName,
                                      assignedOrder: '',
                                      isOpen: false,
                                      openSince: DateTime.now(),
                                      numberOfPeople: 0,
                                      subTotal: 0,
                                      total: 0,
                                      discount: 0,
                                      tax: 0,
                                      paymentType: '',
                                      orderDetail: [],
                                      orderColor: Colors.white.value,
                                      client: {},
                                      isOccupied: false,
                                      shape: _selectedShape,
                                      x: 0.5,
                                      y: 0.5,
                                      tableSize: 0.009744,
                                      docID: '');

                                  oldtablesNotifier.addTable(newTable);
                                  Navigator.of(context).pop();
                                }
                              },
                              child: Center(
                                  child: Text(
                                'Guardar',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400),
                              ))),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
