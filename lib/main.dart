import 'package:flutter/material.dart';
import 'package:todo_list/ui/home.dart';


void main(){
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "Todo App",
    home: Home(),
  ));
}