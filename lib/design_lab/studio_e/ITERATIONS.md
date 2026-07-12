# Studio E — „Dubina" · Iteracije

Neon cinema: slojevi ugljena, cyan/violet glow kao začin, parallax dubina,
animirani hero-orb. Syne (display) + IBM Plex Sans (body).

## Pass 1 — code self-review (builder)

Prošao sam kroz svaki ekran kao neprijateljski dizajn-direktor. Nalazi i popravke:

### Kontrast (body ≥ 4.5:1)
- Proverio `#8D97A8` (textDim) na sve tri pozadine:
  - na `#0C0F14` (bg): ≈ 6,5:1 ✓
  - na `#1A2130` (layer2, najsvetlija kartica): ≈ 5,4:1 ✓
  - Primarni tekst `#EDF1F7` je svuda visoko iznad praga.
- Micro-labele (9–11px, uppercase) su isključivo dekorativne/sekundarne i i dalje
  prolaze prag; nijedan nosilac informacije nije ispod 4.5:1.
- Neon akcenti (cyan/violet) koriste se samo za istaknute brojeve/CTA na tamnoj
  podlozi — visok kontrast.

### Tap-targeti (≥ 48dp) — NAĐENO I POPRAVLJENO
- **Prekidač metrike (Merenja):** tabovi su bili 40dp visoki → podignuto na **48dp**.
- **Avatar u header-u Početne** (prečica na Profil): bio 46dp → **48dp**.
- Ostalo već ≥48: nav stavke (64dp red), back dugme (48), glow CTA (56),
  send dugme (48), „Zaboravljena lozinka?" (theme minimumSize 48), toggle lozinke (48).

### Glow disciplina (max 2–3 po ekranu)
- Audit po ekranu — svuda ≤ 3 glow tačke (glow = začin):
  - Prijava: orb + (fokus-glow na aktivnom polju) + CTA.
  - Početna: samo hero-orb je jak glow; statovi/prečice/kartice bez glow-a.
  - Termini: jedan emphasis (zakazani termin); trenerske kartice bez glow-a.
  - Detalj trenera: glow avatar + cyan CTA (2).
  - Merenja: emphasis „Težina" + neon linija charta (data-viz momenat) (2).
  - Poruke: samo nepročitani razgovor nosi glow (+ glow tačka istog elementa).
  - Chat: samo send dugme.
  - Profil: glow avatar + access-card (2).

### Spacing / ritam
- Sve razmake vezao za `StudioESpace` skalu (4pt grid); sekcijski ritam = 28.
- Sekcijske etikete (neon crtica + caps) daju konzistentan vertikalni puls.

### Režija animacija (nikad `Curves.linear`)
- Tranzicije: `easeOutQuint` (push, tabovi, entrance, count-up, draw-in charta),
  `easeOutCubic`/`easeInOutCubic` (fokus polja, morph charta), `easeInCubic` (reverse).
- Orb: rotacija je kontinualna (AnimationController.repeat) — konstantna ugaona
  brzina je namerna za beskonačno okretanje; nije `Curves.linear` tween tranzicija.
- Orb tempo: najbrži prsten ~1 krug / 13s, „dah" jezgra period ~18s → spor i
  hipnotičan, ne vrtoglav.

### 60fps svest
- `RepaintBoundary` oko orb-a, charta i parallax pozadine.
- Statični painteri (sparkline, ring članarine) imaju `shouldRepaint => false`.
- Inaktivni tabovi se dispose-uju (AnimatedSwitcher) → aktivan je samo jedan
  animirani backdrop/orb u datom trenutku.

### Overflow na 360dp
- 3-u-red grupe (statovi, trenutna merenja, metrike trenera) koriste `FittedBox`
  na labelama i `Flexible`/`Expanded` + `ellipsis` na tekstu → bez žutih traka.
- Orb hero: `clamp(240, 330)` po širini ekrana.
- Trenerska kartica: ime `Expanded`+ellipsis, iskustvo `Flexible`+ellipsis.

### Tri plana dubine (dokaz brief-a)
- Svaki ekran: (1) parallax glow blob-ovi pozadi, (2) depth kartice sredina,
  (3) neon akcenti (orb, indikatori, CTA) napred.

## Namerni upgrade kompleksnosti (Pass 1)

**Autonomni drift parallax pozadine.** Pre: blob-ovi su se pomerali samo na
scroll — Prijava i Chat (bez skrola) imali su statičnu pozadinu. Sada
`StudioEParallaxBackdrop` ima sopstveni spori tiker (42s) i kombinuje sinusni
drift sa scroll-offset-om, pa svaki ekran zadrži živu kinematsku dubinu
(„neonska reklama preko puta" diše i kad se ne skroluje). Amplituda je mala
(16–24px), izolovano u `RepaintBoundary`.

## Verifikacija
- `dart analyze lib/design_lab/studio_e` → **No issues found!** (0 errors, 0 warnings, 0 info).

## Poznate slabosti (za direktorov Pass 2)
- Chat bubble `maxWidth` je vezan za `MediaQuery.width * 0.76`; na širokom
  desktopu ga kapira 560px container preko `Flexible`, ali bi eksplicitan
  `LayoutBuilder` bio čistiji.
- Count-up animacije kreću pri svakom mount-u taba (AnimatedSwitcher rekreira
  ekran) — namerno „oživljavanje", ali direktor nek proceni da li je preučestalo.
- Pozdrav na Početnoj zavisi od `DateTime.now()` (jutro/dan/veče) — vizuelno
  konzistentno, ali nije fiksno za screenshot reprodukciju.
- Orb i backdrop rade neprekidno dok je ekran živ; na jako slabim uređajima
  vredi proveriti termalni profil (nije primećen problem u analizi).
