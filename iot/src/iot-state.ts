import moment from 'moment';

export enum ParkingStatus {
    Vacant,
    Occupied,
    Changing,
    Unknown,
}

export class IotState {
    vehicleId: string;
    parkingStatus: ParkingStatus;
    time: moment.Moment;

    constructor(vehicleId: string, parkingStatus: ParkingStatus) {
        this.vehicleId = vehicleId;
        this.parkingStatus = parkingStatus;
        this.time = moment();
    }

    toObj(imageUrl: string): Object {
        if(imageUrl == null) {
            return {
                image_url: imageUrl,
                vehicle_id: this.vehicleId,
                state: this.parkingStatus,
                time: this.time,
            }
        } else {
            return {
                vehicle_id: this.vehicleId,
                state: this.parkingStatus,
                time: this.time,
            }
        }
    }
}