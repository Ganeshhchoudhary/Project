import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/trading_signal.dart';
import '../models/market_data.dart';
import 'database_service.dart';

class AIService {
  static final AIService instance = AIService._init();
  Interpreter? _interpreter;
  bool _isInitialized = false;

  AIService._init();

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load TensorFlow Lite model
      final modelPath = 'assets/models/trading_model_quantized.tflite';
      
      // TensorFlow Lite doesn't work on web, skip initialization
      if (Platform.isAndroid || Platform.isIOS || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        try {
          _interpreter = await Interpreter.fromAsset(modelPath);
          _isInitialized = true;
          print('AI Service initialized successfully');
        } catch (e) {
          print('Model file not found or error loading: $e');
          print('AI Service will continue without model (mock mode)');
          _isInitialized = false;
        }
      } else {
        // Web platform - TensorFlow Lite not supported
        print('AI Service: TensorFlow Lite not supported on web platform');
        print('AI Service will continue in mock mode');
        // Conditional export: use native implementation on non-web, stub on web
        export 'ai_service_io.dart'
          if (dart.library.html) 'ai_service_web.dart';
      print('Error initializing AI Service: $e');

      print('AI Service will continue in mock mode');
