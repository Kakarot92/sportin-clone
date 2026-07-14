// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Serbian (`sr`).
class AppLocalizationsSr extends AppLocalizations {
  AppLocalizationsSr([String locale = 'sr']) : super(locale);

  @override
  String get appTitle => 'Studio';

  @override
  String get navHome => 'Početna';

  @override
  String get navSchedule => 'Termini';

  @override
  String get navMeasurements => 'Merenja';

  @override
  String get navChat => 'Poruke';

  @override
  String get navProfile => 'Profil';

  @override
  String get homeWelcome => 'Dobrodošli u vaš studio';

  @override
  String get homeSubtitle =>
      'Zakazujte treninge, pratite napredak i dopisujte se sa trenerom.';

  @override
  String get scheduleTitle => 'Termini';

  @override
  String get schedulePlaceholder =>
      'Ovde će se prikazivati slobodni termini i vaša zakazivanja.';

  @override
  String get measurementsTitle => 'Merenja';

  @override
  String get measurementsPlaceholder =>
      'Ovde će se prikazivati vaša merenja i grafikoni napretka.';

  @override
  String get chatTitle => 'Poruke';

  @override
  String get chatPlaceholder =>
      'Ovde će se prikazivati razgovori sa trenerima.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get settingsAppearance => 'Izgled';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get themeSystem => 'Sistemska';

  @override
  String get themeLight => 'Svetla';

  @override
  String get themeDark => 'Tamna';

  @override
  String get settingsLanguage => 'Jezik';

  @override
  String get languageSerbian => 'Srpski';

  @override
  String get languageEnglish => 'Engleski';

  @override
  String get loginTitle => 'Prijava';

  @override
  String get signupTitle => 'Kreiranje naloga';

  @override
  String get resetTitle => 'Reset lozinke';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Lozinka';

  @override
  String get displayNameLabel => 'Ime i prezime';

  @override
  String get phoneLabel => 'Telefon';

  @override
  String get loginButton => 'Prijavi se';

  @override
  String get signupButton => 'Napravi nalog';

  @override
  String get resetButton => 'Pošalji link za reset';

  @override
  String get noAccountPrompt => 'Nemaš nalog? Napravi ga';

  @override
  String get haveAccountPrompt => 'Već imaš nalog? Prijavi se';

  @override
  String get forgotPassword => 'Zaboravljena lozinka?';

  @override
  String get resetSent =>
      'Ako je taj email registrovan, poslali smo link za reset.';

  @override
  String get consentLabel =>
      'Saglasan/na sam sa obradom mojih zdravstvenih i telesnih podataka i prihvatam uslove korišćenja.';

  @override
  String get consentRequired => 'Morate prihvatiti uslove da biste nastavili.';

  @override
  String get validationRequired => 'Obavezno polje.';

  @override
  String get validationEmailInvalid => 'Unesite ispravnu email adresu.';

  @override
  String get validationPasswordShort =>
      'Lozinka mora imati najmanje 6 karaktera.';

  @override
  String get errorEmailInUse => 'Ovaj email je već registrovan.';

  @override
  String get errorInvalidEmail => 'Email adresa nije ispravna.';

  @override
  String get errorWrongCredentials => 'Pogrešan email ili lozinka.';

  @override
  String get errorWeakPassword => 'Lozinka je previše slaba.';

  @override
  String get errorTooManyRequests => 'Previše pokušaja. Pokušajte kasnije.';

  @override
  String get errorNetwork => 'Greška u mreži. Proverite konekciju.';

  @override
  String get errorGeneric => 'Došlo je do greške. Pokušajte ponovo.';

  @override
  String get accountSection => 'Nalog';

  @override
  String get profileRole => 'Uloga';

  @override
  String get roleClient => 'Klijent';

  @override
  String get roleTrainer => 'Trener';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get editProfile => 'Izmeni profil';

  @override
  String get save => 'Sačuvaj';

  @override
  String get cancel => 'Otkaži';

  @override
  String get logout => 'Odjavi se';

  @override
  String get profileSaved => 'Profil je sačuvan.';

  @override
  String get trainersTitle => 'Treneri';

  @override
  String get chooseTrainer => 'Izaberi trenera';

