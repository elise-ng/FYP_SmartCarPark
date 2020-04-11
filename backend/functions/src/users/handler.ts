import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import { stripe } from '../common/stripe'

const db = admin.firestore()

// Create user record
export const createUserRecord = functions
    .region('asia-east2')
    .auth.user().onCreate(async (user) => {
        // Generate stripe customer on user signup
        const customer = await stripe.customers.create({
            phone: user.phoneNumber,
            metadata: {
                uid: user.uid
            }
        })

        // Create user reecord
        await db.collection('userRecords').doc(user.uid).set({
            phoneNumber: user.phoneNumber,
            stripe_customerId: customer.id
        })
    })