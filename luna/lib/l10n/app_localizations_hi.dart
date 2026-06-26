// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'Luna';

  @override
  String get phaseMenstrual => 'मासिक धर्म';

  @override
  String get phaseFollicular => 'फॉलिक्युलर चरण';

  @override
  String get phaseOvulation => 'ओव्युलेशन चरण';

  @override
  String get phaseLuteal => 'ल्यूटियल चरण';

  @override
  String get copyMenstrual =>
      'विश्राम करें। आपका शरीर शक्तिशाली काम कर रहा है।';

  @override
  String get copyFollicular => 'ऊर्जा बढ़ रही है। नई शुरुआत का अच्छा समय है।';

  @override
  String get copyOvulation => 'आप अपने चरम पर हैं। इसका भरपूर उपयोग करें।';

  @override
  String get copyLuteal => 'धीरे-धीरे आराम करें। अपना ख्याल रखें।';

  @override
  String cycleDay(int day) {
    return 'चक्र का दिन $day';
  }

  @override
  String nextPeriodIn(int days) {
    return '$days दिनों में पीरियड आने की उम्मीद है';
  }

  @override
  String nextPeriodRange(String range) {
    return '$range की उम्मीद';
  }

  @override
  String get logPeriod => 'पीरियड दर्ज करें';

  @override
  String get logSymptoms => 'लक्षण दर्ज करें';

  @override
  String get logMood => 'मूड दर्ज करें';

  @override
  String get done => 'हो गया';

  @override
  String get skip => 'अभी छोड़ें';

  @override
  String get next => 'आगे';

  @override
  String get back => 'वापस';

  @override
  String get save => 'सहेजें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get later => 'बाद में';

  @override
  String get flowSpotting => 'स्पॉटिंग';

  @override
  String get flowLight => 'हल्का';

  @override
  String get flowMedium => 'मध्यम';

  @override
  String get flowHeavy => 'भारी';

  @override
  String get symptomCramps => 'ऐंठन';

  @override
  String get symptomHeadache => 'सिरदर्द';

  @override
  String get symptomBloating => 'सूजन';

  @override
  String get symptomFatigue => 'थकान';

  @override
  String get symptomBackPain => 'पीठ दर्द';

  @override
  String get symptomMoodSwings => 'मूड में बदलाव';

  @override
  String get symptomBreastTenderness => 'स्तन में दर्द';

  @override
  String get symptomNausea => 'जी मिचलाना';

  @override
  String get symptomAcne => 'मुहांसे';

  @override
  String get symptomFoodCravings => 'खाने की तीव्र इच्छा';

  @override
  String get symptomSleepChanges => 'नींद में बदलाव';

  @override
  String get symptomSpotting => 'स्पॉटिंग';

  @override
  String get moodHappy => 'खुश';

  @override
  String get moodCalm => 'शांत';

  @override
  String get moodSad => 'उदास';

  @override
  String get moodAnxious => 'चिंतित';

  @override
  String get moodIrritable => 'चिड़चिड़ा';

  @override
  String get moodEnergetic => 'ऊर्जावान';

  @override
  String get updateAvailable => 'अपडेट उपलब्ध है';

  @override
  String updateVersion(String version) {
    return 'संस्करण $version';
  }

  @override
  String updateSize(String size) {
    return '$size MB';
  }

  @override
  String get updateDownloadInstall => 'डाउनलोड और इंस्टॉल करें';

  @override
  String get updateDownloading => 'डाउनलोड हो रहा है…';

  @override
  String get updateLater => 'बाद में';

  @override
  String get updateMandatoryTitle => 'आवश्यक अपडेट';

  @override
  String get updateMandatoryBody => 'जारी रखने के लिए Luna अपडेट करें।';

  @override
  String get updateRequired => 'अपडेट आवश्यक है';

  @override
  String get updateNow => 'अभी अपडेट करें';

  @override
  String get updateRetry => 'पुनः प्रयास करें';

  @override
  String get updateMandatoryNote =>
      'Luna का उपयोग जारी रखने के लिए यह अपडेट आवश्यक है।';

  @override
  String get updateDownloadFailed => 'डाउनलोड विफल। कृपया पुनः प्रयास करें।';

  @override
  String get homeTrackYourCycle => 'अपना चक्र ट्रैक करें';

  @override
  String get homeStartTrackingSubtitle =>
      'शुरू करने के लिए अपना पीरियड दर्ज करें।';

  @override
  String get periodStartedToday => 'आज पीरियड शुरू हुआ';

  @override
  String get noPeriodInProgress => 'कोई पीरियड जारी नहीं है';

  @override
  String get noPeriodStartBelow =>
      'फ्लो की तीव्रता दर्ज करना शुरू करने के लिए नीचे अपना पीरियड शुरू करें।';

  @override
  String get noPeriodStartFromHome =>
      'ट्रैकिंग शुरू करने के लिए होम से अपना पीरियड शुरू करें, फिर पिछली तारीखें दर्ज कर सकती हैं।';

  @override
  String get saveLog => 'लॉग सहेजें';

  @override
  String get flowIntensity => 'फ्लो की तीव्रता';

  @override
  String get tapFlowLevel =>
      'अपना पीरियड दर्ज करने के लिए एक फ्लो स्तर टैप करें।';

  @override
  String get whatAreYouFeeling => 'आप क्या महसूस कर रहे हैं?';

  @override
  String get howAreYouFeeling => 'आप कैसा महसूस कर रहे हैं?';

  @override
  String get severity => 'तीव्रता';

  @override
  String get energy => 'ऊर्जा';

  @override
  String get tabPeriod => 'पीरियड';

  @override
  String get tabSymptoms => 'लक्षण';

  @override
  String get tabMood => 'मूड';

  @override
  String get calendarPeriodLogged => 'पीरियड दर्ज किया गया';

  @override
  String get calendarMoodLogged => 'मूड / लक्षण दर्ज किए गए';

  @override
  String get calendarPredictedPeriod => 'अनुमानित पीरियड';

  @override
  String get calendarStartTracking =>
      'चरण के रंग और लॉग इतिहास देखने के लिए अपना पीरियड ट्रैक करना शुरू करें।';

  @override
  String get nextPeriodLabel => 'अगला पीरियड';

  @override
  String get predictionHighAccuracy => 'उच्च सटीकता';

  @override
  String get predictionLearning => 'सीख रहे हैं…';

  @override
  String predictionCyclesTracked(int count) {
    return '$count चक्र ट्रैक किए गए';
  }

  @override
  String get predictionKeepLogging => 'अनुमान बेहतर करने के लिए लॉग करते रहें';

  @override
  String get predictionFixedSchedule => 'आपकी गोली की समय-सारणी के अनुसार';

  @override
  String predictionAccuracy(int accurate, int total) {
    return 'पिछले $total में से $accurate चक्रों का सटीक अनुमान (3 दिन के अंदर)';
  }

  @override
  String get logToday => 'आज दर्ज करें';

  @override
  String get logYesterday => 'कल दर्ज करें';

  @override
  String logFor(String date) {
    return '$date के लिए दर्ज करें';
  }

  @override
  String get logSaveError => 'सहेजा नहीं जा सका। कृपया पुनः प्रयास करें।';

  @override
  String get addNoteHint => 'नोट जोड़ें… (वैकल्पिक)';

  @override
  String get homeCycleStartsHere => 'आपका चक्र यहाँ से शुरू होता है';

  @override
  String get homeCycleStartsSubtitle =>
      'अपनी सेहत ट्रैक करना शुरू करने के लिए अपना पीरियड दर्ज करें।';

  @override
  String get homeStartedFewDaysAgo => 'कुछ दिन पहले शुरू हुआ?';

  @override
  String get homePhaseTip => 'चरण सुझाव';

  @override
  String get homeSeeAll => 'सभी देखें →';

  @override
  String get periodEndedToday => 'आज पीरियड खत्म हुआ';

  @override
  String get periodEndConfirmTitle => 'पीरियड समाप्त करें?';

  @override
  String get periodEndConfirmBody =>
      'आज को आपका आखिरी दिन माना जाएगा। आपका डेटा सेव हो जाएगा।';

  @override
  String get periodEndConfirm => 'पीरियड समाप्त करें';

  @override
  String get periodEndedSuccess => 'पीरियड समाप्त के रूप में दर्ज किया गया';

  @override
  String get periodDateBeforeCycleStart =>
      'यह तारीख आपके मौजूदा पीरियड शुरू होने से पहले की है';

  @override
  String get periodDateBeforeCycleStartHint =>
      'आप केवल अपने मौजूदा पीरियड की तारीखों में फ्लो दर्ज कर सकती हैं।';

  @override
  String get editStartDate => 'शुरुआती तारीख गलत? सुधारें';

  @override
  String get editStartDateTitle => 'पीरियड शुरू होने की तारीख सुधारें';

  @override
  String get editStartDateSuccess => 'शुरुआती तारीख अपडेट हो गई';

  @override
  String get editEndDate => 'पीरियड अभी भी जारी है? अंतिम तारीख सुधारें';

  @override
  String get editEndDateTitle => 'पीरियड समाप्त होने की तारीख सुधारें';

  @override
  String get editEndDateSuccess => 'अंतिम तारीख अपडेट हो गई';

  @override
  String editDateError(String reason) => 'तारीख अपडेट नहीं हो सकी। $reason';
}
