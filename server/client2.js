const { WebSocket } = require('ws');

const ws = new WebSocket("ws://localhost:3000");

ws.onopen = () => {

    ws.send(JSON.stringify({msgID: "initRes", data: { username: "hitsu", friendlist: [], friendRequests: ["uName"], online: true } }));

    ws.send(JSON.stringify({msgID: "acceptRequest", data: { target: "uName", sender: "hitsu"}}));

    ws.send(JSON.stringify({msgID: "getRoute", data: { index: 0 }}));
    
    ws.send(JSON.stringify({msgID: "getLeaderboard"}));

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
        }
    });
}