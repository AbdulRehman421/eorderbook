class Area {
  int id;
  int distCode;
  int areaCd;
  String name;
  int secCd;

  Area({
    required this.id,
    required this.distCode,
    required this.areaCd,
    required this.name,
    required this.secCd,
  });

  Map<String, dynamic> toMap() {
    return {
      'ID': id,
      'dist_code': distCode,
      'areacd': areaCd,
      'name': name,
      'seccd': secCd,
    };
  }

  factory Area.fromMap(Map<String, dynamic> map) {
    return Area(
      id: map['ID'],
      distCode: map['dist_code'],
      areaCd: map['areacd'],
      name: map['name'],
      secCd: map['seccd'],
    );
  }

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: int.parse(json['ID']),
      distCode: int.parse(json['dist_code']),
      areaCd: int.parse(json['areacd']),
      name: json['name'],
      secCd: int.parse(json['seccd']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'dist_code': distCode,
      'areacd': areaCd,
      'name': name,
      'seccd': secCd,
    };
  }
}
