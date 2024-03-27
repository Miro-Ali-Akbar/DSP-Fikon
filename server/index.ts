import * as express from "express";
import { Server } from "ws";

const PORT = process.env.PORT || 3000;

const server = express().use((req, res) => res.send('Hello World')).listen(PORT, () => console.log(`Listening on ${PORT}`));

const wss = new Server({server});

function heartbeat() {
	this.isAlive = true;
}

function generateID() {
	return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
}

wss.getUniqueID = () => {
	return generateID() + generateID() + generateID();
}

wss.getUsernameID = () {
	// TODO: Get user's ID - could be done from client side by an init req on connection
}

wss.on('connection', ws => {
	// give client a UID
	ws.id = wss.getUniqueID;
	ws.userID = wss.getUsernameID; // or alternate way
	// inform client of their UID
	ws.send(JSON.stringify({type:"id", data: ws.id}));

	// log it in the terminal for debugging purposes
	console.log('Client connected with ID: ' + ws.id);

	// set client to alive
	ws.isAlive = true;

	ws.on('pong', heartbeat); // when we receive 'pong' event we respond with the client's heartbeat

	ws.on('message', function inc(data, isBinary) {
		// if received message is in binary, we need to translate it
		let message = isBinary ? data : data.toString();

		message = JSON.parse(message); // translate message back into JSON

		switch(message.msgID) {
			case "frq":
				// TODO: Get target from Database and check wss.clients for correct username, otherwise queue friendrequest / find alternate way
				// example of JSON for frq:
				/* 
					{
						msgID: 'friendRequest',
						uID: 0000-0001
						targetUID: 0000-0002,
						ans: NULL,
					}
				*/
				break;
			case "frqAns": 
				// TODO: Get target from Database and check wss.clients for correct username, otherwise queue friendrequest / find alternate way
				// example of JSON for frqAns:
				/* 
					{
						msgID: 'friendRequest',
						uID: 0000-0002,
						targetUID: 0000-0001,
						ans: [true/false],
					}
				*/
				break;
			case "userChange":
				// TODO: get uID from database, check old username, check new username (must be unique) if true, username = newUsername, else, response false
				// example of JSON for userChange:
				/* 
					{
						msgID: 'userChange',
						uID: 0000-0001,
						oldUser: 'hitsuindaface',
						newUser: 'hitsu',
					}
				*/
				break;
			case "getLeaderboard":
				// TODO: get user leaderboard for specific title
				// example of JSON for getLeaderboard:
				/*
					{
						msgID: 'getLeaderboard',
						uID: 0000-0001,
						leaderboard: [0000-0003, 0000-0001, 0000-0002],
					}
				*/
				break;
			case "updateLeaderboard":
				// TODO: update leaderboard upon request from a user or in interval
				break;
		}
	})

	console.log(wss.clients);
	ws.on('message', message => console.log(`Received: ${message}`));
	ws.on('close', () => console.log('Client disconnected'));
});