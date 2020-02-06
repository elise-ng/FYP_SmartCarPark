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
  const imageMoment = moment(params.imageTimestamp)
  // decode image and save temp file
  let imageLocalPath:string 
  try {
    imageLocalPath = base64ImgSync(
      params.imageData, // data
      path.join(os.tmpdir(), params.deviceId), // path
      imageMoment.toISOString() // filename
    )
  } catch (e) {
    console.error(e)
    throw new functions.https.HttpsError('invalid-argument', 'failed to decode image data')
  }
  const imageLocalPathProps = path.parse(imageLocalPath)
  // upload file to cloud storage
  const bucket = admin.storage().bucket('fyp-smartcarpark.appspot.com')
  const [file] = await bucket.upload(imageLocalPath, {
    destination: `iotSnapshots/${params.deviceId}/${imageLocalPathProps.base}`,
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
.firestore.document('iotStates/{documentId}')
.onUpdate(async (change, context) => {
  // parse params
  const previousState = change.before.data()
  const newState = change.after.data()
  // sanity check
  if (!previousState || !newState) { throw new Error('state undefined') }
  if (previousState.deviceId !== newState.deviceId) { throw new Error('states deviceId mismatch') }
  // log change on iotStateChanges collection
  const db = admin.firestore()
  return db.collection('iotStateChanges').add({
    deviceId: previousState.deviceId,
    previousState,
    newState
  })
})
