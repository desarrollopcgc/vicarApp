import 'package:flutter/material.dart';

const Color kTextColor = Color(0xFFFFFFFF);
const Color kBackgroundColor = Color(0xFF179448);
const Color kColor1 = Color(0xFF179448);
const Color kColor2 = Color(0xFFD72E0F);
const Color kColor3 = Color(0xFFFE3A41);
const Color kColor4 = Color(0xFF000000);
const Color kColor5 = Color(0xFF2E2E2E);

//ENVIROMENTS VARS//
//API URLS//
const String usrInfo = '$baseUrl/users/';
const String registerUrl = '$baseUrl/users/';
const String employeesInfo = '$baseUrl/employees/';
const String logInUrl = '$baseUrl/users/authenticate';
const String detailPayment = '$baseUrl/PayRollDetails/';
const String historyPayment = '$baseUrl/PayRollHeaders/';
const String baseUrl = 'https://api.emcocables.com:14001';
//API URLS//
//ENVIROMENTS VARS//

class Services {
  final int id;
  final String name;
  final Color color;
  final IconData icon;
  final String description;

  const Services({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    required this.description,
  });

  factory Services.fromJson(Map<String, dynamic> json) => Services(
        id: json["id"],
        name: json["name"],
        color: json["color"],
        icon: json["icon"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "color": color,
        "icon": icon,
        "description": description,
      };

  Services copy() => Services(
        id: id,
        name: name,
        color: color,
        icon: icon,
        description: description,
      );
}

class Members {
  final int id;
  final String name;
  final Color color;
  final String photo;
  final String description;

  const Members({
    required this.id,
    required this.name,
    required this.color,
    required this.photo,
    required this.description,
  });

  factory Members.fromJson(Map<String, dynamic> json) => Members(
        id: json["id"],
        name: json["name"],
        color: json["color"],
        photo: json["photo"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "color": color,
        "photo": photo,
        "description": description,
      };

  Members copy() => Members(
        id: id,
        name: name,
        color: color,
        photo: photo,
        description: description,
      );
}
