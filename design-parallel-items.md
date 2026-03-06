# Design-Vorschlag: Parallele Implementierung durch Item-per-File-Architektur

**Status:** Entwurf zur Diskussion
**Datum:** 2026-02-25
**Bezug:** Aktuelles Format `overview-features-bugs.xml` (alle Items inline in einer Datei)

---

## 1. Problem

Das aktuelle Design speichert alle Work-Items in einer einzelnen XML-Datei (`overview-features-bugs.xml`). Das macht parallele Ausführung strukturell unmöglich:

- Zwei Agents, die gleichzeitig implementieren, würden dieselbe Datei lesen und schreiben → XML-Korruption oder Lost-Updates
- `/run 14 15 16` läuft daher sequenziell — Item 15 wartet, bis Item 14 vollständig abgeschlossen ist
- Git-Merges auf dieser Datei erzeugen massive Konflikte, wenn mehrere Branches parallel Items bearbeiten

**Wurzelproblem 1 (Datei):** Shared mutable state in einer einzelnen XML-Datei → serialisierte Arbeit.

**Wurzelproblem 2 (Quellcode):** Zwei logisch unabhängige Items können dieselben Quelldateien des Projekts bearbeiten. Parallelismus ohne Ressourcenkonflikt-Erkennung würde Implementierungen gegenseitig überschreiben. Dieses Problem besteht unabhängig von Wurzelproblem 1 und muss separat gelöst werden.

---

## 2. Lösung: Item-per-File

Jedes Work-Item bekommt eine eigene Datei. `overview-features-bugs.xml` wird zu einem schlanken **Index** (Manifest), der nur Referenzen und Anzeigemetadaten enthält — inklusive vorhergesagter betroffener Quelldateien für Konfliktprüfung.

### Neue Verzeichnisstruktur

```
ai-docs/
  overview.xml                          # unverändert — Architektur-Baseline
  overview-features-bugs.xml            # NEU: schlanker Index (kein Item-Inhalt mehr)
  items/
    0014.xml                            # vollständiges Item 14
    0015.xml                            # vollständiges Item 15
    0016.xml
    archive/
      0001.xml                          # archiviertes Item 1 (aus items/ hierher verschoben)
      0002.xml
```

### Was wo lebt

| Inhalt | Früher | Jetzt |
|---|---|---|
| Item-Inhalt (tasks, r, verification, ...) | inline in XML | `ai-docs/items/{ID:04d}.xml` |
| Item-Übersicht (id, status, type, title) | inline in XML | `<item-ref>` im Index |
| Vorhergesagte betroffene Quelldateien | nicht vorhanden | `planned-files` Attribut in `<item-ref>` |
| Sprints, Releases, Blockers | inline in XML | weiterhin inline im Index (klein, selten parallel) |
| Changelog | inline in XML | weiterhin im Index (Orchestrator schreibt einmalig) |
| Archivierte Items | separate `*-archive.xml` | `ai-docs/items/archive/{ID:04d}.xml` |

---

