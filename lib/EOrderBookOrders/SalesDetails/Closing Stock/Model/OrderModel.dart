class   Order {
  final String name;
  final String companyCode;
  final String companyName;
  final String distributorCode;
  final String distributorName;
  final String purchaseNumber;
  final String productCode;
  final String purchaseOrderNumber;
  final double rate;
  final int quantity;
  final int bonus;
  final double discount;
  final DateTime date;
  final String distcode;
  final double orderValue;

  Order({
    required this.name,
    required this.companyCode,
    required this.companyName,
    required this.distributorCode,
    required this.distributorName,
    required this.purchaseNumber,
    required this.productCode,
    required this.purchaseOrderNumber,
    required this.rate,
    required this.quantity,
    required this.bonus,
    required this.discount,
    required this.date,
    required this.distcode,
    required this.orderValue,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      name: json['name'],
      companyCode: json['companycode'],
      companyName: json['companyname'],
      distributorCode: json['cdist_code'],
      distributorName: json['cdist_name'],
      purchaseNumber: json['pur_no'],
      productCode: json['pcode'],
      purchaseOrderNumber: json['dpur_no'],
      rate: double.parse(json['rate']),
      quantity: int.parse(json['qty']),
      bonus: int.parse(json['bonus']),
      discount: double.parse(json['dip']),
      date: DateTime.parse(json['date']),
      distcode: json['dist_code'],
      orderValue: double.parse(json['order_value']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'companycode': companyCode,
      'companyname': companyName,
      'cdist_code': distributorCode,
      'cdist_name': distributorName,
      'pur_no': purchaseNumber,
      'pcode': productCode,
      'dpur_no': purchaseOrderNumber,
      'rate': rate,
      'qty': quantity,
      'bonus': bonus,
      'dip': discount,
      'date': date.toIso8601String(),
      'dist_code': distcode,
      'order_value': orderValue,
    };
  }
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'companycode': companyCode,
      'companyname': companyName,
      'cdist_code': distributorCode,
      'cdist_name': distributorName,
      'pur_no': purchaseNumber,
      'pcode': productCode,
      'dpur_no': purchaseOrderNumber,
      'rate': rate,
      'qty': quantity,
      'bonus': bonus,
      'dip': discount,
      'date': date.toIso8601String(),
      'dist_code': distcode,
      'order_value': orderValue,
    };
  }
  String getIndex(int index) {
    switch (index) {
      case 0:
        return name;
      case 1:
        return _formatCurrency(rate);
      case 2:
        return (quantity).toString();
      case 3:
        return (discount).toStringAsFixed(2);
      case 4:
        return (orderValue).toStringAsFixed(2);
      case 5:
        return _formatCurrency(orderValue);
    }
    return '';
  }
  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)}';
  }
  static double calculateTotalOrderValue(List<Order> orders) {
    double total = 0.0;
    for (var order in orders) {
      total += order.orderValue;
    }
    return total;
  }
}

