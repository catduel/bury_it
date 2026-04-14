import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/supabase_service.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  String _selectedPlan = 'yearly';
  bool _isLoading = false;

  Future<void> _purchase() async {
    setState(() => _isLoading = true);

    // TODO: Implement actual in-app purchase with RevenueCat or StoreKit
    // For now, just show a message
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔜 In-app purchase coming soon!'),
          backgroundColor: Color(0xFFC9A962),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = SupabaseService.isPremium;

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF12121A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Crown Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFC9A962), Color(0xFFE8D5A3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFC9A962).withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('👑', style: TextStyle(fontSize: 50)),
                  ),
                ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),

                const SizedBox(height: 24),

                // Title
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFC9A962), Color(0xFFE8D5A3), Color(0xFFC9A962)],
                  ).createShader(bounds),
                  child: const Text(
                    'PREMIUM',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 6,
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 8),

                Text(
                  'Unlock the full graveyard experience',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 30),

                // Already Premium
                if (isPremium)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFC9A962).withOpacity(0.2),
                          const Color(0xFF8B5CF6).withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFC9A962)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('✨', style: TextStyle(fontSize: 24)),
                        SizedBox(width: 12),
                        Text(
                          'You are Premium!',
                          style: TextStyle(
                            color: Color(0xFFC9A962),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms),

                if (!isPremium) ...[
                  // Features
                  _buildFeatureList(),

                  const SizedBox(height: 24),

                  // Plan Selection
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Choose your plan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Yearly Plan
                  GestureDetector(
                    onTap: () => setState(() => _selectedPlan = 'yearly'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: _selectedPlan == 'yearly'
                            ? LinearGradient(
                                colors: [
                                  const Color(0xFFC9A962).withOpacity(0.2),
                                  const Color(0xFF8B5CF6).withOpacity(0.2),
                                ],
                              )
                            : null,
                        color: _selectedPlan != 'yearly' ? const Color(0xFF12121A) : null,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _selectedPlan == 'yearly'
                              ? const Color(0xFFC9A962)
                              : Colors.grey.withOpacity(0.3),
                          width: _selectedPlan == 'yearly' ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectedPlan == 'yearly'
                                    ? const Color(0xFFC9A962)
                                    : Colors.grey,
                                width: 2,
                              ),
                              color: _selectedPlan == 'yearly'
                                  ? const Color(0xFFC9A962)
                                  : Colors.transparent,
                            ),
                            child: _selectedPlan == 'yearly'
                                ? const Icon(Icons.check, color: Colors.black, size: 16)
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Yearly',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        'SAVE 44%',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$1.67/month, billed annually',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            '\$19.99',
                            style: TextStyle(
                              color: Color(0xFFC9A962),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 12),

                  // Monthly Plan
                  GestureDetector(
                    onTap: () => setState(() => _selectedPlan = 'monthly'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: _selectedPlan == 'monthly'
                            ? LinearGradient(
                                colors: [
                                  const Color(0xFFC9A962).withOpacity(0.2),
                                  const Color(0xFF8B5CF6).withOpacity(0.2),
                                ],
                              )
                            : null,
                        color: _selectedPlan != 'monthly' ? const Color(0xFF12121A) : null,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _selectedPlan == 'monthly'
                              ? const Color(0xFFC9A962)
                              : Colors.grey.withOpacity(0.3),
                          width: _selectedPlan == 'monthly' ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectedPlan == 'monthly'
                                    ? const Color(0xFFC9A962)
                                    : Colors.grey,
                                width: 2,
                              ),
                              color: _selectedPlan == 'monthly'
                                  ? const Color(0xFFC9A962)
                                  : Colors.transparent,
                            ),
                            child: _selectedPlan == 'monthly'
                                ? const Icon(Icons.check, color: Colors.black, size: 16)
                                : null,
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Monthly',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Billed monthly',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            '\$2.99',
                            style: TextStyle(
                              color: Color(0xFFC9A962),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 500.ms),

                  const SizedBox(height: 24),

                  // Purchase Button
                  GestureDetector(
                    onTap: _isLoading ? null : _purchase,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFC9A962), Color(0xFFE8D5A3)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFC9A962).withOpacity(0.4),
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
                                  color: Colors.black,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _selectedPlan == 'yearly'
                                    ? 'Subscribe for \$19.99/year'
                                    : 'Subscribe for \$2.99/month',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.95, 0.95)),

                  const SizedBox(height: 16),

                  // Restore & Terms
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Restore purchases coming soon'),
                              backgroundColor: Color(0xFF8B5CF6),
                            ),
                          );
                        },
                        child: const Text(
                          'Restore Purchases',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    ],
                  ),

                  Text(
                    'Cancel anytime. Terms & Privacy Policy apply.',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureList() {
    final features = [
      {'emoji': '♾️', 'title': 'Unlimited Graves', 'desc': 'Bury as many memories as you want'},
      {'emoji': '🪦', 'title': 'Premium Tombstones', 'desc': 'Access exclusive designs'},
      {'emoji': '👁️', 'title': 'Unlimited Visits', 'desc': 'Visit graves without limits'},
      {'emoji': '🕯️', 'title': 'Unlimited Reactions', 'desc': 'Pay respects & leave flowers'},
      {'emoji': '💬', 'title': 'Unlimited Comments', 'desc': 'Leave condolences freely'},
      {'emoji': '🚫', 'title': 'Ad-Free Experience', 'desc': 'No interruptions ever'},
    ];

    return Column(
      children: features.asMap().entries.map((entry) {
        final index = entry.key;
        final feature = entry.value;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF12121A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFC9A962).withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFC9A962).withOpacity(0.2),
                        const Color(0xFF8B5CF6).withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(feature['emoji']!, style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature['title']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        feature['desc']!,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFFC9A962),
                  size: 22,
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 300 + index * 50)).slideX(begin: 0.1);
      }).toList(),
    );
  }
}
