# Dizajn-ustav — Design Lab „Studio"

Važi za svih 5 studija. Nepregovarački. Kršenje = rad se vraća.

## Proizvod

Booking aplikacija za fitnes studio (sportIN-style). Dizajniramo **klijentski** doživljaj.
Površine koje SVAKI studio isporučuje (isti sadržaj, radikalno drugačiji vizuelni jezik):

1. **Prijava** — mock (dugme „Prijavi se" ulazi u app bez backend-a), ali vizuelno puna forma
2. **Početna** — pozdrav (`mockUser`), sledeći trening (`mockNextSession`), nedeljne statistike (`mockWeekStats`), prečice
3. **Termini** — direktorijum trenera (`mockTrainers`) → detalj trenera (push): bio, specijalnost, ocena, cena, CTA „Izaberi trenera"
4. **Merenja** — trenutni brojevi + grafikon napretka 12 nedelja (`mockMeasurements`) — data-viz momenat studija
5. **Poruke** — lista razgovora (`mockThreads`) → thread (push) sa porukama
6. **Profil** — korisnik, uloga, članarina (`mockMembership`), odjava + **diskretno dugme koje zove `onExit`** (povratak u galeriju)

## Pravila

1. **SAMO REALAN COPY** — srpski. Izvor: `lib/l10n/app_localizations_sr.dart` + `mock_data.dart`. Lorem ipsum = fail.
2. **DISTINKTIVNA TIPOGRAFIJA** — `google_fonts` po brief-u. Default Roboto = fail.
3. **NAMERNE KRIVE** — nikad `Curves.linear`. Svaka tranzicija ima režiranu krivu i trajanje.
4. **RESPONSIVNO** — 360–430dp telefon I desktop web, bez overflow-a, bez žutih traka.
5. **PRISTUPAČNOST** — kontrast body teksta ≥ 4.5:1; tap-target ≥ 48dp.
6. **NULA GREŠAKA** — `dart analyze` čist za tvoj folder; nula runtime crvenih ekrana.
7. **NAMERNA KOMPLEKSNOST** — svaki ekran bar jedan „nije-AI-default" momenat: proceduralna tekstura, mikro-interakcija, neočekivan layout potez. Ravna kartica na sivoj pozadini = fail.
8. **BEZ DELJENIH KOMPONENTI** — ništa se ne importuje iz drugih studija niti iz pravog app-a (jedini dozvoljeni deljeni import: `../mock_data.dart`). Konvergencija dva studija = fail oba.

## Tehnički kontrakt

- Folder: `lib/design_lab/studio_<x>/` — **jedini** koji builder sme da menja.
- Ulaz: klasa `Studio<X>App({super.key, this.onExit})` u `studio_<x>.dart` — ime i potpis fiksni (galerija zavisi od njih). Studio je sopstveni `MaterialApp` (svoja tema). `onExit` se poziva iz diskretnog dugmeta (npr. u Profilu).
- Sve javne klase prefiksovane sa `Studio<X>` (kolizije među studijima).
- Podaci: isključivo `import '../mock_data.dart';`
- **Zabranjeno:** menjati `pubspec.yaml`, `gallery.dart`, `mock_data.dart`, tuđe foldere, bilo šta van `design_lab`; dodavati pakete; asseti na disku; fragment shaderi; `Image.network`. Sve vizuale graditi proceduralno (CustomPainter, gradijenti, ShaderMask, BackdropFilter).
- Git: builder NE komituje. `flutter run`: builder NE pokreće (direktor pokreće preview).

## Iteracioni protokol (3 prolaza po studiju)

- **Pass 1 (builder, code-level):** neprijateljski self-review svakog ekrana — ritam, poravnanje, kontrast, spacing skala, režija animacija. Popravi sve + dodaj JEDAN namerni upgrade kompleksnosti. Nalazi u `ITERATIONS.md`.
- **Pass 2 i 3 (direktor, pixel-level):** direktor renderuje app u Chrome-u, snima desktop + mobile screenshotove (vrh/sredina/dno), čita konzolu, i vraća QA beleške. Builder popravlja + po pravilu dodaje jedan upgrade po prolazu.
