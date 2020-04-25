import { Gpio } from "pigpio"

// The number of microseconds it takes sound to travel 1cm at 20 degrees celcius
const MICROSECDONDS_PER_CM = 1e6 / 34321
type DistanceCallback = (distanceInCm: number) => Promise<void>

export class DistanceHelper {
    trigger: Gpio
    echo: Gpio
    log: boolean
    intervalInMillis: number
    triggerTimeoutId: NodeJS.Timeout

    constructor(intervalInMillis: number = 500, triggerPin: number = 18, echoPin: number = 24, log: boolean = false) {
        this.intervalInMillis = intervalInMillis
        this.trigger = new Gpio(triggerPin, { mode: Gpio.OUTPUT })
        this.echo = new Gpio(echoPin, { mode: Gpio.INPUT, alert: true })
        this.log = log
    }

    async startAndSubscribeDistanceChanges(callback: DistanceCallback) {
        let startTick: number
        let shouldIgnoreEvents: boolean = false 
        this.trigger.digitalWrite(0) // Make sure trigger is low
        this.echo.on('alert', async (level, tick) => {
            if (shouldIgnoreEvents) return
            if (!startTick && level == 1) {
                startTick = tick
            } else if (startTick && level == 0) {
                let endTick = tick
                let diff = (endTick >> 0) - (startTick >> 0) // Unsigned 32 bit arithmetic
                let dist = diff / 2 / MICROSECDONDS_PER_CM
                if(this.log) {
                    console.log(`Measured Distance: ${dist} cm`)
                }
                this.pause()
                shouldIgnoreEvents = true
                await callback(dist)
                startTick = undefined
                shouldIgnoreEvents = false
                this.resume()
            }
        })
        this.resume()
    }

    resume() {
        // Trigger a distance measurement once per second
        this.triggerTimeoutId = setInterval(() => {
            this.trigger.trigger(10, 1) // Set trigger high for 10 microseconds
        }, this.intervalInMillis)
    }

    pause() {
        clearInterval(this.triggerTimeoutId)
    }
}