<template>
  <div class="live">
    <el-row style="padding-bottom: 16px">
      <vl-map
        :load-tiles-while-animating="true"
        :load-tiles-while-interacting="true"
        :default-controls="{rotate: false}"
        data-projection="EPSG:4326"
        style="height: 500px; box-shadow: 0 4px 8px 0 grey"
      >
        <vl-view
          :zoom.sync="zoom"
          :center.sync="center"
          :rotation="rotation"
          :min-zoom="minZoom"
          :max-zoom="maxZoom"
          :extent="extent"
        ></vl-view>
        <vl-layer-tile id="osm">
          <vl-source-osm></vl-source-osm>
        </vl-layer-tile>
        <!-- Floor tile -->
        <div v-if="selectedFloor">
        <vl-feature>
          <vl-geom-polygon
            :coordinates="[selectedFloor.points.map(geopoint => [geopoint.longitude, geopoint.latitude])]"
          />
        </vl-feature>
        <!-- Parking spaces -->
        <vl-layer-vector id="spaces" z-index="999">
          <vl-feature
            v-for="state in iotStates.filter(state => state.floorId === selectedFloor.id)"
            v-bind:key="state.id"
            :id="state.id"
          >
            <vl-geom-polygon :coordinates="[getParkingCoordinatesFromState(state)]" />
            <vl-overlay
              :id="state.id"
              :position="getParkingSpaceCenter(state)"
              positioning="center-center"
            >
              <div
                style="font: 16px; font-weight: bold; user-select: none"
              >{{ state.displayName || state.id.toUpperCase() }}</div>
            </vl-overlay>
            <vl-style-box>
              <vl-style-fill :color="getParkingSpaceColor(state)" />
              <vl-style-stroke :color="[0, 153, 255, 1]" />
              <!-- <vl-style-text :text="state.id.toUpperCase()" font="2em sans-serif"></vl-style-text> -->
            </vl-style-box>
          </vl-feature>
        </vl-layer-vector>
        </div>
        <!-- interactions -->
        <vl-interaction-select v-if="drawType == null" :filter="onParkingSpaceClick"/>
        <!--// interactions -->
      </vl-map>
    </el-row>
    <el-row>
      <el-button @click="dialogFormVisible = true;">Manual Entry</el-button>
    </el-row>

    <el-dialog title="Manual Entry" :visible.sync="dialogFormVisible">
      <el-form :model="form">
        <el-form-item label="Liscense Plate" :label-width="formLabelWidth">
          <el-input v-model="form.vehicleId" autocomplete="off" ref="vehicleId"></el-input>
        </el-form-item>
        <el-form-item label="Phone Number" :label-width="formLabelWidth">
          <el-input v-model="form.phoneNumber" autocomplete="off" ref="phoneNumber"></el-input>
        </el-form-item>
        <el-form-item label="Gate" :label-width="formLabelWidth">
          <el-select v-model="form.gate" placeholder="Please select a gate" ref="gate">
            <el-option label="South Gate" value="south"></el-option>
            <el-option label="North Gate" value="north"></el-option>
          </el-select>
        </el-form-item>
      </el-form>
      <span slot="footer" class="dialog-footer">
        <el-button @click="dialogFormVisible = false">Cancel</el-button>
        <el-button type="primary" @click="manualEntry();dialogFormVisible = false;">Confirm</el-button>
      </span>
    </el-dialog>

    <el-table :data="gateRecords" @row-click="navPushToGateRecord">
      <el-table-column label="License Plate" prop="vehicleId" sortable></el-table-column>
      <el-table-column label="Entry Gate" prop="entryGate" :formatter="entryGateFormatter" sortable></el-table-column>
      <el-table-column
        label="Entry Scan Time"
        prop="entryScanTime"
        :formatter="entryScanTimeFormatter"
        sortable
      ></el-table-column>
      <el-table-column label="Exit Gate" prop="exitGate" :formatter="exitGateFormatter" sortable></el-table-column>
      <el-table-column
        label="Exit Scan Time"
        prop="exitScanTime"
        :formatter="exitScanTimeFormatter"
        sortable
      ></el-table-column>
      <el-table-column
        label="Phone Number"
        prop="phoneNumber"
        :formatter="phoneNumberFormatter"
        sortable
      ></el-table-column>
      <el-table-column label="Payment" prop="paymentStatus" sortable></el-table-column>
    </el-table>
    <div>
      <el-pagination background layout="prev, pager, next" :total="1000"></el-pagination>
    </div>
  </div>
