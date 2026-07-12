# DESIGN LAB — 5 studija, jedan direktor

> Prompt za orkestrator-sesiju. Cilj: napraviti **5 fundamentalno različitih, kompletnih
> vizuelnih dizajna** aplikacije **„Studio"** (sportin-clone), svaki u izolovanom folderu,
> proći svaki kroz **3 obavezna iteraciona prolaza**, pa mi na kraju servirati galeriju da
> **izaberem pobednika**. Pobednik se posle portuje u pravi `lib/`.

---

## 0. Kontekst aplikacije (nemenjivo — ovo je proizvod)

Aplikacija je booking platforma za fitnes studio (sportIN-style). Flutter, Firebase,
Riverpod, go_router, i18n (SR primarno / EN). Uloge: **Klijent, Trener, Administrator**.

Pet donjih tabova + auth tok koji SVAKI studio mora da isporuči (isti sadržaj, drugačiji
vizuelni jezik):

| # | Ekran | Ruta | Šta mora da pokaže |
|---|-------|------|--------------------|
| 1 | **Splash + Prijava** | `/splash`, `/login`, `/signup`, `/reset` | brend, prvi utisak, forme sa validacijom |
| 2 | **Početna** | `/home` | pozdrav, sledeći trening, prečice, „hero" momenat |
| 3 | **Termini** | `/schedule` → `/schedule/trainer/:uid` | lista/grid trenera → profil trenera (bio, izbor) |
| 4 | **Merenja** | `/measurements` | brojevi + grafikon napretka (data-viz momenat) |
| 5 | **Poruke** | `/chat` | lista razgovora / thread sa trenerom |
| 6 | **Profil** | `/profile` | nalog, uloga, tema/jezik, logout |

**Realan copy je obavezan.** Koristi postojeće srpske stringove iz
`lib/l10n/app_localizations_sr.dart` (npr. „Dobrodošli u vaš studio", „Zakazujte treninge,
pratite napredak i dopisujte se sa trenerom.", „Termini", „Merenja", „Poruke", „Izaberi
trenera", „Nema opisa."). Nikakav lorem ipsum, nikakav placeholder tekst.

---

## 1. Arhitektura: jedan direktor, pet studija

**Orchestrator/builder split — ključni trik nije „generiši app 5 puta".**

- **Jedna orkestrator-sesija (ti)** piše zajednički **dizajn-ustav** (`design_lab/CONSTITUTION.md`)
  + **5 individualno art-direktovanih brief-ova** (`design_lab/briefs/studio_[a-e].md`), pa
  potom radiš kao **dizajn-direktor**: gledaš screenshotove svakog gotovog studija SAM,
  vraćaš na doradu sa konkretnim QA beleškama (line-break usred reči, dugme sa slabim
  kontrastom, ekran udavljen u pozadini).
- **5 builder agenata** (subagenti istog modela), svaki dobija JEDAN brief i punu autonomiju
  nad JEDNIM folderom. **Bez šablona, bez deljenih komponenti** — namerno, da nijedna dva
  studija ne mogu da konvergiraju. Svaki studio pravi svoj theme, svoje widgete, svoju
  tipografiju od nule.

Ti (orkestrator) **ne pišeš app kod direktno** — skopiraš ustav i brief-ove, spawnuješ
buildere, pokrećeš validatore, radiš QA, biraš pobednika.

---

## 2. Dizajn-ustav (non-negotiables — važi za svih 5)

Ovo je nepregovarački build-standard. Svaki studio mora da ga zadovolji pre nego što ga
okejim:

1. **Samo realan copy** — srpski stringovi iz `app_localizations_sr.dart`. Bez placeholdera.
2. **Distinktivna tipografija** — svaki studio bira sopstveni type sistem preko `google_fonts`
   (ili bundlovan font). Nikad default Roboto. Type mora da nosi ličnost studija.
