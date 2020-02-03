from datetime import datetime

class IoTState:
    def __init__(self, device_id: str, vehicle_id: str, state: str):
        self.device_id = device_id
        self.vehicle_id = vehicle_id
        self.state = state
        self.time = datetime.now()