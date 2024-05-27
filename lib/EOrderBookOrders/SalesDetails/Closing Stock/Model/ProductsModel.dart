class Product {
  String minOrder;
  String companyCode;
  String unit;
  String name;
  String pCode;
  String rate;
  String qty;
  String pBal;
  String order;
  String dip;
  String cname;

  Product({
    required this.minOrder,
    required this.companyCode,
    required this.unit,
    required this.name,
    required this.pCode,
    required this.rate,
    required this.qty,
    required this.pBal,
    required this.order,
    required this.dip,
    required this.cname,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      minOrder: json['minorder'] ?? '',
      companyCode: json['companycode'] ?? '',
      unit: json['unit'] ?? '',
      name: json['name'] ?? '',
      pCode: json['pcode'] ?? '',
      rate: json['rate'] ?? '',
      qty: json['qty'] ?? '',
      pBal: json['pbal'] ?? '',
      order: json['order'] ?? '',
      dip: json['dip'] ?? '',
      cname: json['cname'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'minorder': minOrder,
      'companycode': companyCode,
      'unit': unit,
      'name': name,
      'pcode': pCode,
      'rate': rate,
      'qty': qty,
      'order': order,
      'dip': dip,
      'cname': cname,
    };
  }
  Map<String, dynamic> toMap() {
    return {
      'minorder': minOrder,
      'companycode': companyCode,
      'unit': unit,
      'name': name,
      'pcode': pCode,
      'rate': rate,
      'qty': qty,
      'pbal': pBal,
      'order': order,
      'dip': dip,
      'cname': cname,
    };
  }
  String getIndex(int index) {
    switch (index) {
      case 0:
        return pCode;
      case 1:
        return name;
      case 2:
        return _formatCurrency(double.parse(rate));
      case 3:
        return (dip).toString();
      case 4:
        return _formatCurrency(double.parse(order));
    }
    return '';
  }
  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0)}';
  }
}

class ProductMonthSale {
  final String year;
  final String month;
  final String totalQty;

  ProductMonthSale({required this.year, required this.month, required this.totalQty});

  factory ProductMonthSale.fromJson(Map<String, dynamic> json) {
    return ProductMonthSale(
      year: json['year'],
      month: json['month'],
      totalQty: json['total_qty'],
    );
  }
}
class ProductMonthPur {
  final String name;
  final String pname;
  final String invno;
  final String invdt;
  final String rate;
  final String qty;
  final String bonus;
  final String dip1;
  final String dip2;
  final String batchNo;
  final String expdt;

  ProductMonthPur({required this.name, required this.rate,required this.invdt,required this.invno,required this.pname, required this.qty,required this.bonus, required this.dip2, required this.dip1,required this.batchNo, required this.expdt});

  factory ProductMonthPur.fromJson(Map<String, dynamic> json) {
    return ProductMonthPur(
      pname: json['productname'],
      name: json['name'],
      invdt: json['date(i.invdt)'],
      invno: json['invno'],
      rate: json['rate'],
      qty: json['qty'],
      bonus: json['bonus'],
      dip2: json['dip1'],
      dip1: json['dip2'],
      batchNo: json['batchno'],
      expdt: json['date(id.expdt)'],
    );
  }
}
class ProductNames {
  final String name;
  final String pcode;

  ProductNames({required this.name, required this.pcode});

  factory ProductNames.fromJson(Map<String, dynamic> json) {
    return ProductNames(
      name: json['name'],
      pcode: json['pcode'],
    );
  }
}


