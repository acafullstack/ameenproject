class JanazahModel {
  bool success;
  String message;
  Data data;

  JanazahModel({this.success, this.message, this.data});

  JanazahModel.fromJson(Map<String, dynamic> json) {
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
  List<Janazahs> janazahs;

  Data({this.janazahs});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['janazahs'] != null) {
      janazahs = new List<Janazahs>();
      json['janazahs'].forEach((v) {
        janazahs.add(new Janazahs.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.janazahs != null) {
      data['janazahs'] = this.janazahs.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Janazahs {
  int id;
  String nameOfDeceased;
  String image;
  String age;
  String gender;
  String heritage;
  String janazahDate;
  String janazahTime;
  String mosque;
  String cemetery;
  String latitude;
  String longitude;
  String janazah_after;

  Janazahs(
      {this.id,
        this.nameOfDeceased,
        this.image,
        this.age,
        this.gender,
        this.heritage,
        this.janazahDate,
        this.janazahTime,
        this.mosque,
        this.cemetery,
        this.latitude,
        this.longitude,
      this.janazah_after});

  Janazahs.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nameOfDeceased = json['name_of_deceased'];
    image = json['image'];
    age = json['age'];
    gender = json['gender'];
    heritage = json['heritage'];
    janazahDate = json['janazah_date'];
    janazahTime = json['janazah_time'];
    mosque = json['mosque'];
    cemetery = json['cemetery'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    janazah_after = json['janazah_after'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name_of_deceased'] = this.nameOfDeceased;
    data['image'] = this.image;
    data['age'] = this.age;
    data['gender'] = this.gender;
    data['heritage'] = this.heritage;
    data['janazah_date'] = this.janazahDate;
    data['janazah_time'] = this.janazahTime;
    data['mosque'] = this.mosque;
    data['cemetery'] = this.cemetery;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['janazah_after'] = janazah_after;
    return data;
  }
}
