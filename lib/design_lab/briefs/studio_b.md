# Studio B — „Aurora"

Wellness smirenost. Svetla aplikacija koja diše: animirani aurora gradient u
pozadini, frosted-glass paneli, pill forme, meke senke.

## Paleta
- Pozadina: animirani mesh — `#E9F1FF`, `#FCE9F5`, `#E7FBF2` (spori blob prelazi)
- Glass: bela 55–70% opacity + blur 20–28
- Tekst: `#1C2733` primarni, `#5A6B7C` sekundarni — kontrast na glass panelima mora AA!
- Akcenti: `#6F5FE6` (violet) primarni CTA, `#2FB593` (mint) uspeh/napredak

## Tipografija (google_fonts)
- Display: **Sora** (SemiBold naslovi)
- Body: **Manrope**
- Tretman: mekan; izdašan line-height; bez agresivnih uppercase blokova

## Signature tehnike (minimum 4)
1. Aurora pozadina: CustomPainter sa 3–4 blob-a (radial gradijenti) koji se SPORO pomeraju (~20s loop, `AnimationController.repeat`) — suptilno, ne cirkus
2. `BackdropFilter` glass kartice sa 1px belom ivicom na 40% opacity
3. „Breathing" mikro-animacija: scale 1.0→1.02 na hero elementu, ~4s, `Curves.easeInOutSine`
4. Progres prsten za merenja (CustomPainter arc sa gradijentom violet→mint)
5. `Hero` tranzicija avatara između liste trenera i detalja

## Mora da dokaže
Dubinu i mir: slojevi providnosti nad živom pozadinom, a čitljivost netaknuta.

## Po ekranima
- **Prijava:** aurora full-screen, plutajuća glass forma, tipografski logo
- **Početna:** pozdrav + sledeći trening u glavnoj glass kartici; statovi kao pill čipovi
- **Termini:** treneri kao glass kartice sa gradijent-avatarima (inicijali); detalj sa Hero avatarom
- **Merenja:** veliki progres-prsten (kg ↓) + glatka area-chart linija (CustomPainter)
- **Poruke:** glass bubble-ovi (moji sa violet tintom), thread nad aurorom
- **Profil:** članarina kao glass „boarding pass"; izlaz diskretno pri dnu

## Anti-patterns (= fail)
Tvrde crne linije; oštre ivice; prenatrpanost; agresivne/brze animacije; siva ravna pozadina.
