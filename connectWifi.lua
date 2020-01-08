-- WIFI Verbindung herstellen

function checkWiFiStatus()
  local s = wifi.sta.status()
  print("WiFi Status: " .. s) 
  if s == 5 then
    myTimer:stop()
    print("Connected on " .. wifi.sta.getip())
    pcall(node.flashindex("_init"))
    dofile('NFC_RC522.lua')
    dofile('API.lua')
    dofile("main.lua")
  end
end

--print(node.stripdebug())
--node.stripdebug(1)
--print(node.stripdebug())
--node.compile('NFC_RC522.lua')
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
