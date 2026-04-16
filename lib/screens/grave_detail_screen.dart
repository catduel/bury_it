import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/supabase_service.dart';

class GraveDetailScreen extends StatefulWidget {
  final Map<String, dynamic> grave;

  const GraveDetailScreen({super.key, required this.grave});

  @override
  State<GraveDetailScreen> createState() => _GraveDetailScreenState();
}

class _GraveDetailScreenState extends State<GraveDetailScreen> {
  late Map<String, dynamic> _grave;
  List<Map<String, dynamic>> _comments = [];
  bool _isLoadingComments = true;
  bool _hasRespected = false;
  bool _hasFlowered = false;
  bool _isReacting = false;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _grave = Map<String, dynamic>.from(widget.grave);
    _trackVisit();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _trackVisit() async {
    await SupabaseService.incrementVisitor(_grave['id']);
    setState(() {
      _grave['visitor_count'] = (_grave['visitor_count'] ?? 0) + 1;
    });
  }

  Future<void> _loadComments() async {
    try {
      final comments = await SupabaseService.getComments(_grave['id']);
      setState(() {
        _comments = comments;
        _isLoadingComments = false;
      });
    } catch (e) {
      setState(() => _isLoadingComments = false);
    }
  }

  Future<void> _addReaction(String type) async {
    if (_isReacting) return;
    if (type == 'respect' && _hasRespected) {
      _showSnackBar('You already paid respect', Colors.orange);
      return;
    }
    if (type == 'flower' && _hasFlowered) {
      _showSnackBar('You already sent flowers', Colors.orange);
      return;
    }

    final userId = SupabaseService.effectiveUserId;
    if (userId == null) {
      _showSnackBar('Please sign in to react', Colors.red);
      return;
    }

    final canReact = await SupabaseService.canReact();
    if (!canReact) {
      _showSnackBar('Daily reaction limit reached. Upgrade to Premium!', const Color(0xFFC9A962));
      return;
    }

    setState(() => _isReacting = true);
    
    final success = await SupabaseService.addReaction(userId, _grave['id'], type);
    
    setState(() => _isReacting = false);
    
    if (success) {
      HapticFeedback.mediumImpact();
      setState(() {
        if (type == 'respect') {
          _hasRespected = true;
          _grave['respect_count'] = (_grave['respect_count'] ?? 0) + 1;
        } else {
          _hasFlowered = true;
          _grave['flower_count'] = (_grave['flower_count'] ?? 0) + 1;
        }
      });
      _showSnackBar(
        type == 'respect' ? 'Respect paid' : 'Flowers sent',
        const Color(0xFF8B5CF6),
      );
    } else {
      _showSnackBar('Already reacted to this grave', Colors.orange);
    }
  }

  Future<void> _addComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final userId = SupabaseService.effectiveUserId;
    if (userId == null) {
      _showSnackBar('Please sign in to comment', Colors.red);
      return;
    }

    final canComment = await SupabaseService.canComment();
    if (!canComment) {
      _showSnackBar('Daily comment limit reached. Upgrade to Premium!', const Color(0xFFC9A962));
      return;
    }

    final success = await SupabaseService.addComment(
      visitorId: userId,
      graveId: _grave['id'],
      content: content,
    );

