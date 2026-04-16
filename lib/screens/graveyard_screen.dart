import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/supabase_service.dart';
import 'grave_detail_screen.dart';

class GraveyardScreen extends StatefulWidget {
  const GraveyardScreen({super.key});

  @override
  State<GraveyardScreen> createState() => _GraveyardScreenState();
}

class _GraveyardScreenState extends State<GraveyardScreen> {
  List<Map<String, dynamic>> _graves = [];
  bool _isLoading = true;
  String _selectedCategory = 'all';
  String _sortBy = 'newest';

  final List<Map<String, String>> _categories = [
    {'id': 'all', 'name': 'All', 'emoji': '🪦'},
    {'id': 'ex-lover', 'name': 'Ex-Lover', 'emoji': '💔'},
    {'id': 'toxic-friend', 'name': 'Toxic Friend', 'emoji': '🐍'},
    {'id': 'old-job', 'name': 'Old Job', 'emoji': '💼'},
    {'id': 'embarrassing', 'name': 'Embarrassing', 'emoji': '🙈'},
    {'id': 'regret', 'name': 'Regret', 'emoji': '😔'},
    {'id': 'broken-dream', 'name': 'Broken Dream', 'emoji': '💭'},
    {'id': 'old-self', 'name': 'Old Self', 'emoji': '👤'},
    {'id': 'addiction', 'name': 'Addiction', 'emoji': '⛓️'},
    {'id': 'failure', 'name': 'Failure', 'emoji': '📉'},
    {'id': 'betrayal', 'name': 'Betrayal', 'emoji': '🗡️'},
    {'id': 'lost-love', 'name': 'Lost Love', 'emoji': '🥀'},
  ];

  @override
  void initState() {
    super.initState();
    _loadGraves();
  }

  Future<void> _loadGraves() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await SupabaseService.getGravesPaginated(
        category: _selectedCategory == 'all' ? null : _selectedCategory,
        sortBy: _sortBy,
      );
      
      setState(() {
        _graves = List<Map<String, dynamic>>.from(result['graves'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Logo
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFa78bfa), Color(0xFF8b5cf6)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(Icons.favorite, color: Colors.white, size: 22),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFFa78bfa), Color(0xFFf472b6)],
                          ).createShader(bounds),
                          child: const Text(
                            'Graveyard',
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        const Spacer(),
                    // Sort Button
                    GestureDetector(
                      onTap: () => _showSortOptions(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.sort, color: const Color(0xFFa78bfa), size: 18),
                            const SizedBox(width: 6),
                            Text(
                              _sortBy == 'newest' ? 'New' : _sortBy == 'popular' ? 'Hot' : 'Random',
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Eternal peace for your memories',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                  ],
                ),
              ).animate().fadeIn(),

              // Categories
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat['id'];
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedCategory = cat['id']!);
                        _loadGraves();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: isSelected 
                              ? const LinearGradient(colors: [Color(0xFFa78bfa), Color(0xFF8b5cf6)])
                              : null,
                          color: isSelected ? null : Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(cat['emoji']!, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              cat['name']!,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey[400],
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 16),

              // Graves Grid
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFa78bfa)))
                    : _graves.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.yard_outlined, color: Colors.grey[600], size: 64),
                                const SizedBox(height: 16),
                                Text('No graves yet', style: TextStyle(color: Colors.grey[400], fontSize: 18)),
                                Text('Be the first to bury something', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadGraves,
                            color: const Color(0xFFa78bfa),
                            child: GridView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.85,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: _graves.length,
                              itemBuilder: (context, index) {
                                final grave = _graves[index];
                                return _buildGraveCard(grave, index);
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGraveCard(Map<String, dynamic> grave, int index) {
    final category = grave['category'] ?? 'other';
    final tombstoneStyle = grave['tombstone_style'] ?? 'classic';
    final isPremium = ['diamond', 'fire', 'star', 'crown', 'skull', 'rose', 'ghost', 'crystal'].contains(tombstoneStyle);

    final categoryEmojis = {
      'ex-lover': '💔', 'toxic-friend': '🐍', 'old-job': '💼', 'embarrassing': '🙈',
      'regret': '😔', 'broken-dream': '💭', 'old-self': '👤', 'addiction': '⛓️',
      'failure': '📉', 'betrayal': '🗡️', 'lost-love': '🥀', 'other': '🔮',
    };

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GraveDetailScreen(grave: grave)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isPremium ? const Color(0xFFd4a853).withOpacity(0.5) : Colors.white.withOpacity(0.15),
            width: isPremium ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tombstone mini
            Container(
              width: 60,
              height: 75,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isPremium 
                      ? [const Color(0xFF4a3f6b), const Color(0xFF2d2a4a)]
                      : [const Color(0xFF3d3a5c), const Color(0xFF252340)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
                border: Border.all(
                  color: isPremium ? const Color(0xFFd4a853) : const Color(0xFFa78bfa).withOpacity(0.6),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isPremium ? const Color(0xFFd4a853) : const Color(0xFFa78bfa)).withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Text(categoryEmojis[category] ?? '🪦', style: const TextStyle(fontSize: 24)),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                grave['title'] ?? 'Unknown',
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_fire_department, color: const Color(0xFFf97316), size: 14),
                const SizedBox(width: 3),
                Text('${grave['respect_count'] ?? 0}', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                const SizedBox(width: 12),
                Icon(Icons.local_florist, color: const Color(0xFFec4899), size: 14),
                const SizedBox(width: 3),
                Text('${grave['flower_count'] ?? 0}', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (50 * index).ms).scale(begin: const Offset(0.95, 0.95), delay: (50 * index).ms);
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1a1a2e),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Sort by', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildSortOption('newest', 'Newest First', Icons.access_time),
            _buildSortOption('popular', 'Most Popular', Icons.local_fire_department),
            _buildSortOption('random', 'Random', Icons.shuffle),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String value, String label, IconData icon) {
    final isSelected = _sortBy == value;
    return GestureDetector(
      onTap: () {
        setState(() => _sortBy = value);
        Navigator.pop(context);
        _loadGraves();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected 
              ? const LinearGradient(colors: [Color(0xFFa78bfa), Color(0xFF8b5cf6)])
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey[400], size: 22),
            const SizedBox(width: 14),
            Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey[300], fontSize: 16)),
            const Spacer(),
            if (isSelected) const Icon(Icons.check, color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }
}
