# Discovery Round 2

_Captured: 2026-07-07T15:20:00Z_  _15 gap-closing follow-ups based on round-1._

**1. Kako se prave nalozi trenera/admina?**
- (a) vlasnik ručno dodeljuje ulogu u admin panelu
- (b) 3 trenera imaju unapred napravljene naloge
- (c) poseban kod/pozivnica za trenere
- (d) orchestrator predloži bezbedan način              ← chosen
  ← custom: korisnik pri registraciji bira „trener" ili „klijent"; otvoren za preporuku. Bezbednosna napomena: self-select uloge nije sigurno — u planu predložiti da se klijenti sami registruju, a treneri unapred kreirani ili preko koda.

**2. Grupni časovi — kapacitet i lista čekanja?**
- (a) fiksan broj mesta, bez liste čekanja               ← chosen
- (b) fiksan broj + lista čekanja
- (c) kapacitet zadaje trener po času
- (d) neograničeno

**3. Ko unosi merenja?**
- (a) samo trener
- (b) samo klijent                                       ← chosen
- (c) i trener i klijent
- (d) trener unosi, klijent samo vidi

**4. Fotografije napretka — skladištenje/privatnost?**
- (a) bez fotografija ipak
- (b) Firebase Storage, privatno po klijentu
- (c) fotografije + eksplicitna saglasnost klijenta      ← chosen
- (d) orchestrator predloži bezbedno rešenje

**5. Paketi/krediti — kako funkcionišu?**
- (a) X termina po paketu, oduzima se po dolasku
- (b) krediti sa rokom važenja
- (c) mesečna pretplata (neograničeno)                   ← chosen
- (d) za sad samo evidencija, dogovoriću detalje
  ← custom: članarine po trajanju 1 / 3 / 6 meseci (i sl.); tačni paketi TBD sa klijentom.

**6. Kako se paketi dodaju/kupuju?**
- (a) trener/admin ručno dodaje (plaćeno uživo)
- (b) kartično plaćanje u aplikaciji
- (c) i jedno i drugo                                    ← chosen
- (d) odlučiću kasnije

**7. Podsetnici — kada stižu?**
- (a) 24h pre termina
- (b) 24h + 1h pre                                       ← chosen
- (c) podesivo po klijentu
- (d) 1h pre

**8. Google Calendar sinhro — čiji i u kom smeru?**
- (a) termini klijenta → njegov Google (jednosmerno)
- (b) termini trenera → njegov Google
- (c) dvosmerno (čita zauzeto iz Google-a)               ← chosen
- (d) samo izvoz (.ics fajl), bez prave sinhro

**9. Chat — koliki obim?**
- (a) 1-na-1 klijent–trener
- (b) 1-na-1 + chat grupnog časa
- (c) samo objave/najave trenera (broadcast)
- (d) pun chat + grupe                                   ← chosen

**10. Admin panel — gde?**
- (a) unutar iste mobilne app (admin ekrani)
- (b) posebna web aplikacija
- (c) i mobilno i web
- (d) mobilno sad, web kasnije                           ← chosen

**11. Gde se izvršava serverska logika (podsetnici, krediti, sinhro)?**
- (a) Firebase Cloud Functions
- (b) koliko može u aplikaciji (klijentski)
- (c) Cloud Functions + zakazani zadaci (Scheduler)
- (d) neka orchestrator odluči                           ← chosen

**12. Okruženja — šta predlažeš?**
- (a) samo prod (najjednostavnije)                       ← chosen
- (b) dev + prod (dva Firebase projekta)
- (c) dev + staging + prod
- (d) neka orchestrator odluči

**13. Crash/greške — Crashlytics ili Sentry?**
- (a) Firebase Crashlytics (ide uz stack)                ← chosen
- (b) Sentry
- (c) oba
- (d) neka orchestrator odluči

**14. Analitika — šta biraš?**
- (a) Firebase Analytics (ide uz stack)                  ← chosen
- (b) privacy-friendly / bez third-party
- (c) nema za sad
- (d) neka orchestrator odluči

**15. Telesni/zdravstveni podaci — saglasnost i brisanje?**
- (a) osnovno, bez posebne saglasnosti
- (b) saglasnost pri registraciji + brisanje na zahtev
- (c) puna GDPR obrada (izvoz + brisanje)
- (d) orchestrator predloži minimalno usklađeno rešenje  ← chosen
