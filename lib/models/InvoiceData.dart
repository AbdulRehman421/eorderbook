import 'package:eorderbook/models/account.dart';
import 'package:eorderbook/models/product.dart';

part 'InvoiceData.g.dart';

class MyData {
  late List<Product> products;
  String paidAmount;
  Account customer;
  String date;
  int invoiceId;
  int invoiceNumber;

  String? partyCode = "";

  @override
  String toString() {
    return 'MyData{products: $products, paidAmount: $paidAmount, customer: $customer, date: $date, invoiceId: $invoiceId, invoiceNumber: $invoiceNumber}';
  }

  MyData(this.products, this.invoiceId, this.invoiceNumber, this.paidAmount, this.customer,
      this.date);

  double get discountTotal {
    double initial = 0;
    for (int i = 0; i < products.length; i++) {
      initial = initial + products[i].discount;
    }
    return initial;
  }

  set product(List<Product> products) {
    this.products = products;
  }

  List<Product> get product => products;

  double get total {
    if (products.isNotEmpty) {
      return products.map<double>((p) => p.total).reduce((a, b) => a + b);
    } else {
      return 0.0; // or any other default value you prefer
    }
  }


}
