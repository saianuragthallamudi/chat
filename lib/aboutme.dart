import 'package:shared_preferences/shared_preferences.dart';

class aboutme{

  static String Loggedin = "ISLOGGEDIN";
  static String UserName = "USERNAMEKEY";
  static String UserEmail = "USEREMAILKEY";
  
  static Future<bool> saveUserLoggedIn(bool isUserLoggedIn) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setBool(Loggedin, isUserLoggedIn);
  }

  static Future<bool> saveUserName(String userName) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(UserName, userName);
  }

  static Future<bool> saveUserEmail(String userEmail) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(UserEmail, userEmail);
  }

  static Future<bool> getUserLoggedIn() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getBool(Loggedin);
  }

  static Future<String> getUserName() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getString(UserName);
  }

  static Future<String> getUserEmail() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getString(UserEmail);
  }

}