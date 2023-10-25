import 'package:denario/Models/User.dart';
import 'package:flutter/material.dart';

class BusinessScheduleSettings extends StatefulWidget {
  final String rol;
  final businessOpens;
  final changeOpenTime;
  final changeCloseTime;
  final BusinessProfile userBusiness;
  const BusinessScheduleSettings(this.rol, this.businessOpens,
      this.changeCloseTime, this.changeOpenTime, this.userBusiness,
      {Key? key})
      : super(key: key);

  @override
  State<BusinessScheduleSettings> createState() =>
      _BusinessScheduleSettingsState();
}

class _BusinessScheduleSettingsState extends State<BusinessScheduleSettings> {
  List? businessSchedule;
  List daysOfWeek = [
    'Lunes',
    'Martes',
    'Miercoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo'
  ];

  void openTime(i) async {
    TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialEntryMode: TimePickerEntryMode.input,
        helpText: 'Horario de apertura',
        confirmText: 'Guardar',
        cancelText: 'Cancelar',
        hourLabelText: 'Hora',
        minuteLabelText: 'Minuto',
        initialTime: TimeOfDay(hour: 9, minute: 00),
        builder: ((context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
                // Using 24-Hour format
                alwaysUse24HourFormat: true),
            child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Colors.black, // header background color
                    onPrimary: Colors.white, // header text color
                    onSurface: Colors.black, // body text color
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black, // button text color
                    ),
                  ),
                ),
                child: child!),
          );
        }));
    setState(() {
      businessSchedule![i]
          ['Open'] = {'Hour': pickedTime!.hour, 'Minute': pickedTime.minute};
      widget.changeOpenTime(
          {'Hour': pickedTime.hour, 'Minute': pickedTime.minute}, i);
    });
  }

  void closeTime(i) async {
    TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialEntryMode: TimePickerEntryMode.input,
        helpText: 'Horario de cierre',
        confirmText: 'Guardar',
        cancelText: 'Cancelar',
        hourLabelText: 'Hora',
        minuteLabelText: 'Minuto',
        initialTime: TimeOfDay(hour: 20, minute: 00),
        builder: ((context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
                // Using 24-Hour format
                alwaysUse24HourFormat: true),
            child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Colors.black, // header background color
                    onPrimary: Colors.white, // header text color
                    onSurface: Colors.black, // body text color
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black, // button text color
                    ),
                  ),
                ),
                child: child!),
          );
        }));
    setState(() {
      businessSchedule![i]
          ['Close'] = {'Hour': pickedTime!.hour, 'Minute': pickedTime.minute};
      widget.changeCloseTime(
          {'Hour': pickedTime.hour, 'Minute': pickedTime.minute}, i);
    });
  }

  @override
  void initState() {
    if (widget.userBusiness.businessSchedule!.isNotEmpty) {
      businessSchedule = widget.userBusiness.businessSchedule;
    } else {
      businessSchedule = [
        {
          'Opens': false,
          'Open': {'Hour': 9, 'Minute': 00},
          'Close': {'Hour': 19, 'Minute': 00},
        },
        {
          'Opens': false,
          'Open': {'Hour': 9, 'Minute': 00},
          'Close': {'Hour': 19, 'Minute': 00},
        },
        {
          'Opens': false,
          'Open': {'Hour': 9, 'Minute': 00},
          'Close': {'Hour': 19, 'Minute': 00},
        },
        {
          'Opens': false,
          'Open': {'Hour': 9, 'Minute': 00},
          'Close': {'Hour': 19, 'Minute': 00},
        },
        {
          'Opens': false,
          'Open': {'Hour': 9, 'Minute': 00},
          'Close': {'Hour': 19, 'Minute': 00},
        },
        {
          'Opens': false,
          'Open': {'Hour': 9, 'Minute': 00},
          'Close': {'Hour': 19, 'Minute': 00},
        },
        {
          'Opens': false,
          'Open': {'Hour': 9, 'Minute': 00},
          'Close': {'Hour': 19, 'Minute': 00},
        },
      ];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: businessSchedule!.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: ((context, i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Day and open?
              Row(
                children: [
                  Container(
                    width: 75,
                    child: Text(
                      daysOfWeek[i],
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ),
                  SizedBox(width: 10),
                  Switch(
                    value: businessSchedule![i]['Opens'],
                    onChanged: (value) {
                      setState(() {
                        businessSchedule![i]['Opens'] = value;
                        widget.businessOpens(value, i);
                        widget.changeOpenTime({'Hour': 0, 'Minute': 0}, i);
                        widget.changeCloseTime({'Hour': 0, 'Minute': 0}, i);
                      });
                    },
                    activeTrackColor: Colors.lightGreenAccent,
                    activeColor: Colors.green,
                  ),
                ],
              ),
              SizedBox(height: 5),
              //Time
              (businessSchedule![i]['Opens'])
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Open
                        Container(
                          width: 150,
                          child: TextButton(
                            onPressed: () => openTime(i),
                            child: Container(
                              height: 50,
                              width: 120,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12))),
                              child: Center(
                                child: Text(
                                  '${businessSchedule![i]['Open']['Hour'].toString().padLeft(2, '0')} : ${businessSchedule![i]['Open']['Minute'].toString().padLeft(2, '0')}',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 15),
                        //Close
                        Container(
                          width: 150,
                          child: TextButton(
                            onPressed: () => closeTime(i),
                            child: Container(
                              height: 50,
                              width: 120,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12))),
                              child: Center(
                                child: Text(
                                  '${businessSchedule![i]['Close']['Hour'].toString().padLeft(2, '0')} : ${businessSchedule![i]['Close']['Minute'].toString().padLeft(2, '0')}',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : SizedBox()
            ],
          ),
        );
      }),
    );
  }
}
