import 'dart:convert';
import 'dart:developer';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../../model/feedback_model.dart';
import '../../../core/cache/cache.dart';

class ApiService {
  // static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // static final FirebaseAuth _auth = FirebaseAuth.instance;
  final String baseUrl = "https://postgres-api-hrd8.onrender.com";

  // static Future<List> checkMapLockStatus() async {
  //   final response = await http.get(Uri.parse('$baseUrl/enable_map'));

  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     return [data['isEnabled'], data['message']];
  //   } else {
  //     return [false, "Error fetching map lock status"];
  //   }
  // }

  Future<void> storeUserData(Map<String, dynamic> userData) async {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to store user data: ${response.body}');
      }
    }


    Future<void> storeMedicalAidData({
      required String medicalaidname,
      required String medicalaidnumber,
      required String medicalaidid,
      required String userId,
    }) async {
      final Map<String, dynamic> medicalAidData = {
        'userId': userId,
        'medicalaidname': medicalaidname,
        'medicalaidnumber': medicalaidnumber,
        'medicalaidid': medicalaidid,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/medicalaid'), // your API endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(medicalAidData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Medical aid data stored successfully");
      } else {
        throw Exception(
            'Failed to store medical aid data: ${response.statusCode} ${response.body}');
      }
    }


  //! REGISTER
  Future<void> register({
    required String name,
    required String surname,
    required String contactInfo,
    required String email,
    required String password,
    required String id_passportnumber,
    required String gender,
    required String dob,
    required String nationality,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
        'surname': surname,
        'phone': contactInfo,
        'id_passportnumber': id_passportnumber,
        'gender': gender,
        'dob': dob,
        'nationality': nationality,
      }),
    );

    if (response.statusCode == 200) {
      print("User registered successfully");
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  // Future<void> renameDocument() async {
  //   final Map<String, dynamic> userData = CacheData.getMapData(key: "userData");
  //   final firestore = FirebaseFirestore.instance;

  //   final userDocRef = firestore.collection('users').doc(userData['uid']);
  //   final originalDocSnapshot = await userDocRef.get();
  //   final data = originalDocSnapshot.data();

  //   if (data != null) {
  //     final newDocRef = firestore.collection('users').doc('account_deprecated');
  //     await newDocRef.set(data);
  //     await userDocRef.delete();

  //     log('Document renamed successfully!');
  //   } else {
  //     log('Original document not found.');
  //   }
  // }

//! LOGIN
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(response.body);
      // Save token locally for future requests
      await CacheData.setData(key: 'authToken', value: data['access_token']);
      await CacheData.setMapData(key: 'userData', value: data['user']);
      return data;
    } else {
      print(response.body);
      throw Exception('Login failed: ${response.body}');
    }
  }

  // Offline mode fallback
  static Future<void> _enableOfflineMode(String email) async {
    try {
      // Store offline user data
      await CacheData.setMapData(key: "userData", value: {
        "name": "Offline User",
        "email": email,
        "uid": "offline_${email.hashCode}",
        "emailVerified": true,
        "offline": true
      });
      log("Offline mode enabled for $email");
    } catch (e) {
      log('Offline mode setup failed: $e');
    }
  }

  //! RESET PASSWORD
  Future<void> resetPassword({required String email}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      print("Password reset email sent");
    } else {
      throw Exception('Failed to send password reset email: ${response.body}');
    }
  }

  //! LOG OUT
  static Future<void> logOut() async {
    // Clear locally stored token
    await CacheData.setData(key: "authToken", value: null);
    print("Logged out successfully");
  }


  //! EMAIL VERIFY
  Future<void> emailVerify({required String email}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/send-verification-email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      print("Verification email sent");
    } else {
      throw Exception('Failed to send verification email: ${response.body}');
    }
  }

  //! DELETE USER
  // static Future<void> deleteUser(
  //     {required String email, required String password}) async {
  //   final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  //   final User? user = firebaseAuth.currentUser;
  //   if (user != null) {
  //     try {
  //       AuthCredential credential = EmailAuthProvider.credential(
  //         email: email,
  //         password: password,
  //       );

  //       await user.reauthenticateWithCredential(credential);
  //       await user.delete();
  //       log('User account deleted successfully.');
  //     } catch (e) {
  //       log('An error occurred while deleting the user account: $e');
  //     }
  //   } else {
  //     log('No user is currently signed in.');
  //   }
  // }

//! CHANGE EMAIL
  Future<void> changeEmail({
    required String userId,
    required String newEmail,
    required String currentPassword,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId/email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'newEmail': newEmail,
        'password': currentPassword,
      }),
    );

    if (response.statusCode == 200) {
      print("Email updated successfully");
    } else {
      throw Exception('Failed to change email: ${response.body}');
    }
  }


//! CHANGE EMAIL WITH REAUTH
  // static Future<void> updateEmailWithReauth(
  //     {required String newEmail, required String password}) async {
  //   try {
  //     User? user = FirebaseAuth.instance.currentUser;

  //     if (user != null) {
  //       AuthCredential credential = EmailAuthProvider.credential(
  //           email: user.email!, password: password);
  //       await user.reauthenticateWithCredential(credential);

  //       await user.verifyBeforeUpdateEmail(newEmail);
  //       log("Email updated successfully to $newEmail");
  //     } else {
  //       log("User not signed in.");
  //     }
  //   } catch (e) {
  //     log("Error updating email: $e]");
  //   }
  // }

  // static Future<void> updateUserImage({String? urlImage}) async {
  //   await FirebaseAuth.instance.currentUser!.updatePhotoURL(urlImage);
  //   log(FirebaseAuth.instance.currentUser!.photoURL.toString());
  // }

  // static Future<void> updateUserDisplayName({String? name}) async {
  //   await FirebaseAuth.instance.currentUser!.updateDisplayName(name);
  //   log(FirebaseAuth.instance.currentUser!.displayName.toString());
  // }

  Future<bool> submitFeedback(Map<String, dynamic> feedback) async {
    final response = await http.post(
      Uri.parse('$baseUrl/feedback'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(feedback),
    );

    return response.statusCode == 200;
  }


  // Test mode functionality for development
  static Future<void> setTestMode() async {
    await CacheData.setData(key: "test_mode", value: true);
    await CacheData.setMapData(key: "userData", value: {
      "name": "Test User",
      "email": "test@demo.com",
      "uid": "test_user_123",
      "emailVerified": true
    });
    log("Test mode enabled");
  }

  static bool isTestMode() {
    return CacheData.getdata(key: "test_mode") ?? false;
  }
}
