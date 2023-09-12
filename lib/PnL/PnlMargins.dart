import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PnlMargins extends StatefulWidget {
  final List pnlAccountGroups;
  final Map<dynamic, dynamic> pnlMapping;
  final double grossMargin;
  final double gross;
  final double operatingMargin;
  final double operating;
  final double profitMargin;
  final double profit;
  final AsyncSnapshot snapshot;

  PnlMargins(
      {this.pnlAccountGroups,
      this.pnlMapping,
      this.grossMargin,
      this.gross,
      this.operatingMargin,
      this.operating,
      this.profitMargin,
      this.profit,
      this.snapshot});

  @override
  _PnlMarginsState createState() => _PnlMarginsState();
}

class _PnlMarginsState extends State<PnlMargins> {
  final formatter = new NumberFormat("#,###");

  Widget marginBox(String marginName, double marginPercentage,
      double marginNumber, BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.18,
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: <BoxShadow>[
          new BoxShadow(
            color: Colors.grey[350],
            offset: Offset(0.0, 0.0),
            blurRadius: 10.0,
          )
        ],
      ),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Text
            Text(
              marginName,
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: Colors.black),
            ),
            SizedBox(height: 10),
            //Amount
            Text(
              '\$${formatter.format(marginNumber)}',
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.grey),
            ),
            SizedBox(height: 10),
            //Margin
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //Number
                  Text(
                    '${marginPercentage.toStringAsFixed(0)}',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 30),
                  ),
                  SizedBox(width: 5),
                  //%
                  Text(
                    '%',
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
                  ),
                ]),
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //Gross Margin
        marginBox(
            'Gross Margin',
            (!widget.grossMargin.isNaN && !widget.grossMargin.isInfinite)
                ? widget.grossMargin
                : 0,
            widget.gross,
            context),
        Spacer(),
        //Op. Margin
        marginBox(
            'Operating Margin',
            (!widget.operatingMargin.isNaN &&
                    !widget.operatingMargin.isInfinite)
                ? widget.operatingMargin
                : 0,
            widget.operating,
            context),
        Spacer(),
        //Profit Margin
        marginBox(
            'Profit Margin',
            (!widget.profitMargin.isNaN && !widget.profitMargin.isInfinite)
                ? widget.profitMargin
                : 0,
            widget.profit,
            context),
      ],
    );
  }
}
