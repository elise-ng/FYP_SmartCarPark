import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import moment from 'moment'
import { imgSync as base64ImgSync } from 'base64-img'
import * as os from 'os'
import * as path from 'path'

const db = admin.firestore()

// Lambda function for IoT Client to upload snapshots
export const iotUploadSnapshot = functions
  .region('asia-east2')
  .https
  .onCall(async (data, context) => {
    interface Parameters {
      deviceId: string,
      imageData: string, // base64
      imageTimestamp: string // iso8601
    }
    // check auth
    if (!context.auth) {
      // throw new functions.https.HttpsError('unauthenticated', 'unauthenticated') //FIXME:
    }
    // parse params
    const params = data as Parameters
    if (!params.deviceId || !params.imageData || !params.imageTimestamp) {
      throw new functions.https.HttpsError('invalid-argument', 'parameter missing')
    }
    // decode image and save temp file
    let imageLocalPath: string
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
      predefinedAcl: 'bucketOwnerFullControl'
    })
    // TODO: remove old files
    return {
      success: true,
      imageUrl: file.metadata.mediaLink
    }
  })

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
    return db.collection('iotStateChanges').add({
      deviceId: context.params.deviceId,
      time: admin.firestore.Timestamp.fromDate(moment(context.timestamp).toDate()),
      previousState,
      newState
    })
  })