import 'package:flutter/material.dart';
import 'package:note/app_define/dialog/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context, 
    title: 'Delete', 
    content: 'Sure to delete the note?', 
    optionsBuilder: () => {
    'OK' : true,
    'Cancel' : false
  }).then((value) => value ?? false);
}