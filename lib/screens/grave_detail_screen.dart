import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/supabase_service.dart';
import 'premium_screen.dart';

class GraveDetailScreen extends StatefulWidget {
  final Map<String, dynamic> grave;

  const GraveDetailScreen({super.key, required this.grave});

  @override
  State<GraveDetailScreen> createState() => _GraveDetailScreenState();
}

class _GraveDetailScreenState extends State<GraveDetailScreen> {
  List<Map<String, dynamic>> _comments = [];
  bool _hasReacted = false;
  bool _isLoadingComments = true;
  final _commentController = TextEditingController();

  final Map<String, String> _categoryEmojis = {
    'ex-lover': '💔',
    'toxic-friend': '🐍',
    'old-job': '💼',
    'embarrassing': '🙈',
    'regret': '😔',
    'broken-dream': '💭',
    'old-self': '👤',
    'addiction': '⛓️',
    'failure': '📉',
    'betrayal': '🗡️',
    'lost-love': '🥀',
    'other': '🔮',
  };

  @override
  void initState() {
    super.initState();
    _incrementVisitor();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _incrementVisitor() async {
    await SupabaseService.incrementVisitor(widget.grave['id']);
  }

  Future<void> _loadComments() async {
    try {
      final comments = await SupabaseService.getComments(widget.grave['id']);
      setState(() {
        _comments = comments;
        _isLoadingComments = false;
      });
    } catch (e) {
      setState(() => _isLoadingComments = false);
    }
  }

  Future<void> _addReaction(String type) async {
    if (_hasReacted) return;

    final canReact = await SupabaseService.canReact();
    if (!canReact) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔒 Daily reaction limit reached. Upgrade to Premium!'),
            backgroundColor: Color(0xFFC9A962),
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PremiumScreen()),
        );
      }
      return;
    }

    final userId = SupabaseService.effectiveUserId;
    if (userId == null) return;

    final success = await SupabaseService.addReaction(
      userId,
      widget.grave['id'],
      type,
    );

    if (success) {
      setState(() {
        _hasReacted = true;
        if (type == 'respect') {
          widget.grave['respect_count'] = (widget.grave['respect_count'] ?? 0) + 1;
        } else if (type == 'flower') {
          widget.grave['flower_count'] = (widget.grave['flower_count'] ?? 0) + 1;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              type == 'respect' ? '🕯️ Respect paid' : '💐 Flowers left',
            ),
            backgroundColor: const Color(0xFF8B5CF6),
          ),
        );
      }
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final canComment = await SupabaseService.canComment();
    if (!canComment) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔒 Daily comment limit reached. Upgrade to Premium!'),
            backgroundColor: Color(0xFFC9A962),
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PremiumScreen()),
        );
      }
      return;
    }

    final userId = SupabaseService.effectiveUserId;
    if (userId == null) return;

    await SupabaseService.addComment(
      visitorId: userId,
      graveId: widget.grave['id'],
      content: _commentController.text.trim(),
    );

    _commentController.clear();
    await _loadComments();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('💬 Comment added'),
          backgroundColor: Color(0xFF8B5CF6),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.grave['category'] ?? 'other';
    final emoji = _categoryEmojis[category] ?? '🪦';
    final tombstoneStyle = widget.grave['tombstone_style'] ?? 'classic';
    final isPremiumGrave = [
      'diamond', 'fire', 'star', 'crown', 'skull',
      'rose', 'ghost', 'crystal', 'butterfly', 'dove', 'infinity', 'heart'
    ].contains(tombstoneStyle);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0A0F), Color(0xFF12121A), Color(0xFF0A0A0F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF12121A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF8B5CF6).withOpacity(0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (isPremiumGrave)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC9A962),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Text('👑', style: TextStyle(fontSize: 12)),
                            SizedBox(width: 4),
                            Text(
                              'PREMIUM',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Tombstone
                      Container(
                        width: 180,
                        height: 220,
                        decoration: BoxDecoration(
                          gradient: isPremiumGrave
                              ? const LinearGradient(
                                  colors: [Color(0xFF2A2A3A), Color(0xFF1E1E2E)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                )
                              : const LinearGradient(
                                  colors: [Color(0xFF1E1E2E), Color(0xFF12121A)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(90),
                            topRight: Radius.circular(90),
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                          border: Border.all(
                            color: isPremiumGrave
                                ? const Color(0xFFC9A962).withOpacity(0.6)
                                : const Color(0xFF8B5CF6).withOpacity(0.4),
                            width: isPremiumGrave ? 3 : 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isPremiumGrave
                                  ? const Color(0xFFC9A962).withOpacity(0.3)
                                  : const Color(0xFF8B5CF6).withOpacity(0.2),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(emoji, style: const TextStyle(fontSize: 50)),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: isPremiumGrave
                                    ? const LinearGradient(
                                        colors: [Color(0xFFC9A962), Color(0xFF8B5CF6)],
                                      )
                                    : const LinearGradient(
                                        colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                                      ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'R.I.P',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (widget.grave['year_start'] != null ||
                                widget.grave['year_end'] != null)
                              Text(
                                '${widget.grave['year_start'] ?? '?'} - ${widget.grave['year_end'] ?? '?'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[400],
                                ),
                              ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 800.ms).scale(
                            begin: const Offset(0.8, 0.8),
                            curve: Curves.easeOutBack,
                          ),

                      const SizedBox(height: 24),

                      // Title
                      Text(
                        widget.grave['title'] ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isPremiumGrave
                              ? const Color(0xFFC9A962)
                              : Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: 20),

                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStat('🕯️', widget.grave['respect_count'] ?? 0, 'Respects'),
                          const SizedBox(width: 24),
                          _buildStat('💐', widget.grave['flower_count'] ?? 0, 'Flowers'),
                          const SizedBox(width: 24),
                          _buildStat('👁️', widget.grave['visitor_count'] ?? 0, 'Visitors'),
                        ],
                      ).animate().fadeIn(delay: 300.ms),

                      const SizedBox(height: 24),

                      // Reaction Buttons
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _hasReacted ? null : () => _addReaction('respect'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: _hasReacted
                                      ? const Color(0xFF1E1E2E)
                                      : const Color(0xFF12121A),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFF8B5CF6).withOpacity(0.4),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('🕯️', style: TextStyle(fontSize: 20)),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Pay Respect',
                                      style: TextStyle(
                                        color: _hasReacted ? Colors.grey : Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: _hasReacted ? null : () => _addReaction('flower'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: _hasReacted
                                      ? const Color(0xFF1E1E2E)
                                      : const Color(0xFF12121A),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFC9A962).withOpacity(0.4),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('💐', style: TextStyle(fontSize: 20)),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Leave Flowers',
                                      style: TextStyle(
                                        color: _hasReacted ? Colors.grey : Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 400.ms),

                      const SizedBox(height: 24),

                      // Story
                      if (widget.grave['story'] != null &&
                          widget.grave['story'].toString().isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF12121A),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF8B5CF6).withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('📜', style: TextStyle(fontSize: 18)),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'The Story',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Divider(color: Colors.grey.withOpacity(0.3)),
                              const SizedBox(height: 12),
                              Text(
                                widget.grave['story'],
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontSize: 15,
                                  height: 1.6,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Divider(color: Colors.grey.withOpacity(0.3)),
                              const SizedBox(height: 8),
                              const Center(
                                child: Text(
                                  '🕊️ Rest in Peace 🕊️',
                                  style: TextStyle(
                                    color: Color(0xFF8B5CF6),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 500.ms),

                      const SizedBox(height: 24),

                      // Comments Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF12121A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF8B5CF6).withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('💬', style: TextStyle(fontSize: 18)),
                                const SizedBox(width: 8),
                                const Text(
                                  'Condolences',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${_comments.length}',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Comment Input
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _commentController,
                                    maxLength: 300,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      hintText: 'Leave a message...',
                                      hintStyle: TextStyle(color: Colors.grey[600]),
                                      counterText: '',
                                      filled: true,
                                      fillColor: const Color(0xFF1E1E2E),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: _addComment,
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.send,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Comments List
                            if (_isLoadingComments)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF8B5CF6),
                                  ),
                                ),
                              )
                            else if (_comments.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Text(
                                    'No messages yet. Be the first.',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              )
                            else
                              ...List.generate(_comments.length, (index) {
                                final comment = _comments[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E1E2E),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text('👻', style: TextStyle(fontSize: 14)),
                                          const SizedBox(width: 6),
                                          Text(
                                            comment['anonymous_name'] ?? 'Anonymous',
                                            style: const TextStyle(
                                              color: Color(0xFF8B5CF6),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        comment['content'] ?? '',
                                        style: TextStyle(
                                          color: Colors.grey[300],
                                          fontSize: 14,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                          ],
                        ),
                      ).animate().fadeIn(delay: 600.ms),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String emoji, int count, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
