import asyncio
import aiohttp
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import time
from datetime import datetime

# Use a service account
cred = credentials.Certificate('./credentials.json')
firebase_admin.initialize_app(cred)

db = firestore.client()

class IoTState:
    def __init__(self, device_id: str, vehicle_id: str, state: str):
        self.device_id = device_id
        self.vehicle_id = vehicle_id
        self.state = state
        self.time = datetime.now()
         

async def upload_log(iotState: IoTState):
    async with aiohttp.ClientSession() as session:
        #TODO: missing target url
        #TODO: missing image base 64 encoding implementation, as the datatype of the camera's captured image is unknown
        async with session.post("url", data={"image": "IMAGE_AS_BASE_64"}) as response:
            image_url = await response.json()["image_url"]

            # Add a new document
            db.collection('iotStates').add({
                'deviceId': iotState.device_id,
                'vehicleId': iotState.vehicle_id,
                'state': iotState.state,
                'time': iotState.time,
                'imageUrl': image_url,
            })