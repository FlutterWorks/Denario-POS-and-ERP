class Discounts {
  String code;
  String description;
  double discount;
  bool active;
  int numberOfUses;
  DateTime createdDate;
  DateTime validUntil;

  Discounts({
    this.code,
    this.description,
    this.discount,
    this.active,
    this.numberOfUses,
    this.createdDate,
    this.validUntil,
  });
}
