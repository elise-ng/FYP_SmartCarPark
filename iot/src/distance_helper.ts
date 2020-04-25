import { Gpio } from "pigpio"

// The number of microseconds it takes sound to travel 1cm at 20 degrees celcius
const MICROSECDONDS_PER_CM = 1e6 / 34321
type DistanceCallback = (distanceInCm: number) => Promise<void>

export class DistanceHelper {
    trigger: Gpio
    echo: Gpio
    log: boolean
    intervalInMillis: number

    constructor(intervalInMillis: number = 500, triggerPin: number = 18, echoPin: number = 24, log: boolean = false) {
        this.intervalInMillis = intervalInMillis
        this.trigger = new Gpio(triggerPin, { mode: Gpio.OUTPUT })
        this.echo = new Gpio(echoPin, { mode: Gpio.INPUT, alert: true })
        this.log = log
    }

    async startAndSubscribeDistanceChanges(callback: DistanceCallback) {
        let startTick: number
        let endTick: number

        async function alertHandler (level, tick) {
            if (!startTick && !endTick && level == 1) {
                // console.log(`Received start tick`)
                startTick = tick
            } else if (startTick && !endTick && level == 0) {
                // console.log(`Received end tick`)
                endTick = tick
                let diff = (endTick >> 0) - (startTick >> 0) // Unsigned 32 bit arithmetic
                let dist = diff / 2 / MICROSECDONDS_PER_CM
                // console.log(`Measured Distance: ${dist} cm`)
                if (dist > 2 && dist < 400) { // sanity check, supported range of sensor
                    await callback(dist)
                } else if (dist > 400) {
                    await callback(Infinity)
                }
                startTick = undefined
                endTick = undefined
            } else {
                // console.log(`Unhandled tick: startTick ${startTick}, endTick ${endTick}, level ${level}`)
            }
        }
        // reset level
        this.trigger.digitalWrite(0) 

        // listen to sensor output
        this.echo.addListener('alert', alertHandler)

        function loop(trigger: Gpio, intervalInMillis: number, log: boolean) {
            trigger.trigger(10, 1)
            setTimeout(async () => {
                if (startTick && !endTick) { // did not receive echo
                    if (log) console.log(`Did not receive end tick`)
                    await callback(Infinity)
                    startTick = undefined
                    endTick = undefined
                }
                if (log) console.log(`Loop Trigger`)
                loop(trigger, intervalInMillis, log)
            }, intervalInMillis)
        }
        // first trigger
        if (this.log) console.log(`First Trigger`)
        loop(this.trigger, this.intervalInMillis, this.log)
    }
}
