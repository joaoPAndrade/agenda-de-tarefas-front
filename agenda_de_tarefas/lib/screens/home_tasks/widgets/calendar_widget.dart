import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';

class CalendarWidget extends StatefulWidget {
  final DateTime selectedDay_;
  final Function(DateTime selectedDay, DateTime focusedDay)? onDayChanged;

  CalendarWidget({
    Key? key,
    required this.selectedDay_,
    required this.onDayChanged,
  }) : super(key: key);

  @override
  CalendarWidgetState createState() => CalendarWidgetState();
}

class CalendarWidgetState extends State<CalendarWidget> {
  late DateTime focusedDay;
  late DateTime selectedDay;

  @override
  void initState() {
    super.initState();
    selectedDay = widget.selectedDay_;
    focusedDay = widget.selectedDay_;
    initializeDateFormatting('pt_BR', null);
  }

  void onDaySelected(DateTime newSelectedDay, DateTime newFocusedDay) {
    setState(() {
      selectedDay = newSelectedDay;
      focusedDay = newFocusedDay;
    });
    widget.onDayChanged?.call(newSelectedDay, newFocusedDay);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8DDCE),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        children: [
          TableCalendar(
            locale: "pt_BR",
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Color(0xFFC03A2B),
                shape: BoxShape.circle,
              ),
            ),
            onDaySelected: onDaySelected,
            availableCalendarFormats: const {CalendarFormat.month: 'Month'},
            headerStyle: const HeaderStyle(
              formatButtonVisible:
                  false, // Remova o botão de formato, se necessário
              titleCentered: true, // Centralize o título
              decoration: BoxDecoration(
                color: Color(0xFFF8DDCE),
              ),
            ),
          )
        ],
      ),
    );
  }
}
