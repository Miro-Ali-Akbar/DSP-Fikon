const { WebSocket } = require('ws');

const ws = new WebSocket("ws://localhost:3000");

ws.onopen = () => {

    ws.send(JSON.stringify({msgID: "initRes", data: { username: "uName", friendRequests: [], friendlist: [], online: true } }));

    // ws.send(JSON.stringify({msgID: "getRoute", data: { index: 0 }}));
    
    ws.send(JSON.stringify({msgID: "getLeaderboard"}));
    // ws.send(JSON.stringify({msgID: "addFriend", data: { target: "uName", sender: "pop"}}));

    ws.send(JSON.stringify({msgID: "addRoute", data: {trailName: "abc", dink: "donk"}}))

    ws.on('message', msg => {
        const message = JSON.parse(msg);
        console.log(message);
        switch(message.msgID) {
            case "init":
                console.log(message.data);
                break;
            case "leaderboard":
                console.log(message.data);
                break;
            case "incomingRequest":
                console.log(message.data);
            case "newFriend":
                console.log(message.data);
        }
    });
}