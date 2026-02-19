import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/chef.dart';
import '../models/chef_config.dart';
import '../models/ingredient.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../services/gemini_service.dart';
import '../services/ingredient_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// AI 셰프 채팅 화면
class ChatScreen extends StatefulWidget {
  final String? initialMessage;

  const ChatScreen({super.key, this.initialMessage});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AuthService _authService = AuthService();
  final IngredientService _ingredientService = IngredientService();
  final ChatService _chatService = ChatService();

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  Chef _currentChef = Chefs.defaultChef;
  List<Ingredient> _ingredients = [];
  GeminiService? _geminiService;
  bool _hasHistory = false;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initChat() async {
    try {
      _geminiService = GeminiService();
    } catch (_) {
      // API 키 미설정 시 무시
    }

    await _loadChefAndIngredients();
    await _loadChatHistory();

    if (!_hasHistory) {
      _addGreeting();
    }

    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      _sendMessage(widget.initialMessage!);
    }
  }

  Future<void> _loadChefAndIngredients() async {
    try {
      final profile = await _authService.getUserProfile();
      final chefId = profile?['primary_chef_id'] ?? 'baek';
      final chef = Chefs.findById(chefId) ?? Chefs.defaultChef;

      final ingredients = await _ingredientService.getIngredients();

      if (mounted) {
        setState(() {
          _currentChef = chef;
          _ingredients = ingredients;
        });
      }
    } catch (_) {
      // 로드 실패 시 기본값 유지
    }
  }

  Future<void> _loadChatHistory() async {
    try {
      final history = await _chatService.getChatHistory(
        chefId: _currentChef.id,
      );
      if (history.isNotEmpty && mounted) {
        setState(() {
          _messages.addAll(history);
          _hasHistory = true;
        });
        _scrollToBottom();
      }
    } catch (_) {
      // 기록 로드 실패 시 무시
    }
  }

  void _addGreeting() {
    final greeting = ChatMessage(
      role: MessageRole.assistant,
      content: '${_currentChef.emoji} ${_currentChef.randomGreeting}',
    );

    setState(() {
      _messages.add(greeting);
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    final userMessage = ChatMessage(
      role: MessageRole.user,
      content: text.trim(),
      chefId: _currentChef.id,
    );

    final loadingMessage = ChatMessage(
      role: MessageRole.assistant,
      content: '',
      isLoading: true,
    );

    setState(() {
      _messages.add(userMessage);
      _messages.add(loadingMessage);
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      if (_geminiService == null) {
        throw Exception('API 키가 설정되지 않았습니다.');
      }

      final ingredientNames = _ingredients.map((i) => i.name).toList();

      final chefConfig = AIChefConfig(
        name: _currentChef.name,
        expertise: _currentChef.specialties,
        cookingPhilosophy: _currentChef.philosophy,
      );

      final response = await _geminiService!.sendMessage(
        message: text.trim(),
        chefConfig: chefConfig,
        ingredients: ingredientNames,
      );

      if (mounted) {
        final assistantMessage = ChatMessage(
          role: MessageRole.assistant,
          content: response,
          chefId: _currentChef.id,
        );

        setState(() {
          final loadingIndex = _messages.indexWhere((m) => m.isLoading);
          if (loadingIndex != -1) {
            _messages[loadingIndex] = assistantMessage;
          }
          _isLoading = false;
        });

        _saveToDB(userMessage, assistantMessage);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          final loadingIndex = _messages.indexWhere((m) => m.isLoading);
          if (loadingIndex != -1) {
            _messages[loadingIndex] = _messages[loadingIndex].copyWith(
              content: '죄송해요, 응답을 생성하지 못했어요. 다시 시도해 주세요.',
              isLoading: false,
            );
          }
          _isLoading = false;
        });
      }
    }

    _scrollToBottom();
  }

  Future<void> _saveToDB(ChatMessage user, ChatMessage assistant) async {
    try {
      await _chatService.saveMessages([user, assistant]);
    } catch (_) {
      // 저장 실패 시 무시
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chefColor = Color(_currentChef.primaryColor);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: chefColor.withValues(alpha: 0.1),
              child: Text(
                _currentChef.emoji,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentChef.name,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _currentChef.title,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: chefColor.withValues(alpha: 0.05),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.role == MessageRole.user;
    final chefColor = Color(_currentChef.primaryColor);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: chefColor.withValues(alpha: 0.1),
              child: Text(
                _currentChef.emoji,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isUser ? chefColor : AppColors.surfaceDim,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppRadius.lg),
                  topRight: const Radius.circular(AppRadius.lg),
                  bottomLeft: Radius.circular(isUser ? AppRadius.lg : 4),
                  bottomRight: Radius.circular(isUser ? 4 : AppRadius.lg),
                ),
              ),
              child: message.isLoading
                  ? _buildLoadingIndicator()
                  : Text(
                      message.content,
                      style: TextStyle(
                        color:
                            isUser ? Colors.white : AppColors.textPrimary,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
          if (isUser) const SizedBox(width: AppSpacing.sm),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const SizedBox(
      width: 40,
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _DotIndicator(delay: 0),
          SizedBox(width: 4),
          _DotIndicator(delay: 200),
          SizedBox(width: 4),
          _DotIndicator(delay: 400),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.sm,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: '${_currentChef.name}에게 물어보세요...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.inputFill,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: 10,
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (value) {
                _sendMessage(value);
                _textController.clear();
              },
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            onPressed: _isLoading
                ? null
                : () {
                    _sendMessage(_textController.text);
                    _textController.clear();
                  },
            icon: Icon(
              Icons.send_rounded,
              color: _isLoading ? AppColors.textTertiary : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 로딩 점 애니메이션
class _DotIndicator extends StatefulWidget {
  final int delay;

  const _DotIndicator({required this.delay});

  @override
  State<_DotIndicator> createState() => _DotIndicatorState();
}

class _DotIndicatorState extends State<_DotIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -4 * _animation.value),
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.textTertiary,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
