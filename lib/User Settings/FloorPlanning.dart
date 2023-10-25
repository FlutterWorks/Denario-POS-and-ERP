import 'package:denario/Models/Tables.dart';
import 'package:denario/User%20Settings/EditTableDialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FloorPlanning extends StatefulWidget {
  final String businessID;
  final double baseSize;
  final TablesNotifier tablesNotifier;
  const FloorPlanning(this.businessID, this.baseSize, this.tablesNotifier,
      {Key? key})
      : super(key: key);

  @override
  State<FloorPlanning> createState() => _FloorPlanningState();
}

class _FloorPlanningState extends State<FloorPlanning> {
  TablesNotifier? _tablesNotifier;
  bool isHovered = false;

  Widget _buildTableWidget(TablesNotifier tablesNotifier, Tables table, int i) {
    switch (table.shape) {
      case 'Square':
        return GestureDetector(
          onLongPress: () {
            showDialog(
                context: context,
                builder: (context) {
                  return ChangeNotifierProvider(
                      create: (_) => _tablesNotifier,
                      child: EditTableDialog(
                          widget.businessID, table, widget.tablesNotifier, i));
                });
          },
          child: Container(
            padding: EdgeInsets.all(5.0),
            width: widget.baseSize,
            height: widget.baseSize,
            decoration: BoxDecoration(
              borderRadius: new BorderRadius.circular(12.0),
              color: Colors.white,
              boxShadow: <BoxShadow>[
                new BoxShadow(
                  color: Colors.grey[350]!,
                  offset: Offset(0.0, 0.0),
                  blurRadius: 10.0,
                )
              ],
            ),
            child: Center(
              child: Text(
                table.table!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w800),
              ),
            ),
          ),
        );
      case 'Circle':
        return GestureDetector(
          onLongPress: () {
            showDialog(
                context: context,
                builder: (context) {
                  return ChangeNotifierProvider(
                      create: (_) => _tablesNotifier,
                      child: EditTableDialog(
                          widget.businessID, table, widget.tablesNotifier, i));
                });
          },
          child: Container(
            width: widget.baseSize,
            height: widget.baseSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: <BoxShadow>[
                new BoxShadow(
                  color: Colors.grey[350]!,
                  offset: Offset(0.0, 0.0),
                  blurRadius: 10.0,
                )
              ],
            ),
            child: Center(
              child: Text(
                table.table!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w800),
              ),
            ),
          ),
        );
      case 'Wide Rectangle':
        return MouseRegion(
          onEnter: (event) => setState(() => isHovered = true),
          onExit: (event) => setState(() => isHovered = false),
          child: GestureDetector(
            onLongPress: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return ChangeNotifierProvider(
                        create: (_) => _tablesNotifier,
                        child: EditTableDialog(widget.businessID, table,
                            widget.tablesNotifier, i));
                  });
            },
            child: Container(
              width: widget.baseSize * 2,
              height: widget.baseSize,
              decoration: BoxDecoration(
                borderRadius: new BorderRadius.circular(12.0),
                color: Colors.white,
                boxShadow: <BoxShadow>[
                  new BoxShadow(
                    color: Colors.grey[350]!,
                    offset: Offset(0.0, 0.0),
                    blurRadius: 10.0,
                  )
                ],
              ),
              child: Stack(
                children: [
                  // isHovered
                  // ? Align(
                  //     alignment: Alignment.topRight,
                  //     child: IconButton(
                  //       onPressed: () {
                  //         setState(() {
                  //           table.shape = 'Tall Rectangle';
                  //         });
                  //         tablesNotifier
                  //           ..editTable(table,
                  //               tablesNotifier.tables.indexOf(table));
                  //       },
                  //       icon: Icon(Icons.autorenew),
                  //       iconSize: 14,
                  //       color: Colors.black,
                  //     ),
                  //   )
                  // : Container(),
                  Center(
                    child: Text(
                      table.table!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      case 'Tall Rectangle':
        return MouseRegion(
          onEnter: (event) => setState(() => isHovered = true),
          onExit: (event) => setState(() => isHovered = false),
          child: GestureDetector(
            onLongPress: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return ChangeNotifierProvider(
                        create: (_) => _tablesNotifier,
                        child: EditTableDialog(widget.businessID, table,
                            widget.tablesNotifier, i));
                  });
            },
            child: Container(
              width: widget.baseSize,
              height: widget.baseSize * 2,
              decoration: BoxDecoration(
                borderRadius: new BorderRadius.circular(12.0),
                color: Colors.white,
                boxShadow: <BoxShadow>[
                  new BoxShadow(
                    color: Colors.grey[350]!,
                    offset: Offset(0.0, 0.0),
                    blurRadius: 10.0,
                  )
                ],
              ),
              child: Stack(
                children: [
                  // isHovered
                  //     ? Align(
                  //         alignment: Alignment.topRight,
                  //         child: IconButton(
                  //           onPressed: () {
                  //             setState(() {
                  //               table.shape = 'Wide Rectangle';
                  //             });
                  //             tablesNotifier
                  //               ..editTable(table,
                  //                   tablesNotifier.tables.indexOf(table));
                  //           },
                  //           icon: Icon(Icons.autorenew),
                  //           iconSize: 14,
                  //           color: Colors.black,
                  //         ),
                  //       )
                  //     : Container(),
                  Center(
                    child: Text(
                      table.table!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

      default:
        return Container();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TablesNotifier>(builder: (context, tablesNotifier, _) {
      final List<Tables> tables = tablesNotifier.tables;
      return InteractiveViewer(
        child: Stack(
          children: [
            ...tables.map((table) => Positioned(
                  left: MediaQuery.of(context).size.width * table.x!,
                  top: MediaQuery.of(context).size.height * table.y!,
                  child: Draggable(
                    data: table,
                    child: _buildTableWidget(
                        tablesNotifier, table, tables.indexOf(table)),
                    feedback: Material(
                        child: _buildTableWidget(tablesNotifier, table,
                            tables.indexOf(table))), //_buildTableWidget(table),
                    childWhenDragging: Container(),
                    onDragEnd: (details) {
                      setState(() {
                        table.x = (details.offset.dx /
                            MediaQuery.of(context).size.width);
                        table.y = ((details.offset.dy - 57) /
                            (MediaQuery.of(context).size.height));
                        table.tableSize = (widget.baseSize /
                                (MediaQuery.of(context).size.height *
                                    MediaQuery.of(context).size.width)) *
                            100;
                      });
                    },
                  ),
                )),
          ],
        ),
      );
    });
  }
}
