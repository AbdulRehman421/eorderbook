class User {
  int userId;
  int roleId;
  int distCode;
  String username;
  String description;
  String mobile;
  String email;
  String password;
  int eOrderBookUser;
  int active;

  User({
    required this.userId,
    required this.roleId,
    required this.distCode,
    required this.username,
    required this.description,
    required this.mobile,
    required this.email,
    required this.password,
    required this.eOrderBookUser,
    required this.active,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'role_id': roleId,
      'dist_code': distCode,
      'username': username,
      'description': description,
      'mobile': mobile,
      'email': email,
      'password': password,
      'eorderbookuser': eOrderBookUser,
      'active': active,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['user_id'],
      roleId: map['role_id'],
      distCode: map['dist_code'],
      username: map['username'],
      description: map['description'],
      mobile: map['mobile'],
      email: map['email'],
      password: map['password'],
      eOrderBookUser: map['eorderbookuser'],
      active: map['active'],
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: int.parse(json['user_id']),
      roleId: int.parse(json['role_id']),
      distCode: int.parse(json['dist_code']),
      username: json['username'],
      description: json['description'],
      mobile: json['mobile'],
      email: json['email'],
      password: json['password'],
      eOrderBookUser: int.parse(json['eorderbookuser']),
      active: int.parse(json['active']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'role_id': roleId,
      'dist_code': distCode,
      'username': username,
      'description': description,
      'mobile': mobile,
      'email': email,
      'password': password,
      'eorderbookuser': eOrderBookUser,
      'active': active,
    };
  }
}
