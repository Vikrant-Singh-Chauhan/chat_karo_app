import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseMethod {
  Future addUser(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("User")
        .doc(id)
        .set(userInfoMap);
  }

  Future addMessage(String chatRoomId, String massageId,
      Map<String, dynamic> massageInfoMap) async {
    return await FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatRoomId)
        .collection("chats")
        .doc(massageId)
        .set(massageInfoMap);
  }

  // Future addMessage(String chatRoomId, String messageId,
  //     Map<String, dynamic> messageInfoMap) async {
  //   return await FirebaseFirestore.instance
  //       .collection("chatRooms")
  //       .doc(chatRoomId)
  //       .collection("chats")
  //       .doc(messageId)
  //       .set(messageInfoMap);
  // }

  Future updateLastMessageSend(
      String chatroomId, Map<String, dynamic> lastMassageInfo) async {
    return await FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatroomId)
        .update(lastMassageInfo);
  }

  Future<QuerySnapshot> Search(String username) async {
    return FirebaseFirestore.instance
        .collection("User")
        .where("SearchKey", isEqualTo: username.substring(0, 1).toUpperCase())
        .get();
  }

  creatChatRoom(String chatRoomId, Map<String, dynamic> chatroomInfoMap) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatRoomId)
        .get();
    if (snapshot.exists) {
      return true;
    } else {
      return FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(chatRoomId)
          .set(chatroomInfoMap);
    }
  }

  Future<Stream<QuerySnapshot>> getChatRoomMessage(chatRoomId) async {
    return await FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("ts", descending: true)
        .snapshots();
  }
}
