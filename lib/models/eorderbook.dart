class EOrderBook {
  int id;
  int orderId;
  String pCode;
  int qty;
  int bonus;
  double rate;
  double discount;

  EOrderBook({
    required this.id,
    required this.orderId,
    required this.pCode,
    required this.qty,
    required this.bonus,
    required this.rate,
    required this.discount,
  });

  double get totalAmount {
    return (qty - bonus) * rate - discount;
  }

  factory EOrderBook.fromMap(Map<String, dynamic> map) {
    return EOrderBook(
      id: map['id'],
      orderId: map['order_id'],
      pCode: map['pcode'],
      qty: map['qty'],
      bonus: map['bonus'],
      rate: map['rate'].toDouble(),
      discount: map['discount'].toDouble(),
    );
  }

  factory EOrderBook.fromJson(Map<String, dynamic> json) {
    return EOrderBook(
      id: json['id'],
      orderId: json['order_id'],
      pCode: json['pcode'],
      qty: json['qty'],
      bonus: json['bonus'],
      rate: json['rate'],
      discount: json['discount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'pcode': pCode,
      'qty': qty,
      'bonus': bonus,
      'rate': rate,
      'discount': discount,
    };
  }
}
