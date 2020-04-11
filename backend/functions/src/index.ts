import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import moment from 'moment'
import { imgSync as base64ImgSync } from 'base64-img'
import * as os from 'os'
import * as path from 'path'
import * as vision from '@google-cloud/vision';

admin.initializeApp()
const db = admin.firestore()
const visionClient = new vision.ImageAnnotatorClient();
const stripe = require('stripe')('sk_test_VckSxVd8Rq6sZh81IMU84W9h00XQrbe0jO');

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
    return db.collection('iotStateChanges').add({
      deviceId: context.params.deviceId,
      time: admin.firestore.Timestamp.fromDate(moment(context.timestamp).toDate()),
      previousState,
      newState
    })
  })

export const recognizeLicensePlate = functions
  .region('asia-east2')
  .https
  .onCall(async (data, _) => { // eslint-disable-line no-unused-vars
    function intersects(a, b) {
      var polygons = [a, b];
        var minA, maxA, projected, i, i1, j, minB, maxB;
    
        for (i = 0; i < polygons.length; i++) {
    
            // for each polygon, look at each edge of the polygon, and determine if it separates
            // the two shapes
            var polygon = polygons[i];
            for (i1 = 0; i1 < polygon.length; i1++) {
    
                // grab 2 vertices to create an edge
                var i2 = (i1 + 1) % polygon.length;
                var p1 = polygon[i1];
                var p2 = polygon[i2];
    
                // find the line perpendicular to this edge
                var normal = { x: p2.y - p1.y, y: p1.x - p2.x };
    
                minA = maxA = undefined;
                // for each vertex in the first shape, project it onto the line perpendicular to the edge
                // and keep track of the min and max of these values
                for (j = 0; j < a.length; j++) {
                    projected = normal.x * a[j].x + normal.y * a[j].y;
                    if (!minA || projected < minA) {
                        minA = projected;
                    }
                    if (!maxA || projected > maxA) {
                        maxA = projected;
                    }
                }
    
                // for each vertex in the second shape, project it onto the line perpendicular to the edge
                // and keep track of the min and max of these values
                minB = maxB = undefined;
                for (j = 0; j < b.length; j++) {
                    projected = normal.x * b[j].x + normal.y * b[j].y;
                    if (!minB || projected < minB) {
                        minB = projected;
                    }
                    if (!maxB || projected > maxB) {
                        maxB = projected;
                    }
                }
    
                // if there is no overlap between the projects, the edge we are looking at separates the two
                // polygons, and we know there is no overlap
                if (maxA < minB || maxB < minA) {
                    return false;
                }
            }
        }
        return true;
    }
    
    function buildTextObject(words) {
      let textArray: string[] = []
      let text = ""
      for(let word of words) {
        text += word.symbols.map(symbol => symbol.text).join("")
        let lastSymbol = word.symbols[word.symbols.length - 1]
        if('property' in lastSymbol && 'detectedBreak' in lastSymbol.property && lastSymbol.property.detectedBreak) {
          let type = lastSymbol.property.detectedBreak.type
          if(type === "EOL_SURE_SPACE" || type === "LINE_BREAK") {
            textArray.push((text.match(/[a-zA-Z0-9粵港]+/g) || []).join('')) // Filter out undesired character
            text = ""
          }
        }
      }
      return textArray
    }

    interface Parameters {
      imageGsPath: string,
    }

    // parse params
    const params = data as Parameters
    if (!params.imageGsPath) {
      throw new functions.https.HttpsError('invalid-argument', 'parameter missing')
    }

    const annotateRequest = {
      image: {
        source: {
          imageUri: params.imageGsPath
        }
      },
      features: [
        {
          type: "OBJECT_LOCALIZATION"
        },
        {
          type: "TEXT_DETECTION"
        },
      ],
      imageContext: {
        languageHints: ["zh-Hant-HK"]
      }
    }
  
    let [annotateResponse] = await visionClient.annotateImage(annotateRequest)
    let fullTextAnnotation = annotateResponse.fullTextAnnotation
    let page = fullTextAnnotation.pages[0]
    let blocks = page.blocks
    let width = page.width
    let height = page.height
  
    let objectAnnotations = annotateResponse.localizedObjectAnnotations
    let licensePlateObjects = objectAnnotations.filter(object => object.mid === '/m/01jfm_') // Filter only license plate object
    let texts: string[] = []
  
    for(let element of licensePlateObjects) {
      let objectVertices = element.boundingPoly.normalizedVertices.map(coord => ({x: Math.round(coord.x * width), y: Math.round(coord.y * height)}))
      for(let textBlock of blocks) {
        if(intersects(objectVertices, textBlock.boundingBox.vertices)) {
          texts = buildTextObject(textBlock.paragraphs[0].words)
          break
        }
      }
    }
  
    if(!licensePlateObjects.length || !texts) {
      /// If license plate object is not found, or no valid text blocks are identified
      return {
        success: true,
        license: fullTextAnnotation.text
      }
    }
  
    let mainlandLicense
    let chinaHKLicenseIndex = texts.findIndex(text => text.includes('粵') || text.includes('港'))
    if(chinaHKLicenseIndex > -1) {
      mainlandLicense = texts.splice(chinaHKLicenseIndex, 1)[0]
    }
  
    let license = texts.join('')
  
    if(mainlandLicense) {
      return {
        success: true,
        license: license,
        mainlandLicense: mainlandLicense
      }
    } else {
      return {
        success: true,
        license: license
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
    // Get gate record
    const docRef = await db.collection('gateRecords').doc(params.gateRecordId)
    const doc = await docRef.get()
    const docData = doc.data()
    if(!doc.exists || !docData) {
      return {
        success: false,
        error: "Gate record does not exist"
      }
    }
    // Get entry time of gate record
    const entryTime = docData.entryScanTime.toDate()
    const paytime = Date.now()
    if(paytime < entryTime) {
      return {
        success: false,
        error: "Entry time is in the future"
      }
    }
    // Calculate fee
    let parkingDurationInMinutes = Math.ceil(((paytime - entryTime)/1000)/60)
    // FIXME: HARDCODED MINUTES FOR TESTING
    parkingDurationInMinutes = 128
    /// Fee: First 2 hours $20 per hour, then every hour $50
    const parkingFee = Math.ceil(Math.min(120, parkingDurationInMinutes)/60) * 20 + Math.ceil(Math.max(0, parkingDurationInMinutes - 120)/60) * 50 
    const paymentIntent = await stripe.paymentIntents.create({
      amount: parkingFee,
      currency: 'hkd',
    });
    return {
      success: true,
      clientSecret: paymentIntent.client_secret
    }
  })