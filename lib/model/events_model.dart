class EventsModels {
  bool success;
  String message;
  Data data;

  EventsModels({this.success, this.message, this.data});

  EventsModels.fromJson(Map<String, dynamic> json) {
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
  String image;
  String location;
  String eventDate;
  String eventTime;
  String latitude;
  String longitude;
  String timer;

  Events({this.id, this.name, this.image, this.location, this.eventDate, this.eventTime});

  Events.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    location = json['location'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    eventDate = json['event_date'];
    eventTime = json['event_time'];
    timer = json['timer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['image'] = this.image;
    data['location'] = this.location;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['event_date'] = this.eventDate;
    data['event_time'] = this.eventTime;
    data['timer'] = this.timer;
    return data;
  }
}
