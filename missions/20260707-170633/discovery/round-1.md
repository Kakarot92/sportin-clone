# Discovery Round 1

_Captured: 2026-07-07T15:12:00Z_  _Adaptations from defaults: baza/auth = Firebase; kategorija E = mobilna distribucija; Q15 = telesna merenja; Q17 = FCM notifikacije umesto web integracija._

## A. Korisnici i pristup

**1. Ko su primarni korisnici?**
- (a) samo klijenti (vežbači)
- (b) klijenti + treneri
- (c) klijenti + treneri + admin/vlasnik            ← chosen
- (d) javno pregledanje + članovi

**2. Očekivani broj korisnika u v1?**
- (a) <50                                            ← chosen
- (b) 50–500
- (c) 500–5.000
- (d) >5.000

**3. Način prijave (Firebase Auth)?**
- (a) email + lozinka                                ← chosen
- (b) broj telefona (SMS kod)
- (c) Google / Apple nalog
- (d) email + social kombinovano

**4. Uloge u aplikaciji?**
- (a) jedna (samo klijenti)
- (b) klijent + trener
- (c) klijent + trener + admin/vlasnik               ← chosen
- (d) detaljne dozvole po resursu

**5. Kako klijenti dobijaju nalog?**
- (a) otvorena samostalna registracija               ← chosen
- (b) na poziv/odobrenje studija
- (c) trener pravi naloge
- (d) registracija pa admin odobrava

## B. Podaci i zakazivanje

**6. Firebase baza?**
- (a) Cloud Firestore
- (b) Realtime Database
- (c) Firestore + delom SQL
- (d) neka orchestrator predloži                      ← chosen

**7. Kako se definišu slobodni termini?**
- (a) fiksni nedeljni raspored po treneru             ← chosen
- (b) trener ručno postavlja termine
- (c) radno vreme studija + dostupnost trenera
- (d) generisano iz radnih sati trenera

**8. Tip treninga?**
- (a) samo individualni (1-na-1)
- (b) individualni + grupni časovi                    ← chosen
- (c) samo grupni časovi
- (d) individualni + grupni + open-gym

**9. Real-time izmene (termini/zakazivanja)?**
- (a) nije potrebno
- (b) osveži pri otvaranju                             ← chosen
- (c) uživo kad se termin promeni
- (d) uživo + push notifikacije

**10. Otkazivanje / pomeranje termina?**
- (a) besplatno bilo kada
- (b) do X sati pre termina                            ← chosen
- (c) bez otkazivanja (kontakt trener)
- (d) podesivo po studiju

## C. Interfejs i aplikacija

**11. Platforme za v1?**
- (a) samo Android
- (b) samo iOS
- (c) i Android i iOS                                  ← chosen
- (d) mobilne + web (Flutter web)

**12. Jezik?**
- (a) samo srpski
- (b) samo engleski
- (c) srpski + engleski                                ← chosen
- (d) više jezika

**13. Stil UI-ja?**
- (a) Material (Flutter default)
- (b) custom brendirani dizajn
- (c) minimalističan/čist
- (d) ja dajem dizajn                                  ← chosen

**14. Tema?**
- (a) samo svetla
- (b) samo tamna
- (c) svetla + tamna (prekidač)                        ← chosen
- (d) prati sistem

**15. „Merenje" — šta se prati?**
- (a) samo težina
- (b) težina + obimi (struk, itd.)
- (c) težina + obimi + % masti/slike
- (d) puna kompozicija + grafikoni napretka            ← chosen

## D. Integracije i notifikacije

**16. Plaćanje u aplikaciji?**
- (a) nema — plaća se uživo
- (b) paketi/krediti za termine u app                  ← chosen
- (c) pretplate (mesečno)
- (d) puna kartična naplata
  ← custom: „odrediću to sa njim" (klijentom) — tentativno b

**17. Notifikacije (Firebase Cloud Messaging)?**
- (a) nema
- (b) samo potvrde zakazivanja
- (c) potvrde + podsetnici                             ← chosen
- (d) podsetnici + poruke trenera

**18. Kalendar?**
- (a) samo u aplikaciji
- (b) izvoz u kalendar telefona
- (c) sinhro sa Google kalendarom                      ← chosen
- (d) i telefon i Google

**19. Komunikacija trener–klijent?**
- (a) nema
- (b) beleške uz termin
- (c) chat u aplikaciji
- (d) chat + slanje slika/videa                        ← chosen

**20. Napredak/statistika za klijenta?**
- (a) nema
- (b) grafikoni istorije merenja
- (c) dolasci + merenja
- (d) pun dashboard (termini, napredak, ciljevi)       ← chosen

## E. Isporuka i distribucija

**21. Distribucija?**
- (a) Google Play + App Store                          ← chosen
- (b) samo Google Play
- (c) prvo interno testiranje (TestFlight/Internal)
- (d) APK/sideload za sada

**22. Backend?**
- (a) samo Firebase (serverless)
- (b) Firebase + Cloud Functions
- (c) Firebase + custom backend
- (d) neka orchestrator odluči                         ← chosen

**23. Okruženja?**
- (a) jedno (prod)
- (b) dev + prod
- (c) dev + staging + prod
- (d) nisam siguran                                    ← chosen

**24. Praćenje grešaka/padova?**
- (a) Firebase Crashlytics
- (b) Sentry
- (c) osnovno logovanje
- (d) ništa za sad
  ← custom: neodlučeno između (a) i (b) — traži preporuku

**25. Analitika?**
- (a) Firebase Analytics
- (b) privacy-friendly
- (c) nema
- (d) nisam siguran                                    ← chosen

## F. Kvalitet i ograničenja

**26. Rad bez interneta (offline)?**
- (a) nema (mora online)                               ← chosen
- (b) pregled keširanih podataka offline
- (c) zakazivanje offline, sync kasnije
- (d) potpuno offline-first

**27. Testiranje?**
- (a) samo kritični tokovi
- (b) široko unit + widget testovi                     ← chosen
- (c) puno, uklj. integracione testove
- (d) za sad ručno

**28. Privatnost podataka/saglasnost?**
- (a) osnovno                                          ← chosen
- (b) GDPR stil (saglasnost + izvoz/brisanje)
- (c) osetljivi zdravstveni podaci
- (d) nisam siguran

**29. Alati za admina/vlasnika?**
- (a) nema (treneri se sami snalaze)
- (b) upravljanje trenerima + rasporedom
- (c) upravljanje + izveštaji/prihod
- (d) pun admin panel                                  ← chosen

**30. Obim za v1?**
- (a) MVP brzo (samo osnovno zakazivanje)
- (b) zakazivanje + merenje
- (c) pun set funkcija                                 ← chosen
- (d) fazno izdavanje
