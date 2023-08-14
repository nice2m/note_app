import 'package:flutter/material.dart';
import 'package:note/app_define/services/auth/auth_exception.dart';
import 'package:note/app_define/services/auth/auth_services.dart';
import 'package:note/app_define/ui/ui_define.dart';
import 'package:note/app_define/ui/ui_toast.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Verify Email",
          style: UI.textTitle,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Your email is NOT verified yet,\nPlease click button bellow to get sent an email binding entrance!",
              style: UI.textDetail.copyWith(color: Colors.black),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
          ),
          const SizedBox(
            height: 44,
          ),
          ElevatedButton(
              style: ButtonStyle(
                  padding: const MaterialStatePropertyAll(
                      EdgeInsets.symmetric(vertical: 12, horizontal: 44)),
                  backgroundColor: MaterialStatePropertyAll(UI.primaryColor)),
              onPressed: _onSendVerifyEmail,
              child: Text(
                "Send verify email",
                style: UI.textTitle.copyWith(color: Colors.white),
              )),
          const SizedBox(
            height: 16,
          ),
          ElevatedButton(
              style: ButtonStyle(
                  padding: const MaterialStatePropertyAll(
                      EdgeInsets.symmetric(vertical: 12, horizontal: 44)),
                  backgroundColor: MaterialStatePropertyAll(UI.primaryColor)),
              onPressed: _onRestart,
              child: Text(
                "Restart",
                style: UI.textTitle.copyWith(color: Colors.white),
              ))
        ],
      ),
    );
  }

  _onRestart() {
    Navigator.of(context).pushNamedAndRemoveUntil("/login/", (_) => false);
  }

  _onSendVerifyEmail() async {
    final user = AuthService.firebase().currentUser;
    try {
      if (user != null) {
        await AuthService.firebase().sendEmailVerification();
      } else {
        ToastUtil.toast("user not logined yet!");
      }
    } on UserNotLoginedAuthException catch (_) {
      ToastUtil.toast("user not logined yet!");
    } on GenericAuthException catch (_) {
      ToastUtil.toast("Auth error!");
    }
  }
}
