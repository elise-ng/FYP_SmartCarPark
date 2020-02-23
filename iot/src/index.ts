import { StillCamera } from "pi-camera-connect";
import moment from "moment";
import { FirebaseHelper } from "./firebase-helper";
import { IotState, ParkingStatus } from "./iot-state";

const Gpio = require('pigpio').Gpio;

// Setting up GPIO

// Setting up Camera
let camera = new StillCamera();

function sleep(ms: number) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

function getDistance() {
  return new Promise((resolve, reject) => {
    var MICROSECDONDS_PER_CM = 1e6 / 34321;
    var trigger = new Gpio(4, { mode: Gpio.OUTPUT });
    var echo = new Gpio(17, { mode: Gpio.INPUT, alert: true });
    trigger.digitalWrite(0); // Make sure trigger is low
    var startTick;
    var prox;
    trigger.trigger(10, 1);
    echo.on('alert', (level, tick) => {
      if (level == 1) {
        startTick = tick;
      } else {
        var endTick = tick;
        var diff = (endTick >> 0) - (startTick >> 0); // Unsigned 32 bit $
        prox = diff / 2 / MICROSECDONDS_PER_CM;
        resolve(prox);
      }
    });
  });
}


async function capture(): Promise<Buffer> {
    return camera.takeImage();
}

async function main() {
    let parked = false;
    let firebaseHelper = new FirebaseHelper('lg5-1');
    await firebaseHelper.init();
    console.log("done firebase helper")
    while(true) {
    console.log("enter loop")
        const dist = await getDistance();

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
