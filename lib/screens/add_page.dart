// ignore_for_file: public_member_api_docs, sort_constructors_first, use_build_context_synchronously
// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../pop-ups/note_add.dart';

// ignore: must_be_immutable
class AddTodoPage extends StatefulWidget {
  String? id, title, description;
  var list = [];
  AddTodoPage({
    Key? key,
    this.id,
    this.title,
    this.description,
  }) : super(key: key);
  var isEditMode = false;
  var isVisible = true;
  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  var titleController = TextEditingController();
  var descriptionController = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      widget.isEditMode = true;
      titleController.text = widget.title.toString();
      descriptionController.text = widget.description.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode ? 'Edit todo' : 'Add todo'),
      ),
      body: bodyContent,
    );
  }

  get bodyContent {
    return Visibility(
      visible: widget.isVisible,
      replacement: Center(
        child: CircularProgressIndicator(),
      ),
      child: Form(
        key: _formkey,
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: titleController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please Enter note title";
                }
              },
              decoration: InputDecoration(
                hintText: 'Title',
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: descriptionController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please Enter note description";
                }
              },
              decoration: InputDecoration(
                hintText: 'Description',
              ),
              keyboardType: TextInputType.multiline,
              minLines: 2,
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitData,
              child: Text(widget.isEditMode ? 'Edit' : 'Submit'),
            )
          ],
        ),
      ),
    );
  }

  submitData() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        widget.isVisible = false;
      });
      final title = titleController.text;
      final description = descriptionController.text;
      final body = {
        "title": title,
        "description": description,
        "is_completed": false,
      };

      if (widget.isEditMode) {
        final url =
            'https://63ee434d5e9f1583bdbf847d.mockapi.io/notes/${widget.id}';
        final uri = Uri.parse(url);
        final responce = await http.put(
          uri,
          body: jsonEncode(body),
          headers: {"Content-Type": 'application/json; charset=UTF-8'},
        );
        if (responce.statusCode == 200) {
          // ignore: duplicate_ignore
          setState(() async {
            await getData();
            final result = await showDialog(
              context: context,
              builder: (context) {
                return NoteAdd(
                  content: 'Data has been successfully Edited',
                );
              },
            );
            if (result) {
              Navigator.of(context).pop(widget.list);
            }
          });
        }
        return responce;
      }
      const url = 'https://63ee434d5e9f1583bdbf847d.mockapi.io/notes/';
      final uri = Uri.parse(url);
      final responce = await http.post(
        uri,
        body: jsonEncode(body),
        headers: {"Content-Type": 'application/json; charset=UTF-8'},
      );
      if (responce.statusCode == 201) {
        setState(() async {
          await getData();
          final result = await showDialog(
            context: context,
            builder: (context) {
              return NoteAdd(
                content: 'Data has been successfully Added',
              );
            },
          );
          if (result) {
            Navigator.of(context).pop(widget.list);
          }
        });
      }
      return responce;
    }
  }

  getData() async {
    const url = 'https://63ee434d5e9f1583bdbf847d.mockapi.io/notes';
    var uri = Uri.parse(url);
    final response = await http.get(uri);
    setState(() {
      widget.list = jsonDecode(response.body);
    });
  }
}
