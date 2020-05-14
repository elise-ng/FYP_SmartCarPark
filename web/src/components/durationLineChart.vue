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
            },
            scaleLabel: {
              display: true,
              labelString: 'Parking Duration (Nearest hours)',
              fontSize: 13
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
          text: 'Parking Duration',
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
        let duration = []
        const entrySnapshot = await db
          .collection('iotStateChanges')
          .where('previousState.state', '==', 'vacant')
          .where('newState.state', '==', 'occupied')
          .where('time', '>=', Timestamp.fromDate(moment().startOf('month').toDate()))
          .orderBy('time')
          // .limit(100)
          .get()
        entrySnapshot.docs.forEach((doc) => { Object.prototype.hasOwnProperty.call(lots, doc.data().deviceId) ? lots[doc.data().deviceId].push(doc.data()) : lots[doc.data().deviceId] = [doc.data()] }) // Save entry snapshots to lots according to device id
        const exitSnapshot = await db
          .collection('iotStateChanges')
          .where('previousState.state', '==', 'occupied')
          .where('newState.state', '==', 'vacant')
          .where('time', '>=', Timestamp.fromDate(moment().startOf('month').toDate()))
          .orderBy('time')
          // .limit(100)
          .get()
        exitSnapshot.docs.forEach((doc) => { Object.prototype.hasOwnProperty.call(lots, doc.data().deviceId) ? lots[doc.data().deviceId].push(doc.data()) : lots[doc.data().deviceId] = [doc.data()] }) // Save exit snapshots to lots according to device id
        Object.keys(lots).forEach(element => {
          lots[element] = lots[element].sort((a, b) => (moment(a.time.toDate()).valueOf() - moment(b.time.toDate().valueOf())))
        })
        Object.keys(lots).forEach(element => {
          for (let i = 0; i < lots[element].length; i += 2) {
            const entryRecord = lots[element][i]
            const exitRecord = lots[element][i + 1]
            if ((entryRecord && exitRecord) && (entryRecord.previousState.state !== exitRecord.previousState.state)) {
              const timeDiff = moment.duration(moment(exitRecord.time.toDate()).diff(moment(entryRecord.time.toDate())))
              if (timeDiff.asHours() > 0) duration.push(Math.round(moment.duration(timeDiff).asHours()))
            }
          }
        })
        duration = duration.filter(duration => duration !== 0)
        duration = duration.sort((a, b) => (a - b))
        const durationUnique = Array.from(new Set(duration))
        const durationCount = []
        let prev
        for (let i = 0; i < duration.length; i++) { // Count the unique duration hour
          if (duration[i] !== prev) {
            durationCount.push(1)
          } else {
            durationCount[durationCount.length - 1]++
          }
          prev = duration[i]
        }
        this.chartdata = {
          // Data to be represented on x-axis
          labels: durationUnique,
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
              data: durationCount
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
