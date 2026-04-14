import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import '../services/supabase_service.dart';

class BuryScreen extends StatefulWidget {
  const BuryScreen({super.key});

  @override
  State<BuryScreen> createState() => _BuryScreenState();
}

class _BuryScreenState extends State<BuryScreen> with TickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _storyController = TextEditingController();
  final _yearStartController = TextEditingController();
  final _yearEndController = TextEditingController();

  String _selectedCategory = 'ex-lover';
  String _selectedTombstone = 'classic';
  bool _isLoading = false;
  bool _showBuryAnimation = false;

  final List<Map<String, String>> _categories = [
    {'id': 'ex-lover', 'emoji': '💔', 'label': 'Ex-Lover'},
    {'id': 'toxic-friend', 'emoji': '🐍', 'label': 'Toxic Friend'},
    {'id': 'old-job', 'emoji': '💼', 'label': 'Old Job'},
    {'id': 'embarrassing', 'emoji': '🙈', 'label': 'Cringe'},
    {'id': 'regret', 'emoji': '😔', 'label': 'Regret'},
    {'id': 'broken-dream', 'emoji': '💭', 'label': 'Dreams'},
    {'id': 'old-self', 'emoji': '👤', 'label': 'Old Self'},
    {'id': 'addiction', 'emoji': '⛓️', 'label': 'Addiction'},
    {'id': 'failure', 'emoji': '📉', 'label': 'Failure'},
    {'id': 'betrayal', 'emoji': '🗡️', 'label': 'Betrayal'},
    {'id': 'lost-love', 'emoji': '🥀', 'label': 'Lost Love'},
    {'id': 'other', 'emoji': '🔮', 'label': 'Other'},
  ];

  final List<Map<String, dynamic>> _tombstones = [
    {'id': 'classic', 'emoji': '🪦', 'label': 'Classic', 'premium': false},
    {'id': 'gothic', 'emoji': '⚰️', 'label': 'Gothic', 'premium': false},
    {'id': 'angel', 'emoji': '👼', 'label': 'Angel', 'premium': false},
    {'id': 'moon', 'emoji': '🌙', 'label': 'Moon', 'premium': false},
    {'id': 'diamond', 'emoji': '💎', 'label': 'Diamond', 'premium': true},
    {'id': 'fire', 'emoji': '🔥', 'label': 'Fire', 'premium': true},
    {'id': 'star', 'emoji': '⭐', 'label': 'Star', 'premium': true},
    {'id': 'crown', 'emoji': '👑', 'label': 'Crown', 'premium': true},
    {'id': 'skull', 'emoji': '💀', 'label': 'Skull', 'premium': true},
    {'id': 'rose', 'emoji': '🌹', 'label': 'Rose', 'premium': true},
    {'id': 'ghost', 'emoji': '👻', 'label': 'Ghost', 'premium': true},
    {'id': 'crystal', 'emoji': '🔮', 'label': 'Crystal', 'premium': true},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _storyController.dispose();
    _yearStartController.dispose();
    _yearEndController.dispose();
    super.dispose();
  }

  Future<void> _buryIt() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please give your burial a title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final userId = SupabaseService.effectiveUserId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check grave limit
    final canCreate = await SupabaseService.canCreateGrave();
    if (!canCreate) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔒 Grave limit reached. Upgrade to Premium!'),
            backgroundColor: Color(0xFFC9A962),
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      await SupabaseService.createGrave(
        userId: userId,
        title: _titleController.text.trim(),
        story: _storyController.text.trim(),
        category: _selectedCategory,
        tombstoneStyle: _selectedTombstone,
        yearStart: _yearStartController.text.isNotEmpty
            ? int.tryParse(_yearStartController.text)
            : null,
        yearEnd: _yearEndController.text.isNotEmpty
            ? int.tryParse(_yearEndController.text)
            : null,
      );

      setState(() {
        _isLoading = false;
        _showBuryAnimation = true;
      });

      // Vibration feedback
      HapticFeedback.heavyImpact();

      // Wait for animation then reset
      await Future.delayed(const Duration(milliseconds: 3500));

      if (mounted) {
        setState(() => _showBuryAnimation = false);

        // Clear form
        _titleController.clear();
        _storyController.clear();
        _yearStartController.clear();
        _yearEndController.clear();
        setState(() {
          _selectedCategory = 'ex-lover';
          _selectedTombstone = 'classic';
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Row(
                    children: [
                      Text('⚰️', style: TextStyle(fontSize: 28)),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bury Your Past',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Let go and find peace',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ).animate().fadeIn().slideX(begin: -0.2),

                  const SizedBox(height: 24),

                  // Title Input
                  _buildLabel('What are you burying?'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    maxLength: 50,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('e.g., My ex, Old job, That embarrassing moment...'),
                  ),

                  const SizedBox(height: 16),

                  // Category Selection
                  _buildLabel('Category'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat['id'];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat['id']!),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF8B5CF6)
                                : const Color(0xFF12121A),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF8B5CF6)
                                  : Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(cat['emoji']!, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                cat['label']!,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey,
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Years
                  _buildLabel('Timeline (optional)'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _yearStartController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Start year'),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('→', style: TextStyle(color: Colors.grey, fontSize: 20)),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _yearEndController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('End year'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Story
                  _buildLabel('Your story (optional)'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _storyController,
                    maxLines: 4,
                    maxLength: 500,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Share why you\'re letting this go...'),
                  ),

                  const SizedBox(height: 16),

                  // Tombstone Selection
                  _buildLabel('Tombstone Style'),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _tombstones.length,
                      itemBuilder: (context, index) {
                        final tomb = _tombstones[index];
                        final isSelected = _selectedTombstone == tomb['id'];
                        final isPremium = tomb['premium'] as bool;
                        final userIsPremium = SupabaseService.isPremium;

                        return GestureDetector(
                          onTap: () {
                            if (isPremium && !userIsPremium) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('👑 Premium tombstone! Upgrade to unlock.'),
                                  backgroundColor: Color(0xFFC9A962),
                                ),
                              );
                              return;
                            }
                            setState(() => _selectedTombstone = tomb['id']);
                          },
                          child: Container(
                            width: 70,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF8B5CF6).withOpacity(0.3)
                                  : const Color(0xFF12121A),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF8B5CF6)
                                    : isPremium
                                        ? const Color(0xFFC9A962).withOpacity(0.5)
                                        : Colors.grey.withOpacity(0.3),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(tomb['emoji'], style: const TextStyle(fontSize: 24)),
                                      const SizedBox(height: 4),
                                      Text(
                                        tomb['label'],
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : Colors.grey,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isPremium)
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFC9A962),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text('👑', style: TextStyle(fontSize: 8)),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Bury Button
                  GestureDetector(
                    onTap: _isLoading ? null : _buryIt,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFFC9A962)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('⚰️', style: TextStyle(fontSize: 20)),
                                  SizedBox(width: 10),
                                  Text(
                                    'BURY IT',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95)),

                  const SizedBox(height: 16),

                  // Info Box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12121A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFC9A962).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text('⏳', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Your burial will be reviewed before appearing in the graveyard. This helps keep our community safe.',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // Bury Animation Overlay
          if (_showBuryAnimation) _buildBuryAnimation(),
        ],
      ),
    );
  }

  Widget _buildBuryAnimation() {
    final categoryEmoji = _categories.firstWhere(
      (c) => c['id'] == _selectedCategory,
      orElse: () => {'emoji': '🪦'},
    )['emoji']!;

    return Container(
      color: Colors.black.withOpacity(0.95),
      child: Stack(
        children: [
          // Dirt particles falling
          ...List.generate(30, (index) {
            final random = Random();
            final startX = random.nextDouble() * MediaQuery.of(context).size.width;
            final delay = random.nextInt(1500);
            final size = 4.0 + random.nextDouble() * 8;

            return Positioned(
              left: startX,
              top: -50,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Color.lerp(
                    const Color(0xFF4A3728),
                    const Color(0xFF2D1F14),
                    random.nextDouble(),
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              )
                  .animate(onPlay: (c) => c.repeat())
                  .moveY(
                    begin: 0,
                    end: MediaQuery.of(context).size.height + 100,
                    duration: Duration(milliseconds: 2000 + random.nextInt(1000)),
                    delay: Duration(milliseconds: delay),
                  )
                  .fadeOut(delay: 1500.ms),
            );
          }),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tombstone dropping
                Container(
                  width: 150,
                  height: 190,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2A2A3A), Color(0xFF1A1A24)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(75),
                      topRight: Radius.circular(75),
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    border: Border.all(
                      color: const Color(0xFF8B5CF6).withOpacity(0.6),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(categoryEmoji, style: const TextStyle(fontSize: 50)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFFC9A962)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'R.I.P',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .moveY(begin: -300, end: 0, duration: 800.ms, curve: Curves.bounceOut)
                    .then()
                    .shimmer(duration: 1000.ms, color: Colors.white24),

                const SizedBox(height: 30),

                // Title
                Text(
                  _titleController.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3),

                const SizedBox(height: 20),

                // REST IN PEACE text
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFFC9A962), Color(0xFF8B5CF6)],
                  ).createShader(bounds),
                  child: const Text(
                    '🕊️ REST IN PEACE 🕊️',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3,
                    ),
                  ),
                ).animate().fadeIn(delay: 1200.ms).scale(begin: const Offset(0.8, 0.8)),

                const SizedBox(height: 30),

                // Success message
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF12121A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('✅', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'Buried successfully!\nAwaiting approval.',
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 1800.ms).slideY(begin: 0.3),
              ],
            ),
          ),

          // Close hint
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Closing automatically...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ).animate().fadeIn(delay: 2500.ms),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
      counterStyle: TextStyle(color: Colors.grey[600]),
      filled: true,
      fillColor: const Color(0xFF12121A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: const Color(0xFF8B5CF6).withOpacity(0.2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF8B5CF6),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
