import 'package:flutter/material.dart';

import '../sevices/auth.dart';

class Onboard extends StatefulWidget {
  const Onboard({super.key});

  @override
  State<Onboard> createState() => _OnboardState();
}

class _OnboardState extends State<Onboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 100,
            ),

            /// onBoarding image///
            Image.asset("images/onBoard.jpg"),
            SizedBox(
              height: 50,
            ),
            Text(
              "Life is  so Small,\nlets talk with your frined ",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 30,
            ),
            ///Google Button ///
            GestureDetector(onTap: (){
              AuthMethod().sininWithGoogle(context);

            },
              child: Container(
                margin: EdgeInsets.only(right: 20, left: 20),
                child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: EdgeInsets.only(top: 8, bottom: 8, left: 10),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(color: Colors.redAccent[100],
                        borderRadius: BorderRadius.circular(30)
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          "images/google_logo.png",
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 20,),
                        Text(
                          "Sign in with Google",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
