// import 'package:blog_app/HomePage.dart';
// import 'package:blog_app/LoginRegisterPage.dart';
import 'package:blog_app/Authentication.dart';
import 'package:blog_app/Mapping.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(BlogApp());
}

class BlogApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Blog App",
      theme: ThemeData(
        primarySwatch: Colors.purple,
        useMaterial3: true,
      ),
      // home: LoginRegisterPage(),
      // home: HomePage(),
      home: MappingPage(
        auth: Auth(),
      ),
    );
  }
}
