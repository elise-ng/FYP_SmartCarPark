import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import { stripe } from '../common/stripe'

const db = admin.firestore()

const normalHourFee = 20
const busyHourFee = 50

interface ParkingInvoice {
  total: number
  durationInMinutes: number
  license: string
  items: Array<object>
}

// Calculate parking fees and generate invoice
async function calculateParkingInvoice(gateRecordId: string): Promise<ParkingInvoice> {
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
  /// Fee: First 2 hours $20 per hour, then every hour $50
  const roundedUpParkingHours = Math.ceil(parkingDurationInMinutes / 60)
  const numberOfNormalHours = Math.min(roundedUpParkingHours, 2)
  const numberOfBusyHours = Math.max(roundedUpParkingHours - 2, 0)
  const normalSubtotal = numberOfNormalHours * normalHourFee
  const busySubtotal = numberOfBusyHours * busyHourFee
  const total = normalSubtotal + busySubtotal

  return {
    total: total,
    license: docData.vehicleId,
    durationInMinutes: parkingDurationInMinutes,
    items: [
      {
        name: "First two hours",
        quantity: numberOfNormalHours,
        fee: normalHourFee,
        subtotal: normalSubtotal
      },
      {
        name: "Third hour and thereafter",
        quantity: numberOfBusyHours,
        fee: busyHourFee,
        subtotal: busySubtotal
      }
    ]
  }
}

// Get Parking Invoice
export const getParkingInvoice = functions.region('asia-east2')
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
      const invoice = await calculateParkingInvoice(params.gateRecordId)
      return {
        success: true,
        invoice: invoice
      }
    } catch (error) {
      throw new functions.https.HttpsError('invalid-argument', error)
    }
  })

// Get Stripe Ephemeral Key
export const getEphemeralKey = functions
  .region('asia-east2')
  .https
  .onCall(async (data, context) => {
    interface Parameters {
      stripeApiVersion: string,
    }
    // check auth
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'unauthenticated')
    }
    // parse params
    const params = data as Parameters
    if (!params.stripeApiVersion) {
      throw new functions.https.HttpsError('invalid-argument', 'parameter missing')
    }
    const docRef = await db.collection('userRecords').doc(context.auth.uid)
    const doc = await docRef.get()
    const docData = doc.data()
    if (!doc.exists || !docData) {
      throw new functions.https.HttpsError('invalid-argument', 'User record does not exist')
    }

    const key = await stripe.ephemeralKeys.create({ customer: docData.stripe_customerId }, { stripe_version: params.stripeApiVersion })
    return {
      success: true,
      key: key
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
      const userRecord = await db.collection('userRecords').doc(context.auth.uid).get()
      const userRecordData = userRecord.data()
      if (!userRecord.exists || !userRecordData) {
        throw new Error("User record does not exist")
      }
      const customerId = userRecordData.stripe_customerId;
      const invoice = await calculateParkingInvoice(params.gateRecordId) // Stripe uses minimum amount as unit
      const parkingFeeTotal = invoice.total * 100
      const paymentIntent = await stripe.paymentIntents.create({
        amount: parkingFeeTotal,
        currency: 'hkd',
        customer: customerId,
        payment_method_types: ['card'],
        metadata: {
          gateRecordId: params.gateRecordId,
        },
      });
      return {
        success: true,
        clientSecret: paymentIntent.client_secret,
        invoice: invoice,
      }
    } catch (error) {
      throw new functions.https.HttpsError('invalid-argument', error)
    }
  })

// Creates Stripe Payment Source (For Alipay and WechatPay)
export const createPaymentSource = functions
  .region('asia-east2')
  .https
  .onCall(async (data, context) => {
    interface Parameters {
      type: string,
      gateRecordId: string,
    }
    // check auth
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'unauthenticated')
    }
    // parse params
    const params = data as Parameters
    if (!params.type || !params.gateRecordId) {
      throw new functions.https.HttpsError('invalid-argument', 'parameter missing')
    }

    if (params.type !== 'alipay' && params.type !== 'wechat') {
      throw new functions.https.HttpsError('invalid-argument', 'Invalid payment type')
    }

    try {
      const userRecord = await db.collection('userRecords').doc(context.auth.uid).get()
      const userRecordData = userRecord.data()
      if (!userRecord.exists || !userRecordData) {
        throw new Error("User record does not exist")
      }
      const customerId = userRecordData.stripe_customerId;
      const invoice = await calculateParkingInvoice(params.gateRecordId) // Stripe uses minimum amount as unit
      const parkingFeeTotal = invoice.total * 100
      let sourceObject
      if(params.type === 'alipay') {
        sourceObject = {
          type: params.type,
          amount: parkingFeeTotal,
          currency: 'hkd',
          metadata: {
            customer: customerId,
            gateRecordId: params.gateRecordId,
          },
          redirect: {
            return_url: 'smartcarpark://safepay/',
          },
        }  
      } else if (params.type === 'wechat') {
        sourceObject = {
          type: params.type,
          amount: parkingFeeTotal,
          currency: 'hkd',
          metadata: {
            customer: customerId,
            gateRecordId: params.gateRecordId,
          },
        }  
      }

      const paymentSource = await stripe.sources.create(sourceObject);
      return {
        success: true,
        source: paymentSource,
        invoice: invoice,
      }
    } catch (error) {
      throw new functions.https.HttpsError('invalid-argument', error)
    }
  })