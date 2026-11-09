import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 全局轻量状态：收藏、评分、语言，并持久化到本地缓存。
class AppState extends ChangeNotifier {
  static const _favoritesKey = 'biaimx.favorites';
  static const _ratingsKey = 'biaimx.ratings';
  static const _localeKey = 'biaimx.locale';

  static const Locale englishLocale = Locale('en');
  static const Locale traditionalLocale = Locale.fromSubtags(
    languageCode: 'zh',
    scriptCode: 'Hant',
  );

  final Set<String> _favoriteIds;
  final Map<String, double> _ratings;
  Locale _locale = englishLocale;

  AppState({
    Set<String>? initialFavorites,
    Map<String, double>? initialRatings,
    Locale? initialLocale,
  }) : _favoriteIds = {...?initialFavorites},
       _ratings = {...?initialRatings},
       _locale = initialLocale ?? englishLocale;

  Set<String> get favorites => Set.unmodifiable(_favoriteIds);

  bool isFavorite(String id) => _favoriteIds.contains(id);

  Locale get locale => _locale;

  bool get isTraditional => _locale.languageCode == 'zh';

  /// 用户对某家交易所的评分（1–5），未评分返回 null。
  double? ratingOf(String exchangeId) => _ratings[exchangeId];

  /// 从本地缓存恢复收藏、评分与语言。App 启动时在 runApp 之前调用一次。
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_favoritesKey);
      if (saved != null) {
        _favoriteIds
          ..clear()
          ..addAll(saved);
      }

      final rawRatings = prefs.getString(_ratingsKey);
      if (rawRatings != null) {
        final decoded = jsonDecode(rawRatings);
        if (decoded is Map) {
          _ratings.clear();
          decoded.forEach((key, value) {
            if (key is String && value is num) {
              _ratings[key] = value.toDouble();
            }
          });
        }
      }

      final language = prefs.getString(_localeKey);
      if (language == 'zh') _locale = traditionalLocale;

      notifyListeners();
    } catch (error) {
      // 缓存不可用时保持默认状态，不影响主流程。
      debugPrint('读取本地缓存失败: $error');
    }
  }

  void toggleFavorite(String id) {
    if (!_favoriteIds.remove(id)) {
      _favoriteIds.add(id);
    }
    notifyListeners();
    _persist();
  }

  /// 记录用户对交易所的评分，再次评分会覆盖旧值。
  void rateExchange(String exchangeId, double rating) {
    final clamped = rating.clamp(1.0, 5.0).toDouble();
    _ratings[exchangeId] = clamped;
    notifyListeners();
    _persist();
  }

  Future<void> setLocale(Locale locale) async {
    if (locale == _locale) return;
    _locale = locale;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
    } catch (error) {
      debugPrint('保存语言设置失败: $error');
    }
  }

  Future<void> toggleLanguage() =>
      setLocale(isTraditional ? englishLocale : traditionalLocale);

  /// 清除本机保存的收藏与评分等个人数据。
  Future<void> clearUserData() async {
    if (_favoriteIds.isEmpty && _ratings.isEmpty) return;
    _favoriteIds.clear();
    _ratings.clear();
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favoritesKey, _favoriteIds.toList());
      await prefs.setString(
        _ratingsKey,
        jsonEncode(_ratings.map((key, value) => MapEntry(key, value))),
      );
    } catch (error) {
      debugPrint('保存本地缓存失败: $error');
    }
  }

  List<String> get favoriteExchangeIds =>
      _favoriteIds.where((id) => !id.startsWith('coin:')).toList();

  List<String> get favoriteCoinIds => _favoriteIds
      .where((id) => id.startsWith('coin:'))
      .map((id) => id.substring(5))
      .toList();
}
