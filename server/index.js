const express = require('express');
const { Server } = require('ws');
const { initializeApp, applicationDefault, cert} = require('firebase-admin/app');
const  { getFirestore, Timestamp, FieldValue, Filter } = require('firebase-admin/firestore');
const serviceAccount = require("./serviceAccountKey.json");
const { heartbeat, generateID, putUser, get, put, send, sortLeaderboard } = require('./helper');

// Initializing database variables


// Initialize server variable

const PORT = process.env.PORT || 3000;
const server = express().use((req, res) => res.send("HELLO WORLD")).listen(PORT, () => console.log(`listening to port: ${PORT}`));
const wss = new Server({server});

wss.connectedUsers = [];

let i = 0;
// Event handler


// TODO: create one dynamic send and dynamic get function.
// TODO: create a sorting function for 
wss.on('connection', ws => {
    ws.id = generateID();

    // inform client of their id
    ws.send(JSON.stringify({
        msgID: "init",
        socketID: ws.id,
        signature: 0, 
    }));

    console.log('Client connected: ', ws.id);

    ws.on('message', function inc(data) {
        let message =  data;

        message = JSON.parse(message);

        console.log('1: ', message);
        console.log('2: ', message.data);
        switch(message.msgID) {
            case "initRes":
                putUser(message.data.username, message.data);
                console.log('=== user added to database ===');
                wss.connectedUsers.push({"username": message.data.username, "socket": ws, "id": ws.id})
                i = i + 1;
                break;
            case "getRoute":
                let index = message.data.index;
                send(ws, 'sendRoute', 'karoRoutes', index);
                break;
            case "getLeaderboard":
                send(ws, 'leaderboard');
                console.log('sent leaderboard');
                break;
            case "updateLeaderboard":
                sortLeaderboard(wss.connectedUsers, message.data.user)

        }
    })

    ws.on('close', () => console.log(`Client with id: ${ws.id} has disconnected.`));

});