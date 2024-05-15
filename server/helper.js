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
 * ID generation for new websockets
 * @returns generated user ID
 */
function generateID() {
    return Math.floor((1 + Math.random()) * 0x10000);
}

// Database helper functions

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


//? Create handling by putting websocket in database --- STRETCH GOAL FOR SCALING
async function handleFriendrequest(ws, sender, target, wsArr) {
    const doc = await usersRef.doc(target).get();
    if ( !doc.exists ) {
        ws.send(JSON.stringify({ msgID: 'outGoingRequest', data: { error: 0 }}));
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

            ws.send(JSON.stringify({ msgID: 'outGoingRequest', data: { error: 1 }}));

            for ( let i = 0; i < wsArr.length; i = i + 1 ) {

                const socket = wsArr[i];
                if ( socket.username === target ) {
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
        const targetPoints = targetRaw.data().score;
        const targetList = targetRaw.data().friendlist;

        const senderPoints= senderRaw.data().score;
        const senderList = senderRaw.data().friendlist;

        ws.send(JSON.stringify({msgID: 'newFriend', data: { username: target, score: targetPoints }}));

        const targetRef = await db.collection(`/users/${sender}/friendList`).doc(target);
        await targetRef.set({username: target, score: targetPoints});


        const index = senderRequests.indexOf(target);
        if (index > -1) { // only splice if element is found
            senderRequests.splice(index, 1);
        }
        await usersRef.doc(sender).update({
            friendRequests: senderRequests
        });



        for ( let i = 0; i < wsArr.length; i = i + 1 ) {
            const socket = wsArr[i];
            
            if ( socket.username === target ) {
                const senderRef = await db.collection(`/users/${target}/friendList`).doc(sender);
                (socket.socket).send(JSON.stringify({msgID: 'newFriend', data: {sender: sender, score: senderPoints}}));
                await senderRef.set({username: sender, score: senderPoints});
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

async function getUsername(email) {
    const raw = await db.collection('connectedEmails').doc(email).get();
    if ( raw.exists ) {
        return {username: raw.data().username, found: true};
    } else {
        return {username: null, found: false};
    }
}

async function putUsername(ws, email, username) {
    const raw = await db.collection('connectedEmails').get();
    const collection = raw.docs.map(doc => doc.data());

    for ( let i = 0; i < collection.length; i++ ) {
        if ( username === collection[i].username) {
            ws.send(JSON.stringify({
                msgID: 'usernameFail'
            }));
            return;
        } else {
            continue;
        }
    }
    await db.collection('connectedEmails').doc(email).set({
        username: username,
        changedUsername: true
    });
    ws.send(JSON.stringify({
        msgID: 'usernameSuccess'
    }))
}

async function init(ws, email) {
    const username = await getUsername(email);
    
    if ( username.found ) {
        const user = await usersRef.doc(username.username).get();
        const leaderboard = await leaderboardRef.doc('leaderboard1').get()
        const friendRef = await db.collection(`/users/${username.username}/friendList`).get();
        const friendlist = friendRef.docs.map(doc => doc.data());
        console.log(friendlist);
        if ( user.exists ) {
            console.log('sending data to', username.username);
            ws.send(JSON.stringify({
                msgID: 'initUser',
                data: {
                    username: username.username,
                    friendlist: friendlist,
                    friendRequests: user.data().friendRequests,
                    leaderboard: leaderboard.data(),
                    score: user.data().score,
                    changedUsername: true
                }
            }));
            await usersRef.doc(username.username).update({
                online: true
            });
        } else {
            console.log('sending data to new user...', username.username);
            await usersRef.doc(username.username).set({
                username: username.username,
                friendRequests: [],
                score: 0,
                online: true
            });
            const friendlist = await db.collection(`/users/${username.username}/friendList`).get();
            ws.send(JSON.stringify({msgID: 'initUser', data: {
                username: username.username,
                friendlist: [],
                friendRequests: [],
                score: 0,
                leaderboard: leaderboard.data(),
                changedUsername: true
            }}));
        }
    } else {
        console.log('did not find username in databse, sending request...');
        ws.send(JSON.stringify({ msgID: 'initUser', data: {
            changedUsername: false
        }}));
    }
}

async function disconnectUser(wsID, wsArr) {
    for ( let i = 0; i < wsArr.length; i++ ) {
        const curr = wsArr[i];
        if( wsID === curr.id ) {
            await usersRef.doc(curr.username).update({
                online: false
            });
            const index = wsArr.indexOf(curr);
            if (index > -1) { // only splice if element is found
                wsArr.splice(index, 1);
            }
            return wsArr;
        }
    }
}

async function sortLeaderboard(wsArr, entry) {
    const leaderboard = await leaderboardRef.doc('leaderboard1').get();
    let updated = false;
    
    if ( entry.points > leaderboard.data().user5[1]) {
        if ( entry.points > leaderboard.data().user4[1]) {
            if ( entry.points > leaderboard.data().user3[1]) {
                if ( entry.points > leaderboard.data().user2[1]) {
                    if ( entry.points > leaderboard.data().user1[1]) {

                        leaderboardRef.doc('leaderboard1').update({
                                                                    user1: [entry.username, entry.points],
                                                                    user2: leaderboard.data().user1,
                                                                    user3: leaderboard.data().user2,
                                                                    user4: leaderboard.data().user3,
                                                                    user5: leaderboard.data().user4
                                                                });
                        updated = true;
                    } else {
                        leaderboardRef.doc('leaderboard1').update({
                                                                    user1: leaderboard.data().user1,
                                                                    user2: [entry.username, entry.points],
                                                                    user3: leaderboard.data().user2,
                                                                    user4: leaderboard.data().user3,
                                                                    user5: leaderboard.data().user4
                                                                });
                        updated = true;
                    }
                } else {
                    leaderboardRef.doc('leaderboard1').update({
                                                                user1: leaderboard.data().user1,
                                                                user2: leaderboard.data().user2,
                                                                user3: [entry.username, entry.points],
                                                                user4: leaderboard.data().user3,
                                                                user5: leaderboard.data().user4
                                                            });
                    updated = true;
                }
            } else {
                leaderboardRef.doc('leaderboard1').update({
                                                            user1: leaderboard.data().user1,
                                                            user2: leaderboard.data().user2,
                                                            user3: leaderboard.data().user3,
                                                            user4: [entry.username, entry.points],
                                                            user5: leaderboard.data().user4
                                                        });
                updated = true;
            }
        } else {
            leaderboardRef.doc('leaderboard1').update({
                                                        user1: leaderboard.data().user1,
                                                        user2: leaderboard.data().user2,
                                                        user3: leaderboard.data().user3,
                                                        user4: leaderboard.data().user4,
                                                        user5: [entry.username, entry.points]
                                                    });
            updated = true;
        }
    }

    if ( updated ) {
        for ( let i = 0; i < wsArr.length; i++ ) {
            send(wsArr[i].socket, 'leaderboard');
        }
    }

}

async function saveRoute(ws, wsArr, data) {
    const name = data.trailName;
    
    let username;
    for ( let i = 0; i < wsArr.length; i++ ) {
        if ( ws.id === wsArr[i].id ) {
            username = wsArr[i].username;
            break;
        }
    } 

    const raw = await usersRef.doc(username).get()
    const friendRef = await db.collection(`user/${username}/friendlist`).get();
    const friendlist = friendRef.docs.map(doc => doc.data());
    console.log(username);
    console.log(friendlist[0]);

    // put trail into database
    await db.collection(`users/${username}/userRoutes`).doc(name).set(data);
    
    ws.send(JSON.stringify({msgID: "returnRoute", data: data}));

    if ( friendlist.length > 0 ) {
        for ( let i = 0; i < friendlist.length; i++ ) {
            console.log(friendlist[0]);
            await db.collection(`users/${friendlist[i].username}/friendRoutes`).doc(name).set(data);
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
    generateID,
    get,
    put,
    send,
    handleFriendrequest,
    respondRequest,
    disconnectUser,
    init,
    putUsername,
    getUsername,
    saveRoute,
    initTrails,
    getRoutes,

};