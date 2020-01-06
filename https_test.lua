machineId = "1337"
userId = "H4CK3R"
time = "2017-07-21T17:32:28Z"
path = string.format("/nfcproject/LaundryRoom/1.0.1/machine/%s/hold",machineId)
params = string.format("?userId=%s&machineId=%s&time=%s",userId, machineId, time)
host = "virtserver.swaggerhub.com"

request = string.format("POST %s%s HTTP/1.1\r\nHost: %s\r\nConnection: keep-alive\r\nAccept: */*\r\n\r\n", path, params, host)

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

srv = net.createConnection(net.TCP, 0)
srv:on("receive", function(sck, c) print("received: ") print(c) end)
srv:on("dns", function(sck, c) print("dns: ") print(c) end)
srv:on("reconnection", function(sck, c) print("error: ") print(c) end)
srv:on("disconnection", function(sck, c) print("disconnect: ") print(c) end)
srv:on("connection", function(sck, c)
  -- Wait for connection before sending.
  print("connected to server")
  sck:send(request)
end)
print("trying to connect to server")
--srv:connect(80,host)
