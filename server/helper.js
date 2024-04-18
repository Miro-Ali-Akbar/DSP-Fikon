
// Server helper functions

/**
 * @brief Updates alive-status of a socket.
 */
function heartbeat() {
    this.isAlive = true;
}

/**
 * @brief ID generation for new websockets
 * @returns generated user ID
 */
function generateID() {
    return Math.floor((1 + Math.random()) * 0x10000);
}


// Database helper functions

/**
 * @brief Enters data into a given document in database
 * @param userData data given to the function from parsed JSON-string
 */
async function initUser(username, userData) {
    await usersRef.doc(username).set(userData);
}
