<script>
import { Line } from 'vue-chartjs'
import moment from 'moment'
import { db, Timestamp } from '@/helpers/firebaseHelper'

export default {
  extends: Line,
  data () {
    return {
      chartdata: {
        type: Object,
        default: null
      },
      // Chart.js options that controls the appearance of the chart
      options: {
        scales: {
          yAxes: [{
            ticks: {
              beginAtZero: true
            },
            gridLines: {
              display: true
            },
            scaleLabel: {
              display: true,
              labelString: 'No. of cars'
            }
          }],
          xAxes: [{
            gridLines: {
              display: false
            }
            // ,
            // scaleLabel: {
            //   display: true,
            //   labelString: 'Parking Time',
            //   fontSize: 13
            // }
          }]
        },
        legend: {
          display: true
        },
        responsive: true,
        maintainAspectRatio: false,
        title: {
          display: true,
          text: 'Parking Time',
          fontSize: 20
        }
      }
    }
  },
  methods: {
    // then you can add controls to let user change options e.g. change from days to months, then on user interact call loadData() and update your ui
    async loadData () {
      try {
        const lots = {}
        const parkingHour = []
        const i = 1
        const hour = { 0: '12am', 1: '1am', 2: '2am', 3: '3am', 4: '4am', 5: '5am', 6: '6am', 7: '7am', 8: '8am', 9: '9am', 10: '10am', 11: '11am', 12: '12pm', 13: '1pm', 14: '2pm', 15: '3pm', 16: '4pm', 17: '5pm', 18: '6pm', 19: '7pm', 20: '8pm', 21: '9pm', 22: '10pm', 23: '11pm' }
        const entrySnapshot = await db
          .collection('iotStateChanges')
          .where('previousState.state', '==', 'vacant')
          .where('newState.state', '==', 'occupied')
          .orderBy('time')
          .limit(100)
          .get()
        entrySnapshot.docs.forEach((doc) => { Object.prototype.hasOwnProperty.call(lots, doc.data().deviceId) ? lots[doc.data().deviceId].push(doc.data()) : lots[doc.data().deviceId] = [doc.data()] }) // Save entry snapshots to lots according to device id
        // entrySnapshot.docs.forEach((doc) => { lotsEntryTime.push(moment(doc.data().time.toDate()).hours()) }) // get entry hour
        const exitSnapshot = await db
          .collection('iotStateChanges')
          .where('previousState.state', '==', 'occupied')
          .where('newState.state', '==', 'vacant')
          .orderBy('time')
          .limit(100)
          .get()
        exitSnapshot.docs.forEach((doc) => { Object.prototype.hasOwnProperty.call(lots, doc.data().deviceId) ? lots[doc.data().deviceId].push(doc.data()) : lots[doc.data().deviceId] = [doc.data()] }) // Save exit snapshots to lots according to device id
        Object.keys(lots).forEach(element => {
          lots[element].forEach(elem => {
            Array.from(lots[element]).sort((a, b) => (a.time - b.time)) // Sort time in each deviceId
          })
        })
        Object.keys(lots).forEach(element => {
          // for (let y = 0; y < lots[element].length; y++) {
          //   console.log(lots[element][y].deviceId)
          //   console.log(lots[element][y].previousState.state)
          // }
          for (let i = 0; i < lots[element].length; i += 2) {
            const entryRecord = lots[element][i]
            const exitRecord = lots[element][i + 1]
            if ((entryRecord && exitRecord) && (entryRecord.previousState.state !== exitRecord.previousState.state)) {
              // console.log(moment(entryRecord.time.toDate()))
              // console.log(moment(exitRecord.time.toDate()))
              const entryHour = moment(entryRecord.time.toDate()).hours()
              const exitHour = moment(exitRecord.time.toDate()).hours()
              const totalHour = exitHour - entryHour
              if (totalHour === 0) {
                parkingHour.push(entryHour)
              } else if (totalHour > 0) {
                while (i <= totalHour) {
                  parkingHour.push(entryHour + i)
                  i++
                }
                parkingHour.push(entryHour)
              }
            }
          }
        })
        const parkingHourSorted = parkingHour.sort((a, b) => (a - b))
        const parkingHourUnique = Array.from(new Set(parkingHourSorted))
        const parkingHourCount = []
        let prev
        // Count no. of cars in each entry hour
        for (let i = 0; i < parkingHourSorted.length; i++) {
          if (parkingHourSorted[i] !== prev) {
            parkingHourCount.push(1)
          } else {
            parkingHourCount[parkingHourCount.length - 1]++
          }
          prev = parkingHourSorted[i]
        }
        for (let i = 0; i < 24; i++) {
          if (parkingHourUnique[i] !== i) {
            parkingHourUnique.splice(i, 0, i) // Add i to parkingHourUnique if no car is parking in this hour
            parkingHourCount.splice(i, 0, 0) // Add 0 to parkingHourCount if no car is parking in this hour
          }
          parkingHourUnique[i] = hour[i] // Convert 24 hour to 12 hour format
        }
        this.chartdata = {
          // Data to be represented on x-axis
          labels: parkingHourUnique,
          datasets: [
            {
              label: 'No. of cars',
              backgroundColor: 'rgba(50, 115, 220, 0.5)',
              pointBackgroundColor: 'white',
              borderColor: 'rgba(50, 115, 220, 0.5)',
              borderWidth: 1,
              pointBorderColor: '#99c5ff',
              pointRadius: 4,
              // Data to be represented on y-axis
              data: parkingHourCount
            }
          ]
        }
        this.renderChart(this.chartdata, this.options)
      } catch (e) {
        console.error(e)
      }
    }
  },
  mounted () {
    this.loadData()
  }
}
</script>

<style>
</style>
