import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intervuex_app/presentation/views/home/home_screen.dart';
import 'package:intervuex_app/presentation/views/questions/question_list_screen.dart';
import 'package:intervuex_app/presentation/views/mock/mock_interview_screen.dart';
import 'package:intervuex_app/presentation/views/resumes/analyze_resume_screen.dart';

/// Shell nav index provider — lets child screens change the active tab
final shellNavIndexProvider = StateProvider<int>((ref) => 0);

class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key});

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  final List<Widget> _pages = const [
    HomeScreen(),
    QuestionListScreen(),
    MockInterviewScreen(),
    AnalyzeResumeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final rawIndex = ref.watch(shellNavIndexProvider);
    final currentIndex = rawIndex.clamp(0, 3);
    final secondary = Theme.of(context).colorScheme.secondary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        reverseDuration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.97, end: 1.0).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(currentIndex),
          child: _pages[currentIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (idx) {
            ref.read(shellNavIndexProvider.notifier).state = idx;
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded, color: secondary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: const Icon(Icons.quiz_outlined),
              selectedIcon: Icon(Icons.quiz_rounded, color: secondary),
              label: 'Practice',
            ),
            NavigationDestination(
              icon: const Icon(Icons.mic_outlined),
              selectedIcon: Icon(Icons.mic_rounded, color: secondary),
              label: 'Mock',
            ),
            NavigationDestination(
              icon: const Icon(Icons.description_outlined),
              selectedIcon: Icon(Icons.description_rounded, color: secondary),
              label: 'Resume',
            ),
          ],
        ),
      ),
    );
  }
}
