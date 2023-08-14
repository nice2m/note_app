import 'package:flutter/material.dart';
import 'package:note/app_define/services/auth/auth_services.dart';
import 'package:note/app_define/ui/ui_define.dart';
import 'package:note/app_define/ui/ui_toast.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

enum MenuAction {
  logout;
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Note",
          style: UI.textTitle,
        ),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              switch (value) {
                case MenuAction.logout:
                  _showLogoutDialog();
                  break;
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: MenuAction.logout,
                  child: Text(
                    "Logout",
                    style: UI.textTitle,
                  ),
                )
              ];
            },
          )
        ],
      ),
      body: const Center(child: Text("Main Page")),
    );
  }

  _showLogoutDialog() {
    ToastUtil.showADialog(
        context: context,
        title: 'Info',
        content: 'Are you sure to logout?',
        confirmTitle: 'Logout',
        onConfirm: () {
          AuthService.firebase()
              .logout()
              .then((_) => Navigator.of(context).pushNamedAndRemoveUntil('/login/', (_) => false));
        },
        cancelTitle: 'Cancle',
        onCancle: () {
          Navigator.of(context).pop();
        }
        );
  }
}
