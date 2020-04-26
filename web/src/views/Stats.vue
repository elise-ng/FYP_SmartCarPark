<template>
  <div>
    <h1>This is the stats view</h1>
    <line-chart></line-chart>
  </div>
</template>

<script>
import LineChart from '@/components/LineChart'

export default {
  name: 'Stats',
  components: {
    'line-chart': LineChart
  }
}
</script>
