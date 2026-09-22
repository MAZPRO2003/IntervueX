import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intervuex_app/core/theme/app_colors.dart';
import 'package:intervuex_app/core/widgets/app_button.dart';
import 'package:intervuex_app/core/widgets/app_card.dart';
import 'package:intervuex_app/data/services/api_service.dart';

final flashcardsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, category) async {
  return await ApiService.instance.getFlashcards(category);
});

class FlashcardsScreen extends ConsumerStatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  ConsumerState<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends ConsumerState<FlashcardsScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isFlipped = false;
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> _masteredCards = [];
  final List<Map<String, dynamic>> _revisionCards = [];

  Offset _dragOffset = Offset.zero;
  double _dragAngle = 0.0;

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
      _dragAngle = (_dragOffset.dx / 300.0) * 0.25;
    });
  }

  void _onPanEnd(DragEndDetails details, List<Map<String, dynamic>> cards) {
    const threshold = 100.0;
    if (_dragOffset.dx > threshold) {
      _swipeCard(true, cards);
    } else if (_dragOffset.dx < -threshold) {
      _swipeCard(false, cards);
    } else {
      setState(() {
        _dragOffset = Offset.zero;
        _dragAngle = 0.0;
      });
    }
  }

  void _swipeCard(bool mastered, List<Map<String, dynamic>> cards) {
    if (_currentIndex >= cards.length) return;
    final card = cards[_currentIndex];
    if (mastered) {
      _masteredCards.add(card);
    } else {
      _revisionCards.add(card);
    }

    if (_isFlipped) {
      _flipController.reverse();
      _isFlipped = false;
    }

    setState(() {
      _dragOffset = Offset.zero;
      _dragAngle = 0.0;
      _currentIndex++;
    });
  }

  void _resetDeck() {
    setState(() {
      _currentIndex = 0;
      _masteredCards.clear();
      _revisionCards.clear();
      _isFlipped = false;
      _flipController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final cardsAsync = ref.watch(flashcardsProvider(_selectedCategory));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.style, color: primary, size: 22),
            const SizedBox(width: 8),
            const Text('Swipe Flashcards', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetDeck,
            tooltip: 'Restart Deck',
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Filter Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'System Design', 'Database & Architecture', 'Data Structures', 'Security & Web'].map((cat) {
                    final isSel = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        selected: isSel,
                        label: Text(cat, style: TextStyle(fontSize: 12, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                        selectedColor: primary.withOpacity(0.2),
                        checkmarkColor: primary,
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              _selectedCategory = cat;
                              _resetDeck();
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 12),

              cardsAsync.when(
                data: (cards) {
                  if (cards.isEmpty) {
                    return const Expanded(child: Center(child: Text('No flashcards available in this category.')));
                  }

                  if (_currentIndex >= cards.length) {
                    // Deck Completion View
                    return Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.workspace_premium, size: 54, color: AppColors.success),
                              ),
                              const SizedBox(height: 16),
                              const Text('Deck Completed!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(
                                'Swiped through all ${cards.length} flashcards.',
                                style: const TextStyle(color: AppColors.textDarkSecondary),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _statBox('Mastered', '${_masteredCards.length}', AppColors.success),
                                  const SizedBox(width: 16),
                                  _statBox('Needs Review', '${_revisionCards.length}', AppColors.danger),
                                ],
                              ),
                              const SizedBox(height: 32),
                              AppButton(
                                label: 'Restart Deck',
                                icon: Icons.replay,
                                onPressed: _resetDeck,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  final card = cards[_currentIndex];
                  final total = cards.length;

                  return Expanded(
                    child: Column(
                      children: [
                        // Progress Indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Card ${_currentIndex + 1} of $total',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDarkMuted),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.electricIndigo.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                card['category'] ?? 'General',
                                style: const TextStyle(color: AppColors.indigoLight, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Swipeable Flip Card Container
                        Expanded(
                          child: GestureDetector(
                            onPanUpdate: _onPanUpdate,
                            onPanEnd: (details) => _onPanEnd(details, cards),
                            onTap: _flipCard,
                            child: Transform.translate(
                              offset: _dragOffset,
                              child: Transform.rotate(
                                angle: _dragAngle,
                                child: Stack(
                                  children: [
                                    // Animated 3D Card
                                    AnimatedBuilder(
                                      animation: _flipAnimation,
                                      builder: (context, child) {
                                        final angle = _flipAnimation.value * pi;
                                        final isBack = angle >= (pi / 2);
                                        return Transform(
                                          transform: Matrix4.identity()
                                            ..setEntry(3, 2, 0.001)
                                            ..rotateY(angle),
                                          alignment: Alignment.center,
                                          child: isBack
                                              ? Transform(
                                                  transform: Matrix4.identity()..rotateY(pi),
                                                  alignment: Alignment.center,
                                                  child: _buildCardBack(card, isDark),
                                                )
                                              : _buildCardFront(card, isDark),
                                        );
                                      },
                                    ),

                                    // Swipe Overlay Badges
                                    if (_dragOffset.dx > 40)
                                      Positioned(
                                        top: 20,
                                        left: 20,
                                        child: Transform.rotate(
                                          angle: -0.2,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: AppColors.success, width: 3),
                                              borderRadius: BorderRadius.circular(8),
                                              color: AppColors.success.withOpacity(0.15),
                                            ),
                                            child: const Text('MASTERED', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w900, fontSize: 20)),
                                          ),
                                        ),
                                      ),

                                    if (_dragOffset.dx < -40)
                                      Positioned(
                                        top: 20,
                                        right: 20,
                                        child: Transform.rotate(
                                          angle: 0.2,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: AppColors.danger, width: 3),
                                              borderRadius: BorderRadius.circular(8),
                                              color: AppColors.danger.withOpacity(0.15),
                                            ),
                                            child: const Text('REVISE', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w900, fontSize: 20)),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Action Controls (Swipe Left / Flip / Swipe Right)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FloatingActionButton.small(
                              heroTag: 'left_btn',
                              backgroundColor: AppColors.danger.withOpacity(0.15),
                              foregroundColor: AppColors.danger,
                              elevation: 0,
                              onPressed: () => _swipeCard(false, cards),
                              child: const Icon(Icons.close),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.electricIndigo,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              onPressed: _flipCard,
                              icon: const Icon(Icons.flip, size: 18),
                              label: Text(_isFlipped ? 'Show Question' : 'Tap to Reveal Answer', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                            FloatingActionButton.small(
                              heroTag: 'right_btn',
                              backgroundColor: AppColors.success.withOpacity(0.15),
                              foregroundColor: AppColors.success,
                              elevation: 0,
                              onPressed: () => _swipeCard(true, cards),
                              child: const Icon(Icons.check),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  );
                },
                loading: () => const Expanded(child: Center(child: CircularProgressIndicator())),
                error: (e, s) => Expanded(child: Center(child: Text('Error loading flashcards: $e'))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardFront(Map<String, dynamic> card, bool isDark) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: AppCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    card['difficulty'] ?? 'Medium',
                    style: const TextStyle(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.touch_app, size: 16, color: AppColors.textDarkMuted),
                const SizedBox(width: 4),
                const Text('Tap to Flip', style: TextStyle(fontSize: 11, color: AppColors.textDarkMuted)),
              ],
            ),
            const Spacer(),
            Text(
              card['question'] ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, height: 1.35),
            ),
            const Spacer(),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: List<String>.from(card['key_concepts'] ?? []).map((kc) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.electricIndigo.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('#$kc', style: const TextStyle(fontSize: 11, color: AppColors.indigoLight, fontWeight: FontWeight.bold)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack(Map<String, dynamic> card, bool isDark) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: AppCard(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: AppColors.success, size: 18),
                  SizedBox(width: 6),
                  Text('MODEL ANSWER & FRAMEWORK', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success)),
                ],
              ),
              const Divider(height: 20),
              const Text('Core Answer Summary:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.indigoLight)),
              const SizedBox(height: 6),
              Text(
                card['answer_summary'] ?? '',
                style: const TextStyle(fontSize: 13, height: 1.4),
              ),
              if (card['star_framework'] != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.electricIndigo.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.electricIndigo.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('⭐ STAR Breakdown (Behavioral / Technical):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.indigoLight)),
                      const SizedBox(height: 4),
                      Text(card['star_framework'], style: const TextStyle(fontSize: 12, height: 1.35)),
                    ],
                  ),
                ),
              ],
              if (card['system_design_blueprint'] != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.warning.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🏗️ Production System Design Tip:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.warning)),
                      const SizedBox(height: 4),
                      Text(card['system_design_blueprint'], style: const TextStyle(fontSize: 12, height: 1.35)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _statBox(String label, String val, Color color) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(val, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
