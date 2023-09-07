import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Dashboard/SalesDetailsFilters.dart';
import 'package:denario/Models/DailyCash.dart';
import 'package:denario/Stats/DaillyStats.dart';
import 'package:denario/Stats/MonthlyStats.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatsDesk extends StatefulWidget {
  final String businessID;
  final CashRegister registerStatus;
  StatsDesk(this.businessID, this.registerStatus);
  @override
  _StatsDeskState createState() => _StatsDeskState();
}

class _StatsDeskState extends State<StatsDesk>
    with SingleTickerProviderStateMixin {
  bool showMonthlyStats;

  AnimationController _controller;
  Animation<double> _animation;
  bool _isExpanded = false;
  String dateFilter;
  DateTime selectedDate;

  @override
  void initState() {
    showMonthlyStats = false;
    dateFilter = 'Today';
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
        // height: MediaQuery.of(context).size.height * 1.2,
        padding: EdgeInsets.all(30),
        child: Stack(
          children: [
            //Stats Page
            Column(
              children: [
                SizedBox(height: 60),
                (showMonthlyStats)
                    ? MonthStats(widget.businessID, dateFilter, selectedDate)
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
            Container(
              width: double.infinity,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Today
                    Container(
                      height: 35,
                      width: 100,
                      child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: (!showMonthlyStats &&
                                    dateFilter == 'Today')
                                ? MaterialStateProperty.all<Color>(Colors.black)
                                : MaterialStateProperty.all<Color>(
                                    Colors.white),
                            overlayColor:
                                MaterialStateProperty.resolveWith<Color>(
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
                            setState(() {
                              showMonthlyStats = false;
                              dateFilter = 'Today';
                              selectedDate = DateTime.now();
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Center(
                              child: Text(
                                'Hoy',
                                style:
                                    (!showMonthlyStats && dateFilter == 'Today')
                                        ? TextStyle(
                                            color: Colors.white, fontSize: 12)
                                        : TextStyle(
                                            color: Colors.black, fontSize: 12),
                              ),
                            ),
                          )),
                    ),
                    SizedBox(width: 20),
                    //Month
                    Container(
                      height: 35,
                      width: 100,
                      child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: (showMonthlyStats)
                                ? MaterialStateProperty.all<Color>(Colors.black)
                                : MaterialStateProperty.all<Color>(
                                    Colors.white),
                            overlayColor:
                                MaterialStateProperty.resolveWith<Color>(
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
                            setState(() {
                              showMonthlyStats = true;
                              dateFilter = 'Month';
                              selectedDate = DateTime(
                                  DateTime.now().year, DateTime.now().month);
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Center(
                              child: Text(
                                'Mes',
                                style: (showMonthlyStats)
                                    ? TextStyle(
                                        color: Colors.white, fontSize: 12)
                                    : TextStyle(
                                        color: Colors.black, fontSize: 12),
                              ),
                            ),
                          )),
                    ),
                    SizedBox(width: 20),
                    //Ir a fecha
                    Container(
                      height: 35,
                      width: 100,
                      child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: (!showMonthlyStats &&
                                    dateFilter == 'Other')
                                ? MaterialStateProperty.all<Color>(Colors.black)
                                : MaterialStateProperty.all<Color>(
                                    Colors.white),
                            overlayColor:
                                MaterialStateProperty.resolveWith<Color>(
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
                          onPressed: () async {
                            //Open dialog box to select date
                            DateTime pickedDate = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now()
                                    .subtract(Duration(days: 365)),
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
                                            foregroundColor: Colors
                                                .black, // button text color
                                          ),
                                        ),
                                      ),
                                      child: child);
                                }));
                            setState(() {
                              if (pickedDate != null) {
                                selectedDate = pickedDate;
                              }
                              showMonthlyStats = false;
                              dateFilter = 'Other';
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Center(
                              child: Text(
                                'Ir a fecha',
                                style:
                                    (!showMonthlyStats && dateFilter == 'Other')
                                        ? TextStyle(
                                            color: Colors.white, fontSize: 12)
                                        : TextStyle(
                                            color: Colors.black, fontSize: 12),
                              ),
                            ),
                          )),
                    ),
                    SizedBox(width: 20),
                    //All
                    Container(
                      height: 35,
                      width: 100,
                      child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            overlayColor:
                                MaterialStateProperty.resolveWith<Color>(
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
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SalesDetailsFilters(
                                      widget.businessID,
                                      widget.registerStatus))),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Center(
                              child: Text(
                                'Todas',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 12),
                              ),
                            ),
                          )),
                    ),
                  ]),
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
                                    MaterialStateProperty.resolveWith<Color>(
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
                              onPressed: () {},
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
                                  MaterialStateProperty.resolveWith<Color>(
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
                            onPressed: () {},
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
