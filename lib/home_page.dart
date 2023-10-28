import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:to_do_application/database.dart';
import 'package:to_do_application/task.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _myBox = Hive.box('mybox');

  Database db = Database();

  late TextEditingController titleController;
  late TextEditingController contentController;
  bool _titleValidation = false;
  bool _contentValidation = false;

  @override
  void initState() {
    if (_myBox.get('taskList') == null) {
      db.createInitialData();
    } else {
      db.readData();
    }

    super.initState();

    titleController = TextEditingController();
    contentController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();

    super.dispose();
  }

  void createTask(String title, String content) {
    setState(() {
      db.taskList.add(Task(title: title, content: content));
    });
    db.updateData();
  }

  void toggleDone(int index) {
    setState(() {
      db.taskList[index].done = !db.taskList[index].done;
    });
    db.updateData();
  }

  void deleteTask(int index) {
    setState(() {
      db.taskList.removeAt(index);
    });
    db.updateData();
  }

  void editTask(int index) async {
    List? values = await _editDialog(db.taskList[index]);
    if (values == null) return;
    setState(() {
      db.taskList[index].title = values[0];
      db.taskList[index].content = values[1];
    });
    db.updateData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAAABBC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF373F47),
        title: const Text('To-Do App'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: db.taskList.length,
        itemBuilder: (context, index) => Task(
          title: db.taskList[index].title,
          content: db.taskList[index].content,
          done: db.taskList[index].done,
          doneCallback: (context) => toggleDone(index),
          deleteCallback: (context) => deleteTask(index),
          editCallback: (context) => editTask(index),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          List? values = await _taskDialog();
          if (values == null) return;
          createTask(values[0], values[1]);
        },
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Dialog to create a new task
  Future _taskDialog() {
    titleController.text = '';
    contentController.text = '';
    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create a new Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  labelText: 'Enter a title',
                  errorText: _titleValidation ? 'This field is required' : null,
                ),
              ),
              TextField(
                controller: contentController,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  labelText: 'Enter the content of the task',
                  errorText:
                      _contentValidation ? 'This field is required' : null,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  titleController.text.trim() == ''
                      ? _titleValidation = true
                      : _titleValidation = false;
                  contentController.text.trim() == ''
                      ? _contentValidation = true
                      : _contentValidation = false;
                  if (!_titleValidation && !_contentValidation) {
                    Navigator.of(context)
                        .pop([titleController.text, contentController.text]);
                    titleController.text = '';
                    contentController.text = '';
                  }
                });
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog to edit a Task
  Future _editDialog(Task task) {
    titleController.text = task.title;
    contentController.text = task.content;
    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit the task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  labelText: 'Edit the title',
                  errorText: _titleValidation ? 'This field is required' : null,
                ),
              ),
              TextField(
                controller: contentController,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  labelText: 'Edit the content of the task',
                  errorText:
                      _contentValidation ? 'This field is required' : null,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  titleController.text.trim() == ''
                      ? _titleValidation = true
                      : _titleValidation = false;
                  contentController.text.trim() == ''
                      ? _contentValidation = true
                      : _contentValidation = false;
                  if (!_titleValidation && !_contentValidation) {
                    Navigator.of(context)
                        .pop([titleController.text, contentController.text]);
                    titleController.text = '';
                    contentController.text = '';
                  }
                });
              },
              child: const Text('Edit'),
            ),
          ],
        ),
      ),
    );
  }
}
