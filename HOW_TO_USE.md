# فهمني القرآن - دليل الاستخدام

## 1. رفع الملفات إلى Cloudflare R2

### المتطلبات:
- Python 3.7 أو أحدث
- حساب Cloudflare مع خدمة R2 مفعلة

### الخطوات:

1. **نسخ ملف الإعدادات:**
   ```
   copy .env.example .env
   ```

2. **تعبئة بيانات R2 في ملف `.env`:**
   - افتح `.env` وأدخل بياناتك من لوحة تحكم Cloudflare R2

3. **تشغيل سكريبت الرفع:**
   ```
   upload_r2.bat
   ```
   أو
   ```
   pip install boto3 python-dotenv
   python upload_r2.py
   ```

4. **السكريبت سيقوم بـ:**
   - مسح جميع مجلدات السور
   - رفع الملفات الصوتية فقط (.mp3, .aac, .wav, .ogg)
   - الحفاظ على أسماء الملفات والمجلدات كما هي
   - إنشاء ملف `data.json` تلقائياً
   - رفع `data.json` إلى R2
   - نسخ `data.json` إلى مجلد assets في مشروع Flutter

## 2. تجربة التطبيق (HTML)

افتح ملف `test_app.html` في المتصفح لتجربة التطبيق.

- أول مرة: سيُظهر بيانات تجريبية
- بعد رفع الملفات إلى R2: سيُطلب منك إدخال رابط `data.json`
- يمكنك تغيير الرابط لاحقاً من خلال الضغط على عنوان التطبيق

## 3. تشغيل تطبيق Flutter

### المتطلبات:
- Flutter SDK (الإصدار 3.2.0 أو أحدث)
- Android Studio أو Visual Studio Code

### الخطوات:

```
cd fahemni_alquran
flutter pub get
flutter run
```

### بناء APK:
```
flutter build apk --release
```

## 4. هيكل المشروع

```
فهمني القرآن/
├── upload_r2.py              # سكريبت رفع الملفات إلى R2
├── upload_r2.bat             # أداة تشغيل السكريبت (Windows)
├── .env.example              # نموذج ملف الإعدادات
├── .env                      # إعدادات R2 (خاص - لا تشاركه)
├── data.json                 # ملف البيانات المُنشأ
├── check_structure.cmd       # فحص هيكل المشروع
├── HOW_TO_USE.md             # هذا الملف
├── test_app.html             # نسخة HTML للتجربة
├── السور/                    # مجلدات السور
│   ├── 1 سورة الفاتحة/
│   ├── 2 سورة البقرة/
│   └── ...
└── fahemni_alquran/          # مشروع Flutter
    ├── pubspec.yaml
    ├── lib/
    │   ├── main.dart
    │   ├── config/
    │   │   ├── theme.dart       # ألوان وتصميم إسلامي
    │   │   ├── constants.dart
    │   │   └── routes.dart
    │   ├── models/
    │   │   ├── surah.dart
    │   │   └── audio_item.dart
    │   ├── services/
    │   │   ├── api_service.dart
    │   │   ├── audio_player_service.dart
    │   │   └── storage_service.dart
    │   ├── screens/
    │   │   ├── splash_screen.dart
    │   │   ├── home_screen.dart
    │   │   ├── surah_detail_screen.dart
    │   │   ├── player_screen.dart
    │   │   ├── favorites_screen.dart
    │   │   └── settings_screen.dart
    │   └── widgets/
    │       ├── surah_card.dart
    │       ├── audio_tile.dart
    │       ├── player_bar.dart
    │       └── no_internet_widget.dart
    ├── assets/
    └── android/
```

## 5. الميزات

- عرض جميع السور على شكل بطاقات أنيقة
- تشغيل_streaming_ مباشر من R2
- مشغل صوت احترافي (تشغيل/إيقاف، التالي/السابق، شريط تقدم)
- البحث في السور والملفات
- إضافة الملفات إلى المفضلة
- الوضع الليلي
- حفظ آخر تشغيل
- التعامل مع انقطاع الإنترنت (عرض بيانات من الذاكرة المؤقتة)
- شاشة بداية احترافية
- واجهة إسلامية بلون أخضر داكن وذهبي
