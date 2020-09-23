import 'dart:io';

import 'package:http/http.dart' as Http;
import 'dart:convert';
import '../models/ProductDao.dart';

String baseUrl = "https://188.166.189.84";

class UserService {
  // static Future<List<UserDao>> getAllUser() async {
  //   var url = "http://10.0.2.2:3000/api/user/";
  //   var response = await Http.get(url);
  //   print('response: ${response.body}');
  //   List list = json.decode(response.body);
  //   return list.map((m) => UserDao.fromjson(m)).toList();
  // }

  // static Future<List<UserDao>> getUserById(id) async {
  //   var url = "http://10.0.2.2:3000/api/user/{$id}";
  //   var response = await Http.get(url);
  //   print('response: ${response.body}');
  //   List list = json.decode(response.body);
  //   return list.map((m) => UserDao.fromjson(m)).toList();
  // }

  static Future<bool> createUserInDB(body) async {
    final response = await Http.post("$baseUrl/auth/register", body: body);
    print('/////////////${response.body}');
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static Future<UserDao> login(body) async {
    print('LOGIN API');
    final response = await Http.post("$baseUrl/auth/login", body: body);
    final String responseString = response.body;
    print('LOGIN API2');
    return userDaoFromJson(responseString);
  }
}

UserDao userDaoFromJson(String str) => UserDao.fromJson(json.decode(str));
String userDaoToJson(UserDao data) => json.encode(data.toJson());

class UserDao {
  int id;
  String name;
  String surname;
  String email;
  String username;
  String password;
  String phone;
  String accessToken;
  String message;

  UserDao({
    this.id,
    this.name,
    this.surname,
    this.email,
    this.username,
    this.password,
    this.phone,
    this.accessToken,
    this.message,
  });

  factory UserDao.fromJson(Map<String, dynamic> json) {
    return UserDao(
      id: json["id"],
      name: json["name"],
      surname: json["surname"],
      email: json["email"],
      username: json["username"],
      password: json["password"],
      phone: json["phone"],
      accessToken: json["accessToken"],
      message: json["message"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "name": this.name,
      "surname": this.surname,
      "email": this.email,
      "username": this.username,
      "password": this.password,
      "phone": this.phone,
      "accessToken": this.accessToken,
      "message": this.message,
    };
  }
}

//--------------------------------------------------------------------------

class ProductService {
  static Future<ProductDao> getProductDetail(id) async {
    
    final response = await Http.get("https://188.166.189.84/api/product/{$id}");
    print('PRODUCTDETAILS RESPONSE: ${response.body}');
    if (response.statusCode == 200) {
      final String responseString = response.body;
      return productDaoFromJson(responseString);
      // List list = json.decode(response.body);
      // return list.map((m) => ProductDao.fromJson(m)).toList();
    } else {
      throw Exception('Failed to Load Product Data!!!');
    }
  }
}

ProductDao productDaoFromJson(String str) =>
    ProductDao.fromJson(json.decode(str));
String productToJson(ProductDao data) => json.encode(data.toJson());
