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
  bool _isLoadingMore = false;
  String _selectedCategory = 'All';
  String _sortBy = 'newest';
  int _currentPage = 0;
  int _totalCount = 0;
  bool _hasMore = true;

  final List<Map<String, String>> _categories = [
    {'id': 'All', 'emoji': '🪦', 'label': 'All'},
    {'id': 'ex-lover', 'emoji': '💔', 'label': 'Ex-Lover'},
    {'id': 'toxic-friend', 'emoji': '🐍', 'label': 'Toxic Friend'},
    {'id': 'old-job', 'emoji': '💼', 'label': 'Old Job'},
    {'id': 'embarrassing', 'emoji': '🙈', 'label': 'Cringe'},
    {'id': 'regret', 'emoji': '😔', 'label': 'Regret'},
    {'id': 'broken-dream', 'emoji': '💭', 'label': 'Dreams'},
    {'id': 'old-self', 'emoji': '👤', 'label': 'Old Self'},
    {'id': 'addiction', 'emoji': '⛓️', 'label': 'Addiction'},
    {'id': 'failure', 'emoji': '📉', 'label': 'Failure'},
    {'id': 'other', 'emoji': '🔮', 'label': 'Other'},
  ];

  final List<Map<String, String>> _sortOptions = [
    {'id': 'newest', 'emoji': '🆕', 'label': 'Newest'},
    {'id': 'popular', 'emoji': '🔥', 'label': 'Popular'},
    {'id': 'random', 'emoji': '🎲', 'label': 'Random'},
  ];

  @override
  void initState() {
    super.initState();
    _loadGraves();
  }

  Future<void> _loadGraves({bool refresh = true}) async {
    if (refresh) {
      setState(() {
        _isLoading = true;
        _currentPage = 0;
        _graves = [];
      });
    }

    try {
      final result = await SupabaseService.getGravesPaginated(
        category: _selectedCategory == 'All' ? null : _selectedCategory,
        sortBy: _sortBy,
        page: _currentPage,
        limit: 20,
      );

      setState(() {
        if (refresh) {
          _graves = List<Map<String, dynamic>>.from(result['graves']);
        } else {
          _graves.addAll(List<Map<String, dynamic>>.from(result['graves']));
        }
        _totalCount = result['totalCount'];
        _hasMore = result['hasMore'];
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });
    await _loadGraves(refresh: false);
  }

  Future<void> _visitRandomGrave() async {
    final grave = await SupabaseService.getRandomGrave();
    if (grave != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GraveDetailScreen(grave: grave)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('⚰️', style: TextStyle(fontSize: 40)),
                    SizedBox(height: 12),
                    Text('Digging up graves...', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () => _loadGraves(),
                color: const Color(0xFF8B5CF6),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        // Compact Header
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF8B5CF6), Color(0xFFC9A962)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text('⚰️', style: TextStyle(fontSize: 18)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bury It',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Your eternal sanctuary',
                                  style: TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Sort Options
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF12121A),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: _sortOptions.map((option) {
                              final isSelected = _sortBy == option['id'];
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() => _sortBy = option['id']!);
                                    _loadGraves();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)])
                                          : null,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(option['emoji']!, style: const TextStyle(fontSize: 11)),
                                        const SizedBox(width: 4),
                                        Text(
                                          option['label']!,
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.grey,
                                            fontSize: 11,
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Categories
                        SizedBox(
                          height: 32,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              final cat = _categories[index];
                              final isSelected = _selectedCategory == cat['id'];
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() => _selectedCategory = cat['id']!);
                                    _loadGraves();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFF12121A),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(cat['emoji']!, style: const TextStyle(fontSize: 10)),
                                        const SizedBox(width: 4),
                                        Text(
                                          cat['label']!,
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.grey,
                                            fontSize: 10,
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Random Grave Button
                        GestureDetector(
                          onTap: _visitRandomGrave,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF8B5CF6).withOpacity(0.2),
                                  const Color(0xFFC9A962).withOpacity(0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFC9A962).withOpacity(0.4)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('🪦', style: TextStyle(fontSize: 12)),
                                SizedBox(width: 6),
                                Icon(Icons.shuffle, color: Color(0xFFC9A962), size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'Visit Random Grave',
                                  style: TextStyle(color: Color(0xFFC9A962), fontWeight: FontWeight.w600, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Count
                        Text(
                          'Showing ${_graves.length} of $_totalCount graves',
                          style: const TextStyle(color: Colors.grey, fontSize: 10),
                        ),

                        const SizedBox(height: 8),

                        // Graves Grid
                        _graves.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(40),
                                  child: Column(
                                    children: [
                                      Text('🪦', style: TextStyle(fontSize: 40)),
                                      SizedBox(height: 12),
                                      Text('The graveyard is empty', style: TextStyle(color: Colors.white, fontSize: 14)),
                                    ],
                                  ),
                                ),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 0.9,
                                ),
                                itemCount: _graves.length,
                                itemBuilder: (context, index) => _buildGraveCard(_graves[index]),
                              ),

                        // Load More
                        if (_hasMore && _graves.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: GestureDetector(
                              onTap: _isLoadingMore ? null : _loadMore,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF12121A),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
                                ),
                                child: Center(
                                  child: _isLoadingMore
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(color: Color(0xFF8B5CF6), strokeWidth: 2),
                                        )
                                      : const Text('Load More', style: TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildGraveCard(Map<String, dynamic> grave) {
    final cat = _categories.firstWhere((c) => c['id'] == grave['category'], orElse: () => {'emoji': '🪦'});
    final isPremium = ['diamond', 'fire', 'star', 'crown', 'skull', 'rose', 'ghost', 'crystal'].contains(grave['tombstone_style']);

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => GraveDetailScreen(grave: grave))),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF12121A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isPremium ? const Color(0xFFC9A962).withOpacity(0.5) : const Color(0xFF8B5CF6).withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tombstone
            Container(
              width: 50,
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2E),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                  bottomLeft: Radius.circular(3),
                  bottomRight: Radius.circular(3),
                ),
                border: Border.all(color: isPremium ? const Color(0xFFC9A962).withOpacity(0.5) : const Color(0xFF8B5CF6).withOpacity(0.3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(cat['emoji']!, style: const TextStyle(fontSize: 18)),
                  Text('RIP', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isPremium ? const Color(0xFFC9A962) : const Color(0xFF8B5CF6))),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              grave['title'] ?? 'Unknown',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🕯️${grave['respect_count'] ?? 0}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                const SizedBox(width: 8),
                Text('💐${grave['flower_count'] ?? 0}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                const SizedBox(width: 8),
                Text('👁️${grave['visitor_count'] ?? 0}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
