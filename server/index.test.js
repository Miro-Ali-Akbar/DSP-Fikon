
const heartbeat = require('./heartbeat');

test('checks the heartbeat of a non-existing client client, returns false', () => {
    expect(client.heartbeat).tobe(false);
})