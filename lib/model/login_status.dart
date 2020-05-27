class LoginStatus {
  bool success;
  String message;
  List<Data> data;

  LoginStatus({this.success, this.message, this.data});

  LoginStatus.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<Data>();
      json['data'].forEach((v) {
        data.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int id;
  String name;
  String email;
  String emailVerifiedAt;
  String profilePicture;
  String firebaseToken;
  String createdAt;
  String updatedAt;
  String role;
  String isApproved;
  String approvedAt;
  String address;
  String mobile;
  String accessToken;
  String isJanzahEnabled;

  Data(
      {this.id,
        this.name,
        this.email,
        this.emailVerifiedAt,
        this.profilePicture,
        this.firebaseToken,
        this.createdAt,
        this.updatedAt,
        this.role,
        this.isApproved,
        this.approvedAt,
        this.address,
        this.mobile,
        this.accessToken,
        this.isJanzahEnabled});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    profilePicture = json['profile_picture'];
    firebaseToken = json['firebase_token'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    role = json['role'];
    isApproved = json['is_approved'];
    approvedAt = json['approved_at'];
    address = json['address'];
    mobile = json['mobile'];
    accessToken = json['access_token'];
    isJanzahEnabled = json['is_janzah_enabled'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['profile_picture'] = this.profilePicture;
    data['firebase_token'] = this.firebaseToken;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['role'] = this.role;
    data['is_approved'] = this.isApproved;
    data['approved_at'] = this.approvedAt;
    data['address'] = this.address;
    data['mobile'] = this.mobile;
    data['access_token'] = this.accessToken;
    data['is_janzah_enabled'] = this.isJanzahEnabled;
    return data;
  }
}
