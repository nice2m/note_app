import 'package:flutter/material.dart';
import 'package:note/app_define/services/auth/auth_exception.dart';
import 'package:note/app_define/services/auth/auth_services.dart';
import 'package:note/app_define/ui/ui_define.dart';
import 'package:note/app_define/ui/ui_toast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController =
      TextEditingController.fromValue(TextEditingValue.empty);
  final TextEditingController _passwordController =
      TextEditingController.fromValue(TextEditingValue.empty);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(
            controller: _userController,
            decoration: InputDecoration(
                labelText: "User",
                hintText: "Please input email",
                fillColor: UI.primaryColor,
                contentPadding: const EdgeInsets.only(left: 8, right: 8)),
          ),
          TextField(
            obscureText: true,
            controller: _passwordController,
            decoration: InputDecoration(
                labelText: "Password",
                hintText: "Please input password",
                fillColor: UI.primaryColor,
                contentPadding: const EdgeInsets.only(left: 8, right: 8)),
          ),
          const SizedBox(
            height: 44,
          ),
          ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(UI.primaryColor)),
              onPressed: _onLogin,
              child: Text("Login",
                  style: UI.textNormal.copyWith(color: Colors.white))),
          TextButton(
              onPressed: _onRegistClick,
              child: Text("Don't have an account?", style: UI.textNormal)),
        ]),
      ),
      appBar: AppBar(
        title: Text("Note", style: UI.textTitle),
      ),
    );
  }

  _onLogin() async {
    final String user = _userController.text.trim();
    final String pwd = _passwordController.text.trim();
    final navigator = Navigator.of(context);

    try {
      await AuthService.firebase().login(email: user, password: pwd);
      final userModel = AuthService.firebase().currentUser;
      if (userModel != null) {
        if (userModel.isEmailVerified == false) {
          navigator.pushNamedAndRemoveUntil("/verifyEmail/", (_) => false);
        } else {
          navigator.pushNamedAndRemoveUntil("/mainPage/", (_) => false);
        }
      }
    } on UserNotFoundAuthException catch (_) {
      ToastUtil.toast("user not found, please check your user name");
    } on WrongPasswordAuthException catch (_) {
      ToastUtil.toast("wrong password!");
    }
  }

  _onRegistClick() {
    Navigator.of(context).pushNamed("/register/");
  }
}
