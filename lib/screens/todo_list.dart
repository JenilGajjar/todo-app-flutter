// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:todo_app/pop-ups/note_delete.dart';
import 'add_page.dart';
import 'package:http/http.dart' as http;

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  var list = [];
  var isloaded = false;

  late StreamSubscription subscription;
  var isDeviceConnected = false;
  bool isAlertSet = false;
  @override
  void initState() {
    super.initState();
    getConnectivity();
    getData();
  }

  getConnectivity() {
    subscription = Connectivity().onConnectivityChanged.listen(
      (event) async {
        isDeviceConnected = await InternetConnectionChecker().hasConnection;
        if (!isDeviceConnected && isAlertSet == false) {
          showDialogBox();
          setState(() {
            isAlertSet = true;
          });
        }
      },
    );
  }

  showDialogBox() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('No Connection'),
          content: Text('Please check your internet connection'),
          actions: [
            ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context, 'Cancel');
                  setState(() => isAlertSet = false);
                  isDeviceConnected =
                      await InternetConnectionChecker().hasConnection;
                  if (!isDeviceConnected) {
                    showDialogBox();
                    setState(() => isAlertSet = true);
                  }
                },
                child: Text('Ok'))
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarContent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) {
              return AddTodoPage();
            },
          ));
          setState(() {
            list = result;
          });
        },
        label: Text('Add Todo'),
      ),
      body: bodyContent,
    );
  }

  get appbarContent {
    return AppBar(
      centerTitle: true,
      title: Text('Todo App'),
    );
  }

  get bodyContent {
    return Visibility(
      visible: isloaded,
      replacement: Center(child: CircularProgressIndicator()),
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: list.length,
        itemBuilder: (context, index) {
          var note = list[index];
          return Dismissible(
            key: UniqueKey(),
            secondaryBackground: Container(
              padding: EdgeInsets.all(8),
              color: Colors.red,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Icon(Icons.delete),
                  Text(' Delete'),
                ],
              ),
            ),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.endToStart) {
                final result = await showDialog(
                  context: context,
                  builder: (context) => NoteDelete(),
                );
                if (result) {
                  delete(list[index]['id']);
                }
                return result;
              } else {
                final result =
                    await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) {
                    return AddTodoPage(
                      id: list[index]['id'],
                      title: list[index]['title'],
                      description: list[index]['description'],
                    );
                  },
                ));
                setState(() {
                  list = result;
                });
              }
            },
            background: Container(
              padding: EdgeInsets.all(8),
              color: Colors.green,
              alignment: Alignment.centerLeft,
              child: Row(
                children: const [
                  Icon(Icons.edit),
                  Text(
                    '  Edit',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            child: ListTile(
              title: Text('${note['title']}'),
              subtitle: Text(note['description']),
            ),
          );
        },
      ),
    );
  }

  getData() async {
    const url = 'https://63ee434d5e9f1583bdbf847d.mockapi.io/notes';
    var uri = Uri.parse(url);
    final response = await http.get(uri);
    isloaded = true;
    setState(() {
      list = jsonDecode(response.body);
    });
  }

  delete(id) async {
    final url = 'https://63ee434d5e9f1583bdbf847d.mockapi.io/notes/$id';
    var uri = Uri.parse(url);
    final response = await http.delete(uri).then((value) {});
    return response;
  }
}
