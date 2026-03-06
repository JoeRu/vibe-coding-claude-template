---
name: chordpro-plan-xml-lifecycle
description: Nutze diesen Skill für alle Änderungen am XML-Planmodell (Items, Statuswechsel, Changelog, Abhängigkeiten, Security-Flags).
tags:
  - workflow
  - xml
  - planning
priority: 1
---

# ChordPro Plan XML Lifecycle

Dieser Skill kapselt den verbindlichen Workflow für `ai-docs/overview-features-bugs.xml` und die Synchronisierung mit `ai-docs/overview.xml`.

## Voraussetzungen

- Folgende Dateien sind verfügbar:
  - `ai-docs/overview-features-bugs.xml`
  - `ai-docs/overview-features-bugs-archive.xml`
  - `ai-docs/overview.xml`
  - `CLAUDE-implementation-plan-chapter.md`
- XML-Validierungstool ist verfügbar (optional, empfohlen): `xmllint`.

## Script-First Regel

- XML-Schreiboperationen laufen zentral ueber `python3 ai-docs/plan_manager.py`.
- Direkte manuelle XML-Edits sind nur fuer Ausnahmefaelle erlaubt (z.B. Recovery), danach muss `validate` erfolgreich sein.
- Command-Mapping:
  - Item-Erstellung (`/feature`, `/bug`, `/refactor`, `/debt`): `create-item`
  - Gate-Transitions (`/approve`, `/deny`, `/plan-impl`, `/start`, `/submit`, `/pass`, `/fail`): `transition`
  - Archivierung (`/archive`): `archive-run`
  - Struktur-Items (`/release`, `/sprint`, `/blockers`): `create-structural`
  - Requirement-Decomposition (`/translate`): `translate`
  - Initialisierung (`/init_overview`): `init-overview`
  - Sync-Updates (`/update`): `sync-update`
  - Security-Pflege (`/security`): `security-update`

## Workflow Schritt für Schritt

1. **Ist-Zustand lesen**
   - Öffne aktive Plan-XML und Overview-XML immer vor Änderungen.
   - Prüfe IDs, Statusverteilung, Dependencies, letzte Changelog-Entries.

2. **Änderung typisieren**
   - Neues Item, Statuswechsel, Security-Markierung, Dependency-Update oder Changelog-Update klar trennen.

3. **Konsistent aktualisieren**
   - IDs sequenziell halten.
   - Für Gate-Transitions `workflow-log`-Einträge ergänzen.
   - Bei sicherheitsrelevanten Themen `security="true"` + Impact-Infos pflegen.

4. **Overview synchronisieren**
   - Bei DONE/archivierten Features `overview.xml` (`completed-features`, ggf. `security`) aktualisieren.

5. **Changelog pflegen**
   - Eine gruppierte, aussagekräftige Changelog-Zeile pro Interaktion bevorzugen.
   - Keine redundanten Einzelzeilen für Mini-Änderungen.

6. **XML prüfen**
   - Nach Änderung strukturelle Validität testen.
  - `python3 ai-docs/plan_manager.py validate` muss ohne Fehler enden.

## Checkliste / DoR / DoD

- **DoR (Ready):**
  - Zieländerung im Lifecycle ist eindeutig.
  - Betroffene XML-Dateien sind bestimmt.
- **DoD (Done):**
  - XML bleibt wohlgeformt.
  - Overview/Plan sind inhaltlich synchron.
  - Changelog und Metadaten (`updated`, Counter) sind konsistent.

## Beispiele

- **XML-Well-formedness prüfen**
  - `xmllint --noout ai-docs/overview-features-bugs.xml`
- **Manager-Integrität prüfen**
  - `python3 ai-docs/plan_manager.py --json validate`
- **Aktive IDs prüfen**
  - `grep -n "<item id=\"" ai-docs/overview-features-bugs.xml`
- **Metadaten prüfen**
  - `grep -n "done-since-last-fulltest\|last-fulltest-date\|<updated>" ai-docs/overview-features-bugs.xml ai-docs/overview.xml`
