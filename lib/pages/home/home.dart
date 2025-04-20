import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../chat_page/chat_page.dart';
import '../sevices/database.dart';
import '../sevices/share_prefer.dart';
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? myUserName, myName, myEmail, myPicture;
  TextEditingController searchController = TextEditingController();

  getTheSharedprefer() async {
    myUserName = await SharePreferHelper().getUserDisplayName();
    myName = await SharePreferHelper().getUserDisplayName();
    myEmail = await SharePreferHelper().getUserEmail();
    myPicture = await SharePreferHelper().getUserImage();
    setState(() {});
  }

  getChatRoomIdByUsername(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$a\$b";
    } else {
      return "$b\$a";
    }
  }

  bool search = false;
  var queryResultSet = [];
  var tempSearchStore = [];

  initiateSearch(String value) {
    if (value.isEmpty) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
        search = false;
      });
      return;
    }

    String capitalizedValue = value.substring(0, 1).toUpperCase() +
        value.substring(1);

    if (queryResultSet.isEmpty && value.length == 1) {
      DatabaseMethod().Search(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.docs.length; ++i) {
          queryResultSet.add(docs.docs[i].data());
        }
        setState(() {
          search = true;
        });
      });
    } else {
      tempSearchStore = [];
      queryResultSet.forEach((element) {
        if (element['username'].startsWith(capitalizedValue)) {
          setState(() {
            tempSearchStore.add(element);
          });
        }
      });
    }
  }
  @override
  void initState() {
    getTheSharedprefer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.redAccent[100],
      body: Container(
        margin: EdgeInsets.only(top: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  Image.asset(
                    "images/wawe.png",
                    height: 50,
                    width: 50,
                  ),
                  Text("hello, ",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  Text(
                    "Vikrant",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Container(
                    margin: EdgeInsets.only(right: 20),
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.person, color: Colors.redAccent[100]),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                "Welcome to",
                style: TextStyle(
                    color: Colors.white60,
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                "Lets Chat",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 35,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    color: Colors.white),
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[300],
                          border: Border.all()),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: TextField(
                          controller: searchController,
                          onChanged: (value) {
                            initiateSearch(value.toUpperCase());
                          },
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.search),
                              hintText: "Search Username"),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    search
                        ? ListView(
                      primary: false,
                      shrinkWrap: true,
                      children: tempSearchStore.map<Widget>((element) {
                        return buildResulCard(element);
                      }).toList(),
                    )
                        : Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: CircleAvatar(
                            foregroundImage: AssetImage("images/photo.jpeg"),
                            radius: 30,
                            backgroundColor: Colors.green,
                          ),
                          title: Text(
                            "Vikrant",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "where are you going today",
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: 15,
                                fontWeight: FontWeight.w400),
                          ),
                          trailing: Column(
                            children: [
                              Text(
                                "01:30",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                              Icon(Icons.done_all),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildResulCard(data) {
    return GestureDetector(
      onTap: () async {
        search = false;
        var chatRoomId = getChatRoomIdByUsername(
            myUserName!, data["username"]!);
        Map<String, dynamic>chatInfoMap = {
          "users": [myUserName, data["username"]]
        };
        await DatabaseMethod().creatChatRoom(chatRoomId, chatInfoMap);
        Navigator.push(context, MaterialPageRoute(builder: (context) =>
            ChatPage(name: data["Name"],
              profileUrl: data["Image"],
              username: data["username"],
            ),));
      },
      child: Card(
        color: Colors.red[200],
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 5),
        child: ListTile(
          leading: ClipRRect(borderRadius: BorderRadius.circular(100),
              child: Image.network(data["Image"] ,fit: BoxFit.cover,)),
          title: Text(
            data["username"],
            style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          subtitle: Text("Tap to start chat"),
          trailing: Column(
            children: [
              Text(
                "01:30",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
              Icon(Icons.done_all),
            ],
          ),
        ),
      ),
    );
  }
}
