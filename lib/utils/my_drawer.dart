import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(        
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
              onTap: (){},
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("collections"),
              onTap: (){},
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Contact"),
              onTap: (){},
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Settings"),
              onTap: (){},
            )
          ],
        ),
      );
  }
}