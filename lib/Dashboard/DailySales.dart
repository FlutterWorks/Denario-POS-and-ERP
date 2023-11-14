import 'package:denario/Dashboard/RegisterSalesCard.dart';
import 'package:denario/Dashboard/RegisterTransactionsCard.dart';
import 'package:denario/Models/DailyCash.dart';
import 'package:denario/Models/User.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DailySales extends StatelessWidget {
  final formatCurrency = new NumberFormat.simpleCurrency();

  @override
  Widget build(BuildContext context) {
    final registerStatus = Provider.of<Registradora?>(context);
    final dailyTransactions = Provider.of<DailyTransactions?>(context);
    final userProfile = Provider.of<UserData?>(context);

    if (dailyTransactions == null) {
      return Container();
    }

    if (registerStatus == null || userProfile == null) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.42,
        height: 400,
        padding: EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: new BorderRadius.circular(12.0),
          boxShadow: <BoxShadow>[
            new BoxShadow(
              color: Colors.grey[350]!,
              offset: Offset(0.0, 0.0),
              blurRadius: 10.0,
            )
          ],
        ),
      );
    }

    if (MediaQuery.of(context).size.width > 1100) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //Total Sales
            Expanded(
                child: RegisterSalesCard(registerStatus, dailyTransactions,
                    userProfile.activeBusiness!)),

            SizedBox(height: 15),
            //Register Transactions
            Expanded(
                child: RegisterTransactionsCard(registerStatus,
                    dailyTransactions, userProfile.activeBusiness!)),
          ]);
    } else if (MediaQuery.of(context).size.width > 850) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //Total Sales
            Expanded(
                child: RegisterSalesCard(registerStatus, dailyTransactions,
                    userProfile.activeBusiness!)),
            SizedBox(width: 15),
            //Sales by Medium
            Expanded(
                child: RegisterTransactionsCard(registerStatus,
                    dailyTransactions, userProfile.activeBusiness!)),
          ]);
    } else {
      return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //Total Sales
            Container(
              width: double.infinity,
              height: 300,
              child: RegisterSalesCard(registerStatus, dailyTransactions,
                  userProfile.activeBusiness!),
            ),
            SizedBox(height: 15),
            //Sales by Medium
            Container(
                width: double.infinity,
                height: 300,
                child: RegisterTransactionsCard(registerStatus,
                    dailyTransactions, userProfile.activeBusiness!)),
          ]);
    }
  }
}
