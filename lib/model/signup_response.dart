class SignUpResponse {
  bool success;
  String message;
  Data data;

  SignUpResponse({this.success, this.message, this.data});

  SignUpResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class Data {
  User user;

  Data({this.user});

  Data.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    return data;
  }
}

class User {
  int id;
  String name;
  String email;
  String role;
  String profilePicture;
  String address;
  String createdAt;
  String access_token;

  User(
      {this.id,
        this.name,
        this.email,
        this.role,
        this.profilePicture,
        this.address,
        this.createdAt,
      this.access_token});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    role = json['role'];
    profilePicture = json['profile_picture'];
    address = json['address'];
    createdAt = json['created_at'];
    access_token = json['access_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['role'] = this.role;
    data['profile_picture'] = this.profilePicture;
    data['address'] = this.address;
    data['created_at'] = this.createdAt;
    data['access_token'] = this.access_token;
    return data;
  }
}
