// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'MyQuran';

  @override
  String get homeEyebrow => 'القرآن الكريم';

  @override
  String get homeTitle => 'الرئيسية';

  @override
  String get homeCaption => 'اقرأ القرآن بطمأنينة — بدون اتصال بالإنترنت.';

  @override
  String get continueEyebrow => 'متابعة القراءة';

  @override
  String get continueButton => 'متابعة';

  @override
  String get noHistoryTitle => 'لا يوجد سجل قراءة بعد.';

  @override
  String get startFromFatihah => 'ابدأ من سورة الفاتحة';

  @override
  String get surahSegment => 'سورة';

  @override
  String get juzSegment => 'جزء';

  @override
  String get ayatCount => 'آيات';

  @override
  String get homeGreeting => 'السلام عليكم،';

  @override
  String get lastReadLabel => 'آخر قراءة';

  @override
  String get prayerScheduleTitle => 'مواقيت الصلاة';

  @override
  String get dailyVerseLabel => 'آية اليوم';

  @override
  String get dailyVerseError => 'فشل في تحميل آية اليوم.';

  @override
  String get shareVerse => 'شارك هذه الآية';

  @override
  String get qaKiblat => 'القبلة';

  @override
  String get qaDoaHarian => 'أدعية يومية';

  @override
  String get qaZakat => 'الزكاة';

  @override
  String get qaMasjidTerdekat => 'أقرب مسجد';

  @override
  String get comingSoon => 'قريباً';

  @override
  String get doaSetelahSholatTitle => 'أدعية بعد الصلاة';

  @override
  String get doaSetelahSholatCaption =>
      'مجموعة أدعية وأذكار تُقرأ بعد صلوات الفروض الخمس';

  @override
  String get doaSetelahSholatHomeTitle => 'أدعية بعد الصلاة';

  @override
  String get doaSetelahSholatHomeSubtitle =>
      'أذكار وأدعية بعد الصلوات المفروضة';

  @override
  String get prayerTimesEyebrow => 'مواقيت الصلاة';

  @override
  String get nextPrayerLabel => 'الصلاة القادمة';

  @override
  String get prayerCountdownPrefix => 'بعد';

  @override
  String get prayerScreenTitle => 'مواقيت الصلاة';

  @override
  String get qiblaTitle => 'اتجاه القبلة';

  @override
  String get qiblaCaption => 'وجّه الإبرة نحو القبلة';

  @override
  String get qiblaAlignHint => 'وجّه جهازك نحو القبلة';

  @override
  String get sunriseLabel => 'الشروق';

  @override
  String get changeLocation => 'تغيير';

  @override
  String get locationUpdated => 'تم تحديث الموقع';

  @override
  String get navSholat => 'الصلاة';

  @override
  String get prayerError => 'فشل في تحميل مواقيت الصلاة.';

  @override
  String get retry => 'حاول مرة أخرى';

  @override
  String get notificationsSection => 'الإشعارات';

  @override
  String get prayerNotificationsLabel => 'إشعارات مواقيت الصلاة';

  @override
  String get prayerNotificationsSublabel => 'تذكير تلقائي عند دخول وقت الصلاة';

  @override
  String get prayerNotificationsDenied =>
      'تم رفض إذن الإشعارات. قم بتفعيله من إعدادات النظام.';

  @override
  String get prayerNotificationsTest => 'اختبار الإشعار';

  @override
  String get prayerNotificationsTestSublabel => 'إرسال إشعار تجريبي الآن';

  @override
  String get prayerNotificationsTestSend => 'إرسال';

  @override
  String get prayerNotificationsTestTitle => 'وقت الصلاة';

  @override
  String get prayerNotificationsTestBody =>
      'هذا إشعار تجريبي. إشعارات مواقيت الصلاة مفعلة.';

  @override
  String get prayerNotificationsTestSent => 'تم إرسال الإشعار التجريبي';

  @override
  String get dzikirReminderLabel => 'أذكار الصباح والمساء';

  @override
  String get dzikirReminderSublabel => 'تذكير يومي بأذكار الصباح والمساء';

  @override
  String get dzikirReminderDenied =>
      'تم رفض إذن الإشعارات. قم بتفعيله من إعدادات النظام.';

  @override
  String get hijriEventReminderLabel => 'تذكير المناسبات الهجرية';

  @override
  String get hijriEventReminderSublabel =>
      'تذكير تلقائي في أيام المناسبات المهمة في التقويم الإسلامي';

  @override
  String get hijriEventReminderDenied =>
      'تم رفض إذن الإشعارات. قم بتفعيله من إعدادات النظام.';

  @override
  String get dzikirReminderMorningTitle => 'أذكار الصباح';

  @override
  String get dzikirReminderMorningBody => 'حان وقت قراءة أذكار الصباح.';

  @override
  String get dzikirReminderEveningTitle => 'أذكار المساء';

  @override
  String get dzikirReminderEveningBody => 'حان وقت قراءة أذكار المساء.';

  @override
  String get adzanVoiceLabel => 'صوت الأذان';

  @override
  String get adzanVoiceDownloading => 'جارٍ تحميل صوت الأذان...';

  @override
  String get adzanVoiceChanged => 'تم تحديث صوت الأذان';

  @override
  String get adzanVoiceDownloadFailed =>
      'فشل في تحميل صوت الأذان. تحقق من اتصال الإنترنت.';

  @override
  String get adzanVoiceSholatLabel => 'صوت أذان الصلاة';

  @override
  String get adzanVoiceFajrLabel => 'صوت أذان الفجر';

  @override
  String get adzanVoiceSholatHint => 'يُستخدم للصلوات غير الفجر';

  @override
  String get adzanVoiceFajrHint => 'يُستخدم خصيصاً لأذان الفجر';

  @override
  String get adzanTestSholat => 'صوت الصلاة';

  @override
  String get adzanTestFajr => 'صوت الفجر';

  @override
  String get testHijriEvent => 'المناسبة الهجرية';

  @override
  String get browseEyebrow => 'القراءة';

  @override
  String get browseTitle => 'القرآن الكريم';

  @override
  String get browseCaption =>
      'استكشف 114 سورة، 30 جزءاً، أو ابحث عن آيات وترجمات.';

  @override
  String get surahListTitle => 'قائمة السور';

  @override
  String get juzListTitle => 'قائمة الأجزاء';

  @override
  String get quickAccessEyebrow => 'القائمة الكاملة';

  @override
  String get quickSurahCaption => '114 سورة';

  @override
  String get quickJuzCaption => '30 جزءاً';

  @override
  String get makkiyah => 'مكية';

  @override
  String get madaniyah => 'مدنية';

  @override
  String get browseSearchHint => 'ابحث عن سورة أو آية...';

  @override
  String get favoritSegment => 'المفضلة';

  @override
  String get favoritEmptyTitle => 'لا توجد سور مفضلة بعد';

  @override
  String get favoritEmptyMessage =>
      'حدد الآيات أثناء القراءة — السور المُعلَّمة ستظهر هنا.';

  @override
  String get penandaCount => 'علامات';

  @override
  String get back => 'رجوع';

  @override
  String get fontSmaller => 'تصغير النص العربي (Ctrl −)';

  @override
  String get fontLarger => 'تكبير النص العربي (Ctrl +)';

  @override
  String get jumpToAyah => 'الانتقال إلى آية';

  @override
  String get jumpLabel => 'آية';

  @override
  String get jumpHint => '1–';

  @override
  String get jumpOutOfRange => 'الرقم خارج النطاق';

  @override
  String get jumpButton => 'انتقال';

  @override
  String get cancel => 'إلغاء';

  @override
  String get tafsirAction => 'تفسير';

  @override
  String get tafsirHeader => 'تفسير · وزارة الشؤون الدينية الإندونيسية';

  @override
  String get bookmarkAyah => 'تحديد هذه الآية';

  @override
  String get removeBookmark => 'إزالة العلامة';

  @override
  String get endOfSurah => 'انتهت القراءة';

  @override
  String get nextSurah => 'السورة التالية';

  @override
  String get backToHome => 'العودة للرئيسية';

  @override
  String surahMeta(int number, int ayahCount) {
    return 'سورة $number • $ayahCount آيات';
  }

  @override
  String get playAyah => 'تشغيل هذه الآية';

  @override
  String get shareAyah => 'مشاركة الآية';

  @override
  String get readerSettings => 'إعدادات القراءة';

  @override
  String get hideTranslation => 'إخفاء الترجمة';

  @override
  String get audioReciter => 'مشاري العفاسي';

  @override
  String audioCaption(String surah, int ayah) {
    return 'سورة $surah — آية $ayah';
  }

  @override
  String get audioPlay => 'تشغيل';

  @override
  String get audioPause => 'إيقاف مؤقت';

  @override
  String get audioPrev => 'السابق';

  @override
  String get audioNext => 'التالي';

  @override
  String get audioSpeedLabel => 'سرعة التشغيل';

  @override
  String get audioVolume => 'مستوى الصوت';

  @override
  String get audioQueue => 'قائمة التشغيل';

  @override
  String get audioClose => 'إغلاق المشغل';

  @override
  String get audioError => 'فشل في تشغيل الصوت. تحقق من اتصال الإنترنت.';

  @override
  String get murottalDownload => 'تحميل تلاوة هذه السورة';

  @override
  String get murottalDownloading => 'جارٍ تحميل التلاوة...';

  @override
  String get murottalCancel => 'إلغاء التحميل';

  @override
  String get murottalDownloaded => 'تم حفظ التلاوة — اضغط لإزالتها';

  @override
  String get murottalDeleteConfirmTitle => 'حذف التلاوة؟';

  @override
  String get murottalDeleteConfirmMessage => 'حذف تسجيل هذه السورة من جهازك؟';

  @override
  String get murottalDelete => 'حذف';

  @override
  String get murottalDownloadFailed =>
      'فشل في تحميل التلاوة. تحقق من اتصال الإنترنت.';

  @override
  String get murottalDownloadDone =>
      'تم حفظ تلاوة هذه السورة للتشغيل بدون إنترنت.';

  @override
  String get searchHint => 'ابحث عن سورة أو آية أو ترجمة';

  @override
  String get openSearch => 'بحث';

  @override
  String get closeSearch => 'إغلاق البحث';

  @override
  String get searchGroupSurah => 'سور';

  @override
  String get searchGroupAyah => 'آيات';

  @override
  String get searchGroupTranslation => 'ترجمات';

  @override
  String get noResultsTitle => 'لا توجد نتائج';

  @override
  String get noResultsHint => 'تحقق من الإملاء أو جرّب كلمات أخرى';

  @override
  String get popularSurahs => 'سور مشهورة';

  @override
  String get bookmarksEyebrow => 'العلامات';

  @override
  String get bookmarksTitle => 'المفضلة والعلامات';

  @override
  String get bookmarksCaption => 'الآيات التي حددتها محفوظة على هذا الجهاز.';

  @override
  String get bookmarksEmptyTitle => 'لا توجد علامات بعد';

  @override
  String get bookmarksEmptyMessage =>
      'حدد الآيات بالنقر على الأيقونة أثناء القراءة — ستظهر هنا.';

  @override
  String get startReading => 'ابدأ القراءة';

  @override
  String get removeBookmarkConfirm => 'إزالة هذه العلامة؟';

  @override
  String get remove => 'إزالة';

  @override
  String get favoritTab => 'المفضلة';

  @override
  String get penandaTab => 'العلامات';

  @override
  String juzPage(int juz, int page) {
    return 'الجزء $juz • الصفحة $page';
  }

  @override
  String get todayLabel => 'اليوم';

  @override
  String get yesterdayLabel => 'أمس';

  @override
  String daysAgo(int n) {
    return 'منذ $n أيام';
  }

  @override
  String weeksAgo(int n) {
    return 'منذ $n أسابيع';
  }

  @override
  String get bookmarksFavoritEmptyTitle => 'لا توجد مفضلات بعد';

  @override
  String get bookmarksFavoritEmptyMessage =>
      'حدد الآيات بالنقر على الأيقونة أثناء القراءة — مفضلاتك ستظهر هنا.';

  @override
  String get bookmarksPenandaEmptyTitle => 'لا توجد علامات بعد';

  @override
  String get bookmarksPenandaEmptyMessage =>
      'سيظهر سجل قراءتك هنا بعد قراءة سورة.';

  @override
  String get settingsEyebrow => 'الإعدادات';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsCaption => 'خصص المظهر والإشعارات والبيانات حسب تفضيلاتك.';

  @override
  String get appearanceSection => 'المظهر';

  @override
  String get themeModeLabel => 'وضع المظهر';

  @override
  String get themeModeSublabel => 'اتبع مظهر نظام التشغيل.';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get quranFontSizeLabel => 'حجم النص العربي';

  @override
  String get quranFontSizeSublabel =>
      'أكبر لراحة القراءة عن بُعد؛ الترجمات تتكيف تلقائياً.';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get showTranslationLabel => 'إظهار الترجمة';

  @override
  String get alignLabel => 'محاذاة النص العربي';

  @override
  String get alignRight => 'محاذاة لليمين';

  @override
  String get alignCenter => 'محاذاة للوسط';

  @override
  String get alignNote => 'المحاذاة الوسطى يمكن أن تساعد في الآيات القصيرة.';

  @override
  String get readingSection => 'القراءة';

  @override
  String get tafsirDefaultLabel => 'فتح التفسير الافتراضي';

  @override
  String get tajwidColorLabel => 'ألوان التجويد';

  @override
  String get tajwidColorSublabel => 'تلوين أحكام التجويد في نص القرآن.';

  @override
  String get tajwidColorTooltip => 'ألوان التجويد';

  @override
  String get restoreLastReadLabel => 'استعادة آخر موضع قراءة';

  @override
  String get dataSection => 'البيانات والمصادر';

  @override
  String get dataSourceLabel =>
      'النص والترجمة والتفسير — وزارة الشؤون الدينية الإندونيسية. جميع البيانات مخزنة بدون إنترنت على جهازك.';

  @override
  String get dataVersionLabel => 'إصدار البيانات';

  @override
  String get licenseLabel => 'الرخصة';

  @override
  String get shortcutsSection => 'اختصارات لوحة المفاتيح';

  @override
  String get shortcutSearch => 'بحث — Ctrl K';

  @override
  String get shortcutZoomIn => 'تكبير النص العربي — Ctrl +';

  @override
  String get shortcutZoomOut => 'تصغير النص العربي — Ctrl −';

  @override
  String get shortcutClose => 'إغلاق اللوحة — Esc';

  @override
  String get resetDataSection => 'بيانات المستخدم';

  @override
  String get resetDataLabel => 'إعادة تعيين البيانات';

  @override
  String get resetDataSublabel =>
      'حذف سجل القراءة، هدف الختم، سجود التلاوة، موضع القراءة، والعلامات.';

  @override
  String get resetDataConfirmTitle => 'إعادة تعيين جميع البيانات؟';

  @override
  String get resetDataConfirmMessage =>
      'سيتم حذف سجل القراءة، هدف الختم، سجود التلاوة، موضع القراءة، والعلامات نهائياً. لن تتأثر نصوص القرآن وإعدادات المظهر.';

  @override
  String get resetDataConfirm => 'إعادة تعيين البيانات';

  @override
  String get resetDataDone => 'تمت إعادة تعيين بيانات المستخدم بنجاح.';

  @override
  String get reciterLabel => 'القارئ';

  @override
  String get reciterDefault => 'مشاري راشد العفاسي';

  @override
  String get reciterDialogTitle => 'اختيار القارئ';

  @override
  String get reciterChanged => 'تم تغيير القارئ بنجاح';

  @override
  String get reciterLoadFailed => 'فشل في تحميل قائمة القراء';

  @override
  String get statsEyebrow => 'الإحصائيات';

  @override
  String get statsTitle => 'الإحصائيات';

  @override
  String get statsCaption => 'أثر قراءتك وتقدم ختمك، محفوظ على هذا الجهاز.';

  @override
  String get statsError => 'فشل في تحميل البيانات.';

  @override
  String get statsStreakLabel => 'أيام متتالية';

  @override
  String get statsTodayLabel => 'آيات مقروءة اليوم';

  @override
  String get statsKhatamEyebrow => 'تقدم الختم';

  @override
  String get statsJuzsOf => 'من 30 جزءاً';

  @override
  String get statsKhatamCaption =>
      'اقرأ جزءاً واحداً يومياً للختم في 30 يوماً.';

  @override
  String get statsTotalDaysLabel => 'إجمالي أيام القراءة';

  @override
  String get statsTotalAyahsLabel => 'إجمالي الآيات المقروءة';

  @override
  String get khatamPlan30 => 'ختم في 30 يوماً';

  @override
  String get khatamPickDate => 'اختر تاريخاً';

  @override
  String get khatamJuz => 'جزء';

  @override
  String get khatamJuzToday => 'اليوم';

  @override
  String get khatamDaysLeft => 'المتبقي';

  @override
  String get khatamDays => 'أيام';

  @override
  String get khatamTargetLabel => 'الهدف';

  @override
  String get khatamClear => 'حذف الهدف';

  @override
  String get khatamClearConfirm => 'حذف هدف الختم هذا؟';

  @override
  String get khatamDone => 'تم تحقيق هدف الختم';

  @override
  String get calendarEyebrow => 'تقويم القراءة';

  @override
  String get calendarTitle => 'آخر 30 يوماً';

  @override
  String get calendarCaption => 'الآيات المقروءة يومياً — آخر 30 يوماً.';

  @override
  String get calendarFew => 'قليل';

  @override
  String get calendarMany => 'كثير';

  @override
  String get sujudLabel => 'سجود التلاوة';

  @override
  String get sujudOf => 'من 15 سجود تلاوة';

  @override
  String get sujudMark => 'تحديد سجود التلاوة';

  @override
  String get sujudUnmark => 'إزالة علامة السجود';

  @override
  String get zenEnter => 'وضع التركيز (Ctrl B)';

  @override
  String get zenExit => 'الخروج من وضع التركيز (Esc)';

  @override
  String get zenSnackbarExitHint => 'الخروج بـ Esc أو Ctrl B.';

  @override
  String get copyAyah => 'نسخ';

  @override
  String get copyAyahDone => 'تم نسخ الآية إلى الحافظة.';

  @override
  String get historyEyebrow => 'سجل القراءة';

  @override
  String get historyProgressOf => 'من';

  @override
  String get historyReadLabel => 'آية';

  @override
  String get changeTheme => 'تغيير المظهر';

  @override
  String get paperThemeLabel => 'لون الورق';

  @override
  String get paperThemeSublabel =>
      'لون ورق عمود القراءة — دافئ في كلا الوضعين.';

  @override
  String get paperHangat => 'دافئ';

  @override
  String get paperKlasik => 'كلاسيكي';

  @override
  String get paperPucat => 'فاتح';

  @override
  String get tahlilTitle => 'التهليل والأدعية';

  @override
  String get tahlilCaption => 'قراءات التهليل الكاملة مع الأدعية';

  @override
  String get ratibTitle => 'الرتاب الحداد';

  @override
  String get ratibCaption => 'ورد المساء للحبيب عبدالله الحداد';

  @override
  String get spiritualNav => 'الأوراد والأدعية';

  @override
  String get dzikirTitle => 'أذكار الصباح والمساء';

  @override
  String get dzikirCaption => 'أذكار الصباح والمساء مع أدعية';

  @override
  String get dzikirPagi => 'الصباح';

  @override
  String get dzikirPetang => 'المساء';

  @override
  String get dzikirEmpty => 'لم يتم العثور على أذكار';

  @override
  String get niatShalatTitle => 'نيّة الصلاة';

  @override
  String get niatShalatCaption => 'نيّات الصلوات المفروضة والمستحبة';

  @override
  String get tadabburTitle => 'التدبر اليومي';

  @override
  String get tadabburCaption => 'تأملات يومية في آيات القرآن';

  @override
  String get tadabburReflection => 'التأمل';

  @override
  String get asmaulHusnaTitle => 'الاسماء الحسنى';

  @override
  String get asmaulHusnaCaption => 'أسماء الله الحسنى ومعانيها';

  @override
  String get asmaulHusnaSearchHint => 'ابحث عن اسم أو معنى...';

  @override
  String get asmaulHusnaEmpty => 'لم يتم العثور عليه';

  @override
  String get asmaulHusnaEmptyHint => 'جرّب كلمات أخرى.';

  @override
  String get asmaulHusnaArti => 'المعنى';

  @override
  String get asmaulHusnaCatatan => 'ملاحظة';

  @override
  String get asmaulHusnaClose => 'إغلاق';

  @override
  String get doaHarianTitle => 'الأدعية اليومية';

  @override
  String get doaHarianCaption => 'مجموعة أدعية يومية مع النص العربي والترجمة.';

  @override
  String get doaSearchHint => 'ابحث عن دعاء...';

  @override
  String get doaEmpty => 'لم يتم العثور عليه';

  @override
  String get doaEmptyHint => 'جرّب كلمات أو فئات أخرى.';

  @override
  String get doaBookmarkAdd => 'تحديد هذا الدعاء';

  @override
  String get doaBookmarkRemove => 'إزالة علامة الدعاء';

  @override
  String get tahlilHeaderTitle => 'قراءة التهليل';

  @override
  String get tahlilHeaderDesc =>
      'التهليل هو سلسلة من الأذكار والأدعية تُقرأ لطلب المغفرة والرحمة من الله سبحانه وتعالى، وغالباً تُوجَّه للأموات. اقرأ بخشوع وطمأنينة.';

  @override
  String get audioComingSoon => 'الصوت قريباً';

  @override
  String readNTimes(int n) {
    return 'تُقرأ $n مرات';
  }

  @override
  String get ratibulHaddadTitle => 'رتاب الحداد';

  @override
  String get ratibIntroChip => 'مقدمة';

  @override
  String get ratibIntroDesc =>
      'ألفه الحبيب عبدالله بن علي بن محمد الحداد. الرتاب هو مجموعة من الأدعية والأذكار مأخوذة من القرآن الكريم والحديث النبوي، تُقرأ لطلب الحفظ والبركة والقرب من الله سبحانه وتعالى.';

  @override
  String get ratibFullTitle => 'رتاب الحداد الكامل';

  @override
  String get playingLabel => 'جارٍ التشغيل';

  @override
  String get counterLabel => 'العدّاد';

  @override
  String get counterReset => 'إعادة تعيين العداد';

  @override
  String get amalanIbadahTitle => 'العبادات اليومية';

  @override
  String get amalanIbadahCaption =>
      'حدد عباداتك اليومية وتتبع تقدم عبادتك كل يوم';

  @override
  String get amalanGoalProgress => 'تقدم الهدف اليومي';

  @override
  String get amalanGoalSubtitle => 'حافظ على الحماس!';

  @override
  String amalanProgress(int done, int total) {
    return '$done/$total مكتمل';
  }

  @override
  String get amalanSearchHint => 'ابحث عن عبادة...';

  @override
  String get amalanLearnMore => 'اعرف المزيد';

  @override
  String get amalanDetailPenjelasan => 'الشرح';

  @override
  String get amalanDetailDalil => 'الدليل';

  @override
  String get amalanEmpty => 'لم يتم العثور عليه';

  @override
  String get amalanEmptyHint => 'جرّب كلمات أو فئات أخرى.';

  @override
  String get amalanCatSemua => 'الكل';

  @override
  String get amalanCatWajib => 'واجب';

  @override
  String get amalanCatSunnah => 'سنة';

  @override
  String get amalanCatDzikir => 'ذكر';

  @override
  String get amalanCatSosial => 'اجتماعي';

  @override
  String get amalanToggleDone => 'تحديد كمكتمل';

  @override
  String get amalanToggleUndone => 'تحديد كغير مكتمل';

  @override
  String get masjidTerdekatTitle => 'أقرب مسجد';

  @override
  String get masjidSearchHint => 'ابحث عن مسجد أو موقع...';

  @override
  String get masjidFilterHint => 'تصفية';

  @override
  String get masjidCatSemua => 'الكل';

  @override
  String get masjidCatParkirLuas => 'موقف واسع';

  @override
  String get masjidCatToilet => 'دورة مياه';

  @override
  String get masjidCatAc => 'تكييف';

  @override
  String get masjidCatDisabilitas => 'مناسب لذوي الاحتياجات';

  @override
  String get masjidRute => 'المسار';

  @override
  String get masjidDetail => 'التفاصيل';

  @override
  String get masjidLoading => 'جارٍ البحث عن المساجد القريبة...';

  @override
  String get masjidError => 'فشل في تحميل بيانات المسجد';

  @override
  String get masjidErrorHint => 'تحقق من اتصال الإنترنت وحاول مرة أخرى.';

  @override
  String get masjidRetry => 'حاول مرة أخرى';

  @override
  String get masjidEmpty => 'لم يتم العثور على مساجد';

  @override
  String get masjidEmptyHint => 'جرّب تغيير الكلمة أو التصفية.';

  @override
  String get masjidLocationUnavailable => 'الموقع غير متاح';

  @override
  String get masjidLocationUnavailableHint =>
      'فعّل إذن الموقع للبحث عن المساجد القريبة.';

  @override
  String get masjidLocationLinuxHint =>
      'هذه الميزة تتطلب جهازاً بتثبيت GPS وليست متاحة على سطح المكتب.';

  @override
  String get masjidRecenter => 'العودة إلى موقعك';

  @override
  String get masjidDetailAddress => 'العنوان';

  @override
  String get masjidDetailDistance => 'المسافة';

  @override
  String get masjidDetailAmenities => 'المرافق';

  @override
  String get masjidDetailHours => 'ساعات العمل';

  @override
  String get masjidNoAddress => 'لا يوجد عنوان مدرج';

  @override
  String get masjidNoAmenities => 'لا توجد معلومات عن المرافق';

  @override
  String get masjidRouteError => 'لا يمكن فتح تطبيق الخرائط';

  @override
  String get masjidCachedNote =>
      'البيانات محفوظة — فشل الاتصال، عرض آخر النتائج.';

  @override
  String get personalityTitle => 'تحليل الشخصية';

  @override
  String get personalityHeaderTitle => 'الشخصية الروحية';

  @override
  String get personalitySubtitle => 'ملخص أنماط قراءتك من سجل قراءة القرآن.';

  @override
  String get personalityError => 'فشل في تحميل التحليل.';

  @override
  String get personalityDnaTitle => 'حمض قراءتك';

  @override
  String get personalityThemeSabar => 'الصبر والشكر';

  @override
  String get personalityThemeKisah => 'قصص الأنبياء';

  @override
  String get personalityThemeTauhid => 'التوحيد والعقيدة';

  @override
  String get personalityActiveSlotLabel => 'وقت النشاط';

  @override
  String get personalitySlotSubuh => 'الفجر';

  @override
  String get personalitySlotPagi => 'الصباح';

  @override
  String get personalitySlotSiang => 'الظهيرة';

  @override
  String get personalitySlotSore => 'العصر';

  @override
  String get personalitySlotMalam => 'الليل';

  @override
  String get personalityFavoriteLabel => 'السورة المفضلة';

  @override
  String get personalityNextTitle => 'الخطوات التالية';

  @override
  String get personalityNextButton => 'ابدأ القراءة';

  @override
  String get personalityEmptyTitle => 'لا توجد بيانات قراءة بعد';

  @override
  String get personalityEmptyMessage =>
      'يتم حساب هذا التحليل من سجل القراءة المحفوظ. ابدأ القراءة لرؤية نتائجك.';

  @override
  String get personalityEmptyCta => 'ابدأ القراءة';

  @override
  String get statsPersonalityTitle => 'تحليل الشخصية';

  @override
  String get statsPersonalityCaption =>
      'أنماط قراءتك: حمض القراءة، وقت النشاط، والسورة المفضلة.';

  @override
  String get learningTitle => 'مركز التعلم';

  @override
  String get learningSearchHint => 'ابحث عن مواد تعليمية...';

  @override
  String get learningSearchEmpty => 'لم يتم العثور على مواد مطابقة';

  @override
  String get learningSearchEmptyHint => 'جرّب كلمات أخرى.';

  @override
  String get learningKategoriTitle => 'فئات التعلم';

  @override
  String get learningHeroLabel => 'متابعة التعلم';

  @override
  String get learningSelesai => 'مكتمل';

  @override
  String get learningLangkah => 'خطوة';

  @override
  String get learningLangkahDari => 'من';

  @override
  String get learningCourseCount => 'دورات';

  @override
  String get learningDaftarLangkah => 'قائمة الخطوات';

  @override
  String get learningMarkDone => 'تحديد كمكتمل';

  @override
  String get learningMarkUndone => 'تحديد كغير مكتمل';

  @override
  String get learningNextLesson => 'الخطوة التالية';

  @override
  String get learningBackToCourse => 'العودة للدورة';

  @override
  String get learningCatShalat => 'تعلم الصلاة';

  @override
  String get learningCatShalatSub => 'الوضوء، الحركات، الدعاء';

  @override
  String get learningCatNgaji => 'تعلم تلاوة القرآن';

  @override
  String get learningCatNgajiSub => 'الحروف الهجائية، التجويد الأساسي';

  @override
  String get learningCatEdukasi => 'التعليم الإسلامي';

  @override
  String get learningCatEdukasiSub => 'الآداب، تاريخ الأنبياء';

  @override
  String get learningHomeEntryTitle => 'مركز التعلم';

  @override
  String get learningHomeEntrySubtitle =>
      'تعلم الصلاة، تلاوة القرآن، والتعليم الإسلامي.';

  @override
  String get hijriTitle => 'التقويم الهجري';

  @override
  String get qaKalenderHijriah => 'التقويم الهجري';

  @override
  String get hijriYearSuffix => 'هـ';

  @override
  String get gregorianYearSuffix => 'م';

  @override
  String get hijriWeekdaySen => 'إثنين';

  @override
  String get hijriWeekdaySel => 'ثلاثاء';

  @override
  String get hijriWeekdayRab => 'أربعاء';

  @override
  String get hijriWeekdayKam => 'خميس';

  @override
  String get hijriWeekdayJum => 'جمعة';

  @override
  String get hijriWeekdaySab => 'سبت';

  @override
  String get hijriWeekdayAhad => 'أحد';

  @override
  String get hijriTodayLabel => 'اليوم';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get profileNameDefault => 'المستخدم';

  @override
  String get profileNameDialogTitle => 'تغيير الاسم';

  @override
  String get profileNameHint => 'اسمك';

  @override
  String get profileSave => 'حفظ';

  @override
  String get profileSurahRead => 'سور مقروءة';

  @override
  String get profileAyahRead => 'آيات مقروءة';

  @override
  String get profileStreakDays => 'أيام متتالية';

  @override
  String get profileHistoryTitle => 'سجل القراءة الأخير';

  @override
  String get profileHistoryEmpty => 'لا يوجد سجل قراءة بعد.';

  @override
  String get profileHistoryEmptyHint => 'ابدأ القراءة لرؤية سجلك هنا.';

  @override
  String get profileSettingsTitle => 'الإعدادات';

  @override
  String get profileThemeLabel => 'الإعدادات';

  @override
  String get profileLanguageLabel => 'اللغة';

  @override
  String get profileLanguageValue => 'العربية';

  @override
  String get profileTimeJustNow => 'الآن';

  @override
  String get profileTimeMinutesAgo => 'دقائق مضت';

  @override
  String get profileTimeHoursAgo => 'ساعات مضت';

  @override
  String get profileTimeYesterday => 'أمس';

  @override
  String get profileTimeDaysAgo => 'أيام مضت';

  @override
  String get zakatTitle => 'حاسبة الزكاة';

  @override
  String get zakatSubtitle =>
      'احسب زكاة الفطر، المال، الذهب والفضة، الدخل، والزراعة';

  @override
  String get zakatTabFitrah => 'الفطر';

  @override
  String get zakatTabMal => 'المال';

  @override
  String get zakatTabEmasPerak => 'الذهب والفضة';

  @override
  String get zakatTabPenghasilan => 'الدخل';

  @override
  String get zakatTabPertanian => 'الزراعة';

  @override
  String get zakatJumlahJiwa => 'عدد الأشخاص';

  @override
  String get zakatHargaBeras => 'سعر الأرز للكيلو (ر.إ)';

  @override
  String get zakatTotalHarta => 'إجمالي المال (ر.إ)';

  @override
  String get zakatHargaEmas => 'سعر الذهب للغرام (ر.إ)';

  @override
  String get zakatGramEmas => 'غرام ذهب';

  @override
  String get zakatGramPerak => 'غرام فضة';

  @override
  String get zakatHargaPerak => 'سعر الفضة للغرام (ر.إ)';

  @override
  String get zakatPenghasilanBulanan => 'الدخل الشهري (ر.إ)';

  @override
  String get zakatHasilPanen => 'محصول (كجم)';

  @override
  String get zakatHargaHasil => 'سعر المحصول للكيلو (ر.إ)';

  @override
  String get zakatIrigasiAlami => 'ري طبيعي (مطر)';

  @override
  String get zakatIrigasiBerbayar => 'ري مدفوع';

  @override
  String get zakatHitung => 'احسب الزكاة';

  @override
  String get zakatHasil => 'نتيجة الحساب';

  @override
  String get zakatWajib => 'زكاة واجبة';

  @override
  String get zakatBelumWajib => 'الزكاة غير واجبة بعد';

  @override
  String get zakatNisab => 'النصاب';

  @override
  String get zakatJumlahZakat => 'مبلغ الزكاة';

  @override
  String get zakatCatatanBelumNisab => 'لم يبلغ النصاب';

  @override
  String get zakatRupiah => 'ر.إ';

  @override
  String get zakatFieldRequired => 'يرجى ملء جميع الحقول أولاً';

  @override
  String get zakatHargaHasilHint => 'اتركه فارغاً للحساب بالكجم';

  @override
  String get onboardingSkip => 'تخطي';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get onboardingStart => 'ابدأ';

  @override
  String get onboardingWelcomeEyebrow => 'مرحباً بك';

  @override
  String get onboardingWelcomeTitle => 'القرآن الكريم';

  @override
  String get onboardingWelcomeTagline =>
      'رفيق عبادتك اليومية — القراءة، الصلاة، والذكر في مكان واحد.';

  @override
  String get onboardingReadTitle => 'اقرأ القرآن';

  @override
  String get onboardingReadDesc =>
      '114 سورة و30 جزءاً كاملاً، بنص عربي واضح ومرتب.';

  @override
  String get onboardingChipTranslation => 'الترجمة';

  @override
  String get onboardingChipTafsir => 'التفسير';

  @override
  String get onboardingChipTajwid => 'ألوان التجويد';

  @override
  String get onboardingHijriTitle => 'التقويم الهجري';

  @override
  String get onboardingHijriDesc =>
      'اعرض التواريخ الهجرية وتابع رحلة ختم القرآن.';

  @override
  String get onboardingChipHijriDate => 'التاريخ الهجري';

  @override
  String get onboardingChipKhatam => 'هدف الختم';

  @override
  String get onboardingHijriLabel => 'هجري';

  @override
  String get onboardingHijriYear => '1448 هـ';

  @override
  String get onboardingMosqueTitle => 'ابحث عن المساجد';

  @override
  String get onboardingMosqueDesc => 'تتبع المساجد القريبة واتجاه القبلة حولك.';

  @override
  String get onboardingChipNearbyMosque => 'أقرب مسجد';

  @override
  String get onboardingChipQibla => 'اتجاه القبلة';
}
