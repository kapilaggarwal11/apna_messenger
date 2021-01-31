import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static String userIdKey = "USERID";
  static String userNameKey = "USERNAME";
  static String displayNameKey = "DISPLAYNAME";
  static String userEmailKey = "USEREMAIL";
  static String userProfilePictureKey = "USERIMAGE";

  //Save data
  Future<bool> saveUserId(String getUserId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userIdKey, getUserId);
  }

  // save user name
  Future<bool> saveUserName(String getUserName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userNameKey, getUserName);
  }

  Future<bool> saveDisplayName(String getDisplayName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(displayNameKey, getDisplayName);
  }

  Future<bool> saveUserEmail(String getUserEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userEmailKey, getUserEmail);
  }

  Future<bool> saveUserProfilePicture(String getUserProfilePicture) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userProfilePictureKey, getUserProfilePicture);
  }

  //Get data
  Future<String> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("--==--==--==Id");
    print(prefs.getString(userIdKey));
    return prefs.getString(userIdKey);
  }

  //get user name
  Future<String> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("--==--==--==Username");
    print(prefs.getString(userNameKey));
    return prefs.getString(userNameKey);
  }

  Future<String> getDisplayName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("--==--==--==DisplayName");
    print(prefs.getString(displayNameKey));
    return prefs.getString(displayNameKey);
  }

  Future<String> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("--==--==--==Email");
    print(prefs.getString(userEmailKey));
    return prefs.getString(userEmailKey);
  }

  Future<String> getUserProfilePicture() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("--==--==--==Img");
    print(prefs.getString(userProfilePictureKey));
    return prefs.getString(userProfilePictureKey);
  }
}
