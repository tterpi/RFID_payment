-- WIFI Verbindung herstellen

function checkWiFiStatus()
  local s = wifi.sta.status()
  print("WiFi Status: " .. s) 
  if s == 5 then
    myTimer:stop()
    print("Connected on " .. wifi.sta.getip())
    print(collectgarbage("count")*1024)
    dofile('API.lua')
    print(collectgarbage("count")*1024)
    dofile('NFC_RC522.lua')
    print(collectgarbage("count")*1024)
    dofile("main.lua")
    print(collectgarbage("count")*1024)
  end
end

print("WifiConnection")
wifi.setmode(wifi.STATION)
local station_cfg={}
dofile('wifiCredentials.lua')
station_cfg.ssid=wifiSsid
station_cfg.pwd=wifiPwd
station_cfg.save=false
station_cfg.auto=false
wifi.sta.config(station_cfg)
print('Verbindungsversuch')
wifi.sta.connect()

myTimer = tmr.create()
myTimer:alarm(1000, tmr.ALARM_AUTO, checkWiFiStatus)
