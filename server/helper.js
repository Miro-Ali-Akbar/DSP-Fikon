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
        ws.send(JSON.stringify({ msgID: 'outGoingRequest', data: { error: 0 }}));
        console.log('did not find user');
        return;
    } else {
        const requests = doc.data().friendRequests;
        for ( let i = 0; i < requests.length; i++ ) {
            if ( sender === requests[i] ) {
                ws.send(JSON.stringify({ msgID: 'outGoingRequest', data: { error: 2 }}));
                return;
            }
        }
        if ( doc.data().online === true ) {
            console.log(doc.data().online);
            ws.send(JSON.stringify({ msgID: 'outGoingRequest', data: { error: 1 }}));
            console.log('IM HERE');
            for ( let i = 0; i < wsArr.length; i = i + 1 ) {
                const socket = wsArr[i];
                console.log('socket: ', socket);
                console.log('arr: ', wsArr);
                if ( socket.username === target ) {
                    console.log("socket: ", socket);
                    (socket.socket).send(JSON.stringify({msgID: 'incomingRequest', data: {sender: sender}}));
                    requests.push(sender);
                    await usersRef.doc(target).update({
                        friendRequests: requests
                    });
                    return;
                }
            }
        } else {
            ws.send(JSON.stringify({ msgID: 'outGoingRequest', data: { error: 1 }}));
            console.log('im here!');
            requests.push(sender);
            await usersRef.doc(target).update({
                friendRequests: requests
            });
        }
    }
}

// '"msgID": "acceptRequest", "data": {"target": "$name", "sender": "$myUserName}'
async function respondRequest(ws, target, sender, response, wsArr) {
    const targetRaw = await usersRef.doc(target).get();
    const senderRaw = await usersRef.doc(sender).get();
    const senderRequests = senderRaw.data().friendRequests;

    if ( response ) {
        const targetPoints = targetRaw.data().points;
        const targetList = targetRaw.data().friendlist;

        const senderPoints= senderRaw.data().points;
        const senderList = senderRaw.data().friendlist;

        ws.send(JSON.stringify({msgID: 'newFriend', data: { username: target, points: targetPoints }}));
        senderList.push({username: target, points: targetPoints});
        await usersRef.doc(sender).update({
            friendlist: senderList
        })
        console.log(senderRequests);
        const index = senderRequests.indexOf(target);
        if (index > -1) { // only splice if element is found
            senderRequests.splice(index, 1);
        }
        await usersRef.doc(sender).update({
            friendRequests: senderRequests
        });
        console.log(senderRequests);

        for ( let i = 0; i < wsArr.length; i = i + 1 ) {
            const socket = wsArr[i];
            
            if ( socket.username === target ) {
                
                (socket.socket).send(JSON.stringify({msgID: 'newFriend', data: {sender: sender, points: senderPoints}}));
                targetList.push(sender);
                await usersRef.doc(target).update({
                    friendlist: targetList
                });
                return;
            }
        }
    } else {
        const index = targetRequests.indexOf(sender);
        if (index > -1) { // only splice if element is found
            senderRequests.splice(index, 1);
        }
        await usersRef.doc(sender).update({
            friendRequests: senderRequests
        });
    }
}

async function init(ws, username) {
    const user = await usersRef.doc(username).get();
    const leaderboard = await leaderboardRef.doc('leaderboard1').get()

    if ( user.exists ) {
        ws.send(JSON.stringify({
            msgID: 'initUser',
            data: {
                username: username,
                friendlist: user.data().friendlist,
                friendRequests: user.data().friendRequests,
                leaderboard: leaderboard.data(),
                score: user.data().score,
            }
        }));
        await usersRef.doc(username).update({
            online: true
        });
    } else {
        const data = 
        await usersRef.doc(username).set({
            username: username,
            friendlist: [],
            friendRequests: [],
            score: 0,
            online: true
        });
        ws.send(JSON.stringify({msgID: 'initUser', data: {
            username: username,
            friendlist: [],
            friendRequests: [],
            score: 0,
            leaderboard: leaderboard.data(),
            online: true
        }}));
    }
}

async function disconnectUser(ws, wsArr) {
    for ( let i = 0; i < wsArr.length; i++ ) {
        const curr = wsArr[i];
        if( ws.id === curr.id ) {
            await usersRef.doc(curr.username).update({
                online: false
            });
            const index = wsArr.indexOf(curr);
            if (index > -1) { // only splice if element is found
                wsArr.splice(index, 1);
            }

        }
    }
}

module.exports = {
    heartbeat,
    generateID,
    putUser,
    get,
    put,
    send,
    handleFriendrequest,
    respondRequest,
    disconnectUser
};