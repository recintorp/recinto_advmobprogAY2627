import 'dart:convert';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart' as cloud_firestore;
import 'package:flutter/foundation.dart' show debugPrint;
import '../constants.dart';
import '../models/user.dart';

class UserService {
  Map<String, dynamic> data = {};

  Future<Map<String, dynamic>> loginUser(String username, String password) async {
    final response = await post(
      Uri.parse('$host/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'expiresInMins': 60,
      }),
    );

    if (response.statusCode == 200) {
      data = jsonDecode(response.body);
      await saveUserData(data);
      return data;
    } else {
      throw Exception(response.body);
    }
  }

  /// **Save User Data to SharedPreferences**
  /// Save user data from API response based on User model
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    final user = User.fromJson(userData);

    await prefs.setInt('id', user.id);
    await prefs.setString('username', user.username);
    await prefs.setString('email', user.email);
    await prefs.setString('firstName', user.firstName);
    await prefs.setString('lastName', user.lastName);
    await prefs.setString('gender', user.gender);
    await prefs.setString('image', user.image);
    await prefs.setString('accessToken', user.accessToken);
    await prefs.setString('refreshToken', user.refreshToken);
    await prefs.setString('loginType', 'dummy');

    // Support generic token key if present in API response
    if (userData.containsKey('token')) {
      await prefs.setString('token', userData['token'] ?? '');
    } else if (user.accessToken.isNotEmpty) {
      await prefs.setString('token', user.accessToken);
    }
  }

  /// Retrieve user data from SharedPreferences
  Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final loginType = prefs.getString('loginType') ?? 'dummy';

    if (loginType == 'firebase') {
      return {
        'id': 0,
        'username': prefs.getString('username') ?? '',
        'email': prefs.getString('email') ?? '',
        'firstName': prefs.getString('firstName') ?? '',
        'lastName': prefs.getString('lastName') ?? '',
        'gender': '',
        'image': '',
        'accessToken': '',
        'refreshToken': '',
        'token': '',
        'age': prefs.getInt('age') ?? 0,
        'contactNo': prefs.getString('contactNo') ?? '',
        'loginType': 'firebase',
      };
    }

    return {
      'id': prefs.getInt('id') ?? 0,
      'username': prefs.getString('username') ?? '',
      'email': prefs.getString('email') ?? '',
      'firstName': prefs.getString('firstName') ?? '',
      'lastName': prefs.getString('lastName') ?? '',
      'gender': prefs.getString('gender') ?? '',
      'image': prefs.getString('image') ?? '',
      'accessToken': prefs.getString('accessToken') ?? '',
      'refreshToken': prefs.getString('refreshToken') ?? '',
      'token': prefs.getString('token') ?? prefs.getString('accessToken') ?? '',
      'age': 0,
      'contactNo': '',
      'loginType': 'dummy',
    };
  }

  /// Retrieve User model from SharedPreferences
  Future<User> getUser() async {
    final userData = await getUserData();
    return User.fromJson(userData);
  }

  /// **Check if User is Logged In**
  Future<bool> isLoggedIn() async {
    if (firebaseAuth.currentUser != null) return true;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? prefs.getString('token');
    return token != null && token.isNotEmpty;
  }

  /// **Logout and Clear User Data**
  /// Clears the active session, but keeps each Firebase account's own
  /// profile fields (age, contact number) cached under a UID-scoped key
  /// (see `profile_age_<uid>` / `profile_contactNo_<uid>`) so they aren't
  /// permanently lost the next time that same account signs back in --
  /// Firebase Authentication itself has no field for either value.
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keysToKeep = prefs.getKeys().where((k) => k.startsWith('profile_'));
      final kept = <String, Object?>{
        for (final k in keysToKeep) k: prefs.get(k),
      };

      await prefs.clear();

      for (final entry in kept.entries) {
        final value = entry.value;
        if (value is int) {
          await prefs.setInt(entry.key, value);
        } else if (value is String) {
          await prefs.setString(entry.key, value);
        }
      }
    } catch (e) {
      throw Exception('Failed to log out: $e');
    }
  }

  final firebase_auth.FirebaseAuth firebaseAuth = firebase_auth.FirebaseAuth.instance;

  // NEW (Lab Activity 6): Firestore instance used to save users for the chat list.
  final cloud_firestore.FirebaseFirestore _db =
      cloud_firestore.FirebaseFirestore.instance;

  firebase_auth.User? get currentUser => firebaseAuth.currentUser;

  Stream<firebase_auth.User?> get authStateChanges => firebaseAuth.authStateChanges();

  /// NEW (Lab Activity 6): Saves (or updates) this account in the Firestore
  /// "Users" collection. The document ID is the Firebase Auth UID, so each
  /// account has exactly one document. If [onlyIfMissing] is true, an
  /// existing document is left untouched.
  Future<void> _saveUserToFirestore({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    required String username,
    bool onlyIfMissing = false,
  }) async {
    try {
      final doc = _db.collection('Users').doc(uid);
      if (onlyIfMissing && (await doc.get()).exists) return;

      await doc.set({
        'uid': uid,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
      }, cloud_firestore.SetOptions(merge: true));
    } catch (e) {
      // Don't block login/sign-up if Firestore has a problem.
      debugPrint('Failed to save user to Firestore: $e');
    }
  }

  Future<firebase_auth.UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final prefs = await SharedPreferences.getInstance();
    final uid = credential.user?.uid ?? '';

    await prefs.setString('loginType', 'firebase');
    await prefs.setString('email', email);
    if (!prefs.containsKey('username')) {
      await prefs.setString('username', email.split('@').first);
    }
    final name = credential.user?.displayName ?? '';
    final parts = name.split(' ');
    await prefs.setString('firstName', parts.isNotEmpty ? parts.first : '');
    await prefs.setString('lastName', parts.length > 1 ? parts.sublist(1).join(' ') : '');

    // Restore this account's own age/contact number from the UID-scoped
    // cache, since Firebase Auth never stored them in the first place.
    if (uid.isNotEmpty) {
      final cachedAge = prefs.getInt('profile_age_$uid');
      final cachedContactNo = prefs.getString('profile_contactNo_$uid');
      await prefs.setInt('age', cachedAge ?? 0);
      await prefs.setString('contactNo', cachedContactNo ?? '');
    }

    // NEW: make sure accounts created before this lab also exist in Firestore.
    if (uid.isNotEmpty) {
      final username = prefs.getString('username') ?? email.split('@').first;
      final firstName = prefs.getString('firstName') ?? '';
      await _saveUserToFirestore(
        uid: uid,
        email: email,
        firstName: firstName.isNotEmpty ? firstName : username,
        lastName: prefs.getString('lastName') ?? '',
        username: username,
        onlyIfMissing: true,
      );
    }

    return credential;
  }

  Future<firebase_auth.UserCredential> createAccount({
    required String fName,
    required String lName,
    required int age,
    required String contactNo,
    required String username,
    required String email,
    required String password,
  }) async {
    final credential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user?.updateDisplayName('$fName $lName');

    final prefs = await SharedPreferences.getInstance();
    final uid = credential.user?.uid ?? '';

    await prefs.setString('loginType', 'firebase');
    await prefs.setString('firstName', fName);
    await prefs.setString('lastName', lName);
    await prefs.setInt('age', age);
    await prefs.setString('contactNo', contactNo);
    await prefs.setString('username', username);
    await prefs.setString('email', email);

    // Cache age/contactNo by UID -- this is what survives a future
    // sign-out/sign-in cycle for this specific account.
    if (uid.isNotEmpty) {
      await prefs.setInt('profile_age_$uid', age);
      await prefs.setString('profile_contactNo_$uid', contactNo);
    }

    // NEW: also save this account in Firestore so it shows up in the chat list.
    if (uid.isNotEmpty) {
      await _saveUserToFirestore(
        uid: uid,
        email: email,
        firstName: fName,
        lastName: lName,
        username: username,
      );
    }

    return credential;
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
    await logout();
  }

  Future<void> updateUsername({required String username}) async {
    await currentUser!.updateDisplayName(username);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    final uid = currentUser?.uid;

    firebase_auth.AuthCredential credential = firebase_auth.EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.delete();
    await firebaseAuth.signOut();

    // Clean up the cached profile fields for this account too -- there's
    // no reason to keep them around once the account itself is gone.
    if (uid != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('profile_age_$uid');
      await prefs.remove('profile_contactNo_$uid');
    }

    await logout();
  }

  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    firebase_auth.AuthCredential credential = firebase_auth.EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.updatePassword(newPassword);
  }
}