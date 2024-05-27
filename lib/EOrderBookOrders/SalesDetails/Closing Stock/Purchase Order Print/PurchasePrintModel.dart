class PurchasePrintModel {
  final String name;
  final String cdistcode;
  final String amount;
  final String date;
  final String distcode;
  final String purNo;
  final String dPurNo;

  PurchasePrintModel({required this.name, required this.cdistcode, required this.amount,required this.date, required this.distcode, required this.purNo,required this.dPurNo});

  factory PurchasePrintModel.fromJson(Map<String, dynamic> json) {
    return PurchasePrintModel(
      name: json['name'],
      cdistcode: json['cdist_code'],
      amount: json['amount'],
      date: json['date'],
      distcode: json['dist_code'],
      purNo: json['pur_no'],
      dPurNo: json['dpur_no'],
    );
  }
}

