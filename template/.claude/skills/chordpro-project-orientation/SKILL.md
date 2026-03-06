---
name: chordpro-project-orientation
description: Nutze diesen Skill zu Beginn jeder Aufgabe, um Architektur, betroffene Bereiche und Risiken im ChordPro-Projekt korrekt einzugrenzen.
tags:
  - architecture
  - perl
  - process
priority: 1
---

# ChordPro Project Orientation

Dieser Skill standardisiert den Projekt-Start für Agenten. Er hilft, vor Änderungen die richtige Domäne, die relevanten Dateien und die notwendigen Verifikationsschritte festzulegen.

## Voraussetzungen

- Repository-Root ist verfügbar.
- Relevante Leitdokumente sind lesbar:
  - `CLAUDE.md`
  - `AGENT.md`
  - `SKILL.md`
  - `ai-docs/overview.xml`
  - `ai-docs/overview-features-bugs.xml`
- Basis-Tooling vorhanden: `perl`, `make`, `prove`.

## Workflow Schritt für Schritt

1. **Kontext erfassen**
   - Lies `CLAUDE.md` vollständig.
   - Lies `ai-docs/overview.xml` und `ai-docs/overview-features-bugs.xml` parallel, um Architektur + aktive Arbeitspakete zu verstehen.

2. **Änderungsfläche eingrenzen**
   - Ordne die Aufgabe einem Bereich zu:
     - Parser: `lib/ChordPro/Song.pm`
     - Backends: `lib/ChordPro/Output/*`
     - Delegate: `lib/ChordPro/Delegate/*`
     - Konfiguration/Templates: `lib/ChordPro/res/*`
     - Tests: `t/*`, `xt/*`
   - Prüfe, ob die Aufgabe bereits als Item im XML-Plan existiert.

3. **Auswirkungsanalyse erstellen**
   - Notiere betroffene Dateien, potenzielle Seiteneffekte und notwendige Regressionstests.
   - Prüfe, ob Sicherheitsaspekte tangiert sind (Input, Disclosure, Access, Netzwerk).

4. **Verifikationspfad festlegen**
   - Definiere minimale Testmenge für den geänderten Bereich.
   - Plane erweiterten Lauf nur bei Bedarf (z. B. `make test` bzw. selektive `prove`-Runs).

5. **Arbeitsauftrag präzisieren**
   - Formuliere eine kurze, ausführbare Implementierungs-Agenda mit 3–7 Schritten.

## Checkliste / DoR / DoD

- **DoR (Ready):**
  - Scope, Dateien und Zielverhalten sind eindeutig.
  - Betroffene Tests sind benannt.
  - Plan-Item ist identifiziert (falls workflow-gesteuert).
- **DoD (Done):**
  - Änderungen sind auf den Scope begrenzt.
  - Relevante Tests wurden ausgeführt und dokumentiert.
  - Bei Workflow-Änderungen sind XML/Changelog konsistent.

## Beispiele

- **Schneller Scope-Check**
  - `grep -R "render_gridline\|delegate\|diagram" lib/ChordPro/Output`
- **Gezielter Testlauf**
  - `prove -bv t/html5/09_bugfixes.t t/190_html5_bugfixes.t`
- **Backend-Ausgabe lokal erzeugen**
  - `perl -Ilib script/chordpro.pl testing/lowlands.cho --generate=HTML5 --output=testing/lowlands-debug.html`
