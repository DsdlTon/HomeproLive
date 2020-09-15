// import 'package:http/http.dart' as Http;
// import 'dart:convert';

// class UserService {
//   static Future<List<UserDao>> getAllUser() async {
//     var url = "http://10.0.2.2:3000/api/user/";
//     var response = await Http.get(url);
//     print('response: ${response.body}');
//     List list = json.decode(response.body);
//     return list.map((m) => UserDao.fromjson(m)).toList();
//   }

//   static Future<List<UserDao>> getUserById(id) async {
//     var url = "http://10.0.2.2:3000/api/user/{$id}";
//     var response = await Http.get(url);
//     print('response: ${response.body}');
//     List list = json.decode(response.body);
//     return list.map((m) => UserDao.fromjson(m)).toList();
//   }

//   static Future<bool> createUserInDB(body) async {
//     final response =
//         await Http.post("http://10.0.2.2:3000/api/user/", body: body);
//     if (response.statusCode == 200) {
//       return true;
//     } else {
//       return false;
//     }
//   }

//   static Future<bool> createUserInFirebase(body) async {
//     final response =
//         await Http.post("http://10.0.2.2:3000/api/user/createuser", body: body);
//     if (response.statusCode == 200) {
//       return true;
//     } else {
//       return false;
//     }
//   }

//   static Future<bool> login(body) async {
//     final response =
//         await Http.post("http://10.0.2.2:3000/api/user/login", body: body);
//     if (response.statusCode == 200) {
//       return true;
//     } else {
//       return false;
//     }
//   }
// }

// class UserDao {
//   String name;
//   String surname;
//   String email;
//   String username;
//   String password;
//   String phone;

//   UserDao(
//       {this.name,
//       this.surname,
//       this.email,
//       this.username,
//       this.password,
//       this.phone});

//   factory UserDao.fromjson(Map<String, dynamic> json) {
//     return UserDao(
//       name: json["name"],
//       surname: json["surname"],
//       email: json["email"],
//       username: json["username"],
//       password: json["password"],
//       phone: json["phone"],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       "name": this.name,
//       "surname": this.surname,
//       "email": this.email,
//       "username": this.username,
//       "password": this.password,
//       "phone": this.phone,
//     };
//   }
// }