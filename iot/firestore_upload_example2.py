from iot_state import IoTState, ParkingState
from firestore_upload_helper import FirestoreUploadHelper
import asyncio
import RPi.GPIO as GPIO
import time
from picamera import PiCamera
from time import sleep
from io import BytesIO

# GPIO Setting
GPIO.setmode(GPIO.BOARD)
GPIO_TRIGGER = 7
GPIO_ECHO = 11
print("now measure the distance with ultrasonic sensor")
camera = PiCamera()
GPIO.setup(GPIO_TRIGGER, GPIO.OUT)
GPIO.setup(GPIO_ECHO,GPIO.IN)
GPIO.output(GPIO_TRIGGER, GPIO.LOW)
time.sleep(2)

def distance():
    GPIO.output(GPIO_TRIGGER, GPIO.HIGH)
    time.sleep(0.00001)
    GPIO.output(GPIO_TRIGGER, GPIO.LOW)

    StartTime = time.time()
    StopTime = time.time()

    while GPIO.input(GPIO_ECHO) == 0:
        StartTime = time.time()
    while GPIO.input(GPIO_ECHO) == 1:
        StopTime = time.time()

    TimeElapsed = StopTime - StartTime
    distance = round(TimeElapsed * 17150,2)

    return distance

def capture():
    stream = BytesIO()
    camera.start_preview()
    sleep(3)
    camera.capture(stream, 'jpeg')
    camera.stop_preview()
    return stream

def analysis():
    return True #if successfully scan the plate num

async def main():
    parked = False
    print("Initialize firestore upload helper...")
    upload_helper = FirestoreUploadHelper()
    while True:
            dist = distance()
            print("Measured Distance = %.1f cm" %dist)
            if (dist < 30 and not parked): #parking near
                stream = capture()
                if(analysis()): #do carplate scan
                    parked = True
                    print("Uploading state")
                    state = IoTState(device_id="test2_device_idabc", vehicle_id="test_vehiicle_id", parking_state=ParkingState.Occupied)
                    await upload_helper.update_state_log(jpg_image_bytes=stream, iot_state=state)
                    print("State updated")
            elif (dist > 30 and parked): # leaving the car space
                parked = False
            else:
                time.sleep(1)

if __name__ == '__main__':
    loop = asyncio.get_event_loop()
    loop.run_until_complete(main())

