class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String cntCode;
  final String udid;
  final String logintoken;
  final String profileimage;
  final String isNotify;
  final String isFirst;
  final String islogin;
  final String balance;

  const User(
      {this.id = '',
      this.name = '',
      this.email = '',
      this.phone = '',
      this.cntCode = '',
      this.udid = '',
      this.logintoken = '',
      this.profileimage = '',
      this.isNotify = '',
      this.isFirst = '',
      this.islogin = '',
      this.balance = ''});

  User copy(
          {String? id,
          String? name,
          String? email,
          String? phone,
          String? cntCode,
          String? udid,
          String? logintoken,
          String? profileimage,
          String? isNotify,
          String? isFirst,
          String? islogin,
          String? balance}) =>
      User(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        cntCode: cntCode ?? this.cntCode,
        udid: udid ?? this.udid,
        logintoken: logintoken ?? this.logintoken,
        profileimage: profileimage ?? this.profileimage,
        isNotify: isNotify ?? this.isNotify,
        isFirst: isFirst ?? this.isFirst,
        islogin: islogin ?? this.islogin,
        balance: balance ?? this.balance,
      );

  static User fromJson(Map<String, dynamic> json) => User(
      id: json['id'].toString(),
      name: json['name'].toString(),
      email: json['email'].toString(),
      phone: json['phone'].toString(),
      udid: json['udid'].toString(),
      cntCode: json['cnt_code'].toString(),
      logintoken: json['login_token'].toString(),
      profileimage: json['profile_image'].toString(),
      isNotify: json['is_notify'].toString(),
      isFirst: json['is_first'].toString(),
      balance: json['total_balance']);

  Map<String, dynamic> toJson() => {
        'id': id.toString(),
        'name': name.toString(),
        'email': email.toString(),
        'phone': phone.toString(),
        'udid': udid.toString(),
        'cnt_code': cntCode.toString(),
        'login_token': logintoken.toString(),
        'profile_image': profileimage.toString(),
        'is_notify': isNotify.toString(),
        'is_first': isFirst.toString(),
        'total_balance': balance.toString()
      };
}
