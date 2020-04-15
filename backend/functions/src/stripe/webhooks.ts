import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import { stripe } from '../common/stripe'

const db = admin.firestore()
const endpointSecret = 'whsec_...';

// Handle stripe 
export const stripeWebhook = functions.region('asia-east2')
  .https
  .onRequest((req, res) => {
    const sig = req.get('stripe-signature');
    let event;
    try {
      if(!sig) {
        throw new Error("Missing stripe signature header")
      }
      event = stripe.webhooks.constructEvent(req.body, sig, endpointSecret);
    }
    catch (err) {
      res.status(400).send(`Webhook Error: ${err.message}`);
    }

    // Handle event according to type
    switch (event.type) {
      case 'payment_intent.succeeded':
      case 'charge.succeeded':
        const gateRecordId = event.data.object.metadata.gateRecordId;
        console.log(gateRecordId)
        // TODO: update 
        break;
      case 'source.chargeable':
        const source = event.data.object
        console.log(source)
        // TODO: charge
        break;
      default:
        // Unexpected event type
        return res.status(400).end();
    }

    // Return a response to acknowledge receipt of the event
    res.json({ received: true });
  });