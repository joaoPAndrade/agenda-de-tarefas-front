import 'package:flutter/material.dart';
import '../../../models/task.dart';
import '../services/task_services.dart';
import './edit_task_modal.dart';
import '../../../models/taskResponse.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskListWidget extends StatefulWidget {
  final DateTime selectedDay;
  final List<TaskResponse> taskList;
  final VoidCallback onTaskUpdated;

  TaskListWidget({Key? key, required this.selectedDay, required this.taskList, required this.onTaskUpdated,})
      : super(key: key);

  @override
  TaskListWidgetState createState() => TaskListWidgetState();
}

class TaskListWidgetState extends State<TaskListWidget> {
  String? ownerEmail;
  TaskService service = TaskService();

  @override
  void initState() {
    super.initState();
    getEmail();
  }
  void getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    String? ownerEmail = prefs.getString('email');

    if (ownerEmail != null) {
      print("E-mail encontrado na sessão: $ownerEmail");
      setState(() {
        this.ownerEmail = ownerEmail;
      });
    } else {
      print("Nenhum e-mail encontrado na sessão.");
    }
  }

  void markAsCompleted(TaskResponse task, bool? value)async  {
    final prefs = await SharedPreferences.getInstance();
    String? ownerEmail = prefs.getString('email');

    if (ownerEmail != null) {
      print("E-mail encontrado na sessão: $ownerEmail");
      setState(() {
        this.ownerEmail = ownerEmail;
      });
    } else {
      print("Nenhum e-mail encontrado na sessão.");
    }
    if(ownerEmail != task.ownerEmail){
      return;
    }
    if(value == true){
      service.concludeTask(task.id);
    }  else  {
      service.unconcludeTask(task.id);
    }
    setState(() {
      task.status = value == true ? Status.COMPLETED : Status.TODO;
      
    });
  }

  void showEditModal(BuildContext contex, TaskResponse task)  async {

    final prefs = await SharedPreferences.getInstance();
    String? ownerEmail = prefs.getString('email');

    if (ownerEmail != null) {
      print("E-mail encontrado na sessão: $ownerEmail");
      setState(() {
        this.ownerEmail = ownerEmail;
      });
    } else {
      print("Nenhum e-mail encontrado na sessão.");
    }
    if(ownerEmail != task.ownerEmail){
      return;
    }

      await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return EditTaskWidget(task: task);
      },
    );
    widget.onTaskUpdated();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8DDCE),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: widget.taskList.isEmpty
          ? const Center(
              child: Text(
                "Nenhuma tarefa para este dia",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: widget.taskList.length,
              itemExtent: 80, // Ajuste para acomodar as novas informações
              itemBuilder: (context, index) {
                final task = widget.taskList[index];
                return GestureDetector(
                  onTap: () => showEditModal(context, task),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFC03A2B),
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        unselectedWidgetColor: const Color(0xFFC03A2B),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Checkbox(
                              value: task.status == Status.COMPLETED,
                              activeColor: const Color(0xFFC03A2B),
                              checkColor: Colors.white,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              onChanged: (bool? value) => markAsCompleted(task, value),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    decoration: task.status == Status.COMPLETED
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                if (task.description.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      task.description,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        decoration:
                                            task.status == Status.COMPLETED
                                                ? TextDecoration.lineThrough
                                                : null,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                // Exibe Grupo e Categoria
                              ],
                            ),
                          ),
                          if (task.groupName.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 4, right: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                task.ownerEmail == ownerEmail ? task.groupName :
                                "${task.groupName } (Membro)",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ),
                          if (task.categoryName.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                task.categoryName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.flag,
                                color: task.priority == Priority.HIGH
                                    ? const Color(0xFFC03A2B)
                                    : task.priority == Priority.MID
                                        ? const Color(0xFFE59E39)
                                        : const Color(0xFF577A59),
                                size: 20,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${task.dateTask.hour.toString().padLeft(2, '0')}:${task.dateTask.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
