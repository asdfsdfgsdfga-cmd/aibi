import 'package:flutter/material.dart';

import 'app.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 先恢复本地收藏与语言偏好，首帧即可据此展示个性化内容与收藏提示。
  final state = AppState();
  await state.load();
  runApp(BiaimxApp(state: state));
}
