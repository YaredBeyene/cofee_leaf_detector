import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class PredictionResult {
  final String label;
  final String amharicLabel;
  final double confidence;
  final Map<String, double> allScores;

  PredictionResult({
    required this.label,
    required this.amharicLabel,
    required this.confidence,
    required this.allScores,
  });
}

class CoffeeClassifier {
  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  // Translation mapping for the 5 classes
  static const Map<String, String> amharicNames = {
    'Cerscospora': 'ሰርኮስፖራ (ቡናማ አይን)',
    'Healthy': 'ጤናማ ቅጠል',
    'Leaf rust': 'የቡና ቅጠል ዝገት',
    'Miner': 'ቅጠል ቆፋሪ ትል',
    'Phoma': 'ፎማ (የቅጠል ጫፍ መድረቅ)',
  };

  /// Load model and labels from assets
  Future<void> loadModel() async {
    try {
      // 1. Load TFLite Model
      _interpreter = await Interpreter.fromAsset('assets/coffee_disease_model.tflite');
      
      // 2. Load Labels
      try {
        final labelData = await rootBundle.loadString('assets/labels.txt');
        _labels = labelData
            .split('\n')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      } catch (e) {
        // Fallback if labels.txt fails to load
        _labels = ['Cerscospora', 'Healthy', 'Leaf rust', 'Miner', 'Phoma'];
      }

      _isLoaded = true;
      print('CoffeeClassifier: Model and labels loaded successfully.');
    } catch (e) {
      print('CoffeeClassifier Error loading model: $e');
      _isLoaded = false;
    }
  }

  /// Classify a leaf image
  Future<PredictionResult?> classifyImage(File imageFile) async {
    if (_interpreter == null) {
      await loadModel();
      if (_interpreter == null) return null;
    }

    // 1. Read and decode image
    final Uint8List imageBytes = await imageFile.readAsBytes();
    final img.Image? originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) return null;

    // 2. Resize to 128x128 (required by our model)
    final img.Image resizedImage = img.copyResize(
      originalImage,
      width: 128,
      height: 128,
    );

    // 3. Preprocess image into 4D tensor [1, 128, 128, 3]
    // The model has layers.Rescaling(1./255) inside, so raw 0..255 pixel values are passed
    var input = List.generate(
      1,
      (_) => List.generate(
        128,
        (y) => List.generate(
          128,
          (x) {
            final pixel = resizedImage.getPixel(x, y);
            return [
              pixel.r.toDouble(),
              pixel.g.toDouble(),
              pixel.b.toDouble(),
            ];
          },
        ),
      ),
    );

    // 4. Prepare output buffer for 5 classes: shape [1, 5]
    var output = List.generate(1, (_) => List<double>.filled(5, 0.0));

    // 5. Run inference
    _interpreter!.run(input, output);

    final List<double> probabilities = output[0];

    // 6. Find the class with the highest probability
    int maxIndex = 0;
    double maxProb = -1.0;
    final Map<String, double> allScores = {};

    for (int i = 0; i < probabilities.length; i++) {
      final labelName = i < _labels.length ? _labels[i] : 'Class $i';
      final prob = probabilities[i];
      allScores[labelName] = prob;

      if (prob > maxProb) {
        maxProb = prob;
        maxIndex = i;
      }
    }

    final topLabel = maxIndex < _labels.length ? _labels[maxIndex] : 'Unknown';
    final amharicName = amharicNames[topLabel] ?? topLabel;

    return PredictionResult(
      label: topLabel,
      amharicLabel: amharicName,
      confidence: maxProb,
      allScores: allScores,
    );
  }

  void close() {
    _interpreter?.close();
  }
}
