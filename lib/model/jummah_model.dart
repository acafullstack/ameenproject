class JummahModel {
  bool success;
  String message;
  Data data;

  JummahModel({this.success, this.message, this.data});

  JummahModel.fromJson(Map<String, dynamic> json) {
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
  String date;
  String firstJummah;
  String secondJummah;
  String thirdJummah;
  String address;
  String latitude;
  String longitude;
  String phone;
  String image;
  String website;
  String contactName;
  String contactPhone;
  String timer;

  Events(
      {this.id,
        this.name,
        this.date,
        this.firstJummah,
        this.secondJummah,
        this.thirdJummah,
        this.address,
        this.latitude,
        this.longitude,
        this.phone,
        this.image,
        this.website,
        this.contactName,
        this.contactPhone,
        this.timer});

  Events.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    date = json['date'];
    firstJummah = json['first_jummah'];
    secondJummah = json['second_jummah'];
    thirdJummah = json['third_jummah'];
    address = json['address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    phone = json['phone'];
    image = json['image'];
    website = json['website'];
    contactName = json['contact_name'];
    contactPhone = json['contact_phone'];
    timer = json['timer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['date'] = this.date;
    data['first_jummah'] = this.firstJummah;
    data['second_jummah'] = this.secondJummah;
    data['third_jummah'] = this.thirdJummah;
    data['address'] = this.address;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['phone'] = this.phone;
    data['image'] = this.image;
    data['website'] = this.website;
    data['contact_name'] = this.contactName;
    data['contact_phone'] = this.contactPhone;
    data['timer'] = this.timer;
    return data;
  }
}
