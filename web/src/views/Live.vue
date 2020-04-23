<template>
  <div class='live'>
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
import moment, { now } from 'moment'
import { db, Timestamp } from '@/helpers/firebaseHelper'
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
      gateRecords: []
    }
  },
  firestore: {
    gateRecords: db.collection('gateRecords')
  },
  methods: {
    // addMessage () {
    //   console.log('gate' + this.gate)
    //   console.log('phoneNumber' + this.phoneNumber)
    //   console.log('vehicleId' + this.vehicleId)
    // },
    navPushToGateRecord (row, _, __) {
      this.$router.push(`/gateRecord/${row.id}`)
    },
    async manualEntry () {
      // TODO: fields for license plate, phonenumber & gate dropdown, create gate record
      // UI Ref: https://element.eleme.io/#/en-US/component/dialog see "Form nested Dialog"
      // DB Ref: https://firebase.google.com/docs/database/web/read-and-write#basic_write , use db object imported from helper above
      // remember to do try-catch and use async-await, ref GateRecordEdit cash payment part
      try {
        // await this.$confirm(`Parked Duration: ${moment.duration(moment(this.gateRecord.entryConfirmTime.toDate()).diff(moment())).humanize()}, Amount Due: $`, 'Cash Payment', {
        //   confirmButtonText: 'Received',
        //   cancelButtonText: 'Cancel'
        // })
        // function writeUserData(userId, name, email, imageUrl) {
        // const today = new Date()
        // const date = today.getFullYear() + '-' + (today.getMonth() + 1) + '-' + today.getDate()
        // const time = today.getHours() + ':' + today.getMinutes() + ':' + today.getSeconds()
        // const dateTime = date + ' ' + time
        // console.log(this.$refs.phoneNumber.value)
        // console.log(this.$refs.vehicleId.value)
        // console.log(this.$refs.gate.value)
        // firebase.database().ref('gateRecords/' + this.$route.params.gateRecordId).set({
        //   username: name,
        //   email: email,
        //   profile_picture : imageUrl
        // });
        // firebase.database().ref('gateRecords/' + this.$route.params.gateRecordId).set({
        // await db.ref('gateRecords/' + this.$route.params.gateRecordId).set({
        //   entryConfirmTime: Timestamp.fromDate(new Date()),
        //   entryGate: this.$refs.gate.value,
        //   phoneNumber: this.$refs.phoneNumber.value,
        //   vehicleId: this.$refs.vehicleId.value
        // })
        // await db.collection('gateRecords').doc(this.$route.params.gateRecordId).update({
        //   paymentStatus: 'succeeded',
        //   paymentTime: Timestamp.fromDate(new Date())
        // })
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
