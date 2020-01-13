## WIP: RFID payment application for public washing machines

This uses an ESP8266 with NodeMCU firmware and a RC522 RFID reader.
Based on work by limbo666 and capella-ben.

This script uses a test LED connected to D8 and GND.  

### Setting up the card

In order for this script to work with your Mifare card, you have to write the correct sector trailer for sector 1 (block 7) and also the correct key to block 4.
The access bits in the sector trailer have the effect that you can only read and write when providing key B that is assumed to be secret. This applies to data blocks and key A and B. The necessary scripts can be found in the KeyBAuthentication branch.

You can configure your card with the following calls, make shure to disable the main script first, by commenting out mtmr:start() at the end of the script.

-- 1. Execute the following call to write the sector trailer:  
=write_block(auth_a, 7, { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x0F, 0x00, 0xFF, 0xFF, 0xAB, 0xCD, 0xEF, 0x12, 0x34, 0x56 })  
-- 2. Remove the card from the reader and place it on the reader again and then execute:  
keyB = { 0xAB, 0xCD, 0xEF, 0x12, 0x34, 0x56 }  
=write_block(auth_b, 4, { 0xAB, 0xCD, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 })

### Lua File System usage

Memory constraints made it neccessary to move some files to Lua-File-System to free up RAM. You will need a firmware with LFS support. To load the image on the NodeMCU-devkit follow these steps. For more info see: https://nodemcu.readthedocs.io/en/master/getting-started/#upload-lfs-image

1. Load the lfs-nfc.img-file to flash memory with esplorer.  
2. Run `node.flashreload("lfs_nfc.img")` once from the console.  
3. Make the scripts from the image available with `pcall(node.flashindex("_init"))` in your init.lua
4. Now you can use the scripts from the img as usual.

The following files are in the img and dont have to be loaded to the flash memory seperately:
_init.lua
dummy_strings.lua
main.lua
NFC_RC522.lua

### Project documentation in German

NFC-Projekt: RFID Bezahlsystem für öffentliche Waschmaschinen

Komponenten:

-NodeMCU-Devkit mit RFID-Schreiber/Leser  
    -Stromversorgung (aktuell nur über USB von Laptop)  
-Server-Applikation mit Datenbank  
-Mifare-Chips oder Karten  

Einführung und Usecase:

