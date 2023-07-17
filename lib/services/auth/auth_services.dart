import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class Authservices extends ChangeNotifier {
  ///instance of firestore
  final FirebaseFirestore _Firestore = FirebaseFirestore.instance;
  //instance of auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

////signin user
  Future<UserCredential> signInWithEmailandPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential;

      ///catch error
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

/////sigup
  Future<UserCredential> SignupwithEmailandPassword(
    String email,
    String password,
    String name,
    String image,
  ) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add a new document for the user in the Users collection
      _Firestore.collection('Users').doc(userCredential.user!.uid).set(
        {
          'name': name,
          'uid': userCredential.user!.uid,
          'Email': email,
          'image': image,
          'isOnline': '',
          // Set the initial value of isOnline to true
        },
      );

      return userCredential;
    } catch (e) {
      throw Exception(e.hashCode);
    }
  }

/////signout
  Future<void> signOut() async {
    return await FirebaseAuth.instance.signOut();
  }
}
