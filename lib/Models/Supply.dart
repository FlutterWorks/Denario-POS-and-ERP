class Supply {
  String supply;
  List searchName;
  double price;
  String unit;
  double qty;
  List suppliers;
  List suppliersSearchName;
  List recipe;
  List priceHistory;
  String docID;

  Supply(
      {this.supply,
      this.searchName,
      this.price,
      this.unit,
      this.qty,
      this.suppliers,
      this.suppliersSearchName,
      this.recipe,
      this.priceHistory,
      this.docID});
}

// class SupplyRecipe {
//   String ingredient;
//   double qty;

//   SupplyRecipe({this.ingredient, this.qty});
// }
