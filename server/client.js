const { WebSocket } = require('ws');

const ws = new WebSocket("ws://trocader.duckdns.org:4000");

ws.onopen = () => {


    ws.send(JSON.stringify({msgID: "initRes", data: { email: "hitsu@gmal.com", name: "hitsu" } }));
    ws.send(JSON.stringify({msgID: "loggedIn", data: { email: "hitsu@gmal.com"}}));

    // ws.send(JSON.stringify({msgID: "getRoute", data: { index: 0 }}));


    ws.send(JSON.stringify({msgID: "updateLeaderboard", data: { user: {username: "uName", points: 1000} }}));

    //ws.send(JSON.stringify({msgID: "getRoute", data: { trailName: "MyTrail", username: 'uName' }}));

    
    ws.send(JSON.stringify({msgID: "getLeaderboard"}));
    // ws.send(JSON.stringify({msgID: "addFriend", data: { target: "uName", sender: "pop"}}));

    ws.send(JSON.stringify({msgID: "addFriend", data: {target: "hjgfhjkkkbbj", sender: "hitsu"}}));

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