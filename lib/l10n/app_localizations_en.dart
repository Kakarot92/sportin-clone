// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Studio';

  @override
  String get navHome => 'Home';

  @override
  String get navSchedule => 'Schedule';

  @override
  String get navMeasurements => 'Measurements';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Profile';

  @override
  String get homeWelcome => 'Welcome to your studio';

  @override
  String get homeSubtitle =>
      'Book trainings, track your progress and chat with your trainer.';

  @override
  String get scheduleTitle => 'Schedule';

  @override
  String get schedulePlaceholder =>
      'Available slots and your bookings will appear here.';

  @override
  String get measurementsTitle => 'Measurements';

  @override
  String get measurementsPlaceholder =>
      'Your measurements and progress charts will appear here.';

  @override
  String get chatTitle => 'Chat';

  @override
  String get chatPlaceholder =>
      'Your conversations with trainers will appear here.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSerbian => 'Serbian';

  @override
  String get languageEnglish => 'English';
}
