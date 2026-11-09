import 'package:flutter/widgets.dart';

import '../l10n/app_strings.dart';

/// 一段中英双语文案。zh 为繁體中文，en 为英文。
class L10nText {
  final String en;
  final String zh;

  const L10nText(this.en, this.zh);

  String of(BuildContext context) => AppStrings.of(context).isZh ? zh : en;

  String plain({required bool isZh}) => isZh ? zh : en;
}
