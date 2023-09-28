import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatsByCannels extends StatefulWidget {
  final Map channels;
  StatsByCannels(this.channels, {Key key}) : super(key: key);

  @override
  State<StatsByCannels> createState() => _StatsByCannelsState();
}

class _StatsByCannelsState extends State<StatsByCannels> {
  final formatCurrency = new NumberFormat.simpleCurrency();

  List keys = [];

  @override
  void initState() {
    keys = widget.channels.keys.toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        child: ListView.builder(
            itemCount: widget.channels.length,
            shrinkWrap: true,
            reverse: false,
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, i) {
              return Container(
                height: 35,
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //Payment Type
                    Container(
                        width: 150,
                        child: Text(
                          (keys[i] != "null") ? '${keys[i]}' : 'Sin definir',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )),
                    Spacer(),
                    //Monto vendidos
                    Container(
                        width: 120,
                        child: Center(
                          child: Text(
                            '${formatCurrency.format(widget.channels[keys[i]])}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                  ],
                ),
              );
            }),
      ),
    );
  }
}
