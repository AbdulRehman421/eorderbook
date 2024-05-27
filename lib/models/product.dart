  class Product {
    int id;
    int distCode;
    String pCode;
    String cmpCd;
    String name;
    double tp;
    double rp;
    int balance;
    String grCd;
    String active;
    bool selected = false;
    int bonus = 0;
    String? partyCode = "";
    double discount;
    int quantity;

    Product({
      required this.id,
      required this.distCode,
      required this.pCode,
      required this.cmpCd,
      required this.name,
      required this.tp,
      required this.rp,
      required this.quantity,
      required this.discount,
      required this.balance,
      required this.grCd,
      required this.active,
    });

    @override
    String toString() {
      return '{sku: $pCode, productName: $name, price: $tp, quantity: $quantity, discount: $discount, id: $id, selected: $selected}';
    }

    double get total => ((tp * quantity) - discount);

    String getIndex(int index) {
      switch (index) {
        case 0:
          return pCode;
        case 1:
          return name;
        case 2:
          return _formatCurrency(tp);
        case 3:
          return (quantity).toString();
        case 4:
          return (discount).toString();
        case 5:
          return _formatCurrency(total);
      }
      return '';
    }

    String _formatCurrency(double amount) {
      return amount.toStringAsFixed(0);
    }

    static double getTotal(List<Product> products) {
      double total = 0;
      for (Product product in products) {
        total += product.tp * product.quantity * (1 - product.discount / 100);
      }
      return total;
    }

    Map<String, dynamic> toSqlMap() {
      return {
        'ID': id,
        'dist_code': distCode,
        'pcode': pCode,
        'cmpcd': cmpCd,
        'name': name,
        'tp': tp,
        'rp': rp,
        'balance': balance,
        'grcd': grCd,
        'active': active,
      };
    }

    toMap(partyCode,entryName) {
      return {
        'pcode': pCode,
        'bonus': bonus,
        'rate': tp,
        'qty': quantity,
        'discount': discount,
        'code': partyCode,
        'username': entryName,
      };
    }

    factory Product.fromMap(Map<String, dynamic> map) {
      return Product(
        id: map['ID'],
        distCode: map['dist_code'],
        pCode: map['pcode'],
        cmpCd: map['cmpcd'],
        name: map['name'],
        tp: map['tp'],
        rp: map['rp'],
        discount: 0,
        quantity: 0,
        balance: map['balance'],
        grCd: map['grcd'],
        active: map['active'],
      );
    }

    factory Product.fromJson(Map<String, dynamic> json) {
      return Product(
        id: int.parse(json['ID']),
        distCode: int.parse(json['dist_code']),
        pCode: json['pcode'],
        cmpCd: json['cmpcd'],
        name: json['name'],
        tp: double.parse(json['tp']),
        rp: double.parse(json['rp']),
        discount: 0,
        quantity: 0,
        balance: int.parse(json['balance']),
        grCd: json['grcd'],
        active: json['active'],
      );
    }

    Map<String, dynamic> toJson() {
      return {
        'ID': id,
        'dist_code': distCode,
        'pcode': pCode,
        'cmpcd': cmpCd,
        'name': name,
        'tp': tp,
        'rp': rp,
        'balance': balance,
        'grcd': grCd,
        'active': active,
      };
    }
    Map<String, dynamic> toMaps() {
      return {
        'ID': id,
        'dist_code': distCode,
        'pcode': pCode,
        'cmpcd': cmpCd,
        'name': name,
        'tp': tp,
        'rp': rp,
        'balance': balance,
        'grcd': grCd,
        'active': active,
      };
    }
  }
