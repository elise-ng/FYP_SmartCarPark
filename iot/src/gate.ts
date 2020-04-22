import { StillCamera } from "pi-camera-connect"
import { FirebaseHelper } from "./firebase-helper"
import { IotState, ParkingStatus } from "./iot-state"
import { GateState, Gate } from "./gate-state"
import { Gpio } from "pigpio"

// The number of microseconds it takes sound to travel 1cm at 20 degrees celcius
const MICROSECDONDS_PER_CM = 1e6 / 34321
// Setting up GPIO
let trigger = new Gpio(4, { mode: Gpio.OUTPUT })
let echo = new Gpio(17, { mode: Gpio.INPUT, alert: true })

let triggerTimeoutId: NodeJS.Timeout

// Setting up Camera
let camera = new StillCamera()

// Capture image
async function capture(): Promise<Buffer> {
  return camera.takeImage()
}

async function main() {
  let firebaseHelper = new FirebaseHelper('southEntry')
  await firebaseHelper.init()

  // Echo distance calculation listener
  let startTick
  trigger.digitalWrite(0) // Make sure trigger is low
  echo.on('alert', async (level, tick) => {
    if (level == 1) {
      startTick = tick
    } else {
      let endTick = tick
      let diff = (endTick >> 0) - (startTick >> 0) // Unsigned 32 bit arithmetic
      let dist = diff / 2 / MICROSECDONDS_PER_CM

      console.log(`Measured Distance: ${dist} cm`)
      if (dist < 30) {
        // Stop the echo trigger
        clearInterval(triggerTimeoutId)
        let imageBuffer = await capture()
        let gateState = new GateState("test_vehicle_id", Gate.southEntry)
        await firebaseHelper.updateEntryGateState(gateState, imageBuffer)

        // Restart the echo trigger
        triggerTimeoutId = setInterval(() => {
          trigger.trigger(10, 1) // Set trigger high for 10 microseconds
        }, 1000)
      }
    }
  })

  // Trigger a distance measurement once per second
  triggerTimeoutId = setInterval(() => {
    trigger.trigger(10, 1) // Set trigger high for 10 microseconds
  }, 1000)
}

main()