    if (success) {
      _commentController.clear();
      FocusScope.of(context).unfocus();
      _loadComments();
      _showSnackBar('Comment added', const Color(0xFF8B5CF6));
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = _grave['category'] ?? 'other';
    final tombstoneStyle = _grave['tombstone_style'] ?? 'classic';
    final isPremiumGrave = ['diamond', 'fire', 'star', 'crown', 'skull', 'rose', 'ghost', 'crystal'].contains(tombstoneStyle);

    final categoryEmojis = {
      'ex-lover': '💔', 'toxic-friend': '🐍', 'old-job': '💼', 'embarrassing': '🙈',
      'regret': '😔', 'broken-dream': '💭', 'old-self': '👤', 'addiction': '⛓️',
      'failure': '📉', 'betrayal': '🗡️', 'lost-love': '🥀', 'other': '🔮',
    };

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f0f23)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.visibility, color: Color(0xFFa78bfa), size: 16),
                          const SizedBox(width: 6),
                          Text('${_grave['visitor_count'] ?? 0}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Tombstone
                      Container(
                        width: 170,
                        height: 210,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isPremiumGrave 
                                ? [const Color(0xFF4a3f6b), const Color(0xFF2d2a4a)]
                                : [const Color(0xFF3d3a5c), const Color(0xFF252340)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(85),
                            topRight: Radius.circular(85),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                          border: Border.all(
                            color: isPremiumGrave ? const Color(0xFFd4a853) : const Color(0xFFa78bfa),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isPremiumGrave ? const Color(0xFFd4a853) : const Color(0xFFa78bfa)).withOpacity(0.4),
                              blurRadius: 25,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(categoryEmojis[category] ?? '🪦', style: const TextStyle(fontSize: 55)),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isPremiumGrave
                                      ? [const Color(0xFFd4a853), const Color(0xFFb8942e)]
                                      : [const Color(0xFFa78bfa), const Color(0xFF8b5cf6)],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text('R.I.P', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 4)),
                            ),
                          ],
                        ),
                      ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),

                      const SizedBox(height: 28),

                      // Title
                      Text(
                        _grave['title'] ?? 'Unknown',
                        style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: 8),

                      // Years
                      if (_grave['year_start'] != null || _grave['year_end'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_grave['year_start'] ?? '?'} - ${_grave['year_end'] ?? '?'}',
                            style: TextStyle(color: Colors.grey[300], fontSize: 14),
                          ),
                        ).animate().fadeIn(delay: 300.ms),

                      const SizedBox(height: 20),

                      // Story
                      if (_grave['story'] != null && _grave['story'].toString().isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.04)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.auto_stories, color: const Color(0xFFa78bfa), size: 20),
                                  const SizedBox(width: 10),
                                  const Text('The Story', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _grave['story'],
                                style: TextStyle(color: Colors.grey[300], fontSize: 14, height: 1.6),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 400.ms),

                      const SizedBox(height: 24),

                      // Reactions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildReactionButton(
                            icon: Icons.local_fire_department,
                            label: 'Respect',
                            count: _grave['respect_count'] ?? 0,
                            isActive: _hasRespected,
                            color: const Color(0xFFf97316),
                            onTap: () => _addReaction('respect'),
                          ),
                          const SizedBox(width: 16),
                          _buildReactionButton(
                            icon: Icons.local_florist,
                            label: 'Flowers',
                            count: _grave['flower_count'] ?? 0,
                            isActive: _hasFlowered,
                            color: const Color(0xFFec4899),
                            onTap: () => _addReaction('flower'),
                          ),
                        ],
                      ).animate().fadeIn(delay: 500.ms),

                      const SizedBox(height: 28),

                      // Comments Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.04)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.chat_bubble_outline, color: Color(0xFFa78bfa), size: 20),
                                const SizedBox(width: 10),
                                const Text('Condolences', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFa78bfa).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text('${_comments.length}', style: const TextStyle(color: Color(0xFFa78bfa), fontSize: 12, fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Add Comment
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _commentController,
                                      style: const TextStyle(color: Colors.white, fontSize: 14),
                                      decoration: InputDecoration(
                                        hintText: 'Leave a message...',
                                        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _addComment,
                                    child: Container(
                                      margin: const EdgeInsets.all(6),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: [Color(0xFFa78bfa), Color(0xFF8b5cf6)]),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Comments List
                            if (_isLoadingComments)
                              const Center(child: Padding(
                                padding: EdgeInsets.all(24),
                                child: CircularProgressIndicator(color: Color(0xFFa78bfa)),
                              ))
                            else if (_comments.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    children: [
                                      Icon(Icons.chat_bubble_outline, color: Colors.grey[600], size: 36),
                                      const SizedBox(height: 10),
                                      Text('No messages yet', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                                      Text('Be the first to leave a message', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ...List.generate(
                                _comments.length > 10 ? 10 : _comments.length,
                                (index) {
                                  final comment = _comments[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 28,
                                              height: 28,
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(colors: [Color(0xFFa78bfa), Color(0xFF8b5cf6)]),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(Icons.person, color: Colors.white, size: 16),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              comment['display_name'] ?? comment['anonymous_name'] ?? 'Anonymous',
                                              style: const TextStyle(color: Color(0xFFa78bfa), fontSize: 13, fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          comment['content'] ?? '',
                                          style: TextStyle(color: Colors.grey[300], fontSize: 13, height: 1.4),
                                        ),
                                      ],
                                    ),
                                  ).animate().fadeIn(delay: (80 * index).ms);
                                },
                              ),
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

  Widget _buildReactionButton({
    required IconData icon,
    required String label,
    required int count,
    required bool isActive,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _isReacting ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        decoration: BoxDecoration(
          gradient: isActive 
              ? LinearGradient(colors: [color.withOpacity(0.3), color.withOpacity(0.1)])
              : null,
          color: isActive ? null : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? color : Colors.white.withOpacity(0.15),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 34, color: isActive ? color : Colors.grey[400]),
            const SizedBox(height: 6),
            Text(
              '$count',
              style: TextStyle(
                color: isActive ? color : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: isActive ? color : Colors.grey[500],
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
