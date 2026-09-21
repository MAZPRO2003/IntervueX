import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intervuex_app/core/theme/app_colors.dart';
import 'package:intervuex_app/presentation/views/home/home_screen.dart';
import 'package:intervuex_app/presentation/views/packs/packs_list_screen.dart';
import 'package:intervuex_app/presentation/views/questions/question_list_screen.dart';
import 'package:intervuex_app/presentation/views/study_plan/study_plan_screen.dart';
import 'package:intervuex_app/presentation/views/profile/profile_screen.dart';

class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key});

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    PacksListScreen(),
    QuestionListScreen(),
    StudyPlanScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppColors.indigoLight),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work, color: AppColors.indigoLight),
            label: 'Interviews',
          ),
          NavigationDestination(
            icon: Icon(Icons.quiz_outlined),
            selectedIcon: Icon(Icons.quiz, color: AppColors.indigoLight),
            label: 'Practice',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up),
            selectedIcon: Icon(Icons.trending_up, color: AppColors.indigoLight),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.indigoLight),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
