import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import { stripe } from '../common/stripe'

const db = admin.firestore()

async function calculateParkingFeeByGateRecord(gateRecordId: string): Promise<number> {
  // Get gate record
  const docRef = await db.collection('gateRecords').doc(gateRecordId)
  const doc = await docRef.get()
  const docData = doc.data()
  if (!doc.exists || !docData) {
    throw new Error("Gate record does not exist")
  }
  // Get entry time of gate record
  const entryTime = docData.entryScanTime.toDate()
  const paytime = Date.now()
  if (paytime < entryTime) {
    throw new Error("Entry time is in the future")
  }
  // Calculate fee
  let parkingDurationInMinutes = Math.ceil(((paytime - entryTime) / 1000) / 60)
  // FIXME: HARDCODED MINUTES FOR TESTING
  parkingDurationInMinutes = 128
  /// Fee: First 2 hours $20 per hour, then every hour $50
  return Math.ceil(Math.min(120, parkingDurationInMinutes) / 60) * 20 + Math.ceil(Math.max(0, parkingDurationInMinutes - 120) / 60) * 50
}

export const calculateParkingFee = functions.region('asia-east2')
  .https
  .onCall(async (data, context) => {
    interface Parameters {
      gateRecordId: string,
    }
    // check auth
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'unauthenticated')
    }
    // parse params
    const params = data as Parameters
    if (!params.gateRecordId) {
      throw new functions.https.HttpsError('invalid-argument', 'parameter missing')
    }

    try {
      const parkingFee = await calculateParkingFeeByGateRecord(params.gateRecordId)
      return {
        success: true,
        parkingFee: parkingFee
      }
    } catch (error) {
      return {
        success: false,
        erorr: error
      }
    }
})

// Creates Stripe PaymentIntent
export const createPaymentIntent = functions
  .region('asia-east2')
  .https
  .onCall(async (data, context) => {
    interface Parameters {
      gateRecordId: string,
    }
    // check auth
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'unauthenticated')
    }
    // parse params
    const params = data as Parameters
    if (!params.gateRecordId) {
      throw new functions.https.HttpsError('invalid-argument', 'parameter missing')
    }
    try {
      const parkingFee = await calculateParkingFeeByGateRecord(params.gateRecordId)
      const paymentIntent = await stripe.paymentIntents.create({
        amount: parkingFee,
        currency: 'hkd',
      });
      return {
        success: true,
        clientSecret: paymentIntent.client_secret
      }
    } catch (error) {
      return {
        success: false,
        erorr: error
      }
    }
  })