import { Gpio } from "onoff";
import { StillCamera } from "pi-camera-connect";
import moment from "moment";
import { FirebaseHelper } from "./firebase-helper";
import { IotState, ParkingStatus } from "./iot-state";

const GPIO_TRIGGER = 7;
const GPIO_ECHO = 11;

// Setting up GPIO
console.log("Measuring distance with ultrasonic sensor");
let trigger = new Gpio(GPIO_TRIGGER, 'out');
let echo = new Gpio(GPIO_ECHO, 'in');
trigger.writeSync(0);

// Setting up Camera
let camera = new StillCamera();

function sleep(ms: number) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function distance(): Promise<number> {
    trigger.writeSync(1);
    await sleep(0.01);
    trigger.writeSync(0);

    let startTime = moment();
    let stopTime = moment();

    while(echo.readSync() == 0) {
        startTime = moment();
    }
    while(echo.readSync() == 1) {
        stopTime = moment();
    }

    let timeElapsed = stopTime.diff(startTime);
    return Number((timeElapsed * 17150).toFixed(2));
}

async function capture(): Promise<Buffer> {
    return camera.takeImage();
}

async function main() {
    let parked = false;
    let firebaseHelper = new FirebaseHelper('lg5-1');
    await firebaseHelper.init();
    while(true) {
        let dist = await distance();
        console.log(`Measured Distance: ${dist} cm`);
        if(dist < 30 && !parked) {
            let imageBuffer = await capture();
            let iotState = new IotState("test_vehicle_id", ParkingStatus.Occupied);
            firebaseHelper.updateIotState(iotState, imageBuffer);
        } else if (dist > 30 && parked) {
            parked = false;
        } else {
            await sleep(1000);
        }
    }
}

main();