## 3. Format: Index-Datei (`overview-features-bugs.xml`)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<plan>

  <metadata>
    <title>My Project</title>
    <version>1.0</version>
    <updated>2026-02-25</updated>
    <next-id>23</next-id>
    <done-since-last-fulltest>3</done-since-last-fulltest>
    <last-fulltest-date>2026-02-10</last-fulltest-date>
  </metadata>

  <!--
    <item-ref> enthält nur das, was für /list, /board, /check-deps, /plan_summary
    und Ressourcenkonflikt-Prüfung benötigt wird.
    Alle Details liegen in items/{id:04d}.xml.

    Attribute:
      id            — eindeutige Item-ID (Integer)
      type          — feature | bug | refactoring | tech-debt | ...
      status        — PENDING | APPROVED | IN_PROGRESS | REVIEW | DONE | DENIED | ARCHIVED
      priority      — CRITICAL | HIGH | MEDIUM | LOW
      title         — Kurztitel für Anzeige
      branch        — Branch-Name (leer wenn PENDING/DENIED)
      depends-on    — kommagetrennte IDs (logische + Ressourcen-Abhängigkeiten)
      parent        — Parent-Item-ID
      security      — true (optional)
      complexity    — S | M | L | XL
      planned-files — leerzeichengetrennte Pfade der vorhergesagten Quelldateien
                      (von DA befüllt; ermöglicht Konfliktprüfung ohne Item-Datei zu laden)
  -->
  <items>
    <item-ref id="14" type="feature"     status="IN_PROGRESS" priority="MEDIUM"
              title="Add CSV export to reports"   branch="feature/item-14-csv-export"
              depends-on=""  parent=""  complexity="M"
              planned-files="src/reports/export.py src/reports/serializers.py" />

    <item-ref id="15" type="bug"         status="APPROVED"    priority="HIGH"
              title="Login fails with SSO + 2FA"  branch="bug/item-15-sso-login"
              depends-on="14" parent=""  complexity="S"
              planned-files="src/auth/sso.py src/auth/mfa.py" />

    <item-ref id="16" type="feature"     status="APPROVED"    priority="MEDIUM"
              title="Add PDF export to reports"   branch="feature/item-16-pdf-export"
              depends-on="14" parent=""  complexity="M"
              planned-files="src/reports/export.py src/reports/renderers.py" />

    <item-ref id="17" type="refactoring" status="PENDING"     priority="MEDIUM"
              title="Extract auth middleware"      branch=""
              depends-on=""  parent=""  complexity="M"
              planned-files="src/auth/middleware.py src/auth/decorators.py" />
  </items>

  <!-- Sprints, Releases, Blockers bleiben inline — klein, selten parallel -->
  <sprints /><releases /><blockers />

  <changelog>
    <entry date="2026-02-25">Item 16 erstellt PENDING; DA: depends-on=14 (Ressourcenkonflikt: export.py). Item 14 → IN_PROGRESS.</entry>
  </changelog>

</plan>
```

**Hinweis im Beispiel:** Item 16 bekommt `depends-on="14"` weil beide `src/reports/export.py` modifizieren — obwohl sie logisch unabhängig wären (CSV vs. PDF). Die DA hat den Konflikt beim Anlegen von Item 16 erkannt und enforced.

---

## 4. Format: Item-Datei (`ai-docs/items/0014.xml`)

Identisches Format wie bisher, plus einem neuen `<affected-files>` Block vor den Tasks:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<item id="14" type="feature" status="IN_PROGRESS" priority="MEDIUM" complexity="M">

  <title>Add CSV export to reports</title>
  <branch>feature/item-14-csv-export</branch>
  <justification>Enterprise clients need CSV for their BI tools</justification>
  <depends-on></depends-on>

  <!--
    affected-files: von DA befüllt während Enrichment (Phase 2).
    planned="true"  — Vorhersage vor Implementierung (DA-Analyse)
    planned="false" — Tatsächlich geänderte Dateien (DEV-Ergebnis, in <r><files>)

    Verwendungszwecke:
      1. Ressourcenkonflikt-Prüfung durch Orchestrator (planned-files im Index)
      2. Abhängigkeitsanalyse durch DA bei neuen Items
      3. Regression-Check durch TST (welche bestehenden Features berührt diese Änderung)
  -->
  <affected-files planned="true">
    <file role="modify">src/reports/export.py</file>
    <file role="create">src/reports/csv_serializer.py</file>
    <file role="modify">src/reports/serializers.py</file>
    <file role="create" test="true">tests/reports/test_csv_export.py</file>
  </affected-files>

  <tasks>
    <task id="14.1">Add /reports/export endpoint accepting format=csv</task>
    <task id="14.2">Implement CSV serializer for report model</task>
    <task id="14.3">Add streaming response for large datasets</task>
    <task id="14.4">Write unit tests</task>
  </tasks>

  <technical-parameters>
    <constraint>Streaming — keine Pufferung vollständiger Datensätze im Speicher</constraint>
    <nfr type="performance">Export von 100k Zeilen in unter 10s</nfr>
  </technical-parameters>

  <verification>
    <tests>
      <test type="unit">
        <file>tests/reports/test_csv_export.py</file>
        <description>CSV-Serialisierung und Streaming</description>
        <assertions>Korrekte Header, Encoding UTF-8, 100k-Zeilen-Test unter 10s</assertions>
      </test>
    </tests>
  </verification>

  <workflow-log>
    <entry timestamp="2026-02-24" role="PO" action="approved"  from-status="PENDING"     to-status="APPROVED"    />
    <entry timestamp="2026-02-25" role="SM" action="started"   from-status="APPROVED"    to-status="IN_PROGRESS" />
  </workflow-log>

  <r>
    <outcome></outcome>
    <observations></observations>
    <lessons-learned></lessons-learned>
    <files><file></file></files>
  </r>

</item>
```

