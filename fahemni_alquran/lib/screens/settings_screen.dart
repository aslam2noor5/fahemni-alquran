import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fahemni_alquran/config/theme.dart';
import 'package:fahemni_alquran/config/constants.dart';
import 'package:fahemni_alquran/main.dart';
import 'package:fahemni_alquran/services/storage_service.dart';
import 'package:fahemni_alquran/widgets/app_back_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppBackButton(),
            const SizedBox(height: 8),
            // Appearance section
            _buildSectionHeader('المظهر', Icons.palette),
            Card(
              child: SwitchListTile(
                title: Text(
                  'المظهر الداكن',
                  style: GoogleFonts.notoNaskhArabic(fontSize: 16),
                ),
                subtitle: Text(
                  'التبديل إلى المظهر الفاتح',
                  style: GoogleFonts.notoNaskhArabic(fontSize: 12, color: Colors.grey),
                ),
                secondary: Icon(
                  themeProvider.isDark ? Icons.dark_mode : Icons.light_mode,
                  color: AppTheme.gold,
                ),
                value: themeProvider.isDark,
                onChanged: (value) {
                  themeProvider.setDark(value);
                  context.read<StorageService>().saveString(
                    AppConstants.cacheKeyThemeMode,
                    value ? 'dark' : 'light',
                  );
                },
                activeColor: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 24),

            // About section
            _buildSectionHeader('عن التطبيق', Icons.info_outline),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.menu_book, color: AppTheme.gold),
                    title: Text(
                      'فهمني القرآن',
                      style: GoogleFonts.notoNaskhArabic(fontSize: 16),
                    ),
                    subtitle: Text(
                      'استمع إلى شرح القرآن الكريم',
                      style: GoogleFonts.notoNaskhArabic(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  Divider(color: AppTheme.gold.withValues(alpha: 0.2)),
                  ListTile(
                    leading: Icon(Icons.code, color: AppTheme.gold),
                    title: Text(
                      'الإصدار',
                      style: GoogleFonts.notoNaskhArabic(fontSize: 16),
                    ),
                    trailing: Text(
                      AppConstants.version,
                      style: GoogleFonts.notoNaskhArabic(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Privacy Policy section
            _buildSectionHeader('سياسة الخصوصية', Icons.privacy_tip),
            Card(
              child: ListTile(
                leading: Icon(Icons.description, color: AppTheme.gold),
                title: Text(
                  'سياسة الخصوصية والأذونات',
                  style: GoogleFonts.notoNaskhArabic(fontSize: 16),
                ),
                subtitle: Text(
                  'اضغط لعرض سياسة الخصوصية',
                  style: GoogleFonts.notoNaskhArabic(fontSize: 12, color: Colors.grey),
                ),
                trailing: Icon(Icons.chevron_left, color: AppTheme.gold),
                onTap: () => _showPrivacyPolicy(context),
              ),
            ),
            const SizedBox(height: 24),

            // Support section
            _buildSectionHeader('الدعم', Icons.support),
            Card(
              child: ListTile(
                leading: Icon(Icons.email, color: AppTheme.gold),
                title: Text(
                  'تواصل معنا',
                  style: GoogleFonts.notoNaskhArabic(fontSize: 16),
                ),
                subtitle: Text(
                  'support@fahemni-alquran.app',
                  style: GoogleFonts.notoNaskhArabic(fontSize: 12, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Footer
            Center(
              child: Text(
                'جميع الحقوق محفوظة © 2026',
                style: GoogleFonts.notoNaskhArabic(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppTheme.darkCard
              : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                Text(
                  'سياسة الخصوصية',
                  style: GoogleFonts.notoNaskhArabic(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'آخر تحديث: يوليو 2026',
                  style: GoogleFonts.notoNaskhArabic(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _policySection('1. مقدمة',
                            'تطبيق "فهمني القرآن" يحترم خصوصيتك. هذه السياسة توضح كيفية جمع واستخدام وحماية معلوماتك عند استخدام التطبيق على أندرويد.'),
                        _policySection('2. الأذونات التي يطلبها التطبيق',
                            'قد يطلب التطبيق الأذونات التالية لتقديم الخدمات المطلوبة:\n\n• الموقع (الوصف التقريبي): يُستخدم فقط لحساب اتجاه القبلة ومواقيت الصلاة بدقة. لا يتم تخزينه أو إرساله إلى أي خادم. يمكنك تعطيل هذا الإذن من إعدادات جهازك في أي وقت.\n\n• الإشعارات: تُستخدم لإرسال تنبيهات بمواقيت الصلاة إذا اخترت تفعيلها.\n\n• الإنترنت: يُستخدم لتحميل بيانات القرآن والأذكار وصوتيات التفسير.\n\n• الصوت: يُستخدم لتشغيل التلاوات القرآنية والمحاضرات.'),
                        _policySection('3. المعلومات التي نجمعها',
                            'نحن لا نجمع أي معلومات شخصية من المستخدمين. التطبيق لا يطلب منك إنشاء حساب أو إدخال بيانات شخصية مثل الاسم أو البريد الإلكتروني أو رقم الهاتف. جميع البيانات تبقى محلياً على جهازك ولا يتم إرسالها إلى أي خوادم تخصنا.'),
                        _policySection('4. كيفية استخدام المعلومات',
                            'الموقع الجغرافي يُستخدم محلياً على جهازك فقط لحساب القبلة ومواقيت الصلاة. لا يتم إرسال هذه البيانات إلى أي جهة خارجية.'),
                        _policySection('5. التخزين المحلي',
                            'يستخدم التطبيق التخزين المحلي على جهاز الأندرويد لحفظ تفضيلاتك مثل: المظهر (داكن/فاتح)، إعدادات تنبيهات الصلاة، حالة الأذكار والتسبيح، والمفضلة.\n\nجميع هذه البيانات تبقى على جهازك ويمكن مسحها من إعدادات الجهاز > التطبيقات > فهمني القرآن > مسح التخزين.'),
                        _policySection('6. خدمات الطرف الثالث',
                            'يستخدم التطبيق الخدمات التالية التي قد تتطلب الاتصال بالإنترنت:\n\n• Aladhan API: لحساب مواقيت الصلاة.\n• Al Quran Cloud API: لعرض نص القرآن الكريم.\n• GitHub: لاستضافة ملفات التطبيق وصوتيات التفسير.'),
                        _policySection('7. ملفات تعريف الارتباط',
                            'التطبيق لا يستخدم ملفات تعريف الارتباط (cookies) لأنه تطبيق أندرويد وليس موقع ويب.'),
                        _policySection('8. أمان البيانات',
                            'نحن نتخذ التدابير الأمنية المناسبة لحماية بياناتك، بما في ذلك عدم جمع أي بيانات شخصية واستخدام التخزين المحلي فقط. التطبيق لا يتصل بأي خوادم تخصنا ولا يشارك بياناتك مع أي طرف ثالث لأغراض تسويقية.'),
                        _policySection('9. تحديثات سياسة الخصوصية',
                            'قد نقوم بتحديث هذه السياسة من وقت لآخر. سيتم إشعارك بأي تغييرات عبر تحديث تاريخ "آخر تحديث" في أعلى هذه الصفحة.'),
                        _policySection('10. الاتصال بنا',
                            'إذا كان لديك أي استفسار، يمكنك التواصل معنا عبر البريد الإلكتروني: support@fahemni-alquran.app'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text('إغلاق', style: GoogleFonts.notoNaskhArabic()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _policySection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.notoNaskhArabic(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.gold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: GoogleFonts.notoNaskhArabic(
              fontSize: 13,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.gold, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.notoNaskhArabic(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}
