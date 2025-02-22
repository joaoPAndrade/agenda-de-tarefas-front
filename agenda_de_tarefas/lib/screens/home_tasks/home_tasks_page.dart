import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../components/navBar.dart';
import '../../components/sideBar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class Task {
  String title;
  String description;
  String category;
  DateTime dueDate;
  TimeOfDay dueTime;
  String? assignedGroup;
  List<String> assignedMembers;

  Task({
    required this.title,
    required this.description,
    required this.category,
    required this.dueDate,
    required this.dueTime,
    this.assignedGroup,
    this.assignedMembers = const [],
  });
}

class HomeTasksPage extends StatefulWidget {
  const HomeTasksPage({Key? key}) : super(key: key);

  @override
  _HomeTasksPageState createState() => _HomeTasksPageState();
}

class _HomeTasksPageState extends State<HomeTasksPage> {
  List<Task> tasks = [];
  List<String> adminGroups = [];
  List<String> categories = [];
  Map<String, List<String>> groupMembers = {};
  bool isAdmin = false;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final String baseUrl = 'LINK DO BACK';

  @override
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null).then((_) {
      _fetchData();
    });
    _fetchData();
  }

  Future<void> _fetchData() async {
    await Future.wait([fetchGroups(), _fetchCategories(), _fetchTasks()]);
  }


  Future<void> _fetchTasks() async {
    try {
      final response = await http.get(Uri.parse('LINK DO BACK TASKS'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        List<Task> fetchedTasks = data.map((taskData) {
          return Task(
            title: taskData['title'],
            description: taskData['description'],
            category: taskData['category'],
            dueDate: DateTime.parse(taskData['dueDate']),
            dueTime: TimeOfDay(
              hour: int.parse(taskData['dueTime'].split(':')[0]),
              minute: int.parse(taskData['dueTime'].split(':')[1]),
            ),
            assignedGroup: taskData['assignedGroup'],
            assignedMembers: List<String>.from(taskData['assignedMembers']),
          );
        }).toList();

        setState(() {
          tasks = fetchedTasks;
        });
      } else {
        print('Erro ao buscar tarefas: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar tarefas: $e');
    }
  }

void _showTaskDetails(Task task) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Color(0xFFC03A2B),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Descrição: ${task.description}',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                'Categoria: ${task.category}',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                'Data: ${DateFormat('dd/MM/yyyy').format(task.dueDate)}',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                'Hora: ${task.dueTime.format(context)}',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 8),
              if (task.assignedGroup != null)
                Text(
                  'Grupo: ${task.assignedGroup}',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              SizedBox(height: 8),
              if (task.assignedMembers.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Membros designados:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    ...task.assignedMembers.map((member) => Text(
                          member,
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        )),
                  ],
                ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Fechar", style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _editTask(task);
                    },
                    child: Text("Editar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFC03A2B),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await _deleteTask(task);
                      Navigator.pop(context);
                    },
                    child: Text("Excluir"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

  void _editTask(Task task) {
    TextEditingController titleController =
        TextEditingController(text: task.title);
    TextEditingController descriptionController =
        TextEditingController(text: task.description);
    DateTime selectedDate = task.dueDate;
    TimeOfDay selectedTime = task.dueTime;
    String? selectedCategory = task.category;
    String? selectedGroup = task.assignedGroup;
    List<String> selectedMembers = task.assignedMembers;

    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFFC03A2B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: "Título da tarefa",
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: "Descrição da tarefa",
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Categoria",
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      value: selectedCategory,
                      items: categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                    if (isAdmin && adminGroups.isNotEmpty)
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "Designar para grupo",
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        value: selectedGroup,
                        items: adminGroups.map((group) {
                          return DropdownMenuItem<String>(
                            value: group,
                            child: Text(group),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedGroup = value;
                          });
                        },
                      ),
                    ListTile(
                      title: Text(
                        "Data: ${DateFormat('dd/MM/yyyy').format(selectedDate)}",
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: Icon(Icons.calendar_today, color: Colors.white),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null && pickedDate != selectedDate) {
                          setState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                    ),
                    ListTile(
                        title: Text(
                        "Horário: ${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}",
                        style: TextStyle(color: Colors.white),
                        ),
                      trailing: Icon(Icons.access_time, color: Colors.white),
                      onTap: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                          builder: (BuildContext context, Widget? child) {
                            return MediaQuery(
                              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                              child: child!,
                            );
                          },
                        );
                        if (pickedTime != null && pickedTime != selectedTime) {
                          setState(() {
                            selectedTime = pickedTime;
                          });
                        }
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Cancelar", style: TextStyle(color: Colors.white)),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (titleController.text.isNotEmpty &&
                                selectedCategory != null) {
                              Task editedTask = Task(
                                title: titleController.text,
                                description: descriptionController.text,
                                category: selectedCategory!,
                                dueDate: selectedDate,
                                dueTime: selectedTime,
                                assignedGroup: selectedGroup,
                                assignedMembers: selectedMembers,
                              );

                              await _updateTask(editedTask);

                              setState(() {
                                int index = tasks.indexOf(task);
                                tasks[index] = editedTask;
                              });
                              Navigator.pop(context);
                            }
                          },
                          child: Text("Salvar"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFFC03A2B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _updateTask(Task task) async {
    final response = await http.put(
      Uri.parse('LINK DO BACK ATUALIZAR TAREFA'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': task.title,
        'description': task.description,
        'category': task.category,
        'dueDate': task.dueDate.toIso8601String(),
        'dueTime': task.dueTime.format(context),
        'assignedGroup': task.assignedGroup,
        'assignedMembers': task.assignedMembers,
      }),
    );

    if (response.statusCode != 200) {
      print('Erro ao atualizar tarefa: ${response.statusCode}');
    }
  }

  Future<void> _deleteTask(Task task) async {
    try {
      final response =
          await http.delete(Uri.parse('LINK DO BACK PARA DELETAR TAREFA'));
      if (response.statusCode == 200) {
        setState(() {
          tasks.remove(task);
        });
      }
    } catch (e) {
      print('Erro ao deletar tarefa: $e');
    }
  }

  Future<void> fetchGroups() async {
    try {
      final response = await http.get(Uri.parse('LINK BACK GRUPOS'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<String> fetchedAdminGroups = [];

        final prefs = await SharedPreferences.getInstance();
        final emailLocal = prefs.getString('email');

        for (var group in data['groups']) {
          if (group['owner'] == emailLocal) {
            fetchedAdminGroups.add(group['name']);
          }
        }

        setState(() {
          adminGroups = fetchedAdminGroups;
          isAdmin = adminGroups.isNotEmpty;
        });
      } else {
        print('Erro ao buscar grupos: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar grupos: $e');
    }
  }

  Future<void> _fetchCategories() async {
    final response = await http.get(Uri.parse('LINK DO BACK CATEGORIAS'));
    if (response.statusCode == 200) {
      setState(() {
        categories = List<String>.from(json.decode(response.body));
      });
    }
  }

  void _addTask() {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    String? selectedCategory;
    String? selectedGroup;
    List<String> selectedMembers = [];

    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFFC03A2B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: "Título da tarefa",
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: "Descrição da tarefa",
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Categoria",
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      value: selectedCategory,
                      items: categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                    if (isAdmin && adminGroups.isNotEmpty)
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "Designar para grupo",
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        value: selectedGroup,
                        items: adminGroups.map((group) {
                          return DropdownMenuItem<String>(
                            value: group,
                            child: Text(group),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedGroup = value;
                          });
                        },
                      ),
                    ListTile(
                      title: Text(
                        "Data: ${DateFormat('dd/MM/yyyy').format(selectedDate)}",
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: Icon(Icons.calendar_today, color: Colors.white),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null && pickedDate != selectedDate) {
                          setState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                    ),
                    ListTile(
                      title: Text(
                      "Horário: ${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}",
                      style: TextStyle(color: Colors.white),
                      ),
                      trailing: Icon(Icons.access_time, color: Colors.white),
                      onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                        builder: (BuildContext context, Widget? child) {
                        return MediaQuery(
                          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                          child: child!,
                        );
                        },
                      );
                      if (pickedTime != null && pickedTime != selectedTime) {
                        setState(() {
                        selectedTime = pickedTime;
                        });
                      }
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Cancelar", style: TextStyle(color: Colors.white)),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (titleController.text.isNotEmpty && selectedCategory != null) {
                              Task newTask = Task(
                                title: titleController.text,
                                description: descriptionController.text,
                                category: selectedCategory!,
                                dueDate: selectedDate,
                                dueTime: selectedTime,
                                assignedGroup: selectedGroup,
                                assignedMembers: selectedMembers,
                              );

                              await _postTasks(newTask);

                              setState(() {
                                tasks.add(newTask);
                              });
                              Navigator.pop(context);
                            }
                          },
                          child: Text("Salvar"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFFC03A2B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _postTasks(Task task) async {
    final response = await http.post(
      Uri.parse('LINK DO BACK'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': task.title,
        'description': task.description,
        'category': task.category,
        'dueDate': task.dueDate.toIso8601String(),
        'dueTime': task.dueTime.format(context),
        'assignedGroup': task.assignedGroup,
        'assignedMembers': task.assignedMembers,
      }),
    );

    if (response.statusCode != 201) {
      print('Erro ao enviar tarefa: ${response.statusCode}');
    }
  }

  List<Task> _getTasksForDay(DateTime day) {
    return tasks.where((task) => isSameDay(task.dueDate, day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: navBar(),
      drawer: Sidebar(),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Column(
                children: [
                Container(
                  decoration: BoxDecoration(
                  color: Color(0xFFF8DDCE),
                  borderRadius: BorderRadius.circular(12),
                  ),
                  child: TableCalendar(
                  locale: 'pt_BR',
                  firstDay: DateTime.utc(2000, 1, 1),
                  lastDay: DateTime.utc(2100, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    });
                  },
                  calendarFormat: CalendarFormat.month,
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Month',
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                    color: Color(0xFFC03A2B),
                    shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                    color: Color(0xFFC03A2B),
                    shape: BoxShape.circle,
                    ),
                    outsideDaysVisible: false,
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(color: Colors.black),
                    leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
                    rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekendStyle: TextStyle(color: Colors.black),
                    weekdayStyle: TextStyle(color: Colors.black),
                  ),
                  daysOfWeekHeight: 30,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF8DDCE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 100.0), // Adjusted padding
                    child: ListView.builder(
                    itemCount: _getTasksForDay(_selectedDay).length,
                    itemBuilder: (context, index) {
                      final task = _getTasksForDay(_selectedDay)[index];
                      return Column(
                      children: [
                        ListTile(
                        title: Text(
                          task.title,
                          style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          ),
                        ),
                        onTap: () {
                          _showTaskDetails(task);
                        },
                        ),
                        if (index < _getTasksForDay(_selectedDay).length - 1)
                        Divider(
                          color: Colors.red,
                          thickness: 1,
                        ),
                      ],
                      );
                    },
                    ),
                  ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton(
                  onPressed: _addTask,
                  child: Icon(Icons.add, color: Colors.white),
                  backgroundColor: const Color(0xFFC03A2B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
