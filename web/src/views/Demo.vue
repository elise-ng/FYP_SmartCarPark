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
      <el-form-item>
        <el-button round type="primary" @click="emulateOccupied">Update IotState</el-button>
      </el-form-item>
      <el-divider content-position="left">4. Parking Space Exit - IoT Device detects vacant</el-divider>
       <el-form-item label="IoT Device ID">
        <el-input v-model="form.iotDeviceId"></el-input>
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
        <el-input v-model="form.entryGate"></el-input>
      </el-form-item>
      <el-form-item label="License Plate">
        <el-input v-model="form.vehicleId"></el-input>
      </el-form-item>
      <el-form-item>
        <el-button round type="primary" @click="emulateExitIotSuccess">Previous record found - Update GateRecord</el-button>
        <el-button round type="warning" @click="emulateExitIotIssue">Plate recognition issue - Create Temp GateRecord</el-button>
      </el-form-item>
      <el-divider content-position="left">6. Park Exit - Kiosk confirmation</el-divider>
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
        vehicleId: '',
        gateRecordId: '',
        phoneNumber: '',
        iotDeviceId: ''
      }
    }
  },
  methods: {
    async emulateEntryIot () {
      console.log()
    },
    async emulateEntryKiosk () {
      console.log()
    },
    async emulateOccupied () {
      console.log()
    },
    async emulateVacant () {
      console.log()
    },
    async emulatePayment () {
      console.log()
    },
    async emulateUnpayment () {
      console.log()
    },
    async emulateExitIotSuccess () {
      console.log()
    },
    async emulateExitIotIssue () {
      console.log()
    },
    async emulateExitKiosk () {
      console.log()
    }
  }
}
</script>
