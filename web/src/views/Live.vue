<template>
  <div class='live'>
    <el-table :data='gateRecords' @row-click='navPushToGateRecord'>
      <el-table-column label='License Plate' prop='vehicleId' sortable></el-table-column>
      <el-table-column label='Entry Gate' prop='entryGate' :formatter='entryGateFormatter' sortable></el-table-column>
      <el-table-column label='Entry Scan Time' prop='entryScanTime' :formatter='entryScanTimeFormatter' sortable></el-table-column>
      <el-table-column label='Exit Gate' prop='exitGate' :formatter='exitGateFormatter' sortable></el-table-column>
      <el-table-column label='Exit Scan Time' prop='exitScanTime' :formatter='exitScanTimeFormatter' sortable></el-table-column>
      <el-table-column label='Phone Number' prop='phoneNumber' :formatter='phoneNumberFormatter' sortable></el-table-column>
      <el-table-column label='Payment' prop='paymentTime' :formatter='paymentFormatter' sortable></el-table-column>
    </el-table>
  </div>
</template>

<script>
import moment from 'moment'
import { db } from '@/helpers/dbHelper.js'
export default {
  name: 'Live',
  data () {
    return {
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
      return row.entryScanTime ? moment(row.entryScanTime.toDate()).format('HH:mm') : ''
    },
    exitScanTimeFormatter (row) {
      return row.exitScanTime ? moment(row.exitScanTime.toDate()).format('HH:mm') : ''
    },
    phoneNumberFormatter (row) {
      return row.phoneNumber ? row.phoneNumber.replace('+852', '') : ''
    },
    paymentFormatter (row) {
      if (!row.paymentTime) { return 'Unpaid' }
      const paymentMoment = moment(row.paymentTime.toDate())
      if (!paymentMoment.isValid()) {
        return 'Unpaid'
      } else if (!row.exitScanTime && moment().isAfter(paymentMoment.add(5, 'minutes'))) {
        return 'Overtime'
      } else {
        return 'Paid'
      }
    }
  }
}
</script>
