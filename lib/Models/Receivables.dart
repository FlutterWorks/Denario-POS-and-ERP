import 'package:denario/Models/Sales.dart';

class Receivables {
  DateTime? savedDate; //
  double? discount; //
  double? tax; //
  List<SoldItems>? orderDetail; //
  String? orderName; //
  String? orderID; //
  double? subTotal; //
  double? total; //
  String? orderType; //
  String? clientName;
  Map? clientDetails; //
  String? id; //
  String? cashRegister; //
  bool? pending;

  Receivables(
      {this.savedDate,
      this.discount,
      this.tax,
      this.orderDetail,
      this.orderName,
      this.orderID,
      this.subTotal,
      this.total,
      this.orderType,
      this.clientName,
      this.clientDetails,
      this.id,
      this.cashRegister,
      this.pending});
}
