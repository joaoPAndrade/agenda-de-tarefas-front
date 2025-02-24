import 'package:flutter/material.dart';
import '../../../models/task.dart';
import '../services/task_services.dart';
import 'package:flutter/cupertino.dart';
import '../../../models/category.dart';
import '../../../models/groups.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/taskResponse.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class EditTaskWidget extends StatefulWidget {
  final TaskResponse task;
  const EditTaskWidget({Key? key, required this.task}) : super(key: key);

  @override
  _EditTaskWidgetState createState() => _EditTaskWidgetState();
}

class _EditTaskWidgetState extends State<EditTaskWidget> {
  DateTime? _selectedDate;
  TimeOfDay? selectedTime;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String? selectedValue;
  TaskService service = TaskService();
  GroupService groupService = GroupService();
  CategoryService categoryService = CategoryService();
  Category? selectedCategory;
  Group? selectedGroup;
  List<Group> groups = [];
  List<Category> categories = [];
  String? ownerEmail;


  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _selectedDate = widget.task.dateTask;
    selectedTime = TimeOfDay(
      hour: widget.task.dateTask.hour,
      minute: widget.task.dateTask.minute,
    );
    titleController.text = widget.task.title;
    descriptionController.text = widget.task.description;
    selectedValue = widget.task.priority.name;
    selectedGroup = Group(id: widget.task.groupId, name: widget.task.groupName, description: "", ownerEmail: widget.task.ownerEmail);
    selectedCategory = Category(id: widget.task.categoryId, name: widget.task.categoryName, ownerEmail: widget.task.ownerEmail);
    _loadUserEmailAndFetchData();
  }

  final Map<String, Map<String, dynamic>> flagIcons = {
    'HIGH': {'icon': Icons.flag, 'color': const Color(0xFFC03A2B)},
    'MID': {'icon': Icons.flag, 'color': const Color(0xFFE59E39)},
    'LOW': {'icon': Icons.flag, 'color': const Color(0xFF577A59)},
  };



  void fetchCategoriesAndGroups(String email) async {
  try {

    
    List<Group> fetchedGroups =
        await groupService.getGroupsOwnedByUser(email);
    List<Category> fetchedCategories =
        await categoryService.getCategories(email);
        

    Group? matchingGroup = fetchedGroups.firstWhere(
      (group) => group.id == selectedGroup?.id,
      orElse: () => Group(id: 0, name: "", description: "", ownerEmail: ""),
    );

    Category? matchingCategory = fetchedCategories.firstWhere(
      (category) => category.id == selectedCategory?.id,
      orElse: () => Category(id: 0, name: "", ownerEmail: ""),
    );

    setState(() {
      // Atualiza as listas de grupos e categorias
      groups = fetchedGroups;
      categories = fetchedCategories;

      // Atualiza os valores de selectedGroup e selectedCategory com os encontrados
      selectedGroup =  matchingGroup;
      selectedCategory =matchingCategory;
    });



  } catch (e) {
    print("Erro ao carregar categorias e grupos: $e");
  }
}



