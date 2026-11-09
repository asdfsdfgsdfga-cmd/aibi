class Candle {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  const Candle({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  bool get isUp => close >= open;
  double get change => close - open;
}

class RiskAlert {
  final String title;
  final String description;
  final RiskAlertLevel level;

  const RiskAlert({
    required this.title,
    required this.description,
    required this.level,
  });
}

enum RiskAlertLevel { info, warning, danger }
