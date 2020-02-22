import * as firebase from "firebase/app";
import "firebase/auth";
import "firebase/firestore";
import "firebase/functions";

import { IotState } from "./iot-state";

export class FirebaseHelper {
    deviceId: string;
    firestore: firebase.firestore.Firestore;

    constructor(deviceId) {
        this.deviceId = deviceId;
    }

    async init() {
        try {
            //FIXME: Security
            let app = firebase.initializeApp({
                project_id: "fyp-smartcarpark",
            })
            await firebase.auth().signInWithEmailAndPassword("iot-client@fyp-smartcarpark.com", "f]T*UjCtLGf7[#TYxJQ;vJ");
            this.firestore = app.firestore();
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

            let uploadFunction = firebase.functions().httpsCallable('iotUploadSnapshot');
            try {
                imageUrl = (await uploadFunction(JSON.stringify(data))).data["imageUrl"];
            } catch (error) {
                console.log(error);
            }
        }

        let state = iotState.toObj(imageUrl);

        await this.firestore.collection("iotState").doc(this.deviceId).set(state);
    }
}