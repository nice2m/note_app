import 'package:flutter/material.dart';
import 'package:note/app_define/dialog/generic_dialog.dart';

Future<bool> showLogoutDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context, 
    title: 'Log out', 
    content: 'Sure to logout?', 
    optionsBuilder: () => {
    'OK' : true,
    'Cancel' : false
  }).then((value) => value ?? false);
}