import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'classifier.dart';
import 'models/disease_data.dart';
import 'services/history_service.dart';
import 'services/language_service.dart';
import 'services/tts_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LanguageService.instance.init();
  await TtsService.init();
  runApp(const CoffeeDiseaseApp());
}

class CoffeeDiseaseApp extends StatefulWidget {
  const CoffeeDiseaseApp({super.key});

  @override
  State<CoffeeDiseaseApp> createState() => _CoffeeDiseaseAppState();
}

class _CoffeeDiseaseAppState extends State<CoffeeDiseaseApp> {
  @override
  void initState() {
    super.initState();
    LanguageService.instance.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coffee Leaf Doctor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E5E3A),
          primary: const Color(0xFF1E5E3A),
          surface: const Color(0xFFF9FBF9),
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F7F3),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E5E3A),
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final LanguageService _lang = LanguageService.instance;

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_lang.t('select_language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: LanguageService.languageNames.entries.map((entry) {
            final isSelected = _lang.currentLanguage == entry.key;
            return ListTile(
              title: Text(
                entry.value,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFF1E5E3A) : Colors.black87,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: Color(0xFF1E5E3A))
                  : null,
              onTap: () {
                _lang.setLanguage(entry.key);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const ScannerScreen(),
      const HistoryScreen(),
      const DiseaseGuideScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              _lang.t('app_title'),
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            Text(
              _lang.t('app_subtitle'),
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language_rounded),
            tooltip: _lang.t('select_language'),
            onPressed: _showLanguageDialog,
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.camera_alt_outlined),
            selectedIcon: const Icon(Icons.camera_alt_rounded),
            label: _lang.t('tab_scan'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history_rounded),
            label: _lang.t('tab_history'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book_rounded),
            label: _lang.t('tab_guide'),
          ),
        ],
      ),
    );
  }
}

