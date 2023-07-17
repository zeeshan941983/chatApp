import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import '../../model/message.dart';

class ChatService extends ChangeNotifier {
  ////get instance of auth and firebase
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference ref = FirebaseFirestore.instance.collection('chat_rooms');
  ////send message
  Future<void> sendMessage(String reciveId, String message) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    ///create new message
    Message newmessage = Message(
        read: 'send',
        image: '',
        senderId: currentUserId,
        senderEmail: currentUserEmail,
        receiverId: reciveId,
        message: message,
        timestamp: timestamp);

    ///construct chat room id from current user id and reciver id(soeted to ensure uniquness)
    List<String> ids = [currentUserId, reciveId];
    ids.sort(); //sort the ids(this is ensure the chat room id is always the same for any pair)
    String chatRoomId =
        ids.join('_'); //comine ids into single to use as chatroomID

    /// add new message to database
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newmessage.toMap());
  }

  //get message
  Stream<QuerySnapshot> getMessages(String userId, String otherUserID) {
    List<String> ids = [userId, otherUserID];
    ids.sort();
    String chatRoomId = ids.join('_');
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> sendimage(String reciveId, String imageurl) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    ///create new message
    Message newmessage = Message(
        read: 'send',
        image: imageurl,
        senderId: currentUserId,
        senderEmail: currentUserEmail,
        receiverId: reciveId,
        timestamp: timestamp);

    ///construct chat room id from current user id and reciver id(soeted to ensure uniquness)
    List<String> ids = [currentUserId, reciveId];
    ids.sort(); //sort the ids(this is ensure the chat room id is always the same for any pair)
    String chatRoomId =
        ids.join('_'); //comine ids into single to use as chatroomID

    /// add new message to database
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newmessage.toMap());
  }

  Stream<QuerySnapshot> getimage(String userId, String otherUserID) {
    List<String> ids = [userId, otherUserID];
    ids.sort();
    String chatRoomId = ids.join('_');
    return _firestore
        .collection('chat_images')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
