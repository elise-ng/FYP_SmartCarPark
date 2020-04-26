<template>
  <div class="stats">
    <h1>This is the stats view</h1>
    <div class="Chart">
      <h1 style="text-align:center;">Linechart</h1>
        <LineChart/>
      <!-- <line-chart :chartdata="chartData" :options="chartOptions"/> -->
    </div>
    <!-- <line-chart :chartdata="chartdata" :options="options"/> -->
    <!-- v-if="loaded"  -->
  </div>
</template>

<script>
// import VueCharts from 'vue-chartjs'
import { LineChart } from '../components/LineChart.vue'
// import { Line, mixins, generateChart } from 'vue-chartjs'
import { db, Timestamp } from '@/helpers/firebaseHelper'
// const { reactiveProp } = mixins
// const CustomLine = generateChart('line-chart', 'line')
export default {
  name: 'Stats',
  components: {
    LineChart
  },
  data () {
    return {
      chartData: {
        Books: 24,
        Magazine: 30,
        Newspapers: 10
      }
    }
  },
  // extends: Line,
  // mixins: [reactiveProp],
  // props: {
  //   chartdata: {
  //     type: Object,
  //     default: null
  //   },
  //   options: {
  //     type: Object,
  //     default: null
  //   }
  // },
  // data: () => ({
  //   chartdata: {
  //     labels: ['January', 'February'],
  //     datasets: [
  //       {
  //         label: 'Data One',
  //         backgroundColor: '#f87979',
  //         data: [40, 20]
  //       }
  //     ]
  //   },
  //   options: {
  //     responsive: true,
  //     maintainAspectRatio: false
  //   }
  // }),
  // mounted () {
  //   this.renderChart(this.chartdata, this.options)
  // },
  // data: () => ({
  //   loaded: false,
  //   chartdata: null
  // }),
  // async mounted () {
  //   this.loaded = false
  //   try {
  //     // const { userlist } = await fetch('/api/userlist')
  //     // this.chartdata = userlist
  //     // this.loaded = true
  //   } catch (e) {
  //     console.error(e)
  //   }
  // }
}
</script>
