<template>
<div>
    <el-page-header @back="navGoBack" :content="`Gate Record: ${gateRecord ? gateRecord.vehicleId || '---' : '---'}`"></el-page-header>

    <el-form v-if="gateRecord" :model="gateRecord" label-width="120px">
      <el-divider content-position="left">Basic Info</el-divider>
      <el-form-item label="License Plate">
        <el-input v-model="gateRecord.vehicleId"></el-input>
      </el-form-item>
      <el-form-item label="Phone Number">
        <el-input v-model="gateRecord.phoneNumber"></el-input>
      </el-form-item>

      <el-divider content-position="left">Entry / Exit Record</el-divider>
      <el-form-item label="Entry Gate">
        <div class="form-field-plaintext">{{ gateRecord.entryGate || '---' }}</div>
      </el-form-item>
      <el-form-item label="Entry Scan Time">
        <div class="form-field-plaintext">{{ formatTimestamp(gateRecord.entryScanTime) || '---' }}</div>
      </el-form-item>
      <el-form-item label="Entry Confirm Time">
        <div class="form-field-plaintext">{{ formatTimestamp(gateRecord.entryConfirmTime) || '---' }}</div>
      </el-form-item>
      <el-form-item label="Exit Gate">
        <div class="form-field-plaintext">{{ gateRecord.exitGate || '---' }}</div>
      </el-form-item>
      <el-form-item label="Exit Scan Time">
        <div class="form-field-plaintext">{{ formatTimestamp(gateRecord.exitScanTime) || '---' }}</div>
      </el-form-item>
      <el-form-item label="Exit Confirm Time">
        <div class="form-field-plaintext">{{ formatTimestamp(gateRecord.exitConfirmTime) || '---' }}</div>
      </el-form-item>
      <el-form-item v-if="gateRecord.paymentStatus !== 'processing' && gateRecord.paymentStatus !== 'succeeded'">
        <el-button round @click="cashPayment">Manual Exit</el-button>
      </el-form-item>

      <el-divider content-position="left">Payment</el-divider>
      <el-form-item label="Payment Status">
        <div class="form-field-plaintext">{{ gateRecord.paymentStatus || '---' }}</div>
      </el-form-item>
      <el-form-item label="Payment Time">
        <div class="form-field-plaintext">{{ formatTimestamp(gateRecord.paymentTime) || '---' }}</div>
      </el-form-item>
      <el-form-item v-if="gateRecord.paymentStatus !== 'processing' && gateRecord.paymentStatus !== 'succeeded'">
        <el-button round @click="cashPayment">Cash Payment</el-button>
      </el-form-item>

      <el-button type="primary" @click="submitForm">Save</el-button>
      <el-button @click="resetForm">Reset</el-button>
    </el-form>
  </div>
</template>

<script>
import moment from 'moment'
import { db, Timestamp } from '@/helpers/firebaseHelper'
export default {
  name: 'GateRecordEdit',
  data () {
    return {
      gateRecord: {}
    }
  },
  methods: {
    navGoBack () {
      this.$router.go(-1)
    },
    async submitForm () {
      try {
        await db.collection('gateRecords').doc(this.$route.params.gateRecordId).set(this.gateRecord)
        this.$message.success('Record Updated')
      } catch (e) {
        this.$message.error(e.message || e.toString())
      }
    },
    async resetForm () {
      try {
        await this.$bind('gateRecord', db.collection('gateRecords').doc(this.$route.params.gateRecordId))
        this.$message.success('Form Resetted')
      } catch (e) {
        this.$message.error(e.message || e.toString())
      }
    },
    formatTimestamp (timestamp) {
      if (!timestamp) { return '---' }
      const timestampMoment = moment(timestamp.toDate())
      return `${timestampMoment.format('YYYY-MM-DD HH:mm')} (${this.getDurationToNow(timestampMoment, true)})`
    },
    getDurationToNow (fromMoment, withSuffix) {
      return moment.duration(fromMoment.diff(moment())).humanize(withSuffix)
    },
    async cashPayment () {
      try {
        // TODO: get amount from cloud function
        await this.$confirm(`Parked Duration: ${moment.duration(moment(this.gateRecord.entryConfirmTime.toDate()).diff(moment())).humanize()}, Amount Due: $`, 'Cash Payment', {
          confirmButtonText: 'Received',
          cancelButtonText: 'Cancel'
        })
        await db.collection('gateRecords').doc(this.$route.params.gateRecordId).update({
          paymentStatus: 'succeeded',
          paymentTime: Timestamp.fromDate(new Date())
        })
        this.$message.success('Cash Payment Success')
      } catch (e) {
        console.error(e)
        this.$message.warning('Cash Payment Cancelled')
      }
    },
    async manualExit () {
      // TODO: allow selection of exitGate, check if payment succeed & payment time not exceed 15 min
      // DB Ref: see cashPayment above
      // remember to do try-catch and use async-await
    }
  },
  async mounted () {
    await this.resetForm()
  }
}
</script>
