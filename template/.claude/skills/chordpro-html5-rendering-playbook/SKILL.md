---
name: chordpro-html5-rendering-playbook
description: Nutze diesen Skill für HTML5-Ausgabeänderungen inklusive Template/CSS-Abgleich, Delegate-Rendering und visualisierbarer Regressionstests.
tags:
  - html5
  - templates
  - testing
priority: 2
---

# ChordPro HTML5 Rendering Playbook

Dieser Skill ist für alle Änderungen am HTML5-Renderer, an Templates und an zugehörigem CSS gedacht.

## Voraussetzungen

- Relevante Dateien sind bekannt:
  - `lib/ChordPro/Output/HTML5.pm`
  - `lib/ChordPro/res/templates/html5/*`
  - `lib/ChordPro/res/templates/html5/paged/*`
  - `t/html5/09_bugfixes.t`
  - `t/190_html5_bugfixes.t`
- Testdaten vorhanden (z. B. `testing/lowlands.cho`).

## Workflow Schritt für Schritt

1. **Renderpfad bestimmen**
   - Identifiziere, ob der Fehler/Feature im Datenaufbau (`HTML5.pm`) oder in der Darstellung (Template/CSS) liegt.

2. **Template-Parität sicherstellen**
   - Prüfe immer beide Varianten:
     - Standard-Template
     - Paged-Template
   - Änderungen an Struktur/CSS konsistent spiegeln.

3. **Rendering robust implementieren**
   - Für Delegate-/SVG-Pfade: Mehrfachpayloads und partielle Styles berücksichtigen.
   - Klassen-/Layout-Änderungen mit minimal-invasiver CSS-Anpassung umsetzen.

4. **Gezielte Regressionstests ergänzen**
   - Primär in `t/html5/09_bugfixes.t`.
   - Spiegelung in `t/190_html5_bugfixes.t` synchron halten.

5. **Artefaktbasiert validieren**
   - Reproduzierbare HTML-Datei erzeugen (z. B. Lowlands-Fall).
   - Kritische Marker im Output prüfen (Klassen, data-URI, Style-Merging).

## Checkliste / DoR / DoD

- **DoR (Ready):**
  - Betroffener HTML5-Pfad ist isoliert.
  - Template- und CSS-Impact sind bekannt.
- **DoD (Done):**
  - Standard + paged sind konsistent.
  - Beide Bugfix-Suiten (`09` und `190`) sind synchron und grün.
  - Optionales HTML-Artefakt bestätigt die Zieländerung.

## Beispiele

- **HTML5-Output erzeugen**
  - `perl script/chordpro.pl testing/lowlands.cho --generate=HTML5 --output=testing/lowlands-debug.html`
- **Mirrored Tests**
  - `prove -bv t/html5/09_bugfixes.t t/190_html5_bugfixes.t`
- **Delegate-Test fokussiert**
  - `prove -bv t/83_html5_delegate.t`
