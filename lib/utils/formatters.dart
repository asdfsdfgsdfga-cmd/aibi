String _group(int intPart) {
  final s = intPart.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

String formatPrice(double price) {
  final decimals = price >= 1000
      ? 2
      : price >= 1
      ? 2
      : price >= 0.01
      ? 4
      : 6;
  final fixed = price.toStringAsFixed(decimals);
  final parts = fixed.split('.');
  final intPart = _group(int.tryParse(parts[0]) ?? 0);
  return parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
}

String formatPercent(double pct) {
  final sign = pct > 0 ? '+' : '';
  return '$sign${pct.toStringAsFixed(2)}%';
}

String formatCompact(double n) {
  if (n.abs() >= 1e12) return '\$${(n / 1e12).toStringAsFixed(2)}T';
  if (n.abs() >= 1e9) return '\$${(n / 1e9).toStringAsFixed(2)}B';
  if (n.abs() >= 1e6) return '\$${(n / 1e6).toStringAsFixed(2)}M';
  if (n.abs() >= 1e3) return '\$${(n / 1e3).toStringAsFixed(2)}K';
  return '\$${n.toStringAsFixed(2)}';
}

String formatCompactNoSymbol(double n) {
  if (n.abs() >= 1e9) return '${(n / 1e9).toStringAsFixed(2)}B';
  if (n.abs() >= 1e6) return '${(n / 1e6).toStringAsFixed(2)}M';
  if (n.abs() >= 1e3) return '${(n / 1e3).toStringAsFixed(1)}K';
  return n.toStringAsFixed(2);
}

String timeAgo(DateTime time, {bool isZh = false}) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return isZh ? '剛剛' : 'Just now';
  if (diff.inMinutes < 60) {
    return isZh ? '${diff.inMinutes} 分鐘前' : '${diff.inMinutes} min ago';
  }
  if (diff.inHours < 24) {
    return isZh ? '${diff.inHours} 小時前' : '${diff.inHours} h ago';
  }
  if (diff.inDays < 30) {
    return isZh ? '${diff.inDays} 天前' : '${diff.inDays} d ago';
  }
  return formatDate(time);
}

String formatDate(DateTime time) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${time.year}-${two(time.month)}-${two(time.day)}';
}

String formatChartTime(DateTime time, String timeframe) {
  String two(int v) => v.toString().padLeft(2, '0');
  if (timeframe == '1d') return '${two(time.month)}/${two(time.day)}';
  return '${two(time.month)}/${two(time.day)} ${two(time.hour)}:${two(time.minute)}';
}
