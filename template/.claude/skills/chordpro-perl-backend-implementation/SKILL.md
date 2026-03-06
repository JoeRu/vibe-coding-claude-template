---
name: chordpro-perl-backend-implementation
description: Nutze diesen Skill für Änderungen an Perl-Modulen in Parser, Core und Output-Backends mit konsistentem Stil und minimaler Änderungsfläche.
tags:
  - backend
  - perl
  - implementation
priority: 1
---

# ChordPro Perl Backend Implementation

Dieser Skill definiert die technische Umsetzung für Änderungen an Perl-Code im ChordPro-Kern und in Backend-Modulen.

## Voraussetzungen

- `CLAUDE.md` wurde gelesen.
- Zielmodule sind lokalisiert (`lib/ChordPro/*.pm`, `lib/ChordPro/*/*.pm`).
- Build-Kette ist verfügbar:
  - `perl Makefile.PL` (falls Initialsetup nötig)
  - `make`
  - `prove`

## Workflow Schritt für Schritt

1. **Bestehendes Muster übernehmen**
   - Prüfe im Zielmodul vorhandenen Stil (Object::Pad vs. prozedural, Signatures, Namenskonventionen).
   - Wiederverwendung bestehender Hilfsfunktionen priorisieren.

2. **Root-Cause implementieren**
   - Korrigiere Ursache statt Symptom.
   - Vermeide API- oder Strukturänderungen außerhalb des Scopes.

3. **Sichere Datennutzung umsetzen**
   - Bei Config-Zugriffen: defensive Zugriffe (z. B. via `eval { ... } // default` bei restriktiven Hashes).
   - Bei Text/Markup-Ausgabe: Escaping-Pfade beibehalten, keine ungefilterte HTML-Injektion.

4. **Build-Artefakte aktualisieren**
   - Nach Änderungen an Perl-Modulen immer `make` ausführen (wegen `blib/`-Cache).

5. **Nahe Tests ausführen**
   - Starte mit kleinsten relevanten Tests (`prove -bv ...`).
   - Erweiterte Tests nur bei Bedarf ergänzen.

6. **Änderung dokumentieren**
   - Kurz festhalten: Was geändert, warum, welche Tests grün.

## Checkliste / DoR / DoD

- **DoR (Ready):**
  - Betroffene Module und Codepfade identifiziert.
  - Erwartetes Verhalten ist klar.
- **DoD (Done):**
  - `make` wurde nach Moduländerungen ausgeführt.
  - Relevante `prove`-Tests sind erfolgreich.
  - Keine unbeabsichtigten Nebenänderungen in fremden Bereichen.

## Beispiele

- **Build nach Moduländerung**
  - `make`
- **Gezielte Unit-/Regressionstests**
  - `prove -bv t/105_chords.t`
  - `prove -bv t/83_html5_delegate.t`
- **Parser-/Backend-Verifikation**
  - `perl -Ilib script/chordpro.pl input.cho --generate=HTML5 --output=out.html`
