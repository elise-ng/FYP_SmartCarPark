from iot_state import IoTState, ParkingState
from firestore_upload_helper import FirestoreUploadHelper
import asyncio
from io import BytesIO

async def main():
    print("Initialize firestore upload helper...")
    upload_helper = FirestoreUploadHelper()
    state = IoTState(device_id="test_device_id123", vehicle_id="test_vehicle_id", parking_state=ParkingState.Occupied)
    await upload_helper.update_state_log(jpg_image_bytes=BytesIO(open('./image.jpeg', 'rb').read()), iot_state=state)
    print("State updated")

if __name__ == '__main__':
    loop = asyncio.get_event_loop()
    loop.run_until_complete(main())
