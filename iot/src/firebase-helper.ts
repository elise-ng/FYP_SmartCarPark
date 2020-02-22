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
            this.functions = app.functions('asia-east-2');
        } catch (error) {
            console.log(error);
        }
    }

    async updateIotState(iotState: IotState, imageBuffer?: Buffer) {
        let imageUrl: string;

        if (imageBuffer != null) {
            let data = {
                deviceId: this.deviceId,
                imageData: imageBuffer.toString('base64'),
                imageTimestamp: iotState.time.toISOString()
            }

            let uploadFunction = this.functions.httpsCallable('iotUploadSnapshot');
            try {
                let response = await uploadFunction(data);
                console.log(response);
                imageUrl = response.data["imageUrl"];
            } catch (error) {
                console.log(error);
            }
        }

        let state = iotState.toObj(imageUrl);

        await this.firestore.collection("iotState").doc(this.deviceId).set(state);
    }
}