import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:random_string/random_string.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../sevices/database.dart';
import '../sevices/share_prefer.dart';


class ChatPage extends StatefulWidget {
  String ? name,profileUrl,username;


  ChatPage({ required this.name,required this.profileUrl,required this.username, });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream ? messageStream;
  String? myUserName , myName , myEmail , myPicture , chatRoom,messageId;
  bool isRecording = false;
  String ? _filePath;
  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  TextEditingController messageController = TextEditingController();
  getTheSharedprefer() async{
    myUserName = await SharePreferHelper().getUserDisplayName();
    myName = await SharePreferHelper().getUserDisplayName();
    myEmail = await SharePreferHelper().getUserEmail();
    myPicture = await SharePreferHelper().getUserImage();
    chatRoom = await getChatRoomIdByUsername(widget.username!,myUserName!);
    setState(() {
    });
  }
  // Future<void> _initialize()async{
  //   await _recorder.openRecorder();
  //   await _requestPeemissin();
  //   var tempDir = await getTemporaryDirectory();
  //   _filePath = "${tempDir.path}/audio.aac";
  // }

  // Future<void>_requestPeemissin()async{
  //     var status = await Permission.microphone.status;
  //     if(!status.isGranted){
  //       await Permission.microphone.request();
  //     }
  // }
  // Future<void> _startRecording()async {
  //   await _recorder.startRecorder(toFile: _filePath);
  //   setState(() {
  //     isRecording = true;
  //     Navigator.pop(context);
  //     openRecordering();
  //   });
  // }
  //
  // Future<void> _stopRecording()async{
  //   await _recorder.stopRecorder();
  //   setState(() {
  //     isRecording = false;
  //     Navigator.pop(context);
  //     openRecording();
  //   });
  // }
  //
  // Future<void>_uploadFie() async {
  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //     backgroundColor: Colors.redAccent,
  //     content: Text("your Audio is uploading please Wait...",
  //     style: TextStyle(
  //       fontSize: 20,
  //     ),),
  //   ));
  //   File file = File(_filePath!);
  //   try{
  //     TaskSnapshot snapshot = await FirebaseFirestore.instance.ref("upload/audio.aac").put
  //   }
  // }

  onTheLoad()async{
    await getTheSharedprefer();
    await getAndSetMessage();
    setState(() {
    });
  }
  @override
  void initState() {
    onTheLoad();
    super.initState();
  }
  getAndSetMessage() async {
    messageStream = await DatabaseMethod().getChatRoomMessage(chatRoom);
    setState(() {});
  }

  getChatRoomIdByUsername(String a , String b){
    if(a.substring(0,1).codeUnitAt(0) > b.substring(0,1).codeUnitAt(0)){
      return "$a\$b";
    }else{
      return "$b\$a";
    }
  }
  addMessage(bool sentClicked){
    if (messageController.text.trim() != "") {
      String message = messageController.text.trim();
      messageController.text = "";
      DateTime now = DateTime.now();
      String formatedDate = DateFormat("h:mma").format(now);
      Map<String, dynamic>messageInfoMap =  {
        "message":message,
        "sentBy":myUserName,
        "ts": FieldValue.serverTimestamp(),
        "ImageUrl":myPicture
      };
      messageId = randomAlphaNumeric(10);
      DatabaseMethod().addMessage(chatRoom!, messageId!, messageInfoMap).then((value) async {
        Map<String,dynamic>lastMassageInfoMap = {
          "lastMassage":message,
          "lastMessageSentTs":formatedDate,
          "time":FieldValue.serverTimestamp(),
          "lastMassageSentBy":myUserName
        };
        await DatabaseMethod().updateLastMessageSend(chatRoom!, lastMassageInfoMap);
        if(sentClicked){
          message = "";
        }
      });
    }
  }
  Widget chatMessageByMe(String message,bool sentByMe){
    return Row(mainAxisAlignment: sentByMe ? MainAxisAlignment.end:MainAxisAlignment.start,
      children: [
        Flexible(child: Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.symmetric(horizontal: 16,vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              bottomRight:sentByMe ? Radius.circular(0):Radius.circular(30),
              bottomLeft: sentByMe ? Radius.circular(30):Radius.circular(0),
              topRight: Radius.circular(30),
            ),
            color: sentByMe ?Colors.blue:Colors.greenAccent,
          ),
          child: sentByMe ? Text(
            message,
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ):Text(
            message,
            style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
        ))
      ],
    );
  }
  Widget chatMessage(){
    return StreamBuilder(
        stream: messageStream,
        builder: ( context,AsyncSnapshot snapshot){
          return snapshot.hasData? ListView.builder(
              itemCount: snapshot.data!.docs.length,
              reverse: true,
              itemBuilder: (context,index){
                DocumentSnapshot ds = snapshot.data.docs[index];
                return chatMessageByMe(ds["message"], myUserName == ds['sentBy']);
              }):Center(child: Container(child: Text("No chat fund here"),));
        });
  }
/*  void addMessage(bool sentClicked) {
    if (messageController.text.trim() != "") {
      String message = messageController.text.trim();
      messageController.text = "";
      DateTime now = DateTime.now();
      String formattedDate = DateFormat("h:mma").format(now);

      Map<String, dynamic> messageInfoMap = {
        "message": message,
        "sentBy": myUserName,
        "ts": FieldValue.serverTimestamp(),
        "imageUrl": myPicture
      };

      String messageId = randomAlphaNumeric(10);

      DatabaseMethod().addMessage(chatRoom!, messageId, messageInfoMap).then((value) async {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageSentTs": formattedDate,
          "time": FieldValue.serverTimestamp(),
          "lastMessageSentBy": myUserName
        };

        await DatabaseMethod().updateLastMessageSend(chatRoom!, lastMessageInfoMap);

        if (sentClicked) {
          message = "";
        }
      });
    }
  }*/


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.name!,
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red[100],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                Container(
                    height: MediaQuery.of(context).size.height /1.22,
                    child: chatMessage()),
                Container(
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.red[100],
                        ),
                        padding: EdgeInsets.all(5),
                        child: Icon(
                          Icons.mic_none,
                          size: 30,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Container(
                            padding: EdgeInsets.only(left: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.blue[50],                          ),
                            child: TextField(
                              controller: messageController,
                              decoration: InputDecoration(
                                  hintText: "Write a massage...",
                                  border: InputBorder.none,
                                  suffixIcon: Icon(Icons.attach_file_rounded)
                              ),
                            )
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: ()=> addMessage(true),
                        child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.red[100],
                            ),
                            padding: EdgeInsets.all(5),
                            child: Icon(Icons.send_rounded)
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
