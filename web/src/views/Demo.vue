<template>
  <div>
    <el-form :model="form" label-width="200px">
      <el-divider content-position="left">1. Park Entry - Gate IoT Device detects approach</el-divider>
      <el-form-item label="IoT Device ID">
        <el-input v-model="form.entryGate"></el-input>
      </el-form-item>
      <el-form-item label="License Plate">
        <el-input v-model="form.vehicleId"></el-input>
      </el-form-item>
      <el-form-item label="Image GS URL">
        <el-input v-model="form.imageUrl"></el-input>
      </el-form-item>
      <el-form-item>
        <el-button round type="primary" @click="emulateEntryIot">Create GateRecord</el-button>
      </el-form-item>
      <el-divider content-position="left">2. Park Entry - Kiosk confirmation</el-divider>
      <el-form-item label="Gate Record ID">
        <el-input v-model="form.gateRecordId"></el-input>
      </el-form-item>
      <el-form-item label="Phone Number">
        <el-input v-model="form.phoneNumber"></el-input>
      </el-form-item>
      <el-form-item>
        <el-button round type="primary" @click="emulateEntryKiosk">Update GateRecord</el-button>
      </el-form-item>
      <el-divider content-position="left">3. Parking Space Entry - IoT Device detects occupied</el-divider>
       <el-form-item label="IoT Device ID">
        <el-input v-model="form.iotDeviceId"></el-input>
      </el-form-item>
      <el-form-item label="License Plate">
        <el-input v-model="form.vehicleId"></el-input>
      </el-form-item>
      <el-form-item label="Image GS URL">
        <el-input v-model="form.imageUrl"></el-input>
      </el-form-item>
      <el-form-item>
        <el-button round type="primary" @click="emulateOccupied">Update IotState</el-button>
      </el-form-item>
      <el-divider content-position="left">4. Parking Space Exit - IoT Device detects vacant</el-divider>
       <el-form-item label="IoT Device ID">
        <el-input v-model="form.iotDeviceId"></el-input>
      </el-form-item>
      <el-form-item label="Image GS URL">
        <el-input v-model="form.imageUrl"></el-input>
      </el-form-item>
      <el-form-item>
        <el-button round type="primary" @click="emulateVacant">Update IotState</el-button>
      </el-form-item>
      <el-divider content-position="left">5. Payment - Stripe confirms transaction</el-divider>
       <el-form-item label="Gate Record ID">
        <el-input v-model="form.gateRecordId"></el-input>
      </el-form-item>
      <el-form-item>
        <el-button round type="primary" @click="emulatePayment">Pay - Update GateRecord</el-button>
        <el-button round type="danger" @click="emulateUnpayment">Unpay - Update GateRecord</el-button>
      </el-form-item>
      <el-divider content-position="left">6. Park Exit - Gate IoT Device detects approach</el-divider>
      <el-form-item label="IoT Device ID">
        <el-input v-model="form.exitGate"></el-input>
      </el-form-item>
      <el-form-item label="License Plate">
        <el-input v-model="form.vehicleId"></el-input>
      </el-form-item>
      <el-form-item label="Image GS URL">
        <el-input v-model="form.imageUrl"></el-input>
      </el-form-item>
      <el-form-item>
        <el-button round type="primary" @click="emulateExitIotSuccess">Previous record found - Update GateRecord</el-button>
        <el-button round type="warning" @click="emulateExitIotIssue">Plate recognition issue - Create Temp GateRecord</el-button>
      </el-form-item>
      <el-divider content-position="left">7. Park Exit - Kiosk confirmation</el-divider>
      <el-form-item label="Gate Record ID">
        <el-input v-model="form.gateRecordId"></el-input>
      </el-form-item>
      <el-form-item>
        <el-button round type="primary" @click="emulateExitKiosk">Update GateRecord</el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<script>
