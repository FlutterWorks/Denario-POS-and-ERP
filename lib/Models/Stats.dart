class MonthlyStats {
  double totalSales;
  int totalSalesCount;
  int totalItemsSold;
  Map<String, dynamic> salesCountbyProduct;
  Map<String, dynamic> salesAmountbyProduct;
  Map<String, dynamic> salesCountbyCategory;
  Map<String, dynamic> salesAmountbyCategory;
  Map<String, dynamic> salesbyOrderType;
  Map<String, dynamic> salesByMedium;
  double totalSuppliesCost;

  MonthlyStats(
      {this.totalSales,
      this.totalSalesCount,
      this.totalItemsSold,
      this.salesCountbyProduct,
      this.salesCountbyCategory,
      this.salesAmountbyProduct,
      this.salesAmountbyCategory,
      this.salesbyOrderType,
      this.salesByMedium,
      this.totalSuppliesCost});
}
