<template>
<div>
    <el-page-header @back="navGoBack" :content="`Gate Record: ${gateRecord.vehicleId || '---'}`"></el-page-header>

    <el-form :model="gateRecord" label-width="120px">
      <el-divider content-position="left">Basic Info</el-divider>
      <el-form-item label="License Plate">
        <div class="form-field-plaintext">{{ gateRecord.vehicleId || '---' }}</div>
      </el-form-item>
      <el-form-item label="Phone Number">
        <div class="form-field-plaintext">{{ gateRecord.phoneNumber || '---' }}</div>
      </el-form-item>

      <el-divider content-position="left">Entry / Exit Record</el-divider>
      <el-form-item label="Entry Gate">
        <div class="form-field-plaintext">{{ gateRecord.entryGate || '---' }}</div>
      </el-form-item>
      <el-form-item label="Entry Scan Time">
        <div class="form-field-plaintext">{{ gateRecord.entryScanTime || '---' }}</div>
      </el-form-item>
      <el-form-item label="Entry Confirm Time">
        <div class="form-field-plaintext">{{ gateRecord.entryConfirmTime || '---' }}</div>
      </el-form-item>
      <el-form-item label="Exit Gate">
        <div class="form-field-plaintext">{{ gateRecord.exitGate || '---' }}</div>
      </el-form-item>
      <el-form-item label="Exit Scan Time">
        <div class="form-field-plaintext">{{ gateRecord.exitScanTime || '---' }}</div>
      </el-form-item>
      <el-form-item label="Exit Confirm Time">
        <div class="form-field-plaintext">{{ gateRecord.exitConfirmTime || '---' }}</div>
      </el-form-item>

      <el-divider content-position="left">Payment</el-divider>
      <el-form-item label="Payment Time">
        <div class="form-field-plaintext">{{ gateRecord.paymentTime || '---' }}</div>
      </el-form-item>

      <el-button type="primary" @click="submitForm">Save</el-button>
      <el-button @click="resetForm">Reset</el-button>
    </el-form>
  </div>
</template>

<script>
import moment from 'moment'
import { db } from '@/helpers/firebaseHelper'
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
    submitForm () {
      // FIXME: handle mutation
    },
    async resetForm () {
      await this.$bind('gateRecord', db.collection('gateRecords').doc(this.$route.params.gateRecordId))
    }
  },
  async mounted () {
    await this.resetForm()
  }
}
</script>
