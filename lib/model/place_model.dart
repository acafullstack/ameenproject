class PlaceModel {
  bool _success;
  String _message;
  Data _data;

  PlaceModel({bool success, String message, Data data}) {
    this._success = success;
    this._message = message;
    this._data = data;
  }

  bool get success => _success;
  set success(bool success) => _success = success;
  String get message => _message;
  set message(String message) => _message = message;
  Data get data => _data;
  set data(Data data) => _data = data;

  PlaceModel.fromJson(Map<String, dynamic> json) {
    _success = json['success'];
    _message = json['message'];
    _data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this._success;
    data['message'] = this._message;
    if (this._data != null) {
      data['data'] = this._data.toJson();
    }
    return data;
  }
}

class Data {
  List<Places> _places;

  Data({List<Places> places}) {
    this._places = places;
  }

  List<Places> get places => _places;
  set places(List<Places> places) => _places = places;

  Data.fromJson(Map<String, dynamic> json) {
    if (json['places'] != null) {
      _places = new List<Places>();
      json['places'].forEach((v) {
        _places.add(new Places.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this._places != null) {
      data['places'] = this._places.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Places {
  int _id;
  String _type;
  String _name;
  String _address;
  String _city;
  String _state;
  String _zip;
  String _country;
  String _latitude;
  String _longitude;
  String _phone;
  String _website;
  String _contactPerson;
  String _contactPhone;
  String _image;
  String _description;

  Places(
      {int id,
        String type,
        String name,
        String address,
        String city,
        String state,
        String zip,
        String country,
        String latitude,
        String longitude,
        String phone,
        String website,
        String contactPerson,
        String contactPhone,
        String image,
        String description}) {
    this._id = id;
    this._type = type;
    this._name = name;
    this._address = address;
    this._city = city;
    this._state = state;
    this._zip = zip;
    this._country = country;
    this._latitude = latitude;
    this._longitude = longitude;
    this._phone = phone;
    this._website = website;
    this._contactPerson = contactPerson;
    this._contactPhone = contactPhone;
    this._image = image;
    this._description = description;
  }

  int get id => _id;
  set id(int id) => _id = id;
  String get type => _type;
  set type(String type) => _type = type;
  String get name => _name;
  set name(String name) => _name = name;
  String get address => _address;
  set address(String address) => _address = address;
  String get city => _city;
  set city(String city) => _city = city;
  String get state => _state;
  set state(String state) => _state = state;
  String get zip => _zip;
  set zip(String zip) => _zip = zip;
  String get country => _country;
  set country(String country) => _country = country;
  String get latitude => _latitude;
  set latitude(String latitude) => _latitude = latitude;
  String get longitude => _longitude;
  set longitude(String longitude) => _longitude = longitude;
  String get phone => _phone;
  set phone(String phone) => _phone = phone;
  String get website => _website;
  set website(Null website) => _website = website;
  String get contactPerson => _contactPerson;
  set contactPerson(String contactPerson) => _contactPerson = contactPerson;
  String get contactPhone => _contactPhone;
  set contactPhone(String contactPhone) => _contactPhone = contactPhone;
  String get image => _image;
  set image(String image) => _image = image;
  String get description => _description;
  set description(Null description) => _description = description;

  Places.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _type = json['type'];
    _name = json['name'];
    _address = json['address'];
    _city = json['city'];
    _state = json['state'];
    _zip = json['zip'];
    _country = json['country'];
    _latitude = json['latitude'];
    _longitude = json['longitude'];
    _phone = json['phone'];
    _website = json['website'];
    _contactPerson = json['contact_person'];
    _contactPhone = json['contact_phone'];
    _image = json['image'];
    _description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this._id;
    data['type'] = this._type;
    data['name'] = this._name;
    data['address'] = this._address;
    data['city'] = this._city;
    data['state'] = this._state;
    data['zip'] = this._zip;
    data['country'] = this._country;
    data['latitude'] = this._latitude;
    data['longitude'] = this._longitude;
    data['phone'] = this._phone;
    data['website'] = this._website;
    data['contact_person'] = this._contactPerson;
    data['contact_phone'] = this._contactPhone;
    data['image'] = this._image;
    data['description'] = this._description;
    return data;
  }
}