</template>

<script>
import moment, { now } from 'moment'
import { db, Timestamp } from '@/helpers/firebaseHelper'
import { computeDestinationPoint } from 'geolib'
import { findPointOnSurface } from 'vuelayers/lib/ol-ext'
export default {
  name: 'Live',
  data () {
    return {
      dialogFormVisible: false,
      form: {
        vehicleId: '',
        phoneNumber: '',
        gate: ''
      },
      formLabelWidth: '120px',
      zoom: 20.8,
      // minZoom: 20.8,
      minZoom: 0,
      maxZoom: 24,
      center: [114.26337, 22.338422],
      extent: [114.263, 22.338, 114.264, 22.339],
      rotation: Math.PI / -2,
      gateRecords: [],
      carParkFloors: [],
      iotStates: [],
      selectedIotState: undefined,
      selectedFloor: undefined,
      drawType: undefined
    }
  },
  watch: {
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    carParkFloors: function (newCarParkFloors, _) {
      if (!this.selectedFloor) {
        this.selectedFloor = newCarParkFloors[0]
      }
    }
  },
  firestore: {
    gateRecords: db.collection('gateRecords'),
    carParkFloors: db.collection('carParkFloors'),
    iotStates: db.collection('iotStates')
  },
  methods: {
    // addMessage () {
    //   console.log('gate' + this.gate)
    //   console.log('phoneNumber' + this.phoneNumber)
    //   console.log('vehicleId' + this.vehicleId)
    // },
    pointOnSurface: findPointOnSurface,
    navPushToGateRecord (row, _, __) {
      this.$router.push(`/gateRecord/${row.id}`)
    },
    async manualEntry () {
      // TODO: fields for license plate, phonenumber & gate dropdown, create gate record
      // UI Ref: https://element.eleme.io/#/en-US/component/dialog see "Form nested Dialog"
      // DB Ref: https://firebase.google.com/docs/database/web/read-and-write#basic_write , use db object imported from helper above
      // remember to do try-catch and use async-await, ref GateRecordEdit cash payment part
      try {
        await db.collection('gateRecords').add({
          phoneNumber: this.$refs.phoneNumber.value,
          vehicleId: this.$refs.vehicleId.value,
          entryGate: this.$refs.gate.value,
          entryConfirmTime: Timestamp.fromDate(new Date())
        })
        this.$message.success('Record Added Successfully')
      } catch (e) {
        console.error(e)
        this.$message.warning('Cash Payment Cancelled')
      }
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
      console.log(JSON.stringify(row.entryScanTime))
      // console.log(typeof (row.entryScanTime))
      if (!row.entryScanTime) { return '' }
      const timeMoment = moment(row.entryScanTime.toDate())
      return `${timeMoment.format('HH:mm')} (${moment.duration(timeMoment.diff(moment())).humanize(true)})`
    },
    exitScanTimeFormatter (row) {
      if (!row.exitScanTime) { return '' }
      const timeMoment = moment(row.exitScanTime.toDate())
      return `${timeMoment.format('HH:mm')} (${moment.duration(timeMoment.diff(moment())).humanize(true)})`
    },
    phoneNumberFormatter (row) {
      return row.phoneNumber ? row.phoneNumber.replace('+852', '') : ''
    },
    getParkingCoordinatesFromState (state) {
      const width = state.widthInMeters || 2.2
      const height = state.heightInMeters || 4.8
      const bearing = state.bearing || 0
      const topLeft = [state.position.longitude, state.position.latitude]
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
    getParkingSpaceCenter (state) {
      const width = state.widthInMeters || 2.2
      const height = state.heightInMeters || 4.8
      const bearing = state.bearing || 0
      const topLeft = [state.position.longitude, state.position.latitude]
      const center = computeDestinationPoint(topLeft, Math.hypot(width / 2, height / 2), (Math.atan2(height, width) * 180 / Math.PI) + 90 - bearing)
      return [center.longitude, center.latitude]
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
    },
    onParkingSpaceClick (feature) {
      const iotStates = this.iotStates.find((state) => state.deviceId === feature.id_)
      if (iotStates) {
        // TODO: DO STUFF
        console.log(iotStates)
      }
    }
  }
}
</script>