// 1. Scanner Screen
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  final CoffeeClassifier _classifier = CoffeeClassifier();
  final LanguageService _lang = LanguageService.instance;

  File? _selectedImage;
  PredictionResult? _result;
  bool _isClassifying = false;

  @override
  void initState() {
    super.initState();
    _classifier.loadModel();
  }

  @override
  void dispose() {
    _classifier.close();
    TtsService.stop();
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
      });

      final result = await _classifier.classifyImage(_selectedImage!);

      if (result != null) {
        await HistoryService.saveScan(
          imagePath: pickedFile.path,
          diseaseKey: result.label,
          confidence: result.confidence,
        );
      }

      setState(() {
        _result = result;
        _isClassifying = false;
      });
    } catch (e) {
      setState(() {
        _isClassifying = false;
      });
    }
  }

  void _speakDiagnosis() {
    if (_result == null) return;
    final info = CoffeeDiseaseDatabase.get(_result!.label);
    final text = "${info.getName(_lang.currentLanguage)}. "
        "${_lang.t('confidence')}: ${(_result!.confidence * 100).toStringAsFixed(0)}%. "
        "${info.getSymptoms(_lang.currentLanguage)}. "
        "${info.getOrganicCare(_lang.currentLanguage)}";

    TtsService.speak(text, _lang.currentLanguage);
  }

  void _openTreatmentSheet(DiseaseInfo info) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TreatmentBottomSheet(info: info),
    );
  }

  Color _getBadgeColor(String label) {
    if (label.toLowerCase() == 'healthy') return Colors.green.shade700;
    if (label.toLowerCase().contains('rust') || label.toLowerCase().contains('phoma')) {
      return Colors.deepOrange.shade700;
    }
    return Colors.amber.shade800;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 260,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
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
                      Image.file(_selectedImage!, fit: BoxFit.cover),
                      if (_isClassifying)
                        Container(
                          color: Colors.black54,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(color: Colors.white),
                                const SizedBox(height: 12),
                                Text(
                                  _lang.t('analyzing'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
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
                        Icon(Icons.spa_rounded, size: 70, color: Colors.green.shade300),
                        const SizedBox(height: 10),
                        Text(
                          _lang.t('empty_picker_title'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _lang.t('empty_picker_subtitle'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isClassifying ? null : () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: Text(_lang.t('take_photo')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E5E3A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isClassifying ? null : () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_rounded),
                  label: Text(_lang.t('pick_gallery')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E5E3A),
                    side: const BorderSide(color: Color(0xFF1E5E3A), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (_result != null) ...[
            Builder(builder: (context) {
              final diseaseInfo = CoffeeDiseaseDatabase.get(_result!.label);
              final localizedName = diseaseInfo.getName(_lang.currentLanguage);
              final badgeColor = _getBadgeColor(_result!.label);

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localizedName,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E5E3A),
                                  ),
                                ),
                                Text(
                                  _result!.label,
                                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: badgeColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: badgeColor.withOpacity(0.4)),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${(_result!.confidence * 100).toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: badgeColor,
                                  ),
                                ),
                                Text(
                                  _lang.t('confidence'),
                                  style: TextStyle(fontSize: 10, color: badgeColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _speakDiagnosis,
                          icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF1E5E3A)),
                          label: Text(
                            _lang.t('listen_voice'),
                            style: const TextStyle(
                              color: Color(0xFF1E5E3A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF1E5E3A)),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _openTreatmentSheet(diseaseInfo),
                          icon: const Icon(Icons.medical_services_outlined),
                          label: Text(_lang.t('treatment_btn')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E5E3A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),

                      const Divider(height: 28),

                      ..._result!.allScores.entries.map((entry) {
                        final score = entry.value;
                        final name = entry.key;
                        final local = CoffeeDiseaseDatabase.get(name).getName(_lang.currentLanguage);
                        final isTop = name == _result!.label;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    local,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                                      color: isTop ? const Color(0xFF1E5E3A) : Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    '${(score * 100).toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              LinearProgressIndicator(
                                value: score.clamp(0.0, 1.0),
                                minHeight: 5,
                                borderRadius: BorderRadius.circular(4),
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isTop ? _getBadgeColor(name) : Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

// 2. History Screen
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final LanguageService _lang = LanguageService.instance;
  List<ScanRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await HistoryService.getHistory();
    setState(() {
      _records = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            Text(_lang.t('no_history'), style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_records.length} ${_lang.t('tab_history')}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () async {
                  await HistoryService.clearHistory();
                  _load();
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                label: Text(_lang.t('clear_history'), style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _records.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final item = _records[index];
              final info = CoffeeDiseaseDatabase.get(item.diseaseKey);
              final localizedName = info.getName(_lang.currentLanguage);
              final dateStr = DateFormat('MMM d, y • h:mm a').format(item.timestamp);

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: File(item.imagePath).existsSync()
                        ? Image.file(File(item.imagePath), width: 48, height: 48, fit: BoxFit.cover)
                        : Container(width: 48, height: 48, color: Colors.grey.shade300, child: const Icon(Icons.spa)),
                  ),
                  title: Text(localizedName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(dateStr, style: const TextStyle(fontSize: 11)),
                  trailing: Text(
                    '${(item.confidence * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E5E3A)),
                  ),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => TreatmentBottomSheet(info: info),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// 3. Disease Guide Screen
class DiseaseGuideScreen extends StatelessWidget {
  const DiseaseGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.instance;
    final list = CoffeeDiseaseDatabase.diseases.values.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final info = list[index];
        final name = info.getName(lang.currentLanguage);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 2,
          child: ExpansionTile(
            leading: Icon(
              info.key == 'Healthy' ? Icons.check_circle_rounded : Icons.warning_rounded,
              color: info.key == 'Healthy' ? Colors.green.shade700 : Colors.amber.shade800,
            ),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Text(info.key, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(lang.t('symptoms'), Icons.visibility_outlined),
                    Text(info.getSymptoms(lang.currentLanguage), style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 10),

                    _header(lang.t('causes'), Icons.info_outline),
                    Text(info.getCauses(lang.currentLanguage), style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 10),

                    _header(lang.t('organic_care'), Icons.eco_outlined),
                    Text(info.getOrganicCare(lang.currentLanguage), style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 10),

                    _header(lang.t('chemical_treatment'), Icons.science_outlined),
                    Text(info.getChemicalTreatment(lang.currentLanguage), style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _header(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3.0),
      child: Row(
        children: [
          Icon(icon, size: 15, color: const Color(0xFF1E5E3A)),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E5E3A)),
          ),
        ],
      ),
    );
  }
}

// 4. Treatment Bottom Sheet
class TreatmentBottomSheet extends StatelessWidget {
  final DiseaseInfo info;
  const TreatmentBottomSheet({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.instance;
    final name = info.getName(lang.currentLanguage);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E5E3A),
                          ),
                        ),
                        Text(info.key, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 20),

              _card(lang.t('symptoms'), info.getSymptoms(lang.currentLanguage), Icons.visibility_outlined, Colors.blue.shade800),
              _card(lang.t('causes'), info.getCauses(lang.currentLanguage), Icons.help_outline_rounded, Colors.purple.shade800),
              _card(lang.t('organic_care'), info.getOrganicCare(lang.currentLanguage), Icons.eco_rounded, Colors.green.shade800),
              _card(lang.t('chemical_treatment'), info.getChemicalTreatment(lang.currentLanguage), Icons.science_rounded, Colors.deepOrange.shade800),
              _card(lang.t('prevention'), info.getPrevention(lang.currentLanguage), Icons.shield_outlined, Colors.teal.shade800),
            ],
          ),
        );
      },
    );
  }

  Widget _card(String title, String content, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          Text(content, style: const TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF2D3748))),
        ],
      ),
    );
  }
}
