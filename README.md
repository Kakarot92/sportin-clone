# Đole — Studio Training App

Mobilna/web aplikacija za trening studio (u stilu *sportIN*, prilagođena za klijenta).
Klijenti se prijavljuju, biraju trenera, gledaju slobodne termine u kalendaru i
zakazuju 1-na-1 treninge. Vlasnik je trener + još dva trenera; predviđeno i
praćenje telesnih mera.

Rađeno **Flutter + Firebase**, dizajn **Kinetik** (tamna tema, volt-žuta `#CCFF00`).

---

## Pokretanje na novom računaru

**1. Preduslovi** (instaliraj jednom):
- [Git](https://git-scm.com/) i [Flutter SDK](https://docs.flutter.dev/get-started/install) (Flutter donosi Dart).
- Proveri: `flutter doctor`.
- Za web pregled dovoljan je Chrome ili Edge.

**2. Kloniraj i pripremi:**
```bash
git clone https://github.com/Kakarot92/sportin-clone.git
cd sportin-clone
flutter pub get
```

**3. Pokreni (web):**
```bash
flutter run -d edge --web-port=8080
# ili: flutter run -d chrome
```
Za Android emulator vidi napomenu na dnu.

**Demo prijava** (radi odmah — Firebase je u cloud-u):
```
Email:    demo@djole.app
Lozinka:  Demo12345
```
> Firebase konfiguracija (`lib/firebase_options.dart`) je u repo-u; to su javni
> *client* ključevi zaštićeni Firestore pravilima (`firestore.rules`). Nema
> `.env` tajni za ručni prenos.

---

## Tehnologije

| Sloj | Izbor |
|------|-------|
| UI | Flutter, Material 3, `google_fonts` (Archivo Black + Inter Tight) |
| State | Riverpod 3 (`Notifier`/`AsyncNotifier`) |
| Rute | `go_router` (StatefulShellRoute, 5 tabova) |
| Backend | Firebase Auth (email/lozinka) + Cloud Firestore |
| Kalendar | `table_calendar` |
| Jezik | Srpski (default) + engleski, `flutter_localizations` + `intl` |

## Struktura

```
lib/
  app/            # tema (Kinetik), router, kinetic UI primitivi, providers
  core/models/    # AppUser, TrainerProfile
  features/
    auth/         # prijava, registracija, reset lozinke
    home/         # početna (sledeći trening)
    trainers/     # direktorijum trenera, profil
    scheduling/   # dostupnost trenera, izuzeci, studio neradni dani, slot browser
    booking/      # rezervacija (bez duplog bukiranja), moji termini, sesije trenera
    admin/        # dodela uloge trener
    profile/      # nalog, tema, jezik
  l10n/           # app_en.arb, app_sr.arb (+ generisani AppLocalizations)
firestore.rules   # role-based sigurnosna pravila (deploy-ovana)
missions/         # stanje "mission" workflow-a (plan, ugovor, run-log)
```

## Napredak (milestones)

- ✅ **M1** Temelj · ✅ **M2** Auth + uloge · ✅ **M3** Treneri
- ✅ **M4** Raspored i dostupnost · ✅ **M5** Zakazivanje (1-na-1) *(kreditni gate odložen)*
- ⏭️ **M6** Otkazivanje/pomeranje · dalje: paketi/krediti, merenja

Detaljan dnevnik: [`missions/20260707-170633/run-log.md`](missions/20260707-170633/run-log.md).

---

## Napomene

- **Android emulator na ovom kompu** zahteva da se u BIOS-u uključi **SVM Mode**
  (AMD virtuelizacija) — bez toga radi samo web/fizički uređaj.
- **Firebase MCP / deploy pravila iz Claude Code**: na novom kompu uradi
  `firebase login` (potrebno samo ako menjaš/deploy-uješ pravila ili sejaš podatke).
- Projekat je vođen **exexutor** „mission" frameworkom — vidi
  [`CLAUDE.md`](CLAUDE.md), [`DOCS.md`](DOCS.md), [`EXEXUTOR-README.md`](EXEXUTOR-README.md).