3. **Custom easing / krive** — nikad goli `Curves.linear`. Namerne krive (`Curves.easeOutCubic`,
   `Cubic(...)`, custom `Curve`) za svaku tranziciju; svesan ritam animacije.
4. **Responsivnost** — radi na telefonu (360–430 dp) I na web/tabletu. Bez horizontalnog
   scroll-a, bez overflow žutih traka, safe-area svestan.
5. **Pristupačnost** — kontrast tekst/pozadina ≥ WCAG AA (4.5:1 za body), tap-target ≥ 48dp,
   `Semantics` gde ima smisla.
6. **Nula grešaka** — `flutter analyze` čist, nula crvenih grešaka u konzoli pri renderu
   (proverava se u loop-u, vidi §5).
7. **Namerna kompleksnost** — svaki ekran mora da ima bar jedan „ovo nije AI-default" momenat:
   tekstura, mikro-interakcija, custom painter, sloj dubine, marginalija. Ravna Material
   kartica na sivoj pozadini = automatski fail.

---

## 3. Pet brief-ova (art-direkcije)

Svaki brief specificira: **koncept, paletu, tipografiju, signature tehniku, i jednu stvar
koju studio MORA da dokaže.** Predlog 5 međusobno maksimalno udaljenih pravaca (orkestrator
sme da finalizuje/zameni, ali mora da ostane 5 distinktnih osa):

- **Studio A — „Kinetik" (atletski / energija).** Oversized condensed variable type, near-black
  + jedan electric akcenat (volt/acid lime), dijagonalna kompozicija, speed-line motion,
  krupni brojevi. **Dokazuje:** kinetičku tipografiju i motion.
- **Studio B — „Aurora / Glass" (wellness / smirenost).** Frosted glass (`BackdropFilter`),
  proceduralni aurora mesh-gradijent u pozadini (CustomPainter/fragment shader), pasteli,
  vazdušasto, zaobljeno. **Dokazuje:** dubinu, blur, gradient mesh, mir.
- **Studio C — „Editorial Noir" (premium boutique).** Serif display + fini grotesk, velika
  bela površina, strog grid, topli neutrali (bone/ink/terakota), fotografski. **Dokazuje:**
  tipografsku disciplinu i luksuz kroz restraint.
- **Studio D — „Neo-Brutalist Data" (coach-driven).** Tvrde ivice, ravni blokovi, monospace
  numerali, sticker-badževi, merenja/napredak gurnuti u prvi plan. **Dokazuje:** gustu
  informaciju sa stilom i ličnošću.
- **Studio E — „Depth / 3D Immersive" (kinematski dark).** Slojevita dubina, suptilan
  parallax, glow, pravi animirani/3D hero (custom shader ili rotirajući objekat), neon na
  ugljenoj pozadini. **Dokazuje:** 3D/shader sposobnost i imerzivni dark UI.

---

## 4. Radni prostor & izolacija

- Sav rad ide u **`design_lab/`** — pravi `lib/` se **NE dira**.
- Struktura: `design_lab/studio_a/ … studio_e/`, svaki self-contained (theme + ekrani + assets).
- **Design-lab launcher**: mali `design_lab/gallery.dart` (+ zaseban `main` entry, npr.
  `lib/design_lab_main.dart`) sa 5 dugmadi za skok u svaki studio — da mogu da prelistavam
  svih 5 iz jedne aplikacije. Pokreće se sa `flutter run -t lib/design_lab_main.dart -d chrome`.
- Svaki studio radi na **mock podacima** (hardkodovani treneri, merenja, poruke) — bez
  Firebase zavisnosti, da galerija radi offline i deterministički.

---

## 5. Self-critique loop (3 obavezna prolaza) — OVO JE DEO KOJI SE RAČUNA

Flutter nema Puppeteer, pa koristimo **Flutter web + preview_screenshot MCP**. Jedan prolaz:

