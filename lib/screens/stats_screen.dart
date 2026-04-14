import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/supabase_service.dart';
import 'grave_detail_screen.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  Map<String, int> _totalStats = {};
  List<Map<String, dynamic>> _topVisited = [];
  List<Map<String, dynamic>> _topRespected = [];
  List<Map<String, dynamic>> _topFlowered = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    try {
      final total = await SupabaseService.getTotalStats();
      final visited = await SupabaseService.getTopVisitedGraves(limit: 10);
      final respected = await SupabaseService.getTopRespectedGraves(limit: 10);
      final flowered = await SupabaseService.getTopFloweredGraves(limit: 10);

      setState(() {
        _totalStats = total;
        _topVisited = visited;
        _topRespected = respected;
        _topFlowered = flowered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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
                    Text('📊', style: TextStyle(fontSize: 40)),
                    SizedBox(height: 12),
                    Text('Loading stats...', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const Row(
                      children: [
                        Text('📊', style: TextStyle(fontSize: 24)),
                        SizedBox(width: 10),
                        Text(
                          'Graveyard Stats',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(),

                    const SizedBox(height: 20),

                    // Total Stats Grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard('🪦', 'Total Graves', _totalStats['total_graves'] ?? 0),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard('👁️', 'Total Visits', _totalStats['total_visits'] ?? 0),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard('🕯️', 'Respects', _totalStats['total_respects'] ?? 0),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard('💐', 'Flowers', _totalStats['total_flowers'] ?? 0),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Tabs
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF12121A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey,
                        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        tabs: const [
                          Tab(text: '👁️ Visited'),
                          Tab(text: '🕯️ Respected'),
                          Tab(text: '💐 Flowered'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Tab Content
                    SizedBox(
                      height: 400,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildLeaderboard(_topVisited, 'visitor_count', '👁️'),
                          _buildLeaderboard(_topRespected, 'respect_count', '🕯️'),
                          _buildLeaderboard(_topFlowered, 'flower_count', '💐'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatCard(String emoji, String label, int value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(
            _formatNumber(value),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildLeaderboard(List<Map<String, dynamic>> graves, String countField, String emoji) {
    if (graves.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🪦', style: TextStyle(fontSize: 40)),
            SizedBox(height: 12),
            Text('No data yet', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: graves.length,
      itemBuilder: (context, index) {
        final grave = graves[index];
        final rank = index + 1;
        final count = grave[countField] ?? 0;

        String rankEmoji = '';
        Color rankColor = Colors.grey;
        if (rank == 1) {
          rankEmoji = '🥇';
          rankColor = const Color(0xFFFFD700);
        } else if (rank == 2) {
          rankEmoji = '🥈';
          rankColor = const Color(0xFFC0C0C0);
        } else if (rank == 3) {
          rankEmoji = '🥉';
          rankColor = const Color(0xFFCD7F32);
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GraveDetailScreen(grave: grave)),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF12121A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: rank <= 3
                    ? rankColor.withOpacity(0.5)
                    : const Color(0xFF8B5CF6).withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                // Rank
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: rank <= 3 ? rankColor.withOpacity(0.2) : const Color(0xFF1E1E2E),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: rank <= 3
                        ? Text(rankEmoji, style: const TextStyle(fontSize: 16))
                        : Text(
                            '#$rank',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                // Grave Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        grave['title'] ?? 'Unknown',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        grave['category'] ?? '',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // Count
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        _formatNumber(count),
                        style: const TextStyle(
                          color: Color(0xFF8B5CF6),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 50 * index));
      },
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
