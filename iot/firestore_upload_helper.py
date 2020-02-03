import asyncio
import aiohttp
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from iot_state import IoTState

class FirestoreUploadHelper:
    def __init__(self):
        # Use a service account
        cred = credentials.Certificate('./credentials.json')
        firebase_admin.initialize_app(cred)
        self.db = firestore.client()        

    async def upload_log(self, iotState: IoTState):
        #TODO: missing target url
        #TODO: missing image base 64 encoding implementation, as the datatype of the camera's captured image is unknown
        
        # async with aiohttp.ClientSession() as session:
        #     async with session.post("url", data={"image": "IMAGE_AS_BASE_64"}) as response:
        #         image_url = await response.json()["image_url"]

                # Add a new document
                self.db.collection('iotStates').add({
                    'deviceId': iotState.device_id,
                    'vehicleId': iotState.vehicle_id,
                    'state': iotState.state,
                    'time': iotState.time,
                    'imageUrl': "TEST_URL", #FIXME:
                })