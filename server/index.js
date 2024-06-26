const express = require('express');
const { Server } = require('ws');
const { initializeApp, applicationDefault, cert} = require('firebase-admin/app');
const  { getFirestore, Timestamp, FieldValue, Filter } = require('firebase-admin/firestore');
const serviceAccount = require("./serviceAccountKey.json");
const { generateID, get, put, send, handleFriendrequest, respondRequest, disconnectUser, init, putUsername, getUsername, sortLeaderboard, saveRoute, initTrails, getRoutes } = require('./helper');


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
  
    i++;
    console.log('=== Client connected: ', ws.id, ' ===');

    ws.on('message', async function inc(data) {

        let message =  data;

        message = JSON.parse(message);
        console.log('count of connected users: ', i);
        console.log('message: ', message);
        console.log('message data: ', message.data);
        switch(message.msgID) {
            case "initRes":
                putUsername(ws, message.data.email, message.data.name);
                console.log('=== user added to database ===');
                wss.connectedUsers.push({"username": message.data.name, "socket": ws, "id": ws.id});
                break;
            case "loggedIn":
                init(ws, message.data.email);
                console.log('=== user logged in ===');
                const username = await getUsername(message.data.email);
                if ( username.found ) {
                    wss.connectedUsers.push({"username": await username.username, "socket": ws, "id": ws.id});
                    console.log('=== added user to connectedClients ===');
                    initTrails(ws, username.username);
                    console.log('=== sent routes to client ===');
                }
                break;
            case "getLeaderboard":
                send(ws, 'leaderboard');
                console.log('=== sent leaderboard === ');
                break;
            case "addFriend":
                handleFriendrequest(ws, message.data.sender, message.data.target, wss.connectedUsers)
                console.log('=== sent friend request to', message.data.target, ' ===');
                break;
            case "acceptRequest":
                respondRequest(ws, message.data.target, message.data.sender, true, wss.connectedUsers);
                break;
            case "rejectRequest":
                respondRequest(ws, message.data.target, message.data.sender, false, wss.connectedUsers);
                break;
            case "updateLeaderboard":
                sortLeaderboard(wss.connectedUsers, message.data.user)
            case "addRoute": 
                console.log("Should be a route: ", message);
                saveRoute(ws, wss.connectedUsers, message.data);
                break;
            case "getRoute":
                getRoutes(ws, message.data.username, message.data.trailname, message.data.trailType);
                break;

        }
    });

    ws.on('close', async () => {
        console.log('=== Client with id: ', ws.id, '=== has disconnected.');
        i = i-1;
        wss.connectedUsers = await disconnectUser(ws.id, wss.connectedUsers);
    });

});