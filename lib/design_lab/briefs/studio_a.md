# Studio A — „Kinetik"

Atletska energija. Aplikacija koja izgleda kao poster za sprint: oversized
condensed tipografija, volt na skoro-crnom, dijagonalni rez, brojevi kao heroji.

## Paleta
- Pozadina: `#0B0B0C` (near-black), sekcije `#131316`
- Akcenat (JEDAN!): volt `#CCFF00` — CTA, aktivni tab, ključni brojevi
- Tekst: `#F5F5F2` primarni, `#8A8A90` sekundarni
- Linije: `#26262B`
- Volt NIKAD kao pozadina velikih tekst blokova; crn tekst na volt dugmetu.

## Tipografija (google_fonts)
- Display: **Archivo Black** — naslovi ekrana, ogromni brojevi, uppercase
- UI/body: **Inter Tight** — labele, body
- Tretman: uppercase + letterSpacing za labele; namerni prelomi naslova preko 2 reda

## Signature tehnike (minimum 4)
1. Marquee traka (beskonačni horizontalni scroll: „SNAGA • KONDICIJA • DISCIPLINA • …") kao separator sekcija
2. Dijagonalni rez sekcija (blagi skew/rotate -2° na hero blokovima, ClipPath)
3. Speed-lines pozadina (CustomPainter: retke tanke linije u pravcu kretanja)
4. Count-up animacija velikih brojeva (TweenAnimationBuilder, `Curves.easeOutExpo`)
5. Staggered ulaz elemenata: slide-up + fade, interval 40–60ms, `Curves.easeOutCubic`

## Mora da dokaže
Kinetičku tipografiju i motion — da ekran izgleda kao da se kreće i dok stoji.

## Po ekranima
- **Prijava:** vertikalno/dijagonalno „STUDIO" preko celog ekrana, forma minimalna pri dnu, volt CTA
- **Početna:** sledeći trening kao poster-blok (dan/vreme OGROMNO), nedeljni statovi kao brojevi na track-lane linijama, marquee separator
- **Termini:** treneri kao startna lista — veliki redni broj uz ime, specialty uppercase; detalj = hero ime preko 2 reda + statovi u koloni
- **Merenja:** trenutna kilaža = NAJVEĆI element ekrana; grafikon = CustomPainter linija sa volt glow tačkama
- **Poruke:** tamno, čisto; bubble-ovi oštrih ivica, moji sa volt levom ivicom
- **Profil:** članarina kao member-card sa dijagonalnim rezom; izlaz u galeriju = mala ikonica u vrhu

## Anti-patterns (= fail)
Zaobljene mekane kartice; više od jednog akcenta; svuda centrirani simetrični layouti; Roboto.
