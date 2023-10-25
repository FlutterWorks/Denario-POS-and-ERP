class SavedOrders {
  String? orderName;
  double? subTotal;
  double? total;
  double? tax;
  double? discount;
  String? paymentType;
  List? orderDetail;
  int? orderColor;
  String? id;
  bool? isTable;
  String? orderType;
  DateTime? savedDate;
  Map? client;

  SavedOrders(
      {this.orderName,
      this.subTotal,
      this.total,
      this.tax,
      this.discount,
      this.paymentType,
      this.orderDetail,
      this.orderColor,
      this.id,
      this.isTable,
      this.orderType,
      this.savedDate,
      this.client});
}
