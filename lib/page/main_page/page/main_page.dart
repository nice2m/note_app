import 'package:flutter/material.dart';
import 'package:note/app_define/dialog/delete_dialog.dart';
import 'package:note/app_define/dialog/logout_dialog.dart';
import 'package:note/app_define/route/route_define.dart';
import 'package:note/app_define/services/auth/auth_services.dart';
import 'package:note/app_define/services/curd/notes_service.dart';
import 'package:note/app_define/ui/ui_define.dart';
import 'package:note/page/main_page/component/note_list_view.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

enum MenuAction {
  logout;
}

class _MainPageState extends State<MainPage> {
  late final NoteService _noteService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _noteService = NoteService();
    _noteService.open();

    super.initState();
  }

  @override
  void dispose() {
    _noteService.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: UI.primaryColor,
          title: Text(
            "Note",
            style: UI.textTitle.copyWith(color: Colors.white),
          ),
          actions: [
            IconButton(onPressed: _newNote, icon: const Icon(Icons.add)),
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
        body: FutureBuilder(
          future: _noteService.getOrCreateUser(email: userEmail),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return StreamBuilder(
                    initialData: _noteService.allNotesRaw,
                    stream: _noteService.allNotes,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.active:
                          if (snapshot.hasData) {
                            List<DatabaseNote> list = snapshot.data ?? [];
                            return NoteListView(
                              list: list,
                              onDelete: (note) async {
                                final shouldDelete = await showDeleteDialog(context);
                                if (shouldDelete) {
                                  _onDeleteNote(note);
                                }
                              }, onTap: (DatabaseNote note) { 
                                _noteOnTap(note);
                               },
                            );
                          } else {
                            return const CircularProgressIndicator();
                          }
                        default:
                          return Text(
                            "All you notes will be display here",
                            style: UI.textNormal,
                          );
                      }
                    });
              default:
                return const CircularProgressIndicator();
            }
          },
        ));
  }


  _noteOnTap(note) {
    Navigator.of(context).pushNamed(newNoteRoute,arguments: note);
  }

  _onDeleteNote(DatabaseNote note) async {
    await _noteService.deleteNote(noteId: note.id);
  }

  _showLogoutDialog() {
    showLogoutDialog(context).then((value) {
      if (value == true) {
        AuthService.firebase().logout().then((_) => Navigator.of(context)
            .pushNamedAndRemoveUntil('/login/', (_) => false));
      }
    });
  }

  _newNote() {
    Navigator.of(context).pushNamed(newNoteRoute);
  }
}