### `role`-Attribute auf `<file>`

| role | Bedeutung |
|---|---|
| `modify` | Bestehende Datei wird geändert — **hart** für Konfliktprüfung |
| `create` | Neue Datei wird angelegt — **kein** Konflikt mit anderen Items möglich |
| `delete` | Datei wird gelöscht — hart |
| `read` | Nur gelesen, nicht geändert — kein Konflikt |

Das `test="true"` Attribut markiert Test-Dateien. Konflikte auf Test-Dateien sind **weich** (meist additive Änderungen, kein struktureller Konflikt).

---

## 5. Abhängigkeitstypen

Das System kennt drei Arten von Abhängigkeiten zwischen Items — alle werden als `depends-on` im Index enkodiert, unterscheiden sich aber in Ursache und Detektionszeitpunkt:

### Typ 1: Logische Abhängigkeit

*"Item B braucht das Ergebnis von Item A als Voraussetzung."*

- Beispiel: A erstellt das DB-Schema → B schreibt darauf aufbauende API-Endpoints
- Erkannt: vom User explizit via `@ID` Modifier oder von DA bei der Planung
- Enforcement: B darf nicht starten, solange A nicht DONE ist

### Typ 2: Ressourcen-Abhängigkeit *(neu)*

*"Items A und B modifizieren dieselbe Quelldatei — parallele Ausführung würde eine Implementierung überschreiben."*

- Beispiel: Item 14 (CSV-Export) und Item 16 (PDF-Export) modifizieren beide `src/reports/export.py`
- Erkannt: von DA während Enrichment durch Abgleich der `planned-files` im Index
- Enforcement: DA fügt automatisch `depends-on` von B nach A ein (niedrigere ID läuft zuerst, unless Priorität anderes vorgibt)
- Beide Items bleiben logisch unabhängig — die Abhängigkeit ist rein durch die geteilte Ressource bedingt

### Typ 3: Weiche Abhängigkeit (Warnung)

*"Items A und B berühren zusammenhängende Bereiche, aber keine direkt geteilten Dateien."*

- Beispiel: A ändert Auth-Middleware, B ändert Session-Management (gleicher Bereich, verschiedene Dateien)
- Erkannt: von DA durch Proximity-Analyse (gleiche Verzeichnisse, gegenseitige `import`-Beziehungen)
- Enforcement: **keine** — nur Warnung im Output; User entscheidet

### Unterschied im Index

Alle drei Typen werden als `depends-on` im `<item-ref>` enkodiert. Die Ursache ist in der Item-Datei dokumentiert:

```xml
<!-- In items/0016.xml -->
<depends-on reason="resource-conflict:src/reports/export.py">14</depends-on>
```

Das `reason` Attribut ist optional, aber hilfreich für `/check-deps` Output.

---

## 6. DA-Protokoll: Ressourcenkonflikt-Erkennung

Die DA führt die Konfliktprüfung **bei jeder Item-Erstellung und bei `/plan-impl`** durch. Dies ist eine Erweiterung der bisherigen Phase 2 (Enrichment).

### Neuer Schritt in Phase 2 aller Erstellungskommandos

Nach dem Analysieren des Codes und Befüllen der Tasks:

```
[Neuer Schritt nach bisherigen Phase-2-Schritten]

N+1. Dateikollisions-Analyse:
  a) Erstelle Liste aller Quelldateien, die dieses Item modifizieren wird
     (role="modify" oder role="delete" — nicht role="create" oder role="read")
     → schreibe als <affected-files planned="true"> in die Item-Datei

  b) Lade Index; lese planned-files aller Items mit status IN (APPROVED, IN_PROGRESS):
     → Suche nach Überschneidungen mit den eigenen affected-files (nur Quelldateien, nicht Test-Dateien)

  c) Für jede Überschneidung:
     → Stufe HARD (role=modify/delete auf gleicher Datei):
        - Falls anderes Item IN_PROGRESS:
            Setze depends-on automatisch; melde: "⚠ Ressourcenkonflikt mit Item N (IN_PROGRESS): {Datei}. depends-on={N} gesetzt."
        - Falls anderes Item APPROVED:
            Schlage depends-on vor; setze es, wenn Priorität und ID-Reihenfolge eindeutig sind.
            Melde: "⚠ Ressourcenkonflikt mit Item N (APPROVED): {Datei}. Empfehle sequenzielle Ausführung."

  d) Für jede Test-Datei-Überschneidung:
     → Warnung (weich): "ℹ Gleiche Test-Datei wie Item N: {Datei}. Parallele Ausführung möglich, aber Merge prüfen."

  e) Proximity-Warnung (weich):
     → Falls anderes Item im gleichen Verzeichnis oder Module mit gegenseitigen Imports:
        Melde: "ℹ Überlappender Bereich mit Item N ({Verzeichnis}). Kein direkter Konflikt, aber erhöhtes Risiko."

  f) Trage planned-files als Leerzeichen-getrennte Liste in <item-ref planned-files="..."> im Index ein
```

