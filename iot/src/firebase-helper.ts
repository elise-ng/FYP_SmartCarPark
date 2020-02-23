import * as firebase from "firebase/app";
import "firebase/auth";
import "firebase/firestore";
import "firebase/functions";

import { IotState } from "./iot-state";

export class FirebaseHelper {
    deviceId: string;
    firestore: firebase.firestore.Firestore;
    functions: firebase.functions.Functions;

    constructor(deviceId) {
        this.deviceId = deviceId;
    }

    async init() {
        try {
            console.log("Initializing Firebase...")
            //FIXME: Security
            let app = firebase.initializeApp({
                apiKey: "AIzaSyCJOspIynTav487E4qnKkj-o8WHTsddGIQ",
                authDomain: "fyp-smartcarpark.firebaseapp.com",
                databaseURL: "https://fyp-smartcarpark.firebaseio.com",
                projectId: "fyp-smartcarpark",
                storageBucket: "fyp-smartcarpark.appspot.com",
                messagingSenderId: "777981643981",
                appId: "1:777981643981:web:6f215aa76849c60389ad84",
                measurementId: "G-TRQVENNKGS"
            })
            await firebase.auth().signInWithEmailAndPassword("iot-client@fyp-smartcarpark.com", "f]T*UjCtLGf7[#TYxJQ;vJ");
            this.firestore = app.firestore();
            this.functions = app.functions('asia-east2');
        } catch (error) {
            console.log(error);
        }
    }

    async updateIotState(iotState: IotState, jpgImageBuffer?: Buffer) {
        let imageUrl: string;

        if (jpgImageBuffer != null) {
            let data = {
                deviceId: this.deviceId,
                imageData: `data:image/jpeg;base64,${jpgImageBuffer.toString('base64')}`,
                imageTimestamp: iotState.time.toISOString()
            }

            let uploadFunction = this.functions.httpsCallable('iotUploadSnapshot');
            try {
                console.log("Uploading image...");
                imageUrl = (await uploadFunction(data)).data["imageUrl"];
            } catch (error) {
                console.log(error);
            }
        }

        console.log(`Updating state of ${this.deviceId}...`);
        let state = iotState.toObj(imageUrl);
        await this.updateDocument("iotStates", this.deviceId, state);
        console.log("State updated");
    }

    async updateDocument(collection: string, document: string, data: object) {
        await this.firestore.collection(collection).doc(document).set(data, {
            merge: true
        });
    }
}