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

  @override
  String get loginTitle => 'Sign in';

  @override
  String get signupTitle => 'Create account';

  @override
  String get resetTitle => 'Reset password';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get displayNameLabel => 'Full name';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get loginButton => 'Sign in';

  @override
  String get signupButton => 'Create account';

  @override
  String get resetButton => 'Send reset link';

  @override
  String get noAccountPrompt => 'No account? Create one';

  @override
  String get haveAccountPrompt => 'Already have an account? Sign in';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get resetSent =>
      'If that email is registered, we\'ve sent a reset link.';

  @override
  String get consentLabel =>
      'I consent to processing of my health and body data and accept the terms of use.';

  @override
  String get consentRequired => 'You must accept the terms to continue.';

  @override
  String get validationRequired => 'Required.';

  @override
  String get validationEmailInvalid => 'Enter a valid email address.';

  @override
  String get validationPasswordShort =>
      'Password must be at least 6 characters.';

  @override
  String get errorEmailInUse => 'This email is already registered.';

  @override
  String get errorInvalidEmail => 'That email address is not valid.';

  @override
  String get errorWrongCredentials => 'Wrong email or password.';

  @override
  String get errorWeakPassword => 'That password is too weak.';

  @override
  String get errorTooManyRequests =>
      'Too many attempts. Please try again later.';

  @override
  String get errorNetwork => 'Network error. Check your connection.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get accountSection => 'Account';

  @override
  String get profileRole => 'Role';

  @override
  String get roleClient => 'Client';

  @override
  String get roleTrainer => 'Trainer';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get logout => 'Log out';

  @override
  String get profileSaved => 'Profile saved.';

  @override
  String get trainersTitle => 'Trainers';

  @override
  String get chooseTrainer => 'Choose a trainer';

  @override
  String get noTrainers => 'No trainers yet.';

  @override
  String get trainerBio => 'Bio';

  @override
  String get emptyBio => 'No description yet.';

  @override
  String get manageRoles => 'Manage roles';

  @override
  String get editTrainerProfile => 'Edit trainer profile';

  @override
  String get usersTitle => 'Users';

  @override
  String get roleTrainerSwitch => 'Trainer';

  @override
  String get notAuthorized => 'You don\'t have access to this page.';

  @override
  String get roleUpdated => 'Role updated.';

  @override
  String get homeShortcuts => 'Shortcuts';

  @override
  String get nextTraining => 'Next training';

  @override
  String get noUpcomingTraining => 'You don\'t have an upcoming training yet.';

  @override
  String get bookTraining => 'Book a training';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get availability => 'Availability';

  @override
  String get weeklyAvailability => 'Weekly availability';

  @override
  String get slotDuration => 'Slot duration';

  @override
  String get minutesShort => 'min';

  @override
  String get addTimeRange => 'Add time range';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get exceptions => 'Exceptions';

  @override
  String get addException => 'Add exception';

  @override
  String get blockWholeDay => 'Block whole day';

  @override
  String get noExceptions => 'No exceptions';

  @override
  String get studioClosedDays => 'Studio closed days';

  @override
  String get closedWeekdaysLabel => 'Closed weekdays';

  @override
  String get closedDatesLabel => 'Closed dates';

  @override
  String get addClosedDate => 'Add date';

  @override
  String get availableSlots => 'Available slots';

  @override
  String get noSlotsForDay => 'No available slots for the selected day';

  @override
  String get selectDay => 'Select a day';

  @override
  String get weekdayMon => 'Mon';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdaySat => 'Sat';

  @override
  String get weekdaySun => 'Sun';

  @override
  String get book => 'Book';

  @override
  String get bookConfirmTitle => 'Confirm booking';

  @override
  String bookConfirmBody(String time, String trainer) {
    return 'Book slot $time with $trainer?';
  }

  @override
  String get booked => 'Booked';

  @override
  String get slotTakenError => 'That slot was just taken.';

  @override
  String get pastSlotError => 'You cannot book a slot in the past.';

  @override
  String get myBookings => 'My bookings';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get history => 'History';

  @override
  String get mySessions => 'My sessions';

  @override
  String get noUpcomingBookings => 'You have no upcoming bookings.';

  @override
  String get noBookingHistory => 'No booking history.';

  @override
  String get noSessions => 'No sessions scheduled.';

  @override
  String get statusBooked => 'Booked';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get cancelBooking => 'Cancel session';

  @override
  String get cancelConfirmTitle => 'Cancel session';

  @override
  String cancelConfirmBody(String time) {
    return 'Are you sure you want to cancel the $time session?';
  }

  @override
  String get cutoffPassedError =>
      'This session has already started or passed — cancellation/rescheduling is no longer possible.';

  @override
  String get reschedule => 'Reschedule';

  @override
  String get rescheduleConfirmTitle => 'Reschedule session';

  @override
  String rescheduleConfirmBody(String time, String trainer) {
    return 'Move session to $time with $trainer?';
  }

  @override
  String get rescheduled => 'Session moved.';

  @override
  String get cancelSuccess => 'Session cancelled.';

  @override
  String get packageTypesTitle => 'Package Types';

  @override
  String get addPackageType => 'Add Package Type';

  @override
  String get packageName => 'Package name';

  @override
  String get packageKind => 'Package kind';

  @override
  String get packageKindDuration => 'Membership (duration)';

  @override
  String get packageKindCredits => 'Sessions (credits)';

  @override
  String get validityDays => 'Validity (days)';

  @override
  String get creditCount => 'Number of sessions';

  @override
  String get assignPackage => 'Assign Package';

  @override
  String get assignPackageTitle => 'Assign Package';

  @override
  String assignPackageBody(String package, String user) {
    return 'Assign \"$package\" to user $user?';
  }

  @override
  String get packageAssigned => 'Package assigned.';

  @override
  String get myPackage => 'My Package';

  @override
  String get noActivePackage => 'You have no active package.';

  @override
  String get getPackagePrompt => 'Contact the studio to get a package.';

  @override
  String get packageExpiry => 'Expires';

  @override
  String get remainingCredits => 'Remaining sessions';

  @override
  String unlimitedUntil(String date) {
    return 'Unlimited until $date';
  }

  @override
  String get packageHistory => 'Package History';

  @override
  String get noPackageHistory => 'No previous packages.';

  @override
  String get noPackageTypesYet => 'No package types defined yet.';

  @override
  String get noActivePackageError =>
      'You have no active package or your credits are depleted. Contact the studio.';

  @override
  String get statusActive => 'Active';

  @override
  String get statusExpired => 'Expired';

  @override
  String get statusDepleted => 'Depleted';

  @override
  String get groupClasses => 'Group classes';

  @override
  String get createGroupClass => 'New group class';

  @override
  String get classTitle => 'Class name';

  @override
  String get classCapacity => 'Capacity';

  @override
  String get classDate => 'Date';

  @override
  String get classTime => 'Time';

  @override
  String get classCreated => 'Class created.';

  @override
  String get joinClass => 'Join';

  @override
  String get leaveClass => 'Leave';

  @override
  String spotsLeft(int n) {
    return '$n spot(s) left';
  }

  @override
  String get classFull => 'Full';

  @override
  String get classFullError => 'This class is full.';

  @override
  String get alreadyJoinedError => 'You are already signed up for this class.';

  @override
  String get joinedSuccess => 'You have joined the class.';

  @override
  String get leftSuccess => 'You have left the class.';

  @override
  String get noUpcomingClasses => 'No group classes scheduled at the moment.';

  @override
  String get myGroupClasses => 'My group classes';

  @override
  String get noGroupClassesYet => 'You haven\'t created any classes yet.';

  @override
  String get addMeasurement => 'New measurement';

  @override
  String get weightKg => 'Weight (kg)';

  @override
  String get waistCm => 'Waist (cm)';

  @override
  String get chestCm => 'Chest (cm)';

  @override
  String get hipsCm => 'Hips (cm)';

  @override
  String get measurementNote => 'Note';

  @override
  String get measurementSaved => 'Measurement saved.';

  @override
  String get measurementDeleted => 'Measurement deleted.';

  @override
  String get noMeasurementsYet => 'No measurements recorded yet.';

  @override
  String get deleteMeasurement => 'Delete measurement';

  @override
  String get editMeasurement => 'Edit measurement';

  @override
  String get myClients => 'My clients';

  @override
  String get noClientsYet => 'You don\'t have any clients yet.';

  @override
  String get clientMeasurements => 'Client measurements';

  @override
  String get dashboardSessionsAttended => 'Sessions attended';

  @override
  String get dashboardCurrentPackage => 'Current package';

  @override
  String get dashboardLatestMeasurement => 'Latest measurement';

  @override
  String get noPackage => 'No package';

  @override
  String get chatMessages => 'Messages';

  @override
  String get typeMessage => 'Type a message…';

  @override
  String get send => 'Send';

  @override
  String get noMessagesYet => 'No messages yet. Say hello!';

  @override
  String get chatWithTrainer => 'Chat with trainer';

  @override
  String get groupClassChat => 'Group class — chat';

  @override
  String get noChatsYet => 'No conversations yet.';

  @override
  String get myChats => 'My chats';

  @override
  String get filterAll => 'All';

  @override
  String get filterClients => 'Clients';

  @override
  String get trainerClientRelationships => 'Trainer–client relationships';

  @override
  String get studioSettingsHub => 'Studio settings';

  @override
  String get bookingReports => 'Booking reports';

  @override
  String get noRelationshipsYet => 'No relationships recorded yet.';

  @override
  String get revenueReportsComingSoon =>
      'Revenue reports will be available once payment is added.';

  @override
  String get totalBookings => 'Total bookings';

  @override
  String get bookedCount => 'Active bookings';

  @override
  String get cancelledCount => 'Cancelled';

  @override
  String get byTrainer => 'By trainer';
}
