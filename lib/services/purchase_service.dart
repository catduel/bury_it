import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'supabase_service.dart';

class PurchaseService {
  static final InAppPurchase _iap = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  // App Store Connect'teki Product ID'ler
  static const String monthlyProductId = 'com.nevalabs.buryit.premium.monthly';
  static const String yearlyProductId = 'com.nevalabs.buryit.premium.yearly';
  
  static final Set<String> _productIds = {monthlyProductId, yearlyProductId};
  
  static List<ProductDetails> products = [];
  static bool isAvailable = false;
  
  // Purchase callback
  static Function(bool success, String message)? onPurchaseUpdate;

  /// Initialize purchase service
  static Future<void> initialize() async {
    isAvailable = await _iap.isAvailable();
    
    if (!isAvailable) {
      print('IAP: Store not available');
      return;
    }

    // Listen to purchase updates
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) => print('IAP Error: $error'),
    );

    // Load products
    await loadProducts();
  }

  /// Load products from App Store
  static Future<void> loadProducts() async {
    if (!isAvailable) return;

    try {
      final response = await _iap.queryProductDetails(_productIds);
      
      if (response.error != null) {
        print('IAP: Error loading products: ${response.error}');
        return;
      }

      if (response.notFoundIDs.isNotEmpty) {
        print('IAP: Products not found: ${response.notFoundIDs}');
      }

      products = response.productDetails;
      print('IAP: Loaded ${products.length} products');
    } catch (e) {
      print('IAP: Load error: $e');
    }
  }

  /// Purchase a subscription
  static Future<bool> purchase(String productId) async {
    if (!isAvailable) {
      onPurchaseUpdate?.call(false, 'Store not available');
      return false;
    }

    ProductDetails? product;
    try {
      product = products.firstWhere((p) => p.id == productId);
    } catch (e) {
      onPurchaseUpdate?.call(false, 'Product not found');
      return false;
    }

    try {
      final purchaseParam = PurchaseParam(productDetails: product);
      return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      print('IAP: Purchase error: $e');
      onPurchaseUpdate?.call(false, 'Purchase failed');
      return false;
    }
  }

  /// Handle purchase updates
  static void _handlePurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      print('IAP: ${purchase.productID} - ${purchase.status}');
      
      switch (purchase.status) {
        case PurchaseStatus.pending:
          onPurchaseUpdate?.call(false, 'Processing...');
          break;
          
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // Verify and deliver
          if (_productIds.contains(purchase.productID)) {
            await SupabaseService.upgradeToPremium();
            onPurchaseUpdate?.call(true, 'Welcome to Premium!');
          }
          break;
          
        case PurchaseStatus.error:
          onPurchaseUpdate?.call(false, purchase.error?.message ?? 'Error');
          break;
          
        case PurchaseStatus.canceled:
          onPurchaseUpdate?.call(false, 'Canceled');
          break;
      }

      // Complete the purchase
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  /// Restore purchases
  static Future<void> restorePurchases() async {
    if (!isAvailable) {
      onPurchaseUpdate?.call(false, 'Store not available');
      return;
    }
    await _iap.restorePurchases();
  }

  /// Get formatted price
  static String getPrice(String productId) {
    try {
      final product = products.firstWhere((p) => p.id == productId);
      return product.price;
    } catch (e) {
      return productId == monthlyProductId ? '\$2.99' : '\$19.99';
    }
  }

  /// Dispose
  static void dispose() {
    _subscription?.cancel();
  }
}
