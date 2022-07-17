import 'dart:io';
import 'package:flutter/material.dart';
import 'package:whatsapp/Login.dart';
import 'RouteGenerator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;


final ThemeData temaIOS = ThemeData(
  primaryColor: Colors.grey[200], colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Color(0xff25D366)),
);

final ThemeData temaPadrao = ThemeData(
  primaryColor: Color(0xff075E54),
  colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Color(0xff25D366)),
  //accentColor: Color(0xff25D366),
);

void main() {

  runApp(MaterialApp(
    home: Login(),
    theme: Platform.isIOS ? temaIOS : temaPadrao,
    initialRoute: "/",
    onGenerateRoute: RouteGenerator.generateRoute,
    debugShowCheckedModeBanner: false,
  ));
}
