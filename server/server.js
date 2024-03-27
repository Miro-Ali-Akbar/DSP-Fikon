const express = require('express');
const { Server } = require('ws');

const PORT = process.env.PORT || 3000;

const server = express().use((req, res) => res.send('Hello World!')).listen(PORT, () => console.log(`Listening on port: ${PORT}`));

const wss = new Server({server});

wss.on('connection', ws => {
    console.log('Client connected');
    ws.on('message', message => console.log(`Received: ${message}`));
    ws.on('close', () => console.log('Client disconnected'));
});