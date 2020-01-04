-- Startup after timer
function startUp()
    print("Starting up...")
    dofile('connectWifi.lua')
end


tmr.create():alarm(5000, tmr.ALARM_SINGLE, startUp)
