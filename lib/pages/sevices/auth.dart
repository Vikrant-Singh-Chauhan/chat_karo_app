import 'package:chatkaro/pages/sevices/share_prefer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../home/home.dart';
import 'database.dart';

class AuthMethod {
  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentUser() async {
    return await auth.currentUser;
  }

  sininWithGoogle(BuildContext context) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
    await googleSignIn.signIn();

    if (googleSignInAccount == null) return;

    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication?.idToken,
        accessToken: googleSignInAuthentication?.accessToken);

    UserCredential result =
    await FirebaseAuth.instance.signInWithCredential(credential);
    User? userDetails = result.user;
    String username  = userDetails!.email!.replaceAll("@gmail.com", "");
    String firstLetter = username.substring(0,1).toUpperCase();
    await SharePreferHelper().saveUserDisplayName(userDetails.displayName!);
    await SharePreferHelper().saveUserEmail(userDetails.email!);
    await SharePreferHelper().saveUserId(userDetails.uid!);
    await SharePreferHelper().saveUserName(username);
    await SharePreferHelper().saveUserImage(userDetails.photoURL!);
    if (result != null) {
      Map<String, dynamic> userInfoMap = {
        "Name": userDetails!.displayName,
        "Email": userDetails!.email,
        "Image": userDetails.photoURL,
        "Id": userDetails.uid,
        "username": username.toUpperCase(),
        "SearchKey": firstLetter
      };
      await DatabaseMethod()
          .addUser(userInfoMap, userDetails!.uid)
          .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              "Registered Successfully",
              style: TextStyle(
                  backgroundColor: CupertinoColors.activeGreen,
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w600),
            )));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home(),));
      });
    }
  }
}
