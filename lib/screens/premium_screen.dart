import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/supabase_service.dart';
import '../services/purchase_service.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  String _selectedPlan = 'yearly';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initPurchases();
  }

  Future<void> _initPurchases() async {
    await PurchaseService.initialize();
    
    PurchaseService.onPurchaseUpdate = (success, message) {
      if (!mounted) return;
      
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '✅ $message' : message),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      
      if (success) {
        setState(() {});
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context);
        });
      }
    };
    
    if (mounted) setState(() {});
  }

  Future<void> _purchase() async {
    setState(() => _isLoading = true);
    
    final productId = _selectedPlan == 'yearly' 
        ? PurchaseService.yearlyProductId 
        : PurchaseService.monthlyProductId;
    
    final success = await PurchaseService.purchase(productId);
    
    if (!success && mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _isLoading = true);
    await PurchaseService.restorePurchases();
    
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(SupabaseService.isPremium 
              ? '✅ Restored!' 
              : 'No purchases found'),
          backgroundColor: SupabaseService.isPremium ? Colors.green : Colors.grey,
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
                  style: TextStyle(fontSize: 14, color: Colors.grey[400]),
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

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Choose your plan',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Yearly Plan
                  _buildPlanCard(
                    isSelected: _selectedPlan == 'yearly',
                    title: 'Yearly',
                    subtitle: '\$1.67/month, billed annually',
                    price: PurchaseService.getPrice(PurchaseService.yearlyProductId),
                    badge: 'SAVE 44%',
                    onTap: () => setState(() => _selectedPlan = 'yearly'),
                  ),

                  const SizedBox(height: 12),

                  // Monthly Plan
                  _buildPlanCard(
                    isSelected: _selectedPlan == 'monthly',
                    title: 'Monthly',
                    subtitle: 'Billed monthly',
                    price: PurchaseService.getPrice(PurchaseService.monthlyProductId),
                    onTap: () => setState(() => _selectedPlan = 'monthly'),
                  ),

                  const SizedBox(height: 24),

                  // Subscribe Button
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
                                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                              )
                            : Text(
                                _selectedPlan == 'yearly'
                                    ? 'Subscribe for ${PurchaseService.getPrice(PurchaseService.yearlyProductId)}/year'
                                    : 'Subscribe for ${PurchaseService.getPrice(PurchaseService.monthlyProductId)}/month',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: 16),

                  // Restore
                  TextButton(
                    onPressed: _isLoading ? null : _restore,
                    child: const Text(
                      'Restore Purchases',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),

                  Text(
                    'Cancel anytime. Terms & Privacy Policy apply.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
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

  Widget _buildPlanCard({
    required bool isSelected,
    required String title,
    required String subtitle,
    required String price,
    String? badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [
                  const Color(0xFFC9A962).withOpacity(0.2),
                  const Color(0xFF8B5CF6).withOpacity(0.2),
                ])
              : null,
          color: !isSelected ? const Color(0xFF12121A) : null,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFFC9A962) : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
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
                  color: isSelected ? const Color(0xFFC9A962) : Colors.grey,
                  width: 2,
                ),
                color: isSelected ? const Color(0xFFC9A962) : Colors.transparent,
              ),
              child: isSelected ? const Icon(Icons.check, color: Colors.black, size: 16) : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(10)),
                          child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Text(price, style: const TextStyle(color: Color(0xFFC9A962), fontSize: 20, fontWeight: FontWeight.bold)),
          ],
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
        final i = entry.key;
        final f = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF12121A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFC9A962).withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      const Color(0xFFC9A962).withOpacity(0.2),
                      const Color(0xFF8B5CF6).withOpacity(0.2),
                    ]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: Text(f['emoji']!, style: const TextStyle(fontSize: 22))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f['title']!, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(f['desc']!, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle, color: Color(0xFFC9A962), size: 22),
              ],
            ),
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 300 + i * 50));
      }).toList(),
    );
  }
}