import { db, Timestamp } from '@/helpers/firebaseHelper'
export default {
  name: 'Demo',
  data () {
    return {
      form: {
        entryGate: '',
        exitGate: '',
        vehicleId: '',
        gateRecordId: '',
        phoneNumber: '',
        iotDeviceId: '',
        imageUrl: ''
      }
    }
  },
  methods: {
    async emulateEntryIot () {
      try {
        console.log('emulateEntryIot')
        const ref = await db.collection('gateRecords').add({
          vehicleId: this.form.vehicleId,
          phoneNumber: null,
          entryGate: this.form.entryGate,
          entryScanTime: Timestamp.fromDate(new Date()),
          entryConfirmTime: null,
          entryImageUrl: this.form.imageUrl,
          exitGate: null,
          exitScanTime: null,
          exitConfirmTime: null,
          exitImageUrl: null,
          paymentStatus: null,
          paymentTime: null
        })
        console.log(`Created gateRecord: ${ref.id}`)
        this.$message.success(`Created gateRecord: ${ref.id}`)
        this.form.gateRecordId = ref.id
      } catch (e) {
        console.error(e)
        this.$message.error(e.message || e.toString())
      }
    },
    async emulateEntryKiosk () {
      try {
        console.log('emulateEntryKiosk')
        await db.collection('gateRecords').doc(this.form.gateRecordId).update({
          phoneNumber: `+852${this.form.phoneNumber}`,
          entryConfirmTime: Timestamp.fromDate(new Date())
        })
        console.log(`Updated gateRecord: ${this.form.gateRecordId}`)
        this.$message.success(`Updated gateRecord: ${this.form.gateRecordId}`)
      } catch (e) {
        console.error(e)
        this.$message.error(e.message || e.toString())
      }
    },
    async emulateOccupied () {
      try {
        console.log('emulateOccupied')
        await db.collection('iotStates').doc(this.form.iotDeviceId).set({
          deviceId: this.form.iotDeviceId,
          state: 'occupied',
          vehicleId: this.form.vehicleId,
          imageUrl: this.form.imageUrl,
          time: Timestamp.fromDate(new Date())
        }, { merge: true })
        console.log(`Upserted iotState: ${this.form.iotDeviceId}`)
        this.$message.success(`Upserted iotState: ${this.form.iotDeviceId}`)
      } catch (e) {
        console.error(e)
        this.$message.error(e.message || e.toString())
      }
    },
    async emulateVacant () {
      try {
        console.log('emulateVacant')
        await db.collection('iotStates').doc(this.form.iotDeviceId).set({
          deviceId: this.form.iotDeviceId,
          state: 'vacant',
          vehicleId: null,
          imageUrl: this.form.imageUrl,
          time: Timestamp.fromDate(new Date())
        }, { merge: true })
        console.log(`Upserted iotState: ${this.form.iotDeviceId}`)
        this.$message.success(`Upserted iotState: ${this.form.iotDeviceId}`)
      } catch (e) {
        console.error(e)
        this.$message.error(e.message || e.toString())
      }
    },
    async emulatePayment () {
      try {
        console.log('emulatePayment')
        await db.collection('gateRecords').doc(this.form.gateRecordId).update({
          paymentStatus: 'succeeded',
          paymentTime: Timestamp.fromDate(new Date())
        })
        console.log(`Updated gateRecord: ${this.form.gateRecordId}`)
        this.$message.success(`Updated gateRecord: ${this.form.gateRecordId}`)
      } catch (e) {
        console.error(e)
        this.$message.error(e.message || e.toString())
      }
    },
    async emulateUnpayment () {
      try {
        console.log('emulateUnpayment')
        await db.collection('gateRecords').doc(this.form.gateRecordId).update({
          paymentStatus: null,
          paymentTime: null
        })
        console.log(`Updated gateRecord: ${this.form.gateRecordId}`)
        this.$message.success(`Updated gateRecord: ${this.form.gateRecordId}`)
      } catch (e) {
        console.error(e)
        this.$message.error(e.message || e.toString())
      }
    },
    async emulateExitIotSuccess () {
      try {
        console.log('emulateExitIotSuccess')
        const query = await db.collection('gateRecords')
          .where('vehicleId', '==', this.form.vehicleId)
          .where('exitScanTime', '==', null)
          .orderBy('entryScanTime', 'asc')
          .limitToLast(1)
          .get()
        if (query.docs.length > 0) {
          console.log('gateRecord Found')
          const ref = query.docs[0].ref
          await ref.update({
            exitGate: this.form.exitGate,
            exitScanTime: Timestamp.fromDate(new Date()),
            exitImageUrl: this.form.imageUrl
          })
          console.log(`Updated gateRecord: ${ref.id}`)
          this.$message.success(`Updated gateRecord: ${ref.id}`)
        } else {
          console.log('gateRecord not found')
          this.$message.error('gateRecord not found: license plate recognition failed?')
        }
      } catch (e) {
        console.error(e)
        this.$message.error(e.message || e.toString())
      }
    },
    async emulateExitIotIssue () {
      try {
        console.log('emulateExitIotIssue')
        const ref = await db.collection('gateRecords').add({
          vehicleId: this.form.vehicleId,
          phoneNumber: null,
          entryGate: null,
          entryScanTime: null,
          entryConfirmTime: null,
          entryImageUrl: null,
          exitGate: this.form.exitGate,
          exitScanTime: Timestamp.fromDate(new Date()),
          exitConfirmTime: null,
          exitImageUrl: this.form.imageUrl,
          paymentStatus: null,
          paymentTime: null
        })
        console.log(`Created gateRecord: ${ref.id}`)
        this.$message.success(`Created gateRecord: ${ref.id}`)
        this.form.gateRecordId = ref.id
      } catch (e) {
        console.error(e)
        this.$message.error(e.message || e.toString())
      }
    },
    async emulateExitKiosk () {
      try {
        console.log('emulateExitKiosk')
        await db.collection('gateRecords').doc(this.form.gateRecordId).update({
          exitConfirmTime: Timestamp.fromDate(new Date())
        })
        console.log(`Updated gateRecord: ${this.form.gateRecordId}`)
        this.$message.success(`Updated gateRecord: ${this.form.gateRecordId}`)
      } catch (e) {
        console.error(e)
        this.$message.error(e.message || e.toString())
      }
    }
  }
}
</script>
