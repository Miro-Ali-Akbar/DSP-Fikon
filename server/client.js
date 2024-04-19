
const { WebSocket } = require('ws');

const ws = new WebSocket("ws://localhost:3000");

ws.onopen = () => {

    ws.send(JSON.stringify({msgID: "initRes", data: { username: "uName" } }));


    ws.send(JSON.stringify({msgID: "routesReq", data: { index: 0 }}));

    ws.on('message', msg => {
        console.log(JSON.parse(msg));
    });
}