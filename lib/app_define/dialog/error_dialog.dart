

import 'package:flutter/material.dart';
import 'package:note/app_define/dialog/generic_dialog.dart';


Future<void> showErrorDialog(
  BuildContext context,
  String text,
){
  return showGenericDialog<void>(
    context: context, 
    title: 'An error accored',
     content: text, 
     optionsBuilder: () =>{
      'OK': null,
     });
}