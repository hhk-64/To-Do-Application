import 'package:hive_flutter/hive_flutter.dart';
import 'package:to_do_application/task.dart';

class Database {
  List taskList = [];

  final _myBox = Hive.box('mybox');

  void createInitialData() {
    taskList = [
      Task(
        title: 'Create a new Task',
        content: 'Write down the stuff I need to do',
      ),
      Task(
        title: 'Mark a Task as done',
        content: 'To keep track of things I don\'t need to do anymore',
      ),
      Task(
        title: 'Edit a Task',
        content: 'If I want to make changes',
      ),
      Task(
        title: 'Delete a Task',
        content: 'When I don\'t need it anymore',
      )
    ];
    updateData();
  }

  void readData() {
    taskList = _myBox.get('taskList');
  }

  void updateData() {
    _myBox.put('taskList', taskList);
  }
}
