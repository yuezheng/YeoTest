http = require 'http'
http.createServer (req, res) ->
  res.writeHead 200, {'Content-Type': 'text/plain'}
  res.end 'Hello World\n'
.listen 3303, '200.21.3.2'

console.log 'Server running at http://200.21.3.2:3303'
