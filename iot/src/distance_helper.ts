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
                startTick = tick
            } else if (startTick && !endTick && level == 0) {
                endTick = tick
                let diff = (endTick >> 0) - (startTick >> 0) // Unsigned 32 bit arithmetic
                let dist = diff / 2 / MICROSECDONDS_PER_CM
                if (this.log) console.log(`Measured Distance: ${dist} cm`)
                await callback(dist)
            }
        }
        // reset level
        this.trigger.digitalWrite(0) 

        // listen to sensor output
        this.echo.addListener('alert', alertHandler)

        function loop(trigger: Gpio, intervalInMillis: number) {
            trigger.trigger(10, 1)
            setTimeout(async () => {
                if (!endTick) { // did not receive echo
                    await callback(Infinity)
                    startTick = undefined
                    endTick = undefined
                }
                loop(trigger, intervalInMillis)
            }, intervalInMillis)
        }
        // first trigger
        loop(this.trigger, this.intervalInMillis)
    }
}
