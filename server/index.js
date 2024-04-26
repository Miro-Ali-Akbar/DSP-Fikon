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

const leaderboardRef = db.collection('leaderboard');


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

/**
 * @brief Gets route from database in hardcoded document
 * @param num - Index under document from which to extract data
 * @returns JSON-file of collected data
 */
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

/**
 * @brief Gets leaderboard array from database in document 
 * @returns array of leaderboard
 */
async function getLeaderboard() {
    try {
        const leaderboard = await leaderboardRef.doc("leaderboard1").get();
        const lbData = leaderboard.data();
        console.log('leaderboard:', lbData.arr);
        return lbData;
    } catch(error) {
        console.log('Error: Something went wrong when fetching data.');
        console.log(error);
        return null;
    }
}

/**
 * @brief helper function to getRoutes, handles async sending and awaiting. 
 * @param ws - webSocket through which to send stringified return value of getRoutes
 * @param index - index passed to getRoutes to specify which one to get from db
 */
async function sendRoutes(ws, index) {
    ws.send(JSON.stringify(await getRoutes(index)));
    console.log('route sent');
}

/**
 * @brief helper function to getLeaderboard, handles async sending and awaiting. 
 * @param ws - webSocket through which to send stringified return value of getLeaderboard
 */
async function sendLeaderboard(ws) {
    const leaderboard = await getLeaderboard();
    let leaderboardMsg = {
        msgID: "leaderboard",
        data: {
            user1: await leaderboard.user1, 
            user2: await leaderboard.user2, 
            user3: await leaderboard.user3, 
            user4: await leaderboard.user4, 
            user5: await leaderboard.user5
        }        
    }
    ws.send(JSON.stringify(leaderboardMsg));
    console.log('leaderboard sent:', leaderboardMsg);
}


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
                initUser(message.data.username, message.data);
                console.log('=== user added to database ===');
                wss.connectedUsers[i] = [message.data.username, ws.id];
                i = i + 1;
                break;
            case "getRoute":
                let index = message.data.index;
                sendRoutes(ws, index);
                break;
            case "getLeaderboard":
                sendLeaderboard(ws);
                console.log('sent leaderboard');
                break;
                
        }
    })

    ws.on('close', () => console.log(`Client with id: ${ws.id} has disconnected.`));

});