class   OrderNew {
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
  final double balance;
  final double unit;

  OrderNew({
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
    required this.unit,
    required this.balance,
  });

  factory OrderNew.fromJson(Map<String, dynamic> json) {
    return OrderNew(
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
      balance: double.parse(json['balance']),
      unit: double.parse(json['unit']),
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
      'balance': balance,
      'unit': unit,
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
      'balance': balance,
      'unit': unit,
    };
  }
  String getIndex(int index) {
    switch (index) {
      case 0:
        return name;
      case 1:
        String remainder = (unit > 0 ? balance / unit : 0).toStringAsFixed(0);
        String quotient = (unit > 0 ? balance % unit : 0).toStringAsFixed(0);
        return '$remainder-$quotient';
      case 2:
        return _formatCurrency(rate);
      case 3:
        return (quantity).toString();
      case 4:
        return (rate * quantity).toStringAsFixed(0);
      case 5:
        return _formatCurrency(orderValue);


    }
    return '';
  }
  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)}';
  }
  static double calculateTotalOrderValue(List<OrderNew> orders) {
    double total = 0.0;
    for (var order in orders) {
      total += order.orderValue;
    }
    return total;
  }
}

