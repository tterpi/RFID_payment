----------------------------------------------------------------------
-- Main
----------------------------------------------------------------------

pin_led = 8
authID = { 0xAB, 0xCD, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 }

-- Initialise the RC522
spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, spi.DATABITS_8, 0)
gpio.mode(pin_rst,gpio.OUTPUT)
gpio.mode(pin_ss,gpio.OUTPUT)
gpio.mode(pin_led,gpio.OUTPUT)
gpio.write(pin_rst, gpio.HIGH)      -- needs to be HIGH all the time for the RC522 to work
gpio.write(pin_ss, gpio.HIGH)       -- needs to go LOW during communications
gpio.write(pin_led, gpio.LOW)
RC522.dev_write(0x01, mode_reset)   -- soft reset
RC522.dev_write(0x2A, 0x8D)         -- Timer: auto; preScaler to 6.78MHz
RC522.dev_write(0x2B, 0x3E)         -- Timer 
RC522.dev_write(0x2D, 30)           -- Timer
RC522.dev_write(0x2C, 0)            -- Timer
RC522.dev_write(0x15, 0x40)         -- 100% ASK
RC522.dev_write(0x11, 0x3D)         -- CRC initial value 0x6363
-- turn on the antenna
current = RC522.dev_read(reg_tx_control)
if bit.bnot(bit.band(current, 0x03)) then
    RC522.set_bitmask(reg_tx_control, 0x03)
end

print("RC522 Firmware Version: 0x"..string.format("%X", RC522.getFirmwareVersion()))

mtmr = tmr.create()
mtmr:register(2000, tmr.ALARM_AUTO, function (t)
    isTagNear, cardType = RC522.request()
  
    if isTagNear == true then
      mtmr:stop()
      err, serialNo = RC522.anticoll()
      print("Tag Found: "..appendHex(serialNo).."  of type: "..appendHex(cardType))

      -- Selecting a tag, and the rest afterwards is only required if you want to read or write data to the card
    
      err, sak = RC522.select_tag(serialNo)
      if err == false then
        print("Tag selected successfully.  SAK: 0x"..string.format("%X", sak))
		local block_addr = 4
		local keyB = { 0xAB, 0xCD, 0xEF, 0x12, 0x34, 0x56 }
        err = RC522.card_auth(auth_b, block_addr, keyB, serialNo)     --  Auth the "A" key.  if this fails you can also auth the "B" key
        if err then 
          print("ERROR Authenticating block "..block_addr) 
        else 
          -- Read card data
            err, tagData = RC522.readTag(block_addr)
            if not err then 
				print("READ Block "..block_addr..": "..appendHex(tagData))
				if blocksIdentical(tagData, authID) then
					print("authorized");
					-- led hi
					gpio.write(pin_led, gpio.HIGH)
					-- timer led lo
					tmr.create():alarm(5000, tmr.ALARM_SINGLE, function() gpio.write(pin_led, gpio.LOW) end)
				end
			end
        end
      else
        print("ERROR Selecting tag")
    
      end
      print(" ")
    
      -- halt tag and get ready to read another.
      buf = {}
      buf[1] = 0x50  --MF1_HALT
      buf[2] = 0
      crc = RC522.calculate_crc(buf)
      table.insert(buf, crc[1])
      table.insert(buf, crc[2])
      err, back_data, back_length = RC522.card_write(mode_transrec, buf)
      RC522.clear_bitmask(0x08, 0x08)    -- Turn off encryption
      
     mtmr:start()
      
    else 
      --print("NO TAG FOUND")
    end
end)  -- timer

mtmr:start()
