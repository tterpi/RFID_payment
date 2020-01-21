-- Startup after timer
function startUp()
    print("Starting up...")
    dofile('NFC_RC522.lua')
end


tmr.create():alarm(5000, tmr.ALARM_SINGLE, startUp)