### Beispiel-Output

```
/feature Add PDF export to reports

→ Erstelle Item 16 (feature, MEDIUM, PENDING)...
→ DA-Analyse läuft...
  Quelldateien: src/reports/export.py (modify), src/reports/renderers.py (create)

  Kollisions-Prüfung:
  ⚠ HARD: src/reports/export.py → auch von Item 14 (IN_PROGRESS: "Add CSV export") modifiziert.
     Automatisch gesetzt: depends-on="14"
     Begründung: parallele Modifikation würde Implementierung überschreiben.

  → Item 16 erstellt (PENDING, depends-on=14).
  → Nach Abschluss von Item 14 kann Item 16 gestartet werden.
```

---

## 7. Parallele Ausführung: neuer `/run`-Ablauf

### Phase 0 — Konfliktgraph aufbauen (neu)

Vor dem Starten der Ausführung erstellt der Orchestrator einen Konfliktgraphen:

```
/run 14 15 16 17

→ Lade Index; lese planned-files aller zu laufenden Items
  Item 14: src/reports/export.py, src/reports/serializers.py
  Item 15: src/auth/sso.py, src/auth/mfa.py
  Item 16: src/reports/export.py, src/reports/renderers.py  ← Konflikt mit 14
  Item 17: src/auth/middleware.py, src/auth/decorators.py

→ Konfliktgraph (nach Dateien):
  src/reports/export.py → [14, 16]  ← Konflikt! 14 und 16 können nicht parallel laufen
  src/auth/*            → [15, 17]  ← kein Dateikonflikt, aber gleicher Bereich (weich)

→ Lade depends-on aus Index:
  14: keine
  15: depends-on=14 (logisch)
  16: depends-on=14 (Ressourcenkonflikt, von DA gesetzt)
  17: keine

→ Topologische Sortierung mit Batch-Zuweisung:
  Batch 1:  [14, 17]   — keine Vorbedingungen, keine Dateikonflikte untereinander
  Batch 2:  [15, 16]   — beide warten auf 14; 15 und 16 haben keinen Dateikonflikt (different files)
```

### Ausführungsplan

```
Batch 1: PARALLEL
  Task(dev-agent-A, items/0014.xml) [background]
  Task(dev-agent-B, items/0017.xml) [background]
  → Warte auf beide

Batch 2: PARALLEL (15 und 16 teilen keine Dateien)
  Task(dev-agent-C, items/0015.xml) [background]
  Task(dev-agent-D, items/0016.xml) [background]
  → Warte auf beide

Orchestrator:
  → Schreibt alle Status-Updates im Index
  → Schreibt einen Changelog-Eintrag

Gesamtdauer: max(T14, T17) + max(T15, T16)
             statt: T14 + T15 + T16 + T17
```

### Stopp-Bedingungen (unverändert + eine neue)

| Bedingung | Verhalten |
|---|---|
| Bug schlägt 2× fehl | Stopp, Report |
| Aktiver BLOCKER | Stopp, Report |
| PROBLEM-Outcome | Stopp, Report |
| Security-Finding mit Design-Änderung | Stopp, Report |
| **Unerwarteter Dateikonflikt zur Laufzeit** | Stopp: "Item N hat Datei X modifiziert, die auch Item M (parallel laufend) bearbeiten wollte. Ressourcenkonflikt nicht im Plan erkannt. Bitte /plan-impl beider Items erneut ausführen." |

Der letzte Fall tritt auf, wenn DEV eine Datei modifiziert, die **nicht** in `planned-files` stand (Code-Analyse war unvollständig). TST erkennt dies beim Regression-Check.

---

## 8. Schreib-/Lese-Muster und Konfliktanalyse

### Wer schreibt was

