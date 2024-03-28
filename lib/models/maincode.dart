class MainCode {
  final String mainCode;

  MainCode({required this.mainCode});

  factory MainCode.fromJson(Map<String, dynamic> json) {
    return MainCode(mainCode: json['main_code']);
  }

  Map<String, dynamic> toJson() {
    return {
      'main_code': mainCode,
    };
  }
}