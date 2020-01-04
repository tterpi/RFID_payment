-- WIFI Verbindung herstellen

function checkWiFiStatus()
  local s = wifi.sta.status()
  print("WiFi Status: " .. s) 
  if s == 5 then
    myTimer:stop()
    print("Connected on " .. wifi.sta.getip())
    --print("Testausgabe Check WIFI")
    --dofile('sendUdp.lua')
    dofile('https_test.lua')
    --dofile('uart.lua')
  end
end

print("WifiConnection")
wifi.setmode(wifi.STATION)
local station_cfg={}
station_cfg.ssid="yourSSID"
station_cfg.pwd="yourPWD"
station_cfg.save=false
station_cfg.auto=false
wifi.sta.config(station_cfg)
print('Verbindungsversuch')
wifi.sta.connect()

myTimer = tmr.create()
myTimer:alarm(1000, tmr.ALARM_AUTO, checkWiFiStatus)
