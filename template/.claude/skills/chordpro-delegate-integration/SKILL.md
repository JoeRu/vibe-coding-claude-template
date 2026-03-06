---
name: chordpro-delegate-integration
description: Nutze diesen Skill für Änderungen an Delegate-Pipelines (ABC, LilyPond, Bilder/SVG), inklusive Handler-Auflösung, Payload-Normalisierung und Sicherheitsaspekten.
tags:
  - delegates
  - abc
  - integration
priority: 2
---

# ChordPro Delegate Integration

Dieser Skill steuert Arbeiten an Delegate-Integrationen und deren Übergabe in verschiedene Backends (insb. HTML5/PDF).

## Voraussetzungen

- Relevante Module sind bekannt:
  - `lib/ChordPro/Delegate/*.pm`
  - `lib/ChordPro/Output/HTML5.pm`
  - `lib/ChordPro/Song.pm` (Asset/Element-Aufbau)
- Relevante Tests verfügbar:
  - `t/83_html5_delegate.t`
  - `t/html5/09_bugfixes.t`
  - `t/190_html5_bugfixes.t`

## Workflow Schritt für Schritt

1. **Delegate-Vertrag klären**
   - Eingabeformat (`elt`, `opts`, `pagewidth`) und Ausgabeformat (`type`, `subtype`, `data`) dokumentieren.
   - Prüfen, ob Backend-spezifische Handlerwahl erforderlich ist.

2. **Handler-Auflösung stabilisieren**
   - Legacy-/Alias-Fälle früh kanonisieren.
   - Warnungen nur dort ausgeben, wo sie echten Handlungsbedarf signalisieren.

3. **Payload robust verarbeiten**
   - SVG-Payload kann aus mehreren Dokumenten bestehen.
   - Style-Kontexte fragmentübergreifend konsistent halten, ohne lokale Styles zu verlieren.

4. **Sicherheits- und Escaping-Pfade wahren**
   - Keine rohe SVG/HTML-Injektion in Endausgaben.
   - Bevorzugt etablierte Renderpfade (`render_image`, data-URI, Escaping-Helfer) nutzen.

5. **Regressionen absichern**
   - Handler-/Warnungs-Regressionen in Delegate-Tests prüfen.
   - Mehrteilige Payloads und Breitenweitergabe explizit testen.

## Checkliste / DoR / DoD

- **DoR (Ready):**
  - Delegate-Typ und Zielbackend sind eindeutig.
  - Erwartete Output-Form (html/svg/image/ignore) ist definiert.
- **DoD (Done):**
  - Handler-Auflösung deterministisch und rückwärtskompatibel.
  - Keine neuen Warnungsrauschen in Standard-Testläufen.
  - Delegate-Regressionstests grün.

## Beispiele

- **Delegate-Fokus testen**
  - `prove -bv t/83_html5_delegate.t`
- **SVG/HTML5 Regressionen**
  - `prove -bv t/html5/09_bugfixes.t t/190_html5_bugfixes.t`
- **Debug-Ausgabe für ABC prüfen**
  - `perl -Ilib script/chordpro.pl --no-default-configs --define debug.abc=1 testing/lowlands.cho --generate=HTML5 --output=testing/lowlands-debug.html`
