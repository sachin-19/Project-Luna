// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Luna';

  @override
  String get phaseMenstrual => 'Menstrual Phase';

  @override
  String get phaseFollicular => 'Follicular Phase';

  @override
  String get phaseOvulation => 'Ovulation Phase';

  @override
  String get phaseLuteal => 'Luteal Phase';

  @override
  String get copyMenstrual => 'Rest. Your body is doing powerful work.';

  @override
  String get copyFollicular =>
      'Energy is building. A good time to start things.';

  @override
  String get copyOvulation => 'You\'re at your peak. Make the most of it.';

  @override
  String get copyLuteal => 'Wind down gently. Nourish yourself.';

  @override
  String cycleDay(int day) {
    return 'Day $day of cycle';
  }

  @override
  String nextPeriodIn(int days) {
    return 'Period expected in $days days';
  }

  @override
  String nextPeriodRange(String range) {
    return 'Expected $range';
  }

  @override
  String get logPeriod => 'Log Period';

  @override
  String get logSymptoms => 'Log Symptoms';

  @override
  String get logMood => 'Log Mood';

  @override
  String get done => 'Done';

  @override
  String get skip => 'Skip for now';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get later => 'Later';

  @override
  String get flowSpotting => 'Spotting';

  @override
  String get flowLight => 'Light';

  @override
  String get flowMedium => 'Medium';

  @override
  String get flowHeavy => 'Heavy';

  @override
  String get symptomCramps => 'Cramps';

  @override
  String get symptomHeadache => 'Headache';

  @override
  String get symptomBloating => 'Bloating';

  @override
  String get symptomFatigue => 'Fatigue';

  @override
  String get symptomBackPain => 'Back Pain';

  @override
  String get symptomMoodSwings => 'Mood Swings';

  @override
  String get symptomBreastTenderness => 'Breast Tenderness';

  @override
  String get symptomNausea => 'Nausea';

  @override
  String get symptomAcne => 'Acne';

  @override
  String get symptomFoodCravings => 'Food Cravings';

  @override
  String get symptomSleepChanges => 'Sleep Changes';

  @override
  String get symptomSpotting => 'Spotting';

  @override
  String get moodHappy => 'Happy';

  @override
  String get moodCalm => 'Calm';

  @override
  String get moodSad => 'Sad';

  @override
  String get moodAnxious => 'Anxious';

  @override
  String get moodIrritable => 'Irritable';

  @override
  String get moodEnergetic => 'Energetic';

  @override
  String get updateAvailable => 'Update available';

  @override
  String updateVersion(String version) {
    return 'Version $version';
  }

  @override
  String updateSize(String size) {
    return '$size MB';
  }

  @override
  String get updateDownloadInstall => 'Download & Install';

  @override
  String get updateDownloading => 'Downloading…';

  @override
  String get updateLater => 'Later';

  @override
  String get updateMandatoryTitle => 'Required update';

  @override
  String get updateMandatoryBody => 'Please update Luna to continue.';

  @override
  String get updateRequired => 'Update required';

  @override
  String get updateNow => 'Update now';

  @override
  String get updateRetry => 'Retry';

  @override
  String get updateMandatoryNote =>
      'This update is required to continue using Luna.';

  @override
  String get updateDownloadFailed => 'Download failed. Please try again.';

  @override
  String get homeTrackYourCycle => 'Track your cycle';

  @override
  String get homeStartTrackingSubtitle =>
      'Log when your period begins to get started.';

  @override
  String get periodStartedToday => 'Period started today';

  @override
  String get noPeriodInProgress => 'No period in progress';

  @override
  String get noPeriodStartBelow =>
      'Start your period below to begin logging flow intensity.';

  @override
  String get noPeriodStartFromHome =>
      'Start your period from Home to begin tracking, then you can log past dates.';

  @override
  String get saveLog => 'Save log';

  @override
  String get flowIntensity => 'Flow intensity';

  @override
  String get tapFlowLevel => 'Tap a flow level to log your period.';

  @override
  String get whatAreYouFeeling => 'What are you feeling?';

  @override
  String get howAreYouFeeling => 'How are you feeling?';

  @override
  String get severity => 'Severity';

  @override
  String get energy => 'Energy';

  @override
  String get tabPeriod => 'Period';

  @override
  String get tabSymptoms => 'Symptoms';

  @override
  String get tabMood => 'Mood';

  @override
  String get calendarPeriodLogged => 'Period logged';

  @override
  String get calendarMoodLogged => 'Mood / symptoms logged';

  @override
  String get calendarPredictedPeriod => 'Predicted period';

  @override
  String get calendarStartTracking =>
      'Start tracking your period to see phase colours and log history here.';

  @override
  String get nextPeriodLabel => 'Next period';

  @override
  String get predictionHighAccuracy => 'High accuracy';

  @override
  String get predictionLearning => 'Learning…';

  @override
  String predictionCyclesTracked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count cycle$_temp0 tracked';
  }

  @override
  String get predictionKeepLogging => 'Keep logging to improve predictions';

  @override
  String get predictionFixedSchedule => 'Based on your pill schedule';

  @override
  String predictionAccuracy(int accurate, int total) {
    return 'Predicted $accurate of last $total cycles within 3 days';
  }

  @override
  String get logToday => 'Log today';

  @override
  String get logYesterday => 'Log yesterday';

  @override
  String logFor(String date) {
    return 'Log for $date';
  }

  @override
  String get logSaveError => 'Could not save. Please try again.';

  @override
  String get addNoteHint => 'Add a note… (optional)';

  @override
  String get homeCycleStartsHere => 'Your cycle starts here';

  @override
  String get homeCycleStartsSubtitle =>
      'Log when your period begins to start tracking your health.';

  @override
  String get homeStartedFewDaysAgo => 'Started a few days ago?';

  @override
  String get homePhaseTip => 'Phase tip';

  @override
  String get homeSeeAll => 'See all →';

  @override
  String get periodEndedToday => 'Period ended today';

  @override
  String get periodEndConfirmTitle => 'End your period?';

  @override
  String get periodEndConfirmBody =>
      'Mark today as your last day. Your flow data will be saved.';

  @override
  String get periodEndConfirm => 'End period';

  @override
  String get periodEndedSuccess => 'Period marked as ended';

  @override
  String get periodDateBeforeCycleStart => 'Date before current cycle start';

  @override
  String get periodDateBeforeCycleStartHint =>
      'You can only log flow days after your cycle started.';

  @override
  String get editStartDate => 'Wrong start date? Edit';

  @override
  String get editStartDateTitle => 'Edit cycle start date';

  @override
  String get editStartDateSuccess => 'Cycle start date updated';

  @override
  String get editEndDate => 'Period still going? Correct end date';

  @override
  String get editEndDateTitle => 'Edit period end date';

  @override
  String get editEndDateSuccess => 'Period end date updated';

  @override
  String editDateError(String reason) {
    return 'Could not update: $reason';
  }
}
