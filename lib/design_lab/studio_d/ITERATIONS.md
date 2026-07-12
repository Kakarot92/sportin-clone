# Studio D — „Blok" · Iteracije

Neo-brutalist data studio. Ovaj fajl beleži prolaze QA-a. Pass 1 je builderov
code-level self-review; Pass 2 i 3 su direktorovi pixel-level prolazi.

---

## Pass 1 — code self-review (builder)

Prošao sam kroz svaki ekran kao neprijateljski dizajn-direktor. Nalazi i popravke:

### Kontrast (body ≥ 4.5:1) — najozbiljnija grupa
- **Merenja / hero delta badge** („-5.6 KG"): tekst je bio beo na zelenoj/crvenoj.
  Beli na `#27AE60` = 2.84:1, na `#FF4D2E` = 3.2:1 → **fail**. Prebačeno na **ink**
  tekst i ink strelicu (ink na zelenoj = 7.4:1, na crvenoj = 6.6:1). Boja bloka i
  dalje nosi semantiku (zeleno = napredak).
- **Merenja / tabela, delta čip** (mono 11px, po redu): isti problem, beli na
  zelenoj/crvenoj. → ink tekst.
- **Merenja / „PROMENA %"**: bila je obojena (zelena) reč na papiru = 2.84:1 → fail.
  Reč je sad **ink**, a semantiku boje nosi mali kvadratić-marker levo (zeleno/crveno
  u okviru). Kontrast rešen bez gubitka informacije.
- **Profil / crveni IZLAZ blok**: beli tekst na `#FF4D2E` (13px) = 3.2:1 → fail.
  → ink tekst + ink ikonica (6.6:1). Crveni blok + crn tekst je i inače brutalist look.
- Provereno da je **beli tekst dozvoljen samo na plavoj** (`#2B5BFF`, 4.93:1) i na ink —
  gde se i koristi (info-baner, prečica Poruke, plavi monogram). Sve ostalo (žuta,
  zelena, crvena) nosi ink tekst.
- **Poznata sitnica (nije body):** crveni pečat „OVERENO" na papiru (branding, dekor)
  je ~2.7:1. Ostavljen namerno kao grafički pečat, ne kao čitljiv sadržaj.

### Glyph rizik (mono font)
- Zaglavlje kolone bilo `Δ KG` — grčko Δ (U+0394) ne mora postojati u Space Mono →
  rizik od „tofu" kvadrata. Zamenjeno sa `± KG` (Latin-1, sigurno prisutno). Same
  delta-vrednosti su ASCII (`-0.6`), bez rizika.

### Tap-targeti < 48dp
- **TopBar strelica nazad**: padding 12 + ikona 20 = 44dp → povećan padding na 14 (48dp).
- **Composer „pošalji" dugme** (Poruke): 13+20 = 46dp → padding 14 (48dp).
- **Prijava, tekst-linkovi** („Zaboravljena lozinka?", „Nemaš nalog?"): bili ~38dp
  visine → uvijeni u `ConstrainedBox(minHeight: 48)`.

### Overflow na 360dp
- **Prijava / masthead**: `STUDIO` blok + fiksni tag „Obrazac br. 01/26" mogli su da
  pređu širinu na 360dp × textScale 1.2. Tag skraćen na „Obr. 01/26" i uvijen u
  `Flexible` + desno poravnanje. Ostali ekranski naslovi već koriste `Expanded(title) +
  fiksni tag`, pa su bezbedni.
- Sve tabele (Merenja 12 redova, spec-sheet, nalog) proverene na 360dp: mono kolone
  staju, delta čip staje u svoju kolonu; global `textScaler` je clamp-ovan na max 1.2
  da guste tabele ne pucaju.

### Poravnanje / grid ispod haosa
- Ceo studio stoji na `StudioDGridPaper` (milimetarski papir, 26px korak). Rotacije
  postoje SAMO na stikerima (ocena, streak, VIP, pečat) i retke su (±2–4°). Sve
  kartice, tabele i dugmad su strogo ortogonalne, 2px ink okvir, senka (4,4) bez blura.
- Sadržaj centriran i kepovan na `maxWidth: 560` (desktop web ne razvlači redove).

### Taktilni feedback
- `StudioDPressable` je jedini interaktivni blok: na pritisak translate (senka − travel)
  + skraćena senka, 90ms easeOutQuad → „utisne se u papir". Primenjen na sva dugmad,
  kartice trenera, redove poruka, prečice, tabove.

### Signature momenat po ekranu (provera „nije-AI-default")
- **Prijava:** rotirajući pečat „OVERENO" (dupli crveni okvir) + easter-egg (5 dodira).
- **Početna:** crno-žute „hazard" pruge (CustomPainter) na ivici žutog bloka termina.
- **Termini:** trading-card kartice sa ocenom-stikerom u uglu; detalj = zebra spec-sheet.
- **Merenja (star):** blok bar-chart + delta badge-ovi + zebra tabela sa `± KG` kolonom.
- **Poruke:** kupon-bubble sa izbušenim perforacijama po ivicama (CustomPainter).
- **Profil:** članska karta sa dashed perforacijom, mrežom iskorišćenih treninga,
  proceduralnim barkodom.

### Namerni upgrade kompleksnosti (Pass 1)
Na STAR ekranu (Merenja) dodata **trend-polilinija preko vrhova blokova**:
isprekidana ink linija + kvadratni čvorovi (poslednji u akcentnoj boji) sa mono
vrednošću iznad poslednjeg čvora. Geometrija čvorova deli istu `_studioDBarGrow`
funkciju sa trakama, pa linija „raste" tačno po vrhovima tokom kaskadne animacije
(levo→desno). Grafikon je refaktorisan u `Stack` sa predvidljivom geometrijom
(bend fiksne visine, oznake nedelja u zasebnom poravnatom redu) da bi overlay bio
piksel-tačan. Time je gustina podataka porasla bez dodatne buke — linija kodira svih
12 tačaka, a per-bar vrednosti (koje bi na 12 traka/360dp bile nečitljive) svedene su
na istaknutu poslednju + trend čvorove.

### Rezultat
`dart analyze lib/design_lab/studio_d` → **0 errors, 0 warnings, 0 info**.

---

## Poznate slabosti (za direktorov Pass 2)
- Pečat „OVERENO" (crveno na papiru) je ispod 4.5:1 — namerno kao dekor/branding, ne
  kao body tekst. Ako direktor traži, može ink varijanta.
- `google_fonts` fetuje Space Grotesk/Mono runtime-om; u offline preview-u fallback na
  sistemski font (bez crasha). Očekivano ponašanje paketa.
- Composer u chatu i polja na Prijavi su vizuelni mock (bez realnog unosa/slanja) —
  po zadatku (mock login, „poruke se ne šalju").
- Bar-chart normalizuje min→18% visine (ne 0) da najniža traka ostane vidljiva kao
  blok; apsolutne vrednosti nose tabela i MAX/MIN caption.
