# Studio B — „Aurora" · Iteracije

## Pass 1 — code self-review (builder)

Neprijateljski prolaz kroz svaki ekran: ritam, poravnanje, kontrast, spacing,
tap-targeti, overflow na 360 dp, režija animacija, signature momenat.

### Nalazi i popravke

1. **Kontrast na najprovidnijim panelima.** Prečice (Početna) i metric-kartice
   (Merenja) bile su na `opacity 0.58` glass-a; sitne etikete (`inkSoft`, 10.5–
   11.5 px) rizik su na AA kad panel sedne nad zasićen aurora blob. → podignuto
   na `0.64`. Body/vrednosti ionako koriste `ink` (#1C2733, ~12:1), CTA je belo
   na violetu ≥ 4.6:1.
2. **Tap-target ispod 48 dp.** „Zaboravljena lozinka?" na Prijavi imao je
   `minimumSize (48, 44)` → `48×48`. Sva ostala tekstualna dugmad već ≥ 48.
3. **Rizik od overflow-a — „boarding pass".** Red „Iskorišćeno / Obnova" na
   članskoj karti mogao je da probije 360 dp (datum „28. jul 2026." + labele).
   → umotan u `FittedBox(scaleDown, centerLeft)`; nikad ne baca žutu traku,
   u najgorem slučaju se blago smanji. Razmak 24 → 20.
4. **`Container` sa dekoracijom bez potrebe.** Glass panel i boarding-pass
   koristili su `Container` gde je dovoljan `DecoratedBox`/`Material`; sređeno
   radi jasnoće (nema funkcionalne promene).
5. **Lint `use_null_aware_elements`.** `if (trailing != null) trailing!` u
   section-headeru → `?trailing`. `dart analyze` čist (0/0).

### Provera animacione režije (nijedna nije `Curves.linear`)

- Aurora mesh: 20 s besšavni loop (celobrojne sin/cos frekvencije), pulsiranje
  ±5 %. Sporo, bez cirkusa.
- Aurora „drift" po tabu: `easeInOutCubic`, 900 ms — nebo se prekomponuje dok
  se šeta kroz app.
- Breathing hero (logo, sledeći trening): 1,0 → 1,02, 4 s, `easeInOutSine`.
- Reveal (fade + lift): 620 ms `easeOutCubic`, stagger po delay-u.
- Push ruta: 520/400 ms `easeOutCubic` / `easeInCubic` + Hero avatar.
- Potvrda „Zahtev poslat": `easeOutBack` scale-in.
- Progres-prsten i area-chart: 1400 ms `easeOutCubic` crtanje.
- Pill pritisak: scale 0,965, 240 ms `easeOutCubic`.

### Namerni upgrade kompleksnosti (obavezan, pass 1)

**Specular sjaj preko „boarding pass" karte.** Dodat `_SheenPainter`: dijagonalni
(-0,38 rad) beli highlight koji `easeInOutSine`-om prelazi preko karte u prvih
~45 % petlje (5,2 s), pa miruje. `IgnorePointer`, ispod teksta — tekst ostaje
oštar, karta dobija „premium" dubinu. Time članarina ima drugi živi sloj povrh
statične aurore.

### Poznate slabosti (za direktorov pass 2)

- „Aktivan danas" i datum na Početnoj (`utorak, 8. jul`) su hardkodovani da se
  slažu sa `mockNextSession` (sreda, 9. jul = „sutra"); nema realnog sata.
- Dva `MaterialApp`-a u steku (galerija → StudioBApp) je po ustavu OK, ali svaki
  Hero/Navigator živi u StudioBApp-ovom stablu — direktor da proveri povratak
  `onExit` iz Profila (pop galerijske rute).
- Sheen i aurora rade neprekidno; na jako slabom webu proveriti FPS (oba su
  `RepaintBoundary`/CustomPaint, ali su stalni).
- Kontrast meren analitički, ne pikselno nad živim meshem — pass 2 (Chrome
  screenshot) da potvrdi najgori slučaj: glass nad `blobPink`.
