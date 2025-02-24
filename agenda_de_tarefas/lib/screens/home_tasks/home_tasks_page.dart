import 'package:flutter/material.dart';
import '../../components/navBar.dart';
import '../../components/sideBar.dart';
import './widgets/calendar_widget.dart';
import './widgets/task_list_widget.dart';
import './services/task_services.dart';
import '../../models/task.dart';
import './widgets/create_task_widget.dart';
import '../../models/taskResponse.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeTasksPage extends StatefulWidget {
  const HomeTasksPage({Key? key}) : super(key: key);

  @override
  _HomeTasksPageState createState() => _HomeTasksPageState();
}

class _HomeTasksPageState extends State<HomeTasksPage> {
    DateTime selectedDay = DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day);
DateTime focusedDay = DateTime.now();
  List<TaskResponse> taskList = [];
  TaskService service = TaskService();
  String? ownerEmail;
  void fetchTask() async {
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

    final List<TaskResponse> taskResponse =
        await service.getTasksByDay(selectedDay, ownerEmail!);
    setState(() {
      taskList = taskResponse.map((e) => e).toList();
    });
  }

  /*  int selectedMonth = selectedDay.month;
    final List<Task> tasks = await service.getTasksByDay(selectedDay);
    setState(() {
      taskList = tasks;
    });
*/

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      this.selectedDay = selectedDay;
      this.focusedDay = focusedDay;
      fetchTask();
    });
  }

  void showDialogCreateTask(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CreateTaskWidget();
      },
    );
    setState(() {
      fetchTask();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchTask();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const navBar(),
      drawer: const Sidebar(),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CalendarWidget(
                selectedDay_: selectedDay,
                onDayChanged: onDaySelected,
              ),
              Container(
                padding: const EdgeInsets.only(top: 30),
                child: TaskListWidget(
                  selectedDay: selectedDay,
                  taskList: taskList,
                  onTaskUpdated: fetchTask,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC03A2B),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add),
                      color: Colors.white,
                      iconSize: 30,
                      onPressed: () => showDialogCreateTask(context),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
