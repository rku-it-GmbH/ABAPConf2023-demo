# ABAPConf 2023 Demo
Dieses Repository enthält die Demo zum Beitrag "Serviceentwicklung mit CDS und RAP im Rahmen einer Greenfield-Transformation" von der ABAPConf 2023.
Der Beitrag ist hier zu finden: [ABAPConf 2023 Livestream](https://www.youtube.com/watch?v=bGtcmIJLeNY&t=8340s)

## Szenario
Die Demo ist eine vereinfachte Version der Zählerstanderfassung, eines der Standardprozesses der Versorgerbranche.

## Inhalt
Das Paket enthält vier unter Pakete:
- Dependency Analysis: Eine Sammlung von CDS Views zur Auswertung von Pakethierarchien, Paketschnittstellen und deren Objekten.
- Meter Reading Service: Das eigentliche Service Paket, dass die Geschäftslogik und die Adapter für die externen Schnittstellen enthält.
- Meter Reading UI: Fiori Elements App für die Zählerstanderfassung.
- RAP Tools: Ein paar allgemeine Hilfsfunktionen, die innerhalb des Service genutzt werden.

## Voraussetzungen
Um die Demo ausführen zu können, müssen geeignete Geschäftspartner, Vertragskonten, technische Plätze und Equipments im System vorhanden sein.

## Kurzbeschreibung des Service

### Datenmodell
Das Datenmodell des Service besteht aus drei Objekten, von denen zwei vereinfachte Kopien von Standardobjekten aus S/4HANA Utilities sind:
- Verträge (Contracts): Fasst die wesentlichen Stammdaten des Szenarios zusammen. In einem echten System sind diese über mehrere Objekte verteilt.
- Ablesebelege (Meter Reading Documents): Repräsentiert eine geplante oder durchgeführte Ablesung.
- Zählerstanderfassung (Meter Reading Upload): Dient zur Persistierung der erfassten Daten und als Prozessstruktur bis zur Erstellung des Ablesebelegs.

### Schnittstellen
Der Service bietet folgende Schnittstellen an:
- Service Binding vom Typ UI zur Nutzung in Fiori Elements Apps.
- Service Binding vom Typ API zur Bereitstellung über das API Management.
- RFC Service Definition zur Bereitstellung als RFC- oder SOAP-Service.  


## Einrichtung
Nach der Installation sind folgende Schritte auszuführen:
- Einrichtung des Intervalls 01 für die Nummernkreise ZDMO_CONTR und ZDMO_MRDOC
- Aktivierung der OData-Services
- Erstellung eines Service Bindings im SOAMANAGER, um den RFC als SOAP-API zu testen
- Definition und Vergabe von Berechtigungen für die Services und die RAP-Objekte (Berechtigungsobjekt ZABP_BEHV)