machineId = "1337"
--userId = "H4CK3R"
time = "2017-07-21T17:32:28Z"
payMachinePath = string.format("/nfcproject/ASDFLaundryRoom/1.0.1/machine/%s/pay",machineId)
host = "virtserver.swaggerhub.com"

function payMachine(userId)
  local params = string.format("?userId=%s&machineId=%s&time=%s",userId, machineId, time)
  print("pay machine:")
  http.post('http://'..host..payMachinePath..params,
    '',
    '',
    function(code, data)
      if (code < 0) then
        print("HTTP request failed")
      elseif (code == 200) then
        print("Paying machine successful")
        print(code, data)
              -- led hi
              gpio.write(pin_led, gpio.HIGH)
              -- timer led lo
              tmr.create():alarm(5000, tmr.ALARM_SINGLE, function() gpio.write(pin_led, gpio.LOW) end)
      else
        print("Paying machine failed")
        print(code, data)
        local state = false
        local blinkCount = 0
        local tobj = tmr.create()
        tobj:alarm(200, tmr.ALARM_AUTO, function()
          if(state) then
            gpio.write(pin_led, gpio.LOW)
            if(blinkCount > 4) then
                tobj:unregister()
            end
          else
            gpio.write(pin_led, gpio.HIGH)
            blinkCount = blinkCount +1
          end
          state = not state
        end)
      end
    end)
end