| Operation | Schreibt auf | Konflikt-Risiko |
|---|---|---|
| Item erstellen | Index: 1 neues `<item-ref>` + `<next-id>` + `planned-files` | Gering — nur Orchestrator |
| Status-Transition | Eigene Item-Datei + 1 Attribut in `<item-ref>` | Null bei eigener Datei |
| Implementierung (DEV) | Nur eigene Item-Datei | **Null** (Quelldateien: durch planned-files bewacht) |
| Verification (TST) | Nur eigene Item-Datei | **Null** |
| Changelog | Index, einmalig am Ende durch Orchestrator | Null — serialisiert |
| Archivierung | `items/NNNN.xml` → `items/archive/NNNN.xml` + Index | Gering |

### Lese-Muster

| Kommando | Liest |
|---|---|
| `/board`, `/list` | Nur Index |
| `/status 14` | Index + `items/0014.xml` |
| `/run 14 15 16` | Index + alle beteiligten Item-Dateien |
| `/check-deps 15` | Nur Index (depends-on im `<item-ref>`) |
| `/plan-impl 16` | Index (planned-files aller APPROVED/IN_PROGRESS) + `items/0016.xml` |
| Session-Start | Nur Index |

---

## 9. ID-Vergabe-Protokoll (parallel-sicher)

**Regel:** Nur der Orchestrator vergibt IDs. Agents erstellen keine Items selbst.

```
Orchestrator (bei Item-Erstellung):
  1. Lese <next-id> aus Index
  2. Schreibe <next-id> + 1 in Index (vor Item-Datei-Erstellung)
  3. Erstelle items/{next-id:04d}.xml
  4. Füge <item-ref id="{next-id}" planned-files="..."> in Index ein
```

**Sonderfall: BUG-Erstellung bei `/run`-Fehler**

- Agent signalisiert: "Test fehlgeschlagen — BUG benötigt für Item N"
- Orchestrator vergibt ID, erstellt Item-Datei, fügt `<item-ref>` in Index ein
- Orchestrator gibt BUG-ID zurück an Agent zur Weiterverarbeitung
- Wichtig: DA-Analyse für den BUG (Phase 2) findet im orchestrierten Kontext statt, nicht parallel zu laufenden Items

---

## 10. Agent-Isolationsmodell

```
Orchestrator  → overview-features-bugs.xml (Index)
              → Konfliktgraph-Berechnung
              → Batch-Planung und -Start
              → Status-Sync nach jedem Batch
              → Changelog

Agent-A (DEV) → items/0014.xml  (ausschließlich)
Agent-B (DEV) → items/0017.xml  (ausschließlich)
Agent-C (DEV) → items/0015.xml  (ausschließlich, nach Batch 1)
Agent-D (DEV) → items/0016.xml  (ausschließlich, nach Batch 1)

overview.xml  → read-only für alle Agents
```

Kein Agent liest oder schreibt die Item-Datei eines anderen Agents. Keine Quellcode-Konflikte durch das `depends-on`-Enforcement der DA.

---

## 11. Änderungen an Archivierung

```
/archive
→ Für jedes DONE/DENIED Item:
    mv ai-docs/items/0014.xml → ai-docs/items/archive/0014.xml
    Entferne <item-ref id="14"> aus Index
    Füge <completed-features>-Eintrag in overview.xml ein
    Extrahiere Lessons → lessons-learned.md
→ Schreibe Changelog-Eintrag im Index
```

Die `overview-features-bugs-archive.xml` entfällt — das Archiv ist das `items/archive/`-Verzeichnis.

---

## 12. Migration von bestehenden Projekten

### Erkennung beim Session-Start

- Existiert `ai-docs/items/`? → neues Format
- Existiert `overview-features-bugs.xml` mit `<item>` Elementen? → Legacy-Format

### Migrations-Angebot (via `/update`)

```
/update
→ ⚠ Legacy-Format: alle Items inline in overview-features-bugs.xml
→ Migration verfügbar (Backup: overview-features-bugs.xml.bak)
→ Migrieren? [ja/nein]
  → Ja:
    - Erstelle ai-docs/items/ und ai-docs/items/archive/
    - Für jedes <item>: schreibe items/{id:04d}.xml, ersetze durch <item-ref>
    - DA: befülle planned-files durch retrospektive Analyse der <r><files> Blöcke (Näherung)
    - ✓ Migration: 18 Items aufgeteilt, 6 archiviert, 12 planned-files befüllt
```

**Hinweis:** Bei der Migration können planned-files für bereits implementierte Items (DONE/IN_PROGRESS) aus den `<r><files>` Blöcken approximiert werden. Für PENDING/APPROVED Items empfiehlt sich ein `/plan-impl` nach der Migration.

