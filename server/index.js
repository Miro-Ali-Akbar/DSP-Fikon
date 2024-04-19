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

const routesRef = db.collection('routes');


// Server helper functions

/**
 * @brief Updates alive-status of a socket.
 */
function heartbeat() {
    this.isAlive = true;
}

/**
 * @brief ID generation for new websockets
 * @returns generated user ID
 */
function generateID() {
    return Math.floor((1 + Math.random()) * 0x10000);
}


// Database helper functions

/**
 * @brief Enters data into a given document in database
 * @param userData data given to the function from parsed JSON-string
 */
async function initUser(username, userData) {
    await usersRef.doc(username).set(userData);
}

async function getRoutes(num) {
    try {
        const route = await routesRef.doc("karoRoutes").get();
        let routeData = route.data().testArr[num];
        return { route: routeData.test, color: routeData.color };
    } catch(error) {
        console.log('Error: Something went wrong when fetching data.');
        console.log(error);
        return null;
    }
}

// Initialize server variable

const PORT = process.env.PORT || 3000;
const server = express().use((req, res) => res.send("HELLO WORLD")).listen(PORT, () => console.log(`listening to port: ${PORT}`));
const wss = new Server({server});

wss.connectedUsers = [];

let i = 0;
// Event handler

async function sendRoutes(ws, index) {
    ws.send(JSON.stringify(await getRoutes(index)));
    console.log('route sent');
}

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
                initUser(message.data.username, message.data);
                console.log('=== user added to database ===');
                wss.connectedUsers[i] = [message.data.username, ws.id];
                i = i + 1;
                break;
            case "routesReq":
                let index = message.data.index;
                sendRoutes(ws, index);
                break;
        }
    })

    ws.on('close', () => console.log(`Client with id: ${ws.id} has disconnected.`));

});