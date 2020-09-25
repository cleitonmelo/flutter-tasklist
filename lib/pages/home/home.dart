import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_app/models/task.dart';
import 'package:task_app/pages/home/components/add.dart';
import 'package:task_app/pages/home/components/list.dart';
import 'package:task_app/pages/home/components/snack.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController taskFieldControl = TextEditingController();
  List<Task> _tasks = [];
  Map<String, dynamic> _removed = Map();

  void save() => Task().saveAll(_tasks);

  void _addTaskAction() {
    if (taskFieldControl.text.isEmpty) {
      return;
    }

    Task task = Task(description: taskFieldControl.text, done: false);
    setState(() {
      _tasks.add(task);
      taskFieldControl.text = "";
      save();
    });
  }

  void _onTaskCheck(int index, bool value) {
    setState(() {
      _tasks[index].done = value;
      save();
    });
  }

  void _onRemoveItem(index, task, context) {
    _removed["index"] = index;
    _removed["task"] = task;

    setState(() {
      _tasks.removeAt(index);
      save();
    });

    SnackMessage(context, task.description).showUndoMessage(_undoDelete);
  }

  void _undoDelete() {
    setState(() {
      _tasks.insert(_removed['index'], _removed['task']);
      save();
    });
  }

  Future<Null> _onRefreshList() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _tasks.sort((a, b) {
        if (a.done && !b.done) {
          return 1;
        }

        return (!a.done && b.done) ? -1 : 0;
      });

      save();
    });
  }

  @override
  void initState() {
    super.initState();

    Task().fetchListFromStorage().then((tasks) {
      setState(() {
        _tasks = tasks;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Lista de Tarefas",
            style: GoogleFonts.poiretOne(
              textStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          centerTitle: true,
          elevation: 0.0,
          toolbarHeight: 80,
        ),
        body: Container(
          color: Colors.purple,
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              AddTask.build(
                addAction: _addTaskAction,
                textController: taskFieldControl,
              ),
              TaskListView.build(
                  items: _tasks,
                  onCheckboxChanged: _onTaskCheck,
                  onRemoveItem: _onRemoveItem,
                  onRefreshItems: _onRefreshList),
            ],
          ),
        ));
  }
}
