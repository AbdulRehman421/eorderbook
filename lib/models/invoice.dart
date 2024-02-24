import 'package:eorderbook/models/eorderbook.dart';
import 'package:eorderbook/models/eorderbook_master.dart';

class Invoice {
  EOrderBookMaster orderDetails;
  List<EOrderBook> productDetails;

  Invoice({required this.orderDetails, required this.productDetails});

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      orderDetails: EOrderBookMaster.fromJson(json['orderDetails']),
      productDetails: (json['productDetails'] as List)
          .map((productJson) => EOrderBook.fromJson(productJson))
          .toList(),
    );
  }

  double get orderAmount {
    return productDetails
        .map<double>((product) => product.totalAmount)
        .fold<double>(0.0, (a, b) => a + b);
  }
}