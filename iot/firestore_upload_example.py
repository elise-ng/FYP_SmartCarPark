from iot_state import IoTState
from firestore_upload_helper import FirestoreUploadHelper
import asyncio

async def main():
    print("Initialize firestore upload helper...")
    upload_helper = FirestoreUploadHelper()
    state = IoTState(device_id="test_device_id", vehicle_id="test_vehicle_id", state="parked")
    await upload_helper.upload_log(state)
    print("State updated")

if __name__ == '__main__':
    loop = asyncio.get_event_loop()
    loop.run_until_complete(main())