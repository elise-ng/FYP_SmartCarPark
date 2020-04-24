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
const mode: string = process.env.mode
const deviceId: string = process.env.deviceId
const occupiedThresholdInCm: number = 50
const vacantThresholdInCm: number = 250
const stableThresholdInCm: number = 5 // TODO: find out error / noise range of reading

async function main() {
  try {
    let lastDistanceInCm: number = Infinity
  
    const camera = new StillCamera()
    const firebaseHelper = new FirebaseHelper(deviceId)
    await firebaseHelper.init()
    const distanceHelper = new DistanceHelper()
  
    switch (mode) {
      case Mode.gate:
        distanceHelper.startAndSubscribeDistanceChanges(async (distanceInCm) => {
          try {
            let triggered: boolean = false
            // if arrroaching && distance < threshold -> take photo
            if (!triggered && lastDistanceInCm > distanceInCm + stableThresholdInCm && distanceInCm < occupiedThresholdInCm) {
              triggered = true
              let imageBuffer = await camera.takeImage()
              let gateState = new GateState("test_vehicle_id", Gate.southEntry)
              await firebaseHelper.updateEntryGateState(gateState, imageBuffer)
            } else if (triggered && distanceInCm > lastDistanceInCm + stableThresholdInCm) { // if leaving, reset
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
            let lastStatus: ParkingStatus
            // if approaching && distance < threshold -> occupied, take photo
            if (lastStatus !== ParkingStatus.Occupied && lastDistanceInCm > distanceInCm + stableThresholdInCm && distanceInCm < occupiedThresholdInCm) {
              // occupied
              lastStatus = ParkingStatus.Occupied
              let imageBuffer = await camera.takeImage()
              let iotState = new IotState("test_vehicle_id", ParkingStatus.Occupied)
              await firebaseHelper.updateIotState(iotState, imageBuffer)
            // if leaving && distance > threshold -> vacant
            } else if (lastStatus !== ParkingStatus.Vacant && distanceInCm > lastDistanceInCm + stableThresholdInCm && distanceInCm > vacantThresholdInCm) {
              // vacant
              lastStatus = ParkingStatus.Vacant
              // let imageBuffer = await camera.takeImage()
              let iotState = new IotState(null, ParkingStatus.Vacant)
              await firebaseHelper.updateIotState(iotState, null)
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

