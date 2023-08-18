import 'package:flutter/material.dart';
import 'package:note/app_define/route/route_define.dart';
import 'package:note/app_define/services/auth/auth_services.dart';
import 'package:note/app_define/ui/ui_define.dart';
import 'package:note/page/login_page/page/login_page.dart';
import 'package:note/page/main_page/page/main_page.dart';
import 'package:note/page/new_note_page/page/new_note_page.dart';
import 'package:note/page/register_page/page/register_page.dart';
import 'package:note/page/verify_email_page/page/verify_email_page.dart';

void main() {
  runApp(const NoteApp());
}

class NoteApp extends StatelessWidget {
  const NoteApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: UI.primaryColor),
        useMaterial3: true,
        primaryColor: UI.primaryColor,
        
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginPage(),
        registerRoute: (context) => const RegisterPage(),
        mainRoute: (context) => const MainPage(),
        verifyEmailRoute: (context) => const VerifyEmailPage(),
        newNoteRoute: (context) => const NewNotePage()
      },
    ); 
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: AuthService.firebase().initialize(),
          builder: (context, snapshot) {
            // not logind we show login page
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                // already logined we show main page
                if (AuthService.firebase().currentUser != null) {
                  return const MainPage();
                }
                return const LoginPage();
              default:
                return  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Center(
                          child: const SizedBox(
                          height: 88,
                          width: 88,
                          child: CircularProgressIndicator(),
                        )),
                        const SizedBox(
                          height: 16,
                        ),
                        Text(
                          "initializing...",
                          style: UI.textNormal,
                        )
                      ]);
                
            }
          }),
    );
  }
}
