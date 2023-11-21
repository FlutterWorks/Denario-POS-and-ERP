class Ticket {
  String? orderName;
  List<TicketItem>? items;
  String? paymentType;
  double? subtotal;
  double? discounts;
  double? total;

  Ticket(
      {this.orderName,
      this.items,
      this.paymentType,
      this.subtotal,
      this.discounts,
      this.total});
}

class TicketItem {
  String? itemName;
  String? itemCategory;
  double? itemPrice;
  double? itemQty;

  TicketItem({this.itemName, this.itemCategory, this.itemPrice, this.itemQty});
}
