import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/supabase_service.dart';
import 'premium_screen.dart';
import 'welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Map<String, dynamic>> _myGraves = [];
  bool _isLoading = true;
  Map<String, int> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      final userId = SupabaseService.effectiveUserId;
      if (userId != null) {
        final graves = await SupabaseService.getUserGraves(userId);
        final stats = await SupabaseService.getUserStats();

        setState(() {
          _myGraves = graves;
          _stats = stats;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    await SupabaseService.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF12121A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 90,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E1E2E), Color(0xFF12121A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                    bottomLeft: Radius.circular(5),
                    bottomRight: Radius.circular(5),
                  ),
                  border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.5), width: 2),
                ),
                child: const Center(child: Text('⚰️', style: TextStyle(fontSize: 32))),
              ),
              const SizedBox(height: 16),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFC9A962)],
                ).createShader(bounds),
                child: const Text(
                  'BURY IT',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 4),
                ),
              ),
              const SizedBox(height: 6),
              Text('Version 1.0.0', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0A0F),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      'Your digital graveyard for burying the past. Let go of painful memories, toxic relationships, and regrets.',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    Container(height: 1, color: Colors.grey.withOpacity(0.2)),
                    const SizedBox(height: 14),
                    Text('Developed by', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                    const SizedBox(height: 4),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFFC9A962)],
                      ).createShader(bounds),
                      child: const Text(
                        'Neva Labs',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text('Istanbul, Turkey 🇹🇷', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(child: Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF12121A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.red.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: const Center(child: Text('⚠️', style: TextStyle(fontSize: 28))),
              ),
              const SizedBox(height: 16),
              const Text('Delete Account?', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(
                'This will permanently delete your account and all your graves. This action cannot be undone.',
                style: TextStyle(color: Colors.grey[400], fontSize: 13, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E2E),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        ),
                        child: const Center(child: Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        await SupabaseService.signOut();
                        if (mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                            (route) => false,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                        child: const Center(child: Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = SupabaseService.isPremium;
    final currentUser = SupabaseService.currentUser;
    final displayName = currentUser?['display_name'] ?? 'Anonymous';
    final email = SupabaseService.currentAuthUser?.email;

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6)))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                            gradient: isPremium
                                ? const LinearGradient(colors: [Color(0xFFC9A962), Color(0xFF8B5CF6)])
                                : const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]),
                            shape: BoxShape.circle,
                          ),
                          child: Center(child: Text(isPremium ? '👑' : '👻', style: const TextStyle(fontSize: 24))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(displayName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                                  ),
                                  if (isPremium) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: const Color(0xFFC9A962), borderRadius: BorderRadius.circular(8)),
                                      child: const Text('PRO', style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(email ?? '', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ).animate().fadeIn(),

                    const SizedBox(height: 20),

                    // Daily Limits
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF12121A),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text('📊', style: TextStyle(fontSize: 16)),
                              SizedBox(width: 8),
                              Text('Daily Usage', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildLimitRow('👁️ Visits', _stats['daily_visits'] ?? 0, isPremium ? 999 : 5, isPremium),
                          const SizedBox(height: 8),
                          _buildLimitRow('🕯️ Reactions', _stats['daily_reactions'] ?? 0, isPremium ? 999 : 2, isPremium),
                          const SizedBox(height: 8),
                          _buildLimitRow('💬 Comments', _stats['daily_comments'] ?? 0, isPremium ? 999 : 1, isPremium),
                        ],
                      ),
                    ).animate().fadeIn(delay: 100.ms),

                    const SizedBox(height: 16),

                    // My Graves
                    Row(
                      children: [
                        const Text('⚰️', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        const Text('My Graves', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Text('${_myGraves.length}/${isPremium ? '∞' : '3'}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (_myGraves.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF12121A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          children: [
                            Text('🪦', style: TextStyle(fontSize: 32)),
                            SizedBox(height: 8),
                            Text('No graves yet', style: TextStyle(color: Colors.white, fontSize: 14)),
                            Text('Bury something to get started', style: TextStyle(color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                      )
                    else
                      ...List.generate(
                        _myGraves.length > 3 ? 3 : _myGraves.length,
                        (index) {
                          final grave = _myGraves[index];
                          final isApproved = grave['is_approved'] ?? false;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF12121A),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isApproved ? const Color(0xFF8B5CF6).withOpacity(0.3) : const Color(0xFFC9A962).withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Text('🪦', style: TextStyle(fontSize: 20)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(child: Text(grave['title'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis)),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isApproved ? Colors.green.withOpacity(0.2) : const Color(0xFFC9A962).withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(isApproved ? '✓ Live' : '⏳ Pending', style: TextStyle(color: isApproved ? Colors.green : const Color(0xFFC9A962), fontSize: 8, fontWeight: FontWeight.w600)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text('🕯️${grave['respect_count'] ?? 0}  💐${grave['flower_count'] ?? 0}  👁️${grave['visitor_count'] ?? 0}', style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: (150 + index * 50).ms);
                        },
                      ),

                    const SizedBox(height: 16),

                    // Premium
                    if (!isPremium)
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PremiumScreen())),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFC9A962), Color(0xFF8B5CF6)]),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Row(
                            children: [
                              Text('👑', style: TextStyle(fontSize: 20)),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Upgrade to Premium', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                  Text('Unlimited graves & reactions', style: TextStyle(color: Colors.white70, fontSize: 10)),
                                ],
                              ),
                              Spacer(),
                              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 16),

                    // Settings Section
                    const Row(
                      children: [
                        Text('⚙️', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 8),
                        Text('Settings', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF12121A),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          _buildSettingsItem(icon: 'ℹ️', title: 'About', subtitle: 'Version 1.0.0', onTap: _showAboutDialog),
                          Divider(color: Colors.grey.withOpacity(0.2), height: 1),
                          _buildSettingsItem(icon: '🔒', title: 'Privacy Policy', onTap: () {}),
                          Divider(color: Colors.grey.withOpacity(0.2), height: 1),
                          _buildSettingsItem(icon: '📄', title: 'Terms of Service', onTap: () {}),
                          Divider(color: Colors.grey.withOpacity(0.2), height: 1),
                          _buildSettingsItem(icon: '🗑️', title: 'Delete Account', titleColor: Colors.red, onTap: _showDeleteAccountDialog),
                        ],
                      ),
                    ).animate().fadeIn(delay: 250.ms),

                    const SizedBox(height: 14),

                    // Sign Out
                    GestureDetector(
                      onTap: _signOut,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF12121A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, color: Colors.red, size: 16),
                            SizedBox(width: 6),
                            Text('Sign Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 300.ms),

                    const SizedBox(height: 20),

                    // Footer
                    Center(
                      child: Column(
                        children: [
                          Text('Made with 🖤 by', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFC9A962)]).createShader(bounds),
                            child: const Text('Neva Labs', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSettingsItem({required String icon, required String title, String? subtitle, Color? titleColor, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: titleColor ?? Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                  if (subtitle != null) Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[600], size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitRow(String label, int used, int max, bool isPremium) {
    final progress = isPremium ? 0.0 : (used / max).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
            Text(isPremium ? '$used / ∞' : '$used / $max', style: TextStyle(color: isPremium ? const Color(0xFFC9A962) : (used >= max ? Colors.red : Colors.white), fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(value: isPremium ? 0 : progress, backgroundColor: const Color(0xFF1E1E2E), valueColor: AlwaysStoppedAnimation<Color>(used >= max ? Colors.red : const Color(0xFF8B5CF6)), minHeight: 4),
        ),
      ],
    );
  }
}
