import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Models/Tables.dart';
import 'package:flutter/material.dart';

class EditTableDialog extends StatefulWidget {
  final String businessID;
  final Tables currentTable;
  final TablesNotifier tablesNotifier;
  final int tableIndex;

  EditTableDialog(
      this.businessID, this.currentTable, this.tablesNotifier, this.tableIndex);
  @override
  _EditTableDialogState createState() => _EditTableDialogState();
}

class _EditTableDialogState extends State<EditTableDialog> {
  String tableName = '';
  String _selectedShape;
  final _formKey = GlobalKey<FormState>();

  List shapeList = ['Square', 'Circle', 'Wide Rectangle', 'Tall Rectangle'];

  Widget tableShapeIcon(shape) {
    switch (shape) {
      case 'Square':
        return Container(
          height: 25,
          width: 25,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 1.5),
          ),
        );
      case 'Circle':
        return Container(
          height: 25,
          width: 25,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 1.5),
          ),
        );
      case 'Wide Rectangle':
        return Container(
          height: 25,
          width: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 1.5),
          ),
        );
      case 'Tall Rectangle':
        return Container(
          height: 50,
          width: 25,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 1.5),
          ),
        );
      default:
        return Container();
    }
  }

  @override
  void initState() {
    super.initState();
    tableName = widget.currentTable.table;
    _selectedShape = widget.currentTable.shape;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Container(
            width: 400,
            height: 400,
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
                    width: double.infinity,
                    child: Text(
                      'Forma',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 60,
                    child: Center(
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: shapeList.length,
                          shrinkWrap: true,
                          itemBuilder: (context, i) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 3.0),
                              child: Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                  border: Border.all(
                                      color: (_selectedShape == shapeList[i])
                                          ? Colors.greenAccent
                                          : Colors.white10,
                                      width: 1.5),
                                ),
                                child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedShape = shapeList[i];
                                      });
                                    },
                                    child: Center(
                                        child: tableShapeIcon(shapeList[i]))),
                              ),
                            );
                          }),
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
                                      x: widget.currentTable.x,
                                      y: widget.currentTable.y,
                                      tableSize: 0.009744,
                                      docID: '');

                                  widget.tablesNotifier
                                    ..editTable(newTable, widget.tableIndex);
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
