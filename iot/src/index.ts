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
const gateThresholdInCm: number = 200
const lotThresholdInCm: number = 100
const stableThresholdInCm: number = 5 // TODO: find out error / noise range of reading
const historySize: number = 3

// Check if array is sorted in accending/decending order
function isIncremental(arr: number[], accending: boolean) {
  return arr.every(function (x, i) {
    if (accending) {
      return i === 0 || x > arr[i - 1]
    } else {
      return i === 0 || x < arr[i - 1]
    }
  })
}

async function main() {
  try {
    let lastDistanceInCm: number = Infinity
    const distanceHistory: number[] = []
    const firebaseHelper = new FirebaseHelper(deviceId)
    await firebaseHelper.init()
    const distanceHelper = new DistanceHelper()

    switch (mode) {
      case Mode.gate:
        console.log('In Gate Mode')
        let triggered: boolean = false
        distanceHelper.startAndSubscribeDistanceChanges(async (distanceInCm) => {
          try {
            if (Math.abs(distanceInCm - lastDistanceInCm) > stableThresholdInCm) {
              console.log(`Major movement: ${lastDistanceInCm} -> ${distanceInCm}`)
            }
            if (distanceHistory.length >= historySize) {
              distanceHistory.shift()
            }
            distanceHistory.push(distanceInCm)
            // if arrroaching && distance < threshold -> take photo
            if (!triggered && isIncremental(distanceHistory, false) && distanceInCm < gateThresholdInCm) {
              console.log(`Apprach detected, dist ${distanceHistory.join(' -> ')}`)
              triggered = true
              let gateState = new GateState("test_vehicle_id", Gate.southEntry)
              let imageBuffer: Buffer
              try {
                const camera = await exec('raspistill -ISO 800 -ex sports -n -o ./snapshot.jpg')
                if (!camera.stderr) {
                  imageBuffer = await readFile('./snapshot.jpg')
                } else {
                  console.log(`Camera no output: ${camera.stderr}`)
                }
              } catch (e) {
                console.error(e)
              }
              await firebaseHelper.updateEntryGateState(gateState, imageBuffer)
            } else if (triggered && isIncremental(distanceHistory, true)) { // if leaving, reset
              console.log(`Departure detected, dist ${distanceHistory.join(' -> ')}`)
              triggered = false
            }
          } catch (e) {
            console.error(e)
          } finally {
            lastDistanceInCm = distanceInCm
          }
        })
        break
      case Mode.iot:
        console.log('In IoT (Lot) Mode')
        let lastStatus: ParkingStatus
        distanceHelper.startAndSubscribeDistanceChanges(async (distanceInCm) => {
          try {
            if (Math.abs(distanceInCm - lastDistanceInCm) > stableThresholdInCm) {
              console.log(`Major movement: ${lastDistanceInCm} -> ${distanceInCm}`)
            }
            if (distanceHistory.length >= historySize) {
              distanceHistory.shift()
            }
            distanceHistory.push(distanceInCm)
            // if approaching && distance < threshold -> occupied, take photo
            if (lastStatus !== ParkingStatus.Occupied && isIncremental(distanceHistory, false) && distanceInCm < lotThresholdInCm) {
              // occupied
              console.log(`Occupied detected, last state ${lastStatus}, dist ${distanceHistory.join(' -> ')}`)
              lastStatus = ParkingStatus.Occupied
              let iotState = new IotState("test_vehicle_id", ParkingStatus.Occupied)
              let imageBuffer: Buffer
              try {
                const camera = await exec('raspistill -ISO 800 -ex sports -n -o ./snapshot.jpg')
                if (!camera.stderr) {
                  imageBuffer = await readFile('./snapshot.jpg')
                } else {
                  console.log(`Camera no output: ${camera.stderr}`)
                }
              } catch (e) {
                console.error(e)
              }
              await firebaseHelper.updateIotState(iotState, imageBuffer)
              // if leaving && distance > threshold -> vacant
            } else if (lastStatus !== ParkingStatus.Vacant && isIncremental(distanceHistory, true) && distanceInCm > lotThresholdInCm) {
              // vacant
              console.log(`Vacant detected, last state ${lastStatus}, dist ${distanceHistory.join(' -> ')}`)
              lastStatus = ParkingStatus.Vacant
              // let imageBuffer = await camera.takeImage()
              let iotState = new IotState(null, ParkingStatus.Vacant)
              await firebaseHelper.updateIotState(iotState, null)
            }
          } catch (e) {
            console.error(e)
          } finally {
            lastDistanceInCm = distanceInCm
          }
        })
        break
    }
  } catch (e) {
    console.error(e)
  }
}

main()
