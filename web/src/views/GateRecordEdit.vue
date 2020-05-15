<template>
<div>
    <el-page-header @back="navGoBack" :content="`Gate Record: ${gateRecord ? gateRecord.vehicleId || '---' : '---'}`"></el-page-header>

    <el-form v-if="gateRecord" :model="gateRecord" label-width="200px">
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
      <el-form-item label="Entry Snapshot">
        <div class="form-field-plaintext">
          <el-image :src="signedEntryImageUrl" style="width: 300px"></el-image>
        </div>
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
      <el-form-item label="Exit Snapshot">
        <div class="form-field-plaintext">
          <el-image :src="signedExitImageUrl" style="width: 300px"></el-image>
        </div>
      </el-form-item>
      <el-form-item label="Exit Scan Time">
        <div class="form-field-plaintext">{{ formatTimestamp(gateRecord.exitScanTime) || '---' }}</div>
      </el-form-item>
      <el-form-item label="Exit Confirm Time">
        <div class="form-field-plaintext">{{ formatTimestamp(gateRecord.exitConfirmTime) || '---' }}</div>
      </el-form-item>
      <el-form-item v-if="gateRecord.exitConfirmTime == null">
        <el-button round @click="dialogFormVisible = true">Manual Exit</el-button>
      </el-form-item>

      <el-dialog title="Manual Exit" :visible.sync="dialogFormVisible">
      <el-form :model="form">
        <!-- @submit="checkForm()" -->
        <!-- <span v-if="error">Gate is required</span> -->
        <el-form-item label="Parked Duration" :label-width="formLabelWidth" v-if="gateRecord.paymentStatus !== 'processing' && gateRecord.paymentStatus !== 'succeeded'">
          <span>{{ getParkedDuration () }}</span>
        </el-form-item>
        <el-form-item label="Amount Due" :label-width="formLabelWidth"  v-if="gateRecord.paymentStatus !== 'processing' && gateRecord.paymentStatus !== 'succeeded'">
          <span>{{ getAmountDue () }}</span>
        </el-form-item>
        <el-form-item label="Parked Duration Excceeds" :label-width="formLabelWidth" v-if="gateRecord.paymentTime !== null && getExceedDuration() > 15">
          <span>{{ getExceedDurationString () }}</span>
        </el-form-item>
        <el-form-item label="Amount Owned" :label-width="formLabelWidth" v-if="gateRecord.paymentTime !== null && getExceedDuration() > 15">
          <span>{{ getExceedAmount () }}</span>
        </el-form-item>
        <el-form-item label="Liscense Plate" :label-width="formLabelWidth">
          <span>{{ gateRecord.vehicleId }}</span>
        </el-form-item>
        <el-form-item label="Phone Number" :label-width="formLabelWidth">
          <span>{{ gateRecord.phoneNumber }}</span>
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
        <el-button type="primary" @click="manualExit();dialogFormVisible = false;" v-if="gateRecord.paymentStatus !== 'processing' && gateRecord.paymentStatus !== 'succeeded'">Paid and Confirm</el-button>
        <el-button type="primary" @click="manualExit();dialogFormVisible = false;" v-else="">Confirm</el-button>
      </span>
    </el-dialog>

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
import { db, Timestamp, storage } from '@/helpers/firebaseHelper'
export default {
  name: 'GateRecordEdit',
  data () {
    return {
      dialogFormVisible: false,
      form: {
        vehicleId: '',
        phoneNumber: '',
        gate: '',
        error: false
      },
      formLabelWidth: '120px',
      gateRecord: {}
    }
  },
  asyncComputed: {
    async signedEntryImageUrl () {
      try {
        const gsUrl = this.gateRecord.entryImageUrl
        return gsUrl ? await storage.refFromURL(gsUrl).getDownloadURL() : null
      } catch (e) {
        this.$message.error(e.message || e.toString())
      }
    },
    async signedExitImageUrl () {
      try {
        const gsUrl = this.gateRecord.exitImageUrl
        return gsUrl ? await storage.refFromURL(gsUrl).getDownloadURL() : null
      } catch (e) {
        this.$message.error(e.message || e.toString())
      }
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
    // checkForm () {
    //   this.error = (this.gate !== null)
    //   return this.error
    // },
    formatTimestamp (timestamp) {
      if (!timestamp) { return '---' }
      const timestampMoment = moment(timestamp.toDate())
      return `${timestampMoment.format('YYYY-MM-DD HH:mm')} (${this.getDurationToNow(timestampMoment, true)})`
    },
    getDurationToNow (fromMoment, withSuffix) {
      return moment.duration(fromMoment.diff(moment())).humanize(withSuffix)
    },
    getParkedDuration () {
      if (!this.gateRecord || !this.gateRecord.entryConfirmTime) return ''
      return moment.duration(moment(this.gateRecord.entryConfirmTime.toDate()).diff(moment())).humanize()
    },
    getAmountDue () {
      // TODO:Change it to the formula
      return '$100'
    },
    getExceedDuration () {
      if (!this.gateRecord || !this.gateRecord.paymentTime) return ''
      return moment(moment()).diff(this.gateRecord.paymentTime.toDate(), 'minutes')
    },
    getExceedDurationString () {
      if (!this.gateRecord || !this.gateRecord.paymentTime) return ''
      return moment.duration(moment().diff(moment(this.gateRecord.paymentTime.toDate()))).humanize()
    },
    getExceedAmount () {
      // TODO: Change it to the formula
      return 'HKD100'
    },
    async cashPayment () {
      console.log('cashPayment')
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
      try {
        if (this.gateRecord.paymentStatus !== 'processing' || this.gateRecord.paymentStatus !== 'succeeded') {
          await db.collection('gateRecords').doc(this.$route.params.gateRecordId).update({
            paymentStatus: 'succeeded',
            paymentTime: Timestamp.fromDate(new Date()),
            exitGate: this.$refs.gate.value,
            exitConfirmTime: Timestamp.fromDate(new Date())
          })
        } else {
          await db.collection('gateRecords').doc(this.$route.params.gateRecordId).update({
            exitGate: this.$refs.gate.value,
            exitConfirmTime: Timestamp.fromDate(new Date())
          })
        }
        this.$message.success('Record Added Successfully')
      } catch (e) {
        console.error(e)
        this.$message.warning('Gate input required')
      }
    }
  },
  async mounted () {
    await this.resetForm()
  }
}
</script>
