<template>
  <div class='live'>
    <el-row >
      <vl-map :load-tiles-while-animating="true" :load-tiles-while-interacting="true"
             data-projection="EPSG:4326" style="height: 400px; padding-bottom: 16px">
      <vl-view :zoom.sync="zoom" :center.sync="center" :rotation="rotation" :min-zoom="minZoom" :max-zoom="maxZoom" :extent="extent"></vl-view>
      <vl-layer-tile id="osm">
        <vl-source-osm></vl-source-osm>
      </vl-layer-tile>
      <vl-feature v-for="floor in carParkFloors" v-bind:key="floor.id">
          <vl-geom-polygon :coordinates="[floor.points.map(geopoint => [geopoint.U, geopoint.V])]"/>
          <vl-feature v-for="state in iotStates.filter(state => state.floorId === floor.id)" v-bind:key="state.id">
              <vl-geom-polygon :coordinates="[getParkingCoordinatesFromState(state)]"/>
              <vl-style-box>
                <vl-style-fill :color="getParkingSpaceColor(state)"/>
                <vl-style-stroke :color="[0, 153, 255, 1]"/>
              </vl-style-box>
          </vl-feature>
      </vl-feature>
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
import { computeDestinationPoint } from 'geolib'

export default {
  name: 'Live',
  data () {
    return {
      zoom: 20,
      minZoom: 20,
      maxZoom: 22,
      center: [114.263326, 22.338422],
      extent: [114.263, 22.338, 114.264, 22.339],
      rotation: Math.PI / -2,
      polygon: {
        latlngs: [[47.2263299, -1.6222], [47.21024000000001, -1.6270065], [47.1969447, -1.6136169], [47.18527929999999, -1.6143036], [47.1794457, -1.6098404], [47.1775788, -1.5985107], [47.1676598, -1.5753365], [47.1593731, -1.5521622], [47.1593731, -1.5319061], [47.1722111, -1.5143967], [47.1960115, -1.4841843], [47.2095404, -1.4848709], [47.2291277, -1.4683914], [47.2533687, -1.5116501], [47.2577961, -1.5531921], [47.26828069, -1.5621185], [47.2657179, -1.589241], [47.2589612, -1.6204834], [47.237287, -1.6266632], [47.2263299, -1.6222]],
        color: 'green'
      },
      gateRecords: [],
      carParkFloors: [],
      iotStates: []
    }
  },
  firestore: {
    gateRecords: db.collection('gateRecords'),
    carParkFloors: db.collection('carParkFloors'),
    iotStates: db.collection('iotStates')
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
    },
    getParkingCoordinatesFromState (state) {
      const width = state.widthInMeters || 2.2
      const height = state.heightInMeters || 4.8
      const bearing = state.bearing || 0
      const topLeft = [state.position.U, state.position.V]
      const topRight = computeDestinationPoint(topLeft, width, 90 - bearing)
      const bottomLeft = computeDestinationPoint(topLeft, height, 180 - bearing)
      const bottomRight = computeDestinationPoint(bottomLeft, width, 90 - bearing)
      return [
        topLeft,
        [topRight.longitude, topRight.latitude],
        [bottomRight.longitude, bottomRight.latitude],
        [bottomLeft.longitude, bottomLeft.latitude]
      ]
    },
    getParkingSpaceColor (state) {
      switch (state.state) {
        case 'vacant':
          return '#66bb6a'
        case 'occupied':
          return '#ef5350'
        case 'changing':
          return '#ffee58'
        case 'disabled':
        default:
          return '#bdbdbd'
      }
    }
  }
}
</script>
