import 'package:flutter/material.dart';
import 'package:khat_husseini/utils/my_appbar.dart';
import 'package:khat_husseini/utils/my_button.dart';
import 'package:khat_husseini/utils/my_drawer.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // App bar for start screen
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 60),
        child: MyAppbar(title: "KhatHusseini", icon: Icons.format_paint),
      ),

// Drawer for mobile application, it contains tiles to navigate between different pages
      drawer: MyDrawer(),

      body: Container(
        padding: EdgeInsets.all(20),
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/islamic-art-bg.jpeg"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6), // Adjust the darkness here
              BlendMode.darken,
            ),
          ),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Spiritual Islamic Art Collection",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
      
            SizedBox(height: 20),
      
            Text(
              "Discover beautiful paintings of revered Shia figures including Imam Ali, Imam Hussein, and Sayed Hassan. Each piece is crafted with devotion and spiritual significance.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
      
            SizedBox(height: 20),
      
            MyButton(title: "Get Started", onPressed: (){}),
          ],
        ),
      ),
    );
  }
}
