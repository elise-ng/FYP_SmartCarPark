import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import { stripe } from '../common/stripe'

const db = admin.firestore()

// Creates Stripe PaymentIntent
export const createPaymentIntent = functions
    .region('asia-east2')
    .auth.user().onCreate(async (user) => {
        const customer = await stripe.customers.create({
            phone: user.phoneNumber,
            metadata: {
                uid: user.uid
            }
        })

        await db.collection('userRecord').doc(user.uid).set({
            phoneNumber: user.phoneNumber,
            stripe_customerId: customer.id
        })
    })