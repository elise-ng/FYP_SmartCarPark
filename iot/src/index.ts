import { FirebaseHelper } from "./firebase-helper"
import { IotState, ParkingStatus } from "./iot-state"
import { GateState, Gate } from "./gate-state"
import { DistanceHelper } from "./distance_helper"
import { promisify } from 'util'
import { exec as execCb } from 'child_process'
import { readFile as readFileCb } from 'fs'
const exec = promisify(execCb)
const readFile = promisify(readFileCb)

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
    const firebaseHelper = new FirebaseHelper(deviceId)
    await firebaseHelper.init()
    const distanceHelper = new DistanceHelper()
  
    switch (mode) {
      case Mode.gate:
        console.log('In Gate Mode')
        distanceHelper.startAndSubscribeDistanceChanges(async (distanceInCm) => {
          try {
            let triggered: boolean = false
            if (Math.abs(distanceInCm - lastDistanceInCm) > stableThresholdInCm) {
              console.log(`Major movement: ${lastDistanceInCm} -> ${distanceInCm}`)
            }
            // if arrroaching && distance < threshold -> take photo
            if (!triggered && lastDistanceInCm > distanceInCm + stableThresholdInCm && distanceInCm < occupiedThresholdInCm) {
              console.log(`Apprach detected, dist ${lastDistanceInCm} -> ${distanceInCm}`)
              triggered = true
              let gateState = new GateState("test_vehicle_id", Gate.southEntry)
              let imageBuffer:Buffer
              const camera = await exec('raspistill -ISO 800 -ex sports -n -o /tmp/iot/snapshot.jpg',)
              if (!camera.stderr) {
                imageBuffer = await readFile('/tmp/iot/snapshot.jpg')
              } else {
                console.log(`Camera no output: ${camera.stderr}`)
              }
              await firebaseHelper.updateEntryGateState(gateState, imageBuffer)
            } else if (triggered && distanceInCm > lastDistanceInCm + stableThresholdInCm) { // if leaving, reset
              console.log(`Departure detected, dist ${lastDistanceInCm} -> ${distanceInCm}`)
              triggered = false
            }
            lastDistanceInCm = distanceInCm
          } catch (e) {
            console.error(e)
          }
        })
        break
      case Mode.iot:
        console.log('In IoT (Lot) Mode')
        distanceHelper.startAndSubscribeDistanceChanges(async (distanceInCm) => {
          try {
            let lastStatus: ParkingStatus
            if (Math.abs(distanceInCm - lastDistanceInCm) > stableThresholdInCm) {
              console.log(`Major movement: ${lastDistanceInCm} -> ${distanceInCm}`)
            }
            // if approaching && distance < threshold -> occupied, take photo
            if (lastStatus !== ParkingStatus.Occupied && lastDistanceInCm > distanceInCm + stableThresholdInCm && distanceInCm < occupiedThresholdInCm) {
              // occupied
              console.log(`Occupied detected, last state ${lastStatus}, dist ${lastDistanceInCm} -> ${distanceInCm}`)
              lastStatus = ParkingStatus.Occupied
              let iotState = new IotState("test_vehicle_id", ParkingStatus.Occupied)
              let imageBuffer:Buffer
              const camera = await exec('raspistill -ISO 800 -ex sports -n -o /tmp/iot/snapshot.jpg',)
              if (!camera.stderr) {
                imageBuffer = await readFile('/tmp/iot/snapshot.jpg')
              } else {
                console.log(`Camera no output: ${camera.stderr}`)
              }
              await firebaseHelper.updateIotState(iotState, imageBuffer)
            // if leaving && distance > threshold -> vacant
            } else if (lastStatus !== ParkingStatus.Vacant && distanceInCm > lastDistanceInCm + stableThresholdInCm && distanceInCm > vacantThresholdInCm) {
              // vacant
              console.log(`Vacant detected, last state ${lastStatus}, dist ${lastDistanceInCm} -> ${distanceInCm}`)
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
