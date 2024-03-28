import 'package:eorderbook/main.dart';

class Distributor {
  int id;
  int distCode;
  int mainCode;
  String name;
  int bonus;

  Distributor({
    required this.id,
    required this.distCode,
    required this.mainCode,
    required this.name,
    required this.bonus,
  });

  Map<String, dynamic> toMap() {
    return {
      'ID': id,
      'dist_code': distCode,
      'main_code': mainCode,
      'name': name,
      'bonus': bonus,
    };
  }

  factory Distributor.fromMap(Map<String, dynamic> map) {
    return Distributor(
      id: map['ID'],
      distCode: map['dist_code'],
      mainCode: map['main_code'],
      name: map['name'],
      bonus: map['bonus'],
    );
  }

  factory Distributor.fromJson(Map<String, dynamic> json) {
    return Distributor(
      id: int.parse(json['ID']),
      distCode: int.parse(json['dist_code']),
      mainCode: int.parse(json['main_code']),
      name: json['name'],
      bonus: int.parse(json['bonus']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'dist_code': distCode,
      'main_code': mainCode,
      'name': name,
      'bonus': bonus,
    };
  }
}
