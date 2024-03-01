class OrderDetails {
  final int orderId;
  final String userName;
  final int distCode;
  final int appOrderNo;
  final int code;
  final String date;
  final double orderAmount;
  final String latitude;
  final String longitude;
  final String remarks;

  OrderDetails({
    required this.orderId,
    required this.userName,
    required this.distCode,
    required this.appOrderNo,
    required this.code,
    required this.date,
    required this.orderAmount,
    required this.latitude,
    required this.longitude,
    required this.remarks,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'user_name': userName,
      'dist_code': distCode,
      'app_orderno': appOrderNo,
      'code': code,
      'date': date,
      'order_amount': orderAmount,
      'latitude': latitude,
      'longitude': longitude,
      'remarks': remarks,
    };
  }

  factory OrderDetails.fromMap(Map<String, dynamic> map) {
    return OrderDetails(
      orderId: map['order_id'],
      userName: map['user_name'],
      distCode: map['dist_code'],
      appOrderNo: map['app_orderno'],
      code: map['code'],
      date: map['date'],
      orderAmount: map['order_amount'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      remarks: map['remarks'],
    );
  }
}

class ProductDetails {
  final int id;
  final int orderId;
  final String pcode;
  final int qty;
  final int bonus;
  final double rate;
  final double discount;

  ProductDetails({
    required this.id,
    required this.orderId,
    required this.pcode,
    required this.qty,
    required this.bonus,
    required this.rate,
    required this.discount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'pcode': pcode,
      'qty': qty,
      'bonus': bonus,
      'rate': rate,
      'discount': discount,
    };
  }

  factory ProductDetails.fromMap(Map<String, dynamic> map) {
    return ProductDetails(
      id: map['id'],
      orderId: map['order_id'],
      pcode: map['pcode'],
      qty: map['qty'],
      bonus: map['bonus'],
      rate: map['rate'],
      discount: map['discount'],
    );
  }
}