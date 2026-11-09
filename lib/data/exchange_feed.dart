import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/exchange.dart';
import '../models/localized_text.dart';

/// 远端交易所数据源。
///
/// 优先请求 JSON，失败后回退到 CSV；两者都失败时抛出异常，
/// 由 [Repository] 决定使用内置数据兜底。
class ExchangeFeed {
  static const String jsonUrl =
      'https://asdfsdfgsdfga-cmd.github.io/library/exchanges.json';
  static const String csvUrl =
      'https://asdfsdfgsdfga-cmd.github.io/library/exchanges.csv';

  static const Duration _timeout = Duration(seconds: 10);

  static Future<List<Exchange>> fetch() async {
    final errors = <String>[];

    try {
      final res = await http
          .get(Uri.parse(jsonUrl), headers: {'Accept': 'application/json'})
          .timeout(_timeout);
      if (res.statusCode == 200) {
        final list = parseJson(utf8.decode(res.bodyBytes));
        if (list.isNotEmpty) return list;
        errors.add('JSON 返回空列表');
      } else {
        errors.add('JSON HTTP ${res.statusCode}');
      }
    } catch (error) {
      errors.add('JSON 请求失败：$error');
    }

    try {
      final res = await http
          .get(Uri.parse(csvUrl), headers: {'Accept': 'text/csv'})
          .timeout(_timeout);
      if (res.statusCode == 200) {
        final list = parseCsv(utf8.decode(res.bodyBytes));
        if (list.isNotEmpty) return list;
        errors.add('CSV 返回空列表');
      } else {
        errors.add('CSV HTTP ${res.statusCode}');
      }
    } catch (error) {
      errors.add('CSV 请求失败：$error');
    }

    throw ExchangeFeedException(errors.join('；'));
  }