Auf das NodeMCU-Devkit, das mit einem ESP8266-Mikrocontroller arbeitet, wurde eine NodeMCU-Firmware geflasht, die es erlaubt in Lua geschriebene Skripte auszuführen. Die Firmware wurde mit einem Cloud-Build-Service (https://nodemcu-build.com/) erstellt und mit der Software PyFlasher (https://github.com/marcelstoer/nodemcu-pyflasher) auf dem NodeMCU-Devkit installiert.
Für die Verwendung des auf einem RC522-Chip basierenden RFID-Lesers konnte auf Github ein entsprechendes Skript gefunden werden (https://github.com/limbo666/LUA_RC522).
Dieses wurde für die konkrete Anwendung angepasst.

Der Skript auf dem ESP8266 arbeitet folgendermaßen: Zunächst wird eine WLAN-Verbindung aufgebaut. Hierfür müssen die Zugangsdaten auf dem ESP gespeichert sein. Wenn eine Verbindung aufgebaut werden konnte, wird der Skript mit den Funktionen für den RC522 geladen. Anschließend wird der Main-Skript ausgeführt, der die Geschäftslogik enthält. 
Alle zwei Sekunden wird versucht, einen RFID-Chip zu lesen. Wenn einer gefunden wird und die User-ID in Block 4 mit dem spezifizierten Key gelesen werden kann, wird ein Bezahl-Request mit der User-ID an die API geschickt. Wenn der Request erfolgreicht ist, wird mit HTTP-Code 200 geantwortet. In diesem Fall soll das Relais geschaltet werden, das die Waschmaschine mit Strom versorgt. An dieser Stelle hat sich als Problem ergeben, dass das Relais mit einer Spannung von 5V arbeitet, das NodeMCU-Devkit an seinen Ausgängen aber maximal 3,3V bereitstellt. Für Demonstrationszwecke wird aktuell nur eine LED geschaltet.  
Zukünftig muss auch ein Signal von der Waschmaschine empfangen werden, wenn diese ihr Programm beendet, damit das Relais wieder ausgeschaltet werden kann. Da verschiedene Waschprogramme unterschiedlich lange dauern und die Dauer zum Teil nicht zu Beginn feststeht, kann kein fester Timer verwendet werden.

Umsetzung:

Für die Authentifizierung des Benutzers wird eine ID in einen bestimmten Block auf einen MIFARE-Chip geschrieben. Der entsprechende Sektor wird mit einem Schlüssel geschützt.
Dieser Schlüssel B wird in den Sektor-Trailer geschrieben. Damit dieser Key verwendet wird, um Lese und Schreibvorgänge zu schützen,
müssen die Access-Bits des Sektors ebenfalls angepasst werden, dies erfolgte mithilfe folgender Web-Anwendung (http://calc.gmss.ru/Mifare1k/).
Der geheime Schlüssel wird auf dem NodeMCU-Devkit gespeichert und bei der Authentifizierung für das Lesen eines Blocks verwendet.
Auf diese Weise kann verhindert werden, dass MIFARE-Chips ohne den geheimen Schlüssel B dupliziert oder manipuliert werden können.

Als nächstes muss die ausgelese User-ID für die Authentifizierung und Authorisierung an den Server übermittelt werden. 
Hierfür wird eine REST-Api verwendet, auf die verschlüsselt mit HTTPS zugegriffen werden kann.
Hierbei zeichnete sich eine Limitation des ESP8266 ab. Die Transport-Layer-Security-Implementierung (TLS) basierend auf mbedTLS, die für die NodeMCU-Firmware verfügbar ist, unterstützt lediglich TLS-Fragmente von 4KiB, in diesem muss bei der Server-Hello-Nachricht die Zertifikatkette des Servers enthalten sein (https://nodemcu.readthedocs.io/en/master/modules/tls/).
Bei längeren Zertifikatketten, wie sie im Internet häufig sind, kann keine Verbindung aufgebaut werden. Lediglich eine unverschlüsselte Verbindung ohne TLS ist in diesem Fall möglich.
Zudem wird Server-Name-Indication (SNI), welches zur Verbindung mit virtuellen Servern erforderlich sein kann, nicht unterstützt. 
Deshalb wird in der NodeMCU-Dokumentation empfohlen, den Server für eine möglichst kurze Zertifikatkette und eine feste IP/Port-Kombination zu konfigurieren.  
Beim Versuch, den Code für den RC522 und den API-Request zu kombinieren, traten weitere Probleme auf. Auf dem ESP sind nach dem Start der Firmware etwas mehr als 40KiB RAM verfügbar. Laut der Dokumentation benötigt ein TLS-Handshake zwischen 25 und 30KiB RAM, ein Großteil des RAM muss also frei sein. Wenn der Code direkt als .lua ausgeführt wird, muss der gesamte Code im RAM liegen. Auch nachdem ungenutzer Code entfernt wurde, waren nur etwa 20KiB RAM frei. Zuerst wurde versucht den Lua-Code zu kompilieren, um Debuginformationen zu entfernen, was den RAM-Bedarf senken soll. Überraschenderweise hatte dies jedoch keine Auswirkungen auf den RAM-Bedarf.
Der nächste Ansatzt, der schließlich zum Erfolg führte, war die Verwendung von Lua-File-System (LFS). Dies erlaubt es kompilierte Skripte aus dem Flash-Speicher heraus auszuführen, was den RAM-Bedarf erheblich gesenkt hat. Mit der Verwendung von LFS sind nun 36KiB RAM frei und der TLS-Handshake kann erfolgreich durchgeführt werden.