void _loadUserEmailAndFetchData() async {
  final prefs = await SharedPreferences.getInstance();
  String? ownerEmail = prefs.getString('email');


  if (ownerEmail != null) {
    print("E-mail encontrado na sessão: $ownerEmail");
    setState(() {
      this.ownerEmail = ownerEmail;
    });
    fetchCategoriesAndGroups(ownerEmail);
  } else {
    print("Nenhum e-mail encontrado na sessão.");
  }
}







  void submit() {
    if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nenhum dos campos pode ser vazio"),
          duration: Duration(seconds: 3),
        ),
      );

      return;
    } else if (!RegExp(r'^[a-zA-Z0-9 ]*$').hasMatch(titleController.text) ||
        !RegExp(r'^[a-zA-Z0-9 ]*$').hasMatch(descriptionController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Insira apenas letras e números"),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    Navigator.pop(context);
  }

  void remove(int id) async {

   try {
      await     service.deleteTask(id);

      if (mounted) {
    Navigator.pop(context);
  }
  } catch (e) {
    print("Erro ao remover: $e");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Erro ao remover tarefa: $e"),
        duration: const Duration(seconds: 3),
      ),
    );
  }



  }

  /*void edit(TaskResponse task){
    if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nenhum dos campos pode ser vazio"),
          duration: Duration(seconds: 3),
        ),
      );

      return;
    } else if (!RegExp(r'^[a-zA-Z0-9 ]*$').hasMatch(titleController.text) ||
        !RegExp(r'^[a-zA-Z0-9 ]*$').hasMatch(descriptionController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Insira apenas letras e números"),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    Task task = Task(
      id: widget.task.id,
      title: titleController.text,
      description: descriptionController.text,
      dateTask: DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      ),
      priority:Priority.values.byName(selectedValue!),
      groupId: selectedGroup!.id,
      categoryId: selectedCategory!.id,
      ownerEmail: ownerEmail!,
      comments: '',
      isRecurrent: false,
      status: widget.task.status,
      dateCreation: DateTime.now(),
      dateConclusion: DateTime.now(),
    );
  }*/
