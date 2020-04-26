<template>
  <div>
    <h1>Parking hour</h1>
    <line-chart v-if="loaded" :chartdata="chartdata" :options="options"/>
    <!-- <h1>Entry Time</h1>
    <line-chart></line-chart>
    <h1>Exit Time</h1>
    <line-chart></line-chart>
    <h1>Parking duration</h1>
    <line-chart></line-chart>
    <h1>Peak hour:</h1> -->
  </div>
</template>

<script>
import LineChart from '@/components/LineChart'
import moment from 'moment'
import { db, Timestamp } from '@/helpers/firebaseHelper'

export default {
  name: 'Stats',
  components: {
    'line-chart': LineChart
  },
  data: () => ({
    loaded: false,
    chartdata: null
  }),
  async mounted () {
    this.loaded = false
    try {
      const snapshot = await db.collection('iotStateChanges').get()
      console.log(JSON.stringify(snapshot))
      // const iotStateChanges = await
      // const previousState = await db.collection('iotStateChange').doc().collection('previousState').get().then(
      //   (data) => {
      //   }
      // )
      //   function (querySnapshot) {
      //   querySnapshot.forEach (function (doc) {
      //     // doc.data() is never undefined for query doc snapshots
      //     console.log(doc.id, '-->', doc.data())
      //   })
      // })
      // const newState = iotStateChanges.doc().collection('newState')
      // const { entryTimeList } = await iotStateChanges.where('previousState/state', '==', 'vacant')
      // .where(iotStateChanges.doc().collection('newState').state, '==', 'occupied')
      // console.log(previousState)
      // console.log(newState)
      // this.chartdata = entryTimeList
      // this.loaded = true
      // const { userlist } = await fetch('/api/userlist')
      // this.chartdata = userlist
      // this.loaded = true
    } catch (e) {
      console.error(e)
    }
  }
}
</script>
