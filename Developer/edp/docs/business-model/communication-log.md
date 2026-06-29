# Kommunikationslog

Arkiv over central korrespondance med interessenter. Nyeste øverst pr. tråd. Se [interessenter](stakeholders.md) for hvem der er hvem.

---

## Change Group (Lars) — kontrakt

**Status:** Kontrakt forventet leveret af CG **mandag/tirsdag 29.–30. juni 2026**. Følg op ved modtagelse; arkivér vilkår her og i [engagement](engagement.md). CG har godkendt at Per tilknytter Jens Marquard Ipsen som timelønnet konsulent.

---

## Til Peter (Finanstilsynet) — løsningsoplæg efter møde

**Kerneindhold:**
- Anbefaler **greenfield**-genimplementering af eksisterende funktionalitet på moderne, vedligeholdelsesvenlig platform.
- Team: Per + én udvalgt samarbejdspartner. Opstart sidst i ugen efter.
- Mål: **funktionelt 1:1-kompatibel** med nuværende EDP; arbejdsgange bevares, plads til UX-forbedringer uden at ændre grundfunktionalitet.
- Teknisk platform: **.NET** backend · **React** web · **native Swift** iPad · **MS SQL Server** (medmindre andre ønsker) · klar til **Azure**-hosting.
- **Agil** proces; Finanstilsynets værktøjer ved ekstern adgang.
- Udvikling på teamets egne arbejdsstationer; **ingen adgang til produktionsdata** nødvendig. Drift/deployment hos Finanstilsynet i samarbejde.
- Omfang: **~3 mandemåneder / ~480 timer** samlet; ~1 manduge/uge; levering **sep/okt 2026**.
- iPad-distribution ønskes flyttet til Apples officielle kanaler (**unlisted App Store** eller **Apple Business Manager** — afklares).
- Markeret som foreløbigt projektoplæg til videre planlægning.

> Fuld ordlyd findes i Pers afsendte mail (gemt eksternt).

---

## Til Lars (Change Group) — estimat-afklaring

**Kerneindhold:**
- Peters opgavebeskrivelse matcher godt Lars' tidligere observationer/anbefalinger om EDP.
- **Vigtig skelnen mellem to estimater:**
  - Tidligere evaluering = **modernisering/oprydning** af eksisterende løsning (framework-opdateringer, fejlhåndtering, arkitekturoprydning, CI/CD).
  - Seneste estimat (~48-63 arbejdsdage) = **greenfield** genimplementering.
  - → De to er **ikke direkte sammenlignelige**.
- Bemærker at Finanstilsynet fortsat nævner **.NET MAUI** som ønsket kompetence → kan indikere forventning om at videreføre eksisterende stak. Strategisk platformsvalg bør indgå i analysefasen.

---

## Til Lars (Change Group) — observationer & greenfield-estimat

**Kerneindhold (Pers vurdering af eksisterende EDP):**
- Oprindelig kontrakt-timepris fundet: **850 kr./time**.
- Løsningen løser fortsat sin forretningsopgave, men bærer **teknisk gæld**; arkitektur svær at vedligeholde/videreudvikle.
- **Konkret eksempel:** en datafejl kunne få iPad-appen til at crashe. Rodårsag lå i **samspillet** mellem flere dele — manglende **validering ved dataregistrering i web** + iPad-app der **ikke håndterede ugyldige data robust**. Fejl kunne forplante sig gennem systemet og føre til nedbrud. → Behov for styrket **datavalidering, fejlhåndtering og robusthed** på tværs af platformen.
- **iPad-app er .NET MAUI** (cross-platform). Fremstår flere steder som en generisk forretningsapp frem for designet til iPad. Udnytter kun begrænset **iPad/Apple Pencil**-mulighederne (navigation, dokumenthåndtering, PDF-annotering kunne tilpasses platformens styrker).
- Samlet vurdering: løsningen kan vedligeholdes, men videreudvikling bør ske ud fra en **strategisk vurdering af fremtidig arkitektur/platform**. Langsigtet modernisering skaber større værdi end fortsatte reparationer.
- Tilbyder at påtage sig **greenfield-udvikling**.

**Foreløbigt greenfield-estimat** (se fasetabel i [engagement](engagement.md)): ~48 arbejdsdage, spændvidde 48-63. Foreløbigt planlægningsestimat, **ikke fastpris**.

---

> Disse poster er sammenfatninger til projektbrug. Originale mails opbevares i Pers mailsystem.
