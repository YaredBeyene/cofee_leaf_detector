# Coffee Leaf Doctor (የቡና ቅጠል በሽታ መለያ ሞባይል አፕ)

የቡና ቅጠል በሽታን በስልኩ ካሜራ ወይም ከጋለሪ ፎቶ በማንሳት በ **TensorFlow Lite (`coffee_disease_model.tflite`)** በሰከንዶች ውስጥ በስልኩ ላይ ብቻ (ሙሉ Offline) የሚለይ የሞባይል አፕሊኬሽን።

---

## 📁 የፕሮጀክቱ ፋይሎች አቀማመጥ (Project Structure)
```
coffee_leaf_app/
├── assets/
│   ├── coffee_disease_model.tflite  <-- ከ Downloads እዚህ ይቅዱት
│   └── labels.txt                   <-- ተዘጋጅቷል (5ቱ ክፍሎች)
├── lib/
│   ├── classifier.dart              <-- ፎቶውን ወደ 128x128 ቀይሮ በሞዴሉ የሚመረምረው
│   └── main.dart                    <-- የሞባይል አፑ UI (ካሜራ፣ ጋለሪ፣ ውጤት ማሳያ)
├── android/
│   └── app/src/main/AndroidManifest.xml <-- የካሜራ እና የፎቶ ፈቃዶች
└── pubspec.yaml
```

---

## 🚀 አፑን ለማስጀመር (How to Run)

### 1. የሞዴል ፋይሉን ማስገባት (Copy Model)
ከ Google Colab ያወረዱትን **`coffee_disease_model.tflite`** ፋይል ወደዚህ ፎልደር ይቅዱት (Copy/Paste)፦
`coffee_leaf_app/assets/coffee_disease_model.tflite`

### 2. ፕሮጀክቱን መክፈት
ይህን ፎልደር (`C:\Users\Yared\.gemini\antigravity\scratch\coffee_leaf_app`) በ **VS Code** ወይም በ **Android Studio** ይክፈቱት።

### 3. Dependencies መጫን
በተርሚናል (Terminal) ላይ የሚከተለውን ያሂዱ፦
```bash
flutter pub get
```

### 4. አፑን ማስጀመር
ስልክዎን በ USB ገመድ ከኮምፒውተር ጋር አገናኝተው (ወይም Emulator ከፍተው)፦
```bash
flutter run
```
