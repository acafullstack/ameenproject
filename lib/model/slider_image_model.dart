class SliderImage {
  bool success;
  String message;
  Data data;

  SliderImage({this.success, this.message, this.data});

  SliderImage.fromJson(Map<String, dynamic> json) {
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
  List<Salats> salats;

  Data({this.salats});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['salats'] != null) {
      salats = new List<Salats>();
      json['salats'].forEach((v) {
        salats.add(new Salats.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.salats != null) {
      data['salats'] = this.salats.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Salats {
  int id;
  String header;
  String subHeader;
  String link;

  Salats({this.id, this.header, this.subHeader, this.link});

  Salats.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    header = json['header'];
    subHeader = json['sub_header'];
    link = json['link'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['header'] = this.header;
    data['sub_header'] = this.subHeader;
    data['link'] = this.link;
    return data;
  }
}
