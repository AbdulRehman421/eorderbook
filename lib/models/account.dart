import 'dart:ui';

import 'package:flutter/src/material/colors.dart';

class Account {
  int id;
  int distCode;
  int code;
  String name;
  String address;
  int areaCd;
  String active;
  String lic_exp_date;
  Color? cardColor; // Property to store the card color


  Account({
    required this.id,
    required this.distCode,
    required this.code,
    required this.name,
    required this.address,
    required this.areaCd,
    required this.active,
    required this.lic_exp_date,
    this.cardColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'ID': id,
      'dist_code': distCode,
      'code': code,
      'name': name,
      'address': address,
      'areacd': areaCd,
      'active': active,
      'lic_exp_date': lic_exp_date,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['ID'],
      distCode: map['dist_code'],
      code: map['code'],
      name: map['name'],
      address: map['address'],
      areaCd: map['areacd'],
      active: map['active'],
      lic_exp_date: map['lic_exp_date'],
    );
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: int.parse(json['ID']),
      distCode: int.parse(json['dist_code']),
      code: int.parse(json['code']),
      name: json['name'],
      address: json['address'],
      areaCd: int.parse(json['areacd']),
      active: json['active'],
      lic_exp_date: json['lic_exp_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'dist_code': distCode,
      'code': code,
      'name': name,
      'address': address,
      'areacd': areaCd,
      'active': active,
      'lic_exp_date': lic_exp_date,
    };
  }
}
