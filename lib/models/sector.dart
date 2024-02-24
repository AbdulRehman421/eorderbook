class Sector {
  int id;
  int distCode;
  int secCd;
  String name;

  Sector({
    required this.id,
    required this.distCode,
    required this.secCd,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'ID': id,
      'dist_code': distCode,
      'seccd': secCd,
      'name': name,
    };
  }

  factory Sector.fromMap(Map<String, dynamic> map) {
    return Sector(
      id: map['ID'],
      distCode: map['dist_code'],
      secCd: map['seccd'],
      name: map['name'],
    );
  }

  factory Sector.fromJson(Map<String, dynamic> json) {
    return Sector(
      id: int.parse(json['ID']),
      distCode: int.parse(json['dist_code']),
      secCd: int.parse(json['seccd']),
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'dist_code': distCode,
      'seccd': secCd,
      'name': name,
    };
  }
}