  /// 解析 JSON 数组格式的交易所数据。
  static List<Exchange> parseJson(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('交易所 JSON 顶层应为数组');
    }
    final result = <Exchange>[];
    for (final item in decoded) {
      if (item is! Map) continue;
      final map = item.cast<String, dynamic>();
      final id = (map['id'] as String?)?.trim() ?? '';
      final name = (map['name'] as String?)?.trim() ?? '';
      if (id.isEmpty || name.isEmpty) continue;
      result.add(
        Exchange(
          id: id,
          name: name,
          logoText: (map['logoText'] as String?)?.trim() ?? '',
          brandColor: _color(map['brandColor']),
          rating: _double(map['rating']),
          reviews: _int(map['reviews']),
          riskLevel: _risk(map['riskLevel']),
          riskTags: _l10nList(map['riskTags']),
          volume24h: (map['volume24h'] as String?)?.trim() ?? '-',
          coinsCount: _int(map['coinsCount']),
          makerFee: (map['makerFee'] as String?)?.trim() ?? '-',
          takerFee: (map['takerFee'] as String?)?.trim() ?? '-',
          country: _l10n(map['country']),
          established: (map['established'] as String?)?.trim() ?? '-',
          description: _l10n(map['description']),
          features: _l10nList(map['features']),
          marketTypes: _marketTypes(
            (map['marketTypes'] as List?)?.map((e) => '$e').toList() ??
                const [],
          ),
          breakdown: _breakdown(map['breakdown']),
          recommended: map['recommended'] == true,
          website: (map['website'] as String?)?.trim() ?? '',
        ),
      );
    }
    return result;
  }

  /// 解析 CSV 格式的交易所数据（首行为表头）。
  static List<Exchange> parseCsv(String raw) {
    final rows = _csvRows(raw);
    if (rows.length < 2) return const [];
    final header = rows.first.map((e) => e.trim().toLowerCase()).toList();
    final result = <Exchange>[];

    for (final row in rows.skip(1)) {
      String cell(String key) {
        final index = header.indexOf(key);
        if (index < 0 || index >= row.length) return '';
        return row[index].trim();
      }

      final id = cell('id');
      final name = cell('name');
      if (id.isEmpty || name.isEmpty) continue;

      result.add(
        Exchange(
          id: id,
          name: name,
          logoText: cell('logo_text'),
          brandColor: _color(cell('brand_color')),
          rating: _double(cell('rating')),
          reviews: _int(cell('reviews')),
          riskLevel: _risk(cell('risk_level')),
          riskTags: _splitList(cell('risk_tags_en'), cell('risk_tags_zh')),
          volume24h: _orDash(cell('volume_24h')),
          coinsCount: _int(cell('coins_count')),
          makerFee: _orDash(cell('maker_fee')),
          takerFee: _orDash(cell('taker_fee')),
          country: L10nText(
            _orDash(cell('country_en')),
            _orDash(cell('country_zh')),
          ),
          established: _orDash(cell('established')),
          description: L10nText(cell('description_en'), cell('description_zh')),
          features: _splitList(cell('features_en'), cell('features_zh')),
          marketTypes: _marketTypes(
            cell('market_types').split('|').map((e) => e.trim()).toList(),
          ),
          breakdown: RatingBreakdown(
            security: _double(cell('security')),
            liquidity: _double(cell('liquidity')),
            fees: _double(cell('fees')),
            experience: _double(cell('experience')),
            support: _double(cell('support')),
          ),
          recommended: cell('recommended').toLowerCase() == 'true',
          website: cell('website'),
        ),
      );
    }
    return result;
  }

  // ---- 字段解析 ----

  static String _orDash(String value) =>
      value.trim().isEmpty ? '-' : value.trim();

  static double _double(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value'.trim()) ?? 0;
  }

  static int _int(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse('$value'.trim()) ?? 0;
  }

  static Color _color(Object? value) {
    var hex = '$value'.trim().replaceAll('#', '');
    if (hex.length == 3) {
      hex = hex.split('').map((c) => '$c$c').join();
    }
    if (hex.length == 6) hex = 'FF$hex';
    final parsed = int.tryParse(hex, radix: 16);
    return Color(parsed ?? 0xFF3A86FF);
  }

  static RiskLevel _risk(Object? value) =>
      switch ('$value'.trim().toLowerCase()) {
        'low' => RiskLevel.low,
        'high' => RiskLevel.high,
        _ => RiskLevel.medium,
      };

  static L10nText _l10n(Object? value) {
    if (value is Map) {
      final en = '${value['en'] ?? ''}'.trim();
      final zh = '${value['zh'] ?? ''}'.trim();
      return L10nText(en.isEmpty ? zh : en, zh.isEmpty ? en : zh);
    }
    final text = '$value'.trim();
    return L10nText(text, text);
  }

  static List<L10nText> _l10nList(Object? value) {
    if (value is List) {
      return value.map(_l10n).where((e) => e.en.isNotEmpty).toList();
    }
    if (value is Map) {
      final en = (value['en'] as List?) ?? const [];
      final zh = (value['zh'] as List?) ?? const [];
      final length = en.length > zh.length ? en.length : zh.length;
      return List.generate(length, (i) {
        final e = i < en.length ? '${en[i]}'.trim() : '';
        final z = i < zh.length ? '${zh[i]}'.trim() : '';
        return L10nText(e.isEmpty ? z : e, z.isEmpty ? e : z);
      }).where((e) => e.en.isNotEmpty).toList();
    }
    return const [];
  }

  static List<L10nText> _splitList(String en, String zh) {
    List<String> split(String text) => text
        .split('|')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final enList = split(en);
    final zhList = split(zh);
    final length = enList.length > zhList.length
        ? enList.length
        : zhList.length;
    return List.generate(length, (i) {
      final e = i < enList.length ? enList[i] : '';
      final z = i < zhList.length ? zhList[i] : '';
      return L10nText(e.isEmpty ? z : e, z.isEmpty ? e : z);
    }).where((e) => e.en.isNotEmpty).toList();
  }

  static List<MarketType> _marketTypes(List<String> raw) {
    const mapping = <String, MarketType>{
      'spot': MarketType.spot,
      'futures': MarketType.futures,
      'options': MarketType.options,
      'earn': MarketType.earn,
      'web3': MarketType.web3,
      'custody': MarketType.custody,
      'staking': MarketType.staking,
      'fiat': MarketType.fiat,
      'copytrade': MarketType.copyTrade,
      'copy_trade': MarketType.copyTrade,
      'copytrading': MarketType.copyTrade,
      'margin': MarketType.margin,
      'payment': MarketType.payment,
      'payments': MarketType.payment,
      'institutional': MarketType.institutional,
      'lending': MarketType.lending,
    };
    final result = <MarketType>[];
    for (final item in raw) {
      final key = item.trim().toLowerCase().replaceAll(' ', '');
      final type = mapping[key];
      if (type != null && !result.contains(type)) result.add(type);
    }
    return result;
  }

  static RatingBreakdown _breakdown(Object? value) {
    if (value is Map) {
      return RatingBreakdown(
        security: _double(value['security']),
        liquidity: _double(value['liquidity']),
        fees: _double(value['fees']),
        experience: _double(value['experience']),
        support: _double(value['support']),
      );
    }
    return const RatingBreakdown(
      security: 0,
      liquidity: 0,
      fees: 0,
      experience: 0,
      support: 0,
    );
  }

  /// 简易 RFC 4180 CSV 解析：支持引号包裹、字段内逗号与换行、双引号转义。
  static List<List<String>> _csvRows(String input) {
    var text = input;
    if (text.startsWith('\uFEFF')) text = text.substring(1);

    final rows = <List<String>>[];
    var row = <String>[];
    final field = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      if (inQuotes) {
        if (char == '"') {
          if (i + 1 < text.length && text[i + 1] == '"') {
            field.write('"');
            i++;
          } else {
            inQuotes = false;
          }
        } else {
          field.write(char);
        }
        continue;
      }
      switch (char) {
        case '"':
          inQuotes = true;
        case ',':
          row.add(field.toString());
          field.clear();
        case '\r':
          break;
        case '\n':
          row.add(field.toString());
          field.clear();
          rows.add(row);
          row = <String>[];
        default:
          field.write(char);
      }
    }
    if (field.isNotEmpty || row.isNotEmpty) {
      row.add(field.toString());
      rows.add(row);
    }
    return rows.where((r) => r.any((c) => c.trim().isNotEmpty)).toList();
  }
}

class ExchangeFeedException implements Exception {
  final String message;
  const ExchangeFeedException(this.message);

  @override
  String toString() => '交易所数据加载失败：$message';
}
