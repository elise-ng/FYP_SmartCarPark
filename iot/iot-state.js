class IotState {
    constructor(deviceId, vehicleId, parkingStatus) {
        this.deviceId = deviceId;
        this.vehicleId = vehicleId;
        this.parkingStatus = parkingStatus;
        this.time = Date.now();
    }

    toJson() {
        return {
            'vehicle_id': this.vehicleId,
            'state': this.parkingStatus,
            'time': this.time,
        }
    }
}