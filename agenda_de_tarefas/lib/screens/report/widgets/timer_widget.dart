import 'package:flutter/material.dart';
import '../../../models/category.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TimerWidget extends StatefulWidget {
  Category category;
  TimerWidget({Key? key, required this.category}) : super(key: key);

  @override
  TimerWidgetState createState() => TimerWidgetState();
}

class TimerWidgetState extends State<TimerWidget> {
  String timeSpentMinutes = '00';
  String timeSpentHours = '00';
  DateTime _selectedDate1 = DateTime.now().subtract(const Duration(days: 7));
  DateTime _selectedDate2 = DateTime.now();
  bool change = false;
  String? ownerEmail;
  Future<void> _selectDate(BuildContext context, int buttonIndex) async {
    change = true;
    final DateTime currentDate = DateTime.now();
    final DateTime pickedDate = await showDatePicker(
            context: context,
            initialDate: currentDate,
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
            builder: (BuildContext context, Widget? child) {
              return Theme(
                data: ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFFC03A2B),
                    onPrimary: Color(0xFFF8DDCE),
                  ),
                  buttonTheme: const ButtonThemeData(
                    textTheme: ButtonTextTheme.primary,
                  ),
                  dialogBackgroundColor: const Color(0xFFF8DDCE),
                  scaffoldBackgroundColor: const Color(0xFFF8DDCE),
                  primaryColor: const Color(0xFFC03A2B),
                ),
                child: child!,
              );
            }) ??
        currentDate;

    // Formatar a data selecionada no formato dd/MM/yyyy
    final String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);

    setState(() {
      if (buttonIndex == 1) {
        _selectedDate1 = pickedDate;
      } else if (buttonIndex == 2) {
        _selectedDate2 = pickedDate;
      }
      if (_selectedDate1.isAfter(_selectedDate2)) {
        print("HHERE");
        setState(() {
        timeSpentHours = '00';
        timeSpentMinutes = '00';
      });
      } else{
         getTimeSpent(ownerEmail!);
      }
    });
  }
  
  Future<int> fetchData(String email) async {

    const String baseUrl = 'http://localhost:3333';
    _selectedDate1 = DateTime(_selectedDate1.year, _selectedDate1.month,
        _selectedDate1.day , 0, 0, 0);
    _selectedDate2 = DateTime(_selectedDate2.year, _selectedDate2.month,
        _selectedDate2.day, 23, 59, 59);

      


    final response = await http.put(
      Uri.parse('$baseUrl/task/time'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'initialDate': _selectedDate1.toUtc().toIso8601String(),
        'finalDate': _selectedDate2.toUtc().toIso8601String(),
        'categoryId': widget.category.id,
        'userEmail': email,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      int minutes = jsonData['minutes'].toInt() ?? 0;
      return minutes;
    } else {
      throw Exception('Erro ao buscar tempo gasto na atividade');
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
    getTimeSpent(ownerEmail);
    setState(() {
      this.ownerEmail = ownerEmail;
    });
  } else {
    print("Nenhum e-mail encontrado na sessão.");
  }
}
















  void getTimeSpent(String email) async {
    int timeSpent = await fetchData(email);
    int timeHours = timeSpent ~/ 60;
    int timeMinutes = timeSpent % 60;

    int hours = 0;
    int minutes = 0;
    Timer.periodic(const Duration(milliseconds: 5), (timer) {
      if (hours == timeHours && minutes == timeMinutes) {
        timer.cancel();
      }
      if (hours < timeHours) {
        if (timeSpent > 2000 && timeHours - hours >= 100) {
          hours += 100;
        } else if (timeSpent > 2000 && timeHours - hours > 10) {
          hours += 10;
        } else {
          hours++;
        }
      }
      if (minutes < timeMinutes) {
        minutes++;
      }
      setState(() {
        timeSpentHours = hours.toString().padLeft(2, '0');
        timeSpentMinutes = minutes.toString().padLeft(2, '0');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$timeSpentHours h & $timeSpentMinutes min',
            style: const TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Entre"),
              const SizedBox(width: 10),
              ElevatedButton(
                  onPressed: () => _selectDate(context, 1),
                  child: Text(
                    !change
                        ? 'DD/MM/YYYY' // Texto padrão
                        : DateFormat('dd/MM/yyyy').format(_selectedDate1),
                    style: const TextStyle(
                      color: Color(0xFFC03A2B),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(
                      color: Color(0xFFC03A2B),
                      width: 3,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  )),
              const SizedBox(width: 10),
              const Text("Até"),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => _selectDate(context, 2),
                child: Text(
                  !change
                      ? 'DD/MM/YYYY'
                      : DateFormat('dd/MM/yyyy').format(_selectedDate2),
                  style: const TextStyle(
                    color: Color(0xFFC03A2B),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(
                    color: Color(0xFFC03A2B),
                    width: 3,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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
