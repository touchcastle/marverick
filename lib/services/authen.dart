import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marverick/utils/constants.dart';
import 'package:marverick/services/pdf.dart';

// class User {
//   String? id;
//   String? name;
//   String? department;
//   String? position;
//
//   User({
//     this.id,
//     this.name,
//     this.department,
//     this.position,
//   });
// }

class Authen {
  static final auth = FirebaseAuth.instance;
  static var user;
  static bool isSample = false;
  static int forceAdmin = 0;

  static void getCurrentUser() {
    if (auth.currentUser != null) {
      user = auth.currentUser;
    }
  }

  static void forcingAdmin(){
    forceAdmin++;
    print(forceAdmin);
  }

  static bool isAdmin() {
    if (user == kSampleMail) {
      return false;
    } else if (user != null && user.email == kAdminMail || forceAdmin >= 5) {
      return true;
    } else {
      return false;
    }
  }
  static bool isTjo() {
    if (user != null && user.email == kTjoMail) {
      return true;
    } else {
      return false;
    }
  }

  static Future signIn(String email, String password) async {
    forceAdmin = 0;
    if (email == kSampleMail && password == kSamplePassword) {
      isSample = true;
      user = 'sample';
    // } else if (email == kBeamMail && password == kBeamPassword) {
    //   isSample = false;
    //   user = 'beamtjo';
    } else {
      isSample = false;
      if (!email.contains('@') &&
          !email.contains('@vietjetair.com') &&
          !email.contains('@vietjetair')) {
        email += '@vietjetair.com';
      }
      try {
        await auth.signInWithEmailAndPassword(email: email, password: password);
        if (auth.currentUser != null) {
          user = auth.currentUser;
        }
      } catch (e) {}
    }
  }

  static Future logOut() async {
    forceAdmin = 0;
    await auth.signOut();
    user = null;
  }
}

// class SecureStorage {
//   final storage = FlutterSecureStorage();
//
//   //Save Credentials
//   Future saveCredentials(AccessToken token, String refreshToken) async {
//     print(token.expiry.toIso8601String());
//     await storage.write(key: "type", value: token.type);
//     await storage.write(key: "data", value: token.data);
//     await storage.write(key: "expiry", value: token.expiry.toString());
//     await storage.write(key: "refreshToken", value: refreshToken);
//   }
//
//   //Get Saved Credentials
//   Future<Map<String, dynamic>?> getCredentials() async {
//     var result = await storage.readAll();
//     if (result.isEmpty) return null;
//     return result;
//   }
//
//   //Clear Saved Credentials
//   Future clear() {
//     return storage.deleteAll();
//   }
// }
