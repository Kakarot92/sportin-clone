# Studio E — „Dubina" (Neon Cinema)

Kinematski dark: slojevi ugljena, neon cyan/violet glow, parallax dubina,
animirani hero-orb. Teretana noću, neonska reklama preko puta.

## Paleta
- Pozadine: `#0C0F14` baza, slojevi `#121722`, `#1A2130` (dubina kroz svetlinu sloja, ne kroz senke)
- Neon: cyan `#53E8D4` (primarni), violet `#B26BFF` (sekundarni) — glow preko `BoxShadow` blur ~24 sa bojom na ~35% opacity
- Tekst: `#EDF1F7` primarni, `#8D97A8` sekundarni

## Tipografija (google_fonts)
- Display: **Syne** (Bold/ExtraBold — futuristički bez sci-fi klišea)
- Body: **IBM Plex Sans**
- Tretman: naslovi sa suptilnim ShaderMask gradijentom cyan→violet

## Signature tehnike (minimum 4)
1. Animirani orb/prsten na Početnoj (CustomPainter: koncentrični arc-ovi, rotacija različitim brzinama — pseudo-3D)
2. Parallax na scroll: pozadinski glow blob-ovi se pomeraju sporije od sadržaja (scroll listener + Transform.translate)
3. Depth kartice: gradient border 1px (cyan→violet) + tamniji unutrašnji sloj
4. Grafikon merenja: neon linija + gradijent fill koji bledi u transparentno + glow tačke
5. Tranzicije tabova: fade-through/scale sa `Curves.easeOutQuint`; aktivni tab sa glow indikatorom

## Mora da dokaže
Imerzivni dark UI sa osećajem dubine — svaki ekran ima 3 plana (pozadina / sadržaj / akcenat).

## Po ekranima
- **Prijava:** orb iznad forme, input polja sa glow fokusom
- **Početna:** orb hero sa sledećim treningom u centru, statovi u depth karticama
- **Termini:** treneri kao noćne kartice sa neon ivicom; detalj sa glow avatarom i cyan CTA
- **Merenja:** neon area-chart preko cele širine + count-up brojevi
- **Poruke:** moji bubble-ovi cyan tint, trenerovi violet; glow samo na nepročitanim
- **Profil:** članarina kao access-card sa gradient ivicom; izlaz diskretan

## Anti-patterns (= fail)
Čist `#000` svuda; glow na SVEMU (glow je začin, ne supa); Orbitron/sci-fi kliše font; nečitljiv kontrast.
