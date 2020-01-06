machineId = "1337"
userId = "H4CK3R"
time = "2017-07-21T17:32:28Z"
path = string.format("/nfcproject/LaundryRoom/1.0.1/machine/%s/hold",machineId)
params = string.format("?userId=%s&machineId=%s&time=%s",userId, machineId, time)
host = "virtserver.swaggerhub.com"

print("http post:")
http.post('http://'..host..path..params,
  '',
  '',
  function(code, data)
    if (code < 0) then
      print("HTTP request failed")
    else
      print(code, data)
    end
  end)
