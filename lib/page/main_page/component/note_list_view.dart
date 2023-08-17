import 'package:flutter/material.dart';
import 'package:note/app_define/services/curd/notes_service.dart';

typedef NoteCallBack = void Function(DatabaseNote note);

class NoteListView extends StatelessWidget {
  final List<DatabaseNote> list;
  final NoteCallBack onDelete;
  final NoteCallBack onTap;

  const NoteListView({
    super.key, 
    required this.list, 
    required this.onDelete, 
    required this.onTap
    });

  @override
  Widget build(BuildContext context) {
    return ListView(
      semanticChildCount: list.length,
      children: list.map((aNote) {
        return ListTile(
          onTap: () {
            onTap(aNote);
          },
          title: Text(
            aNote.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, size: 27),
            onPressed: (){
              onDelete(aNote);
            },
          ),
        );
      }).toList(),
    );
  }
}

