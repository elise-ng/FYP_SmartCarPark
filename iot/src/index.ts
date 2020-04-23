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
const occupiedThresholdInCm: number = 100
const vacantThresholdInCm: number = 300
const stableThresholdInCm: number = 5 // TODO: find out error / noise range of reading

async function main() {
  try {
    let triggered: boolean = false
    let lastDistanceInCm: number = Infinity
  
    const camera = new StillCamera()
    const firebaseHelper = new FirebaseHelper(deviceId)
    await firebaseHelper.init()
    const distanceHelper = new DistanceHelper()
  
    switch (mode) {
      case Mode.gate:
        distanceHelper.startAndSubscribeDistanceChanges(async (distanceInCm) => {
          try {
            // if arrroaching && distance < threshold -> take photo
            if (!triggered && lastDistanceInCm > distanceInCm && distanceInCm < occupiedThresholdInCm) {
              triggered = true
              let imageBuffer = await camera.takeImage()
              let gateState = new GateState("test_vehicle_id", Gate.southEntry)
              await firebaseHelper.updateEntryGateState(gateState, imageBuffer)
            } else if (distanceInCm > lastDistanceInCm) { // if leaving, reset
              triggered = false
            }
            lastDistanceInCm = distanceInCm
          } catch (e) {
            console.error(e)
          }
        })
        break
      case Mode.iot:
        distanceHelper.startAndSubscribeDistanceChanges(async (distanceInCm) => {
          try {
            // if approaching && distance < threshold -> occupied, take photo
            if (!triggered && lastDistanceInCm > distanceInCm && distanceInCm < occupiedThresholdInCm) {
              // occupied
              triggered = true
              let imageBuffer = await camera.takeImage()
              let iotState = new IotState("test_vehicle_id", ParkingStatus.Occupied)
              await firebaseHelper.updateIotState(iotState, imageBuffer)
            // if leaving && distance > threshold -> vacant
            } else if (!triggered && Math.abs(lastDistanceInCm - distanceInCm) < stableThresholdInCm && distanceInCm > vacantThresholdInCm) {
              // vacant
              triggered = true
              // let imageBuffer = await camera.takeImage()
              let iotState = new IotState(null, ParkingStatus.Vacant)
              await firebaseHelper.updateIotState(iotState, null)
            } else if (triggered && Math.abs(lastDistanceInCm - distanceInCm) < stableThresholdInCm) { // stablized, reset
              triggered = false
            }
            lastDistanceInCm = distanceInCm
          } catch (e) {
            console.error(e)
          }
        })
        break
    }
  } catch (e) {
    console.error(e)
  }
}

main()

