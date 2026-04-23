import 'dart:async';
import 'package:flutter/foundation.dart';
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
  static bool isInitialized = false;
  static String? initError;
  
  // Purchase callback
  static Function(bool success, String message)? onPurchaseUpdate;

  /// Initialize purchase service
  static Future<void> initialize() async {
    if (isInitialized) return;
    
    try {
      isAvailable = await _iap.isAvailable();
      
      if (!isAvailable) {
        initError = 'Store not available';
        debugPrint('IAP: Store not available');
        isInitialized = true;
        return;
      }

      // Listen to purchase updates
      _subscription = _iap.purchaseStream.listen(
        _handlePurchaseUpdate,
        onDone: () => _subscription?.cancel(),
        onError: (error) {
          debugPrint('IAP Stream Error: $error');
        },
      );

      // Load products
      await loadProducts();
      isInitialized = true;
    } catch (e) {
      initError = e.toString();
      debugPrint('IAP Init Error: $e');
      isInitialized = true;
    }
  }

  /// Load products from App Store
  static Future<void> loadProducts() async {
    if (!isAvailable) {
      debugPrint('IAP: Cannot load products - store not available');
      return;
    }

    try {
      debugPrint('IAP: Loading products: $_productIds');
      final response = await _iap.queryProductDetails(_productIds);
      
      if (response.error != null) {
        debugPrint('IAP: Error loading products: ${response.error}');
        initError = response.error?.message;
        return;
      }

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('IAP: Products not found: ${response.notFoundIDs}');
      }

      products = response.productDetails;
      debugPrint('IAP: Loaded ${products.length} products');
      
      for (var p in products) {
        debugPrint('IAP: Product: ${p.id} - ${p.title} - ${p.price}');
      }
    } catch (e) {
      debugPrint('IAP: Load error: $e');
      initError = e.toString();
    }
  }

  /// Purchase a subscription
  static Future<bool> purchase(String productId) async {
    // Re-initialize if needed
    if (!isInitialized) {
      await initialize();
    }
    
    if (!isAvailable) {
      onPurchaseUpdate?.call(false, 'Store not available. Please try again later.');
      return false;
    }

    // Reload products if empty
    if (products.isEmpty) {
      debugPrint('IAP: Products empty, reloading...');
      await loadProducts();
    }

    if (products.isEmpty) {
      onPurchaseUpdate?.call(false, 'Unable to load products. Please try again.');
      return false;
    }

    ProductDetails? product;
    try {
      product = products.firstWhere((p) => p.id == productId);
    } catch (e) {
      debugPrint('IAP: Product not found: $productId');
      debugPrint('IAP: Available products: ${products.map((p) => p.id).toList()}');
      onPurchaseUpdate?.call(false, 'Product not available. Please try again.');
      return false;
    }

    try {
      debugPrint('IAP: Purchasing ${product.id}');
      final purchaseParam = PurchaseParam(productDetails: product);
      final result = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      debugPrint('IAP: Purchase initiated: $result');
      return result;
    } catch (e) {
      debugPrint('IAP: Purchase error: $e');
      onPurchaseUpdate?.call(false, 'Purchase failed. Please try again.');
      return false;
    }
  }

  /// Handle purchase updates
  static void _handlePurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      debugPrint('IAP: Update - ${purchase.productID} - ${purchase.status}');
      
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
          final errorMsg = purchase.error?.message ?? 'Purchase error';
          debugPrint('IAP: Error - $errorMsg');
          onPurchaseUpdate?.call(false, errorMsg);
          break;
          
        case PurchaseStatus.canceled:
          onPurchaseUpdate?.call(false, 'Purchase canceled');
          break;
      }

      // Complete the purchase
      if (purchase.pendingCompletePurchase) {
        try {
          await _iap.completePurchase(purchase);
          debugPrint('IAP: Purchase completed');
        } catch (e) {
          debugPrint('IAP: Complete purchase error: $e');
        }
      }
    }
  }

  /// Restore purchases
  static Future<void> restorePurchases() async {
    if (!isInitialized) {
      await initialize();
    }
    
    if (!isAvailable) {
      onPurchaseUpdate?.call(false, 'Store not available');
      return;
    }
    
    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('IAP: Restore error: $e');
      onPurchaseUpdate?.call(false, 'Restore failed. Please try again.');
    }
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
    isInitialized = false;
  }
}
