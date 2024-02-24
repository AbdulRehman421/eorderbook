class Company {
  int id;
  int distCode;
  String cmpCd;
  String name;

  Company({
    required this.id,
    required this.distCode,
    required this.cmpCd,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'ID': id,
      'dist_code': distCode,
      'cmpcd': cmpCd,
      'name': name,
    };
  }

  factory Company.fromMap(Map<String, dynamic> map) {
    return Company(
      id: map['ID'],
      distCode: map['dist_code'],
      cmpCd: map['cmpcd'],
      name: map['name'],
    );
  }

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: int.parse(json['ID']),
      distCode: int.parse(json['dist_code']),
      cmpCd: json['cmpcd'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'dist_code': distCode,
      'cmpcd': cmpCd,
      'name': name,
    };
  }
}
