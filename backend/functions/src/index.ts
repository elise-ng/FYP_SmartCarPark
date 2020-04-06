import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import moment from 'moment'
import { imgSync as base64ImgSync } from 'base64-img'
import * as os from 'os'
import * as path from 'path'

admin.initializeApp()

/**
 * SDK Refs:
 * - onCall Hook Specs: https://firebase.google.com/docs/functions/callable
 * - Function Error Codes: https://firebase.google.com/docs/reference/functions/providers_https_.html#functionserrorcode
 * - Google Cloud Storage API: https://googleapis.dev/nodejs/storage/latest/index.html
 * - Firestore Hook Specs: https://firebase.google.com/docs/firestore/extend-with-functions
 * - Firestore API: https://googleapis.dev/nodejs/firestore/latest/
 */

// Lambda function for IoT Client to upload snapshots
export const iotUploadSnapshot = functions
.region('asia-east2')
.https
.onCall(async (data, context) => {
  interface Parameters {
    deviceId:string,
    imageData:string, // base64
    imageTimestamp:string // iso8601
  }
  // check auth
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'unauthenticated')
  }
  // parse params
  const params = data as Parameters
  if (!params.deviceId || !params.imageData || !params.imageTimestamp) {
    throw new functions.https.HttpsError('invalid-argument', 'parameter missing')
  }
  // decode image and save temp file
  let imageLocalPath:string 
  try {
    imageLocalPath = base64ImgSync(
      params.imageData, // data
      path.join(os.tmpdir(), params.deviceId), // path
      moment(params.imageTimestamp).toISOString() // filename
    )
  } catch (e) {
    console.error(e)
    throw new functions.https.HttpsError('invalid-argument', 'failed to decode image data')
  }
  // upload file to cloud storage
  const bucket = admin.storage().bucket('fyp-smartcarpark.appspot.com')
  const [file] = await bucket.upload(imageLocalPath, {
    destination: `iotSnapshots/${params.deviceId}/${path.parse(imageLocalPath).base}`,
    private: true,
    gzip: true
  })
  // TODO: remove old files
  return {
    success: true,
    imageUrl: file.metadata.mediaLink
  }
})

// Lambda function for logging iotState changes
export const firestoreIotStatesOnUpdate = functions
.region('asia-east2')
.firestore.document('iotStates/{deviceId}')
.onUpdate(async (change, context) => {
  // parse params
  const previousState = change.before.data()
  const newState = change.after.data()
  // sanity check
  if (!context.params.deviceId) { throw new Error('device id missing') }
  if (!previousState || !newState) { throw new Error('state missing') }
  // log change on iotStateChanges collection
  const db = admin.firestore()
  return db.collection('iotStateChanges').add({
    deviceId: context.params.deviceId,
    time: admin.firestore.Timestamp.fromDate(moment(context.timestamp).toDate()),
    previousState,
    newState
  })
})

export const stripePaymentWebhook = functions
.region('asia-east2')
.https
.onRequest(async (req, res) => { // express.js style req and res object
  // handle request as per stripe spec: https://stripe.com/docs/webhooks/build
  // their sample is already using express.js
  console.log(req.body)

  // verify secret, return 403 if not authorized

  // read paymentIntent object to get state, metadata and payment time: https://stripe.com/docs/api/payment_intents
  // update record in our db if paid
  const db = admin.firestore()
  // read metadata object of paymentIntent, which our mobile app should write gateRecord Id inside
  await db.ref(`gateRecords/${gateRecordId}`).update({
    paymentReceived: true
    // should probably write paymentIntent id, amount paid and duration covered here as well? need to review whole payment flow
  })

  res.status(200).json({ // send 3xx if error as per stripe spec
    success: true
  })
})
