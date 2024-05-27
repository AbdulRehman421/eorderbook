
import 'package:eorderbook/EOrderBookOrders/SalesDetails/Closing%20Stock/Model/OrderModel.dart';

class MyData {
  late List<Order> products;
  DateTime time = DateTime.now();

  @override
  String toString() {
    return 'MyData{products: $products}';
  }

  MyData(this.products);

  int get discountTotal {
    var initial = 0;
    for (int i = 0; i < products.length; i++) {
      initial = initial + int.parse(products[i].rate.toString());
    }
    return initial;
  }

  set product(List<Order> products) {
    this.products = products;
  }

  List<Order> get product => products;



}

  /*Map<String, dynamic> toMap() {
    Map<String,dynamic>productM={};
    int i=0;
    for (var element in products) {
      productM.putIfAbsent("$time - $i", () => element.toMap(customer.id));
      i++;
  }

    print(productM);
    return {"prod":productM};
  }*/
  Map<String, dynamic> toMap(current,entry) {

    Map<String, dynamic> newMap = {};


    print(newMap);
    return newMap;
  }
