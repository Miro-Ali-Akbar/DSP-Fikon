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
            const route = await get('', doc);
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

async function saveRoute(ws, wsArr, data) {
    const name = data.trailName;
    const username = getSocketUser(ws, wsArr);
    const user = await get(usersRef, username);
    const friendlist = await user.friendlist;
    console.log(username);
    console.log(friendlist[0]);

    // put trail into database
    db.collection(`users/${username}/userRoutes`).doc(name).set(data);

    if ( friendlist.length > 0 ) {
        for ( let i = 0; i < friendlist.length; i++ ) {
            console.log(friendlist[0]);
            db.collection(`users/${friendlist[i]}/friendRoutes`).doc(name).set(data);
        }
    } else {
        // Do nothing
    }    
}

async function initTrails(ws, username) {
    const userRoutes = await db.collection(`users/${username}/userRoutes`).get();
    const friendRoutes = await db.collection(`users/${username}/friendRoutes`).get();
    
    const docsUser = userRoutes.docs.map(doc => doc.data());
    const docsFriend = friendRoutes.docs.map(doc => doc.data());
    
    ws.send(JSON.stringify({
        msgID: 'initTrails',
        data: {
            userTrails: docsUser,
            friendTrails: docsFriend
        }
    }));
}

async function getRoutes(ws, username, trailName, trailType) {
    const raw = db.collection(`users/${username}/${trailType}`).doc(trailname).get();
    ws.send(JSON.stringify({
        msgID: 'sendRoute',
        data: {
            route: raw.data()
        }
    }));
}

module.exports = {
    heartbeat,
    generateID,
    putUser,
    get,
    put,
    send,
    saveRoute,
    initTrails,
    getRoutes,
};