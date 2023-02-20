// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';

class NoteAdd extends StatefulWidget {
  String content;

  NoteAdd({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  State<NoteAdd> createState() => _NoteAddState();
}

class _NoteAddState extends State<NoteAdd> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Success'),
      content: Text(widget.content),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: const Text(
            'Ok',
          ),
        )
      ],
    );
  }

  
}
