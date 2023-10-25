import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Models/Tables.dart';
import 'package:denario/User%20Settings/CreateTableDialog.dart';
import 'package:denario/User%20Settings/FloorPlanning.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FloorPlanConfig extends StatefulWidget {
  final String businessID;
  const FloorPlanConfig(this.businessID, {Key? key}) : super(key: key);

  @override
  State<FloorPlanConfig> createState() => _FloorPlanConfigState();
}

class _FloorPlanConfigState extends State<FloorPlanConfig> {
  Future getTables() async {
    var firestore = FirebaseFirestore.instance;

    final docRef =
        firestore.collection('ERP').doc(widget.businessID).collection('Tables');

    QuerySnapshot querySnapshot = await docRef.get();

    final List<Tables> tableList = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>?; // Cast to nullable Map
      return Tables.fromFirestore(
          data ?? {}, doc.id); // Provide a default empty Map if data is null
    }).toList();

    return tableList;
  }

  late Future tablesFromSnap;
  List<Tables> newTables = [];
  late double baseSize;

  @override
  void initState() {
    tablesFromSnap = getTables();
    baseSize = 75;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: tablesFromSnap,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(); // or any other loading indicator
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          // _tablesNotifier.tables = snapshot.data;

          return ChangeNotifierProvider(
              create: (_) => TablesNotifier(initialItems: snapshot.data),
              child: FloorPlanNotifier(widget.businessID));
        });
  }
}

class FloorPlanNotifier extends StatefulWidget {
  final String businessID;
  const FloorPlanNotifier(this.businessID, {Key? key}) : super(key: key);

  @override
  State<FloorPlanNotifier> createState() => _FloorPlanNotifierState();
}

class _FloorPlanNotifierState extends State<FloorPlanNotifier> {
  late double baseSize;

  @override
  void initState() {
    baseSize = 75;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final tablesNotifier = Provider.of<TablesNotifier>(context);
    return Consumer<TablesNotifier>(builder: (context, tablesNotifier, _) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          leading: TextButton(
            child: Text(
              'Volver',
              style: TextStyle(color: Colors.black, fontSize: 14),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            'Configuración del salón',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.all(8),
              child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.black),
                    overlayColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.hovered))
                          return Colors.grey.shade500;
                        if (states.contains(MaterialState.focused) ||
                            states.contains(MaterialState.pressed))
                          return Colors.grey.shade500;
                        return null; // Defer to the widget's default.
                      },
                    ),
                  ),
                  onPressed: () {
                    tablesNotifier.tables.forEach((i) {
                      if (i.docID == '') {
                        //If is new, create new doc
                        DatabaseService()
                            .createTable(widget.businessID, i.toMap());
                      } else {
                        //If not, update table name and X,Y
                        //Update firestore doc
                        DatabaseService().updateExistingTable(
                            widget.businessID,
                            i.docID!,
                            i.table!,
                            i.x!,
                            i.y!,
                            (baseSize /
                                    (MediaQuery.of(context).size.height *
                                        MediaQuery.of(context).size.width)) *
                                100);
                      }
                    });
                    Navigator.of(context).pop();
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
          ],
        ),
        body: FloorPlanning(widget.businessID, baseSize, tablesNotifier),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Row(
            //   children: [
            //     //Minus
            //     ElevatedButton(
            //       style: ButtonStyle(
            //         backgroundColor:
            //             MaterialStateProperty.all<Color>(Colors.black),
            //         overlayColor: MaterialStateProperty.resolveWith<Color>(
            //           (Set<MaterialState> states) {
            //             if (states.contains(MaterialState.hovered))
            //               return Colors.grey.shade500;
            //             if (states.contains(MaterialState.focused) ||
            //                 states.contains(MaterialState.pressed))
            //               return Colors.grey.shade500;
            //             return null; // Defer to the widget's default.
            //           },
            //         ),
            //       ),
            //       onPressed: () {
            //         setState(() {
            //           baseSize = baseSize - (baseSize * 0.1);
            //         });
            //       },
            //       child: Container(
            //         height: 40,
            //         width: 40,
            //         child: Center(
            //             child: Icon(Icons.zoom_out,
            //                 color: Colors.white, size: 21)),
            //       ),
            //     ),
            //     SizedBox(width: 12),
            //     //More
            //     ElevatedButton(
            //       style: ButtonStyle(
            //         backgroundColor:
            //             MaterialStateProperty.all<Color>(Colors.black),
            //         overlayColor: MaterialStateProperty.resolveWith<Color>(
            //           (Set<MaterialState> states) {
            //             if (states.contains(MaterialState.hovered))
            //               return Colors.grey.shade500;
            //             if (states.contains(MaterialState.focused) ||
            //                 states.contains(MaterialState.pressed))
            //               return Colors.grey.shade500;
            //             return null; // Defer to the widget's default.
            //           },
            //         ),
            //       ),
            //       onPressed: () {
            //         setState(() {
            //           baseSize = baseSize + (baseSize * 0.1);
            //         });
            //       },
            //       child: Container(
            //         height: 40,
            //         width: 40,
            //         child: Center(
            //             child: Icon(Icons.zoom_in,
            //                 color: Colors.white, size: 21)),
            //       ),
            //     ),
            //   ],
            // ),
            // SizedBox(width: 30),
            FloatingActionButton(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              hoverColor: Colors.grey,
              splashColor: Colors.grey.shade300,
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return CreateTableDialog(
                          widget.businessID, tablesNotifier);
                      // ChangeNotifierProvider(
                      //     create: (_) => _tablesNotifier,
                      //     child: CreateTableDialog(
                      //         widget.businessID, _tablesNotifier));
                    });
              },
              child: Icon(Icons.add),
            ),
          ],
        ),
      );
    });
  }
}
