import 'package:flutter/material.dart';

class Coin {
  final String symbol;
  final String name;
  final Color color;
  final double price;
  final double change24h;
  final double high24h;
  final double low24h;
  final double volume24h;
  final double marketCap;

  const Coin({
    required this.symbol,
    required this.name,
    required this.color,
    required this.price,
    required this.change24h,
    required this.high24h,
    required this.low24h,
    required this.volume24h,
    required this.marketCap,
  });

  bool get isUp => change24h >= 0;
}
