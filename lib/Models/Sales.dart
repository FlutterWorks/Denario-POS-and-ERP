class Sales {
  String account;
  DateTime date;
  double discount;
  double tax;
  List<SoldItems> soldItems;
  String orderName;
  String orderID;
  double subTotal;
  double total;
  String paymentType;
  String clientName;
  Map clientDetails;
  String transactionID;
  String docID;
  String cashRegister;
  bool reversed;
  String orderType;
  List splitPaymentDetails;
  double totalSuppliesCost;

  Sales(
      {this.account,
      this.date,
      this.discount,
      this.tax,
      this.soldItems,
      this.orderName,
      this.orderID,
      this.subTotal,
      this.total,
      this.paymentType,
      this.clientName,
      this.clientDetails,
      this.transactionID,
      this.docID,
      this.cashRegister,
      this.reversed,
      this.orderType,
      this.splitPaymentDetails,
      this.totalSuppliesCost});
}

class SoldItems {
  String product;
  String category;
  double price;
  double qty;
  double total;
  List supplies;

  SoldItems(
      {this.product,
      this.category,
      this.price,
      this.qty,
      this.total,
      this.supplies});
}
