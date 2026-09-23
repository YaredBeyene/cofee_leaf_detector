import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'classifier.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CoffeeDiseaseApp());
}

class CoffeeDiseaseApp extends StatelessWidget {
  const CoffeeDiseaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coffee Leaf Doctor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E5E3A), // Coffee plantation green
          primary: const Color(0xFF1E5E3A),
          surface: const Color(0xFFF7FAF7),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7F4),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E5E3A),
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  final CoffeeClassifier _classifier = CoffeeClassifier();

  File? _selectedImage;
  PredictionResult? _result;
  bool _isClassifying = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _classifier.loadModel().catchError((e) {
      setState(() {
        _errorMessage = "ሞዴሉን መጫን አልተቻለም፡ እባክዎ coffee_disease_model.tflite በ assets ውስጥ መኖሩን ያረጋግጡ።";
      });
    });
  }

  @override
  void dispose() {
    _classifier.close();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile == null) return;

      setState(() {
        _selectedImage = File(pickedFile.path);
        _result = null;
        _isClassifying = true;
        _errorMessage = null;
      });

      // Run classification on the selected image
      final result = await _classifier.classifyImage(_selectedImage!);

      setState(() {
        _result = result;
        _isClassifying = false;
      });
    } catch (e) {
      setState(() {
        _isClassifying = false;
        _errorMessage = "ምርመራውን ማከናወን አልተቻለም፡ $e";
      });
    }
  }

  Color _getBadgeColor(String label) {
    if (label.toLowerCase() == 'healthy') {
      return Colors.green.shade700;
    } else if (label.toLowerCase().contains('rust')) {
      return Colors.deepOrange.shade700;
    } else {
      return Colors.amber.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: const [
            Text(
              'Coffee Leaf Doctor',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'የቡና ቅጠል በሽታ መለያ',
              style: TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Error banner if any
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade900, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            // Image Preview Area
            Container(
              height: 280,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: _selectedImage != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                        ),
                        if (_isClassifying)
                          Container(
                            color: Colors.black45,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  CircularProgressIndicator(color: Colors.white),
                                  SizedBox(height: 12),
                                  Text(
                                    'ቅጠሉን በመመርመር ላይ...\nAnalyzing leaf...',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.eco_rounded,
                            size: 72,
                            color: Colors.green.shade300,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'የቡና ቅጠል ፎቶ ያንሱ ወይም ይምረጡ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Take or upload a coffee leaf photo',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
            ),

            const SizedBox(height: 20),

            // Camera and Gallery buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isClassifying ? null : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text('ካሜራ (Camera)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E5E3A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isClassifying ? null : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_rounded),
                    label: const Text('ጋለሪ (Gallery)'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1E5E3A),
                      side: const BorderSide(color: Color(0xFF1E5E3A), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Results Card
            if (_result != null) ...[
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'የምርመራ ውጤት (Diagnosis)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _result!.amharicLabel,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E5E3A),
                                  ),
                                ),
                                Text(
                                  _result!.label,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Confidence Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _getBadgeColor(_result!.label).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getBadgeColor(_result!.label).withOpacity(0.5),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${(_result!.confidence * 100).toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _getBadgeColor(_result!.label),
                                  ),
                                ),
                                Text(
                                  'እርግጠኝነት',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: _getBadgeColor(_result!.label),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 32),

                      // Breakdown of all 5 classes
                      const Text(
                        'የሁሉም ክፍሎች ንጽጽር (All Probabilities):',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 12),

                      ..._result!.allScores.entries.map((entry) {
                        final double score = entry.value;
                        final String className = entry.key;
                        final String amharic = CoffeeClassifier.amharicNames[className] ?? className;
                        final bool isTop = className == _result!.label;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    amharic,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                                      color: isTop ? const Color(0xFF1E5E3A) : Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    '${(score * 100).toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                                      color: isTop ? const Color(0xFF1E5E3A) : Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: score.clamp(0.0, 1.0),
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(4),
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isTop ? _getBadgeColor(className) : Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
