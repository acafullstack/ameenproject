class BusinessDirectory {
  bool success;
  String message;
  Data data;

  BusinessDirectory({this.success, this.message, this.data});

  BusinessDirectory.fromJson(Map<String, dynamic> json) {
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
  List<Events> events;

  Data({this.events});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['events'] != null) {
      events = new List<Events>();
      json['events'].forEach((v) {
        events.add(new Events.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.events != null) {
      data['events'] = this.events.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Events {
  int id;
  String name;
  String address;
  String latitude;
  String longitude;
  String phone;
  String image;
  String website;

  Events(
      {this.id,
        this.name,
        this.address,
        this.latitude,
        this.longitude,
        this.phone,
        this.image,
        this.website});

  Events.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    address = json['address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    phone = json['phone'];
    image = json['image'];
    website = json['website'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['address'] = this.address;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['phone'] = this.phone;
    data['image'] = this.image;
    data['website'] = this.website;
    return data;
  }
}
