<template>
  <div>
    <!-- <table>
      <th>Peaking Hour</th>
      <tr><td>hi</td></tr>
    </table> -->
    <!-- <h1 align=center>Entry Time</h1> -->
    <entry-line-chart :chartdata="chartdata" :options="options"/>
    <br><br>
    <exit-line-chart :chartdata="chartdata" :options="options"/>
    <br><br>
    <duration-line-chart :chartdata="chartdata" :options="options"/>
    <br><br>
    <parking-hour-line-chart :chartdata="chartdata" :options="options"/>
  </div>
</template>

<script>
import entryLineChart from '@/components/entryLineChart'
import exitLineChart from '@/components/exitLineChart'
import durationLineChart from '@/components/durationLineChart'
import parkingHourLineChart from '@/components/parkingHourLineChart'

export default {
  name: 'Stats',
  components: {
    'entry-line-chart': entryLineChart,
    'exit-line-chart': exitLineChart,
    'duration-line-chart': durationLineChart,
    'parking-hour-line-chart': parkingHourLineChart
  },
  data: () => ({
    loaded: false,
    chartdata: null,
    options: null
  })
}
</script>
