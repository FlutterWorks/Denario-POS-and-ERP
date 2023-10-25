import 'package:denario/Models/Expenses.dart';

class Payables {
  DateTime? date;
  DateTime? creationDate;
  String? costType;
  String? vendor;
  double? total;
  String? paymentType;
  List<ExpenseItems>? items;
  String? expenseID;
  List? vendorSearchName;
  String? referenceNo;

  Payables(
      {this.date,
      this.creationDate,
      this.costType,
      this.total,
      this.vendor,
      this.paymentType,
      this.items,
      this.expenseID,
      this.vendorSearchName,
      this.referenceNo});
}
