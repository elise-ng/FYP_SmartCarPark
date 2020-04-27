import moment from 'moment'

export enum Gate {
    southEntry = 'southEntry',
    northEntry = 'northEntry',
    southExit = 'southExit',
    northExit = 'northExit',
}

export class GateState {
    vehicleId: string
    phoneNumber: number
    entryScanTime: moment.Moment
    entryConfirmTime: moment.Moment
    paymentTime: moment.Moment
    exitScanTime: moment.Moment
    exitConfirmTime: moment.Moment
    entryGate: Gate
    exitGate: Gate

    constructor(vehicleId: string, gate: Gate) {
        this.vehicleId = vehicleId
        this.entryScanTime = moment()
        this.entryGate = gate
    }

    toObj(imageUrl: string): Object {
        if (imageUrl != null) {
            console.log("imageUrl not null")
            return {
                imageUrl: imageUrl,
                entryScanTime: this.entryScanTime.toDate(),
                entryGate: Gate[this.entryGate],
            }
        } else {
            console.log("imageUrl null")
            return {
                entryScanTime: this.entryScanTime.toDate(),
                entryGate: Gate[this.entryGate],
            }
        }
    }
}

