import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'task.g.dart';

@HiveType(typeId: 1)
// ignore: must_be_immutable
class Task extends StatefulWidget {
  Task({
    super.key,
    required this.title,
    required this.content,
    this.done = false,
    this.doneCallback,
    this.deleteCallback,
    this.editCallback,
  });

  @HiveField(0)
  String title;
  @HiveField(1)
  String content;
  @HiveField(2)
  bool done;

  Function(BuildContext)? doneCallback;
  Function(BuildContext)? deleteCallback;
  Function(BuildContext)? editCallback;

  @override
  State<Task> createState() => _TaskState();
}

class _TaskState extends State<Task> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => widget.doneCallback!(context),
              icon: widget.done ? Icons.undo : Icons.check,
              backgroundColor: widget.done
                  ? const Color(0xFF6C91C2)
                  : const Color(0xFF8893D3),
              borderRadius: BorderRadius.circular(10),
            ),
            SlidableAction(
              onPressed: (context) => widget.editCallback!(context),
              icon: Icons.edit,
              backgroundColor: Colors.blueGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            SlidableAction(
              onPressed: (context) => widget.deleteCallback!(context),
              icon: Icons.delete,
              backgroundColor: Colors.redAccent,
              borderRadius: BorderRadius.circular(10),
            ),
          ],
        ),
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF8B8982),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Text(
                  widget.title,
                  style: TextStyle(
                    color: widget.done
                        ? Colors.white.withOpacity(0.5)
                        : Colors.white,
                    fontSize: 20,
                    decoration: widget.done ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              Text(
                widget.content,
                style: TextStyle(
                  color: widget.done
                      ? Colors.white.withOpacity(0.5)
                      : Colors.white,
                  fontSize: 14,
                  decoration: widget.done ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
