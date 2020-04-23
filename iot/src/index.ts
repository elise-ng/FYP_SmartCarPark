import { StillCamera } from "pi-camera-connect"
import { FirebaseHelper } from "./firebase-helper"
import { IotState, ParkingStatus } from "./iot-state"
import { GateState, Gate } from "./gate-state"
import { DistanceHelper } from "./distance_helper"

enum Mode {
  iot = 'iot',
  gate = 'gate'
}

// Configs
const mode: string = Mode.gate
const deviceId: string = Gate.southEntry
const triggerDistanceInCm: number = 30

async function main() {
  let triggered = false
  const camera = new StillCamera()
  const firebaseHelper = new FirebaseHelper(deviceId)
  await firebaseHelper.init()
  const distanceHelper = new DistanceHelper()
  distanceHelper.startAndSubscribeDistanceChanges(async (distanceInCm) => {
      if (distanceInCm < triggerDistanceInCm && !triggered) {
        triggered = true
        let imageBuffer = await camera.takeImage()
        if (mode === Mode.iot) {
          let iotState = new IotState("test_vehicle_id", ParkingStatus.Occupied)
          await firebaseHelper.updateIotState(iotState, imageBuffer)
        } else if (mode === Mode.gate) {
          let gateState = new GateState("test_vehicle_id", Gate.southEntry)
          await firebaseHelper.updateEntryGateState(gateState, imageBuffer)
        }
      } else if (distanceInCm > triggerDistanceInCm && triggered) {
        triggered = false
      }
  })
}

main()

