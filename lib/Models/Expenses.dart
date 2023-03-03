class Expenses {
  DateTime date;
  DateTime creationDate;
  String costType;
  String vendor;
  double total;
  String paymentType;
  List<ExpenseItems> items;
  String cashRegister;
  bool reversed;
  bool usedCashfromRegister;
  double amountFromRegister;
  String expenseID;
  List vendorSearchName;
  String referenceNo;

  Expenses(
      {this.date,
      this.creationDate,
      this.costType,
      this.total,
      this.vendor,
      this.paymentType,
      this.items,
      this.cashRegister,
      this.reversed,
      this.usedCashfromRegister,
      this.amountFromRegister,
      this.expenseID,
      this.vendorSearchName,
      this.referenceNo});
}

class ExpenseItems {
  String product;
  String category;
  double price;
  double qty;
  double total;

  ExpenseItems({this.product, this.category, this.price, this.qty, this.total});
}
