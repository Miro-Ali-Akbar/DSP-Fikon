const express = require('express');
const { Server } = require('ws');
const { initializeApp, applicationDefault, cert} = require('firebase-admin/app');
const  { getFirestore, Timestamp, FieldValue, Filter } = require('firebase-admin/firestore');
const serviceAccount = require("./serviceAccountKey.json");

// Initializing database variables
initializeApp({
    credential: cert(serviceAccount),
});

const db = getFirestore();

const usersRef = db.collection('users');


// Initialize server variables
const PORT = process.env.PORT || 3000;

const server = express().use((req, res) => res.send("HELLO WORLD")).listen(PORT, () => console.log(`listening to port: ${PORT}`));

const wss = new Server({server});


// Server helper functions
function heartbeat() {
    this.isAlive = true;
}

function generateID() {
    return Math.floor((1 + Math.random()) * 0x10000);
}


// Database helper functions
async function initUser(userData) {
    await usersRef.doc("hitsu").set(userData);
}


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
        switch(message.msgID) {
            case "initRes":
                initUser(message);
                console.log('added data');
                break;
        }
    })

    ws.on('close', () => console.log(`Client with id: ${ws.id} has disconnected.`));

});