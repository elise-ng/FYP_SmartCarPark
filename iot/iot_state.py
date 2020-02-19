from datetime import datetime
from enum import Enum

class ParkingState(Enum):
    Vacant = 0
    Occupied = 1
    Changing = 2
    Unknown = 3

class IoTState:
    def __init__(self, device_id: str, vehicle_id: str, parking_state: ParkingState):
        self.device_id = device_id
        self.vehicle_id = vehicle_id
        self.parking_state = parking_state
        self.time = datetime.now()

    def toDict(self):
        return {
            'vehicleId': self.vehicle_id,
            'state': self.parking_state.name.lower(),
            'time': self.time,
        }
