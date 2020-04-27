import moment from 'moment'

export enum ParkingStatus {
    Vacant,
    Occupied,
    Changing,
    Unknown,
}

export class IotState {
    vehicleId: string
    parkingStatus: ParkingStatus
    time: moment.Moment

    constructor(vehicleId: string, parkingStatus: ParkingStatus) {
        this.vehicleId = vehicleId
        this.parkingStatus = parkingStatus
        this.time = moment()
    }

    toObj(imageUrl: string): Object {
        if(imageUrl != null) {
            return {
                imageUrl: imageUrl,
                vehicleId: this.vehicleId,
                state: ParkingStatus[this.parkingStatus].toLowerCase(),
                time: this.time.toDate(),
            }
        } else {
            return {
                vehicleId: this.vehicleId,
                state: ParkingStatus[this.parkingStatus].toLowerCase(),
                time: this.time.toDate(),
            }
        }
    }
}