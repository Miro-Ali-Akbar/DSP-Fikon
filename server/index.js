const express = require('express');
const { Server } = require('ws');
const { initializeApp, applicationDefault, cert} = require('firebase-admin/app');
const  { getFirestore, Timestamp, FieldValue, Filter } = require('firebase-admin/firestore');
const serviceAccount = require("./serviceAccountKey.json");

// Initializing database variables

initializeApp({
    credential: cert(serviceAccount),
});

const db = getFirestore();

const usersRef = db.collection('users');

// Initialize server variable

const PORT = process.env.PORT || 3000;

const server = express().use((req, res) => res.send("HELLO WORLD")).listen(PORT, () => console.log(`listening to port: ${PORT}`));

const wss = new Server({server});

wss.connectedUsers = [];

// Event handler

wss.on('connection', ws => {
    ws.id = generateID();

    // inform client of their id
    ws.send(JSON.stringify({
        msgID: "init",
        socketID: ws.id,
        signature: 0, 
    }
    ));

    console.log('Client connected: ', ws.id);

    // ws.isAlive = true;

    // ws.on('pong', heartbeat);

    ws.on('message', function inc(data) {
        let message =  data;

        message = JSON.parse(message);

        console.log(message);
        console.log(message.data);
        switch(message.msgID) {
            case "initRes":
                initUser(message.data);
                console.log('added data');
                wss.connectedUsers[0] = [message.data.signature, ws.id];
                break;
        }
    })

    ws.on('close', () => console.log(`Client with id: ${ws.id} has disconnected.`));

});