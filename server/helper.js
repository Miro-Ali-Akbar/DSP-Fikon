const express = require('express');
const { Server } = require('ws');
const { initializeApp, applicationDefault, cert} = require('firebase-admin/app');
const  { getFirestore, Timestamp, FieldValue, Filter } = require('firebase-admin/firestore');
const serviceAccount = require("./serviceAccountKey.json");

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
async function putUser(username, userData) {
    await usersRef.doc(username).set(userData);
}

/**
 * @brief Gets document in collection from database
 * @returns data from database
 */
async function get(collection, document) {
    try {
        const raw = await collection.doc(document).get();
        const data = raw.data();
        return data;
    } catch(e) {
        console.log('[ERROR]: There was an error when fetching data');
        console.log(e);
    }
}

/**
 * @brief Puts fields into document in collection in database
 * @param {*} collection - collection to be selected (what type of data are we entering) (e.g. userdata)
 * @param {*} document  - document to which data should be written (e.g. user whose data should be updated)
 * @param {*} fields - data to be updated (e.g. friend-request to be updated)
 */
async function put(collection, document, fields) {
    await collection.doc(document).set(fields);
}

/**
 * @brief sends data through websocket
 * @param {*} ws - websocket through which data will be sent
 * @param {*} msgID - id of message to be sent (depends on data)
 * @param {*} doc? - if a route is to be sent, what route should be sent
 * @param {*} index - route in doc to be sent
 */
async function send(ws, msgID, doc, index) {
    let data;
    switch(msgID) {
        case "leaderboard":
            const lb = await get(leaderboardRef, "leaderboard1");
            data = {
                    user1: await lb.user1, 
                    user2: await lb.user2, 
                    user3: await lb.user3, 
                    user4: await lb.user4, 
                    user5: await lb.user5
            }        
            break;
        case "sendRoute":
            const route = await get(routesRef, doc);
            data = {
                route: route[0],
                color: route[1]
            }
            break;
    }
    let msg = {
        msgID: msgID,
        data: data
    }
    ws.send(JSON.stringify(msg));
}


module.exports = {
    heartbeat,
    generateID,
    putUser,
    get,
    put,
    send
};