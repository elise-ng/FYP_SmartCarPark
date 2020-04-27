import * as firebase from "firebase/app"
import "firebase/firestore"

export enum GateMode {
    // eslint-disable-next-line no-unused-vars
    entry = 'entry',
    // eslint-disable-next-line no-unused-vars
    exit = 'exit'
}

export default class GateRecord {
    vehicleId: string = null
    phoneNumber: string = null
    entryScanTime: firebase.firestore.Timestamp = null
    entryConfirmTime: firebase.firestore.Timestamp = null
    entryImageUrl: string = null
    exitScanTime: firebase.firestore.Timestamp = null
    exitConfirmTime: firebase.firestore.Timestamp = null
    exitImageUrl: string = null
    entryGate: string = null
    exitGate: string = null
    paymentStatus: string = null
    paymentTime: firebase.firestore.Timestamp = null 
    
    constructor(deviceId: string, gateMode: GateMode, vehicleId: string, imageUrl: string) {
        this.vehicleId = vehicleId
        switch (gateMode) {
            case GateMode.entry:
                this.entryGate = deviceId
                this.entryScanTime = firebase.firestore.Timestamp.fromDate(new Date())
                this.entryImageUrl = imageUrl
                break
            case GateMode.exit:
                this.exitGate = deviceId
                this.exitScanTime = firebase.firestore.Timestamp.fromDate(new Date())
                this.exitImageUrl = imageUrl
                break
        }
    }
}
