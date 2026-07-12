# Studio D — „Blok" (Neo-Brutalist Data)

Trenerska tabla: tvrde ivice, 2px crni okviri, offset senke bez blura,
sticker badge-ovi, monospace brojevi. Podaci napred, ličnost svuda.

## Paleta
- Pozadina: `#F2F0EB` (papir)
- Ink/okviri: `#111111` — 2px border na svakoj kartici
- Blokovi boje (funkcionalno): žuta `#FFD02F` = akcija, plava `#2B5BFF` = info,
  crvena `#FF4D2E` = upozorenje, zelena `#27AE60` = napredak
- Senka: čvrsta, offset (4,4), blurRadius 0, crna

## Tipografija (google_fonts)
- Display/UI: **Space Grotesk** (bold naslovi)
- Numerali/labele: **Space Mono** — SVI brojevi mono, tabele mono
- Tretman: uppercase labele u malim „tag" blokovima sa okvirom

## Signature tehnike (minimum 4)
1. Hard-shadow kartice: border 2px + `BoxShadow(offset: Offset(4,4), blurRadius: 0)`
2. Sticker badge-ovi: rotirani −3° do 3° tagovi („NOVO", „5 NEDELJA STREAK", ocena)
3. Bar-chart od blokova (nula zaobljenja) za merenja; mono vrednost iznad svake trake
4. Pritisak dugmeta = translate(2,2) + senka se skrati (taktilni feedback)
5. Tabela podataka sa zebra prugama i mono kolonama

## Mora da dokaže
Da gusta informacija može da ima šarm: maksimum podataka, nula dosade.

## Po ekranima
- **Prijava:** forma kao formular-karton sa pečat-badge-om
- **Početna:** dashboard grid 2 kolone — sledeći trening (žuti blok), statovi (mono brojači), streak sticker
- **Termini:** treneri kao trading-card kartice sa ocenom u uglu; detalj = spec-sheet tabela (godine, klijenti, cena)
- **Merenja:** STAR EKRANA — mono tabela 12 nedelja + blok bar-chart + delta badge-ovi (−5.6 kg, zeleno)
- **Poruke:** bubble-ovi kao kuponi sa okvirom, vremena mono
- **Profil:** članarina kao karta sa perforacijom (dashed linija); izlaz = mali crveni blok

## Anti-patterns (= fail)
Blur senke; gradijenti; zaobljenja > 4px; pasteli; prazni „minimal" ekrani.
