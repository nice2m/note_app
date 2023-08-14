import 'package:flutter/material.dart';
import 'package:note/app_define/route/route_define.dart';
import 'package:note/app_define/services/auth/auth_services.dart';
import 'package:note/app_define/ui/ui_define.dart';
import 'package:note/page/login_page/page/login_page.dart';

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
      ),
      home: const HomePage(),
      routes: routesDefine,
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
    return Scaffold(body: FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context,snapshot){

          // already logined we show main page
          if (AuthService.firebase().currentUser != null) {
            return const LoginPage();
          }

          // not logind we show login page
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return const LoginPage();
            default:
              return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                      children: [
                       const SizedBox(
                        height: 88,
                        width: 88,
                        child: CircularProgressIndicator(),
                        ),
                        const SizedBox(height: 16,),
                        Text("Sync System",style: UI.textNormal,)
                    ]),
                );
          }
    }),);
  }
}