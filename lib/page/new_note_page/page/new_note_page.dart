import 'package:flutter/material.dart';
import 'package:note/app_define/services/auth/auth_services.dart';
import 'package:note/app_define/services/curd/notes_service.dart';
import 'package:note/app_define/ui/ui_define.dart';
import 'package:note/utilities/generics/get_arguments.dart';

class NewNotePage extends StatefulWidget {
  const NewNotePage({super.key});

  @override
  State<NewNotePage> createState() => _NewNotePageState();
}

class _NewNotePageState extends State<NewNotePage> {
  DatabaseNote? _note;
  late final TextEditingController _textController;
  late final NoteService _noteService;

  Future<DatabaseNote>createOrGetExistingNote() async {
    final widgetNote = context.getArgument<DatabaseNote>();
    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final email = AuthService.firebase().currentUser!.email!;
    final user = await _noteService.getOrCreateUser(email: email);
    
    _note = await _noteService.createNote(owner: user, text: '');
    return _note!;
  }

  _textEditing() {
    final text = _textController.text;
    final previousNote = _note;
    if (previousNote != null){
      _note = DatabaseNote(id: previousNote.id, userId: previousNote.userId, text: text, isSyncWithCloud: false);
    }
  }

  _delNoteIfTextEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (note != null && text.isEmpty){
        await _noteService.deleteNote(noteId: note.id);
    }
  }
  _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (note != null && text.isNotEmpty){
        await _noteService.updateNote(note: note, text: note.text);
    }
  }

  @override
  void initState(){
    _textController = TextEditingController();
    _noteService = NoteService();
    _setupTextControllerListenner();

    super.initState();
  }

  @override
  void dispose() {
    _delNoteIfTextEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();

    super.dispose();
  }

  void _setupTextControllerListenner() {
    _textController.removeListener(_textEditing);
    _textController.addListener(_textEditing);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text('New note',style: UI.textTitle.copyWith(color: Colors.white),),
        backgroundColor: UI.primaryColor,
      ),
      body: FutureBuilder(future: createOrGetExistingNote(),
      builder:(context, snapshot){
        return TextField(
            controller: _textController,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              hintText: 'Start typing your note...',
              contentPadding:  EdgeInsets.all(16),
            ),
          );
      },
        )
    );
  }
}