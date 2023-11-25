import 'package:hive_flutter/hive_flutter.dart';
import 'package:to_do_application/task.dart';

class Database {
  List tLists = [];
  int curTListIndex = 0;

  final _myBox = Hive.box('mybox');

  void createInitialData() {
    tLists = [
      TList(
        title: 'List 1',
        list: [
          Task(
            title: 'Your First Task',
            content: 'Create your first Task',
          ),
        ],
      ),
      TList(
        title: 'List 2',
        list: [
          Task(
            title: 'Your second Task',
            content: 'Access more options by swiping left on a Task',
          ),
        ],
      ),
    ];
    updateData();
  }

  void readData() {
    tLists = _myBox.get('tLists');
    curTListIndex = _myBox.get('curTListIndex');
  }

  void updateData() {
    _myBox.put('tLists', tLists);
    _myBox.put('curTListIndex', curTListIndex);
  }
}
