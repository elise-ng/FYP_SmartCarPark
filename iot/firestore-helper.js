import * as admin from 'firebase-admin';
var credentials = require("./credentials.json");

class FirestoreHelper {
    constructor(deviceId) {
        admin.initializeApp({
            credential: admin.credential.cert(credentials)
        })
        admin.auth().createCustomToken(deviceId)
    }
}