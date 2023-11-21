import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Dashboard/SalesDetailsFilters.dart';
import 'package:denario/Models/DailyCash.dart';
import 'package:denario/Models/Stats.dart';
import 'package:denario/No%20POS%20Sales/NewSaleScreen.dart';
import 'package:denario/Stats/DaillyStats.dart';
import 'package:denario/Stats/MonthlyStats.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatsDesk extends StatefulWidget {
  final String businessID;
  final Registradora registerStatus;
  StatsDesk(this.businessID, this.registerStatus);
  @override
  _StatsDeskState createState() => _StatsDeskState();
}

class _StatsDeskState extends State<StatsDesk>
    with SingleTickerProviderStateMixin {
  late bool showMonthlyStats;

  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isExpanded = false;
  late String dateFilter;
  late DateTime selectedDate;

  String year = DateTime.now().year.toString();
  String month = DateTime.now().month.toString();

  @override
  void initState() {
    showMonthlyStats = false;
    dateFilter = 'Hoy';
    selectedDate = DateTime.now();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        child: Stack(
          children: [
            //Stats Page
            Column(
              children: [
                SizedBox(height: 80),
                (showMonthlyStats)
                    ? StreamProvider<MonthlyStats?>.value(
                        value: DatabaseService().monthlyStatsfromSnapshot(
                            widget.businessID, year, month),
                        initialData: null,
                        child: MonthStats(widget.businessID, dateFilter,
                            selectedDate, year, month))
                    : StreamProvider<List<DailyTransactions>>.value(
                        initialData: [],
                        value: DatabaseService().specificDailyTransactions(
                            widget.businessID,
                            selectedDate.year.toString(),
                            selectedDate.month.toString(),
                            selectedDate),
                        child: DailyStats(
                            widget.businessID, dateFilter, selectedDate)),
              ],
            ),
            //Select Monthly or Daily Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PopupMenuButton<int>(
                    child: Container(
                      height: 50,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: <BoxShadow>[
                          new BoxShadow(
                            color: Colors.grey[350]!,
                            offset: Offset(0.0, 0.0),
                            blurRadius: 10.0,
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.filter_alt,
                              color: Colors.black,
                              size: 16,
                            ),
                            SizedBox(width: 10),
                            Text(
                              dateFilter,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    onSelected: (value) async {
                      switch (value) {
                        case 0:
                          setState(() {
                            showMonthlyStats = false;
                            dateFilter = 'Hoy';
                            selectedDate = DateTime.now();
                          });
                          break;
                        case 1:
                          setState(() {
                            showMonthlyStats = true;
                            dateFilter = 'Mes';
                            selectedDate = DateTime(
                                DateTime.now().year, DateTime.now().month);
                          });
                          break;
                        case 2:
                          //Open dialog box to select date
                          DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate:
                                  DateTime.now().subtract(Duration(days: 365)),
                              lastDate: DateTime.now(),
                              builder: ((context, child) {
                                return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: Colors
                                            .black, // header background color
                                        onPrimary:
                                            Colors.white, // header text color
                                        onSurface:
                                            Colors.black, // body text color
                                      ),
                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor:
                                              Colors.black, // button text color
                                        ),
                                      ),
                                    ),
                                    child: child!);
                              }));
                          setState(() {
                            selectedDate = pickedDate!;
                            showMonthlyStats = false;
                            dateFilter = 'Fecha';
                          });
                          break;
                        case 3:
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SalesDetailsFilters(
                                      widget.businessID,
                                      widget.registerStatus)));
                      }
                    },
                    itemBuilder: (context) {
                      List<PopupMenuItem<int>> items = [
                        //Discount
                        PopupMenuItem<int>(
                          value: 0,
                          child: Center(
                            child: Text(
                              'Hoy',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 12),
                            ),
                          ),
                        ),
                        //Tax
                        PopupMenuItem<int>(
                          value: 1,
                          child: Center(
                            child: Text(
                              'Mes',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 12),
                            ),
                          ),
                        ),
                        //Custom item
                        PopupMenuItem<int>(
                          value: 2,
                          child: Center(
                            child: Text(
                              'Ir a fecha',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 12),
                            ),
                          ),
                        ),
                        //All
                        PopupMenuItem<int>(
                          value: 3,
                          child: Center(
                            child: Text(
                              'Todas',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 12),
                            ),
                          ),
                        ),
                      ];
                      return items;
                    }),
                SizedBox(width: 20),
                //Mes
                (showMonthlyStats)
                    ? Container(
                        height: 50,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: <BoxShadow>[
                            new BoxShadow(
                              color: Colors.grey[350]!,
                              offset: Offset(0.0, 0.0),
                              blurRadius: 10.0,
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            //Month
                            Container(
                              padding: EdgeInsets.all(5),
                              child: DropdownButton<String>(
                                value: month.toString(),
                                //elevation: 5,
                                style: TextStyle(color: Colors.black),
                                items: <String>[
                                  '1',
                                  '2',
                                  '3',
                                  '4',
                                  '5',
                                  '6',
                                  '7',
                                  '8',
                                  '9',
                                  '10',
                                  '11',
                                  '12',
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                hint: Text(
                                  month.toString(),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    month = value!;
                                    selectedDate = DateTime(
                                        selectedDate.year, int.parse(value), 0);
                                  });
                                },
                              ),
                            ),
                            Divider(
                                indent: 5,
                                endIndent: 5,
                                color: Colors.grey,
                                thickness: 0.5),
                            //Year
                            Container(
                              padding: EdgeInsets.all(5),
                              child: DropdownButton<String>(
                                value: year.toString(),
                                //elevation: 5,
                                style: TextStyle(color: Colors.black),
                                items: <String>[
                                  '2021',
                                  '2022',
                                  '2023',
                                  '2024',
                                  '2025',
                                  '2026',
                                  '2027',
                                  '2028',
                                  '2029',
                                  '2030',
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                hint: Text(
                                  year.toString(),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    year = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox()
              ],
            ),
            //Create
            Align(
              alignment: Alignment.topRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    tooltip: 'Crear',
                    onPressed: _toggleDropdown,
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.grey,
                    child: Icon(
                      _isExpanded ? Icons.close : Icons.add,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  if (_isExpanded)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: FadeTransition(
                        opacity: _animation,
                        child: Container(
                          height: 35,
                          width: 150,
                          child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white),
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
                                _toggleDropdown();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            StreamProvider<MonthlyStats?>.value(
                                              value: DatabaseService()
                                                  .monthlyStatsfromSnapshot(
                                                      widget.businessID,
                                                      year,
                                                      month),
                                              initialData: null,
                                              child: NewSaleScreen(
                                                widget.businessID,
                                                fromPOS: false,
                                              ),
                                            )));
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 5),
                                child: Center(
                                  child: Text(
                                    'Crear Venta',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              )),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: FadeTransition(
                      opacity: _animation,
                      child: Container(
                        height: 35,
                        width: 150,
                        child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              overlayColor:
                                  MaterialStateProperty.resolveWith<Color?>(
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
                              _toggleDropdown();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
                              child: Center(
                                child: Text(
                                  'Crear Remito',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            )),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
