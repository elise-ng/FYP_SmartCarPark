import * as firebase from 'firebase/app'
import 'firebase/auth'
import 'firebase/firestore'
import 'firebase/functions'
import moment from 'moment'

import GateRecord, { GateMode } from './gateRecord'

export enum ParkingStatus {
    // eslint-disable-next-line no-unused-vars
    vacant = 'vacant',
    // eslint-disable-next-line no-unused-vars
    occupied = 'occupied',
    // eslint-disable-next-line no-unused-vars
    unknown = 'unknown'
}

export default class FirebaseHelper {
    deviceId: string
    firestore: firebase.firestore.Firestore
    functions: firebase.functions.Functions

    constructor(deviceId) {
        this.deviceId = deviceId
    }

    async init() {
        try {
            console.log('Initializing Firebase...')
            //FIXME: Security
            let app = firebase.initializeApp({
                apiKey: 'AIzaSyCJOspIynTav487E4qnKkj-o8WHTsddGIQ',
                authDomain: 'fyp-smartcarpark.firebaseapp.com',
                databaseURL: 'https://fyp-smartcarpark.firebaseio.com',
                projectId: 'fyp-smartcarpark',
                storageBucket: 'fyp-smartcarpark.appspot.com',
                messagingSenderId: '777981643981',
                appId: '1:777981643981:web:6f215aa76849c60389ad84',
                measurementId: 'G-TRQVENNKGS'
            })
            await firebase.auth().signInWithEmailAndPassword('iot-client@fyp-smartcarpark.com', 'f]T*UjCtLGf7[#TYxJQ;vJ')
            this.firestore = app.firestore()
            this.functions = app.functions('asia-east2')
            console.log('Firebase initialized')
        } catch (error) {
            console.log(error)
            await this.init()
        }
    }

    async uploadJpgImage(buffer: Buffer) : Promise<string> {
        const data = {
            deviceId: this.deviceId,
            imageData: `data:image/jpeg;base64,${buffer.toString('base64')}`,
            imageTimestamp: moment().toISOString()
        }

        const func = this.functions.httpsCallable('iotUploadSnapshot')
        console.log('Uploading image...')
        return (await func(data)).data['imageUrl']
    }

    async recognizeLicensePlate(imageUrl: string) : Promise<string> {
        const data = {
            imageGsPath: imageUrl
        }

        const func = this.functions.httpsCallable('recognizeLicensePlate')
        console.log('Recognizing license plate...')
        return (await func(data)).data['license']
    }

    async updateIotState(state: ParkingStatus, vehicleId: string, imageUrl: string) {
        console.log(`Updating iotState...`)
        const payload = {
            deviceId: this.deviceId,
            state: state,
            vehicleId: vehicleId,
            imageUrl: imageUrl,
            time: firebase.firestore.Timestamp.fromDate(new Date())
        }
        await this.firestore.collection('iotStates').doc(this.deviceId).set(payload, { merge: true })
        console.log('iotState updated')
    }

    async createEntryGateRecord(vehicleId: string, imageUrl: string) {
        console.log(`Creating gateRecord...`)
        const payload = Object.assign({}, new GateRecord(
            this.deviceId, GateMode.entry, vehicleId, imageUrl
        ))
        const ref = await this.firestore.collection('gateRecords').add(payload)
        console.log(`gateRecord created: ${ref.id}`)
    }

    async updateElseCreateExitGateRecord(vehicleId: string, imageUrl: string) {
        const query = await this.firestore.collection('gateRecords')
            .where('vehicleId', '==', vehicleId)
            .where('exitScanTime', '==', null)
            .limitToLast(1)
            .get()
        if (query.docs.length > 0) {
            // previous record found
            console.log('gateRecord found')
            const gateRecordRef = query.docs[0].ref
            await gateRecordRef.set({
                exitGate: this.deviceId,
                exitScanTime: firebase.firestore.Timestamp.fromDate(new Date()),
                exitImageUrl: imageUrl
            }, { merge: true })
            console.log('gateRecord updated')
        } else {
            console.log('gateRecord not found, creating')
            const payload = Object.assign({}, new GateRecord(
                this.deviceId, GateMode.exit, vehicleId, imageUrl
            ))
            const ref = await this.firestore.collection('gateRecords').add(payload)
            console.log(`gateRecord created: ${ref.id}`)
        }
    }
}
