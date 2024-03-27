"use strict";
exports.__esModule = true;
var express = require("express");
var ws_1 = require("ws");
var PORT = process.env.PORT || 3000;
var server = express().use(function (req, res) { return res.send('Hello World'); }).listen(PORT, function () { return console.log("Listening on ".concat(PORT)); });
var wss = new ws_1.Server({ server: server });
wss.on('connection', function (ws) {
    console.log('Client connected');
    console.log(wss.clients);
    ws.on('message', function (message) { return console.log("Received: ".concat(message)); });
    ws.on('close', function () { return console.log('Client disconnected'); });
});
