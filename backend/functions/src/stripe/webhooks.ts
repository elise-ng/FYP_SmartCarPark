import * as functions from 'firebase-functions'
import * as firestore from '@google-cloud/firestore'
import * as admin from 'firebase-admin'
import { stripe } from '../common/stripe'

const db = admin.firestore()
const endpointSecret = 'whsec_uyk3TTHy4HXzeIhNSg8xjOa0Upx2t5xU'

// Handle stripe 
export const stripeWebhook = functions.region('asia-east2')
  .https
  .onRequest(async (req, res) => {
    const sig = req.get('stripe-signature');
    let event;
    try {
      if (!sig) {
        throw new Error("Missing stripe signature header")
      }
      event = stripe.webhooks.constructEvent(req.rawBody, sig, endpointSecret);
    }
    catch (err) {
      res.status(400).send(`Webhook Error: ${err.message}`);
    }

    // Handle event according to type
    switch (event.type) {
      case 'payment_intent.succeeded':
      case 'charge.succeeded': {
        const gateRecordId = event.data.object.metadata.gateRecordId
        await db.collection('gateRecords').doc(gateRecordId).update({ paymentStatus: "succeeded", paymentTime: firestore.Timestamp.now() })
        break;
      }
      case 'source.chargeable': {
        const source = event.data.object
        await stripe.charges.create({
          amount: source.amount,
          currency: source.currency,
          source: source.id,
          customer: source.metadata.customer,
          metadata: {
            gateRecordId: source.metadata.gateRecordId
          }
        })
        break;
      }
      default:
        // Unexpected event type
        return res.status(400).end();
    }

    // Return a response to acknowledge receipt of the event
    res.json({ received: true });
  });