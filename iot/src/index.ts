import { promisify } from 'util'
import { exec as execCb } from 'child_process'
import { readFile as readFileCb } from 'fs'
const exec = promisify(execCb)
const readFile = promisify(readFileCb)

import FirebaseHelper, { ParkingStatus } from './firebaseHelper'
import { GateMode } from './gateRecord'
import DistanceHelper from './distanceHelper'

enum Mode {
  // eslint-disable-next-line no-unused-vars
  iot = 'iot',
  // eslint-disable-next-line no-unused-vars
  gate = 'gate'
}

// Configs
const mode: string = process.env.mode
const deviceId: string = process.env.deviceId
const gateMode: string = process.env.gateMode
const gateThresholdInCm: number = 250
const lotThresholdInCm: number = 150
const stableThresholdInCm: number = 5 // TODO: find out error / noise range of reading
const historySize: number = 3

// Return average of all members in arr
function average(arr: number[]) {
  const sum = arr.reduce((a, b) => a + b, 0)
  return (sum / arr.length) || 0
}

async function takePicture() : Promise<Buffer> {
  const camera = await exec('raspistill -q 10 -ISO 800 -ex sports -n -o ./snapshot.jpg -t 500')
  if (!camera.stderr) {
    return await readFile('./snapshot.jpg')
  } else {
    console.log(`Camera no output: ${camera.stderr}`)
  }
}

async function main() {
  try {
    let lastDistanceInCm: number = Infinity
    const distanceHistory: number[] = []
    const firebaseHelper = new FirebaseHelper(deviceId)
    await firebaseHelper.init()
    const distanceHelper = new DistanceHelper()

    switch (mode) {
      case Mode.gate: {
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
            if (!triggered && average(distanceHistory) < gateThresholdInCm) {
              console.log(`Apprach detected, dist ${distanceHistory.join(' -> ')}`)
              triggered = true
              let imageBuffer: Buffer
              try {
                imageBuffer = await takePicture()
              } catch (e) {
                console.error(e)
              }
              let imageUrl = ''
              let vehicleId = ''
              try {
                imageUrl = await firebaseHelper.uploadJpgImage(imageBuffer)
                vehicleId = await firebaseHelper.recognizeLicensePlate(imageUrl)
              } catch (e) {
                console.log(e)
              }
              // TODO: Call CV for license plate
              switch (gateMode) {
                case GateMode.entry: {
                  await firebaseHelper.createEntryGateRecord(vehicleId, imageUrl)
                  break
                }
                case GateMode.exit: {
                  // TODO: try to retreive existing gate record by license plate, otherwise create new
                  await firebaseHelper.updateElseCreateExitGateRecord(vehicleId, imageUrl)
                  break
                }
                default:
                  console.error('Gate mode not handled')
              }
            } else if (triggered && average(distanceHistory) >= gateThresholdInCm) { // if leaving, reset
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
      }
      case Mode.iot: {
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
            if (lastStatus === undefined && distanceHistory.length < historySize) {
              return // Wait for distance history to fill up before analysing states 
            }
            // if approaching && distance < threshold -> occupied, take photo
            if (lastStatus !== ParkingStatus.occupied && average(distanceHistory) < lotThresholdInCm) {
              // occupied
              console.log(`Occupied detected, last state ${lastStatus}, dist ${distanceHistory.join(' -> ')}`)
              lastStatus = ParkingStatus.occupied
              let imageBuffer: Buffer
              try {
                imageBuffer = await takePicture()
              } catch (e) {
                console.error(e)
              }
              let imageUrl = ''
              let vehicleId = ''
              try {
                imageUrl = await firebaseHelper.uploadJpgImage(imageBuffer)
                vehicleId = await firebaseHelper.recognizeLicensePlate(imageUrl)
              } catch (e) {
                console.log(e)
              }
              await firebaseHelper.updateIotState(lastStatus, vehicleId, imageUrl)
              // if leaving && distance > threshold -> vacant
            } else if (lastStatus !== ParkingStatus.vacant && average(distanceHistory) > lotThresholdInCm) {
              // vacant
              console.log(`Vacant detected, last state ${lastStatus}, dist ${distanceHistory.join(' -> ')}`)
              lastStatus = ParkingStatus.vacant
              let imageBuffer: Buffer
              try {
                imageBuffer = await takePicture()
              } catch (e) {
                console.error(e)
              }
              const imageUrl = await firebaseHelper.uploadJpgImage(imageBuffer)
              await firebaseHelper.updateIotState(lastStatus, null, imageUrl)
            }
          } catch (e) {
            console.error(e)
          } finally {
            lastDistanceInCm = distanceInCm
          }
        })
        break
      }
    }
  } catch (e) {
    console.error(e)
  }
}

main()
