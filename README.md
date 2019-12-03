WIP: RFID payment application for public washing machines

This uses an ESP8266 with NodeMCU firmware and a RC522 RFID reader.
Based on work by limbo666 and capella-ben.

In order for this script to work with your Mifare card, you have to write the correct sector trailer for sector 2 (block 7) and also the correct key to block 4.
The access bits in the sector trailer have the effect that you can only read and write when providing key B that is assumed to be secret. This applies to data blocks and key A and B.

You can configure your card with the following calls, make shure to disable the main script first, by commenting out mtmr:start() at the end of the script.

-- 1. Execute the following call to write the sector trailer:  
=write_block(auth_a, 7, { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x0F, 0x00, 0xFF, 0xFF, 0xAB, 0xCD, 0xEF, 0x12, 0x34, 0x56 })  
-- 2. Remove the card from the reader and place it on the reader again and then execute:  
keyB = { 0xAB, 0xCD, 0xEF, 0x12, 0x34, 0x56 }  
=write_block(auth_b, 4, { 0xAB, 0xCD, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 })

This script also uses a test LED connected to D8 and GND.
