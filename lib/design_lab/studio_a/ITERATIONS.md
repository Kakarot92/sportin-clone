# Studio A — „Kinetik" · Iteracioni dnevnik

## Pass 1 — code self-review (builder)

Neprijateljski prolaz kroz svaki ekran (ritam, poravnanje, kontrast, spacing,
tap-targeti, overflow na 360dp, režija animacija, signature moment).

### Nalazi i popravke

1. **Lint `use_null_aware_elements` (shell.dart)** — `if (currentChild != null)
   currentChild` u `AnimatedSwitcher.layoutBuilder` zamenjeno sa `?currentChild`.
   `dart analyze` sada čist (0/0).

2. **Tap-target < 48dp (Profil → redovi podešavanja)** — vertikalni padding 15
   davao je ~46dp. Dodat `minHeight: 48` + padding 16. Sada ≥ 48dp.

3. **Overflow rizik (Termini → red trenera, meta linija)** — `„8 GOD •
   2.500 RSD"` uz zvezdicu i ocenu moglo je da pređe 360dp. Umotano u
   `Flexible` + `TextOverflow.ellipsis`.

4. **`FittedBox` na svim hero brojevima/imenima** — potvrđeno: Prijava naslov,
   Početna weekday/time, Merenja hero kilaža, Detalj trenera imena i sve
   sekundarne pločice skaliraju se (`scaleDown`) → nema preloma na 360dp.

5. **Kontrast sekundarnog teksta** — `inkDim #8A8A90` na `bg #0B0B0C` = **5.7:1**
   (računato), iznad 4.5:1. Primarni `ink #F5F5F2` daleko iznad. Hint tekst u
   poljima je dekorativni placeholder (alpha 0.55), ne body.

6. **Režija animacija** — nijedna tranzicija ne koristi `Curves.linear`.
   Rute: `easeOutCubic`/`easeInCubic` (420/300ms). Count-up: `easeOutExpo`.
   Reveal: `easeOutCubic`, interval 52ms. Jedini linearni controller je
   **marquee** — namerno (fizika transportne trake, ne UI tranzicija), i
   dokumentovano u kodu.

### Namerni upgrade kompleksnosti (Pass 1)

**`StudioAPulseDot`** — proceduralni „tempo" metronom: dva volt prstena šire se
i blede u fazi razmaka 0.5 (`easeOutCubic`, beskonačno), sa punom tačkom u
centru. Postavljen uz labelu „SLEDEĆI TRENING" na Početnoj. Direktno služi
brief-u („da ekran izgleda kao da se kreće i dok stoji") bez dodatnog šuma.
Ceo efekat je `CustomPainter` — bez asseta, bez slika.

### Signature moment po ekranu (potvrda)

- **Prijava** — džinovsko vertikalno „STUDIO" (RotatedBox + ShaderMask volt
  gradijent na konturnom tekstu) + speed-lines preko cele pozadine.
- **Početna** — poster-blok sledećeg treninga sa dijagonalnim rezom (ClipPath),
  track-lane statovi sa count-up brojevima i ševronima brzine, marquee separator,
  novi tempo-puls.
- **Termini** — startna lista sa džinovskim konturnim rednim brojevima; „TVOJ
  TERMIN" traka sa volt levom ivicom.
- **Detalj trenera** — hero ime preko 2 reda (drugi red volt), ghost redni broj,
  count-up statistika, CTA koji se skew-uje i menja stanje („Trener izabran").
- **Merenja** — hero kilaža koja se „topi" od 94,2 → 88,6 (count-up 1600ms);
  CustomPainter grafikon sa volt glow linijom, gradijent fill, scrub interakcija
  (prevlačenje bira nedelju), prekidač metrika (težina/mast/struk).
- **Poruke** — startni redni identiteti (inicijali u oštrom kvadratu), „NOVO"
  skew značka; thread sa bubble-ovima oštrih ivica (moji = volt leva ivica),
  živ composer koji dodaje poruku + auto-scroll.
- **Profil** — članska karta sa dijagonalnim rezom, segmentni bar preostalih
  treninga (skew segmenti), volt „shine" sweep (tap = ponovi), diskretni izlaz
  u galeriju (grid ikonica u vrhu).

## Poznate slabosti (za direktorov Pass 2)

- **Speed-lines su statične** (seeded random), tekstura a ne animacija — svesna
  odluka radi čitljivosti/performansi; može se animirati u kasnijem prolazu.
- **Reveal koreografija se ponavlja** pri svakoj promeni taba (AnimatedSwitcher
  gradi ekran sa novim key-em) — namerna „re-režija", ali direktor može da je
  ublaži ako deluje repetitivno.
- **Bez `disableAnimations` opt-out-a** za marquee i puls (kontinuirane
  animacije) — kandidat za pristupačnosni prolaz.
- **Grafikon** prikazuje samo min/max vrednosti na Y osi; nema međuvrednosti na
  mreži (namerno čisto, ali direktor može tražiti gušću skalu).
- Hero imena u Detalju trenera pretpostavljaju 2 reči (mock podaci) — 3+ reči bi
  se složile u više redova (funkcionalno ispravno, vizuelno neprovereno).
