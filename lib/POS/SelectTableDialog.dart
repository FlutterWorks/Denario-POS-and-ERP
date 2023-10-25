import 'package:denario/Backend/Ticket.dart';
import 'package:denario/Models/Tables.dart';
import 'package:flutter/material.dart';

import '../Backend/DatabaseService.dart';

class SelectTableDialog extends StatefulWidget {
  final TextEditingController? orderNameController;
  final List<Tables> tables;
  final bool changeTables;
  final String activeBusiness;
  SelectTableDialog(this.tables, this.changeTables, this.activeBusiness,
      {this.orderNameController});

  @override
  State<SelectTableDialog> createState() => _SelectTableDialogState();
}

class _SelectTableDialogState extends State<SelectTableDialog> {
  var snackBar = SnackBar(
    content: Text('Uupss... No puedes cambiar a una mesa activa'),
  );

  @override
  Widget build(BuildContext context) {
    if (widget.tables == []) {
      return Dialog();
    } else if (widget.tables.length == 0) {
      return SingleChildScrollView(
          child: Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              child: Container(
                padding: EdgeInsets.all(20),
                height: 500,
                width: (MediaQuery.of(context).size.width > 650)
                    ? 600
                    : MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //Text
                    Text(
                      'Ups!... No hay ninguna mesa para seleccionar',
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: Colors.black),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Puedes agregar desde la vista de "mesas" disponible en la parte superior derecha de la pantalla inicial',
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Colors.black45),
                    ),
                    SizedBox(height: 50),
                    Container(
                      width: 250,
                      height: 40,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: Center(
                              child: Text('Volver',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w400)))),
                    )
                  ],
                ),
              )));
    }

    return StreamBuilder(
        stream: bloc.getStream,
        initialData: bloc.ticketItems,
        builder: (context, AsyncSnapshot snapshot) {
          return SingleChildScrollView(
              child: Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                  child: Container(
                    // padding: EdgeInsets.all(20),
                    height: 500,
                    width: (MediaQuery.of(context).size.width > 650)
                        ? 600
                        : MediaQuery.of(context).size.width * 0.9,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        //Close
                        Padding(
                          padding: const EdgeInsets.only(right: 20.0, top: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: Icon(Icons.close),
                                  splashRadius: 5,
                                  iconSize: 20.0),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        //Text
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Abrir mesa',
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 25),

                        //lIST OF Products
                        Expanded(
                            child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: GridView.builder(
                                    shrinkWrap: true,
                                    physics: BouncingScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          (MediaQuery.of(context).size.width >
                                                  650)
                                              ? 4
                                              : 3,
                                      crossAxisSpacing: 15.0,
                                      mainAxisSpacing: 15.0,
                                      childAspectRatio: 1,
                                    ),
                                    scrollDirection: Axis.vertical,
                                    itemCount: widget.tables.length,
                                    itemBuilder: (context, i) {
                                      return Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: ElevatedButton(
                                            onPressed: () {
                                              //Switch tables if that is the case
                                              if (widget.changeTables) {
                                                if (widget.tables[i].isOpen!) {
                                                  //You cannot do this if the table is open
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(snackBar);
                                                } else {
                                                  //Take order to new table
                                                  DatabaseService().updateTable(
                                                      widget.activeBusiness,
                                                      widget.tables[i].table,
                                                      bloc.subtotalTicketAmount,
                                                      snapshot.data['Discount'],
                                                      snapshot.data['IVA'],
                                                      bloc.totalTicketAmount,
                                                      snapshot.data['Items'],
                                                      '',
                                                      Colors.greenAccent.value,
                                                      true,
                                                      snapshot.data["Client"]);
                                                  DatabaseService().saveOrder(
                                                    widget.activeBusiness,
                                                    snapshot.data['Order ID'],
                                                    bloc.subtotalTicketAmount,
                                                    snapshot.data['Discount'],
                                                    snapshot.data['IVA'],
                                                    bloc.totalTicketAmount,
                                                    snapshot.data["Items"],
                                                    widget.tables[i].table,
                                                    '',
                                                    Colors.greenAccent.value,
                                                    true,
                                                    'Mesa',
                                                    {
                                                      'Name': snapshot
                                                              .data["Client"]
                                                          ['Name'],
                                                      'Address': snapshot
                                                              .data["Client"]
                                                          ['Address'],
                                                      'Phone': snapshot
                                                              .data["Client"]
                                                          ['Phone'],
                                                      'email': snapshot
                                                              .data["Client"]
                                                          ['email'],
                                                    },
                                                  );
                                                  //Erase order on old table
                                                  DatabaseService()
                                                      .updateTable(
                                                        widget.activeBusiness,
                                                        snapshot
                                                            .data['Order Name'],
                                                        0,
                                                        0,
                                                        0,
                                                        0,
                                                        [],
                                                        '',
                                                        Colors.white.value,
                                                        false,
                                                        {
                                                          'Name': '',
                                                          'Address': '',
                                                          'Phone': 0,
                                                          'email': '',
                                                        },
                                                      )
                                                      .then((value) =>
                                                          bloc.changeOrderName(
                                                              widget.tables[i]
                                                                  .table));
                                                  Navigator.of(context).pop();
                                                }
                                              } else {
                                                //Check if open
                                                if (widget.tables[i].isOpen!) {
                                                  //retrieve order
                                                  bloc.retrieveOrder(
                                                      widget.tables[i].table,
                                                      widget.tables[i]
                                                          .paymentType,
                                                      widget.tables[i]
                                                          .orderDetail,
                                                      widget.tables[i].discount,
                                                      widget.tables[i].tax,
                                                      Color(widget.tables[i]
                                                          .orderColor!),
                                                      true,
                                                      'Mesa ${widget.tables[i].table}',
                                                      false,
                                                      'Mesa',
                                                      (widget.tables[i].client![
                                                                      'Name'] ==
                                                                  '' ||
                                                              widget.tables[i]
                                                                          .client![
                                                                      'Name'] ==
                                                                  null)
                                                          ? false
                                                          : true,
                                                      widget.tables[i].client);
                                                  Navigator.of(context).pop();
                                                } else {
                                                  bloc.changeOrderType('Mesa');
                                                  bloc.changeOrderName(
                                                      '${widget.tables[i].table}');
                                                  bloc.changeTableStatus(false);
                                                  widget.orderNameController!
                                                          .text =
                                                      widget.tables[i].table!;
                                                }
                                                Navigator.of(context).pop();
                                              }
                                            },
                                            style: ButtonStyle(
                                              backgroundColor: (widget
                                                      .tables[i].isOpen!)
                                                  ? MaterialStateProperty.all<
                                                      Color>(Colors.greenAccent)
                                                  : MaterialStateProperty.all<
                                                      Color>(Colors.white),
                                              overlayColor:
                                                  MaterialStateProperty
                                                      .resolveWith<Color?>(
                                                (Set<MaterialState> states) {
                                                  if (states.contains(
                                                      MaterialState.hovered))
                                                    return Colors.black12;
                                                  if (states.contains(
                                                          MaterialState
                                                              .focused) ||
                                                      states.contains(
                                                          MaterialState
                                                              .pressed))
                                                    return Colors.black26;
                                                  return null; // Defer to the widget's default.
                                                },
                                              ),
                                            ),
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    widget.tables[i].table!,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ])),
                                      );
                                    }))),
                      ],
                    ),
                  )));
        });
  }
}
