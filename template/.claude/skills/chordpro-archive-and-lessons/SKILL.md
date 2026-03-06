---
name: chordpro-archive-and-lessons
description: Nutze diesen Skill für Archive-Runs: DONE/DENIED auslagern, Changelog rotieren, Lessons extrahieren und Volltest-Empfehlung ableiten.
tags:
  - archive
  - knowledge-base
  - process
priority: 2
---

# ChordPro Archive and Lessons

Dieser Skill standardisiert den `/archive`-ähnlichen Ablauf für Planhygiene und Wissensextraktion.

## Voraussetzungen

- Verfügbare Dateien:
  - `ai-docs/overview-features-bugs.xml`
  - `ai-docs/overview-features-bugs-archive.xml`
  - `ai-docs/overview.xml`
  - `ai-docs/lessons-learned.md`
- Nur Items ohne offene Abhängigkeiten archivieren.

## Script-First Regel

- Der Archivlauf wird ueber `python3 ai-docs/plan_manager.py archive-run` ausgefuehrt.
- Direkte Verschiebung von Item-Knoten per Hand ist nur als Recovery erlaubt.
- Nach jedem Lauf sind `validate` und XML-Well-formedness Pflicht.

## Workflow Schritt für Schritt

1. **Archivkandidaten bestimmen**
   - Selektiere `DONE`/`DENIED`-Items, die keine aktiven Downstream-Abhängigkeiten haben.

2. **Items verschieben**
  - Fuehre `plan_manager.py archive-run` aus.
  - Verifiziere: Kandidaten sind aus aktivem Plan entfernt und im Archiv mit `archived="YYYY-MM-DD"` enthalten.

3. **Counter und Historie pflegen**
   - `done-since-last-fulltest` korrekt erhöhen.
   - Changelog-Länge im aktiven Plan begrenzen (ältere Einträge ins Archiv-History verschieben).

4. **Lessons extrahieren**
   - Relevante Learnings aus den archivierten Items in `ai-docs/lessons-learned.md` aufnehmen.
   - Eindeutige L-IDs und Kategoriezuordnung sicherstellen.

5. **Overview nachziehen**
   - `overview.xml` aktualisieren (`completed-features`, ggf. Security-Concers/Mitigations, `updated`).

6. **Abschlussprüfung durchführen**
   - Aktiver Plan enthält nur nicht-archivierte Items.
   - Archive enthält alle verschobenen IDs.
   - Optional Volltest-Empfehlung ausgeben.
  - `python3 ai-docs/plan_manager.py validate` liefert keine Fehler.

## Checkliste / DoR / DoD

- **DoR (Ready):**
  - Kandidatenliste mit IDs steht fest.
  - Abhängigkeitsprüfung ist erfolgt.
- **DoD (Done):**
  - Aktive/archivierte XML-Dateien sind konsistent.
  - Lessons-File ist erweitert.
  - Counter/Changelog/`updated` sind synchron.

## Beispiele

- **Kandidaten im aktiven Plan finden**
  - `grep -n "status=\"DONE\"\|status=\"DENIED\"" ai-docs/overview-features-bugs.xml`
- **Archiveinträge prüfen**
  - `grep -n "archived=\"" ai-docs/overview-features-bugs-archive.xml`
- **Lessons prüfen**
  - `grep -n "^\- \*\*L-" ai-docs/lessons-learned.md`
- **Manager-Validierung**
  - `python3 ai-docs/plan_manager.py --json validate`
