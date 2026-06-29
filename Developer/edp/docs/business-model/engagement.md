# Engagement — kommercielle vilkår & omfang

Kommercielle rammer for EDP-greenfield-engagementet. Se [interessenter](stakeholders.md) for roller og [kommunikationslog](communication-log.md) for korrespondancen bag.

## Tilgang

Opgaven gennemføres som et **greenfield-projekt**: eksisterende funktionalitet genimplementeres på en moderne, vedligeholdelsesvenlig platform. Målet er **funktionelt 1:1-kompatibel** med nuværende EDP — eksisterende arbejdsgange og forretningsfunktionalitet bevares, med plads til relevante UX-/arbejdsgangsforbedringer der ikke ændrer grundfunktionaliteten.

> **Vigtigt:** Dette estimat (greenfield) er **ikke** sammenligneligt med Lars' tidligere evaluering, der dækkede *modernisering/oprydning* af den eksisterende løsning (framework-opdateringer, fejlhåndtering, arkitekturoprydning, CI/CD).

## Timepris & økonomi

| Post | Værdi |
|---|---|
| **Timepris** (oprindelig kontrakt) | **850 kr./time** |
| Samlet omfang | ~480 timer / ~3 mandemåneder for teamet samlet |
| I arbejdsdage | ~48 dage (foreløbigt), spændvidde **48-63 dage** |
| Pers kapacitet | ~300-400 timer |
| Pers kadence | ~1 manduge pr. kalenderuge (deltid) |
| Forventet leveringsvindue | **september / oktober 2026** |
| Forventet opstart | slutningen af ugen efter oplægget til Peter |

> Estimatet er et **foreløbigt planlægningsestimat**, ikke fastpris. Endeligt omfang afhænger af integrationskompleksitet, afklaringer undervejs og evt. yderligere ønsker.

## Makker / underleverandør (Jens Marquard Ipsen)

Per tager en makker med på ~20-40 % af arbejdet: **Jens Marquard Ipsen**, .NET-udvikler, primært backend. Han har **ikke eget CVR** → aflønnes som løn via **Danløn**.

> **Status (28. juni 2026):** Bekræftet og **oprettet i Danløn** (klar til løn). Ansættelseskontrakt udfærdiget som udkast → [`kontrakt-jens-ipsen-ansaettelse.md`](kontrakt-jens-ipsen-ansaettelse.md). **Finanstilsynets tavshedserklæring** skal accepteres/underskrives **før** repo/data deles. CG har godkendt tilknytningen. Løbende driftsomkostning: **Claude Code-licens** til Jens. Tidsregistrering er grundlag for løn.

| Post | Værdi |
|---|---|
| Tilbudt timeløn | **500 kr./time** (after-hours-sats, bevidst i den høje ende) |
| + Feriepenge | **12,5 %** oven på (→ 562,50 kr./time i reel udgift) |
| Forventet omfang | **~100 timer** (~21 % af de 480) |
| Pers udgift til Jens | 100 × 562,50 = **~56.250 kr** (50.000 løn + 6.250 feriepenge) |
| Pers margin på Jens' timer | (850 − 562,50) × 100 = **~28.750 kr** |

> Hensigten er **en ordentlig løn til Jens**, ikke at maksimere margin. De 500 kr./time ligger klart over en fuldtids-ækvivalent (~355 kr./time af 64.000 kr./md alt incl.) netop fordi det er ekstraarbejde ved siden af et dagligt job. Tallene er brutto for Jens — A-skat/AM-bidrag trækkes fra hans udbetaling. Bekræftes endeligt efter samtalen med Jens.

## Estimat — fasefordeling (greenfield)

Fra Lars-korrespondancen:

| Fase | Estimat |
|---|---|
| Analyse og kravspecifikation | 5 dage |
| Teknisk analyse og arkitekturdesign | 5 dage |
| Backend-udvikling | 12 dage |
| Web-udvikling | 10 dage |
| iPad-udvikling | 12 dage |
| Deployment og implementering | 2-6 dage |
| Brugertest | 4 dage |
| Fejlrettelser og tilpasninger | 2-9 dage |
| **I alt** | **~48 dage** (spændvidde 48-63) |

## Arbejdsform

- **Agil** med løbende dialog, prioritering og afstemning med Finanstilsynet.
- Finanstilsynets egne projekt-/samarbejdsværktøjer anvendes, **forudsat ekstern adgang**.
- Udvikling primært på teamets **egne arbejdsstationer** — projektet forudsætter **ikke adgang til produktionsdata**.
- **Deployment, drift og produktionssætning** håndteres af Finanstilsynet i samarbejde med teamet.

## Åbne kommercielle / organisatoriske punkter

1. **Makker uden CVR** — **bekræftet: Jens Marquard Ipsen** (se makker-sektion ovenfor). Aflønnes som løn via **Danløn** (oprettet), 500 kr./time + feriepenge, ~100 timer. Kontraktudkast klar. **Bør stadig verificeres med revisor/jurist** at Danløn-modellen og ansættelsesformen (ansættelse vs. konsulent, funktionærstatus) er den rette.
2. **iPad-platform vs. kundens MAUI-forventning** — Finanstilsynet nævner fortsat **.NET MAUI** som ønsket kompetence, hvilket kan indikere en forventning om at videreføre den eksisterende stak. Vores oplæg anbefaler **native Swift** (se [ADR-0001](../architecture/decisions/0001-technology-stack.md)). Den strategiske platformsbeslutning bør indgå i den indledende analysefase.
3. **iPad-distribution** — ønske om at flytte distributionen til Apples officielle kanaler. Model ikke fastlagt: **unlisted App Store** eller **Apple Business Manager**, afhængigt af Finanstilsynets organisatoriske krav.
4. **MS SQL Server** angivet som databaseplatform i oplægget til Peter, "medmindre Finanstilsynet har andre ønsker" (matcher vores Azure SQL-valg).
