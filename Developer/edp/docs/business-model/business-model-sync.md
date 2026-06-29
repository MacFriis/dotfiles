# Forretningsmodel-synk (privat)

> Flyttet hertil fra `docs/planning/` (28. juni 2026) — beskrivelsen hører til forretningsmodellen og ligger derfor i den private, git-ignorerede `docs/business-model/`-mappe. **Bemærk:** maskiner uden denne mappe (rejsemaskine, 3. computer, Claude på web) har ikke denne fil — men `.businessupdate` (tracked, i repo-roden) indeholder en kort protokol-gengivelse, og `CLAUDE.md` opsummerer reglen. Mekanikken virker derfor stadig uden filen.

Denne note beskriver hvordan kommercielle/private oplysninger håndteres på tværs af flere maskiner uden at de havner i den delte kode-historik mere end nødvendigt.

## Opsætning

- `docs/business-model/` er **git-ignored** (se `.gitignore`) og indeholder kommercielt/personligt indhold: **rater, stakeholder-detaljer, kontrakter, kommunikationslog**.
- Mappen findes **kun på main-maskinen**. Rejsemaskinen (og andre maskiner) har den **ikke** — og skal ikke have den.

## Problemet

Når der arbejdes på en maskine uden mappen, dukker der nogle gange noget op, der hører hjemme i forretningsmodellen (fx en aftalt timeløn). Men mappen findes ikke her, så det kan ikke skrives det rigtige sted med det samme.

## Løsningen — `.businessupdate`-køen

`.businessupdate` i repo-roden er en **tracked** (ikke-ignored), append-only kø:

- **Retning er én vej:** maskine **uden** mappen *skriver* poster → maskine **med** mappen *anvender* dem. Mappen flyder aldrig tilbage til de andre maskiner.
- Fordi `.businessupdate` er tracked, **rejser noterne via git** mellem maskinerne — også til en 3. computer eller Claude Code på web.

### Tradeoff (bevidst accepteret)

Da `.businessupdate` er tracked og pushes, er de afventende noter teknisk set delt med teamet via repoet ("halv-hemmeligt"). Det er accepteret mod at der holdes øje med, hvad der lægges ind. Læg kun det nødvendige i køen.

## Protokol for Claude Code (gælder hver session)

1. **Ved sessionsstart:** tjek om `docs/business-model/` findes.
   - **Findes den** og der er poster under "Afventende" i `.businessupdate` → **spørg brugeren**, om de skal foldes ind i forretningsmodellen. Når de er anvendt, flyt dem til "Behandlet" i `.businessupdate` med dato.
   - **Findes den ikke** → arbejd i "append-mode": opstår der business-model-relevant info, tilføj en dateret post under "Afventende" i `.businessupdate` i stedet for at røre mappen.
2. Reglen er også gengivet kort i `CLAUDE.md`, som læses hver session.
