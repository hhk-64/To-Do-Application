import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
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
  late int curDelBuffer;
  bool _titleValidation = false;
  bool _contentValidation = false;

  @override
  void initState() {
    if (_myBox.get('tLists') == null) {
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
    if (db.tLists.isEmpty) return;
    setState(() {
      db.tLists[db.curTListIndex].list
          .add(Task(title: title, content: content));
    });
    db.updateData();
  }

  void createTList(String title) {
    setState(() {
      db.tLists.add(TList(title: title, list: []));
      db.curTListIndex = db.tLists.length - 1;
    });
    db.updateData();
  }

  void deleteTList(int index) {
    setState(() {
      if (db.tLists.length == 1) return;
      db.tLists.removeAt(index);
      db.updateData();
      if (index == 0) return;
      if (db.curTListIndex == index) db.curTListIndex -= 1;
    });
  }

  void toggleDone(int index) {
    if (db.tLists.isEmpty) return;
    setState(() {
      db.tLists[db.curTListIndex].list[index].done =
          !db.tLists[db.curTListIndex].list[index].done;
    });
    db.updateData();
  }

  void deleteTask(int index) {
    if (db.tLists.isEmpty) return;
    setState(() {
      db.tLists[db.curTListIndex].list.removeAt(index);
    });
    db.updateData();
  }

  void editTask(int index) async {
    List? values = await _editDialog(db.tLists[db.curTListIndex].list[index]);
    if (values == null) return;
    setState(() {
      db.tLists[db.curTListIndex].list[index].title = values[0];
      db.tLists[db.curTListIndex].list[index].content = values[1];
    });
    db.updateData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            const SizedBox(
              height: 100,
              child: DrawerHeader(
                decoration: BoxDecoration(color: Color(0xFF373F47)),
                child: Center(
                  child: Text(
                    'Lists',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: db.tLists.length,
                itemBuilder: (context, index) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    selectedTileColor: Colors.grey.withOpacity(0.5),
                    selectedColor: Colors.black,
                    selected: db.curTListIndex == index,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    title: Text(db.tLists[index].title),
                    onTap: () {
                      setState(() {
                        db.curTListIndex = index;
                        db.updateData();
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFAAABBC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF373F47),
        title: const Text('To-Do App'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About this App'),
                  content: const Text('Made by Halil Hamza Kozak.'),
                  actions: [
                    const Text('Version 1.1'),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.help_outline),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: db.tLists[db.curTListIndex].list.length,
        itemBuilder: (context, index) {
          return Task(
            title: db.tLists[db.curTListIndex].list[index].title,
            content: db.tLists[db.curTListIndex].list[index].content,
            done: db.tLists[db.curTListIndex].list[index].done,
            doneCallback: (context) => toggleDone(index),
            deleteCallback: (context) => deleteTask(index),
            editCallback: (context) => editTask(index),
          );
        },
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_arrow,
        buttonSize: const Size(60, 60),
        childrenButtonSize: const Size(60, 60),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        renderOverlay: false,
        childMargin: const EdgeInsets.symmetric(vertical: 20),
        children: [
          SpeedDialChild(
              label: 'Create a Task',
              child: const Icon(Icons.add),
              onTap: () async {
                List? values = await _taskDialog();
                if (values == null) return;
                createTask(values[0], values[1]);
              }),
          SpeedDialChild(
              label: 'Create a new List',
              child: const Icon(Icons.format_list_bulleted_add),
              onTap: () async {
                String? title = await _tListDialog();
                if (title == null || title.trim() == '') return;
                createTList(title);
              }),
          SpeedDialChild(
              label: 'Delete a List',
              child: const Icon(Icons.delete_sweep),
              onTap: () async {
                _deleteTListDialog();
              }),
        ],
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
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    labelText: 'Enter a title',
                    errorText:
                        _titleValidation ? 'This field is required' : null,
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

  // Dialog to create a TList
  Future _tListDialog() {
    titleController.text = '';
    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create a new Task List'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    labelText: 'Enter a title',
                    errorText:
                        _titleValidation ? 'This field is required' : null,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  titleController.text.trim() == ''
                      ? _titleValidation = true
                      : _titleValidation = false;
                  if (!_titleValidation) {
                    Navigator.of(context).pop(titleController.text);
                    titleController.text = '';
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
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    labelText: 'Edit the title',
                    errorText:
                        _titleValidation ? 'This field is required' : null,
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

  // Dialog to delete a TList
  Future _deleteTListDialog() {
    curDelBuffer = 0;
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete a List'),
        content: DropdownMenu(
          initialSelection: 0,
          label: const Text('List'),
          dropdownMenuEntries: List.generate(
            db.tLists.length,
            (index) => DropdownMenuEntry(
              label: db.tLists[index].title,
              value: index,
            ),
          ),
          onSelected: (value) => curDelBuffer = value!,
        ),
        actions: [
          TextButton(
            onPressed: db.tLists.length == 1
                ? null
                : () {
                    setState(() {
                      if (db.curTListIndex == curDelBuffer) {
                        db.curTListIndex - 1 >= 0
                            ? db.curTListIndex -= 1
                            : db.curTListIndex = 0;
                      }
                      deleteTList(curDelBuffer);
                      Navigator.of(context).pop();
                    });
                  },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