1. **Renderuj pravi ekran** u Chrome-u: `flutter run -t lib/design_lab_main.dart -d chrome`
   (ili build web), pa preko `preview_*` alata snimi **desktop I mobile viewport**, i za svaki
   ključni ekran po **vrh / sredina scroll-a / dno**. Uhvati **console greške** i visinu dokumenta.
2. **Gledaj piksele.** Agent čita SVOJE screenshotove vizuelno i kritikuje kao neprijateljski
   dizajn-direktor: ritam, poravnanje, kontrast, udovice (widow reči), mrtve zone, sve što
   „smrdi na AI-default".
3. **Popravi sve nađeno** — pa dodaj **jedan namerni upgrade kompleksnosti** (tekstura,
   mikro-interakcija, marginalija, easter egg). Pravilo o upgrade-u sprečava da iteracija
   konvergira u bezličnu sigurnost.

Zašto radi: code-review ne vidi udovicu ni mutno dugme. Zatvaranje petlje između napisanog
koda i renderovanih piksela je ono što pretvara „uverljiv izlaz" u dizajn-prosuđivanje.

**Minimum 3 puna prolaza po studiju pre nego što se okeji.** Beleži nalaze svakog prolaza u
`design_lab/studio_x/ITERATIONS.md`.

---

## 6. Asset pipeline (bez Higgsfield-a)

Higgsfield krediti nedostupni → dva izvora:

- **Pinterest (referenca).** Korisnik daje email za pristup; skidaš referentne slike SAMO kao
  moodboard/inspiraciju u `design_lab/studio_x/refs/`. Referenca ≠ krađa: iz nje izvlačiš
  paletu, kompoziciju, type-pairing — pa gradiš original.
- **Proceduralno (default, „restraint is also a budget").** Većina vizuala iz Fluttera:
  `CustomPainter`, gradijenti, **fragment shaderi** (`.frag` / `FragmentProgram`), implicit +
  explicit animacije, SVG. Nula troška, potpuna kontrola.
- Ako se koristi bilo koja rasterska referenca u samom UI-ju: optimizuj (ffmpeg → WebP,
  ≤1920w). 5 MB PNG → 40–190 KB.

---

## 7. Isporuka & „/guide" ekvivalent

- **Galerija** (`design_lab/gallery.dart`) — jedan ekran, 5 ulaza, da biram pobednika.
- **`design_lab/DESIGN_LAB.md`** — kratak writeup „kako sam ovo napravio i kako da ponoviš"
  (ekvivalent `/guide` rute iz originala): arhitektura direktor/studio, ustav, 3-pass loop,
  asset izvori. Da drugi mogu isto.
- Po studiju: `brief.md`, `ITERATIONS.md` (nalazi 3 prolaza), screenshotovi u `refs/shots/`.

## 8. Kraj: izbor pobednika

Kada su svih 5 prošli 3 prolaza i zadovoljili ustav, spakuj galeriju i **servirati mi je** sa
kratkim rezimeom jačih/slabijih strana svakog studija. **Ja biram pobednika.** Tek posle mog
izbora portujemo pobednika u pravi `lib/` (novi task, ne sad).

---

### Radni redosled (za orkestratora)
1. Napiši `design_lab/CONSTITUTION.md` + 5 brief-ova.
2. Postavi `lib/design_lab_main.dart` + `design_lab/gallery.dart` skelet + mock podatke.
3. (Ako Pinterest) traži email, skini reference u `refs/`.
4. Spawnuj 5 builder agenata — svaki svoj folder, pun brief, ustav, mock data.
5. Za svaki studio pokreni 3-pass loop; vraćaj sa QA beleškama dok ne zadovolji ustav.
6. Sklopi galeriju + `DESIGN_LAB.md`. Serviraj mi izbor.

> Radi autonomno unutar `design_lab/`. Pitaj me samo za: (a) Pinterest email, (b) finalni
> izbor pobednika. Sve ostalo odlučuješ sam.