void edit(TaskResponse task) async {
  if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Nenhum dos campos pode ser vazio"),
        duration: Duration(seconds: 3),
      ),
    );
    return;
  } else if (!RegExp(r'^[a-zA-Z0-9 ]*$').hasMatch(titleController.text) ||
      !RegExp(r'^[a-zA-Z0-9 ]*$').hasMatch(descriptionController.text)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Insira apenas letras e números"),
        duration: Duration(seconds: 3),
      ),
    );
    return;
  }
  if( selectedGroup == null || selectedCategory == null || selectedTime == null || _selectedDate == null || selectedValue == null){
    return;
  }
  Task updatedTask = Task(
    id: widget.task.id,
    title: titleController.text,
    description: descriptionController.text,
    dateTask: DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    ),
    priority: Priority.values.byName(selectedValue!),
    groupId: selectedGroup!.id,
    categoryId: selectedCategory!.id,
    ownerEmail: ownerEmail!,
    comments: '',
    isRecurrent: false,
    status: widget.task.status,
    dateCreation: widget.task.dateCreation,
    dateConclusion: widget.task.dateConclusion ?? DateTime.now(),
  );
  print(updatedTask.priority);
  //await service.updateTask(updatedTask);



    try {
      await service.updateTask(updatedTask);
      print("Tarefa atualizada com sucesso!");

      if (mounted) {
    Navigator.pop(context);
  }
  } catch (e) {
    print("Erro ao atualizar: $e");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Erro ao atualizar tarefa: $e"),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}


  void confirmAction(BuildContext context, int action) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFFC03A2B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          height: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Confirmar Ação",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 10),
              const Text(
                "Você tem certeza que deseja realizar essa ação?",
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "Cancelar",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      //Navigator.of(context).pop();
                      if (action == 0) {
                        edit(widget.task);
                         print("Ação Editar realizada");
                      } else if (action == 1) {
                        remove(widget.task.id);
                        print("Ação Remover realizada");
                      }
                      Navigator.of(context).pop();

                    },
                    child: const Text(
                      "Confirmar",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void selectTime(BuildContext context) async {
    selectedTime = selectedTime ?? TimeOfDay.now();

    final TimeOfDay? pickedTime = await showModalBottomSheet<TimeOfDay>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        TimeOfDay? tempTime = selectedTime;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: 400,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFC03A2B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Selecione a Hora",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Theme(
                      data: ThemeData.dark().copyWith(
                        cupertinoOverrideTheme: const CupertinoThemeData(
                          textTheme: CupertinoTextThemeData(
                            dateTimePickerTextStyle:
                                TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        initialDateTime: DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                          selectedTime?.hour ?? 0,
                          selectedTime?.minute ?? 0,
                        ),
                        onDateTimeChanged: (DateTime newTime) {
                          tempTime = TimeOfDay.fromDateTime(newTime);
                          setModalState(() {});
                        },
                        use24hFormat: true,
                        backgroundColor: const Color(0xFFC03A2B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, tempTime),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                    ),
                    child: const Text("Confirmar"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  void selectDate(BuildContext context) async {
    DateTime selectedDate = _selectedDate ?? DateTime.now();

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: 400,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFFC03A2B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Selecione a Data",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: CalendarDatePicker(
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  onDateChanged: (date) {
                    setState(() {
                      selectedDate = date;
                    });
                  },
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedDate = selectedDate;
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                ),
                child: const Text("Confirmar"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFFC03A2B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      height: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Criar Nova Tarefa",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: titleController,
                  maxLength: 15,
                  decoration: const InputDecoration(
                    labelText: 'Título da tarefa',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira um título';
                    } else if (!RegExp(r'^[a-zA-Z0-9 ]+$').hasMatch(value)) {
                      return 'Apenas letras, números e espaços são permitidos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  maxLength: 30,
                  decoration: const InputDecoration(
                    labelText: 'Descrição da tarefa',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira uma descrição';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => selectDate(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC03A2B),
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _selectedDate == null
                      ? "dd/mm/aaaa"
                      : "${_selectedDate?.day}/${_selectedDate?.month}/${_selectedDate?.year}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => selectTime(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC03A2B),
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  selectedTime == null
                      ? "hh:mm"
                      : "${selectedTime?.hour}:${selectedTime?.minute.toString().padLeft(2, '0')}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              DropdownButton<String>(
                value: selectedValue,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedValue = newValue!;
                  });
                },
                icon: const Icon(Icons.flag, color: Colors.white),
                dropdownColor: const Color.fromARGB(255, 255, 255, 255),
                style: const TextStyle(color: Colors.white),
                items: flagIcons.entries.map<DropdownMenuItem<String>>((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Row(
                      children: [
                        Icon(entry.value['icon'],
                            color: entry.value['color'], size: 30),
                        const SizedBox(width: 8),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [











              Container(
                 height: 33, 
                 width: 120,

  decoration: BoxDecoration(
    border: Border.all(color: Colors.white, width: 2),  // Borda branca de 2px
    borderRadius: BorderRadius.circular(8),            // Borda com cantos arredondados
  ),
  child:Center(
    child: DropdownButton<Category>(
                value: selectedCategory,
                onChanged: (Category? newValue) {
                  setState(() {
                    selectedCategory = newValue!;
                  });
                },
                icon: const Icon(Icons.category, color: Colors.white),
                dropdownColor: const Color(0xFFC03A2B),
                style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                underline: const SizedBox(), 
                items: categories.map<DropdownMenuItem<Category>>((category) {
                  return DropdownMenuItem<Category>(
                    value: category,
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        Text(category.name),
                      ],
                    ),
                  );
                }).toList(),
              ),
  ) 
  
  
  ),




              // Dropdown para Categoria
              





Container(
                 height: 33, 
                 width: 120,

  decoration: BoxDecoration(
    border: Border.all(color: Colors.white, width: 2),  // Borda branca de 2px
    borderRadius: BorderRadius.circular(8),            // Borda com cantos arredondados
  ),
  child: DropdownButton<Group>(
                value: selectedGroup,
                onChanged: (Group? newValue) {
                  setState(() {
                    selectedGroup = newValue;
                  });
                },
                icon: const Icon(Icons.group, color: Colors.white),
                
                dropdownColor: const Color(0xFFC03A2B),
                style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                underline: SizedBox(), 
                items: groups.map<DropdownMenuItem<Group>>((group) {
                  return DropdownMenuItem<Group>(
                    value: group,
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        Text(group.name),
                      ],
                    ),
                  );
                }).toList(),
              ) ,
  
  
  ),


              // Dropdown para Grupo
             
















            ],
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            height: 1,
            color: Colors.white.withOpacity(0.5),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => confirmAction(context, 0),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC03A2B),
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Editar",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => confirmAction(context, 1, ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC03A2B),
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Remover",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
