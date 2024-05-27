class PurOrder {
  final int purNo;
  final int distCode;
  final int cdistCode;
  final String date;
  final double amount;
  final String remarks;

  PurOrder({
    required this.purNo,
    required this.distCode,
    required this.cdistCode,
    required this.date,
    required this.amount,
    required this.remarks,
  });

  Map<String, dynamic> toMap() {
    return {
      'purNo': purNo,
      'distCode': distCode,
      'cdistCode': cdistCode,
      'date': date,
      'amount': amount,
      'remarks': remarks,
    };
  }

  factory PurOrder.fromMap(Map<String, dynamic> map) {
    return PurOrder(
      purNo: map['pur_no'],
      distCode: map['dist_code'],
      cdistCode: map['cdist_code'],
      date: map['date'],
      amount: map['amount'],
      remarks: map['remarks'],
    );
  }
}

class PurOrderDetail {
  final int id;
  final int purNo;
  final String pcode;
  final double rate;
  final int qty;
  final int bonus;
  final double dip;

  PurOrderDetail({
    required this.id,
    required this.purNo,
    required this.pcode,
    required this.rate,
    required this.qty,
    required this.bonus,
    required this.dip,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'purNo': purNo,
      'pcode': pcode,
      'rate': rate,
      'qty': qty,
      'bonus': bonus,
      'dip': dip,
    };
  }

  factory PurOrderDetail.fromMap(Map<String, dynamic> map) {
    return PurOrderDetail(
      id: map['id'],
      purNo: map['pur_no'],
      pcode: map['pcode'],
      rate: map['rate'],
      qty: map['qty'],
      bonus: map['bonus'],
      dip: map['dip'],
    );
  }
}
