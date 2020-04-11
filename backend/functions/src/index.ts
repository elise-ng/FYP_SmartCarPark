/**
 * SDK Refs:
 * - onCall Hook Specs: https://firebase.google.com/docs/functions/callable
 * - Function Error Codes: https://firebase.google.com/docs/reference/functions/providers_https_.html#functionserrorcode
 * - Google Cloud Storage API: https://googleapis.dev/nodejs/storage/latest/index.html
 * - Firestore Hook Specs: https://firebase.google.com/docs/firestore/extend-with-functions
 * - Firestore API: https://googleapis.dev/nodejs/firestore/latest/
 */

import * as admin from 'firebase-admin'
admin.initializeApp()

// IoT
export * from './iot/handler'

// CV
export * from './cv/handler'

// Stripe
export * from './stripe/handler'