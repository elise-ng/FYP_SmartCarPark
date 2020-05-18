# Cloud Functions

Source code for cloud functions used in LIX2's Final Year Project: Smart Car Park

Cloud functions are separated into their own respective folders in `functions/src`:

- `cv/` - License Plate Recognition
- `iot/` - Handles IoT devices' snapshot uploads and database iotStates changes
- `stripe/` - Calculate parking fee, generate payment secrets and provides webhook for Stripe events
- `users/` - Handles Stripe ID generation after user creation

- `common/` - Common modules and objects shared across different cloud functions

## Setting up environment

### Install firebase cli tools

```sh
npm install -g firebase-tools
```

### Login with firebase cli tools

```sh
firebase login
```

### Install node deps

> remember to aloways work with npm in `./functions` dir

```sh
cd functions
npm i
```

## Development workflow

### Deploy to cloud

```sh
firebase deploy --only functions
```

### Invoke functions locally

```sh
export GOOGLE_APPLICATION_CREDENTIALS="path_to_firebase_service_acc_key.json"
firebase functions:shell
```
