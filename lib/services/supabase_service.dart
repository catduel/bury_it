import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class SupabaseService {
  static SupabaseClient get _client => Supabase.instance.client;
  static const _uuid = Uuid();

  static User? get currentAuthUser => _client.auth.currentUser;
  static Map<String, dynamic>? _currentUser;
  static Map<String, dynamic>? get currentUser => _currentUser;
  static String? get effectiveUserId => currentAuthUser?.id;
  static bool get isPremium => _currentUser?['is_premium'] ?? false;

  // ==================== AUTH ====================

  static Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await _client.auth.signUp(email: email, password: password);
      if (response.user != null) {
        await _client.from('users').insert({
          'id': response.user!.id,
          'display_name': displayName,
          'is_premium': false,
          'created_at': DateTime.now().toIso8601String(),
        });
        await _loadUserProfile(response.user!.id);
        return true;
      }
      return false;
    } catch (e) {
      print('Sign up error: $e');
      return false;
    }
  }

  static Future<bool> signIn({required String email, required String password}) async {
    try {
      final response = await _client.auth.signInWithPassword(email: email, password: password);
      if (response.user != null) {
        await _loadUserProfile(response.user!.id);
        return true;
      }
      return false;
    } catch (e) {
      print('Sign in error: $e');
      return false;
    }
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
    _currentUser = null;
  }

  static Future<void> _loadUserProfile(String userId) async {
    try {
      final response = await _client.from('users').select().eq('id', userId).single();
      _currentUser = response;
    } catch (e) {
      print('Load profile error: $e');
    }
  }

  static Future<bool> checkExistingSession() async {
    final user = currentAuthUser;
    if (user != null) {
      await _loadUserProfile(user.id);
      return true;
    }
    return false;
  }

  static Future<bool> upgradeToPremium() async {
    final userId = effectiveUserId;
    if (userId == null) return false;
    try {
      await _client.from('users').update({'is_premium': true}).eq('id', userId);
      _currentUser?['is_premium'] = true;
      return true;
    } catch (e) {
      print('Upgrade error: $e');
      return false;
    }
  }

  // ==================== GRAVES ====================

  static Future<Map<String, dynamic>> getGravesPaginated({
    String? category,
    String sortBy = 'newest',
    int page = 0,
    int limit = 20,
  }) async {
    try {
      List<Map<String, dynamic>> graves;

      if (sortBy == 'popular') {
        if (category != null) {
          final response = await _client.from('graves').select()
              .eq('is_approved', true).eq('category', category)
              .order('respect_count', ascending: false)
              .range(page * limit, (page + 1) * limit - 1);
          graves = List<Map<String, dynamic>>.from(response);
        } else {
          final response = await _client.from('graves').select()
              .eq('is_approved', true)
              .order('respect_count', ascending: false)
              .range(page * limit, (page + 1) * limit - 1);
          graves = List<Map<String, dynamic>>.from(response);
        }
      } else if (sortBy == 'random') {
        if (category != null) {
          final response = await _client.from('graves').select()
              .eq('is_approved', true).eq('category', category)
              .range(page * limit, (page + 1) * limit - 1);
          graves = List<Map<String, dynamic>>.from(response);
        } else {
          final response = await _client.from('graves').select()
              .eq('is_approved', true)
              .range(page * limit, (page + 1) * limit - 1);
          graves = List<Map<String, dynamic>>.from(response);
        }
        graves.shuffle();
      } else {
        if (category != null) {
          final response = await _client.from('graves').select()
              .eq('is_approved', true).eq('category', category)
              .order('created_at', ascending: false)
              .range(page * limit, (page + 1) * limit - 1);
          graves = List<Map<String, dynamic>>.from(response);
        } else {
          final response = await _client.from('graves').select()
              .eq('is_approved', true)
              .order('created_at', ascending: false)
              .range(page * limit, (page + 1) * limit - 1);
          graves = List<Map<String, dynamic>>.from(response);
        }
      }

      final allGraves = await _client.from('graves').select('id').eq('is_approved', true);
      final totalCount = allGraves.length;

      return {
        'graves': graves,
        'totalCount': totalCount,
        'hasMore': (page + 1) * limit < totalCount,
      };
    } catch (e) {
      print('Get graves error: $e');
      return {'graves': [], 'totalCount': 0, 'hasMore': false};
    }
  }

  static Future<List<Map<String, dynamic>>> getPublicGraves() async {
    try {
      final response = await _client.from('graves').select()
          .eq('is_approved', true).order('created_at', ascending: false).limit(50);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getGravesByCategory(String category) async {
    try {
      final response = await _client.from('graves').select()
          .eq('category', category).eq('is_approved', true)
          .order('created_at', ascending: false).limit(50);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getRandomGrave() async {
    try {
      final response = await _client.from('graves').select().eq('is_approved', true);
      final graves = List<Map<String, dynamic>>.from(response);
      if (graves.isEmpty) return null;
      graves.shuffle();
      return graves.first;
    } catch (e) {
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getUserGraves(String userId) async {
    try {
      final response = await _client.from('graves').select()
          .eq('user_id', userId).order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>?> createGrave({
    required String userId,
    required String title,
    String? story,
    required String category,
    String tombstoneStyle = 'classic',
    int? yearStart,
    int? yearEnd,
  }) async {
    try {
      final response = await _client.from('graves').insert({
        'id': _uuid.v4(),
        'user_id': userId,
        'title': title,
        'story': story,
        'category': category,
        'tombstone_style': tombstoneStyle,
        'year_start': yearStart,
        'year_end': yearEnd,
        'respect_count': 0,
        'flower_count': 0,
        'visitor_count': 0,
        'is_approved': false,
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();
      return response;
    } catch (e) {
      print('Create grave error: $e');
      return null;
    }
  }

  static Future<bool> canCreateGrave() async {
    if (isPremium) return true;
    final userId = effectiveUserId;
    if (userId == null) return false;
    try {
      final response = await _client.from('graves').select('id').eq('user_id', userId);
      return response.length < 3;
    } catch (e) {
      return false;
    }
  }

  // ==================== STATS ====================

  static Future<List<Map<String, dynamic>>> getTopVisitedGraves({int limit = 10}) async {
    try {
      final response = await _client.from('graves').select()
          .eq('is_approved', true).order('visitor_count', ascending: false).limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getTopRespectedGraves({int limit = 10}) async {
    try {
      final response = await _client.from('graves').select()
          .eq('is_approved', true).order('respect_count', ascending: false).limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getTopFloweredGraves({int limit = 10}) async {
    try {
      final response = await _client.from('graves').select()
          .eq('is_approved', true).order('flower_count', ascending: false).limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, int>> getTotalStats() async {
    try {
      final graves = await _client.from('graves').select().eq('is_approved', true);
      int totalRespects = 0, totalFlowers = 0, totalVisits = 0;
      for (var grave in graves) {
        totalRespects += (grave['respect_count'] ?? 0) as int;
        totalFlowers += (grave['flower_count'] ?? 0) as int;
        totalVisits += (grave['visitor_count'] ?? 0) as int;
      }
      return {
        'total_graves': graves.length,
        'total_respects': totalRespects,
        'total_flowers': totalFlowers,
        'total_visits': totalVisits,
      };
    } catch (e) {
      return {'total_graves': 0, 'total_respects': 0, 'total_flowers': 0, 'total_visits': 0};
    }
  }

  // ==================== INTERACTIONS ====================

  static Future<void> incrementVisitor(String graveId) async {
    try {
      await _client.rpc('increment_visitor', params: {'grave_id': graveId});
    } catch (e) {
      try {
        final grave = await _client.from('graves').select('visitor_count').eq('id', graveId).single();
        await _client.from('graves').update({'visitor_count': (grave['visitor_count'] ?? 0) + 1}).eq('id', graveId);
      } catch (e2) {
        print('Increment visitor error: $e2');
      }
    }
  }

  static Future<bool> addReaction(String visitorId, String graveId, String type) async {
    try {
      final existing = await _client.from('reactions').select()
          .eq('visitor_id', visitorId).eq('grave_id', graveId);
      if (existing.isNotEmpty) return false;

      await _client.from('reactions').insert({
        'id': _uuid.v4(),
        'visitor_id': visitorId,
        'grave_id': graveId,
        'type': type,
        'created_at': DateTime.now().toIso8601String(),
      });

      final field = type == 'respect' ? 'respect_count' : 'flower_count';
      final grave = await _client.from('graves').select(field).eq('id', graveId).single();
      await _client.from('graves').update({field: (grave[field] ?? 0) + 1}).eq('id', graveId);
      await _trackDailyAction('reaction');
      return true;
    } catch (e) {
      print('Add reaction error: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getComments(String graveId) async {
    try {
      final response = await _client.from('comments').select()
          .eq('grave_id', graveId).order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  static Future<bool> addComment({
    required String visitorId,
    required String graveId,
    required String content,
  }) async {
    try {
      final anonymousNames = ['Wandering Soul', 'Silent Visitor', 'Midnight Ghost',
        'Peaceful Spirit', 'Gentle Shadow', 'Quiet Mourner', 'Lost Wanderer'];
      anonymousNames.shuffle();

      await _client.from('comments').insert({
        'id': _uuid.v4(),
        'visitor_id': visitorId,
        'grave_id': graveId,
        'content': content,
        'anonymous_name': anonymousNames.first,
        'created_at': DateTime.now().toIso8601String(),
      });
      await _trackDailyAction('comment');
      return true;
    } catch (e) {
      print('Add comment error: $e');
      return false;
    }
  }

  // ==================== LIMITS ====================

  static Future<void> _trackDailyAction(String actionType) async {
    final userId = effectiveUserId;
    if (userId == null) return;
    final today = DateTime.now().toIso8601String().split('T')[0];
    try {
      await _client.from('daily_actions').insert({
        'id': _uuid.v4(),
        'user_id': userId,
        'action_type': actionType,
        'action_date': today,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Track action error: $e');
    }
  }

  static Future<int> _getDailyActionCount(String actionType) async {
    final userId = effectiveUserId;
    if (userId == null) return 0;
    final today = DateTime.now().toIso8601String().split('T')[0];
    try {
      final response = await _client.from('daily_actions').select()
          .eq('user_id', userId).eq('action_type', actionType).eq('action_date', today);
      return response.length;
    } catch (e) {
      return 0;
    }
  }

  static Future<bool> canVisitGrave() async {
    if (isPremium) return true;
    return await _getDailyActionCount('visit') < 5;
  }

  static Future<bool> canReact() async {
    if (isPremium) return true;
    return await _getDailyActionCount('reaction') < 2;
  }

  static Future<bool> canComment() async {
    if (isPremium) return true;
    return await _getDailyActionCount('comment') < 1;
  }

  static Future<Map<String, int>> getUserStats() async {
    return {
      'daily_visits': await _getDailyActionCount('visit'),
      'daily_reactions': await _getDailyActionCount('reaction'),
      'daily_comments': await _getDailyActionCount('comment'),
    };
  }
}
