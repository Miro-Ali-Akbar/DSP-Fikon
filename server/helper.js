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
 * Updates alive-status of a socket.
 */
function heartbeat() {
    this.isAlive = true;
}

/**
 * ID generation for new websockets
 * @returns generated user ID
 */
function generateID() {
    return Math.floor((1 + Math.random()) * 0x10000);
}

// Database helper functions

/**
 * Enters data into a given document in database
 * @param {String} username username used to index database
 * @param {JSON} userData data given to the function from parsed JSON-string
 */
async function putUser(username, userData) {
    await usersRef.doc(username).set(userData);
}

/**
 * Gets document in collection from database
 * @param {String} collection 
 * @param {String} document 
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
 * Puts fields into document in collection in database
 * @param {String} collection - collection to be selected (what type of data are we entering) (e.g. userdata)
 * @param {String} document  - document to which data should be written (e.g. user whose data should be updated)
 * @param {String} fields - data to be updated (e.g. friend-request to be updated)
 */
async function put(collection, document, fields) {
    await collection.doc(document).set(fields);
}

/**
 *  sends data through websocket
 * @param {WebSocket} ws - websocket through which data will be sent
 * @param {String} msgID - id of message to be sent (depends on data)
 * @param {String} doc? - if a route is to be sent, what route should be sent
 * @param {Number} index - route in doc to be sent
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
                route: route.testArr[0].test,
                color: route.testArr[0].color
            }
            break;
    }
    let msg = {
        msgID: msgID,
        data: data
    }
    ws.send(JSON.stringify(msg));
}

//? Create handling by putting websocket in database --- STRETCH GOAL FOR SCALING
async function handleFriendrequest(ws, sender, target, wsArr) {
    const doc = await usersRef.doc(target).get();
    if ( !doc.exists ) {
        // TODO: Change msgID to match client listener
        ws.send(JSON.stringify({ msgID: 'outGoingRequest', data: { error: 1 }}));
        console.log('did not find user');
    } else if ( doc.data.online ) {
        for ( let i = 0; i < wsArr.length; i++ ) {
            const socket = wsArr[i];
            if ( socket[0] === target ) {
                socket[1].send(JSON.stringify({msgID: 'incomingRequest', data: {sender: sender}}));
                return;
            }
        }
    } else {
        let requests = await doc.data.friendRequests || [];
        requests.push(sender);
        usersRef.doc(target).update({
            friendRequests: requests,
        })
    }
}


module.exports = {
    heartbeat,
    generateID,
    putUser,
    get,
    put,
    send,
    handleFriendrequest
};