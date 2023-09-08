import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/home_screen.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  Stream<User?> get userStream => _auth.authStateChanges();


  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print(result);
      _user = result.user;
      print(_user);
      notifyListeners();
      if (_user != null) {


        Navigator.of(_scaffoldContext!).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (e) {
      // Handle login errors and show an error message.
      final errorMessage = _handleAuthError(e);
      ScaffoldMessenger.of(_scaffoldContext!).showSnackBar(
        SnackBar(
          margin: EdgeInsets.all(10),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          closeIconColor: Colors.white,
          showCloseIcon: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Text(errorMessage),
        ),
      );
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }


  // Handle Firebase Auth exceptions and return an error message.
  String _handleAuthError(dynamic e) {
    String errorMessage = 'An error occurred.';

    if (e is FirebaseAuthException) {
      switch (e.code) {
        default:
          errorMessage = 'Authentication failed. Please try again later.';
      }
    }

    return errorMessage;
  }

  // Store the context for showing SnackBars.
  BuildContext? _scaffoldContext;

  void setScaffoldContext(BuildContext context) {
    _scaffoldContext = context;
  }
}
