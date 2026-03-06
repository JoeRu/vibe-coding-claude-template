---
name: chordpro-testing-and-ci
description: Nutze diesen Skill für reproduzierbare Verifikation mit make/prove, fokussierte Testpyramide und saubere Ergebnisdokumentation.
tags:
  - testing
  - ci
  - perl
priority: 1
---

# ChordPro Testing and CI

Dieser Skill standardisiert Testausführung und Verifikation für lokale Entwicklung und CI-nahe Checks.

## Voraussetzungen

- Tooling verfügbar: `perl`, `make`, `prove`.
- Nach Moduländerungen ist Build-Schritt geplant (`make`).
- Betroffene Testdateien sind identifiziert.

## Workflow Schritt für Schritt

1. **Testscope bestimmen**
   - Starte mit den nächstliegenden Tests der geänderten Dateien.
   - Erweitere nur schrittweise, falls Risiko/Impact höher ist.

2. **Build-/Cache-Konsistenz herstellen**
   - Nach jeder Perl-Moduländerung: `make` ausführen.
   - Erst danach Tests starten, damit `blib/`-Stand konsistent ist.

3. **Fokussierte Verifikation fahren**
   - Verwende gezielte `prove -bv` Läufe für betroffene Suiten.
   - Halte Laufzeit und Signalqualität hoch.

4. **Optional breite Regression**
   - `make test` nur bei größerem Impact oder vor Übergaben.
   - `make tests` (inkl. xt) für erweiterte Qualitätstore.

5. **Ergebnisse dokumentieren**
   - Notiere ausgeführte Befehle, Pass/Fail-Status und ggf. bekannte externe Ursachen.

## Checkliste / DoR / DoD

- **DoR (Ready):**
  - Teststrategie (klein → groß) ist definiert.
  - Relevante Testdateien sind bekannt.
- **DoD (Done):**
  - `make` wurde bei Moduländerungen ausgeführt.
  - Alle geplanten Testläufe sind dokumentiert.
  - Keine unbegründeten Testauslassungen.

## Beispiele

- **Initiales Setup**
  - `perl Makefile.PL`
- **Build**
  - `make`
- **Fokussiert**
  - `prove -bv t/83_html5_delegate.t t/html5/09_bugfixes.t t/190_html5_bugfixes.t`
- **Breit**
  - `make test`
  - `make tests`
