# Studio C — „Editorial Noir" · Iteracioni dnevnik

Studio-magazin: bone papir, ink tekst, terakota kao jedini akcenat, hairline
grid, veliki vazduh. Fraunces (display) + Inter (UI). Disciplina: RESTRAINT.

## Arhitektura fajlova

| Fajl | Uloga |
| --- | --- |
| `studio_c.dart` | Ulaz `StudioCApp` — MaterialApp, tema, papirno zrno, `onExit` prosleđen |
| `theme.dart` | Tokeni (paleta, tipo-skala, formatери brojeva), `StudioCTheme` |
| `widgets.dart` | Deljeni elementi: hairline, kicker, reveal, route, dugmad, polje, zrno, marginalija, leader |
| `login_screen.dart` | Prijava — naslovna strana / masthead |
| `shell.dart` | Shell + editorial nav (serif folio 01–05, bez ikonica) |
| `home_tab.dart` | Početna — „današnje izdanje" |
| `schedule_tab.dart` | Termini — imenik trenera |
| `trainer_detail_screen.dart` | Detalj trenera — profil-članak sa lettrine bio-om |
| `measurements_tab.dart` | Merenja — ledger + ink linija grafikona |
| `messages_tab.dart` | Poruke — lista korespondencije |
| `chat_thread_screen.dart` | Thread — „korespondencija" bez bubble-ova |
| `profile_tab.dart` | Profil — kolofon + fusnota `onExit` |

## Signature tehnike (brief traži min. 4 — isporučeno 6)

1. Editorial grid: velike margine (24), asimetrični levo-teški naslovi, kolona ≤ 640.
2. Hairline separatori + numerisani uppercase kickeri („01 — TERMINI").
3. Lettrine u bio-u trenera: drop-cap inicijal + razmaknute verzalne uvodne reči.
4. Minimalan motion: fade + translate, 320ms, `Curves.easeOutQuart`, stagger.
5. Marginalia: vertikalni folio uz ivicu (detalj trenera).
6. Proceduralno papirno zrno (`CustomPainter`, fiksni seed) preko cele scene.

---

## Pass 1 — code self-review

Prošao svaki ekran kao neprijateljski dizajn-direktor. Nalazi i popravke:

### Ritam i grid
- **Baseline razmaci** svedeni na skalu 4/6/8/10/12/14/16/18/22/26/28. Uklonjeni
  proizvoljni „magični" razmaci.
- **Home standfirst**: dodat propušteni `SizedBox(height:12)` između podnaslova i
  „ČITALAC" meta reda (bio zalepljen).
- **Termini/Poruke** kickeri: `const` konstruktor je davao string-interpolaciju u
  `trailing` → prebačeno na ne-const `StudioCReveal` (build greška izbegnuta pre analyze).

### Poravnanje / overflow na 360dp
- **Merenja `_NowCell`**: vrednost „94,2 kg" na 30px numeralu je na 360dp prelazila
  ~84px sadržaja ćelije (rizik od preloma reda i pomeranja baseline-a). Popravka:
  ceo red (vrednost + jedinica) umotan u `FittedBox(scaleDown, centerLeft)`.
- **Masthead** („STUDIO", 84px, letterSpacing 14): `FittedBox(scaleDown)` +
  kompenzacioni `padding-left:14` da poslednji glif ne visi ulevo.
- **Stat/Fact/Now labele**: sve uppercase labele u `FittedBox(scaleDown)` — nema
  žutih traka ni na 360dp.
- **Nav labele**: `FittedBox(scaleDown)` po stavci (5 tabova na 360dp).

### Grafikon (data-viz)
- **Prva tačka** je najviša (početna, najveća težina) → njena labela je izlazila
  IZNAD platna (`y = topPad − 16 ≈ −2`). Popravka: labela pomerena ISPOD tačke
  (`dy + 6`), poslednja (najniža) ostaje iznad.
- Rez linije: beli čvorovi (bone fill + ink stroke) na svakom merenju; terakota
  marker + prsten SAMO na poslednjem (poštuje „terakota za male elemente").
- X-osa: tick svake 3 nedelje sa tabularnim numeralom — bez pretrpavanja.

### Kontrast (WCAG)
- Body `inkSoft #5C554A` na `bone #F4EFE6` ≈ **6,35:1** (≥ 4.5 ✓).
- Terakota se koristi ISKLJUČIVO za male akcente (numeral, delta, CTA tekst,
  separator) — nikad za body blok. Jedan akcenat, bez izuzetka.

### Tap-targeti
- Svi interaktivni redovi/linkovi/dugmad ≥ 48dp: nav stavke (64), povratne strelice
  (48), „zaboravljena lozinka"/„napravi ga" (48), primarno/ghost dugme (56),
  „pošalji" (48), fusnota kolofona (48).

### Tipografske udovice
- Naslovi su 1–2 reči (Napredak, Imenik trenera, Korespondencija) — bez udovica.
- „Dobrodošli u vaš studio" prelama balansirano; nbsp-hack svesno preskočen zbog
  rizika neподударања ć/š bajtova u izvoru (ne-suštinski trošak).

### Režija animacija
- Jedinstven `StudioCReveal` (fade + translate 14px, 320ms, easeOutQuart, stagger
  45ms×order). Push tranzicija `StudioCRoute` (fade + 2.5% slide). Nigde `linear`.
- Tab-switch: `AnimatedSwitcher` sa 0.6% slide-om — „ništa ne skače".

### Namerni upgrade kompleksnosti (obavezan +1)
- **Lettrine otvor bio-a**: `_DropCapParagraph` prerađen sa običnog „inicijal pored
  bloka" na pravi magazinski lettrine — oversized inicijal + prve dve reči u
  razmaknutom verzalu (`Text.rich`, regex-split na inicijal/uvod/ostatak). To je
  najjači „ovo je slagao čovek-tipograf" signal i direktno služi brief tehnici #3.

### Verifikacija
- `dart analyze lib/design_lab/studio_c` → **No issues found** (0 err / 0 warn / 0 info).
- Ispravljen 1 info-lint: `use_null_aware_elements` u `shell.dart` (`?currentChild`).

## Poznate slabosti (za direktorov Pass 2)
- Lettrine je „hanging initial" (inicijal pored bloka), ne pravi float-drop-cap sa
  obavijanjem teksta oko slova — Flutter nema jeftin float bez custom RenderObject-a.
- Grafikon je statičan (bez scrub/tooltip interakcije) — svesna suzdržanost, ali
  kandidat za mikro-interakciju u Pass 2/3.
- Nav labele na vrlo uskim ekranima (≤ 340dp) idu kroz `FittedBox` skaliranje;
  proveriti čitljivost na realnom malom uređaju.
