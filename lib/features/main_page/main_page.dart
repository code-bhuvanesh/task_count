import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_count/features/calender_page/calender_page.dart';
import 'package:task_count/features/settings_page/settings_page.dart';
import 'package:task_count/features/statistics_page/statistics_page.dart';

import '../calender_page/bloc/calender_bloc.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var pages = [
    BlocProvider(
      create: (context) => CalenderBloc(),
      child: const CalenderPage(),
    ),
    const StatisticsPage(),
    const SettingsPage(),
  ];

  var index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) { 
          setState(() {
            index = i;
          });
        },
        items: const [
          BottomNavigationBarItem(
            label: "calender",
            icon: Icon(Icons.calendar_month),
          ),
          BottomNavigationBarItem(
            label: "statistics",
            icon: Icon(Icons.auto_graph),
          ),
          BottomNavigationBarItem(
            label: "settings",
            icon: Icon(Icons.settings),
          ),
        ],
      ),
    );
  }
}
