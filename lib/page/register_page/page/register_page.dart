import 'package:flutter/material.dart';
import 'package:note/app_define/debug/dev_tool.dart';
import 'package:note/app_define/services/auth/auth_exception.dart';
import 'package:note/app_define/services/auth/auth_services.dart';
import 'package:note/app_define/ui/ui_define.dart';
import 'package:note/app_define/ui/ui_toast.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _userController =
      TextEditingController.fromValue(TextEditingValue.empty);
  final TextEditingController _passwordController =
      TextEditingController.fromValue(TextEditingValue.empty);
  final TextEditingController _password2Controller =
      TextEditingController.fromValue(TextEditingValue.empty);

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    _password2Controller.dispose();

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
          TextField(
            controller: _password2Controller,
            obscureText: true,
            decoration: InputDecoration(
                labelText: "Password again",
                hintText: "Please re-input password",
                fillColor: UI.primaryColor,
                contentPadding: const EdgeInsets.only(left: 8, right: 8)),
          ),
          const SizedBox(
            height: 44,
          ),
          ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(UI.primaryColor)),
              onPressed: _onRegister,
              child: Text("Register",
                  style: UI.textNormal.copyWith(color: Colors.white)))
        ]),
      ),
      appBar: AppBar(
        title: Text("Note", style: UI.textTitle),
      ),
    );
  }

  _onRegister() async {
    DevTool.log("message");
    final String user = _userController.text.trim();
    final String pwd = _passwordController.text.trim();
    final String pwd2 = _password2Controller.text.trim();

    if (pwd != pwd2) {
      ToastUtil.toast("the passwords arent' the same");
      return;
    }

    try {
      AuthService.firebase().createUser(email: user, password: pwd);
    } on InvalidEmailAuthException catch (_) {
      ToastUtil.toast("invalid email,check your email!");
    } on WeakPasswordAuthException catch (_) {
      ToastUtil.toast("weak password,check your password!");
    } on EmailAlreadyInUseAuthException catch (_) {
      ToastUtil.toast("invalid email,check your email!");
    }
  }
}
