import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UIHelper{
  static CustomTextField(TextEditingController controller,String text,IconData iconData,bool tohide){
    return TextField(
      controller: controller,
      obscureText: tohide,
      decoration: InputDecoration(
        hintText: text,
        suffixIcon: Icon(iconData),
          border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
      )
      )
    );
  }
}