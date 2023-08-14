import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:note/app_define/ui/ui_define.dart';

class ToastUtil {
  static Future<bool?> toast(String message,
      {ToastGravity position = ToastGravity.CENTER,
      Toast toastLength = Toast.LENGTH_LONG}) {
    return Fluttertoast.showToast(
        msg: message, gravity: position, toastLength: toastLength);
  }

  static Future<dynamic> showADialog(
      {required BuildContext context,
      String title = "info",
      String content = "Are you sure?",
      String confirmTitle = "Sure",
      VoidCallback? onConfirm,
      String? cancelTitle,
      VoidCallback? onCancle}) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: Text(
              title,
              style: UI.textTitle,
            ),
          ),
          content: Text(
            content,
            textAlign: TextAlign.center,
            style: UI.textDetail,
          ),
          actions: cancelTitle != null
              ? [
                  Center(
                    child: Row(children: [
                      ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(UI.primaryColor)),
                          onPressed: () {
                            onConfirm != null ? onConfirm() : null;
                          },
                          child: Text(
                            confirmTitle,
                            style: UI.textNormal.copyWith(color: Colors.white),
                          )),
                      const Spacer(),
                      ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(UI.grayColor)),
                          onPressed: () {
                            onCancle != null ? onCancle() : null;
                          },
                          child: Text(
                            cancelTitle,
                            style: UI.textNormal,
                          ))
                    ]),
                  )
                ]
              : [
                  Center(
                    child: ElevatedButton(
                        onPressed: () {
                          onConfirm != null ? onConfirm() : ();
                        },
                        child: Text(
                          confirmTitle,
                          style: UI.textNormal,
                        )),
                  )
                ],
        );
      },
    );
  }
}
