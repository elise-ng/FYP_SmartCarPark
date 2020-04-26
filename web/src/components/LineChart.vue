<script>
import { Line } from 'vue-chartjs'
import moment from 'moment'
import { db, Timestamp } from '@/helpers/firebaseHelper'

export default {
  extends: Line,
  data () {
    return {
      chartdata: {
        // Data to be represented on x-axis
        type: Object,
        default: null
        // labels: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
        // datasets: [
        //   {
        //     label: 'Data One',
        //     backgroundColor: '#f87979',
        //     pointBackgroundColor: 'white',
        //     borderWidth: 1,
        //     pointBorderColor: '#249EBF',
        //     // Data to be represented on y-axis
        //     data: [40, 20, 30, 50, 90, 10, 20, 40, 50, 70, 90, 100]
        //   }
        // ]
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
            }
          }],
          xAxes: [{
            gridLines: {
              display: false
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
          text: 'Parking hours'
        }
      }
    }
  },
  mounted () {
    this.renderChart(this.chartdata, this.options)
  }
}
</script>

<style>
</style>
