const http = require('http');
const os = require('os');
console.log("Inciando servidor ...");
var handler = function(request, response) {
    console.log("Request desde  " + request.connection.remoteAddress);
    response.writeHead(200);
    response.end("Te ha tocado el servidor " + os.hostname() + "\n");
};
var www = http.createServer(handler);
www.listen(9000);
