import 'package:flutter/material.dart';
import '../../../models/task.dart';
import '../services/task_services.dart';
import 'package:flutter/cupertino.dart';
import '../../../models/category.dart';
import '../../../models/groups.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateTaskWidget extends StatefulWidget {
  @override
  _CreateTaskWidgetState createState() => _CreateTaskWidgetState();
}

class _CreateTaskWidgetState extends State<CreateTaskWidget> {
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

  final Map<String, Map<String, dynamic>> flagIcons = {
    'HIGH': {
      'icon': Icons.flag,
      'color': const Color(0xFFC03A2B)
    }, // Exemplo de ícone de bandeira dos EUA
    'MID': {
      'icon': Icons.flag,
      'color': const Color(0xFFE59E39)
    }, // Exemplo de ícone de bandeira do Brasil
    'LOW': {
      'icon': Icons.flag,
      'color': const Color(0xFF577A59)
    }, // Exemplo de ícone de bandeira da França
  };

void fetchCategoriesAndGroups(String email) async {
  try {

    
    List<Group> fetchedGroups =
        await groupService.getGroupsOwnedByUser(email);
    List<Category> fetchedCategories =
        await categoryService.getCategories(email);
        

    setState(() {
      categories = fetchedCategories;
      groups = fetchedGroups;
     
      // Opcional: Definir os primeiros valores como padrão
      if (categories.isNotEmpty) selectedCategory = categories.first;
      if (groups.isNotEmpty) selectedGroup = groups.first;
    });
  } catch (e) {
    print("Erro ao carregar categorias e grupos: $e");
  }
}

@override
void initState() {
  super.initState();
  _loadUserEmailAndFetchData();
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



  void submit() async {
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
    if(selectedCategory == null || selectedGroup == null || selectedValue == null || selectedTime == null || _selectedDate == null){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Preencha todos os campos"),
          duration: Duration(seconds: 3),
        ),
      );
      return;
      
    }
    print(titleController.text);
    print(descriptionController.text);
    print(_selectedDate);
    print(selectedTime);
    print(selectedValue);
    print(selectedCategory!.name);
    print(selectedGroup!.name);





Task newTask = Task(
    id: 0,
    ownerEmail: ownerEmail!,
    title: titleController.text,
    description: descriptionController.text,
    dateTask: _selectedDate!,
    isRecurrent: false,
    priority:  Priority.values.byName(selectedValue!) ,
    status: Status.TODO,
    groupId: selectedGroup!.id,
    categoryId: selectedCategory!.id, 
    comments: '',
    dateCreation: DateTime.now(),
    dateConclusion: DateTime.now(),
  );




try {
  print("Criando");
    await service.createTask(newTask);

    // Mostrar sucesso
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Tarefa criada com sucesso!"),
        duration: Duration(seconds: 3),
      ),
    );

    // Fechar a tela atual
    Navigator.pop(context);
  } catch (e) {
    // Tratar erro caso o serviço falhe
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Erro ao criar tarefa: $e"),
        duration: Duration(seconds: 3),
      ),
    );
      print(e);
  }
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
                          DateTime.now().hour,
                          DateTime.now().minute,
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
              // Botão de Data
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
              Container(
                 height: 33, 
  decoration: BoxDecoration(
    border: Border.all(color: Colors.white, width: 2),  // Borda branca de 2px
    borderRadius: BorderRadius.circular(8),            // Borda com cantos arredondados
  ),
  child: Center(
    child: DropdownButton<String>(
                value: selectedValue,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedValue = newValue!;
                  });
                },
                icon: const Icon(Icons.flag, color: Colors.white),
                dropdownColor: const Color.fromARGB(255, 255, 255, 255),
                style: const TextStyle(color: Colors.white),
                underline: const SizedBox(), 
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
  )
              )
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
          ElevatedButton(
            onPressed: submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC03A2B),
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white, width: 2),
              padding: const EdgeInsets.all(12), // Ajuste no padding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