  @override
  String get noTrainers => 'Još nema trenera.';

  @override
  String get trainerBio => 'Biografija';

  @override
  String get emptyBio => 'Nema opisa.';

  @override
  String get manageRoles => 'Upravljaj ulogama';

  @override
  String get editTrainerProfile => 'Uredi trenerski profil';

  @override
  String get usersTitle => 'Korisnici';

  @override
  String get roleTrainerSwitch => 'Trener';

  @override
  String get notAuthorized => 'Nemate pristup ovoj stranici.';

  @override
  String get roleUpdated => 'Uloga ažurirana.';

  @override
  String get homeShortcuts => 'Prečice';

  @override
  String get nextTraining => 'Sledeći trening';

  @override
  String get noUpcomingTraining => 'Još nemaš zakazan trening.';

  @override
  String get bookTraining => 'Zakaži trening';

  @override
  String get comingSoon => 'Uskoro';

  @override
  String get availability => 'Dostupnost';

  @override
  String get weeklyAvailability => 'Nedeljni raspored';

  @override
  String get slotDuration => 'Trajanje termina';

  @override
  String get minutesShort => 'min';

  @override
  String get addTimeRange => 'Dodaj interval';

  @override
  String get from => 'Od';

  @override
  String get to => 'Do';

  @override
  String get exceptions => 'Izuzeci';

  @override
  String get addException => 'Dodaj izuzetak';

  @override
  String get blockWholeDay => 'Ceo dan';

  @override
  String get noExceptions => 'Nema izuzetaka';

  @override
  String get studioClosedDays => 'Neradni dani studija';

  @override
  String get closedWeekdaysLabel => 'Neradni dani u nedelji';

  @override
  String get closedDatesLabel => 'Neradni datumi';

  @override
  String get addClosedDate => 'Dodaj datum';

  @override
  String get availableSlots => 'Slobodni termini';

  @override
  String get noSlotsForDay => 'Nema slobodnih termina za izabrani dan';

  @override
  String get selectDay => 'Izaberi dan';

  @override
  String get weekdayMon => 'Pon';

  @override
  String get weekdayTue => 'Uto';

  @override
  String get weekdayWed => 'Sre';

  @override
  String get weekdayThu => 'Čet';

  @override
  String get weekdayFri => 'Pet';

  @override
  String get weekdaySat => 'Sub';

  @override
  String get weekdaySun => 'Ned';

  @override
  String get book => 'Rezerviši';

  @override
  String get bookConfirmTitle => 'Potvrda rezervacije';

  @override
  String bookConfirmBody(String time, String trainer) {
    return 'Rezerviši termin $time sa $trainer?';
  }

  @override
  String get booked => 'Rezervisano';

  @override
  String get slotTakenError => 'Termin je upravo zauzet.';

  @override
  String get pastSlotError => 'Ne možeš rezervisati termin u prošlosti.';

  @override
  String get myBookings => 'Moji termini';

  @override
  String get upcoming => 'Predstojeći';

  @override
  String get history => 'Istorija';

  @override
  String get mySessions => 'Moje sesije';

  @override
  String get noUpcomingBookings => 'Nemaš predstojećih termina.';

  @override
  String get noBookingHistory => 'Nema istorije.';

  @override
  String get noSessions => 'Nema zakazanih sesija.';

  @override
  String get statusBooked => 'Rezervisano';

  @override
  String get statusCancelled => 'Otkazano';

  @override
  String get cancelBooking => 'Otkaži termin';

  @override
  String get cancelConfirmTitle => 'Otkazivanje termina';

  @override
  String cancelConfirmBody(String time) {
    return 'Da li si siguran da želiš da otkažeš termin $time?';
  }

  @override
  String get cutoffPassedError =>
      'Ovaj termin je već počeo ili prošao — otkazivanje/pomeranje više nije moguće.';

  @override
  String get reschedule => 'Pomeri termin';

  @override
  String get rescheduleConfirmTitle => 'Pomeranje termina';

  @override
  String rescheduleConfirmBody(String time, String trainer) {
    return 'Pomeri termin na $time sa $trainer?';
  }

  @override
  String get rescheduled => 'Termin je pomeren.';

  @override
  String get cancelSuccess => 'Termin je otkazan.';
}
