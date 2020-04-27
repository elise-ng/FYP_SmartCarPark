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
              labelString: 'No. of cars',
              fontSize: 14
            }
          }],
          xAxes: [{
            gridLines: {
              display: false
            },
            scaleLabel: {
              display: true,
              labelString: 'Exit Time',
              fontSize: 14
            }
          }]
        },
        legend: {
          display: true
        },
        responsive: true,
        maintainAspectRatio: false,
        title: {
          display: true,
          text: 'Exit Time',
          fontSize: 20
        }
      }
    }
  },
  methods: {
    // then you can add controls to let user change options e.g. change from days to months, then on user interact call loadData() and update your ui
    async loadData () {
      try {
        const lotsExitHour = []
        const hour = { 0: '12am', 1: '1am', 2: '2am', 3: '3am', 4: '4am', 5: '5am', 6: '6am', 7: '7am', 8: '8am', 9: '9am', 10: '10am', 11: '11am', 12: '12pm', 13: '1pm', 14: '2pm', 15: '3pm', 16: '4pm', 17: '5pm', 18: '6pm', 19: '7pm', 20: '8pm', 21: '9pm', 22: '10pm', 23: '11pm' }
        const exitSnapshot = await db
          .collection('iotStateChanges')
          .where('previousState.state', '==', 'occupied')
          .where('newState.state', '==', 'vacant')
          .limit(100)
          .get()
        exitSnapshot.docs.forEach((doc) => { lotsExitHour.push(moment(doc.data().time.toDate()).hours()) })
        const lotsExitHourSorted = Array.from(lotsExitHour).sort((a, b) => (a - b))
        const exitHourUnique = Array.from(new Set(lotsExitHourSorted))
        const exitHourCount = []
        let prev
        for (let i = 0; i < lotsExitHourSorted.length; i++) {
          if (lotsExitHourSorted[i] !== prev) {
            exitHourCount.push(1)
          } else {
            exitHourCount[exitHourCount.length - 1]++
          }
          prev = lotsExitHourSorted[i]
        }
        for (let i = 0; i < 24; i++) {
          if (exitHourUnique[i] !== i) {
            exitHourUnique.splice(i, 0, i)
            exitHourCount.splice(i, 0, 0)
          }
          exitHourUnique[i] = hour[i]
        }
        this.chartdata = {
          // Data to be represented on x-axis
          labels: exitHourUnique,
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
              data: exitHourCount
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
