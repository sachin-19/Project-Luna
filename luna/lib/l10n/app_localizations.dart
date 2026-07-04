import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Luna'**
  String get appName;

  /// No description provided for @phaseMenstrual.
  ///
  /// In en, this message translates to:
  /// **'Menstrual Phase'**
  String get phaseMenstrual;

  /// No description provided for @phaseFollicular.
  ///
  /// In en, this message translates to:
  /// **'Follicular Phase'**
  String get phaseFollicular;

  /// No description provided for @phaseOvulation.
  ///
  /// In en, this message translates to:
  /// **'Ovulation Phase'**
  String get phaseOvulation;

  /// No description provided for @phaseLuteal.
  ///
  /// In en, this message translates to:
  /// **'Luteal Phase'**
  String get phaseLuteal;

  /// No description provided for @copyMenstrual.
  ///
  /// In en, this message translates to:
  /// **'Rest. Your body is doing powerful work.'**
  String get copyMenstrual;

  /// No description provided for @copyFollicular.
  ///
  /// In en, this message translates to:
  /// **'Energy is building. A good time to start things.'**
  String get copyFollicular;

  /// No description provided for @copyOvulation.
  ///
  /// In en, this message translates to:
  /// **'You\'re at your peak. Make the most of it.'**
  String get copyOvulation;

  /// No description provided for @copyLuteal.
  ///
  /// In en, this message translates to:
  /// **'Wind down gently. Nourish yourself.'**
  String get copyLuteal;

  /// No description provided for @cycleDay.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of cycle'**
  String cycleDay(int day);

  /// No description provided for @nextPeriodIn.
  ///
  /// In en, this message translates to:
  /// **'Period expected in {days} days'**
  String nextPeriodIn(int days);

  /// No description provided for @nextPeriodRange.
  ///
  /// In en, this message translates to:
  /// **'Expected {range}'**
  String nextPeriodRange(String range);

  /// No description provided for @logPeriod.
  ///
  /// In en, this message translates to:
  /// **'Log Period'**
  String get logPeriod;

  /// No description provided for @logSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Log Symptoms'**
  String get logSymptoms;

  /// No description provided for @logMood.
  ///
  /// In en, this message translates to:
  /// **'Log Mood'**
  String get logMood;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @flowSpotting.
  ///
  /// In en, this message translates to:
  /// **'Spotting'**
  String get flowSpotting;

  /// No description provided for @flowLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get flowLight;

  /// No description provided for @flowMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get flowMedium;

  /// No description provided for @flowHeavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get flowHeavy;

  /// No description provided for @symptomCramps.
  ///
  /// In en, this message translates to:
  /// **'Cramps'**
  String get symptomCramps;

  /// No description provided for @symptomHeadache.
  ///
  /// In en, this message translates to:
  /// **'Headache'**
  String get symptomHeadache;

  /// No description provided for @symptomBloating.
  ///
  /// In en, this message translates to:
  /// **'Bloating'**
  String get symptomBloating;

  /// No description provided for @symptomFatigue.
  ///
  /// In en, this message translates to:
  /// **'Fatigue'**
  String get symptomFatigue;

  /// No description provided for @symptomBackPain.
  ///
  /// In en, this message translates to:
  /// **'Back Pain'**
  String get symptomBackPain;

  /// No description provided for @symptomMoodSwings.
  ///
  /// In en, this message translates to:
  /// **'Mood Swings'**
  String get symptomMoodSwings;

  /// No description provided for @symptomBreastTenderness.
  ///
  /// In en, this message translates to:
  /// **'Breast Tenderness'**
  String get symptomBreastTenderness;

  /// No description provided for @symptomNausea.
  ///
  /// In en, this message translates to:
  /// **'Nausea'**
  String get symptomNausea;

  /// No description provided for @symptomAcne.
  ///
  /// In en, this message translates to:
  /// **'Acne'**
  String get symptomAcne;

  /// No description provided for @symptomFoodCravings.
  ///
  /// In en, this message translates to:
  /// **'Food Cravings'**
  String get symptomFoodCravings;

  /// No description provided for @symptomSleepChanges.
  ///
  /// In en, this message translates to:
  /// **'Sleep Changes'**
  String get symptomSleepChanges;

  /// No description provided for @symptomSpotting.
  ///
  /// In en, this message translates to:
  /// **'Spotting'**
  String get symptomSpotting;

  /// No description provided for @moodHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get moodHappy;

  /// No description provided for @moodCalm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get moodCalm;

  /// No description provided for @moodSad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get moodSad;

  /// No description provided for @moodAnxious.
  ///
  /// In en, this message translates to:
  /// **'Anxious'**
  String get moodAnxious;

  /// No description provided for @moodIrritable.
  ///
  /// In en, this message translates to:
  /// **'Irritable'**
  String get moodIrritable;

  /// No description provided for @moodEnergetic.
  ///
  /// In en, this message translates to:
  /// **'Energetic'**
  String get moodEnergetic;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateAvailable;

  /// No description provided for @updateVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String updateVersion(String version);

  /// No description provided for @updateSize.
  ///
  /// In en, this message translates to:
  /// **'{size} MB'**
  String updateSize(String size);

  /// No description provided for @updateDownloadInstall.
  ///
  /// In en, this message translates to:
  /// **'Download & Install'**
  String get updateDownloadInstall;

  /// No description provided for @updateDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading…'**
  String get updateDownloading;

  /// No description provided for @updateLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updateLater;

  /// No description provided for @updateMandatoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Required update'**
  String get updateMandatoryTitle;

  /// No description provided for @updateMandatoryBody.
  ///
  /// In en, this message translates to:
  /// **'Please update Luna to continue.'**
  String get updateMandatoryBody;

  /// No description provided for @updateRequired.
  ///
  /// In en, this message translates to:
  /// **'Update required'**
  String get updateRequired;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update now'**
  String get updateNow;

  /// No description provided for @updateRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get updateRetry;

  /// No description provided for @updateMandatoryNote.
  ///
  /// In en, this message translates to:
  /// **'This update is required to continue using Luna.'**
  String get updateMandatoryNote;

  /// No description provided for @updateDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed. Please try again.'**
  String get updateDownloadFailed;

  /// No description provided for @homeTrackYourCycle.
  ///
  /// In en, this message translates to:
  /// **'Track your cycle'**
  String get homeTrackYourCycle;

  /// No description provided for @homeStartTrackingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log when your period begins to get started.'**
  String get homeStartTrackingSubtitle;

  /// No description provided for @periodStartedToday.
  ///
  /// In en, this message translates to:
  /// **'Period started today'**
  String get periodStartedToday;

  /// No description provided for @noPeriodInProgress.
  ///
  /// In en, this message translates to:
  /// **'No period in progress'**
  String get noPeriodInProgress;

  /// No description provided for @noPeriodStartBelow.
  ///
  /// In en, this message translates to:
  /// **'Start your period below to begin logging flow intensity.'**
  String get noPeriodStartBelow;

  /// No description provided for @noPeriodStartFromHome.
  ///
  /// In en, this message translates to:
  /// **'Start your period from Home to begin tracking, then you can log past dates.'**
  String get noPeriodStartFromHome;

  /// No description provided for @saveLog.
  ///
  /// In en, this message translates to:
  /// **'Save log'**
  String get saveLog;

  /// No description provided for @flowIntensity.
  ///
  /// In en, this message translates to:
  /// **'Flow intensity'**
  String get flowIntensity;

  /// No description provided for @tapFlowLevel.
  ///
  /// In en, this message translates to:
  /// **'Tap a flow level to log your period.'**
  String get tapFlowLevel;

  /// No description provided for @whatAreYouFeeling.
  ///
  /// In en, this message translates to:
  /// **'What are you feeling?'**
  String get whatAreYouFeeling;

  /// No description provided for @howAreYouFeeling.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling?'**
  String get howAreYouFeeling;

  /// No description provided for @severity.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get severity;

  /// No description provided for @energy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get energy;

  /// No description provided for @tabPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get tabPeriod;

  /// No description provided for @tabSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get tabSymptoms;

  /// No description provided for @tabMood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get tabMood;

  /// No description provided for @calendarPeriodLogged.
  ///
  /// In en, this message translates to:
  /// **'Period logged'**
  String get calendarPeriodLogged;

  /// No description provided for @calendarMoodLogged.
  ///
  /// In en, this message translates to:
  /// **'Mood / symptoms logged'**
  String get calendarMoodLogged;

  /// No description provided for @calendarPredictedPeriod.
  ///
  /// In en, this message translates to:
  /// **'Predicted period'**
  String get calendarPredictedPeriod;

  /// No description provided for @calendarStartTracking.
  ///
  /// In en, this message translates to:
  /// **'Start tracking your period to see phase colours and log history here.'**
  String get calendarStartTracking;

  /// No description provided for @nextPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Next period'**
  String get nextPeriodLabel;

  /// No description provided for @predictionHighAccuracy.
  ///
  /// In en, this message translates to:
  /// **'High accuracy'**
  String get predictionHighAccuracy;

  /// No description provided for @predictionLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning…'**
  String get predictionLearning;

  /// No description provided for @predictionCyclesTracked.
  ///
  /// In en, this message translates to:
  /// **'{count} cycle{count, plural, one{} other{s}} tracked'**
  String predictionCyclesTracked(int count);

  /// No description provided for @predictionKeepLogging.
  ///
  /// In en, this message translates to:
  /// **'Keep logging to improve predictions'**
  String get predictionKeepLogging;

  /// No description provided for @predictionFixedSchedule.
  ///
  /// In en, this message translates to:
  /// **'Based on your pill schedule'**
  String get predictionFixedSchedule;

  /// No description provided for @predictionAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Predicted {accurate} of last {total} cycles within 3 days'**
  String predictionAccuracy(int accurate, int total);

  /// No description provided for @logToday.
  ///
  /// In en, this message translates to:
  /// **'Log today'**
  String get logToday;

  /// No description provided for @logYesterday.
  ///
  /// In en, this message translates to:
  /// **'Log yesterday'**
  String get logYesterday;

  /// No description provided for @logFor.
  ///
  /// In en, this message translates to:
  /// **'Log for {date}'**
  String logFor(String date);

  /// No description provided for @logSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Please try again.'**
  String get logSaveError;

  /// No description provided for @addNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Add a note… (optional)'**
  String get addNoteHint;

  /// No description provided for @homeCycleStartsHere.
  ///
  /// In en, this message translates to:
  /// **'Your cycle starts here'**
  String get homeCycleStartsHere;

  /// No description provided for @homeCycleStartsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log when your period begins to start tracking your health.'**
  String get homeCycleStartsSubtitle;

  /// No description provided for @homeStartedFewDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'Started a few days ago?'**
  String get homeStartedFewDaysAgo;

  /// No description provided for @homePhaseTip.
  ///
  /// In en, this message translates to:
  /// **'Phase tip'**
  String get homePhaseTip;

  /// No description provided for @homeSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all →'**
  String get homeSeeAll;

  /// No description provided for @periodEndedToday.
  ///
  /// In en, this message translates to:
  /// **'Period ended today'**
  String get periodEndedToday;

  /// No description provided for @periodEndConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'End your period?'**
  String get periodEndConfirmTitle;

  /// No description provided for @periodEndConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Mark today as your last day. Your flow data will be saved.'**
  String get periodEndConfirmBody;

  /// No description provided for @periodEndConfirm.
  ///
  /// In en, this message translates to:
  /// **'End period'**
  String get periodEndConfirm;

  /// No description provided for @periodEndedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Period marked as ended'**
  String get periodEndedSuccess;

  /// No description provided for @periodDateBeforeCycleStart.
  ///
  /// In en, this message translates to:
  /// **'Date before current cycle start'**
  String get periodDateBeforeCycleStart;

  /// No description provided for @periodDateBeforeCycleStartHint.
  ///
  /// In en, this message translates to:
  /// **'You can only log flow days after your cycle started.'**
  String get periodDateBeforeCycleStartHint;

  /// No description provided for @editStartDate.
  ///
  /// In en, this message translates to:
  /// **'Wrong start date? Edit'**
  String get editStartDate;

  /// No description provided for @editStartDateTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit cycle start date'**
  String get editStartDateTitle;

  /// No description provided for @editStartDateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cycle start date updated'**
  String get editStartDateSuccess;

  /// No description provided for @editEndDate.
  ///
  /// In en, this message translates to:
  /// **'Period still going? Correct end date'**
  String get editEndDate;

  /// No description provided for @editEndDateTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit period end date'**
  String get editEndDateTitle;

  /// No description provided for @editEndDateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Period end date updated'**
  String get editEndDateSuccess;

  /// No description provided for @editDateError.
  ///
  /// In en, this message translates to:
  /// **'Could not update: {reason}'**
  String editDateError(String reason);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
