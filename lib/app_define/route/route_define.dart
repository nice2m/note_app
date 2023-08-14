
import 'package:flutter/material.dart';
import 'package:note/page/login_page/page/login_page.dart';
import 'package:note/page/main_page/page/main_page.dart';
import 'package:note/page/register_page/page/register_page.dart';
import 'package:note/page/verify_email_page/page/verify_email_page.dart';

 final Map<String, WidgetBuilder>  routesDefine = {
  "/login/": (context) => const LoginPage(),
  "/register/": (context) => const RegisterPage(),
  "/verifyEmail/":(context) => const VerifyEmailPage(),
  "/mainPage/":(context) => const MainPage()
};