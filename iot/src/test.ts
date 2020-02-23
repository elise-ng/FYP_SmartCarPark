import { FirebaseHelper } from "./firebase-helper";
import { IotState, ParkingStatus } from "./iot-state";
import { readFileSync } from "fs";

async function main() {
    let firebaseHelper = new FirebaseHelper("lg5-1");
    await firebaseHelper.init();
    let image = readFileSync("./image.jpeg");
    let iotState = new IotState("vehicleID", ParkingStatus.Occupied);
    try {
        await firebaseHelper.updateIotState(iotState, image);
    } catch (error) {
        console.log(error);
    }
    process.exit();
}

main();