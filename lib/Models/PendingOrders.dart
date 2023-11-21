class PendingOrders {
  String? orderName;
  String? address;
  int? phone;
  double? total;
  String? paymentType;
  List? orderDetail;
  DateTime? orderDate;
  String? docID;
  String? orderType;

  PendingOrders(
      {this.orderName,
      this.total,
      this.address,
      this.phone,
      this.paymentType,
      this.orderDetail,
      this.orderDate,
      this.docID,
      this.orderType});
}
