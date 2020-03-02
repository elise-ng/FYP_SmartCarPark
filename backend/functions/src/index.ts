import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import moment from 'moment'
import { imgSync as base64ImgSync } from 'base64-img'
import * as os from 'os'
import * as path from 'path'
import * as vision from '@google-cloud/vision';

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
      deviceId: string,
      imageData: string, // base64
      imageTimestamp: string // iso8601
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
      predefinedAcl: 'bucketOwnerFullControl',
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

export const recognizeNumberPlate = functions
  .region('asia-east2')
  .storage
  .bucket('fyp-smartcarpark.appspot.com')
  .object()
  .onFinalize(async (object) => {
    interface Annotation {
      xCoord: number;
      yCoord: number;
      score: number;
      text: string;
    }

    let re = /image\//;
    if (object == undefined || object.contentType == undefined || !re.exec(object.contentType)) {
      return; // Null object, or object is not an image, exiting
    }

    let client = new vision.ImageAnnotatorClient();
    let detections = await client.textDetection(`gs://${object.bucket}/${object.name}`);
    let textDetections = detections.textAnnotations;
    // Get all necessary fields from text annotations
    let annotations: Annotation[] = [];
    for(let anno of textDetections) {
      if(!anno) continue;
      annotations.push({
        xCoord: Math.min(anno.boundingPoly.vertices.map((vertex) => vertex.x)),
        yCoord: Math.min(anno.boundingPoly.vertices.map((vertex) => vertex.y)),
        score: anno.score,
        text: anno.description,
      })
    }
    // Sort text by y coordinates of bounding box
    annotations.sort((a, b) => a.yCoord - b.yCoord);

    // Logging
    for(let anno of annotations) {
      console.log(`Text "${anno.text}" found at (x:${anno.xCoord}, y:${anno.yCoord}) with confidence: ${anno.score}`);
    }

    // Results
    let vehicleNumber: string = annotations.map((anno) => anno.text).join("");
    let averageConfidence: number = annotations.map((anno) => anno.score).reduce((a, b) => a + b) / annotations.length;
    console.log(`Identified vehicle number ${vehicleNumber} with confidence of ${averageConfidence}`);
  });