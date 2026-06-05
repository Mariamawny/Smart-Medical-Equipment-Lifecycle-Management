import 'package:ed_app/Screens/dashboard.dart';
import 'package:ed_app/Screens/login.dart';
import 'package:ed_app/Screens/splash.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      

      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => const SplashScreen(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/Login': (context) => const Login(),
        '/Dashboard': (context) => const Dashboard(),
        
      },
    );
  }
}
