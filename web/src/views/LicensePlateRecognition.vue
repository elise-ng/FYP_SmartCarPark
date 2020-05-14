<template>
  <div>
    <el-table :data="iotStateChanges">
      <el-table-column label="Device" prop="newState.deviceId"></el-table-column>
      <el-table-column label="Time" prop="newState.time" :formatter="timeFormatter"></el-table-column>
      <el-table-column label="Image" prop="newState.imageUrl">
        <template slot-scope="scope">
          <el-image :src="imageUrlMap[scope.row.newState.imageUrl]" style="width: 300px"></el-image>
        </template>
      </el-table-column>
      <el-table-column label="License Plate" prop="newState.vehicleId"></el-table-column>
    </el-table>
  </div>
</template>

<script>
import moment from 'moment'
import { db, storage } from '@/helpers/firebaseHelper'
export default {
  name: 'LicensePlateRecognition',
  data () {
    return {
      iotStateChanges: {}
    }
  },
  asyncComputed: {
    async imageUrlMap () {
      const output = {}
      for (const row of this.iotStateChanges) {
        if (row.newState.imageUrl) {
          output[row.newState.imageUrl] = await this.getImageUrl(row.newState.imageUrl)
        }
        console.log(row)
      }
      return output
    }
  },
  methods: {
    getData () {
      this.$bind('iotStateChanges', db.collection('iotStateChanges').where('newState.state', '==', 'occupied').orderBy('time', 'desc').limit(100))
    },
    timeFormatter (row) {
      if (!row.newState.time) { return '-' }
      const timeMoment = moment(row.newState.time.toDate())
      return timeMoment.format('YYYY-MM-DD HH:mm')
    },
    async getImageUrl (gsUrl) {
      try {
        return gsUrl ? await storage.refFromURL(gsUrl).getDownloadURL() : null
      } catch (e) {
        this.$message.error(e.message || e.toString())
      }
    }
  },
  mounted () {
    this.getData()
  }
}
</script>
