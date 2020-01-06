machineId = "1337"
--userId = "H4CK3R"
time = "2017-07-21T17:32:28Z"
holdMachinePath = string.format("/nfcproject/LaundryRoom/1.0.1/machine/%s/hold",machineId)
host = "virtserver.swaggerhub.com"

function holdMachine(userId)
  local params = string.format("?userId=%s&machineId=%s&time=%s",userId, machineId, time)
  print("hold machine:")
  http.post('http://'..host..holdMachinePath..params,
    '',
    '',
    function(code, data)
      if (code < 0) then
        print("HTTP request failed")
      elseif (code == 200) then
        print("Holding machine successful")
        print(code, data)
              -- led hi
              gpio.write(pin_led, gpio.HIGH)
              -- timer led lo
              tmr.create():alarm(5000, tmr.ALARM_SINGLE, function() gpio.write(pin_led, gpio.LOW) end)
      else
        print("Holding machine failed")
        print(code, data)
      end
    end)
end
