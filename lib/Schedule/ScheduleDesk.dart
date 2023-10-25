import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Models/ScheduledSales.dart';
import 'package:denario/Models/Stats.dart';
import 'package:denario/Models/User.dart';
import 'package:denario/No%20POS%20Sales/NewSaleScreen.dart';
import 'package:denario/Schedule/DaysList.dart';
import 'package:denario/Schedule/TasksList.dart';
import 'package:denario/Schedule/TasksWeeklyList.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScheduleDesk extends StatefulWidget {
  const ScheduleDesk({Key? key}) : super(key: key);

  @override
  State<ScheduleDesk> createState() => _ScheduleDeskState();
}

class _ScheduleDeskState extends State<ScheduleDesk> {
  List filtersList = [
    'Día',
    'Esta semana',
    'Semana anterior',
    'Próxima semana'
  ];
  List weekFilterList = ['Esta semana', 'Semana anterior', 'Próxima semana'];
  late String selectedFilter;
  late DateTime selectedDate;

  late String selectedWeekFilter;
  DateTime selectedWeek = DateTime.now();

  final List<String> meses = [
    'Enero',
    'Febrero',
    'VMarzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre'
  ];
  final List<String> diasDeLaSemana = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];
  final List<String> dDeLaSemana = [
    'L',
    'M',
    'M',
    'J',
    'V',
    'S',
    'D',
  ];

  List<DateTime> calendarDays = [];

  @override
  void initState() {
    selectedDate = DateTime.now();
    selectedFilter = 'Esta semana';
    selectedWeekFilter = 'Esta semana';

    DateTime initDate = selectedDate.subtract(Duration(days: 3));
    DateTime endDate = selectedDate.add(Duration(days: 14));

    var date = initDate;
    for (var x = 0; x < endDate.difference(initDate).inDays; x++) {
      calendarDays.add(date);
      date = date.add(Duration(days: 1));
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<UserData>(context);

    if (userProfile == UserData()) {
      return Container();
    }

    if (MediaQuery.of(context).size.width > 650) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            //Tasks view
            Expanded(
                flex: 5,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Title
                      Row(
                        children: [
                          Text(
                            'Agenda',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          //Calendar dialog
                          SizedBox(width: 15),
                          Container(
                            height: 20,
                            width: 20,
                            child: IconButton(
                              splashRadius: 1,
                              onPressed: () async {
                                DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now()
                                        .subtract(Duration(days: 365)),
                                    lastDate:
                                        DateTime.now().add(Duration(days: 365)),
                                    builder: ((context, child) {
                                      return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary: Colors
                                                  .black, // header background color
                                              onPrimary: Colors
                                                  .white, // header text color
                                              onSurface: Colors
                                                  .black, // body text color
                                            ),
                                            textButtonTheme:
                                                TextButtonThemeData(
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors
                                                    .black, // button text color
                                              ),
                                            ),
                                          ),
                                          child: child!);
                                    }));
                                setState(() {
                                  selectedDate = pickedDate!;
                                });

                                DateTime initDate =
                                    selectedDate.subtract(Duration(days: 3));
                                DateTime endDate =
                                    selectedDate.add(Duration(days: 14));
                                calendarDays = [];

                                var date = initDate;
                                for (var x = 0;
                                    x < endDate.difference(initDate).inDays;
                                    x++) {
                                  calendarDays.add(date);
                                  date = date.add(Duration(days: 1));
                                }
                              },
                              padding: EdgeInsets.all(0),
                              tooltip: 'Seleccionar fecha',
                              iconSize: 18,
                              icon: Icon(Icons.calendar_month),
                            ),
                          ),
                          //Go to today
                          SizedBox(
                              width: (selectedDate.day == DateTime.now().day &&
                                      selectedDate.month ==
                                          DateTime.now().month &&
                                      selectedDate.year == DateTime.now().year)
                                  ? 0
                                  : 8),
                          (selectedDate.day == DateTime.now().day &&
                                  selectedDate.month == DateTime.now().month &&
                                  selectedDate.year == DateTime.now().year)
                              ? SizedBox()
                              : TextButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedDate = DateTime.now();
                                    });
                                  },
                                  child: Text(
                                    'Hoy',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  )),

                          Spacer(),
                          Container(
                            height: 50,
                            child: Tooltip(
                              message: 'Hacer nueva venta fuera de caja',
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                ),
                                onPressed: () {
                                  final User user =
                                      FirebaseAuth.instance.currentUser!;
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MultiProvider(
                                                providers: [
                                                  StreamProvider<
                                                          UserData>.value(
                                                      initialData: UserData(),
                                                      value: DatabaseService()
                                                          .userProfile(user.uid
                                                              .toString())),
                                                  StreamProvider<
                                                      MonthlyStats>.value(
                                                    value: DatabaseService()
                                                        .monthlyStatsfromSnapshot(
                                                            userProfile
                                                                .activeBusiness!),
                                                    initialData: MonthlyStats(),
                                                  )
                                                ],
                                                child: Scaffold(
                                                    body: NewSaleScreen(
                                                  userProfile.activeBusiness!,
                                                  fromPOS: false,
                                                )),
                                              )));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add, size: 16),
                                        SizedBox(width: 10),
                                        Text('Crear nueva')
                                      ]),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 20),
                      //List of tasks within list of days
                      Expanded(
                        child: DaysList(userProfile.activeBusiness!,
                            selectedFilter, selectedDate),
                      )
                    ],
                  ),
                )),
            SizedBox(width: 30),
            //Calendar selection
            Expanded(
                flex: 5,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vista por semana',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Filtra por semana para ver el total de encargos por día, presiona el día para verlo a detalle',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey),
                      ),
                      SizedBox(height: 20),
                      //Available filters
                      Container(
                        width: double.infinity,
                        height: 50,
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: weekFilterList.length,
                            itemBuilder: ((context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                    right: 15, top: 5, bottom: 5),
                                child: Container(
                                  height: 40,
                                  width: 125,
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor: (weekFilterList[
                                                    index] !=
                                                selectedWeekFilter)
                                            ? MaterialStateProperty.all<Color>(
                                                Colors.white)
                                            : MaterialStateProperty.all<Color>(
                                                Colors.black),
                                        overlayColor: MaterialStateProperty
                                            .resolveWith<Color?>(
                                          (Set<MaterialState> states) {
                                            if (states.contains(
                                                MaterialState.hovered))
                                              return Colors.grey.shade200;
                                            if (states.contains(
                                                    MaterialState.focused) ||
                                                states.contains(
                                                    MaterialState.pressed))
                                              return Colors.grey.shade300;
                                            return null; // Defer to the widget's default.
                                          },
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          selectedWeekFilter =
                                              weekFilterList[index];
                                          selectedWeek = DateTime.now();
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 5),
                                        child: Center(
                                          child: Text(
                                            weekFilterList[index],
                                            textAlign: TextAlign.center,
                                            style: (weekFilterList[index] ==
                                                    selectedWeekFilter)
                                                ? TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12)
                                                : TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12),
                                          ),
                                        ),
                                      )),
                                ),
                              );
                            })),
                      ),
                      SizedBox(height: 20),
                      //Weekly
                      Expanded(
                          child: ListView.builder(
                              itemCount: 7,
                              itemBuilder: ((context, i) {
                                DateTime? now;

                                if (selectedWeekFilter == 'Esta semana') {
                                  now = DateTime.now();
                                } else if (selectedWeekFilter ==
                                    'Semana anterior') {
                                  now = DateTime.now()
                                      .subtract(Duration(days: 7));
                                } else if (selectedWeekFilter ==
                                    'Próxima semana') {
                                  now = DateTime.now().add(Duration(days: 7));
                                }

                                int currentDay = now!.weekday;
                                DateTime dayOfWeek = now.subtract(
                                    Duration(days: currentDay - (i + 1)));
                                return Container(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              selectedDate = dayOfWeek;
                                            });
                                          },
                                          child: Text(
                                            '${diasDeLaSemana[i]}, ${dayOfWeek.day} ${meses[dayOfWeek.month - 1]}',
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        StreamProvider<
                                                List<ScheduledSales>>.value(
                                            initialData: [],
                                            value: DatabaseService()
                                                .scheduledList(
                                                    userProfile.activeBusiness,
                                                    dayOfWeek),
                                            child: TaskWeeklyList(
                                                userProfile.activeBusiness!)),
                                      ],
                                    ));
                              })))
                    ],
                  ),
                )),
          ],
        ),
      );
    } else {
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.white,
              pinned: false,
              automaticallyImplyLeading: false,
              actions: <Widget>[Container()],
              expandedHeight: 150,
              flexibleSpace: FlexibleSpaceBar(
                background: Column(
                  children: [
                    //Title
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Text(
                            '${meses[selectedDate.month - 1]}',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          //Calendar dialog
                          SizedBox(width: 15),
                          Container(
                            height: 20,
                            width: 20,
                            child: IconButton(
                              splashRadius: 1,
                              onPressed: () async {
                                DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now()
                                        .subtract(Duration(days: 365)),
                                    lastDate:
                                        DateTime.now().add(Duration(days: 365)),
                                    builder: ((context, child) {
                                      return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary: Colors
                                                  .black, // header background color
                                              onPrimary: Colors
                                                  .white, // header text color
                                              onSurface: Colors
                                                  .black, // body text color
                                            ),
                                            textButtonTheme:
                                                TextButtonThemeData(
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors
                                                    .black, // button text color
                                              ),
                                            ),
                                          ),
                                          child: child!);
                                    }));
                                setState(() {
                                  selectedDate = pickedDate!;
                                });

                                DateTime initDate =
                                    selectedDate.subtract(Duration(days: 3));
                                DateTime endDate =
                                    selectedDate.add(Duration(days: 14));
                                calendarDays = [];

                                var date = initDate;
                                for (var x = 0;
                                    x < endDate.difference(initDate).inDays;
                                    x++) {
                                  calendarDays.add(date);
                                  date = date.add(Duration(days: 1));
                                }
                              },
                              padding: EdgeInsets.all(0),
                              tooltip: 'Seleccionar fecha',
                              iconSize: 18,
                              icon: Icon(Icons.calendar_month),
                            ),
                          ),
                          //Go to today
                          SizedBox(
                              width: (selectedDate.day == DateTime.now().day &&
                                      selectedDate.month ==
                                          DateTime.now().month &&
                                      selectedDate.year == DateTime.now().year)
                                  ? 0
                                  : 8),
                          (selectedDate.day == DateTime.now().day &&
                                  selectedDate.month == DateTime.now().month &&
                                  selectedDate.year == DateTime.now().year)
                              ? SizedBox()
                              : TextButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedDate = DateTime.now();
                                    });
                                  },
                                  child: Text(
                                    'Hoy',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  )),
                          Spacer(),
                          FloatingActionButton(
                            backgroundColor: Colors.greenAccent,
                            foregroundColor: Colors.black,
                            onPressed: () {
                              final User user =
                                  FirebaseAuth.instance.currentUser!;
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MultiProvider(
                                            providers: [
                                              StreamProvider<UserData>.value(
                                                  initialData: UserData(),
                                                  value: DatabaseService()
                                                      .userProfile(
                                                          user.uid.toString())),
                                              StreamProvider<
                                                  MonthlyStats>.value(
                                                value: DatabaseService()
                                                    .monthlyStatsfromSnapshot(
                                                        userProfile
                                                            .activeBusiness!),
                                                initialData: MonthlyStats(),
                                              )
                                            ],
                                            child: Scaffold(
                                                body: NewSaleScreen(
                                              userProfile.activeBusiness!,
                                              fromPOS: false,
                                            )),
                                          )));
                            },
                            child: Center(
                                child: Icon(
                              Icons.add,
                              color: Colors.black,
                            )),
                          ),
                        ],
                      ),
                    ),
                    //Available filters
                    Container(
                      height: 50,
                      width: double.infinity,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: calendarDays.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, i) {
                            return Container(
                              width: 50,
                              height: 50,
                              child: TextButton(
                                  style: TextButton.styleFrom(
                                      backgroundColor:
                                          (selectedDate == calendarDays[i])
                                              ? Colors.greenAccent
                                              : Colors.transparent),
                                  onPressed: () {
                                    setState(() {
                                      selectedDate = calendarDays[i];
                                    });
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      //Day of week
                                      Text(
                                        '${dDeLaSemana[calendarDays[i].weekday - 1]}',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 11),
                                      ),

                                      SizedBox(height: 5),
                                      //Number of day
                                      Text(
                                        '${calendarDays[i].day}',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: (selectedDate ==
                                                    calendarDays[i])
                                                ? FontWeight.bold
                                                : FontWeight.normal),
                                      ),
                                    ],
                                  )),
                            );
                          }),
                    ),
                  ],
                ),
              ),
            ),
            //List of tasks within list of days
            StreamProvider<List<ScheduledSales>>.value(
                initialData: [],
                value: DatabaseService()
                    .scheduledList(userProfile.activeBusiness, selectedDate),
                child: TaskList(userProfile.activeBusiness!)),
          ],
        ),
      );
    }
  }
}
