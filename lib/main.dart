import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';
import 'app.dart';
import 'core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  // 通过 screen_retriever 获取主屏幕可用区域
  final primaryDisplay = await screenRetriever.getPrimaryDisplay();
  final screenW = primaryDisplay.visibleSize?.width ??
      primaryDisplay.size.width;
  final screenH = primaryDisplay.visibleSize?.height ??
      primaryDisplay.size.height;

  final maxW = screenW * AppConstants.maxScreenRatio;
  final maxH = screenH * AppConstants.maxScreenRatio;
  final width = math.min(AppConstants.windowWidth, maxW);
  final height = math.min(AppConstants.windowHeight, maxH);

  final windowOptions = WindowOptions(
    size: Size(width, height),
    minimumSize: const Size(
      AppConstants.minWindowWidth,
      AppConstants.minWindowHeight,
    ),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    title: AppConstants.appTitle,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setMinimumSize(const Size(
      AppConstants.minWindowWidth,
      AppConstants.minWindowHeight,
    ));
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
