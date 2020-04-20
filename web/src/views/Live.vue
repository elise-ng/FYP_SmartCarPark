<template>
  <div class='live'>
    <el-row >
      <vl-map :load-tiles-while-animating="true" :load-tiles-while-interacting="true"
             data-projection="EPSG:4326" style="height: 400px; padding-bottom: 16px">
      <vl-view :zoom.sync="zoom" :center.sync="center" :rotation.sync="rotation"></vl-view>
      <vl-layer-tile id="osm">
        <vl-source-osm></vl-source-osm>
      </vl-layer-tile>
    </vl-map>
    </el-row>
    <el-row>
      <el-button @click="manualEntry">Manual Entry</el-button>
    </el-row>
    <el-table :data='gateRecords' @row-click='navPushToGateRecord'>
      <el-table-column label='License Plate' prop='vehicleId' sortable></el-table-column>
      <el-table-column label='Entry Gate' prop='entryGate' :formatter='entryGateFormatter' sortable></el-table-column>
      <el-table-column label='Entry Scan Time' prop='entryScanTime' :formatter='entryScanTimeFormatter' sortable></el-table-column>
      <el-table-column label='Exit Gate' prop='exitGate' :formatter='exitGateFormatter' sortable></el-table-column>
      <el-table-column label='Exit Scan Time' prop='exitScanTime' :formatter='exitScanTimeFormatter' sortable></el-table-column>
      <el-table-column label='Phone Number' prop='phoneNumber' :formatter='phoneNumberFormatter' sortable></el-table-column>
      <el-table-column label='Payment' prop='paymentStatus' sortable></el-table-column>
    </el-table>
  </div>
</template>

<script>
import moment from 'moment'
import { db } from '@/helpers/firebaseHelper'

export default {
  name: 'Live',
  data () {
    return {
      zoom: 16,
      center: [114.263270, 22.338616],
      rotation: 0,
      polygon: {
        latlngs: [[47.2263299, -1.6222], [47.21024000000001, -1.6270065], [47.1969447, -1.6136169], [47.18527929999999, -1.6143036], [47.1794457, -1.6098404], [47.1775788, -1.5985107], [47.1676598, -1.5753365], [47.1593731, -1.5521622], [47.1593731, -1.5319061], [47.1722111, -1.5143967], [47.1960115, -1.4841843], [47.2095404, -1.4848709], [47.2291277, -1.4683914], [47.2533687, -1.5116501], [47.2577961, -1.5531921], [47.26828069, -1.5621185], [47.2657179, -1.589241], [47.2589612, -1.6204834], [47.237287, -1.6266632], [47.2263299, -1.6222]],
        color: 'green'
      },
      gateRecords: []
    }
  },
  firestore: {
    gateRecords: db.collection('gateRecords')
  },
  methods: {
    navPushToGateRecord (row, _, __) {
      this.$router.push(`/gateRecord/${row.id}`)
    },
    async manualEntry () {
      // TODO: fields for license plate, phonenumber & gate dropdown, create gate record
      // UI Ref: https://element.eleme.io/#/en-US/component/dialog see "Form nested Dialog"
      // DB Ref: https://firebase.google.com/docs/database/web/read-and-write#basic_write , use db object imported from helper above
      // remember to do try-catch and use async-await, ref GateRecordEdit cash payment part
    },
    entryGateFormatter (row) {
      switch (row.entryGate) {
        case 'northEntry':
          return 'North'
        case 'southEntry':
          return 'South'
        default:
          return row.entryGate
      }
    },
    exitGateFormatter (row) {
      switch (row.exitGate) {
        case 'northExit':
          return 'North'
        case 'southExit':
          return 'South'
        default:
          return row.exitGate
      }
    },
    entryScanTimeFormatter (row) {
      const timeMoment = moment(row.entryScanTime.toDate())
      return row.entryScanTime ? `${timeMoment.format('HH:mm')} (${moment.duration(timeMoment.diff(moment())).humanize(true)})` : ''
    },
    exitScanTimeFormatter (row) {
      const timeMoment = moment(row.entryScanTime.toDate())
      return row.exitScanTime ? `${timeMoment.format('HH:mm')} (${moment.duration(timeMoment.diff(moment())).humanize(true)})` : ''
    },
    phoneNumberFormatter (row) {
      return row.phoneNumber ? row.phoneNumber.replace('+852', '') : ''
    }
  }
}
</script>