### Rückwärtskompatibilität

Wenn `ai-docs/items/` nicht existiert, fällt das System auf Legacy-Lesen zurück. Kein Breaking-Change.

---

## 13. Gegenüberstellung: Vorher vs. Nachher

| Aspekt | Aktuell | Neu |
|---|---|---|
| Parallele `/run`-Ausführung | Nicht möglich | Möglich für Batches ohne Ressourcenkonflikt |
| Ressourcenkonflikt-Erkennung | Nicht vorhanden | DA erkennt und enforced bei Planung |
| Abhängige Items (logisch oder Ressource) | Sequenziell (nur logisch erkannt) | Sequenziell (beide Typen erkannt und enforced) |
| Unerwartete Dateikonflikte zur Laufzeit | Stille Überschreibung | Stopp mit Fehlermeldung |
| Regression-Check-Qualität | Files aus `<r>` bekannt | Zusätzlich: planned-files für Vorhersage verfügbar |
| Git-Konflikte (parallele Branches) | Häufig (gleiche XML) | Selten (je Branch: 1–2 Dateien) |
| Session-Start | Alle Items laden | Nur Index laden |
| `/list`, `/board` | 1 Datei | 1 Datei (unverändert) |
| `/plan-impl` Konfliktanalyse | Nicht vorhanden | Im Index per planned-files (kein volles Laden) |

---

## 14. Offene Punkte

1. **planned-files Genauigkeit:** DA-Vorhersagen sind immer Schätzungen. Wie gehen wir mit Fällen um, wo DEV mehr Dateien ändert als geplant? → Vorschlag: DEV schreibt tatsächliche Dateien in `<r><files>` und Orchestrator prüft am Ende auf unerwartete Überschneidungen.

2. **Granularität der Konflikterkennung:** Datei-Ebene ist grob — zwei Items könnten dieselbe Datei modifizieren, aber verschiedene Funktionen darin (feiner: Funktion/Klasse-Ebene). → Für v1 reicht Dateiebene; feingranulare Erkennung ist optionale Erweiterung.

3. **Test-Datei-Konflikte:** Als weiche Konflikte behandelt. Ist das immer korrekt? → Wenn zwei Items neue Test-Klassen in dieselbe Datei schreiben, sind das additive Änderungen — kein struktureller Konflikt. Wenn sie die gleiche Test-Klasse modifizieren, ist es doch hart. Einfachste Regel: Test-Dateien als weich behandeln, DEV merged manuell.

4. **Maximale Batch-Größe:** Die 5-Item-Grenze gilt pro Interaktion. Wie viele Items dürfen in einem Batch parallel laufen? → Vorschlag: max 3 parallel (begrenzt durch Token-Kontext der Sub-Agents). Konfigurierbar via Metadata.

5. **Sub-Items von Epics:** Wenn Sub-Items 11a und 11b beide `src/auth/oauth.py` modifizieren, müssen sie ohnehin sequenziell laufen. depends-on sollte hier explizit gesetzt sein. → DA-Protokoll deckt dies ab (Ressourcenkonflikt-Erkennung gilt auch für Sub-Items).

6. **TST-Callback für BUG-Erstellung:** Erfordert eine Signalling-Schnittstelle zwischen laufendem Agent und Orchestrator. In der aktuellen Claude-Code-Umgebung möglich über: Agent schreibt Ergebnis zurück, Orchestrator wertet aus. Kein echter async-Callback nötig.

---

## 15. Empfehlung

Das Design löst beide Wurzelprobleme:

1. **Datei-Konflikt** → gelöst durch Item-per-File
2. **Quellcode-Ressourcenkonflikt** → gelöst durch DA-Analyse + planned-files + automatisches depends-on

**Vorgeschlagene Implementierungsreihenfolge:**

1. `<affected-files>` Block zum XML-Schema hinzufügen (`implementation-plan-template.xml`)
2. `planned-files` Attribut zu `<item-ref>` im Index-Schema hinzufügen
3. DA-Enrichment aller Erstellungskommandos um Kollisions-Analyse-Schritt erweitern (`feature.md`, `bug.md`, `refactor.md`, `debt.md`, `plan-impl.md`)
4. Index-Format und Item-per-File einführen (§2–§4)
5. `/run` mit Konfliktgraph und Batch-Planung aktualisieren (§7)
6. `/update` mit Migration erweitern (§12)
