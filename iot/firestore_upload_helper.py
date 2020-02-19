import asyncio
import aiohttp
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from iot_state import IoTState
from io import BytesIO
import base64

class FirestoreUploadHelper:
    def __init__(self):
        # Use a service account
        cred = credentials.Certificate('./credentials.json')
        firebase_admin.initialize_app(cred)
        self.db = firestore.client()        

    async def update_state_log(self, jpg_image_bytes: BytesIO, iot_state: IoTState):
        #TODO: missing target url
        #TODO: missing image base 64 encoding implementation, as the datatype of the camera's captured image is unknown
        
        http_data = {
            'deviceId': iot_state.device_id,
            'imageData': base64.b64encode(jpg_image_bytes.read()),
            'imageTimestamp': iot_state.time.isoformat()
        }

        async with aiohttp.ClientSession() as session:
            async with session.post('https://asia-east2-fyp-smartcarpark.cloudfunctions.net/iotUploadSnapshot', data=http_data) as response:
                image_url = await response.json()["imageUrl"]

                # Add a new document
                data_dict = iot_state.toDict()
                data_dict['imageUrl'] = image_url
                self.upload_document('iotStates', iot_state.device_id, data_dict)

    def upload_document(self, collection_name: str, id: str, data: dict, update: bool = True):
        self.db.collection(collection_name).document(id).set(data, merge=update)