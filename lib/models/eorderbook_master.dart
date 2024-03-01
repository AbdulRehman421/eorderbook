class EOrderBookMaster {
  int? orderId;
  String userName;
  int distCode;
  int appOrderNo;
  int code;
  String date;
  double orderAmount;
  String latitude;
  String longitude;
  String remarks;

  EOrderBookMaster({
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

  factory EOrderBookMaster.fromMap(Map<String, dynamic> map) {
    return EOrderBookMaster(
      userName: map['user_name'],
      distCode: map['dist_code'],
      appOrderNo: map['app_orderno'],
      code: map['code'],
      date:map['date'],
      orderAmount: map['order_amount'].toDouble(),
      latitude: map['latitude'],
      longitude: map['longitude'],
      remarks: map['remarks'],
    );
  }

  factory EOrderBookMaster.fromJson(Map<String, dynamic> json) {
    return EOrderBookMaster(
      userName: json['user_name'],
      distCode: json['dist_code'],
      appOrderNo: json['app_orderno'],
      code: json['code'],
      date: json['date'],
      orderAmount: json['order_amount'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      remarks: json['remarks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
}
