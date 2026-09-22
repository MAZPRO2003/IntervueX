import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intervuex_app/core/theme/app_colors.dart';
import 'package:intervuex_app/data/services/api_service.dart';
import 'package:intervuex_app/presentation/providers/pack_provider.dart';

class AiCoachScreen extends ConsumerStatefulWidget {
  const AiCoachScreen({super.key});

  @override
  ConsumerState<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends ConsumerState<AiCoachScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  final List<_ChatMessage> _messages = [];
  bool _isThinking = false;

  // Preset coaching prompts
  static const List<Map<String, String>> _quickPrompts = [
    {
      'label': '💡 Explain SOLID Principles',
      'prompt':
          'Explain the SOLID principles with real-world coding examples I can use in a technical interview.',
    },
    {
      'label': '🔥 System Design Tips',
      'prompt':
          'What are the key things to cover when answering a system design question in a senior software engineer interview?',
    },
    {
      'label': '🎯 Tell Me About Yourself',
      'prompt':
          'How should I structure my "Tell me about yourself" answer for a software engineering interview? Give me a strong template.',
    },
    {
      'label': '⚡ SQL Join Types',
      'prompt':
          'Explain the difference between INNER JOIN, LEFT JOIN, RIGHT JOIN and FULL OUTER JOIN with clear examples.',
    },
    {
      'label': '🧠 Dynamic Programming',
      'prompt':
          'How do I recognize when to use Dynamic Programming in a coding interview? Give me patterns and examples.',
    },
    {
      'label': '🤝 Behavioral Questions',
      'prompt':
          'Give me the STAR method template and 3 strong example answers for common behavioral interview questions.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    _messages.add(const _ChatMessage(
      text:
          "Hi! I'm your **IntervueX AI Coach** 🎯\n\nI can help you:\n• Understand complex technical concepts\n• Practice answering interview questions\n• Get coaching on system design\n• Prepare for behavioral rounds\n\nAsk me anything, or tap a quick prompt below!",
      isAi: true,
    ));
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: text.trim(), isAi: false));
      _isThinking = true;
      _msgCtrl.clear();
    });
    _scrollToBottom();

    try {
      // Use the active pack context if available
      final packId = ref.read(activePackIdProvider) ?? '';
      final activePackAsync = ref.read(activePackProvider);
      String packContext = '';
      activePackAsync.whenData((pack) {
        if (pack != null) {
          packContext = ' (Context: ${pack.company} ${pack.role} interview)';
        }
      });

      final result = await ApiService.instance.askAiCoach(
        question: text.trim() + packContext,
        packId: packId,
      );
      setState(() {
        _messages.add(_ChatMessage(
          text: result['answer'] as String? ??
              'I couldn\'t generate a response. Please try again.',
          isAi: true,
        ));
        _isThinking = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(const _ChatMessage(
          text:
              'Sorry, I encountered an error. Please check your connection and try again.',
          isAi: true,
          isError: true,
        ));
        _isThinking = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [primary, secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Coach',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        height: 1.2)),
                Text('IntervueX Intelligence',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textDarkMuted,
                        fontWeight: FontWeight.w500,
                        height: 1.2)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: 'New Conversation',
            onPressed: () {
              setState(() {
                _messages.clear();
                _addWelcomeMessage();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length + (_isThinking ? 1 : 0),
              itemBuilder: (context, idx) {
                if (_isThinking && idx == _messages.length) {
                  return _buildThinkingBubble(primary);
                }
                return _buildMessageBubble(_messages[idx], isDark, primary, secondary);
              },
            ),
          ),

          // Quick prompts
          if (_messages.length <= 2) ...[
            Container(
              height: 44,
              padding: const EdgeInsets.only(left: 12, bottom: 4),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _quickPrompts.length,
                itemBuilder: (context, i) {
                  final p = _quickPrompts[i];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(p['label']!,
                          style: TextStyle(
                              fontSize: 12,
                              color: primary,
                              fontWeight: FontWeight.w600)),
                      backgroundColor: primary.withOpacity(0.08),
                      side: BorderSide(color: primary.withOpacity(0.3)),
                      onPressed: () => _sendMessage(p['prompt']!),
                    ),
                  );
                },
              ),
            ),
          ],

          // Input bar
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              border: Border(
                  top: BorderSide(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    maxLines: 3,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (val) => _sendMessage(val),
                    decoration: InputDecoration(
                      hintText: 'Ask your AI coach anything...',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFCBD5E1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFCBD5E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: primary, width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _sendMessage(_msgCtrl.text),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primary, secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
      _ChatMessage msg, bool isDark, Color primary, Color secondary) {
    final isAi = msg.isAi;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isAi) ...[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [primary, secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isAi
                    ? (isDark
                        ? AppColors.surfaceDarkElevated
                        : const Color(0xFFF1F5F9))
                    : primary.withOpacity(0.15),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isAi ? 4 : 16),
                  topRight: Radius.circular(isAi ? 16 : 4),
                  bottomLeft: const Radius.circular(16),
                  bottomRight: const Radius.circular(16),
                ),
                border: isAi
                    ? null
                    : Border.all(color: primary.withOpacity(0.3)),
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: msg.isError
                      ? AppColors.danger
                      : (isDark
                          ? AppColors.textDarkPrimary
                          : AppColors.textLightPrimary),
                ),
              ),
            ),
          ),
          if (!isAi) ...[
            const SizedBox(width: 10),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceDarkElevated
                    : const Color(0xFFE2E8F0),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person_rounded,
                  size: 18,
                  color:
                      isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildThinkingBubble(Color primary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [primary, primary.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primary.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dot(primary, 0),
                const SizedBox(width: 4),
                _dot(primary, 150),
                const SizedBox(width: 4),
                _dot(primary, 300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color, int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      builder: (_, val, _) => Opacity(
        opacity: val,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isAi;
  final bool isError;

  const _ChatMessage({
    required this.text,
    required this.isAi,
    this.isError = false,
  });
}
